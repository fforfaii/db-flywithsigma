SELECT 
  t.TicketID, 
  t.PassengerName, 
  t.SeatNo, 
  t.TicketStatus, 
  f.FlightNo, 
  f.Schedule,
  al.AirlineName,
  al.AirlineCaption
FROM TICKET t
LEFT JOIN FLIGHT f ON t.FlightNo = f.FlightNo AND t.Schedule = f.Schedule
LEFT JOIN AIRLINE al ON al.AirlineName = f.AirlineName;