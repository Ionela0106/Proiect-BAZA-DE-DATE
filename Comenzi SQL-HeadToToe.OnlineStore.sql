SELECT*FROM Users;
SELECT*FROM Orders;
SELECT*FROM Payments;
SELECT first_name,last_name,customer_id FROM Customers;
SELECT DISTINCT last_name
FROM Customers
WHERE city='Baltimore';
UPDATE Orders
SET number_of_items =5
WHERE order_id=10;
SELECT product_id,product_category,stock_units,'Price range' =CASE
	      WHEN stock_units= 0 THEN 'item not for sale'
		  WHEN stock_units>=1 THEN'Item for sale'
		END
FROM Products
ORDER BY product_id;
SELECT*FROM Products;
 SELECT COUNT(*)FROM Users;
  SELECT YEAR(order_date),COUNT('order_data')FROM Orders
  GROUP BY YEAR(order_date);

  SELECT*FROM sys.fn_get_audit_file
('C:\AUDIT\Audit_DDL_Comands_91644D9E-6BA3-4A3D-AC67-39F77F121B89_0_133191175679860000.sqlaudit',DEFAULT,DEFAULT);

CREATE MASTER KEY ENCRYPTION BY PASSWORD ='MasterKey';

SELECT name KeyName,
      symmetric_key_id KeyID,
      key_length KeyLength,
      algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
GO
CREATE CERTIFICATE Encryptin_Certificate
WITH SUBJECT ='Protect data';
go
SELECT name CertName,
Certificate_id CertID,
pvt_key_encryption_type_desc EncriptType,
issuer_name Issuer
FROM sys.certificates;
GO
CREATE SYMMETRIC KEY First_SymKey WITH ALGORITHM =AES_256
ENCRYPTION BY CERTIFICATE Encryptin_Certificate;
GO 
SELECT name KeyName,
      symmetric_key_id KeyID,
      key_length KeyLength,
      algorithm_desc KeyAlgorithm
FROM sys.symmetric_keys;
GO
ALTER TABLE Payments
ADD credit_card_numberEncrypted VARBINARY(MAX);
GO
OPEN SYMMETRIC KEY First_SymKey
DECRYPTION BY CERTIFICATE Encryptin_Certificate;
GO
UPDATE Payments
SET credit_card_numberEncrypted=ENCRYPTBYKEY(KEY_GUID('First_SymKey'),credit_card_number)
FROM Payments;
go
CLOSE SYMMETRIC KEY First_SymKey;
GO
SELECT*FROM Payments;
GO
ALTER TABLE Payments
DROP COLUMN credit_card_number;
go
OPEN SYMMETRIC KEY First_SymKey
DECRYPTION BY CERTIFICATE Encryptin_Certificate;
GO
SELECT user_id,name_on_the_card,credit_card_numberEncrypted AS 'Encrypted data',
CONVERT(VARCHAR,Decryptbykey(credit_card_numberEncrypted))AS'Decrypted bank account'
FROM Payments;
GO
CLOSE SYMMETRIC KEY First_SymKey;
GO
ALTER TABLE Users
ADD passwordEncrypted VARBINARY(MAX);

OPEN SYMMETRIC KEY First_SymKey
DECRYPTION BY CERTIFICATE Encryptin_Certificate;
GO
UPDATE Users
SET passwordEncrypted=ENCRYPTBYKEY(KEY_GUID('First_SymKey'),password)
FROM Users;
go
CLOSE SYMMETRIC KEY First_SymKey;
GO
SELECT*FROM Users;
GO
ALTER TABLE Users
DROP COLUMN password;
go
OPEN SYMMETRIC KEY First_SymKey
DECRYPTION BY CERTIFICATE Encryptin_Certificate;
GO
SELECT user_id,user_name,passwordEncrypted AS 'Encrypted data',
CONVERT(VARCHAR,Decryptbykey(passwordEncrypted))AS'Decrypted bank account'
FROM Users;
GO
CLOSE SYMMETRIC KEY First_SymKey;
GO
CREATE FUNCTION everything_on_sale(@column_name INT,@percent INT)
RETURNS INT
AS
BEGIN
RETURN @column_name-(@column_name*@percent)/100;
END
GO


DROP FUNCTION everything_on_sale;


DECLARE @product_table TABLE(
       product_category VARCHAR(MAX) NOT NULL,
	   brand_id INT NOT NULL,
	   product_price VARCHAR(50) NOT NULL
);
INSERT INTO @product_table
SELECT product_category,brand_id,product_price
FROM Products
WHERE brand_id=7;
SELECT*FROM tempdb.sys.tables
SELECT*FROM @product_table;
GO
SELECT*FROM Products

;
CREATE NONCLUSTERED INDEX idx_CustomerID
ON dbo.Customers(customer_id);
CREATE NONCLUSTERED INDEX idx_OrderDate
ON dbo.Orders(order_date);
GO
SELECT o.order_id,c.*
FROM Customers c
INNER JOIN Orders o
ON c.customer_id=o.customer_id;

ALTER DATABASE HEADtoTOE
ADD FILEGROUP HEADtoTOEINMEMORY CONTAINS MEMORY_OPTIMIZED_DATA;
GO
ALTER DATABASE HEADtoTOE
ADD FILE(name='email_address_1',filename='C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\HEADtoTOEInMemory')
TO FILEGROUP HEADtoTOEINMEMORY;
GO
CREATE STATISTICS stats_email_address_customer_id
ON Customers(customer_id)WITH FULLSCAN,NORECOMPUTE
UPDATE STATISTICS Customers WITH FULLSCAN ,NORECOMPUTE
go

