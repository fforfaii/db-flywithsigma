-- If Ticket exist then add ticket into domestic or international 


CREATE OR REPLACE PROCEDURE BookTicket (
    IN p_UserID VARCHAR(10),
    IN p_FlightNo VARCHAR(10),
    IN p_SeatNo VARCHAR(10),
    IN p_Schedule TIMESTAMP,
    IN p_FlightNo VARCHAR(10),
    IN p_PassengerName VARCHAR(100),
    IN p_CheckedBaggage INT,
    IN p_CabinBaggage INT,
    IN p_GateTerminal VARCHAR(10),
    IN p_Price DECIMAL(10,2),
    IN p_RegistrationNo VARCHAR(20),
    IN p_Currency VARCHAR(10),
    IN p_PaymentMethod VARCHAR(50)
)
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
