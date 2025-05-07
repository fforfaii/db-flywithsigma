--
-- PostgreSQL database dump
--

-- Dumped from database version 12.22 (Debian 12.22-1.pgdg120+1)
-- Dumped by pg_dump version 12.22 (Debian 12.22-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: bookticket(character varying, character varying, character varying, timestamp without time zone, character varying, integer, integer, character varying, numeric, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.bookticket(p_userid character varying, p_flightno character varying, p_seatno character varying, p_schedule timestamp without time zone, p_passengername character varying, p_checkedbaggage integer, p_cabinbaggage integer, p_gateterminal character varying, p_price numeric, p_registrationno character varying, p_currency character varying, p_paymentmethod character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    newTicketID VARCHAR(10);
    isUnique BOOLEAN DEFAULT FALSE;
    attempts INT DEFAULT 0;
    expTime TIMESTAMP;
    newPaymentID VARCHAR(10);
BEGIN
    expTime := CURRENT_TIMESTAMP + INTERVAL '24 HOURS';

    WHILE NOT isUnique AND attempts < 100 LOOP
        newTicketID := 'T' || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');
        IF NOT EXISTS (SELECT 1 FROM TICKET WHERE TicketID = newTicketID) THEN
            isUnique := TRUE;
        END IF;
        attempts := attempts + 1;
    END LOOP;

    IF NOT isUnique THEN
        RAISE EXCEPTION 'Cannot generate a unique TicketID. Try again.';
    END IF;

    -- Generate PaymentID
    newPaymentID := 'P' || LPAD(FLOOR(RANDOM() * 1000000)::TEXT, 6, '0');

    BEGIN
        -- Start transaction block
        INSERT INTO TICKET (
            TicketID, PassengerName, SeatNo, Schedule, FlightNo, Price, CheckedBaggage, CabinBaggage, GateTerminal, ExpiredAt, RegistrationNo
        ) VALUES (
            newTicketID, p_PassengerName, p_SeatNo, p_Schedule, p_FlightNo, p_Price, p_CheckedBaggage, p_CabinBaggage, p_GateTerminal, expTime, p_RegistrationNo
        );

        -- Insert Payment record
        INSERT INTO PAYMENT (PaymentID, Amount, Currency, PaymentTimeStamp, PaymentMethod, TransactionStatus)
        VALUES (newPaymentID, p_Price, p_Currency, NULL, p_PaymentMethod, 'Pending'); -- Currency, PaymentTimeStamp will be update in payment's part

        -- Insert Purchase with valid PaymentID
        INSERT INTO PURCHASE (UserAccountID, PaymentID, TicketID)
        VALUES (p_UserID, newPaymentID, newTicketID);
        
    EXCEPTION
        WHEN OTHERS THEN
            RAISE NOTICE 'Error occurred. Rolling back...';
            RAISE;
    END;
END;
$$;


ALTER PROCEDURE public.bookticket(p_userid character varying, p_flightno character varying, p_seatno character varying, p_schedule timestamp without time zone, p_passengername character varying, p_checkedbaggage integer, p_cabinbaggage integer, p_gateterminal character varying, p_price numeric, p_registrationno character varying, p_currency character varying, p_paymentmethod character varying) OWNER TO admin;

--
-- Name: cal_total_price(character varying); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.cal_total_price(func_useraccountid character varying) RETURNS numeric
    LANGUAGE plpgsql
    AS $$
DECLARE total_spent DECIMAL(10,2);
BEGIN
    SELECT SUM(p.Amount) INTO total_spent
    FROM PAYMENT p
    NATURAL JOIN PURCHASE pu
    WHERE p.TransactionStatus = 'Success'  -- TODO Need to Update with Parm and Fei version
    AND pu.UserAccountID = func_userAccountID; -- TODO need to check column(attribute) name of pu.userid

    RETURN COALESCE(total_spent, 0);
END;
$$;


ALTER FUNCTION public.cal_total_price(func_useraccountid character varying) OWNER TO admin;

--
-- Name: get_avail_seats(character varying, timestamp without time zone); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.get_avail_seats(func_flightno character varying, func_schedule timestamp without time zone) RETURNS integer
    LANGUAGE plpgsql
    AS $$
    DECLARE total_seats INT;
    DECLARE booked_seats INT;
BEGIN
    SELECT SeatCapacity
    INTO total_seats
    FROM AIRCRAFT A
    JOIN FLIGHT F ON A.RegistrationNo = F.AircraftRegNo -- TODO Update With Parm
    WHERE F.FlightNo = func_flightNo AND F.Schedule = func_Schedule; -- TODO Update With Parm

    SELECT COUNT(*)
    INTO booked_seats
    FROM TICKET t
    WHERE t.FlightNo = func_flightNo AND t.Schedule = func_Schedule AND t.ticketstatus != 'Cancelled';

    RETURN COALESCE(total_seats - booked_seats,0);
END;
$$;


ALTER FUNCTION public.get_avail_seats(func_flightno character varying, func_schedule timestamp without time zone) OWNER TO admin;

--
-- Name: makepayment(character varying, character varying, numeric, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: admin
--

CREATE PROCEDURE public.makepayment(p_userid character varying, p_ticketid character varying, p_amount numeric, p_currency character varying, p_method character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
    existingPaymentID VARCHAR(10);
    expectedAmount DECIMAL(10,2);
    currentStatus VARCHAR(20);
BEGIN

    SELECT PaymentID INTO existingPaymentID
    FROM PURCHASE
    WHERE TicketID = p_TicketID AND UserAccountID = p_UserID;

    -- ตรวจสอบว่ามีหรือไม่
    IF existingPaymentID IS NULL THEN
        RAISE EXCEPTION 'No payment record found for TicketID % and UserID %', p_TicketID, p_UserID;
    END IF;

    -- อัปเดตข้อมูลใน PAYMENT
    UPDATE PAYMENT
    SET
        Amount = p_Amount,
        Currency = p_Currency,
        PaymentMethod = p_Method,
        PaymentTimeStamp = CURRENT_TIMESTAMP,
        TransactionStatus = 'Success'
    WHERE PaymentID = existingPaymentID;

    -- อัปเดตสถานะตั๋ว
    UPDATE TICKET
    SET TicketStatus = 'Confirmed'
    WHERE TicketID = p_TicketID;
END;
$$;


ALTER PROCEDURE public.makepayment(p_userid character varying, p_ticketid character varying, p_amount numeric, p_currency character varying, p_method character varying) OWNER TO admin;

--
-- Name: trg_prevent_invalid_booking(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.trg_prevent_invalid_booking() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE available INT;
BEGIN
    SELECT get_avail_seats(NEW.FlightNo,NEW.Schedule)
    INTO available;

    IF available <= 0 THEN
        RAISE EXCEPTION 'Flight is full';
    END IF;

    IF NEW.Schedule <= NOW() THEN
        RAISE EXCEPTION 'Flight is already departed';
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_prevent_invalid_booking() OWNER TO admin;

--
-- Name: trg_user_purchase(); Type: FUNCTION; Schema: public; Owner: admin
--

CREATE FUNCTION public.trg_user_purchase() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE 
    verify BOOLEAN;
    existingPaymentID VARCHAR(10);
    expectedAmount DECIMAL(10,2);
    currentStatus VARCHAR(20);
BEGIN
    -- Check User Verification
    SELECT u.VerificationStatus INTO verify
    FROM app_user u
    WHERE NEW.UserAccountID = u.AccountID;
    
    IF NOT verify THEN
        RAISE EXCEPTION 'User is not verified';
    END IF;

    -- Check that if payment already paid
    SELECT TransactionStatus INTO currentStatus
    FROM PAYMENT
    WHERE PaymentID = NEW.paymentid;

    IF currentStatus = 'Success' THEN
        RAISE EXCEPTION 'Payment has already been completed.';
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.trg_user_purchase() OWNER TO admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: account; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.account (
    accountid character varying(10) NOT NULL,
    accountpassword character varying(100) NOT NULL,
    firstname character varying(50) NOT NULL,
    lastname character varying(50) NOT NULL
);


ALTER TABLE public.account OWNER TO admin;

--
-- Name: admin; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.admin (
    accountid character varying(10) NOT NULL,
    ipaddress character varying(45) NOT NULL
);


ALTER TABLE public.admin OWNER TO admin;

--
-- Name: aircraft; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.aircraft (
    registrationno character varying(20) NOT NULL,
    airlinename character varying(100),
    seatcapacity integer,
    modelname character varying(50),
    CONSTRAINT aircraft_seatcapacity_check CHECK ((seatcapacity > 0))
);


ALTER TABLE public.aircraft OWNER TO admin;

--
-- Name: airline; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.airline (
    airlinename character varying(100) NOT NULL,
    airlinecaption character varying(100),
    website character varying(100),
    amountofaircraft integer,
    CONSTRAINT airline_amountofaircraft_check CHECK ((amountofaircraft >= 0))
);


ALTER TABLE public.airline OWNER TO admin;

--
-- Name: airline_message; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.airline_message (
    airlinename character varying(100) NOT NULL,
    adminaccountid character varying(20) NOT NULL,
    airlinemessagetext text NOT NULL
);


ALTER TABLE public.airline_message OWNER TO admin;

--
-- Name: airline_tel_no; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.airline_tel_no (
    airlinename character varying(100) NOT NULL,
    telno character varying(20) NOT NULL
);


ALTER TABLE public.airline_tel_no OWNER TO admin;

--
-- Name: airport; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.airport (
    airportid character(3) NOT NULL,
    airportname character varying(100),
    city character varying(50),
    country character varying(50)
);


ALTER TABLE public.airport OWNER TO admin;

--
-- Name: app_user; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.app_user (
    accountid character varying(10) NOT NULL,
    citizenid character varying(20),
    passportno character varying(20),
    email character varying(100),
    verificationstatus boolean DEFAULT false,
    country character varying(50) NOT NULL
);


ALTER TABLE public.app_user OWNER TO admin;

--
-- Name: assigned_to; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.assigned_to (
    useraccountid character varying(10) NOT NULL,
    flightno character varying(10) NOT NULL,
    schedule timestamp without time zone NOT NULL
);


ALTER TABLE public.assigned_to OWNER TO admin;

--
-- Name: cabinclass; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.cabinclass (
    registrationno character varying(20) NOT NULL,
    class character varying(20) NOT NULL,
    CONSTRAINT cabinclass_class_check CHECK (((class)::text = ANY ((ARRAY['Economy'::character varying, 'Business'::character varying, 'First Class'::character varying])::text[])))
);


ALTER TABLE public.cabinclass OWNER TO admin;

--
-- Name: connected_flight; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.connected_flight (
    flightno character varying(10) NOT NULL,
    schedule timestamp without time zone NOT NULL
);


ALTER TABLE public.connected_flight OWNER TO admin;

--
-- Name: connected_flight_transit; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.connected_flight_transit (
    flightno character varying(10) NOT NULL,
    schedule timestamp without time zone NOT NULL,
    transitcity character varying(20) NOT NULL,
    transittime time without time zone NOT NULL
);


ALTER TABLE public.connected_flight_transit OWNER TO admin;

--
-- Name: contact; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.contact (
    adminaccountid character varying(10) NOT NULL,
    airlinename character varying(100) NOT NULL,
    contactstatus character varying(20) DEFAULT 'Open'::character varying,
    CONSTRAINT contact_contactstatus_check CHECK (((contactstatus)::text = ANY ((ARRAY['Open'::character varying, 'InProgress'::character varying, 'Resolved'::character varying])::text[])))
);


ALTER TABLE public.contact OWNER TO admin;

--
-- Name: direct_flight; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.direct_flight (
    flightno character varying(10) NOT NULL,
    schedule timestamp without time zone NOT NULL
);


ALTER TABLE public.direct_flight OWNER TO admin;

--
-- Name: domestic_ticket; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.domestic_ticket (
    ticketid character varying(10) NOT NULL,
    citizenid character varying(20) NOT NULL
);


ALTER TABLE public.domestic_ticket OWNER TO admin;

--
-- Name: flight; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.flight (
    flightno character varying(10) NOT NULL,
    schedule timestamp without time zone NOT NULL,
    arrivalairportid character(3) NOT NULL,
    departureairportid character(3) NOT NULL,
    airlinename character varying(100) NOT NULL,
    aircraftregno character varying(20) NOT NULL
);


ALTER TABLE public.flight OWNER TO admin;

--
-- Name: international_ticket; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.international_ticket (
    ticketid character varying(10) NOT NULL,
    passportno character varying(20) NOT NULL
);


ALTER TABLE public.international_ticket OWNER TO admin;

--
-- Name: operate; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.operate (
    airportid character(3) NOT NULL,
    airlinename character varying(100) NOT NULL
);


ALTER TABLE public.operate OWNER TO admin;

--
-- Name: payment; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.payment (
    paymentid character varying(10) NOT NULL,
    amount numeric(10,2),
    currency character varying(10) DEFAULT NULL::character varying,
    paymenttimestamp timestamp without time zone,
    paymentmethod character varying(50),
    transactionstatus character varying(20) DEFAULT 'Pending'::character varying,
    CONSTRAINT payment_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payment_currency_check CHECK (((currency)::text = ANY ((ARRAY['USD'::character varying, 'EUR'::character varying, 'JPY'::character varying, 'GBP'::character varying, 'THB'::character varying, 'CNY'::character varying, 'AUD'::character varying, 'CAD'::character varying])::text[]))),
    CONSTRAINT payment_paymentmethod_check CHECK (((paymentmethod)::text = ANY ((ARRAY['Credit/Debit Card'::character varying, 'eBanking'::character varying, 'PayPal'::character varying])::text[]))),
    CONSTRAINT payment_transactionstatus_check CHECK (((transactionstatus)::text = ANY ((ARRAY['Success'::character varying, 'Pending'::character varying, 'Failed'::character varying])::text[])))
);


ALTER TABLE public.payment OWNER TO admin;

--
-- Name: purchase; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.purchase (
    useraccountid character varying(10),
    paymentid character varying(10) NOT NULL,
    ticketid character varying(10) NOT NULL
);


ALTER TABLE public.purchase OWNER TO admin;

--
-- Name: report_to; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.report_to (
    useraccountid character varying(10) NOT NULL,
    adminaccountid character varying(10) NOT NULL,
    reportstatus character varying(20) DEFAULT 'Open'::character varying,
    CONSTRAINT report_to_reportstatus_check CHECK (((reportstatus)::text = ANY ((ARRAY['Open'::character varying, 'InProgress'::character varying, 'Resolved'::character varying])::text[])))
);


ALTER TABLE public.report_to OWNER TO admin;

--
-- Name: seat; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.seat (
    aircraftregno character varying(10) NOT NULL,
    seatno character varying(10) NOT NULL,
    seattype character varying(20),
    CONSTRAINT seat_seattype_check CHECK (((seattype)::text = ANY ((ARRAY['Economy'::character varying, 'Business'::character varying, 'First Class'::character varying])::text[])))
);


ALTER TABLE public.seat OWNER TO admin;

--
-- Name: ticket; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.ticket (
    ticketid character varying(10) NOT NULL,
    passengername character varying(100) NOT NULL,
    seatno character varying(10) NOT NULL,
    schedule timestamp without time zone,
    flightno character varying(10) NOT NULL,
    price numeric(10,2) NOT NULL,
    ticketstatus character varying(20) DEFAULT 'Pending'::character varying,
    checkedbaggage integer DEFAULT 0,
    cabinbaggage integer DEFAULT 0,
    gateterminal character varying(10),
    createdat timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    expiredat timestamp without time zone,
    registrationno character varying(20) NOT NULL,
    CONSTRAINT ticket_cabinbaggage_check CHECK ((cabinbaggage >= 0)),
    CONSTRAINT ticket_checkedbaggage_check CHECK ((checkedbaggage >= 0)),
    CONSTRAINT ticket_price_check CHECK ((price >= (0)::numeric)),
    CONSTRAINT ticket_ticketstatus_check CHECK (((ticketstatus)::text = ANY ((ARRAY['Confirmed'::character varying, 'Cancelled'::character varying, 'Pending'::character varying])::text[])))
);


ALTER TABLE public.ticket OWNER TO admin;

--
-- Name: user_message; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.user_message (
    useraccountid character varying(10) NOT NULL,
    adminaccountid character varying(10) NOT NULL,
    usermessage text NOT NULL
);


ALTER TABLE public.user_message OWNER TO admin;

--
-- Name: user_tel_no; Type: TABLE; Schema: public; Owner: admin
--

CREATE TABLE public.user_tel_no (
    accountid character varying(20) NOT NULL,
    tel character varying(20) NOT NULL
);


ALTER TABLE public.user_tel_no OWNER TO admin;

--
-- Data for Name: account; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.account (accountid, accountpassword, firstname, lastname) FROM stdin;
A001	pass123	John	Doe
A002	secure456	Jane	Smith
A003	admin123	anna	admin
A004	admin456	apple	admin
A005	user555	Chatrin	Verygood
\.


--
-- Data for Name: admin; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.admin (accountid, ipaddress) FROM stdin;
A003	123.345.4.5
A004	122.446.5.4
\.


--
-- Data for Name: aircraft; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.aircraft (registrationno, airlinename, seatcapacity, modelname) FROM stdin;
HS-FS001	FlySigma	180	Airbus A320
JA123	FlyJapan	300	Boeing 787
\.


--
-- Data for Name: airline; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.airline (airlinename, airlinecaption, website, amountofaircraft) FROM stdin;
FlySigma	Fly with Comfort	www.flysigma.com	10
FlyJapan	Fly with us	www.flyjapan.com	20
\.


--
-- Data for Name: airline_message; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.airline_message (airlinename, adminaccountid, airlinemessagetext) FROM stdin;
FlySigma	A003	We are updating our fleet this year.
FlyJapan	A004	We love u.
\.


--
-- Data for Name: airline_tel_no; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.airline_tel_no (airlinename, telno) FROM stdin;
FlySigma	+6623456789
FlyJapan	+0101010101
\.


--
-- Data for Name: airport; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.airport (airportid, airportname, city, country) FROM stdin;
BKK	Suvarnabhumi Airport	Bangkok	Thailand
HND	Haneda Airport	Tokyo	Japan
OSK	Osaka Airport	Osaka	Japan
PVG	Shanghai Airport	Shanghai	China
DMK	Donmueang Airport	Bangkok	Thailand
\.


--
-- Data for Name: app_user; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.app_user (accountid, citizenid, passportno, email, verificationstatus, country) FROM stdin;
A002	1234567890123	P9193939	jane@example.com	t	Thailand
A001	1030204949495	P1234567	john@example.com	t	Japan
A005	1234567890155	P9193967	chat55@gmail.com	t	China
\.


--
-- Data for Name: assigned_to; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.assigned_to (useraccountid, flightno, schedule) FROM stdin;
A002	FS100	2025-05-01 10:00:00
A001	FJ200	2025-06-01 11:00:00
\.


--
-- Data for Name: cabinclass; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.cabinclass (registrationno, class) FROM stdin;
HS-FS001	Economy
JA123	Business
\.


--
-- Data for Name: connected_flight; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.connected_flight (flightno, schedule) FROM stdin;
FJ200	2025-06-01 11:00:00
\.


--
-- Data for Name: connected_flight_transit; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.connected_flight_transit (flightno, schedule, transitcity, transittime) FROM stdin;
FS100	2025-05-01 10:00:00	Chiang Mai	01:00:00
FJ200	2025-06-01 11:00:00	Osaka	02:00:00
FJ200	2025-06-01 11:00:00	Shanghai	01:00:00
\.


--
-- Data for Name: contact; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.contact (adminaccountid, airlinename, contactstatus) FROM stdin;
A003	FlySigma	Open
A004	FlyJapan	Open
\.


--
-- Data for Name: direct_flight; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.direct_flight (flightno, schedule) FROM stdin;
FS100	2025-05-01 10:00:00
\.


--
-- Data for Name: domestic_ticket; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.domestic_ticket (ticketid, citizenid) FROM stdin;
T001	1234567890123
\.


--
-- Data for Name: flight; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.flight (flightno, schedule, arrivalairportid, departureairportid, airlinename, aircraftregno) FROM stdin;
FS100	2025-05-01 10:00:00	BKK	DMK	FlySigma	HS-FS001
FJ200	2025-06-01 11:00:00	BKK	HND	FlyJapan	JA123
\.


--
-- Data for Name: international_ticket; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.international_ticket (ticketid, passportno) FROM stdin;
T002	P1234567
\.


--
-- Data for Name: operate; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.operate (airportid, airlinename) FROM stdin;
BKK	FlySigma
HND	FlyJapan
\.


--
-- Data for Name: payment; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.payment (paymentid, amount, currency, paymenttimestamp, paymentmethod, transactionstatus) FROM stdin;
P001	500.00	THB	2025-04-01 12:05:00	Credit/Debit Card	Success
P002	2500.00	THB	2025-04-01 13:00:00	eBanking	Pending
P078258	7800.89	THB	2025-05-06 18:28:30.545099	PayPal	Success
\.


--
-- Data for Name: purchase; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.purchase (useraccountid, paymentid, ticketid) FROM stdin;
A002	P001	T001
A001	P002	T002
A005	P078258	T779820
\.


--
-- Data for Name: report_to; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.report_to (useraccountid, adminaccountid, reportstatus) FROM stdin;
A002	A003	Open
A001	A004	Open
\.


--
-- Data for Name: seat; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.seat (aircraftregno, seatno, seattype) FROM stdin;
HS-FS001	12A	Economy
JA123	55B	Business
HS-FS001	5F	Business
\.


--
-- Data for Name: ticket; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.ticket (ticketid, passengername, seatno, schedule, flightno, price, ticketstatus, checkedbaggage, cabinbaggage, gateterminal, createdat, expiredat, registrationno) FROM stdin;
T001	Jane Smith	12A	2025-05-01 10:00:00	FS100	500.00	Confirmed	1	1	A1	2025-04-01 12:00:00	2025-05-01 09:00:00	HS-FS001
T002	John Doe	55B	2025-06-01 11:00:00	FJ200	2500.00	Confirmed	1	1	A5	2025-04-01 12:00:00	2025-05-01 09:00:00	JA123
T779820	Chatrin Verygood	5F	2025-05-01 10:00:00	FS100	7800.89	Confirmed	20	7	A2	2025-05-06 18:27:51.046861	2025-05-07 18:27:51.046861	HS-FS001
\.


--
-- Data for Name: user_message; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.user_message (useraccountid, adminaccountid, usermessage) FROM stdin;
A002	A004	I need help with my ticket.
\.


--
-- Data for Name: user_tel_no; Type: TABLE DATA; Schema: public; Owner: admin
--

COPY public.user_tel_no (accountid, tel) FROM stdin;
A002	+66891234567
\.


--
-- Name: account account_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.account
    ADD CONSTRAINT account_pkey PRIMARY KEY (accountid);


--
-- Name: admin admin_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_pkey PRIMARY KEY (accountid);


--
-- Name: aircraft aircraft_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aircraft
    ADD CONSTRAINT aircraft_pkey PRIMARY KEY (registrationno);


--
-- Name: airline_message airline_message_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.airline_message
    ADD CONSTRAINT airline_message_pkey PRIMARY KEY (airlinename, adminaccountid, airlinemessagetext);


--
-- Name: airline airline_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.airline
    ADD CONSTRAINT airline_pkey PRIMARY KEY (airlinename);


--
-- Name: airport airport_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.airport
    ADD CONSTRAINT airport_pkey PRIMARY KEY (airportid);


--
-- Name: app_user app_user_citizenid_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_citizenid_key UNIQUE (citizenid);


--
-- Name: app_user app_user_email_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_email_key UNIQUE (email);


--
-- Name: app_user app_user_passportno_key; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_passportno_key UNIQUE (passportno);


--
-- Name: app_user app_user_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_pkey PRIMARY KEY (accountid);


--
-- Name: assigned_to assigned_to_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.assigned_to
    ADD CONSTRAINT assigned_to_pkey PRIMARY KEY (useraccountid, flightno, schedule);


--
-- Name: contact contact_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.contact
    ADD CONSTRAINT contact_pkey PRIMARY KEY (adminaccountid, airlinename);


--
-- Name: domestic_ticket domestic_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.domestic_ticket
    ADD CONSTRAINT domestic_ticket_pkey PRIMARY KEY (ticketid);


--
-- Name: international_ticket international_ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.international_ticket
    ADD CONSTRAINT international_ticket_pkey PRIMARY KEY (ticketid);


--
-- Name: operate operate_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.operate
    ADD CONSTRAINT operate_pkey PRIMARY KEY (airportid, airlinename);


--
-- Name: payment payment_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_pkey PRIMARY KEY (paymentid);


--
-- Name: cabinclass pk_cabin; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cabinclass
    ADD CONSTRAINT pk_cabin PRIMARY KEY (registrationno, class);


--
-- Name: connected_flight pk_connected_flight; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.connected_flight
    ADD CONSTRAINT pk_connected_flight PRIMARY KEY (flightno, schedule);


--
-- Name: connected_flight_transit pk_connected_flight_transit; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.connected_flight_transit
    ADD CONSTRAINT pk_connected_flight_transit PRIMARY KEY (flightno, schedule, transitcity, transittime);


--
-- Name: direct_flight pk_direct_flight; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.direct_flight
    ADD CONSTRAINT pk_direct_flight PRIMARY KEY (flightno, schedule);


--
-- Name: flight pk_flight; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.flight
    ADD CONSTRAINT pk_flight PRIMARY KEY (flightno, schedule);


--
-- Name: seat pk_seat; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.seat
    ADD CONSTRAINT pk_seat PRIMARY KEY (aircraftregno, seatno);


--
-- Name: airline_tel_no pk_tel; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.airline_tel_no
    ADD CONSTRAINT pk_tel PRIMARY KEY (airlinename, telno);


--
-- Name: purchase purchase_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_pkey PRIMARY KEY (paymentid, ticketid);


--
-- Name: report_to report_to_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.report_to
    ADD CONSTRAINT report_to_pkey PRIMARY KEY (useraccountid, adminaccountid);


--
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (ticketid);


--
-- Name: user_message user_message_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_message
    ADD CONSTRAINT user_message_pkey PRIMARY KEY (useraccountid, adminaccountid, usermessage);


--
-- Name: user_tel_no user_tel_no_pkey; Type: CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_tel_no
    ADD CONSTRAINT user_tel_no_pkey PRIMARY KEY (accountid, tel);


--
-- Name: idx_airport_city_country; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_airport_city_country ON public.airport USING btree (city, country);


--
-- Name: idx_arrival_airport_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_arrival_airport_id ON public.flight USING btree (arrivalairportid);


--
-- Name: idx_departure_airport_id; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_departure_airport_id ON public.flight USING btree (departureairportid);


--
-- Name: idx_flightno; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_flightno ON public.flight USING btree (flightno);


--
-- Name: idx_schedule; Type: INDEX; Schema: public; Owner: admin
--

CREATE INDEX idx_schedule ON public.flight USING btree (schedule);


--
-- Name: ticket adding_new_ticket; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER adding_new_ticket BEFORE INSERT ON public.ticket FOR EACH ROW EXECUTE FUNCTION public.trg_prevent_invalid_booking();


--
-- Name: purchase check_user_purchase; Type: TRIGGER; Schema: public; Owner: admin
--

CREATE TRIGGER check_user_purchase BEFORE INSERT ON public.purchase FOR EACH ROW EXECUTE FUNCTION public.trg_user_purchase();


--
-- Name: admin admin_accountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.admin
    ADD CONSTRAINT admin_accountid_fkey FOREIGN KEY (accountid) REFERENCES public.account(accountid) ON DELETE CASCADE;


--
-- Name: aircraft aircraft_airlinename_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.aircraft
    ADD CONSTRAINT aircraft_airlinename_fkey FOREIGN KEY (airlinename) REFERENCES public.airline(airlinename) ON DELETE CASCADE;


--
-- Name: airline_message airline_message_adminaccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.airline_message
    ADD CONSTRAINT airline_message_adminaccountid_fkey FOREIGN KEY (adminaccountid) REFERENCES public.admin(accountid);


--
-- Name: airline_message airline_message_airlinename_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.airline_message
    ADD CONSTRAINT airline_message_airlinename_fkey FOREIGN KEY (airlinename) REFERENCES public.airline(airlinename);


--
-- Name: airline_tel_no airline_tel_no_airlinename_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.airline_tel_no
    ADD CONSTRAINT airline_tel_no_airlinename_fkey FOREIGN KEY (airlinename) REFERENCES public.airline(airlinename) ON DELETE CASCADE;


--
-- Name: app_user app_user_accountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.app_user
    ADD CONSTRAINT app_user_accountid_fkey FOREIGN KEY (accountid) REFERENCES public.account(accountid) ON DELETE CASCADE;


--
-- Name: assigned_to assigned_to_flightno_schedule_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.assigned_to
    ADD CONSTRAINT assigned_to_flightno_schedule_fkey FOREIGN KEY (flightno, schedule) REFERENCES public.flight(flightno, schedule);


--
-- Name: assigned_to assigned_to_useraccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.assigned_to
    ADD CONSTRAINT assigned_to_useraccountid_fkey FOREIGN KEY (useraccountid) REFERENCES public.app_user(accountid);


--
-- Name: cabinclass cabinclass_registrationno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.cabinclass
    ADD CONSTRAINT cabinclass_registrationno_fkey FOREIGN KEY (registrationno) REFERENCES public.aircraft(registrationno) ON DELETE CASCADE;


--
-- Name: connected_flight connected_flight_flightno_schedule_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.connected_flight
    ADD CONSTRAINT connected_flight_flightno_schedule_fkey FOREIGN KEY (flightno, schedule) REFERENCES public.flight(flightno, schedule);


--
-- Name: connected_flight_transit connected_flight_transit_flightno_schedule_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.connected_flight_transit
    ADD CONSTRAINT connected_flight_transit_flightno_schedule_fkey FOREIGN KEY (flightno, schedule) REFERENCES public.flight(flightno, schedule);


--
-- Name: contact contact_adminaccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.contact
    ADD CONSTRAINT contact_adminaccountid_fkey FOREIGN KEY (adminaccountid) REFERENCES public.admin(accountid) ON DELETE CASCADE;


--
-- Name: contact contact_airlinename_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.contact
    ADD CONSTRAINT contact_airlinename_fkey FOREIGN KEY (airlinename) REFERENCES public.airline(airlinename);


--
-- Name: direct_flight direct_flight_flightno_schedule_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.direct_flight
    ADD CONSTRAINT direct_flight_flightno_schedule_fkey FOREIGN KEY (flightno, schedule) REFERENCES public.flight(flightno, schedule);


--
-- Name: domestic_ticket domestic_ticket_ticketid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.domestic_ticket
    ADD CONSTRAINT domestic_ticket_ticketid_fkey FOREIGN KEY (ticketid) REFERENCES public.ticket(ticketid) ON DELETE CASCADE;


--
-- Name: flight flight_aircraftregno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_aircraftregno_fkey FOREIGN KEY (aircraftregno) REFERENCES public.aircraft(registrationno);


--
-- Name: flight flight_airlinename_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.flight
    ADD CONSTRAINT flight_airlinename_fkey FOREIGN KEY (airlinename) REFERENCES public.airline(airlinename);


--
-- Name: international_ticket international_ticket_ticketid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.international_ticket
    ADD CONSTRAINT international_ticket_ticketid_fkey FOREIGN KEY (ticketid) REFERENCES public.ticket(ticketid) ON DELETE CASCADE;


--
-- Name: operate operate_airlinename_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.operate
    ADD CONSTRAINT operate_airlinename_fkey FOREIGN KEY (airlinename) REFERENCES public.airline(airlinename);


--
-- Name: operate operate_airportid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.operate
    ADD CONSTRAINT operate_airportid_fkey FOREIGN KEY (airportid) REFERENCES public.airport(airportid);


--
-- Name: purchase purchase_paymentid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_paymentid_fkey FOREIGN KEY (paymentid) REFERENCES public.payment(paymentid);


--
-- Name: purchase purchase_ticketid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_ticketid_fkey FOREIGN KEY (ticketid) REFERENCES public.ticket(ticketid);


--
-- Name: purchase purchase_useraccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.purchase
    ADD CONSTRAINT purchase_useraccountid_fkey FOREIGN KEY (useraccountid) REFERENCES public.app_user(accountid);


--
-- Name: report_to report_to_adminaccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.report_to
    ADD CONSTRAINT report_to_adminaccountid_fkey FOREIGN KEY (adminaccountid) REFERENCES public.admin(accountid) ON DELETE CASCADE;


--
-- Name: report_to report_to_useraccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.report_to
    ADD CONSTRAINT report_to_useraccountid_fkey FOREIGN KEY (useraccountid) REFERENCES public.app_user(accountid) ON DELETE CASCADE;


--
-- Name: seat seat_aircraftregno_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.seat
    ADD CONSTRAINT seat_aircraftregno_fkey FOREIGN KEY (aircraftregno) REFERENCES public.aircraft(registrationno) ON DELETE CASCADE;


--
-- Name: ticket ticket_flightno_schedule_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_flightno_schedule_fkey FOREIGN KEY (flightno, schedule) REFERENCES public.flight(flightno, schedule) ON DELETE CASCADE;


--
-- Name: user_message user_message_adminaccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_message
    ADD CONSTRAINT user_message_adminaccountid_fkey FOREIGN KEY (adminaccountid) REFERENCES public.admin(accountid) ON DELETE CASCADE;


--
-- Name: user_message user_message_useraccountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_message
    ADD CONSTRAINT user_message_useraccountid_fkey FOREIGN KEY (useraccountid) REFERENCES public.app_user(accountid) ON DELETE CASCADE;


--
-- Name: user_tel_no user_tel_no_accountid_fkey; Type: FK CONSTRAINT; Schema: public; Owner: admin
--

ALTER TABLE ONLY public.user_tel_no
    ADD CONSTRAINT user_tel_no_accountid_fkey FOREIGN KEY (accountid) REFERENCES public.app_user(accountid);


--
-- PostgreSQL database dump complete
--

