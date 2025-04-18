-- ACCOUNT (password -> AccountPassword)
CREATE TABLE ACCOUNT (
    AccountID VARCHAR(10) PRIMARY KEY,
    AccountPassword VARCHAR(100) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL
);

-- ADMIN
CREATE TABLE ADMIN (
    AccountID VARCHAR(10) PRIMARY KEY,
    IPAddress VARCHAR(45) NOT NULL,
    FOREIGN KEY (AccountID) REFERENCES ACCOUNT(AccountID) ON DELETE CASCADE
);

-- APP_USER (renamed from USER)
CREATE TABLE APP_USER (
    AccountID VARCHAR(10) PRIMARY KEY,
    CitizenID VARCHAR(20) UNIQUE,
    PassportNo VARCHAR(20) UNIQUE,
    Email VARCHAR(100) UNIQUE,
    VerificationStatus BOOLEAN DEFAULT FALSE,
    Country VARCHAR(50) NOT NULL,
    FOREIGN KEY (AccountID) REFERENCES ACCOUNT(AccountID) ON DELETE CASCADE
);

-- AIRPORT
CREATE TABLE AIRPORT (
    AirportID CHAR(3) PRIMARY KEY,
    AirportName VARCHAR(100),
    City VARCHAR(50),
    Country VARCHAR(50)
);

-- AIRLINE
CREATE TABLE AIRLINE (
    AirlineName VARCHAR(100) PRIMARY KEY,
    AirlineCaption VARCHAR(100),
    Website VARCHAR(100),
    AmountOfAircraft INT CHECK (AmountOfAircraft >= 0)
);

-- new table
CREATE TABLE AIRLINE_TEL_NO (
    AirlineName VARCHAR(100) ,
    TelNo VARCHAR(20),
    CONSTRAINT pk_Tel PRIMARY KEY (AirlineName, TelNo),
    FOREIGN KEY (AirlineName) REFERENCES AIRLINE(AirlineName) ON DELETE CASCADE
);

-- AIRCRAFT
CREATE TABLE AIRCRAFT (
    RegistrationNo VARCHAR(20) PRIMARY KEY,
    AirlineName VARCHAR(100),
    SeatCapacity INT CHECK (SeatCapacity > 0),
    ModelName VARCHAR(50),
    FOREIGN KEY (AirlineName) REFERENCES AIRLINE(AirlineName) ON DELETE CASCADE
);

-- new table
CREATE TABLE CABINCLASS (
    RegistrationNo VARCHAR(20) NOT NULL,
    Class VARCHAR(20) CHECK (Class IN ('Economy', 'Business','First Class')),
    CONSTRAINT pk_Cabin PRIMARY KEY (RegistrationNo, Class),
    FOREIGN KEY (RegistrationNo) REFERENCES AIRCRAFT(RegistrationNo) ON DELETE CASCADE
);

-- FLIGHT
CREATE TABLE FLIGHT (
    FlightNo VARCHAR(10),
    Schedule TIMESTAMP,
    ArrivalAirportID CHAR(3) NOT NULL,
    DepartureAirportID CHAR(3) NOT NULL,
    AirlineName VARCHAR(100) NOT NULL,
    AircraftRegNo VARCHAR(20) NOT NULL,
    CONSTRAINT pk_Flight PRIMARY KEY (FlightNo, Schedule),
    FOREIGN KEY (AirlineName) REFERENCES AIRLINE(AirlineName),
    FOREIGN KEY (AircraftRegNo) REFERENCES AIRCRAFT(RegistrationNo)
);

-- CONNECTED_FLIGHT
CREATE TABLE CONNECTED_FLIGHT (
    FlightNo VARCHAR(10),
    Schedule TIMESTAMP,
    CONSTRAINT pk_Connected_Flight PRIMARY KEY (FlightNo, Schedule),
    FOREIGN KEY (FlightNo, Schedule) REFERENCES FLIGHT(FlightNo, Schedule)
);

-- new table
CREATE TABLE CONNECTED_FLIGHT_TRANSIT (
    FlightNo VARCHAR(10),
    Schedule TIMESTAMP,
    TransitCity VARCHAR(20), 
    TransitTime TIME,
    CONSTRAINT pk_Connected_Flight_Transit PRIMARY KEY (FlightNo, Schedule,TransitCity,TransitTime),
    FOREIGN KEY (FlightNo, Schedule) REFERENCES FLIGHT(FlightNo, Schedule)
);

-- DIRECT_FLIGHT
CREATE TABLE DIRECT_FLIGHT (
    FlightNo VARCHAR(10) ,
    Schedule TIMESTAMP,
    CONSTRAINT pk_Direct_Flight PRIMARY KEY (FlightNo, Schedule),
    FOREIGN KEY (FlightNo, Schedule) REFERENCES FLIGHT(FlightNo, Schedule)
);

