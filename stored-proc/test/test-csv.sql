-- สำหรับทดสอบกับข้อมูล .csv

-- Correct BookTicket
CALL BookTicket(
	'A010',
	'F101',
	'1A',
	'Chanatda Konchom',
	20,
	7,
	'Gate 8',
	'4600.00'
);

CALL BookTicket(
    'A007',       -- UserNo
    'F102',      -- FlightNo
    '1B',        -- SeatNo
    'Chat GPT',  -- PassengerName
    15,           -- CheckedBaggage
    3,            -- CabinBaggage
    'Gate 5',     -- GateTerminal
    '5000.00'      -- Price
);

-- Recheck Result
SELECT * FROM ticket;

-- Correct MakePayment
CALL MakePayment(
    'A007',      -- UserID ที่จอง (Chat GPT)
    'T531249',      -- TicketID
    5000.00,     -- จ่ายตรงเป๊ะ
    'THB',
    'CreditCard'
);

-- Invalid Payment (จ่ายเงินไม่ครบ)
CALL MakePayment(
    'A010',		-- (Chanatda Konchom)
    'T328947',
    4000.00,     -- ขาดจากราคาจริง
    'THB',
    'CreditCard'
);

-- Invalid Payment (จ่ายเงินเกิน)
CALL MakePayment(
    'A010',
    'T328947',
    5000.00,     -- เกินจากราคาจริง
    'THB',
    'CreditCard'
);

-- Invalid Payment (จ่ายเงินซ้ำในรายการที่สำเร็จแล้ว)
CALL MakePayment(
    'A007',      -- UserID ที่จอง (Chat GPT)
    'T531249',      -- TicketID
    5000.00,     -- จ่ายตรงเป๊ะ
    'THB',
    'Paypal'
);

-- Recheck Result
SELECT * FROM TICKET WHERE TicketID = 'T010';
SELECT * FROM PAYMENT WHERE PaymentID = (
    SELECT PaymentID FROM PURCHASE WHERE TicketID = 'T010'
);
