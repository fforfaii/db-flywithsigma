-- ACCOUNT
\copy ACCOUNT(AccountID, AccountPassword, FirstName, LastName) FROM '/home/flywithsigma-csv/ACCOUNT.csv' DELIMITER ',' CSV HEADER;

-- ADMIN
\copy ADMIN(AccountID, IPAddress) FROM '/home/flywithsigma-csv/ADMIN.csv' DELIMITER ',' CSV HEADER;

-- AIRPORT
\copy AIRPORT(AirportID, AirportName, City, Country) FROM '/home/flywithsigma-csv/AIRPORT.csv' DELIMITER ',' CSV HEADER;

-- AIRLINE
\copy AIRLINE(AirlineName, AirlineCaption, Website, AmountOfAircraft) FROM '/home/flywithsigma-csv/AIRLINE.csv' DELIMITER ',' CSV HEADER;

-- AIRLINE_TEL_NO
\copy AIRLINE_TEL_NO(AirlineName, TelNo) FROM '/home/flywithsigma-csv/AIRLINE_TEL_NO.csv' DELIMITER ',' CSV HEADER;

-- AIRCRAFT
\copy AIRCRAFT(RegistrationNo, AirlineName, SeatCapacity, ModelName) FROM '/home/flywithsigma-csv/AIRCRAFT.csv' DELIMITER ',' CSV HEADER;

-- CABINCLASS
\copy CABINCLASS(RegistrationNo, Class) FROM '/home/flywithsigma-csv/CABINCLASS.csv' DELIMITER ',' CSV HEADER;

-- APP_USER
\copy APP_USER(AccountID, CitizenID, PassportNo, Email, VerificationStatus, Country) FROM '/home/flywithsigma-csv/USER.csv' DELIMITER ',' CSV HEADER;

-- SEAT
\copy SEAT(AircraftRegNo, SeatNo, SeatType) FROM '/home/flywithsigma-csv/SEAT.csv' DELIMITER ',' CSV HEADER;

-- FLIGHT
\copy FLIGHT(FlightNo, Schedule, ArrivalAirportID, DepartureAirportID, AirlineName, AircraftRegNo) FROM '/home/flywithsigma-csv/FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- CONNECTED_FLIGHT
\copy CONNECTED_FLIGHT(FlightNo, Schedule) FROM '/home/flywithsigma-csv/CONNECTED_FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- CONNECTED_FLIGHT_TRANSIT
\copy CONNECTED_FLIGHT_TRANSIT(FlightNo, Schedule, TransitCity, TransitTime) FROM '/home/flywithsigma-csv/CONNECTED_FLIGHT_TRANSIT.csv' DELIMITER ',' CSV HEADER;

-- DIRECT_FLIGHT
\copy DIRECT_FLIGHT(FlightNo, Schedule) FROM '/home/flywithsigma-csv/DIRECT_FLIGHT.csv' DELIMITER ',' CSV HEADER;

-- TICKET
\copy TICKET(TicketID, PassengerName, SeatNo, Schedule, FlightNo, Price, TicketStatus, CheckedBaggage, CabinBaggage, GateTerminal, CreatedAt, ExpiredAt, RegistrationNo) FROM '/home/flywithsigma-csv/TICKET.csv' DELIMITER ',' CSV HEADER;

-- DOMESTIC_TICKET
\copy DOMESTIC_TICKET(TicketID, CitizenID) FROM '/home/flywithsigma-csv/DOMESTIC.csv' DELIMITER ',' CSV HEADER;

-- INTERNATIONAL_TICKET
\copy INTERNATIONAL_TICKET(TicketID, PassportNo) FROM '/home/flywithsigma-csv/INTERNATIONAL.csv' DELIMITER ',' CSV HEADER;

-- PAYMENT
\copy PAYMENT(PaymentID, Amount, Currency, PaymentTimeStamp, PaymentMethod, TransactionStatus) FROM '/home/flywithsigma-csv/PAYMENT.csv' DELIMITER ',' CSV HEADER;

-- REPORT_TO
\copy REPORT_TO(UserAccountID, AdminAccountID, ReportStatus) FROM '/home/flywithsigma-csv/REPORT_TO.csv' DELIMITER ',' CSV HEADER;

-- USER_MESSAGE
\copy USER_MESSAGE(UserAccountID, AdminAccountID, UserMessage) FROM '/home/flywithsigma-csv/USER_MESSAGE.csv' DELIMITER ',' CSV HEADER;

-- CONTACT
\copy CONTACT(AdminAccountID, AirlineName, ContactStatus) FROM '/home/flywithsigma-csv/CONTACT.csv' DELIMITER ',' CSV HEADER;

-- PURCHASE
\copy PURCHASE(UserAccountID, PaymentID, TicketID) FROM '/home/flywithsigma-csv/PURCHASE.csv' DELIMITER ',' CSV HEADER;

-- OPERATE
\copy OPERATE(AirportID, AirlineName) FROM '/home/flywithsigma-csv/OPERATE.csv' DELIMITER ',' CSV HEADER;

-- ASSIGNED_TO
\copy ASSIGNED_TO(UserAccountID, FlightNo, Schedule) FROM '/home/flywithsigma-csv/ASSIGNED_TO.csv' DELIMITER ',' CSV HEADER;

-- USER_TEL_NO
\copy USER_TEL_NO(AccountID, Tel) FROM '/home/flywithsigma-csv/USER_TEL_NO.csv' DELIMITER ',' CSV HEADER;

-- AIRLINE_MESSAGE
\copy AIRLINE_MESSAGE(AirlineName, AdminAccountID, AirlineMessageText) FROM '/home/flywithsigma-csv/AIRLINE_MESSAGE.csv' DELIMITER ',' CSV HEADER;
