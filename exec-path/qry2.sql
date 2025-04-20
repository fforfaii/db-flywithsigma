(SELECT 
  t.TicketID, 
  t.PassengerName, 
  t.SeatNo, 
  f.FlightNo, 
  f.Schedule,
  al.AirlineName,
  al.AirlineCaption
FROM TICKET t
LEFT JOIN FLIGHT f ON t.FlightNo = f.FlightNo AND t.Schedule = f.Schedule
LEFT JOIN AIRLINE al ON al.AirlineName = f.AirlineName
WHERE f.FlightNo = 'FS100')
UNION ALL
(SELECT 
  t.TicketID, 
  t.PassengerName, 
  t.SeatNo, 
  f.FlightNo, 
  f.Schedule,
  al.AirlineName,
  al.AirlineCaption
FROM TICKET t
LEFT JOIN FLIGHT f ON t.FlightNo = f.FlightNo AND t.Schedule = f.Schedule
LEFT JOIN AIRLINE al ON al.AirlineName = f.AirlineName
WHERE f.FlightNo = 'FJ200');