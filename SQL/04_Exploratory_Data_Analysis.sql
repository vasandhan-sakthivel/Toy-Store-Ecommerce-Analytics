-- ==========================================================
-- PROJECT: TOY STORE E-COMMERCE ANALYTICS
-- SCRIPT: 04 - EXPLORATORY DATA ANALYSIS
-- PURPOSE: Analyse sales, profitability, customer behaviour,
--          website performance, product performance and refunds
-- DATABASE: toy_store_analytics
-- ==========================================================

USE toy_store_analytics;

-- ==========================================================
-- 1. DATASET DATE COVERAGE
-- ==========================================================

-- Identify the earliest and latest dates available across key tables

SELECT
    'Products' AS table_name,
    MIN(created_at) AS first_record,
    MAX(created_at) AS last_record
FROM products

UNION ALL

SELECT
    'Orders',
    MIN(created_at),
    MAX(created_at)
FROM orders

UNION ALL

SELECT
    'Website Sessions',
    MIN(created_at),
    MAX(created_at)
FROM website_sessions

UNION ALL

SELECT
    'Website Pageviews',
    MIN(created_at),
    MAX(created_at)
FROM website_pageviews

UNION ALL

SELECT
    'Refunds',
    MIN(created_at),
    MAX(created_at)
FROM order_item_refunds;

-- ==========================================================
-- 2. OVERALL SALES PERFORMANCE
-- ==========================================================

-- Calculate total orders, revenue and average order value

SELECT
    COUNT(*) AS total_orders,
    SUM(price_usd) AS total_revenue,
    AVG(price_usd) AS average_order_value
FROM orders;

-- ==========================================================
-- 3. OVERALL PROFITABILITY
-- ==========================================================

-- Calculate total revenue, cost of goods sold, profit and profit margin

SELECT
    SUM(price_usd) AS total_revenue,
    SUM(cogs_usd) AS total_cogs,
    SUM(price_usd - cogs_usd) AS total_profit,
    ROUND(
        SUM(price_usd - cogs_usd) / SUM(price_usd) * 100, 2
    ) AS profit_margin_percentage
FROM orders;

-- ==========================================================
-- 4. MONTHLY SALES PERFORMANCE
-- ==========================================================

-- Analyse monthly order volume, revenue, costs and profit
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    SUM(price_usd) AS monthly_revenue,
    SUM(cogs_usd) AS monthly_cogs,
    SUM(price_usd - cogs_usd) AS monthly_profit
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY order_month;

-- Identify the top 5 months by revenue
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    SUM(price_usd) AS monthly_revenue,
    SUM(price_usd - cogs_usd) AS monthly_profit
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY monthly_revenue DESC
LIMIT 5;

-- Identify the bottom 5 months by revenue
SELECT
    DATE_FORMAT(created_at, '%Y-%m') AS order_month,
    COUNT(*) AS total_orders,
    SUM(price_usd) AS monthly_revenue,
    SUM(price_usd - cogs_usd) AS monthly_profit
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
ORDER BY monthly_revenue ASC
LIMIT 5;

-- ==========================================================
-- 5. MONTHLY ORDER TRENDS AND GROWTH
-- ==========================================================

-- Calculate the month-over-month change in order volume
WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
),
previous_orders AS (
SELECT
    order_month,
    total_orders,
    LAG(total_orders) OVER (ORDER BY order_month) AS previous_month_orders
FROM monthly_orders
)
SELECT 
	order_month,
    total_orders,
    previous_month_orders,
	total_orders - previous_month_orders AS order_change
FROM previous_orders
ORDER BY order_month;

-- Calculate the month-over-month order growth percentage
WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
),
previous_orders AS (
    SELECT
        order_month,
        total_orders,
        LAG(total_orders) OVER (
            ORDER BY order_month
        ) AS previous_month_orders
    FROM monthly_orders
)
SELECT
    order_month,
    total_orders,
    previous_month_orders,
	total_orders - previous_month_orders AS order_change,
	ROUND(
        (total_orders - previous_month_orders)
        / previous_month_orders * 100, 2
    ) AS order_growth_percentage
