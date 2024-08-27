use project;
select * from sales_dataa;

#  Show distinct values on any of the fields on your table
select distinct PRODUCTLINE from sales_dataa;

#  Create a function on the table.
DELIMITER //
create function
NewTotalSalesForProductLine(prodLine varchar(255))
returns decimal(10,2)
deterministic
begin
declare total_sales decimal(10,2);
select sum(Total_Sales) into total_sales
from sales_dataa
where Productline=prodline;
return total_sales;
end //
DELIMITER ;

# Create Insert, Delete and Update triggers on your table.
DELIMITER //
create trigger before_insert_sales
before insert on sales_dataa
for each row
begin
set new.Sales=NEW.QuantityOrdered * NEW.PriceEach;
end //
DELIMITER ;

# DELETE TRIGGER
DELIMITER //
create trigger after_delete_sales
after delete on sales_dataa
for each row
begin
insert into Sales_audit(action,product_line,action_time)
values('Delete', OLD.Productline,
now());
end //
DELIMITER //

# UPDATE TRIGGER
DELIMITER //
create trigger before_update_sales
before update on sales_dataa
for each row
begin
set new.SALES=NEW.QuantityOrdered * NEW.PriceEach;
end //
DELIMITER ;

# Create stored procedures.
drop procedure if exists AddOrder;
DELIMITER //
create procedure AddOrder(
in p_OrderNumber int,
in p_QuantityOrdered int,
in p_PriceEach decimal(10,2),
in p_OrderLineNumber int,
in p_OrderDate Date,
in p_Status varchar(50),
in p_QTR_ID int,
in p_Month_ID int,
in p_Year_ID int,
in p_Productline varchar(255))
begin
insert into sales_dataa
(OrderNumber,QuantityOrdered,PriceEach,OrderLineNumber,OrderDate,Status,QTR_ID,Month_ID,Year_ID,
Productline)
values (p_OrderNumber,p_QuantityOrdered,p_PriceEach,p_OrderLineNumber,p_OrderDate,p_Status,
p_QTR_ID,p_Month_ID,p_Year_ID,p_Productline);
end //
DELIMITER ;

# STORED PROCEDURE TO UPDATE A RECORD
DELIMITER //
create procedure UpdateOrder(in p_Ordernumber int,
in p_NewStatus varchar(255),
in p_NewSales decimal(10,2))
begin
update sales_dataa
set 
Status=p_NewStatus,
Sales=p_NewSales
where 
ordernumber=p_Ordernumber;
end //
DELIMITER ;
# ADD A NEW FIELD TO THE TABLE
alter table sales_dataa
add column Category decimal(10,2);

# CHANGE THE NAME OF A FIELD ON YOUR TABLE
alter table sales_dataa
change column SALES_AMOUNT TOTAL_SALES
DECIMAL(10,2);
describe sales_dataa;

# CREATE A NEW USER IN YOUR DATABASE
create user 'Kylian'@'localhost'
identified by '1121';

# GRANT THE NEW USER SELECT,INSERT, AND ALTER PRIVILEGES
grant select, insert, alter on sales_dataa.* to
'Kylian'@'localhost';

# REVOKE ALL THE PRIVILEGES GRANTED TO THE NEW USER
revoke all privileges, grant option from 'Kylian'@'localhost';

# SQL STATEMENTS TO BACKUP AND RESTORE
---# FOR BACKUP USING COMMAND PROMPT

# ---Microsoft Windows [Version 10.0.19045.4598]
# ---(c) Microsoft Corporation. All rights reserved.

# ---C:\WINDOWS\system32>cd C:\Program Files\MySQL\MySQL Server 8.4\bin

# ---C:\Program Files\MySQL\MySQL Server 8.4\bin>mysqldump -u root -p project >projectbkp.sql
#-----Enter password: **********

# --- TO RESTORE BACKUP USING COMMAND PROMPT
#---Microsoft Windows [Version 10.0.19045.4598]
#---(c) Microsoft Corporation. All rights reserved.

#----C:\WINDOWS\system32>cd C:\Program Files\MySQL\MySQL Server 8.4\bin

#----C:\Program Files\MySQL\MySQL Server 8.4\bin>mysql -u root -p project < projectbkp.sql
#----Enter password: **********



# DIFFERENCE BETWEEN CHAR AND VARCHAR DATA TYPE
# CHAR: Is a fixed-length nonbinary (character) string

