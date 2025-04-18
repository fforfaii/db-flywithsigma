CREATE OR REPLACE PROCEDURE MakePayment(
    IN p_UserID VARCHAR(10),
    IN p_TicketID VARCHAR(10),
    IN p_Amount DECIMAL(10,2),
    IN p_Currency VARCHAR(10),
    IN p_Method VARCHAR(50)
)
LANGUAGE plpgsql
AS
$$
DECLARE
    existingPaymentID VARCHAR(10);
    expectedAmount DECIMAL(10,2);
    currentStatus VARCHAR(20);
BEGIN
    -- อัปเดตข้อมูลใน PAYMENT
    UPDATE PAYMENT
    SET
        Amount = p_Amount,
        Currency = p_Currency,
        PaymentMethod = p_Method,
        PaymentTimeStamp = CURRENT_TIMESTAMP,
        TransactionStatus = 'Success'
    WHERE PaymentID = existingPaymentID;

    -- อัปเดตสถานะตั๋ว
    UPDATE TICKET
    SET Status = 'Confirmed'
    WHERE TicketID = p_TicketID;
END;
$$;
