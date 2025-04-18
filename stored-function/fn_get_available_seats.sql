CREATE OR REPLACE FUNCTION fn_get_available_seats(flightNo VARCHAR(20), schedule TIMESTAMP) -- TODO Update DataType with Parm
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
    WHERE F.FlightNo = flightNo AND F.Schedule = schedule; -- TODO Update With Parm

    SELECT COUNT(*)
    INTO booked_seats
    FROM TICKET t
    WHERE t.FlightNo = flightNo AND t.Schedule = schedule AND t.Status != 'Cancelled';

    RETURN COALESCE(total_seats - booked_seats,0);
END;
$$