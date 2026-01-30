/* =============================================================================
   PROJECT: E-Commerce Sales & Customer Behavior Analysis
   DATASET: UK-based Online Retail (2010-2011)
   -----------------------------------------------------------------------------
   OBJECTIVE:
   Analyze sales performance and customer purchasing behavior to derive 
   insights related to revenue trends using structured SQL analysis. This project
   demonstrates the ability to transform raw transactional data into clean, 
   business-ready datasets. 

   TOOLS & SKILLS DEMONSTRATED:
   - Data Transformation and Cleaning: CTEs & View creation for modular, reusable code
   - Analytical Logic: Advanced aggregations, filtering (HAVING, Group BY), and Joins
   - Advanced SQL: Window functions for ranking and trend identification.
   ============================================================================= */


/* =============================================================================
   CORE SALES METRICS
   ============================================================================= */


-- Total revenue and total orders across all transactions
SELECT 
  COUNT(DISTINCT InvoiceNo) AS total_orders,
  printf('%,.2f', SUM(sales_value)) AS total_revenue
FROM clean_sales;

-- Revenue by country
SELECT 
  Country,
printf('%,.2f', SUM(sales_value)) AS country_revenue
FROM clean_sales
GROUP BY Country
ORDER BY SUM(sales_value) DESC;

-- Monthly Revenue Trend
WITH monthly_data AS (
    SELECT 
      printf('%s-%02d', 
      -- Formats InvoiceDate string to 'YYYY-MM', taking year (last 4 digits before space) and month (before first slash)
        SUBSTR(InvoiceDate, INSTR(InvoiceDate, ' ') - 4, 4), 
        SUBSTR(InvoiceDate, 1, INSTR(InvoiceDate, '/') - 1)
      ) AS month,       -- Example: 'DD/MM/YYYY HH:MI' becomes 'YYYY-MM'
      SUM(sales_value) AS revenue_val
    FROM clean_sales
    GROUP BY month
)
-- Monthly Rows
SELECT month, printf('%,.2f', revenue_val) AS monthly_revenue
FROM monthly_data

UNION ALL

-- Check to ensure Grand Total matches total revenue across all transactions
SELECT 'GRAND TOTAL', printf('%,.2f', SUM(revenue_val))
FROM monthly_data;


/* =============================================================================
   CUSTOMER-LEVEL ANALYSIS
   ============================================================================= */


-- Top 10 highest-spending customers
WITH customer_totals AS (
  SELECT
    CustomerID,
    ROUND(SUM(sales_value), 2) AS total_spent
  FROM clean_sales
  GROUP BY CustomerID
)
SELECT *
FROM customer_totals
ORDER BY total_spent DESC
LIMIT 10;

-- Customer Purchase Frequency (repeat customers only)
SELECT 
  CustomerID,
  COUNT(DISTINCT InvoiceNo) AS total_orders
FROM clean_sales
GROUP BY CustomerID
HAVING total_orders > 1
ORDER BY total_orders DESC
LIMIT 50;

-- Average order value across all customers
SELECT
  ROUND(
    SUM(sales_value) / COUNT(DISTINCT InvoiceNo),2) AS avg_order_value
FROM clean_sales;

-- Create customer segments based on total lifetime spend       
WITH customer_segments AS (
  SELECT 
    CustomerID,
    SUM(sales_value) AS total_spent,
    CASE 
      WHEN SUM(sales_value) > 5000 THEN 'VIP'
      WHEN SUM(sales_value) > 1000 THEN 'High Value'
      ELSE 'Standard'
    END AS customer_segment
  FROM clean_sales
  GROUP BY CustomerID
)

SELECT 
  customer_segment,
  COUNT(*) AS customer_count
FROM customer_segments
GROUP BY customer_segment
ORDER BY customer_count DESC;


/* =============================================================================
   BASIC WINDOW FUNCTION ANALYSIS
   ============================================================================= */


-- Percentage contribution of each country to total revenue
SELECT
  Country,
  ROUND(SUM(sales_value), 2) AS country_revenue,
  ROUND(
    SUM(sales_value) * 100.0 /
    SUM(SUM(sales_value)) OVER (),
    2
  ) AS percentage_of_total_revenue
FROM clean_sales
GROUP BY Country
ORDER BY country_revenue DESC;

-- Compare individual customer order counts to the average
WITH customer_counts AS (
  SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS total_orders
  FROM clean_sales
  GROUP BY CustomerID
)
SELECT
  CustomerID,
  total_orders,
  ROUND(AVG(total_orders) OVER (), 2) AS avg_orders_per_customer,
  ROUND(total_orders - AVG(total_orders) OVER (), 2) AS variance_from_avg
FROM customer_counts
ORDER BY total_orders DESC
LIMIT 70;


/* =============================================================================
   JOIN-BASED ANALYSIS
   ============================================================================= */


-- Transaction details for high-value customers
WITH customer_totals AS (
  SELECT
    CustomerID,
    SUM(sales_value) AS total_spent
  FROM clean_sales
  GROUP BY CustomerID
)
  SELECT
    cs.InvoiceNo,
    cs.InvoiceDate,
    cs.CustomerID,
    ROUND(cs.sales_value, 2) AS transaction_value,
    ROUND(ct.total_spent, 2) AS lifetime_spent
  FROM clean_sales cs
  JOIN customer_totals ct
    ON cs.CustomerID = ct.CustomerID
  ORDER BY ct.total_spent DESC
  LIMIT 20;

-- Compare highest individual order values to total revenue of the customer's country
WITH country_revenue AS (
  SELECT
    Country,
    SUM(sales_value) AS total_country_revenue
  FROM clean_sales
  GROUP BY Country
)
SELECT
  cs.InvoiceNo,
  cs.Country,
  ROUND(cs.sales_value, 2) AS order_value,
  ROUND(cr.total_country_revenue, 2) AS country_revenue
FROM clean_sales cs
JOIN country_revenue cr
  ON cs.Country = cr.Country
ORDER BY order_value DESC
LIMIT 20;


/* =============================================================================
   KEY INSIGHTS
   -----------------------------------------------------------------------------
   - Total revenue for the period was £8.91M, with an average order value of £480.87.
   - The United Kingdom accounts for 82.01% of total revenue, indicating strong
     geographic concentration.
   - Revenue peaks in Q4 2011, with November being the highest-performing month,
     suggesting seasonal purchasing behavior.
   - Customer activity is highly skewed: while the average customer places ~4
     orders, a small subset places over 200 orders and contributes a
     disproportionate share of revenue.
   - Only 38% of customers fall into the VIP and High-Value segments, yet they 
     account for a significant portion of total revenue, this signals a major opportunity
     to optimize growth through specialized VIP retention strategies.
   ============================================================================= */