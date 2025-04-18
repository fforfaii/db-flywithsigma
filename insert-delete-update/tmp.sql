-- INSERT INTO ticket (
--     TicketID,
--     PassengerName,
--     SeatNo,
--     Schedule,
--     FlightNo,
--     Price,
--     TicketStatus,
-- 	checkedbaggage,
-- 	cabinbaggage,
-- 	gateterminal,
--     RegistrationNo
-- ) VALUES (
--     'T123456',
--     'Somchai Prasert',
--     '12A',
--     '2025-04-25 10:00:00',
--     'TG123',
--     3500.00,
--     'Confirmed',
--     'HS-TGW'
-- );

-- INSERT INTO user_tel_no (
--     AccountID,
--     Tel
-- ) VALUES (
--     'A002',
--     '0915054050'
-- )
-- ON CONFLICT (AccountID, Tel)
-- DO NOTHING;

-- select * from user_tel_no;

-- DELETE FROM ticket
-- WHERE TicketID = 'T123456';

-- select * from ticket;

-- UPDATE ticket
-- SET SeatNo = '14B'
-- WHERE TicketID = 'T123456';

-- select * from ticket;


INSERT INTO ticket (TicketID,PassengerName,SeatNo,Schedule,FlightNo,Price,TicketStatus,CheckedBaggage,CabinBaggage,GateTerminal,CreatedAt,ExpiredAt,RegistrationNo)
VALUES ('T003','Jane Nee','13A','2025-05-01 10:00:00','FS100',500.00,'Confirmed',1,1,'A1','2025-04-01 12:00:00','2025-05-01 09:00:00','HS-FS001');

INSERT INTO ticket (TicketID,PassengerName,SeatNo,Schedule,FlightNo,Price,TicketStatus,CheckedBaggage,CabinBaggage,GateTerminal,CreatedAt,ExpiredAt,RegistrationNo)
VALUES ('T003','John Nee','33A','2025-05-01 10:00:00','FS100',500.00,'Confirmed',1,1,'A1','2025-04-01 12:00:00','2025-05-01 09:00:00','HS-FS001');

INSERT INTO APP_USER (AccountID,CitizenID,PassportNo,Email,VerificationStatus,Country)
VALUES ('A004','CID12334','P12345','use1r@example.com',TRUE,'United States');

INSERT INTO APP_USER (AccountID,CitizenID,PassportNo,Email,VerificationStatus,Country)
VALUES ('A005','CID12334','P67891','use2r@example.com',TRUE,'United States');

DELETE FROM ticket
WHERE TicketID = 'T001';

UPDATE seat
SET seattype = 'lala'
WHERE seatno = '12A';