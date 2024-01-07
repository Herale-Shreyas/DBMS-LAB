create database StudentEnrollment;
DROP DATABASE StudentEnrollment;

use StudentEnrollment;

create table STUDENT (
regno varchar(15) primary key,
name varchar(20) not null,
major varchar(20) not null,
bdate date not null
);

create table COURSE (
courseId int primary key,
cname varchar(50) not null,
dept varchar(50) not null
);

create table ENROLL (
regno varchar(15) not null,
courseId int not null,
sem int not null,
marks int not null,
foreign key (regno) references STUDENT(regno) on delete cascade,
foreign key (courseId) references COURSE(courseId) on delete cascade
);

create table TEXT (
bookISBN int primary key,
bookTitle varchar(30) not null,
publisher varchar(50) not null,
author varchar(50) not null
);

create table BOOK_ADOPTION (
courseId int not null,
sem int not null,
bookISBN int not null,
foreign key (courseId) references COURSE(courseId) on delete cascade,
foreign key (bookISBN) references TEXT(bookISBN) on delete cascade
);

insert into STUDENT(regno, name, major, bdate)
values
("01JS123", "Karthik", "CSE", "2003-01-04"),
("01JS234", "John", "ECE", "2003-02-04"),
("01JS345", "Reba", "ISE", "2003-03-04"),
("01JS456", "Sathvik", "CSE", "2003-04-04"),
("01JS567", "Vinay", "EEE", "2003-05-04");

insert into COURSE(courseId, cname, dept)
values
(101, "DBMS", "CSE"),
(102, "Communication", "ECE"),
(103, "Operating Systems", "ISE"),
(104, "Marketing Management", "CTM"),
(105, "Power Plant", "EEE");

insert into ENROLL(regno, courseId, sem, marks)
values
("01JS123", 101, 5 , 96),
("01JS234", 104, 6, 89),
("01JS345", 105, 5, 67),
("01JS456", 102, 6, 39),
("01JS567", 103, 5, 76);

insert into TEXT(bookISBN, bookTitle, publisher, author)
values
(258341, "Database Management Systems", "Publications1", "Author1"),
(561685, "Communications- made easier", "Publications2", "Author2"),
(631685, "Operating Systems Vol1", "Publications1", "Author3"),
(421613, "Market Research", "Publications3", "Author4"),
(153716, "Power Plantations", "Publications4", "Author5"); 

insert into BOOK_ADOPTION(courseId, sem, bookISBN)
values
(101, 5, 258341),
(104, 6, 421613),
(105, 5, 153716),
(102, 6, 561685),
(103, 5, 631685);

-- Demonstrate how you add a new text book to the database and make this book be
-- adopted by some department.

-- Produce a list of text books (include Course #, Book-ISBN, Book-title) in the alphabetical
-- order for courses offered by the ‘CS’ department that use more than two books.

SELECT b.courseId, b.bookISBN, t.bookTitle
FROM BOOK_ADOPTION b
JOIN TEXT t ON b.bookISBN = t.bookISBN
JOIN COURSE c USING (courseId)
WHERE c.dept = 'CSE' AND 
2 < (SELECT COUNT(bookISBN) FROM BOOK_ADOPTION JOIN COURSE USING (courseId) WHERE dept = "CSE")  
ORDER BY t.bookTitle;

-- List any department that has all its adopted books published by a specific publisher. 

-- SELECT c.dept 
-- FROM COURSE c
-- JOIN BOOK_ADOPTION b ON (courseId)
-- JOIN TEXT t ON (bookISBN) 

-- List the students who have scored maximum marks in ‘DBMS’ course.

SELECT s.name
FROM STUDENT s
JOIN ENROLL USING (regno)
JOIN COURSE USING (courseId)
WHERE cname = 'DBMS' 
AND ENROLL.marks IN (SELECT MAX(marks) FROM ENROLL);

-- Create a view to display all the courses opted by a student along with marks obtained.
CREATE VIEW studentsMarks AS
SELECT c.cname, e.marks
FROM COURSE c
JOIN ENROLL e USING (courseId)
JOIN STUDENT USING (regno)
WHERE regno = "01JS123";

SELECT * FROM studentsMarks;

-- Create a trigger that prevents a student from enrolling in a course if the marks
-- prerequisite is less than 40.

DELIMITER //
CREATE TRIGGER preventFailedStudent
BEFORE INSERT ON ENROLL
FOR EACH ROW
BEGIN 
	IF (NEW.marks < 40) THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "HAHA BRO YOU FAILED";
END IF;
END; //
DELIMITER ;

INSERT INTO ENROLL VALUES ("01JS456", 103, 6, 39);