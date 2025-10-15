﻿



CREATE TABLE sales_store(
transaction_id varchar(15),
customer_id varchar(15),
customer_name varchar(30),
customer_age int,
gender varchar(15),
product_id varchar(15),
product_name varchar(15),
product_category varchar(15),
quantiy int,
prce float,
payment_mode varchar(15),
purchase_date date,
time_of_purchase time,
status varchar(15)
);
select * from sales_store
set dateformat dmy
bulk insert sales_store
from 'D:\Store_data.csv'
with(
firstrow=2,
fieldterminator=',',
rowterminator='\n'
);
--copying data for cleaning
select * from sales_store
select * into sales from sales_store
select * from sales_store
select* from sales
--data cleaning
--step1= duplicate check
select transaction_id,count(*)
from sales
group by transaction_id
having count(transaction_id) >1

TXN240646
TXN342128
TXN855235
TXN981773
with cte as (
select *,             --2nd method 
ROW_NUMBER() over (partition by transaction_id order by transaction_id) as row_num
from sales
)
select * from cte
where row_num >1

with cte as (
select *,             --2nd method where the duplictae
ROW_NUMBER() over (partition by transaction_id order by transaction_id) as row_num
from sales
)
select * from cte
where transaction_id in ('TXN240646','TXN342128','TXN855235','TXN981773')

--deleting duplicate 4 rows;
with cte as (
select *,             --2nd method where the duplictae
ROW_NUMBER() over (partition by transaction_id order by transaction_id) as row_num
from sales
)
--delete from cte
--where row_num=2

--step2: correction of headers
select* from sales 
exec  sp_rename'sales.quantiy','quantity', 'column'
exec sp_rename'sales.prce','price','column'

--step3: check datatype
select column_name, data_type
from INFORMATION_SCHEMA.columns
where table_name='sales'
--step4: check null value
DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;

--treating null values 

SELECT *
FROM sales 
WHERE transaction_id IS NULL
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR
product_name IS NULL
OR
product_category IS NULL
OR
quantity IS NULL
or
payment_mode is null
or
purchase_date is null
or 
status is null
or 
price is null

DELETE FROM sales 
WHERE  transaction_id IS NULL


SELECT * FROM sales 
Where Customer_name='Ehsaan Ram'

UPDATE sales
SET customer_id='CUST9494'
WHERE transaction_id='TXN977900'

SELECT * FROM sales 
Where Customer_name='Damini Raju'

UPDATE sales
SET customer_id='CUST1401'
WHERE transaction_id='TXN985663'

SELECT * FROM sales 
Where Customer_id='CUST1003'

UPDATE sales
SET customer_name='Mahika Saini',customer_age=35,gender='Male'
WHERE transaction_id='TXN432798'

SELECT * FROM sales

--Step 5:- Data Cleaning

SELECT DISTINCT gender
FROM sales

UPDATE sales
SET gender='M'
WHERE gender='Male'

UPDATE sales
SET gender='F'
WHERE gender='Female'

SELECT DISTINCT payment_mode
FROM sales

UPDATE sales
SET payment_mode='Credit Card'
WHERE payment_mode='CC'
---------------------------------------Data Analysis-------------------------
---Q1. What are the top 5 most selling product by quantity?
SELECT * FROM sales
SELECT DISTINCT status
from sales

SELECT TOP 5 product_name, SUM(quantity) AS total_quantity_sold
FROM sales
WHERE status='delivered'
GROUP BY product_name
ORDER BY total_quantity_sold DESC

--Business Problem: We don't know which products are most in demand.

--Business Impact: Helps prioritize stock and boost sales through targeted promotions.
 
 --------------------------------------------------------------------------------------
 ------Q2. Which products are most frequently cancelled?

SELECT TOP 5 product_name, COUNT(*) AS total_cancelled
FROM sales
WHERE status='cancelled'
GROUP BY product_name
ORDER BY total_cancelled DESC

--Business Problem: Frequent cancellations affect revenue and customer trust.

--Business Impact: Identify poor-performing products to improve quality or remove from catalog.
------------------------------------------------------------------------------------------------------------
----Q3. What time of the day has the highest number of purchases?

select * from sales
	
	SELECT 
		CASE 
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END AS time_of_day,
		COUNT(*) AS total_orders
	FROM sales
	GROUP BY 
		CASE 
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 0 AND 5 THEN 'NIGHT'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 6 AND 11 THEN 'MORNING'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 12 AND 17 THEN 'AFTERNOON'
			WHEN DATEPART(HOUR,time_of_purchase) BETWEEN 18 AND 23 THEN 'EVENING'
		END
