-- For Testing Trigger
-- SELECT *
-- FROM flight;

-- SELECT *
-- FROM airline;

-- SELECT * 
-- FROM aircraft;

-- SELECT * 
-- FROM ticket;

-- Case 1 Flight already depart
INSERT INTO Flight
VALUES ('SG102','2022-10-01 10:00:00','BKK','LAO','Suan Air','OSK-141');

-- DELETE FROM TICKET
-- WHERE ticketid = 'T003';

INSERT INTO TICKET -- This INSERT should should 'ERROR: Flight is already departed'
VALUES ('T003','Chanatda Konchom','14A','2022-10-01 10:00:00','SG102',90,'Pending',20,20,'B2',NOW()::timestamp(0),'2026-10-01 12:00:00','OSK-141');

-- Case 2 Flight is full
INSERT INTO airline
VALUES ('Mew','Fly with Punyapat','https://www.punyapat.com',3);

INSERT INTO aircraft
VALUES ('Mew','Mew',1,'Mewwing');

INSERT INTO Flight
VALUES ('TU82','2030-10-01 10:00:00','BKK','USA','Mew','Mew');

INSERT INTO TICKET
VALUES ('T004','Chanatda Konchom','14A','2030-10-01 10:00:00','TU82',90,'Confirmed',20,20,'B2',NOW()::timestamp(0),'2035-10-01 10:00:00','Mew');

-- SELECT *,get_avail_seats(flightno,schedule) as emptySeat
-- FROM flight
-- WHERE flightno = 'TU82';

INSERT INTO TICKET -- This INSERT Should Show 'ERROR: Flight is full'
VALUES ('T005','Mew Punyapat','15A','2030-10-01 10:00:00','TU82',90,'Pending',20,20,'B2',NOW()::timestamp(0),'2035-10-01 10:00:00','Mew');
