CREATE OR REPLACE FUNCTION trg_user_purchase()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE verify BOOLEAN;
BEGIN
    SELECT u.VerificationStatus INTO verify
    FROM user u
    WHERE NEW.UserAccountID = u.AccountID;

    IF NOT verify THEN
        RAISE EXCEPTION 'User is not verify';
    ENDIF;

END;
$$

CREATE TRIGGER check_user_purchase
BEFORE INSERT ON PURCHASE
FOR EACH ROW
EXECUTE PROCEDURE trg_user_purchase();