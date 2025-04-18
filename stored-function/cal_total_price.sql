CREATE OR REPLACE FUNCTION cal_total_price(func_userAccountID VARCHAR)
RETURNS DECIMAL(10,2)
LANGUAGE plpgsql
AS $$
DECLARE total_spent DECIMAL(10,2);
BEGIN
    SELECT SUM(p.Amount) INTO total_spent
    FROM PAYMENT p
    NATURAL JOIN PURCHASE pu
    WHERE p.TransactionStatus = 'Success'  -- TODO Need to Update with Parm and Fei version
    AND pu.UserAccountID = func_userAccountID; -- TODO need to check column(attribute) name of pu.userid

    RETURN COALESCE(total_spent, 0);
END;
$$;

-- Testing Query (Should show All account id with their totalSpent)
SELECT accountid,cal_total_price(accountid) as totalSpent
FROM account