ORDER BY total_orders DESC
---------------------------------------------------------------------------------------------
SELECT 
	DATEPART(HOUR,time_of_purchase) AS Peak_time,
	COUNT(*) AS Total_orders
FROM sales
GROUP BY DATEPART(HOUR,time_of_purchase)
ORDER BY Peak_time

--Business Problem Solved: Find peak sales times.

--Business Impact: Optimize staffing, promotions, and server loads.
-----------------------------------------------------------------------------------------------------------

--Q4. Who are the top 5 highest spending customers?

SELECT * FROM sales

SELECT TOP 5 customer_name,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_spend
FROM sales 
GROUP BY customer_name
ORDER BY SUM(price*quantity) DESC

--Business Problem Solved: Identify VIP customers.

--Business Impact: Personalized offers, loyalty rewards, and retention.
------------------------------------------------------------------------------------
--🛍️ 5. Which product categories generate the highest revenue?

SELECT * FROM sales

SELECT 
	product_category,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS Revenue
FROM sales 
GROUP BY product_category
ORDER BY SUM(price*quantity) DESC

--Business Problem Solved: Identify top-performing product categories.

--Business Impact: Refine product strategy, supply chain, and promotions.
--allowing the business to invest more in high-margin or high-demand categories.

-----------------------------------------------------------------------------------------------------------
--Q6. What is the return/cancellation rate per product category?

SELECT * FROM sales
--cancellation
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*),'N3')+' %'AS cancelled_percent
FROM sales 
GROUP BY product_category
ORDER BY cancelled_percent DESC

--Return
SELECT product_category,
	FORMAT(COUNT(CASE WHEN status='returned' THEN 1 END)*100.0/COUNT(*),'N3')+' %' AS returned_percent
FROM sales 
GROUP BY product_category
ORDER BY returned_percent DESC

--Business Problem Solved: Monitor dissatisfaction trends per category.
---Business Impact: Reduce returns, improve product descriptions/expectations.Helps identify and fix product or logistics issues.
---------------------------------------------------------------------------------------------------
-----Q7. What is the most preferred payment mode?

SELECT * FROM sales

SELECT payment_mode, COUNT(payment_mode) AS total_count
FROM sales 
GROUP BY payment_mode
ORDER BY total_count desc
--Business Problem Solved: Know which payment options customers prefer.

--Business Impact: Streamline payment processing, prioritize popular modes.
----------------------------------------------------------------------------------------------------
----8. How does age group affect purchasing behavior?
SELECT * FROM sales
--SELECT MIN(customer_age) ,MAX(customer_age)
--from sales

SELECT 
	CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END AS customer_age,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_purchase
FROM sales 
GROUP BY CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END
ORDER BY SUM(price*quantity) DESC

------Business Problem Solved: Understand customer demographics.

--Business Impact: Targeted marketing and product recommendations by age group.

-----------------------------------------------------------------------------------------------------------
--Q9. What’s the monthly sales trend?
SELECT * FROM sales
--Method 1

SELECT 
	FORMAT(purchase_date,'yyyy-MM') AS Month_Year,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
	SUM(quantity) AS total_quantity
FROM sales 
GROUP BY FORMAT(purchase_date,'yyyy-MM')

--Method 2
SELECT * FROM sales
	
	SELECT 
		--YEAR(purchase_date) AS Years,
		MONTH(purchase_date) AS Months,
		FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
		SUM(quantity) AS total_quantity
FROM sales
GROUP BY MONTH(purchase_date)
ORDER BY Months
--2023	1	₹ 46,28,608
--2024	1	₹ 3,39,442

SELECT(4628608+339442)--4968050
--Business Problem: Sales fluctuations go unnoticed.


--Business Impact: Plan inventory and marketing according to seasonal trends.
------------------------------------------------------------------------------------------------------------
-----10. Are certain genders buying more specific product categories?

SELECT * from sales

--Method 1
SELECT gender,product_category,COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender,product_category
ORDER BY gender

--Method 2
SELECT * 
FROM ( 
	SELECT gender,product_category
	FROM sales 
	) AS source_table
PIVOT (
	COUNT(gender)
	FOR gender IN ([Male],[Female])
	) AS pivot_table
ORDER BY product_category

--Business Problem Solved: Gender-based product preferences.

--Business Impact: Personalized ads, gender-focused campaigns.


