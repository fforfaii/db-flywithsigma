-- สำหรับเขียนผลลัพธ์ลง final report

-- For Testing Query : BookTicket

SELECT * FROM account;

-- 'U' for User
-- 'A' for Admin
INSERT INTO account
VALUES 
	('U01253', 'passw01253', 'Chanatda', 'Konchom'),
	('U27492', 'passw27492', 'Markie', 'Badshawty'),
	('A73953', 'passw73953', 'Parmie', 'Eieiza');

INSERT INTO admin
VALUES 
	('A73953', '192.168.1.2');

SELECT * FROM admin;

INSERT INTO app_user
VALUES 
	('U01253', '0861357202', 'CZ0006', 'PP00006', '098ff@gmail.com', true, 'China'),
	('U27492', '0889408700', 'CZ0003', 'PP00003', 'mksha3tie@hotmail.com', false, 'Japan');

SELECT * FROM app_user;

INSERT INTO flight
VALUES 
    ('F101', TO_TIMESTAMP('2025-05-02T04:38:46.439051', 'YYYY-MM-DDTHH24:MI:SS.US')),
    ('F102', TO_TIMESTAMP('2025-04-20T04:38:46.439051', 'YYYY-MM-DDTHH24:MI:SS.US')),
    ('F103', TO_TIMESTAMP('2025-04-24T04:38:46.439051', 'YYYY-MM-DDTHH24:MI:SS.US'));

SELECT * FROM flight;

INSERT INTO seat
VALUES
	('F101', '1A', 'Business'),
	('F101', '3C', 'Business'),
	('F102', '2B', 'Economy'),
	('F102', '5D', 'Business'),
	('F103', '10F', 'Business');

SELECT * FROM seat;

-- CALL Procedures
CALL BookTicket(
	'U01253',
	'F102',
	'5D',
	'Chanatda Konchom',
	20,
	7,
	'Gate 4',
	5980.45
);

SELECT * FROM ticket;