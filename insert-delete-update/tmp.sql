INSERT INTO ticket (
    TicketID,
    PassengerName,
    SeatNo,
    Schedule,
    FlightNo,
    Price,
    TicketStatus,
	checkedbaggage,
	cabinbaggage,
	gateterminal,
    RegistrationNo
) VALUES (
    'T123456',
    'Somchai Prasert',
    '12A',
    '2025-04-25 10:00:00',
    'TG123',
    3500.00,
    'Confirmed',
    'HS-TGW'
);

INSERT INTO user_tel_no (
    AccountID,
    Tel
) VALUES (
    'A002',
    '0915054050'
)
ON CONFLICT (AccountID, Tel)
DO NOTHING;

select * from user_tel_no;

DELETE FROM ticket
WHERE TicketID = 'T123456';

select * from ticket;

UPDATE ticket
SET SeatNo = '14B'
WHERE TicketID = 'T123456';

select * from ticket;
