CREATE OR REPLACE FUNCTION trg_user_purchase()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE verify BOOLEAN;
BEGIN
    SELECT u.VerificationStatus INTO verify
    FROM app_user u
    WHERE NEW.UserAccountID = u.AccountID;

    IF NOT verify THEN
        RAISE EXCEPTION 'User is not verified';
    ELSE
		UPDATE payment
		SET transactionstatus = 'Success'
		WHERE NEW.paymentid = paymentid;

		UPDATE TICKET
		SET TicketStatus = 'Confirmed' -- Need Recheck
		WHERE NEW.ticketid = ticketid;
	END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER check_user_purchase
BEFORE INSERT ON PURCHASE
FOR EACH ROW
EXECUTE PROCEDURE trg_user_purchase();

-- For Testing Trigger Function
INSERT INTO app_user
VALUES ('A001','9876543210321','Parmzaza','chayaphon33630@gmail.com',false,'Laos');

-- SELECT * FROM airline;

INSERT INTO airline
VALUES ('Suan Air','Fly with OSK','https://www.SuanAir.com',141);

INSERT INTO aircraft
VALUES ('OSK-141','Suan Air',141,'SuanAir-35');

INSERT INTO Flight
VALUES ('SG102','2025-10-01 10:00:00','BKK','LAO','Suan Air','OSK-141');

-- SELECT * FROM TICKET;

INSERT INTO TICKET
VALUES ('T002','Chayaphon Kultanon','13A','2025-10-01 10:00:00','SG102',90000,'Pending',1,1,'B1',NOW()::timestamp(0),NOW()::timestamp(0),'OSK-141');

-- SELECT * FROM Payment;

INSERT INTO PAYMENT
VALUES ('P998',90000,'THB',NOW()::timestamp(0),'Credit Card','Pending');

-- SELECT * FROM Purchase;
-- DELETE FROM PURCHASE
-- WHERE ticketid = 'T002' AND paymentid = 'P998'

INSERT INTO PURCHASE
VALUES ('A001','P998','T002'); -- This Insert Should Show error that 'User is not verify'

SELECT * from app_user;

UPDATE app_user
SET verificationstatus = true
WHERE accountid = 'A001'; -- Verify User

INSERT INTO PURCHASE
VALUES ('A001','P998','T002'); -- This INSERT Should Complete

SELECT *
FROM PAYMENT
WHERE paymentid = 'P998'; -- This transaction status should be updated

SELECT *
FROM TICKET
WHERE ticketid = 'T002'; -- This TicketStatus should be confirmed


