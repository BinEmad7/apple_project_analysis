--- Explore Data
SELECT * FROM category;
SELECT * FROM products;
SELECT * FROM sales;
SELECT * FROM stores;
SELECT * FROM warranty;


---- EDA
SELECT DISTINCT repair_status FROM warranty;
SELECT COUNT(*) FROM sales;

--- Improving Query Performance
CREATE INDEX sales_product_id ON sales(product_id);
CREATE INDEX sales_store_id ON sales(store_id);
CREATE INDEX sales_sale_date ON sales(sale_date);


--- Problems

-- 1st
-- Number of Stores in each Country
SELECT Country, COUNT(Store_ID) as Stores_Number
FROM stores
GROUP BY Country
ORDER BY Stores_Number DESC
;

-- 2nd
-- Number of Units Sold by each Store
SELECT sl.store_id, st.Store_Name, st.City, st.Country, SUM(quantity) as Total_Sales
FROM sales as sl
JOIN stores as st ON sl.store_id = st.Store_ID
GROUP BY sl.store_id, st.Store_Name, st.City, st.Country
ORDER BY Total_Sales DESC
;

-- 3rd
-- Number of Sales in DEC 2023
SELECT COUNT(sale_id) Total_Sales
FROM sales
WHERE sale_date = '2023-12-01'
;

SELECT EOMONTH(sale_date) as [Month], COUNT(sale_id) as Total_Sales
FROM sales
GROUP BY EOMONTH(sale_date)
ORDER BY [Month]
;

-- 4th
-- Number of Stores have NEVER had a Warranty Claim Filed
SELECT COUNT(*)
FROM
(
    SELECT st.Store_ID
    FROM stores st
    LEFT JOIN sales s
        ON st.Store_ID = s.store_id
    LEFT JOIN warranty w
        ON s.sale_id = w.sale_id
    GROUP BY st.Store_ID
    HAVING COUNT(w.claim_id) = 0
) AS SubQuery;


-- 5th
-- Percentages of Different Warranty Claims
SELECT repair_status, COUNT(repair_status) as Num_Repeair_status, 
		CAST(
			COUNT(repair_status)
			*100.0
			/(SELECT COUNT(*) FROM warranty) 
			AS DECIMAL(12,2))
FROM warranty
GROUP BY repair_status
ORDER BY COUNT(repair_status) DESC
;

-- 6th
-- Store with Highest Number of sold Units 2023
SELECT TOP 12
	st.Store_ID, 
	st.Store_Name,
	YEAR(sl.sale_date),
	SUM(sl.quantity) Total_Units_Sold
FROM sales as sl
JOIN stores as st ON sl.store_id = st.Store_ID
WHERE YEAR(sl.sale_date) = '2023'
GROUP BY st.Store_ID, st.Store_Name, YEAR(sl.sale_date)
ORDER BY Total_Units_Sold DESC
;

-- 7th
-- Number of Unique Products sold 2023
SELECT COUNT(DISTINCT product_id) as NUM_Unique_Products
FROM sales
WHERE YEAR(sale_date) = '2023'
;

-- 8th
-- Average Price of Products in each Category
SELECT c.category_id, c.category_name, AVG(p.Price) as avg_price
FROM category as c
JOIN products as p On c.category_id = p.Category_ID
GROUP BY c.Category_id, c.category_name
ORDER BY avg_price DESC
;

-- 9th
-- Number of Warranty Claims files in 2020
SELECT COUNT(*)
FROM warranty
WHERE YEAR(claim_date) = 2020
;

-- 10th
-- Best-Selling Day for each Story based on Highest Quantity sold
SELECT Store_ID, Store_Name, Day_of_Week, Total_Quantity
FROM(
	SELECT  st.Store_ID,
			st.Store_Name,
			DATENAME(weekday, sl.sale_date) as Day_of_Week,
			SUM(sl.quantity) as Total_Quantity,
			RANK() OVER(PARTITION BY st.Store_ID ORDER BY SUM(sl.quantity) DESC) as SalesRank
	FROM sales as sl
	JOIN stores as st 
	ON sl.store_id = st.Store_ID
	GROUP BY st.Store_ID, st.Store_Name, 
	DATENAME(weekday, sl.sale_date)
) as SubQuery
WHERE SalesRank = 1
ORDER BY Store_Name
;

-- 11th
-- Least Selling Product for Each Country for Each Year based on Units Sold
SELECT Country, [YEAR], product_id, Product_Name, Total_Quantity
FROM (
		SELECT  st.Country,
			YEAR(sl.sale_date) as [Year], 
			sl.product_id, 
			p.Product_Name,
			SUM(sl.quantity) as Total_Quantity,
			RANK() OVER(PARTITION BY st.Country, YEAR(sl.sale_date) ORDER BY SUM(sl.quantity) ASC) as SalesRank
		FROM sales as sl
		JOIN products as p
		ON sl.product_id = p.Product_ID
		JOIN stores as st
		ON sl.store_id = st.Store_ID
		GROUP BY st.Country, 
				 YEAR(sl.sale_date), 
				 sl.product_id, 
				 p.Product_Name
) AS SubQuery
WHERE SalesRank = 1
ORDER BY Country, Year
;

