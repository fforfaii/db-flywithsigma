-- This will Work only if you run Stored Function before running this
CREATE OR REPLACE FUNCTION trg_prevent_invalid_booking()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
DECLARE available INT;
BEGIN
    SELECT get_avail_seats(NEW.FlightNo,NEW.Schedule)
    INTO available;

    IF available <= 0 THEN
        RAISE EXCEPTION 'Flight is full';
    END IF;

    IF NEW.Schedule <= NOW() THEN
        RAISE EXCEPTION 'Flight is already departed';
    END IF;
    RETURN NEW;
END;
$$;

CREATE TRIGGER adding_new_ticket
BEFORE INSERT ON TICKET
FOR EACH ROW
EXECUTE PROCEDURE trg_prevent_invalid_booking();
