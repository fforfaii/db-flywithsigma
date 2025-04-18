EXPLAIN
(SELECT 
  t.TicketID, 
  t.PassengerName, 
  t.SeatNo, 
  t.TicketStatus, 
  f.FlightNo, 
  f.Schedule 
FROM TICKET t 
JOIN SEAT s ON t.SeatNo = s.SeatNo 
JOIN FLIGHT f ON s.FlightNo = f.FlightNo
WHERE f.FlightNo = 'FS100')
UNION
(SELECT 
  t.TicketID, 
  t.PassengerName, 
  t.SeatNo, 
  t.TicketStatus, 
  f.FlightNo, 
  f.Schedule 
FROM TICKET t 
JOIN SEAT s ON t.SeatNo = s.SeatNo 
JOIN FLIGHT f ON s.FlightNo = f.FlightNo
WHERE f.FlightNo = 'SK102');