SET TRAN ISOLATION LEVEL READ UNCOMMITTED;
GO
BEGIN TRANSACTION
SELECT*FROM dbo.Customers
WHERE customer_id=50;
ROLLBACK TRANSACTION
GO
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
GO
BEGIN TRANSACTION
SELECT*FROM dbo.Customers;

ROLLBACK TRANSACTION
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
GO
ALTER DATABASE HEADtoTOE
SET ALLOW_SNAPSHOT_ISOLATION ON;
GO
SET TRANSACTION ISOLATION LEVEL SNAPSHOT; 
BEGIN TRANSACTION
UPDATE dbo.Products
SET stock_units=stock_units+50
WHERE product_id=2;
SELECT*FROM dbo.Products
WHERE product_id=2;
ROLLBACK TRANSACTION
ALTER DATABASE HEADtoTOE
SET ALLOW_SNAPSHOT_ISOLATION OFF;
GO
ALTER DATABASE HEADtoTOE
SET READ_COMMITTED_SNAPSHOT ON;
GO
-----------------------------
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT*FROM dbo.Products
WHERE product_id=2;

BEGIN TRANSACTION
UPDATE dbo.Products
SET stock_units=stock_units+15
WHERE product_id=2;
COMMIT TRANSACTION
go
SELECT *INTO dbo.CustomersBackup
FROM dbo.Customers;
go
SELECT*FROM dbo.Customers;
SELECT*FROM dbo.CustomersBackup;
go
SET DEADLOCK_PRIORITY HIGH;
BEGIN TRANSACTION 
UPDATE dbo.Customers
SET first_name='Transaction',
last_name='Transaction'
WHERE customer_id=62;
GO
UPDATE dbo.CustomersBackup
SET first_name='Transaction',
last_name='Transaction'
WHERE customer_id IN(62,72,53,94);
GO
COMMIT TRANSACTION
go
SELECT*FROM CustomersBackup;
GO
CREATE TRIGGER trg_brands
ON Brands
INSTEAD OF INSERT
AS
BEGIN
--SET NOCOUNT ON;
INSERT INTO Brands(brand_name)
SELECT i.brand_name
FROM inserted i
WHERE i.brand_name NOT IN(
SELECT brand_name FROM Brands);
END;
go

IF OBJECT_ID(N'trg_brands',N'TR')IS NOT NULL
DROP TRIGGER trg_brands;
SELECT name FROM sys.triggers
WHERE type='TR';
GO
DISABLE TRIGGER ALL ON DATABASE;
go

CREATE TABLE Payments_Approvels(
payment_id INT IDENTITY PRIMARY KEY,
name_on_the_card VARCHAR(50) NOT NULL);
GO
CREATE VIEW vw_payments
AS 
SELECT name_on_the_card,'Approval' approval_status
FROM Payments 
UNION
SELECT name_on_the_card,'Pending approval' approval_status
FROM Payments_Approvels;
GO
SELECT name_on_the_card,approval_status
FROM vw_payments;
GO
CREATE TRIGGER trg_vw_Payments
ON vw_payments
INSTEAD OF INSERT
AS
BEGIN
SET NOCOUNT ON;
INSERT INTO Payments_Approvels(name_on_the_card)
SELECT i.name_on_the_card
FROM inserted i
WHERE i.name_on_the_card NOT IN(
SELECT name_on_the_card FROM Payments);
END;
GO
INSERT INTO vw_payments(name_on_the_card)
VALUES('test payment');
GO
SELECT*FROM Payments_Approvels;
go

CREATE VIEW online_sales
AS
 SELECT year(order_date)AS Year,month(order_date)AS Month,day(order_date)AS  Day,p.product_id,product_category,stock_units
 FROM Products p
 INNER JOIN Orders o
 ON o.product_id=p.product_id
 INNER JOIN Customers c
 ON o.customer_id=c.customer_id;
 GO
 SELECT*FROM online_sales
 ORDER BY year,month,day,product_category;
 go
CREATE OR ALTER VIEW online_sales
AS
 SELECT year(order_date)AS Year,month(order_date)AS Month,day(order_date)AS  Day,
 concat(first_name,' ',last_name)AS customer_name,
 p.product_id,product_category,stock_units
 FROM Products p
 INNER JOIN Orders o
 ON p.product_id=o.product_id
  INNER JOIN Customers c	
 ON o.customer_id=c.customer_id;

go
SELECT 
OBJECT_SCHEMA_NAME(v.object_id)schema_name,
v.name
FROM sys.views as v;
SELECT 
OBJECT_SCHEMA_NAME(o.object_id)schema_name,
o.name
FROM sys.views as o
WHERE o.type='v';
SELECT definition,
uses_ansi_nulls,
uses_quoted_identifier,
is_schema_bound
FROM sys.sql_modules
WHERE object_id=object_id('online_sales');
SELECT OBJECT_DEFINITION(OBJECT_ID('online_sales'))
view_info;
DROP VIEW IF EXISTS online_sales,vw_payments;
DBCC LOGINFO;
DBCC SQLPERF(logspace);
BACKUP DATABASE [HEADtoTOE] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\HEADtoTOE.bak' WITH NOFORMAT, NOINIT,  NAME = N'HEADtoTOE-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
BACKUP LOG [HEADtoTOE] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\HEADtoTOETRN.trn' WITH NOFORMAT, NOINIT,  NAME = N'HEADtoTOE-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10
GO
BACKUP LOG [HEADtoTOE] TO  DISK = N'C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\HEADtoTOE.tailLOG' WITH NOFORMAT, NOINIT,  NAME = N'HEADtoTOE-Full Database Backup', SKIP, NOREWIND, NOUNLOAD,  STATS = 10, CONTINUE_AFTER_ERROR
GO

