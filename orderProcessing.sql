create database orderProcessing;

use orderProcessing;

create table Customer (
 cust int primary key,
 cname varchar(50),
 city varchar(50) 
);

create table Orders (
 order_id int primary key,
 odate date ,
 orderAmt int ,
 cust int,
 foreign key (cust) references Customer(cust) on delete set null 
);

create table Item (
 items int primary key,
 unitprice int 
);

create table OrderItems (
 order_id int ,
 item int ,
 qty int,
 foreign key (order_id) references Orders(order_id) on delete set null ,
 foreign key (item) references Item(items) on delete set null 
);

create table Warehouse (
 warehouse int primary key,
 city varchar(50) 
);


create table Shipment (
order_id int ,
warehouse int ,
ship_date date ,
foreign key (warehouse) references Warehouse(warehouse) on delete set null,
foreign key (order_id) references Orders(order_id) on delete set null
);

insert into Customer (cust, cname, city)
values 
(1,"Kumar","Pune"),
(2,"Rahul Sharma","Mumbai"),
(3,"Sneha Kapoor","Kolkata"),
(4,"Rajesh Gupta","Chennai"),
(5,"Priya Singh","Delhi");


insert into Item (items, unitprice)
values
(51,45),
(52,67),
(53,90),
(54,12),
(55,150);

insert into Warehouse (warehouse, city)
values
(81,"Mandya"),
(82,"Shivamogga"),
(83,"Madikeri"),
(84,"Kanpur"),
(85,"Jaipur");

insert into Orders (order_id, odate, orderAmt, cust)
values
(101, '2023-01-15', 1000, 1),
(102, '2023-02-20', 2000, 2),
(103, '2023-03-10', 3000, 3),
(104, '2023-04-05', 9000, 4),
(105, '2023-05-12', 6000, 5);

insert into OrderItems (order_id,  item, qty)
values
(101, 52, 6),
(102, 53, 3),
(103, 51, 4),
(104, 55, 12),
(105, 54, 15);

insert into Shipment (order_id , warehouse, ship_date)
values
(101, 81, '2023-02-15'),
(102, 83, '2023-03-20'),
(103, 83, '2023-04-10'),
(104, 84, '2023-05-05'),
(105, 83, '2023-06-12');


-- List the Order# and Ship_date for all orders shipped from Warehouse# "83". 
select order_id , ship_date from Shipment where warehouse = 83;

-- List the Warehouse information from which the Customer named "Kumar" was supplied his orders. Produce a listing of Order#, Warehouse#
select Shipment.order_id , Shipment.warehouse , Customer.cname
from Shipment , Orders, Customer 
where Shipment.order_id = Orders.order_id AND
Orders.cust = Customer.cust AND
Customer.cname LIKE '%Kumar%';

-- Produce a listing: Cname, #ofOrders, Avg_Order_Amt, where the middle column is the total
-- number of orders by the customer and the last column is the average order amount for that
-- customer. (Use aggregate functions)

SELECT c.cname, COUNT(order_id) AS NumberOfOrders, AVG(orderAmt) AS AverageMoney
FROM Customer c
JOIN Orders o USING (cust)
GROUP BY c.cust;


--  Delete all orders for customer named "Kumar"
delete from Orders where cust = 
(select cust from Customer where cname like "Kumar%");

-- Find the item with the maximum unit price
select items , MAX(unitprice) as maximum from Item
group by items 
order by maximum desc
limit 1;
-- OR
SELECT items, MAX(unitprice) AS maximum 
FROM Item
WHERE unitprice IN (SELECT MAX(unitprice) FROM Item)
GROUP BY items;

-- Create a view to display orderID and shipment date of all orders shipped from a warehouse 83
create view order_shipment
as select 
order_id , ship_date 
from Shipment
where warehouse = 83;

select * from order_shipment;

-- A trigger that updates order_amout based on quantity and unitprice of order_item

DELIMITER //
CREATE TRIGGER my_amt
AFTER INSERT ON OrderItems
FOR EACH ROW
BEGIN
    UPDATE Orders
    SET orderAmt = (SELECT unitprice FROM Item WHERE items = NEW.item) * NEW.qty
    WHERE order_id = NEW.order_id;
END;
//

DELIMITER ;