-- SEAT
CREATE TABLE SEAT (
    AircraftRegNo VARCHAR(10),
    SeatNo VARCHAR(10),
    SeatType VARCHAR(20) CHECK (SeatType IN ('Economy', 'Business','First Class')),
    CONSTRAINT pk_Seat PRIMARY KEY (AircraftRegNo, SeatNo),
    FOREIGN KEY (AircraftRegNo) REFERENCES AIRCRAFT(RegistrationNo) ON DELETE CASCADE
);

-- TICKET (เปลี่ยนชื่อจาก status -> TicketStatus)
CREATE TABLE TICKET (
    TicketID VARCHAR(10) PRIMARY KEY,
    PassengerName VARCHAR(100) NOT NULL,
    SeatNo VARCHAR(10) NOT NULL,
    RegNo VARCHAR(20) NOT NULL,
    Schedule TIMESTAMP,
    FlightNo VARCHAR(10) NOT NULL,
    Price DECIMAL(10,2) NOT NULL CHECK (Price >= 0),
    TicketStatus VARCHAR(20) CHECK (TicketStatus IN ('Confirmed', 'Cancelled', 'Pending')) DEFAULT 'Pending',
    CheckedBaggage INT DEFAULT 0 CHECK (CheckedBaggage >= 0),
    CabinBaggage INT DEFAULT 0 CHECK (CabinBaggage >= 0),
    GateTerminal VARCHAR(10),
    CreatedAt TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    ExpiredAt TIMESTAMP
);


-- DOMESTIC
CREATE TABLE DOMESTIC_TICKET (
    TicketID VARCHAR(10) PRIMARY KEY,
    CitizenID VARCHAR(20) NOT NULL,
    FOREIGN KEY (TicketID) REFERENCES TICKET(TicketID) ON DELETE CASCADE
);

-- INTERNATIONAL
CREATE TABLE INTERNATIONAL_TICKET (
    TicketID VARCHAR(10) PRIMARY KEY,
    PassportNo VARCHAR(20) NOT NULL,
    FOREIGN KEY (TicketID) REFERENCES TICKET(TicketID) ON DELETE CASCADE
);

-- PAYMENT
CREATE TABLE PAYMENT (
    PaymentID VARCHAR(10) PRIMARY KEY,
    Amount DECIMAL(10,2) CHECK (Amount > 0),
    Currency VARCHAR(10) DEFAULT NULL,
    PaymentTimeStamp TIMESTAMP DEFAULT NULL, -- เวลาที่จ่ายเงิน (if Pending then NULL)
    PaymentMethod VARCHAR(50),
    TransactionStatus VARCHAR(20) CHECK (TransactionStatus IN ('Success', 'Pending', 'Failed')) DEFAULT 'Pending'
);

-- REPORT_TO (เปลี่ยนชื่อ status)
CREATE TABLE REPORT_TO (
    UserAccountID VARCHAR(10),
    AdminAccountID VARCHAR(10),
    ReportStatus VARCHAR(20) CHECK (ReportStatus IN ('Open', 'InProgress', 'Resolved')) DEFAULT 'Open',
    PRIMARY KEY (UserAccountID, AdminAccountID),
    FOREIGN KEY (UserAccountID) REFERENCES APP_USER(AccountID) ON DELETE CASCADE,
    FOREIGN KEY (AdminAccountID) REFERENCES ADMIN(AccountID) ON DELETE CASCADE
);

-- new table (message -> User_message)
CREATE TABLE USER_MESSAGE (
    UserAccountID VARCHAR(10),
    AdminAccountID VARCHAR(10),
    UserMessage TEXT,
    PRIMARY KEY (UserAccountID, AdminAccountID, UserMessage),
    FOREIGN KEY (UserAccountID) REFERENCES APP_USER(AccountID) ON DELETE CASCADE,
    FOREIGN KEY (AdminAccountID) REFERENCES ADMIN(AccountID) ON DELETE CASCADE
);

-- CONTACT (status -> ContactStatus)
CREATE TABLE CONTACT (
    AdminAccountID VARCHAR(10),
    AirlineName VARCHAR(100),
    ContactStatus VARCHAR(20) CHECK (ContactStatus IN ('Open', 'InProgress', 'Resolved')) DEFAULT 'Open',
    PRIMARY KEY (AdminAccountID, AirlineName),
    FOREIGN KEY (AdminAccountID) REFERENCES ADMIN(AccountID) ON DELETE CASCADE,
    FOREIGN KEY (AirlineName) REFERENCES AIRLINE(AirlineName)
);

-- -- OWN
-- CREATE TABLE OWN (
--     AirlineName VARCHAR(100),
--     RegistrationNo VARCHAR(20),
--     Amount INT,
--     PRIMARY KEY (AirlineName, RegistrationNo),
--     FOREIGN KEY (AirlineName) REFERENCES AIRLINE(AirlineName),
--     FOREIGN KEY (RegistrationNo) REFERENCES AIRCRAFT(RegistrationNo)
-- );