# VARCHAR: – This is a string of text. The number denotes the length of
# the string. VARCHAR stands for a variable character. In the parentheses, we
# enter a number which represents the maximum length that the string of text
# can be. For example, VARCHAR(5) would allow a string of five characters
# such as ‘hello.’

# CREATE AN ERD WITH 6 RELATED TABLES
# ERD(Entity-Relationship Diagram) it is a visual representation of a database schema,not a SQL
# command.
# 1.Customers: Stores customers information
# 2.Orders: stores order information related to customers.
# 3. OrderDetails: Stores details for each order.
# 4.Products: Stores product information
# 5.Suppliers: Stores supplier information
# 6.ProductSupplier: Maps products to their suppliers.

# CREATE CUSTOMERS TABLE
create table Customers(CustomerID int auto_increment
primary key,
CustomerName varchar(255) not null,
ContactDetails varchar(255),
address varchar(255));

# CREATE PRODUCTS TABLE
create table Products(ProductID int auto_increment
primary key,
ProductName varchar(255) not null,
ProductLine varchar(255),
Price decimal(10,2) not null);

# CREATE SUPPLIER TABLE
create table Suppliers(SupplierID int auto_increment
primary key,
SupplierName varchar(255) not null,
ContactDetails varchar(255));
drop table if exists Suppliers;

# CREATE PRODUCT SUPPLIER TABLE(Associative table for products and suppliers)
create table ProductSupplier(ProductID int,
SupplierID int,
primary key(ProductID, SupplierID),
foreign key (ProductID) references Products(ProductID),
foreign key (SupplierID) references Suppliers(SupplierID));

# CREATE ORDER TABLE
create table Orders(OrderID int auto_increment primary key,
CustomerID int,
OrderDate DATE not null,
Status varchar(50),
foreign key (CustomerID)
references Customers(CustomerID));

# CREATE OrderDetails Table
create table OrderDetails(OrderDetailID int auto_increment primary key,
OrderID int,
ProductID int,
Quantity int not null,
PriceEach decimal(10,2) not null,
foreign key(OrderID) references Orders(OrderID),
foreign key(ProductID) references Products(ProductID));

# 1: Customers to Orders. One-to-many relationship(one customer can have multiple orders)
# 2: Orders to OrderDetails: One-to-many relationship(one order can have multiple details)
# 3: Products to OrderDetails; One-to-many relationship(one product can be in many order details)
# 4: Products to ProductSupplier: Many-to-many relationship(one product can have multiple suppliers and vice versa)
# 5: Suppliers to ProductSupplier: Many-to-many relationship(one supplier can supply multiple products)

# DIFFERENCES BETWEEN SQL AND MYSQL
# SQL(Structured Query Language): A standard programming language used for managing relational 
# databases while MYSQL is a specific relational database management system(RDBMS) that uses SQL

# KEY DIFFERENCES:
# 1.SQL is a language,while MYSQL is a database management system
# 2.SQL is used to write queries,create tables and manipulate data, while MYSQL is the software 
# that stores and manages the data
# 3.SQL is standardized, while MYSQL has its own extensions and variations.alter
# 4.SQL can be used with various databases, including MYSQL,PostgreSQL,SQL Server,and Oracle
# while MySQL is a specific database system.
# 5.SQL syntax may vary slightly depending on the database system, while MYSQL has its own syntax
# and features.

# WHY ARE TRIGGERS CREATED ON A DATABAS?
# 1:DATA INTERGRITY:They enforce data intergrity by ensuring that specific conditions are met
# before or after a data modification(INSERT,UPDATE,DELETE)
# 2.CONSISTENCY:Triggers help maintain consistency across related tables by performing automatic
# updates or deletion.
# 3.AUDIT AND SECURITY:Triggers can log changes or raise alerts when unauthorized operations are
# attempted
# 4.AUTOMATE TASKS:Triggers can automate tasks, such as updating related tables,sending
# notifications,or logging changes
# 5.PERFORMANCE OPTIMIZATION:Triggers can optimize performance by reducing the need
# for redundant data,improving data consistency, and streamlining processes

# WHAT IS THE DIFFERENCE BETWEEN A PRIMARY KEY AND A FOREIGN KEY?
# PRIMARY KEY:It is a unique value that is used to identify a row in a table. Each table can
# have only one primary key.example CustomerID, in the customer table

# FOREIGN KEY: It links related records between tables by referencing the primary key of 
# another table




