CREATE DATABASE IF NOT EXISTS superstore;
USE superstore;
SELECT* FROM data;

## DATA CLEANING

-- Check duplicates

SELECT `Order ID`, COUNT(*)
FROM Data
GROUP BY `Order ID`
HAVING COUNT(*) > 1;

SELECT *
FROM (
SELECT `Order ID`,
ROW_NUMBER() OVER(PARTITION BY `Order ID` ORDER BY `Order ID`) AS Duplicates
FROM Data ) AS Subquery
WHERE Duplicates > 1;

-- FULL DATA OF DUPLICATED

SELECT d.*
FROM Data d
JOIN(
	SELECT `Order ID`, COUNT(`Order ID`) DUPLICATED
    FROM data
    GROUP BY `Order ID`
    HAVING DUPLICATED > 1
    ) DUP ON d.`Order ID` = DUP.`Order ID`;

-- Solve and remove duplicates using CTE (Common table expression)
SET SQL_SAFE_UPDATES=0;

WITH CTE AS (
SELECT `Order ID`,
ROW_NUMBER() OVER(PARTITION BY `Order ID` ORDER BY `Order ID`) AS ROW_NUM
FROM Data
)DELETE FROM CTE WHERE ROW_NUM > 1;

-- another way to delete

DELETE FROM Data
WHERE `Order ID` IN (
SELECT `Order ID`
FROM (
SELECT `Order ID`,
ROW_NUMBER() OVER(PARTITION BY `Order ID` ORDER BY `Order ID`) AS DUPLICATED
FROM Data) AS SUBQUERY
WHERE DUPLICATED > 1
);

-- Check for Missing Values:

SELECT 
	SUM(CASE WHEN `Postal Code` IS NULL THEN 1 ELSE 0 END) AS `Missing PostalCode`,
	SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS `Missing Sales`,
    SUM(CASE WHEN Quantity IS NULL THEN 1 ELSE 0 END) AS `Missing Quantity`,
    SUM(CASE WHEN Discount IS NULL THEN 1 ELSE 0 END) AS `Missing Discount`,
    SUM(CASE WHEN Profit IS NULL THEN 1 ELSE 0 END) AS `Missing Profit`
FROM Data;

-- Check for Inconsistent Categorical Data:

SELECT DISTINCT `Ship Mode`
FROM Data;

-- Inspect Data Types:
DESCRIBE Data;

UPDATE Data
SET `Order Date` = str_to_date(`Order Date`,'%m/%d/%Y'),
	`Ship Date` = str_to_date(`Ship Date`,'%m/%d/%Y');

ALTER TABLE Data
MODIFY COLUMN `Order Date` DATE,
MODIFY COLUMN `Ship Date` date;

-- ---------------------------------------------------------------------------------

-- MySQL queries 

-- 1. What is the total sales amount in the dataset?

SELECT ROUND(SUM(sales),2) as `total sales`
FROM DATA;

-- 2.Which product category has the highest sales?

SELECT Category, ROUND(SUM(sales),2) as `highest sales`
FROM DATA
GROUP BY Category
ORDER BY `highest sales` DESC
LIMIT 1;

-- 3.What is the average discount given across all orders?
DESCRIBE Data;

SELECT ROUND(AVG(Discount),3) as total_discount
FROM data;

-- 4.Which state has the highest number of orders?
SELECT State, COUNT(DISTINCT `Order ID`) AS `Highest order`
FROM Data
GROUP BY State
ORDER BY `Highest order` DESC
LIMIT 1;

-- 5.What is the most common ship mode used?
SELECT `Ship mode`,COUNT(`Ship mode`) as most_used
FROM Data
GROUP BY `Ship mode`
ORDER BY most_used
LIMIT 1;

-- 6. Which customer has the highest total sales?
SELECT 
	`Customer Name`, 
    ROUND(MAX(Sales),3) AS `Highest total sales`
FROM Data
GROUP BY `Customer Name`
ORDER BY `Highest total sales` DESC
LIMIT 1;

-- WINDOW FUNCTION
SELECT 
    `Customer ID`, 
    `Customer Name`, 
    SUM(Sales) OVER (PARTITION BY `Customer ID`) AS TotalSales
FROM 
    Data
ORDER BY 
    TotalSales DESC
LIMIT 1;


-- 7. Top 5 most profitable products:
SELECT 
	`Product Name`, 
    ROUND(SUM(Profit),2) AS `most profitable`
FROM Data
GROUP BY `Product Name`
ORDER BY `most profitable` DESC
LIMIT 5;

-- 8. Customer segment with the highest total sales:
SELECT 
		Segment, 
        ROUND(SUM(sales),3) AS `highest total sales`
FROM Data
GROUP BY Segment
ORDER BY `highest total sales` DESC
LIMIT 1;

-- 9.Average shipping time in days:
SELECT * FROM DATA;
DESCRIBE Data;

SELECT ROUND(AVG(timediff(str_to_date(`Ship Date`,'%m/%d/%Y'),
       str_to_date(`Order Date`,'%m/%d/%Y'))),2) AS `Average shipping in days`
FROM Data;

-- 10. Top 3 cities with the highest average profit per order:

SELECT 	
	 City,
	`Order ID`,
	 ROUND(AVG(Profit),2) AS `highest average profit`
FROM Data
GROUP BY City,`Order ID`
ORDER BY `highest average profit` DESC
lIMIT 3;

-- 11. Correlation between discount and profit:
SELECT 
    (COUNT(*) * SUM(Discount * Profit) - SUM(Discount) * SUM(Profit)) / 
    (SQRT((COUNT(*) * SUM(Discount * Discount) - SUM(Discount) * SUM(Discount)) * 
    (COUNT(*) * SUM(Profit * Profit) - SUM(Profit) * SUM(Profit)))) AS DiscountProfitCorrelation
FROM Data;


-- 12.Sales distribution across different discount levels:
SELECT * FROM Data;
SELECT distinct(Discount) FROM DATA;

SELECT CASE
		WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.1 THEN '0-10%'
        WHEN Discount <= 0.2 THEN '11-20%'
        WHEN Discount <= 0.3 THEN '21-30%'
        ELSE '31%+'
        END AS Discount_total,
        ROUND(SUM(sales),2) AS `Total sales`
FROM Data
GROUP BY Discount_total
ORDER BY `Total sales`;

SELECT 
    CASE 
        WHEN Discount = 0 THEN 'No Discount'
        WHEN Discount <= 0.1 THEN '0-10%'
        WHEN Discount <= 0.2 THEN '11-20%'
        WHEN Discount <= 0.3 THEN '21-30%'
        ELSE '31%+'
    END AS DiscountBucket,
    ROUND(SUM(Sales), 2) AS TotalSales
FROM data
GROUP BY DiscountBucket
ORDER BY TotalSales DESC;














