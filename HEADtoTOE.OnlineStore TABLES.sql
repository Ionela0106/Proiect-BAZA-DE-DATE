USE HEADtoTOE;


CREATE TABLE Users(
      user_id int IDENTITY(1,1)PRIMARY KEY,
	  password varchar(20)NOT NULL,
	  user_name varchar(50) NOT NULL);

CREATE TABLE Customers(
      customer_id int IDENTITY(1,1)PRIMARY KEY,
	  first_name varchar(30)NOT NULL,
	  last_name varchar(30)NOT NULL,
	  email_address varchar(50) NOT NULL,
	  address varchar(40)NOT NULL,
	  city varchar(30)NOT NULL,
	  region varchar(20),
	  postal_code varchar(20) NOT NULL,
	  country varchar(20) NOT NULL,
	  phone_number varchar(20)NOT NULL,
	  user_id int NOT NULL,
	  CONSTRAINT user_id FOREIGN KEY (user_id) REFERENCES Users(user_id));

CREATE TABLE Brands(
      brand_id int IDENTITY(1,1) PRIMARY KEY,
	  brand_name varchar(50) NOT NULL);


  CREATE TABLE Providers(
      provider_id int IDENTITY(1,1)PRIMARY KEY,
	  provider_name varchar(30) NOT NULL,
	  providers_country varchar(30) NOT NULL,
	  brand_id int NOT NULL FOREIGN KEY(brand_id)REFERENCES Brands(brand_id));
	  



CREATE TABLE Products(
      product_id int IDENTITY(1,1)PRIMARY KEY,
	  product_name varchar (50)NOT NULL,
	  provider_id int NOT NULL,
	  product_category varchar(50),
	  stock_units int,
	  product_price money,
	  brand_id int NOT NULL,
	  CONSTRAINT brand_id FOREIGN KEY (brand_id)REFERENCES Brands(brand_id),
	  CONSTRAINT provider_id FOREIGN KEY(provider_id)REFERENCES Providers(provider_id));


CREATE TABLE Categories(
      category_id int IDENTITY(1,1) PRIMARY KEY,
	  category_name varchar (20),
	  description text);

 DROP TABLE Categories;

CREATE TABLE Product_Categories(
      category_id int IDENTITY(1,1)PRIMARY KEY,
	  product_id int NOT NULL FOREIGN KEY(product_id)REFERENCES Products(product_id),
	  product_type varchar(30));


CREATE TABLE Orders(
      order_id int IDENTITY(1,1)PRIMARY KEY,
	  customer_id int NOT NULL,
	  order_date date NOT NULL,
	  product_id int NOT NULL,
	  number_of_items int NOT NULL,
	  registration_number int NOT NULL,
	  total_amount int NOT NULL,
	  CONSTRAINT customer_id FOREIGN KEY(customer_id)REFERENCES Customers(customer_id),
	  CONSTRAINT product_id FOREIGN KEY(product_id) REFERENCES Products(product_id));




CREATE TABLE Payments(
      payment_id int IDENTITY(1,1)PRIMARY KEY,
	  credit_card_number decimal NOT NULL,
	  bank_name varchar(50) NOT NULL,
	  name_on_the_card varchar(30) NOT NULL,
	  expiration_date date NOT NULL,
	  user_id int NOT NULL FOREIGN KEY (user_id) REFERENCES Users(user_id),
	  order_id int NOT NULL FOREIGN KEY(order_id)REFERENCES Orders(order_id));






ALTER TABLE dbo.Products
ALTER COLUMN  product_price varchar(50) NOT NULL;


ALTER TABLE dbo.Payments
ALTER COLUMN credit_card_number varchar(50) NOT NULL;



ALTER TABLE dbo.Orders
ALTER COLUMN  order_date varchar(50) NOT NULL;