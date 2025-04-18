CREATE OR REPLACE FUNCTION trg_user_purchase()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE 
    verify BOOLEAN;
    existingPaymentID VARCHAR(10);
    expectedAmount DECIMAL(10,2);
    currentStatus VARCHAR(20);
BEGIN
    -- Check User Verification
    SELECT u.VerificationStatus INTO verify
    FROM app_user u
    WHERE NEW.UserAccountID = u.AccountID;
    
    IF NOT verify THEN
        RAISE EXCEPTION 'User is not verified';
    END IF;

    -- Check does payment record exist
    SELECT PaymentID INTO existingPaymentID
    FROM PURCHASE
    WHERE ticketid = NEW.ticketid AND PaymentID = NEW.paymentid;

    IF existingPaymentID IS NULL THEN
        RAISE EXCEPTION 'Payment record not found for this User and Ticket.';
    END IF;

    -- Check that if payment already paid
    SELECT TransactionStatus INTO currentStatus
    FROM PAYMENT
    WHERE PaymentID = NEW.paymentid;

    IF currentStatus = 'Success' THEN
        RAISE EXCEPTION 'Payment has already been completed.';
    END IF;

    RETURN NEW;
END;
$$;

CREATE TRIGGER check_user_purchase
BEFORE INSERT ON PURCHASE
FOR EACH ROW
EXECUTE PROCEDURE trg_user_purchase();