-- 12th
-- Number of Warranty Claims Filed within 180 Days of Product Sale
SELECT COUNT(*)
FROM warranty as w
JOIN sales as s
ON w.sale_id = s.sale_id
WHERE DATEDIFF(day,  s.sale_date, w.claim_date) <= 180
;

-- 13th
-- Number of Warranty Claims Files for Products Lanuched the Last Four Years
SELECT	p.Product_ID, 
		P.Product_Name, 
		COUNT(w.claim_id) AS Num_Claim
FROM (	SELECT *
		FROM products
		WHERE Launch_Date >  DATEADD(YEAR, -4, GETDATE())
) AS p
JOIN sales as s
ON p.Product_ID = s.product_id
JOIN warranty as w
ON s.sale_id = w.sale_id
GROUP BY p.Product_ID, 
		 P.Product_Name
;

-- 14th
-- Months where Sales Exceeded 15,000 units in the USA in the Last 30 Months
SELECT  CAST((EOMONTH(sale_date)) AS VARCHAR) AS [Month], 
		SUM(quantity) AS Total_Units
FROM stores AS st
JOIN sales AS sl
ON st.Store_ID = sl.store_id
WHERE st.Country =  'United States'
AND sl.sale_date >  DATEADD(MONTH, -30, GETDATE())
GROUP BY EOMONTH(sale_date)
HAVING SUM(quantity) > 15000
ORDER BY Total_Units DESC
;

-- 15th
-- Identify Category with the Most Warranty Claim Files in the last Three Years.
SELECT c.category_name, c.category_id, COUNT(w.claim_id) AS Num_Claim
FROM warranty as w
JOIN sales as s
ON w.sale_id = s.sale_id
JOIN products as p
ON s.product_id = p.Product_ID
JOIN category as c
ON p.Category_ID = c.category_id
WHERE w.claim_date >  DATEADD(YEAR, -3, GETDATE())
GROUP BY c.category_name, c.category_id
ORDER BY Num_Claim DESC
;

-- 16th
-- Percentage Chance of Recieving Warranty Claims after Each Purchase for Each Country
SELECT  st.Country,
		SUM(sl.quantity) AS Total_Units,
		COUNT(w.claim_id) AS Num_Claim,
		CAST(100.0*COUNT(w.claim_id)/SUM(sl.quantity) AS DECIMAL(10,3)) AS Risk
FROM sales as sl
LEFT JOIN warranty as w
ON sl.sale_id = w.sale_id
JOIN stores as st
ON sl.store_id = st.Store_ID
GROUP BY st.Country
ORDER BY Risk DESC
;

-- 17th
-- Analyze the year-by-year Growth Ratio for each Store
WITH Year_Sales AS(
	SELECT  st.Store_ID, st.Store_Name, 
		    YEAR(sl.sale_date) AS [Year], 
			SUM(sl.quantity) AS Total_Units,
			SUM(sl.quantity * p.Price) AS Total_Revenue
    FROM sales AS sl
    JOIN stores AS st ON sl.store_id = st.Store_ID 
    JOIN products AS p ON sl.product_id = p.Product_ID 
    GROUP BY st.Store_ID, st.Store_Name, YEAR(sl.sale_date)
),
Growth AS(
	SELECT  Store_ID,
			Store_Name, 
			[Year], 
			Total_Units, 
			Total_Revenue,
			LAG(Total_Revenue) OVER (PARTITION BY Store_ID ORDER BY [Year]) AS Last_Year_Revenue,
			CAST(
				(Total_Revenue - LAG(Total_Revenue) OVER (PARTITION BY Store_ID ORDER BY [Year])) * 100.0 
				/ 
				LAG(Total_Revenue) OVER (PARTITION BY Store_ID ORDER BY [Year])
				AS DECIMAL(10,2)) AS Revenue_Growth
	FROM Year_Sales
)
SELECT 
    Store_Name, 
    [Year], 
    Revenue_Growth,
    RANK() OVER (ORDER BY Revenue_Growth DESC) AS Growth_Rank
FROM Growth
WHERE Revenue_Growth IS NOT NULL
ORDER BY Store_Name, [Year]
;

