CREATE OR REPLACE FUNCTION cal_total_price(userAccountID VARCHAR)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE total_spent DECIMAL(10,2);
BEGIN
    SELECT SUM(p.Amount) INTO total_spent
    FROM PAYMENT p
    NATURAL JOIN PURCHASE pu
    WHERE p.TransactionStatus = 'Success'  -- TODO Need to Update with Parm and Fei version
    AND pu.UserAccountID = userAccountID; -- TODO need to check column(attribute) name of pu.userid

    RETURN COALESCE(total_spent, 0);
END;
$$