FROM previous_orders
ORDER BY order_month;

-- Identify the top 5 months by order growth
WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS order_month,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY DATE_FORMAT(created_at, '%Y-%m')
),
previous_orders AS (
    SELECT
        order_month,
        total_orders,
        LAG(total_orders) OVER (
            ORDER BY order_month
        ) AS previous_month_orders
    FROM monthly_orders
),
monthly_growth AS(
SELECT
    order_month,
    total_orders,
    previous_month_orders,
    total_orders - previous_month_orders AS order_change,
    ROUND(
        (total_orders - previous_month_orders)
        / previous_month_orders * 100, 2
    ) AS order_growth_percentage
FROM previous_orders
)
SELECT 
	order_month,
    total_orders,
    previous_month_orders,
    order_change,
    order_growth_percentage
FROM monthly_growth
WHERE order_growth_percentage IS NOT NULL
ORDER BY order_growth_percentage DESC
LIMIT 5;

-- Identify the bottom 5 months by order growth
WITH monthly_orders AS (
    SELECT
        DATE_FORMAT(created_at, '%Y-%m') AS order_month,
        COUNT(*) AS total_orders
FROM orders
GROUP BY DATE_FORMAT(created_at, '%Y-%m')
),
previous_orders AS (
    SELECT
        order_month,
        total_orders,
        LAG(total_orders) OVER (
            ORDER BY order_month
        ) AS previous_month_orders
    FROM monthly_orders
),
monthly_growth AS(
SELECT
    order_month,
    total_orders,
    previous_month_orders,
    total_orders - previous_month_orders AS order_change,
    ROUND(
        (total_orders - previous_month_orders)
        / previous_month_orders * 100, 2
    ) AS order_growth_percentage
FROM previous_orders
)
SELECT 
	order_month,
    total_orders,
    previous_month_orders,
    order_change,
    order_growth_percentage
FROM monthly_growth
WHERE order_growth_percentage IS NOT NULL
ORDER BY order_growth_percentage ASC
LIMIT 5;

-- ==========================================================
-- 6. CUSTOMER PURCHASING BEHAVIOUR
-- ==========================================================

-- How many unique customers do we have, and how frequently do they place orders?
SELECT
    COUNT(DISTINCT user_id) AS unique_customers,
    COUNT(*) AS total_orders,
    ROUND(
        COUNT(*) / COUNT(DISTINCT user_id), 2
    ) AS average_orders_per_customer
FROM orders;

-- Classify customers based on their total number of orders
WITH customer_orders AS (
    SELECT
        user_id,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY user_id
)
SELECT
    CASE
        WHEN total_orders = 1 THEN 'One-time Customer'
        ELSE 'Repeat Customer'
    END AS customer_type,
    COUNT(*) AS customer_count
FROM customer_orders
GROUP BY customer_type;

-- Analyse the distribution of customers by number of orders
SELECT
    total_orders,
    COUNT(*) AS customer_count
FROM (
    SELECT
        user_id,
        COUNT(*) AS total_orders
    FROM orders
    GROUP BY user_id
) AS customer_orders
GROUP BY total_orders
ORDER BY total_orders;

-- ==========================================================
-- 7. WEBSITE SESSION AND CONVERSION ANALYSIS
-- ==========================================================

-- Compare session conversion rates between new and returning visitors
SELECT
    CASE
        WHEN ws.is_repeat_session = 0 THEN 'New Visitor'
        ELSE 'Returning Visitor'
    END AS session_type,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.website_session_id) AS converted_sessions,
    COUNT(DISTINCT ws.website_session_id)
        - COUNT(DISTINCT o.website_session_id) AS non_converted_sessions,
    ROUND(
        COUNT(DISTINCT o.website_session_id)
        / COUNT(DISTINCT ws.website_session_id) * 100, 2
    ) AS conversion_rate_percentage
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.is_repeat_session
ORDER BY ws.is_repeat_session;

