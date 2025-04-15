SELECT 
  t.TicketID, 
  t.PassengerName, 
  t.SeatNo, 
  t.Status, 
  f.FlightNo, 
  f.Schedule 
FROM TICKET t 
LEFT JOIN SEAT s ON t.SeatNo = s.SeatNo 
LEFT JOIN FLIGHT f ON s.FlightNo = f.FlightNo;