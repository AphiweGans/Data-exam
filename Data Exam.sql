-- Create and select the database, then run DATA6222E1Preload.sql
USE Data6222_Exam;
GO
USE Data6222_Exam;
GO
-- >>> Run DATA6222E1Preload.sql here, then continue below <<<

-- Q1.1
USE Data6222_Exam   
GO

CREATE VIEW LargeBOOKINGs
AS
SELECT
    VenueID,
    ClientID,
    EventStartDate,
    EventEndDate,
    NumberOfAttendees
FROM BOOKING
WHERE YEAR(EventStartDate) = 2026
AND NumberOfAttendees >= 100;
GO

SELECT * FROM dbo.LargeBOOKINGs ORDER BY EventStartDate;   -- 4 rows
GO

-- Q1.2
IF OBJECT_ID('dbo.FindBOOKINGs', 'P') IS NOT NULL DROP PROCEDURE dbo.FindBOOKINGs;
USE StudentNumber_DATA6222_ExamQ1;
GO

CREATE PROCEDURE FindBOOKINGs
    @VenueID VARCHAR(5)
AS
BEGIN
    SELECT
        C.ClientFullName,
        C.ClientContact,
        B.EventStartDate,
        B.EventEndDate,
        B.NumberOfAttendees
    FROM BOOKING B
    INNER JOIN CLIENT C
        ON B.ClientID = C.ClientID
    INNER JOIN VENUE V
        ON B.VenueID = V.VenueID
    WHERE V.VenueID = @VenueID;
END;
GO

-- Q1.3
USE StudentNumber_DATA6222_ExamQ1;
GO

SELECT
    V.VenueID,
    V.VenueName,
    V.VenueAddress,
    CASE
        WHEN COUNT(B.BookingID) > 0
            THEN 'Bookings exist'
        ELSE 'No bookings exist'
    END AS [BOOKING STATUS]
FROM VENUE V
LEFT JOIN BOOKING B
    ON V.VenueID = B.VenueID
GROUP BY
    V.VenueID,
    V.VenueName,
    V.VenueAddress
ORDER BY V.VenueID;

-- Q1.4
USE StudentNumber_DATA6222_ExamQ1;
GO

SELECT
    V.VenueName,
    SUM(B.NumberOfAttendees) AS [TOTAL ATTENDEES]
FROM VENUE V
LEFT JOIN BOOKING B
    ON V.VenueID = B.VenueID
GROUP BY
    V.VenueID,
    V.VenueName
ORDER BY
    SUM(B.NumberOfAttendees) DESC;


-- 1.5
USE StudentNumber_DATA6222_ExamQ1;
GO

SELECT
    V.VenueName
FROM VENUE V
WHERE NOT EXISTS
(
    SELECT 1
    FROM BOOKING B
    WHERE B.VenueID = V.VenueID
);
-- Q2.1
CREATE TABLE EQUIPMENT (
    EQUIPMENT_ID   VARCHAR(5)  NOT NULL PRIMARY KEY,
    EQUIPMENT_NAME VARCHAR(40) NOT NULL
);

CREATE TABLE WAREHOUSE (
    WAREHOUSE_ID   VARCHAR(5)  NOT NULL PRIMARY KEY,
    WAREHOUSE_NAME VARCHAR(20) NOT NULL,
    ADDRESS        VARCHAR(40) NOT NULL
);

CREATE TABLE AVAILABILITY (
    EQUIPMENT_ID VARCHAR(5) NOT NULL FOREIGN KEY REFERENCES EQUIPMENT(EQUIPMENT_ID),
    WAREHOUSE_ID VARCHAR(5) NOT NULL FOREIGN KEY REFERENCES WAREHOUSE(WAREHOUSE_ID),
    QUANTITY     SMALLINT   NOT NULL,
    PRIMARY KEY (EQUIPMENT_ID, WAREHOUSE_ID)
);
GO

-- Q2.2
INSERT INTO EQUIPMENT VALUES
('E001','Football Nets'),('E002','Training Cones'),('E003','Cricket Bats'),
('E004','Tennis Rackets'),('E005','Gym Mats');

INSERT INTO WAREHOUSE VALUES
('W001','Central Sports Depot','15 Loop Street, Cape Town'),
('W002','Northern Supplies','88 Church Street, Polokwane'),
('W003','Coastal Storage','44 Marine Road, Durban'),
('W004','Inland Hub','9 Park Avenue, Bloemfontein'),
('W005','Eastern Depot','61 Oxford Street, East London');

INSERT INTO AVAILABILITY (EQUIPMENT_ID, WAREHOUSE_ID, QUANTITY) VALUES
('E002','W001',20),('E002','W004',12),('E003','W005',7),
('E004','W003',9),('E004','W001',14);
GO