-- Compare website conversion rates across device types
SELECT
    ws.device_type,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.website_session_id) AS converted_sessions,
    ROUND(
        COUNT(DISTINCT o.website_session_id)
        / COUNT(DISTINCT ws.website_session_id) * 100, 2
    ) AS conversion_rate_percentage
FROM website_sessions ws
LEFT JOIN orders o
    ON ws.website_session_id = o.website_session_id
GROUP BY ws.device_type
ORDER BY total_sessions DESC;

-- ==========================================================
-- 8. PRODUCT PERFORMANCE AND PROFITABILITY
-- ==========================================================

-- Sort products by total sales revenue in descending order
SELECT
    p.product_id,
    p.product_name,
    SUM(oi.price_usd) AS total_revenue
FROM products p
INNER JOIN order_items oi
    ON p.product_id = oi.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_revenue DESC;

-- Compare product revenue, costs, profit and profit margin
WITH product_performance AS (
    SELECT
        p.product_id,
        p.product_name,
        SUM(oi.price_usd) AS total_revenue,
        SUM(oi.cogs_usd) AS total_cogs,
        SUM(oi.price_usd - oi.cogs_usd) AS total_profit
    FROM products p
    INNER JOIN order_items oi
        ON p.product_id = oi.product_id
    GROUP BY
        p.product_id,
        p.product_name
)
SELECT
    product_id,
    product_name,
    total_revenue,
    total_cogs,
    total_profit,
    ROUND(
        total_profit / total_revenue * 100, 2
    ) AS profit_margin_percentage
FROM product_performance
ORDER BY total_profit DESC;

-- ==========================================================
-- 9. REFUND ANALYSIS AND NET PROFITABILITY
-- ==========================================================

-- Summarise total and average refund amounts
SELECT
    COUNT(*) AS total_refund_records,
    SUM(refund_amount_usd) AS total_refund_amount,
    ROUND(AVG(refund_amount_usd), 2) AS average_refund_amount
FROM order_item_refunds;

-- Identify products with the highest refund amounts
SELECT
    p.product_id,
    p.product_name,
    COUNT(r.order_item_refund_id) AS refund_records,
    SUM(r.refund_amount_usd) AS total_refund_amount
FROM order_item_refunds r
INNER JOIN order_items oi
    ON r.order_item_id = oi.order_item_id
INNER JOIN products p
    ON oi.product_id = p.product_id
GROUP BY
    p.product_id,
    p.product_name
ORDER BY total_refund_amount DESC;

-- Estimate product-level net revenue and profit after refunds
WITH product_sales AS (
    SELECT
        product_id,
        SUM(price_usd) AS total_revenue,
        SUM(cogs_usd) AS total_cogs
    FROM order_items
    GROUP BY product_id
),
product_refunds AS (
    SELECT
        oi.product_id,
        SUM(r.refund_amount_usd) AS total_refunds
    FROM order_items oi
    INNER JOIN order_item_refunds r
        ON oi.order_item_id = r.order_item_id
    GROUP BY oi.product_id
)
SELECT
    p.product_name,
    ps.total_revenue,
    ps.total_cogs,
    COALESCE(pr.total_refunds, 0) AS total_refunds,
    ps.total_revenue - COALESCE(pr.total_refunds, 0) AS net_revenue,
	ps.total_revenue - ps.total_cogs - COALESCE(pr.total_refunds, 0) AS estimated_net_profit
FROM products p
INNER JOIN product_sales ps
    ON p.product_id = ps.product_id
LEFT JOIN product_refunds pr
    ON p.product_id = pr.product_id
ORDER BY estimated_net_profit DESC;
