CREATE OR REPLACE FUNCTION get_avail_seats(func_flightNo VARCHAR, func_Schedule TIMESTAMP) -- TODO Update DataType with Parm
RETURNS INT
LANGUAGE plpgsql
AS $$
    DECLARE total_seats INT;
    DECLARE booked_seats INT;
BEGIN
    SELECT SeatCapacity
    INTO total_seats
    FROM AIRCRAFT A
    JOIN FLIGHT F ON A.RegistrationNo = F.AircraftRegNo -- TODO Update With Parm
    WHERE F.FlightNo = func_flightNo AND F.Schedule = func_Schedule; -- TODO Update With Parm

    SELECT COUNT(*)
    INTO booked_seats
    FROM TICKET t
    WHERE t.FlightNo = func_flightNo AND t.Schedule = func_Schedule AND t.ticketstatus != 'Cancelled';

    RETURN COALESCE(total_seats - booked_seats,0);
END;
$$;

-- Testing Query (Should show how many seat that are available)
SELECT f.flightNo,f.Schedule,get_avail_seats(f.flightNo,f.Schedule) as totalEmptySeat
FROM flight f;
