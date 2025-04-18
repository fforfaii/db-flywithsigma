-- ACCOUNT
INSERT INTO ACCOUNT
VALUES ('A005', 'user555', 'Chatrin', 'Verygood');

SELECT * FROM ACCOUNT;
-- USER
INSERT INTO APP_USER
VALUES ('A005', '1234567890155', 'P9193967', 'chat55@gmail.com', TRUE, 'China');

SELECT * FROM APP_USER;
-- SEAT
INSERT INTO SEAT 
VALUES ('HS-FS001', '5F', 'Business');

SELECT * FROM SEAT;

CALL BookTicket (
    'A005',
    'FS100',
    '5F',
    '2025-05-01 10:00:00',
    'Chatrin Verygood',
    20,
    7,
    'A2',
    7800.89,
    'HS-FS001',
    'THB',
    'PayPal'
);

SELECT * FROM TICKET;

CALL MakePayment (
    'A005',
    'T927531',
    7800.89,
    'THB',
    'PayPal'
);

SELECT * FROM TICKET;

SELECT * FROM PAYMENT;