-- PURCHASE
CREATE TABLE PURCHASE (
    UserAccountID VARCHAR(10),
    PaymentID VARCHAR(10),
    TicketID VARCHAR(10),
    PRIMARY KEY (PaymentID, TicketID),
    FOREIGN KEY (UserAccountID) REFERENCES APP_USER(AccountID),
    FOREIGN KEY (PaymentID) REFERENCES PAYMENT(PaymentID),
    FOREIGN KEY (TicketID) REFERENCES TICKET(TicketID)
);

-- OPERATE
CREATE TABLE OPERATE (
    AirportID CHAR(3),
    AirlineName VARCHAR(100),
    PRIMARY KEY (AirportID, AirlineName),
    FOREIGN KEY (AirportID) REFERENCES AIRPORT(AirportID),
    FOREIGN KEY (AirlineName) REFERENCES AIRLINE(AirlineName)
);

-- -- MANAGE
-- CREATE TABLE MANAGE (
--     AirlineName VARCHAR(100),
--     FlightNo VARCHAR(10),
--     PRIMARY KEY (AirlineName, FlightNo),
--     FOREIGN KEY (AirlineName) REFERENCES AIRLINE(AirlineName),
--     FOREIGN KEY (FlightNo) REFERENCES FLIGHT(FlightNo)
-- );

-- -- CONTAIN
-- CREATE TABLE CONTAIN (
--     RegistrationNo VARCHAR(20),
--     SeatNo VARCHAR(10),
--     Amount INT,
--     PRIMARY KEY (RegistrationNo, SeatNo),
--     FOREIGN KEY (RegistrationNo) REFERENCES AIRCRAFT(RegistrationNo)
-- );

-- ASSIGNED_TO
CREATE TABLE ASSIGNED_TO (
    UserAccountID VARCHAR(10),
    FlightNo VARCHAR(10),
    Schedule TIMESTAMP,
    PRIMARY KEY (UserAccountID, FlightNo, Schedule),
    FOREIGN KEY (UserAccountID) REFERENCES APP_USER(AccountID),
    FOREIGN KEY (FlightNo, Schedule) REFERENCES FLIGHT(FlightNo, Schedule)
);

-- -- DEPART_FROM
-- CREATE TABLE DEPART_FROM (
--     FlightNo VARCHAR(10) PRIMARY KEY,
--     AirportID CHAR(3),
--     FOREIGN KEY (FlightNo) REFERENCES FLIGHT(FlightNo),
--     FOREIGN KEY (AirportID) REFERENCES AIRPORT(AirportID)
-- );

-- -- ARRIVE_AT
-- CREATE TABLE ARRIVE_AT (
--     FlightNo VARCHAR(10) PRIMARY KEY,
--     AirportID CHAR(3),
--     FOREIGN KEY (FlightNo) REFERENCES FLIGHT(FlightNo),
--     FOREIGN KEY (AirportID) REFERENCES AIRPORT(AirportID)
-- );

-- -- BELONG_TO
-- CREATE TABLE BELONG_TO (
--     TicketID VARCHAR(10) PRIMARY KEY,
--     FlightNo VARCHAR(10),
--     FOREIGN KEY (TicketID) REFERENCES TICKET(TicketID),
--     FOREIGN KEY (FlightNo) REFERENCES FLIGHT(FlightNo)
-- );

-- -- OCCUPY
-- CREATE TABLE OCCUPY (
--     TicketID VARCHAR(10) PRIMARY KEY,
--     FlightNo VARCHAR(10),
--     SeatNo VARCHAR(10),
--     FOREIGN KEY (TicketID) REFERENCES TICKET(TicketID),
--     FOREIGN KEY (FlightNo, SeatNo) REFERENCES SEAT(FlightNo, SeatNo)
-- );

-- -- FEATURE
-- CREATE TABLE FEATURE (
--     RegistrationNo VARCHAR(20),
--     FlightNo VARCHAR(10),
--     PRIMARY KEY (RegistrationNo, FlightNo),
--     FOREIGN KEY (RegistrationNo) REFERENCES AIRCRAFT(RegistrationNo),
--     FOREIGN KEY (FlightNo) REFERENCES FLIGHT(FlightNo)
-- );

-- new table
CREATE TABLE USER_TEL_NO (
    AccountID VARCHAR(20),
    Tel VARCHAR(20),
    PRIMARY KEY (AccountID,Tel),
    FOREIGN KEY (AccountID) REFERENCES APP_USER(AccountID)
);

-- new table (text -> AirlineMessageText)
CREATE TABLE AIRLINE_MESSAGE (
    AirlineName VARCHAR(100),
    AdminAccountID VARCHAR(20),
    AirlineMessageText TEXT,
    PRIMARY KEY (AirlineName, AdminAccountID,AirlineMessageText),
    FOREIGN KEY (AirlineName) REFERENCES AIRLINE(AirlineName), --เปลี่ยนเปนอ้้างอิงไปที่airlineแทนairline_tel_no
    FOREIGN KEY (AdminAccountID) REFERENCES ADMIN(AccountID)
);
