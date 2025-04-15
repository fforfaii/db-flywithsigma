-- Copy & paste all of them in psql pgAdmin

-- สำหรับไฟล์ ACCOUNT.csv
\copy ACCOUNT(AccountID, Password, FirstName, LastName) FROM '/home/flysigma-csv/ACCOUNT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ ADMIN.csv
\copy ADMIN(AccountID, IPAddress) FROM '/home/flysigma-csv/ADMIN.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ AIRCRAFT.csv
\copy AIRCRAFT(RegistrationNo, SeatCapacity, ModelName, CabinClass) FROM '/home/flysigma-csv/AIRCRAFT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ AIRLINE.csv
\copy AIRLINE(AirlineName, AirlineCaption, Website, TelNo) FROM '/home/flysigma-csv/AIRLINE.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ AIRPORT.csv
\copy AIRPORT(AirportID, AirportName, City, Country) FROM '/home/flysigma-csv/AIRPORT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ CONNECTED_FLIGHT.csv
\copy CONNECTED_FLIGHT(FlightNo, TransitCity, TransitTime) FROM '/home/flysigma-csv/CONNECTED_FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ DIRECT_FLIGHT.csv
\copy DIRECT_FLIGHT(FlightNo) FROM '/home/flysigma-csv/DIRECT_FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ DOMESTIC.csv
\copy DOMESTIC(TicketID, CitizenID) FROM '/home/flysigma-csv/DOMESTIC.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ FLIGHT.csv
\copy FLIGHT(FlightNo, Schedule) FROM '/home/flysigma-csv/FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ INTERNATIONAL.csv
\copy INTERNATIONAL(TicketID, PassportNo) FROM '/home/flysigma-csv/INTERNATIONAL.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ PAYMENT.csv
\copy PAYMENT(PaymentID, Amount, Currency, PaymentTimeStamp, PaymentMethod, TransactionStatus) FROM '/home/flysigma-csv/PAYMENT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ SEAT.csv
\copy SEAT(FlightNo, SeatNo, SeatType) FROM '/home/flysigma-csv/SEAT.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ TICKET.csv
\copy TICKET(TicketID, PassengerName, SeatNo, Price, Status, CheckedBaggage, CabinBaggage, GateTerminal, CreatedAt, ExpiredAt) FROM '/home/flysigma-csv/TICKET.csv' DELIMITER ',' CSV HEADER;

-- สำหรับไฟล์ USER.csv (APP_USER)
\copy APP_USER(AccountID, TelNo, CitizenID, PassportNo, Email, Verified, Country) FROM '/home/flysigma-csv/USER.csv' DELIMITER ',' CSV HEADER;
