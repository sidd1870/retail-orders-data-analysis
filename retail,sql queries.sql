
-- 1. Total Sales and Profit
SELECT SUM(sale_price) AS Total_Sales, SUM(profit) AS Total_Profit
FROM df_orders;

-- 2. Sales by Category
SELECT category, SUM(sale_price) AS Category_Sales
FROM df_orders
GROUP BY category
ORDER BY Category_Sales DESC;

-- 3. Top 10 Customers by Sales
SELECT TOP 10 customer_name, SUM(sale_price) AS Total_Sales
FROM df_orders
GROUP BY customer_name
ORDER BY Total_Sales DESC;

-- 4. Customer Segmentation
SELECT segment, COUNT(DISTINCT customer_id) AS Customer_Count
FROM df_orders
GROUP BY segment;

-- 5. Sales by Region
SELECT region, SUM(sale_price) AS Region_Sales
FROM df_orders
GROUP BY region
ORDER BY Region_Sales DESC;

-- 6. Profit by State
SELECT state, SUM(profit) AS State_Profit
FROM df_orders
GROUP BY state
ORDER BY State_Profit DESC;

-- 7. Most Profitable Products
SELECT TOP 10 product_name, SUM(profit) AS Total_Profit
FROM df_orders
GROUP BY product_name
ORDER BY Total_Profit DESC;

-- 8. Loss-Making Products
SELECT product_name, SUM(profit) AS Total_Profit
FROM df_orders
GROUP BY product_name
HAVING SUM(profit) < 0
ORDER BY Total_Profit ASC;

-- 9. Monthly Sales Trend
SELECT FORMAT(order_date, 'yyyy-MM') AS Month, SUM(sale_price) AS Monthly_Sales
FROM df_orders
GROUP BY FORMAT(order_date, 'yyyy-MM')
ORDER BY Month;

-- 10. Yearly Profit
SELECT YEAR(order_date) AS Year, SUM(profit) AS Yearly_Profit
FROM df_orders
GROUP BY YEAR(order_date)
ORDER BY Year;















---CTE's----

-- 1. Top 5 Highest Selling Products in Each Region
WITH cte AS (
    SELECT region, product_id, SUM(sale_price) AS sales
    FROM df_orders
    GROUP BY region, product_id
)
SELECT *
FROM (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY region ORDER BY sales DESC) AS rn
    FROM cte
) A
WHERE rn <= 5;

-- 2. Month-over-Month Growth Comparison (2022 vs 2023)
WITH cte AS (
    SELECT YEAR(order_date) AS order_year,
           MONTH(order_date) AS order_month,
           SUM(sale_price) AS monthly_sales
    FROM df_orders
    GROUP BY YEAR(order_date), MONTH(order_date)
)
SELECT order_month,
       SUM(CASE WHEN order_year = 2022 THEN monthly_sales ELSE 0 END) AS sales_2022,
       SUM(CASE WHEN order_year = 2023 THEN monthly_sales ELSE 0 END) AS sales_2023
FROM cte
GROUP BY order_month
ORDER BY order_month;

-- 3. Highest Sales Month per Category
WITH cte AS (
    SELECT category,
           YEAR(order_date) AS order_year,
           MONTH(order_date) AS order_month,
           SUM(sale_price) AS monthly_sales
    FROM df_orders
    GROUP BY category, YEAR(order_date), MONTH(order_date)
)
SELECT category, order_year, order_month, monthly_sales
FROM (
    SELECT *,
           RANK() OVER (PARTITION BY category ORDER BY monthly_sales DESC) AS rnk
    FROM cte
) A
WHERE rnk = 1;

-- 4. Subcategory Growth Analysis (2022 vs 2023)
WITH cte AS (
    SELECT sub_category,
           YEAR(order_date) AS order_year,
           SUM(profit) AS yearly_profit
    FROM df_orders
    GROUP BY sub_category, YEAR(order_date)
)
SELECT sub_category,
       SUM(CASE WHEN order_year = 2022 THEN yearly_profit ELSE 0 END) AS profit_2022,
       SUM(CASE WHEN order_year = 2023 THEN yearly_profit ELSE 0 END) AS profit_2023,
       (SUM(CASE WHEN order_year = 2023 THEN yearly_profit ELSE 0 END) -
        SUM(CASE WHEN order_year = 2022 THEN yearly_profit ELSE 0 END)) AS profit_growth
FROM cte
GROUP BY sub_category
ORDER BY profit_growth DESC;