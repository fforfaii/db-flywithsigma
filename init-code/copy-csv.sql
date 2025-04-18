-- Copy & paste all of them in psql pgAdmin

-- สำหรับไฟล์ ACCOUNT.csv
\copy ACCOUNT(AccountID, AccountPassword, FirstName, LastName) FROM '/home/flysigma-csv/ACCOUNT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ ADMIN.csv
\copy ADMIN(AccountID, IPAddress) FROM '/home/flysigma-csv/ADMIN.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ USER.csv (APP_USER)
\copy APP_USER(AccountID,CitizenID,PassportNo,Email,VerificationStatus,Country) FROM '/home/flysigma-csv/USER.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ AIRCRAFT.csv
\copy AIRCRAFT(RegistrationNo, AirlineName, SeatCapacity, ModelName) FROM '/home/flysigma-csv/AIRCRAFT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ AIRLINE.csv
\copy AIRLINE(AirlineName, AirlineCaption, Website, AmountOfAircraft) FROM '/home/flysigma-csv/AIRLINE.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ AIRPORT.csv
\copy AIRPORT(AirportID, AirportName, City, Country) FROM '/home/flysigma-csv/AIRPORT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ CONNECTED_FLIGHT.csv
\copy CONNECTED_FLIGHT(FlightNo, Schedule) FROM '/home/flysigma-csv/CONNECTED_FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ DIRECT_FLIGHT.csv
\copy DIRECT_FLIGHT(FlightNo,Schedule) FROM '/home/flysigma-csv/DIRECT_FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ DOMESTIC.csv
\copy DOMESTIC_TICKET(TicketID, CitizenID) FROM '/home/flysigma-csv/DOMESTIC_TICKET.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ FLIGHT.csv
\copy FLIGHT(FlightNo,Schedule,ArrivalAirportID,DepartureAirportID,AirlineName,AircraftRegNo) FROM '/home/flysigma-csv/FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ INTERNATIONAL.csv
\copy INTERNATIONAL_TICKET(TicketID, PassportNo) FROM '/home/flysigma-csv/INTERNATIONAL_TICKET.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ PAYMENT.csv
\copy PAYMENT(PaymentID, Amount, Currency, PaymentTimeStamp, PaymentMethod, TransactionStatus) FROM '/home/flysigma-csv/PAYMENT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ SEAT.csv
\copy SEAT(AircraftRegNo, SeatNo, SeatType) FROM '/home/flysigma-csv/SEAT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ TICKET.csv
\copy TICKET(TicketID,PassengerName,SeatNo,Price,TicketStatus,CheckedBaggage,CabinBaggage,GateTerminal,CreatedAt,ExpiredAt,Schedule,FlightNo,RegistrationNo ) FROM '/home/flysigma-csv/TICKET.csv' DELIMITER ',' CSV HEADER;


-- add copy csv
-- สำหรับไฟล์ AIRLINE_TEL_NO.csv
\copy AIRLINE_TEL_NO(AirlineName, TelNo) FROM '/home/flysigma-csv/AIRLINE_TEL_NO.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ CABINCLASS.csv
\copy CABINCLASS(RegistrationNo, Class) FROM '/home/flysigma-csv/CABINCLASS.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ CONNECTED_FLIGHT_TRANSIT.csv
\copy CONNECTED_FLIGHT_TRANSIT(FlightNo, Schedule, TransitCity, TransitTime) FROM '/home/flysigma-csv/CONNECTED_FLIGHT_TRANSIT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ REPORT_TO.csv
\copy REPORT_TO(UserAccountID, AdminAccountID, ReportStatus) FROM '/home/flysigma-csv/REPORT_TO.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ USER_MESSAGE.csv
\copy USER_MESSAGE(UserAccountID, AdminAccountID, UserMessage) FROM '/home/flysigma-csv/USER_MESSAGE.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ CONTACT.csv
\copy CONTACT(AdminAccountID, AirlineName, ContactStatus) FROM '/home/flysigma-csv/CONTACT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ PURCHASE.csv
\copy PURCHASE(UserAccountID, PaymentID, TicketID) FROM '/home/flysigma-csv/PURCHASE.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ OPERATE.csv
\copy OPERATE(AirportID, AirlineName) FROM '/home/flysigma-csv/OPERATE.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ ASSIGNED_TO.csv
\copy ASSIGNED_TO(UserAccountID, FlightNo, Schedule) FROM '/home/flysigma-csv/ASSIGNED_TO.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ USER_TEL_NO.csv
\copy USER_TEL_NO(AccountID, Tel) FROM '/home/flysigma-csv/USER_TEL_NO.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ AIRLINE_MESSAGE.csv
\copy AIRLINE_MESSAGE(AirlineName, AdminAccountID, AirlineMessageText) FROM '/home/flysigma-csv/AIRLINE_MESSAGE.csv' DELIMITER ',' CSV HEADER;