-- Q2.3
ALTER TABLE AVAILABILITY ADD STOCK_ORDERED SMALLINT;
GO

-- Q2.4
UPDATE AVAILABILITY
SET STOCK_ORDERED = 3
WHERE EQUIPMENT_ID = 'E004' AND WAREHOUSE_ID = 'W003';
GO

-- Q2.5  (returns Football Nets, Gym Mats)
SELECT e.EQUIPMENT_NAME
FROM EQUIPMENT e
WHERE NOT EXISTS (SELECT 1 FROM AVAILABILITY a WHERE a.EQUIPMENT_ID = e.EQUIPMENT_ID);

-- Q2.6
SELECT e.EQUIPMENT_NAME, SUM(a.QUANTITY) AS TOTAL_AVAILABLE
FROM EQUIPMENT e
LEFT JOIN AVAILABILITY a ON e.EQUIPMENT_ID = a.EQUIPMENT_ID
GROUP BY e.EQUIPMENT_NAME
ORDER BY e.EQUIPMENT_NAME;
-- Cricket Bats 7, Football Nets NULL, Gym Mats NULL, Tennis Rackets 23, Training Cones 32

-- Q2.7  (returns Central Sports Depot, 20)
SELECT TOP 1 w.WAREHOUSE_NAME, w.ADDRESS, e.EQUIPMENT_NAME, a.QUANTITY
FROM AVAILABILITY a
INNER JOIN WAREHOUSE w ON a.WAREHOUSE_ID = w.WAREHOUSE_ID
INNER JOIN EQUIPMENT e ON a.EQUIPMENT_ID = e.EQUIPMENT_ID
WHERE a.EQUIPMENT_ID = 'E002'
ORDER BY a.QUANTITY DESC;








-- Parent tables first
CREATE TABLE CLIENT (
    ClientID       VARCHAR(10)  NOT NULL PRIMARY KEY,
    ClientFullName VARCHAR(100) NOT NULL,
    ClientContact  VARCHAR(20)  NOT NULL
);

CREATE TABLE VENUE (
    VenueID      VARCHAR(10)  NOT NULL PRIMARY KEY,
    VenueName    VARCHAR(100) NOT NULL,
    VenueAddress VARCHAR(150) NOT NULL
);

-- Child table (two foreign keys, per the ER diagram)
CREATE TABLE BOOKING (
    BookingID         VARCHAR(10) NOT NULL PRIMARY KEY,
    ClientID          VARCHAR(10) NOT NULL
        CONSTRAINT FK_Booking_Client REFERENCES CLIENT(ClientID),
    VenueID           VARCHAR(10) NOT NULL
        CONSTRAINT FK_Booking_Venue  REFERENCES VENUE(VenueID),
    EventStartDate    DATE NOT NULL,
    EventEndDate      DATE NOT NULL,
    NumberOfAttendees INT  NOT NULL
);
GO

INSERT INTO CLIENT (ClientID, ClientFullName, ClientContact) VALUES
('111222', 'Lindiwe Mokoena', '072 4567 891'),
('222333', 'Mark Peterson',   '083 9123 456'),
('333444', 'Ayanda Dlamini',  '074 6789 321'),
('444555', 'Sipho Khumalo',   '071 3456 789'),
('555666', 'Rachel Adams',    '082 9876 543');

INSERT INTO VENUE (VenueID, VenueName, VenueAddress) VALUES
('V0001', 'Grand Hall',              '45 Summit Road, Johannesburg'),
('V0002', 'City Convention Centre',  '10 Market Street, Durban'),
('V0003', 'Riverside Pavilion',      '88 River Road, Pretoria'),
('V0004', 'Coastal Conference Hall', '12 Beach Avenue, Gqeberha'),
('V0005', 'Mountain View Centre',    '5 Peak Drive, Cape Town');

INSERT INTO BOOKING (BookingID, ClientID, VenueID, EventStartDate, EventEndDate, NumberOfAttendees) VALUES
('B00007', '111222', 'V0001', '2026-09-30', '2026-10-01', 120),
('B00005', '222333', 'V0005', '2026-09-29', '2026-10-02',  40),
('B00006', '222333', 'V0004', '2026-10-01', '2026-10-07', 200),
('B00002', '444555', 'V0002', '2026-09-28', '2026-10-01', 150),
('B00003', '555666', 'V0001', '2026-09-29', '2026-10-02', 300),
('B00001', '111222', 'V0002', '2026-09-20', '2026-09-30',  80),
('B00004', '222333', 'V0004', '2026-09-29', '2026-10-01',  60);
GO

-- Quick check that the data loaded
SELECT * FROM CLIENT;
SELECT * FROM VENUE;
SELECT * FROM BOOKING;

SELECT user_id, username, status, country 
FROM users 
WHERE status = 'Active' AND country = 'USA';