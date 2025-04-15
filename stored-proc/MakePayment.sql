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
    -- ดึง PaymentID จาก PURCHASE
    SELECT PaymentID INTO existingPaymentID
    FROM PURCHASE
    WHERE UserID = p_UserID AND TicketID = p_TicketID;

    IF existingPaymentID IS NULL THEN
        RAISE EXCEPTION 'Payment record not found for this User and Ticket.';
    END IF;

    -- ดึงสถานะปัจจุบันของ Payment
    SELECT TransactionStatus INTO currentStatus
    FROM PAYMENT
    WHERE PaymentID = existingPaymentID;

    -- ตรวจสอบว่าจ่ายเงินไปแล้วหรือยัง
    IF currentStatus = 'Success' THEN
        RAISE EXCEPTION 'Payment has already been completed.';
    END IF;

    -- ดึงราคาที่ต้องจ่ายจริงจาก TICKET
    SELECT Price INTO expectedAmount
    FROM TICKET
    WHERE TicketID = p_TicketID;

    -- ตรวจสอบว่าจ่ายเงินถูกต้องหรือไม่
    IF expectedAmount IS DISTINCT FROM p_Amount THEN
        RAISE EXCEPTION 'Invalid payment amount: expected %, got %.', expectedAmount, p_Amount;
    END IF;

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
