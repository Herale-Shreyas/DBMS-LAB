CREATE DATABASE COMPANY;
DROP DATABASE COMPANY;
USE COMPANY;

CREATE TABLE Employee (
	ssn INT PRIMARY KEY,
    ename VARCHAR(30) NOT NULL,
    address VARCHAR(45) NOT NULL,
    sex VARCHAR(7) NOT NULL,
    salary FLOAT NOT NULL, 
    superSSN INT,
    dno int,
    FOREIGN KEY (superSSN) REFERENCES Employee(ssn) ON DELETE CASCADE
);

CREATE TABLE Department (
	dno INT PRIMARY KEY,
    dname VARCHAR(15) NOT NULL,
    mgrSSN INT,
    mgrStartDate DATE,
    FOREIGN KEY (mgrSSN) REFERENCES Employee(ssn) ON DELETE CASCADE
);

ALTER TABLE Employee ADD FOREIGN KEY (dno) REFERENCES Department(dno) ON DELETE CASCADE;

CREATE TABLE DLocation (
	dno INT,
	dloc VARCHAR(35) NOT NULL,
    FOREIGN KEY(dno) REFERENCES Department(dno)
);

CREATE TABLE Project (
	pno INT PRIMARY KEY,
    pname VARCHAR(45) NOT NULL,
    plocation VARCHAR(30) NOT NULL,
    dno INT NOT NULL,
    FOREIGN KEY (dno) REFERENCES Department(dno) ON DELETE CASCADE
);

CREATE TABLE Works_on (
	ssn INT,
    pno INT,
    hours INT,
    FOREIGN KEY (ssn) REFERENCES Employee (ssn) ON DELETE CASCADE,
    FOREIGN KEY (pno) REFERENCES Project (pno) ON DELETE CASCADE
);


-- REQUIREMENTS 
-- EMPLOYEE WITH LAST NAME SCOTT
-- PROJECT NAMED IOT
-- DEPARTMENT NAMED ACCOUNTS, AND DEPARTMENT NUMBER 5
-- SALARY > 6L

INSERT INTO Employee (ssn, ename, address, sex, superSSN, salary) VALUES 
(104, "Sachin Elevendulkar", "Near Antilia, Mumbai", "Male",NULL, 100000),
(101, "Peter Scott", "KRS Road, London", "Male", 104, 750000),
(102, "Mustafa Kumar Scott", "Dharavi, Bombay", "Male",104, 62000),
(103, "Alexandra Cleopatra Singh", "New Yolk, Bengaluru West", "Female", 104, 980000),
(105, "Mahendra King Dhoni", "Ranchi, India", "Male",104, 777777);

INSERT INTO Department VALUES 
(001, "Accounts", 102, '2023-05-15'),
(002, "CS", 103, '2023-06-15'),
(003, "Administration", 101, '2023-07-15'),
(005, "Sports", 105, '2023-07-07');

UPDATE Employee SET dno = 001 WHERE ssn = 102;
UPDATE Employee SET dno = 002 WHERE ssn = 103;
UPDATE Employee SET dno = 003 WHERE ssn = 101;
UPDATE Employee SET dno = 005 WHERE ssn = 105;

SELECT * FROM Employee;

INSERT INTO DLocation VALUES
(001, "Bombay"),
(002, "Bengaluru"),
(003, "London"),
(005, "Ranchi");

INSERT INTO Project VALUES 
(1001, "Money Heist", "Spain", 001),
(1002, "IOT", "Mysuru", 002),
(1003, "Cricket", "Ranchi", 005);

INSERT INTO Works_On VALUES 
(105, 1003, 10),
(104, 1002, 8),
(103, 1002, 7),
(102, 1001, 12);

-- Make a list of all project numbers for projects that involve an employee whose last name
-- is ‘Scott’, either as a worker or as a manager of the department that controls the project.

SELECT w.pno, e.ename, p.pname
FROM Works_on w, Employee e, Project p
WHERE w.ssn = e.ssn AND p.pno = w.pno AND e.ename LIKE "%scott"; 

-- Show the resulting salaries if every employee working on the ‘IoT’ project is given a 10
-- percent raise.

UPDATE Employee SET salary = salary + (salary * 0.1) WHERE ssn IN (SELECT ssn FROM Works_on w, Project p WHERE w.pno = p.pno AND p.pname = "IOT");

SELECT * FROM Employee;

-- Find the sum of the salaries of all employees of the ‘Accounts’ department, as well as the
-- maximum salary, the minimum salary, and the average salary in this department

SELECT SUM(salary) AS Sum_Of_Salary, MAX(salary) as Minimum, MIN(salary) AS Minimum, AVG(salary) AS Average
FROM Employee e, Department d
WHERE e.dno = d.dno AND d.dname = "Accounts"
GROUP BY e.ename;

-- Retrieve the name of each employee who works on all the projects controlled by
-- department number 5 (use NOT EXISTS operator).

SELECT e.ename 
FROM Employee e WHERE NOT EXISTS (
			SELECT p.pno FROM Project p WHERE p.dno = 5 AND p.pno NOT IN (
					SELECT pno FROM Works_on w WHERE w.ssn = e.ssn));

-- For each department that has more than zero employees, retrieve the department
-- number and the number of its employees who are making more than Rs. 6,00,000.

SELECT d.dno, COUNT(*) AS Count_Of_Emp 
FROM DEPARTMENT d, Employee e
WHERE d.dno = e.dno AND e.salary > 600000
GROUP BY e.dno HAVING COUNT(e.ssn) > 0;

-- Create a view that shows name, dept name and location of all employees.

CREATE VIEW Details AS
SELECT e.ename, d.dname, l.dloc
FROM Employee e, Department d, DLocation l
WHERE e.dno = d.dno AND d.dno = l.dno;

SELECT * FROM Details;

-- Create a trigger that prevents a project from being deleted if it is currently being worked
-- by any employee.

DELIMITER //
CREATE TRIGGER Prevention 
BEFORE DELETE ON Project
FOR EACH ROW
BEGIN
	IF ( OLD.pno IN (SELECT pno FROM Works_on WHERE Works_on.pno = OLD.pno) ) THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = "Shreyas is the king!!";
	END IF;
END; //
DELIMITER ;

DELETE FROM Project WHERE pno = "1001"; 
