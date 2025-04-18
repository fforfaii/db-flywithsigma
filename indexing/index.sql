-- FLIGHT Table
CREATE INDEX idx_flightno
ON FLIGHT(FlightNo);


CREATE INDEX idx_schedule
ON FLIGHT(Schedule);


CREATE INDEX idx_arrival_airport_id
ON FLIGHT(ArrivalAirportID); 


CREATE INDEX idx_departure_airport_id
ON AIRPORT(DepartureAirportID); 


CREATE INDEX idx_airport_city_country
ON AIRPORT(City, Country);