-- =====================================================
-- SUPERSTORE SALES ANALYSIS
-- PostgreSQL
-- =====================================================


-- =====================================================
-- 1. DATA VALIDATION
-- =====================================================

-- Check total number of rows
SELECT COUNT(*) AS total_rows
FROM superstore_clean;


-- Check for NULL values in important columns
SELECT
    COUNT(*) FILTER (WHERE order_id IS NULL) AS null_order_id,
    COUNT(*) FILTER (WHERE order_date IS NULL) AS null_order_date,
    COUNT(*) FILTER (WHERE sales IS NULL) AS null_sales,
    COUNT(*) FILTER (WHERE profit IS NULL) AS null_profit
FROM superstore_clean;


-- Check date ranges
SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date,
    MIN(ship_date) AS earliest_ship_date,
    MAX(ship_date) AS latest_ship_date
FROM superstore_clean;


-- Check for orders shipped before they were placed
SELECT COUNT(*) AS invalid_ship_dates
FROM superstore_clean
WHERE ship_date < order_date;

-- =====================================================
-- 2. DUPLICATE CHECK
-- =====================================================

-- Check for duplicate rows
SELECT
    order_id,
    product_id,
    customer_id,
    order_date,
    COUNT(*) AS duplicate_count
FROM superstore_clean
GROUP BY
    order_id,
    product_id,
    customer_id,
    order_date
HAVING COUNT(*) > 1;
-- =====================================================
-- 3. DATE VALIDATION
-- =====================================================

-- Check the order and ship date ranges
SELECT
    MIN(order_date) AS earliest_order_date,
    MAX(order_date) AS latest_order_date,
    MIN(ship_date) AS earliest_ship_date,
    MAX(ship_date) AS latest_ship_date
FROM superstore_clean;


-- Check for invalid shipping dates
-- Ship date should not be earlier than order date
SELECT COUNT(*) AS invalid_ship_dates
FROM superstore_clean
WHERE ship_date < order_date;
-- =====================================================
-- 4. KPI ANALYSIS
-- =====================================================

-- Calculate key business KPIs
SELECT
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    SUM(quantity) AS total_quantity,
    ROUND(
        (SUM(profit) / NULLIF(SUM(sales), 0) * 100)::numeric,
        2
    ) AS profit_margin_percentage
FROM superstore_clean;

-- =====================================================
-- 5. BUSINESS ANALYSIS
-- =====================================================

-- Sales and profit by category
SELECT
    category,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM superstore_clean
GROUP BY category
ORDER BY total_sales DESC;
-- Sales and profit by sub-category
SELECT
    sub_category,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM superstore_clean
GROUP BY sub_category
ORDER BY total_sales DESC;

-- Monthly sales and profit trend
SELECT
    DATE_TRUNC('month', order_date)::date AS month,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM superstore_clean
GROUP BY DATE_TRUNC('month', order_date)
ORDER BY month;
-- Year-over-year sales, profit, and quantity
SELECT
    EXTRACT(YEAR FROM order_date) AS year,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit,
    SUM(quantity) AS total_quantity
FROM superstore_clean
GROUP BY EXTRACT(YEAR FROM order_date)
ORDER BY year;

-- Tables profitability analysis for 2026
SELECT
    sub_category,
    ROUND(AVG(discount)::numeric, 2) AS avg_discount,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM superstore_clean
WHERE sub_category = 'Tables'
  AND EXTRACT(YEAR FROM order_date) = 2026
GROUP BY sub_category;

-- 2026 sub-category performance
SELECT
    sub_category,
    ROUND(SUM(sales)::numeric, 2) AS total_sales,
    ROUND(SUM(profit)::numeric, 2) AS total_profit
FROM superstore_clean
WHERE EXTRACT(YEAR FROM order_date) = 2026
GROUP BY sub_category
ORDER BY total_sales DESC;