-- 18th
-- Correlation between Product Price and Warranty Claims for Products sold in the Last Five Years, segmented by Price Range
WITH CTE AS(
			SELECT  w.claim_id,
					p.Price,
					s.quantity,
					s.sale_id,
					CASE
						WHEN p.Price <= 400 THEN 'Cheap'
						WHEN p.Price <= 800 THEN 'Less Expensive'
						WHEN p.Price <= 1200 THEN 'Mid Range'
						WHEN p.Price <= 1500 THEN 'Expensive'
						ELSE 'More Expensive'
					END AS Price_Segment
			FROM sales as s
			JOIN products as p
			ON s.product_id = p.Product_ID
			LEFT JOIN warranty as w
			ON s.sale_id = w.sale_id
			WHERE s.sale_date >  DATEADD(YEAR, -5, GETDATE())
)
SELECT	Price_Segment,
		COUNT(sale_id) AS Num_sales,
		COUNT(claim_id) AS Num_Claim, 
		SUM(Price) AS Total_Sales,
		SUM(quantity) AS Total_Units,
		CAST(
			COUNT(claim_id)
			*100.0
			/(COUNT(sale_id)) 
			AS DECIMAL(10,2)
			) AS Claim_Percentage
FROM CTE
GROUP BY Price_Segment
;

-- 19th
-- Store with the highest percentage of 'Paid Repaired' Cliams relative to Total Claims Filed
SELECT  TOP 1
		st.Store_ID, 
		st.Store_Name,
		COUNT(w.claim_id) AS Num_Claim,
		SUM(
			CASE 
			    WHEN w.repair_status = 'Completed' THEN 1
			    ELSE 0
			END
			) AS Paid_Claims,
		CAST(
			  SUM(CASE 
				      WHEN w.repair_status = 'Completed' THEN 1
				      ELSE 0
				  END) * 100.0
				  / COUNT(w.claim_id)
			  AS DECIMAL(5,2)
			) AS Paid_Percentage
FROM warranty AS w
JOIN sales AS sl
ON sl.sale_id = w.sale_id
JOIN stores AS st
ON sl.store_id = st.Store_ID
GROUP BY  st.Store_ID, 
		  st.Store_Name
ORDER BY Paid_Percentage DESC
;

-- 20th
-- Write a Query to Calculate the Monthly Running Total of Sales for each Store over the Past Four Years and Compare Trends during this Period
SELECT  st.Store_ID,
		st.Store_Name,
		EOMONTH(sl.sale_date) AS [Month],
		COUNT(sl.sale_id) AS Total_Orders_Sales,
		SUM(sl.quantity) AS Total_Units_Sold,
		SUM(p.Price * sl.quantity) AS Total_Money_Sales,
		SUM(SUM(p.Price * sl.quantity)) 
			OVER(PARTITION BY st.Store_ID
				 ORDER BY EOMONTH(sl.sale_date)
				 ) AS Running_Total_Sales
FROM sales AS sl
JOIN stores AS st
ON sl.store_id = st.Store_ID
JOIN products AS p
ON sl.product_id = p.Product_ID
WHERE sl.sale_date >  DATEADD(YEAR, -4, GETDATE())
GROUP BY  st.Store_ID, 
		  st.Store_Name,
		  EOMONTH(sl.sale_date)
ORDER BY st.Store_Name, [Month]
;

-- 21st
-- Analyze Product Sales Trends over Time, Segmented into Key Periods: from Launch to 6 Months, 6-12 Months, 12-18 Months, and beyond 18 Months.
WITH CTE AS(
SELECT  sl.sale_id,
		p.Product_ID,
		p.Product_Name,
		p.Launch_Date,
		sl.quantity,
		p.Price,
		CASE
			WHEN sl.sale_date <= DATEADD(MONTH, 6, p.Launch_Date) THEN '0 - 6 Months'
			WHEN sl.sale_date <= DATEADD(MONTH, 12, p.Launch_Date) THEN '6 - 12 Months'
			WHEN sl.sale_date <= DATEADD(MONTH, 18, p.Launch_Date) THEN '12 - 18 Months'
			ELSE 'Beyond 18 Months'
		END AS Time_Segment,
		CASE
			WHEN sl.sale_date <= DATEADD(MONTH, 6, p.Launch_Date) THEN 1
			WHEN sl.sale_date <= DATEADD(MONTH, 12, p.Launch_Date) THEN 2
			WHEN sl.sale_date <= DATEADD(MONTH, 18, p.Launch_Date) THEN 3
			ELSE 4
		END AS Order_Time_Segment
FROM sales AS sl
JOIN products AS p
ON sl.product_id = p.Product_ID
)
SELECT  Product_ID,
		Product_Name,
		Launch_Date,
		Time_Segment,
		COUNT(sale_id) AS Total_Orders_Sales,
		SUM(quantity) AS Total_Units_Sold,
		SUM(Price * quantity) AS Total_Money_Sales
FROM CTE
GROUP BY  Product_ID,
		  Product_Name,
		  Launch_Date,
		  Time_Segment,
		  Order_Time_Segment
ORDER BY  Product_Name,
		  Order_Time_Segment
;
