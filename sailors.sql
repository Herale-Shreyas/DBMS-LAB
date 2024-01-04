create database Sailors;

use Sailors;


create table SAILORS (
sid int primary key,
sname varchar(20) not null,
rating float not null,
age int not null 
);

create table BOAT (
bid int primary key,
bname varchar(20) not null,
color varchar(20) not null 
);

create table RSERVERS (
sid int not null,
bid int not null,
reserve_date date not null,
foreign key (sid) references SAILORS(sid) on delete cascade,
foreign key (bid) references BOAT(bid) on delete cascade
);

insert into SAILORS (sid, sname, rating, age)
values
(201, 'Albert', 8.9, 43),
(202, 'Stormy', 9.1, 23),
(203, 'Boystorm', 6.6, 31),
(204, 'Harrystorms', 9.3, 45),
(205, 'Kumar', 7.9, 48),
(206, 'Patil', 9.5, 40),
(207, 'Shetty', 9.0, 35);

insert into BOAT (bid, bname, color)
values
(101, 'Boat1', 'Red'),
(102, 'Boat2', 'Green'),
(103, 'Boat3', 'Yellow'),
(104, 'Boat4', 'Beige'),
(105, 'Boat5', 'Pink'),
(106, 'Boat6', 'Blue');

insert into RSERVERS (sid, bid, reserve_date)
values
(201, 103, '2023-01-15'),
(202, 105, '2023-02-15'),
(203, 101, '2023-03-15'),
(204, 102, '2023-04-15'),
(205, 104, '2023-05-15'),
(206, 106, '2023-06-15'),
(207, 103, '2023-07-15');

select color 
from SAILORS s, BOAT b, RSERVERS r 
where s.sid=r.sid and b.bid=r.bid and s.sname="Albert";

-- Find all sailor id’s of sailors who have a rating of at least 8 or reserved boat 103

SELECT s.sid 
FROM SAILORS s, RSERVERS r
WHERE s.sid = r.sid AND (s.rating >= 8 OR r.bid = 103);

-- Find the names of sailors who have not reserved a boat whose name contains the string
-- “storm”. Order the names in ascending order

SELECT sname 
FROM SAILORS
WHERE sid NOT IN (SELECT DISTINCT sid FROM RSERVERS) AND SNAME LIKE "%storm%"
ORDER BY sname ASC;

-- find the name of the sailors who have reserved all boats

SELECT SAILORS.sname
FROM SAILORS 
JOIN RSERVERS  ON SAILORS.sid = RSERVERS.sid
GROUP BY SAILORS.sid, SAILORS.sname
HAVING COUNT(DISTINCT RSERVERS.bid) = (SELECT COUNT(*) FROM BOAT);


-- find the name of the oldest sailor
SELECT s.sname, s.age FROM SAILORS s
WHERE s.age IN (SELECT max(age) FROM SAILORS);

-- For each boat which was reserved by at least 5 sailors with age >= 40, find the boat id and
-- the average age of such sailors.

SELECT b.bid, AVG(s.age)
FROM SAILORS s
JOIN RSERVERS r ON s.sid = r.sid
JOIN BOAT b ON b.bid = r.bid
WHERE
s.age >= 40
GROUP BY b.bid
HAVING count(s.sid) >= 2 ;

-- Create a view that shows the names and colours of all the boats that have been reserved by
-- a sailor with a specific rating.

CREATE VIEW specific_rating AS 
SELECT b.bname, b.color 
FROM BOAT b 
JOIN RSERVERS r ON b.bid = r.bid
JOIN SAILORS s ON r.sid = s.sid
WHERE s.rating like 9.1;

SELECT * FROM specific_rating;

-- A trigger that prevents boats from being deleted If they have active reservations.

DELIMITER //
CREATE TRIGGER Prevent_Deletion
BEFORE DELETE ON BOAT
FOR EACH ROW
BEGIN
IF ( old.bid in (SELECT DISTINCT bid FROM boat) )THEN
	SIGNAL SQLSTATE '45000' SET message_text='Boat is reserved and hence cannot be deleted';
END IF;
END //
DELIMITER ;
