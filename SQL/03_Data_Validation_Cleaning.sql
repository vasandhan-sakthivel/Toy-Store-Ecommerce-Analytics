-- ==========================================================
-- PROJECT: TOY STORE E-COMMERCE ANALYTICS
-- SCRIPT: 03 - DATA VALIDATION AND CLEANING
-- PURPOSE: Validate raw data and create clean analytical tables
-- ==========================================================

USE toy_store_analytics;

-- ==========================================================
-- 1. CHECK MISSING VALUES ACROSS ALL STAGING TABLES
-- ==========================================================

SELECT 
	'products_staging' AS table_name,
    SUM(CASE
		WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) AS missing_product_id,
	SUM(CASE
		WHEN created_at IS NULL OR TRIM(created_at) = '' THEN 1 ELSE 0 END) AS missing_dates
FROM products_staging

UNION ALL

SELECT 
	'orders_staging',
    SUM(CASE
		WHEN order_id IS NULL OR TRIM(order_id) = '' THEN 1 ELSE 0 END),
	SUM(CASE
		WHEN created_at IS NULL OR TRIM(created_at) = '' THEN 1 ELSE 0 END)
FROM orders_staging

UNION ALL

SELECT 
	'order_items_staging',
    SUM(CASE
		WHEN order_item_id IS NULL OR TRIM(order_item_id) = '' THEN 1 ELSE 0 END),
	SUM(CASE
		WHEN created_at IS NULL OR TRIM(created_at) = '' THEN 1 ELSE 0 END)
FROM order_items_staging

UNION ALL

SELECT 
	'order_item_refunds_staging',
    SUM(CASE
		WHEN order_item_refund_id IS NULL OR TRIM(order_item_refund_id) = '' THEN 1 ELSE 0 END),
	SUM(CASE
		WHEN created_at IS NULL OR TRIM(created_at) = '' THEN 1 ELSE 0 END)
FROM order_item_refunds_staging

UNION ALL

SELECT 
	'website_sessions_staging',
    SUM(CASE
		WHEN website_session_id IS NULL OR TRIM(website_session_id) = '' THEN 1 ELSE 0 END),
	SUM(CASE
		WHEN created_at IS NULL OR TRIM(created_at) = '' THEN 1 ELSE 0 END)
FROM website_sessions_staging

UNION ALL

SELECT 
	'website_pageviews_staging',
    SUM(CASE
		WHEN website_pageview_id IS NULL OR TRIM(website_pageview_id) = '' THEN 1 ELSE 0 END),
	SUM(CASE
		WHEN created_at IS NULL OR TRIM(created_at) = '' THEN 1 ELSE 0 END)
FROM website_pageviews_staging;

-- ==========================================================
-- 2. CHECK DUPLICATE PRIMARY IDs ACROSS STAGING TABLES
-- ==========================================================

SELECT 
	'products_staging' AS table_name,
    COUNT(*) - COUNT(DISTINCT product_id) AS duplicate_ids
FROM products_staging

UNION ALL

SELECT 'orders_staging',
	COUNT(*) - COUNT(DISTINCT order_id)
FROM orders_staging

UNION ALL

SELECT
	'order_items_staging',
    COUNT(*) - COUNT(DISTINCT order_item_id)
FROM order_items_staging

UNION ALL

SELECT 
	'order_item_refunds_staging',
    COUNT(*) - COUNT(DISTINCT order_item_refund_id)
FROM order_item_refunds_staging

UNION ALL

SELECT 
	'website_sessions_staging',
    COUNT(*) - COUNT(DISTINCT website_session_id)
FROM website_sessions_staging

UNION ALL

SELECT 
	'website_pageviews_staging',
    COUNT(*) - COUNT(DISTINCT website_pageview_id)
FROM website_pageviews_staging;

-- ==========================================================
-- 3. VALIDATE NUMERIC VALUES
-- ==========================================================

SELECT *
FROM orders_staging
WHERE
	price_usd IS NULL OR TRIM(price_usd) = ''
	OR TRIM(price_usd) NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
    OR cogs_usd IS NULL OR TRIM(cogs_usd) = ''
    OR TRIM(cogs_usd) NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
    OR items_purchased IS NULL OR TRIM(items_purchased) = ''
    OR TRIM(items_purchased) NOT REGEXP '^[0-9]+$';
    
SELECT *
FROM order_items_staging
WHERE
	price_usd IS NULL OR TRIM(price_usd) = ''
    OR TRIM(price_usd) NOT REGEXP '^[0-9]+(\\.[0-9]+)?$'
    OR cogs_usd IS NULL OR TRIM(cogs_usd) = ''
    OR TRIM(cogs_usd) NOT REGEXP '^[0-9]+(\\.[0-9]+)?$';

SELECT *
FROM order_item_refunds_staging
WHERE
	refund_amount_usd IS NULL OR TRIM(refund_amount_usd) = ''
    OR TRIM(refund_amount_usd) NOT REGEXP '^[0-9]+(\\.[0-9]+)?$';
    
SELECT *
FROM website_sessions_staging
WHERE is_repeat_session IS NULL
   OR TRIM(is_repeat_session) = ''
   OR TRIM(is_repeat_session) NOT IN ('0', '1');

SELECT COUNT(*) AS missing_pageview_urls
FROM website_pageviews_staging
WHERE pageview_url IS NULL
   OR TRIM(pageview_url) = '';
   
SELECT *
FROM order_items_staging
WHERE is_primary_item IS NULL
   OR TRIM(is_primary_item) = ''
   OR TRIM(is_primary_item) NOT IN ('0', '1');

-- ==========================================================
-- 4. VALIDATE REFERENTIAL INTEGRITY
-- ==========================================================

-- Validate Orders -> Website Sessions
SELECT COUNT(*) AS unmatched_sessions
FROM orders_staging o
LEFT JOIN website_sessions_staging s
    ON o.website_session_id = s.website_session_id
WHERE s.website_session_id IS NULL;

-- Validate Orders -> Products
SELECT COUNT(*) AS unmatched_products
FROM orders_staging o
LEFT JOIN products_staging p
    ON o.primary_product_id = p.product_id
WHERE p.product_id IS NULL;

-- Validate Order Items -> Orders
SELECT COUNT(*) AS unmatched_orders
FROM order_items_staging oi
LEFT JOIN orders_staging o
    ON oi.order_id = o.order_id
WHERE o.order_id IS NULL;

-- Validate Order Items -> Products
SELECT COUNT(*) AS unmatched_products
FROM order_items_staging oi
LEFT JOIN products_staging p
    ON oi.product_id = p.product_id
WHERE p.product_id IS NULL;

-- Validate Refunds -> Order Items
SELECT COUNT(*) AS unmatched_order_items
FROM order_item_refunds_staging r
LEFT JOIN order_items_staging oi
    ON r.order_item_id = oi.order_item_id
WHERE oi.order_item_id IS NULL;

-- Validate Website Pageviews -> Website Sessions
SELECT COUNT(*) AS unmatched_sessions
FROM website_pageviews_staging pv
LEFT JOIN website_sessions_staging s
    ON pv.website_session_id = s.website_session_id
WHERE s.website_session_id IS NULL;

-- Validate Refunds -> Order Items
SELECT COUNT(*) AS unmatched_orders
FROM order_item_refunds_staging r
LEFT JOIN orders_staging o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;

-- ==========================================================
-- 5. CREATE CLEANED PRODUCTS TABLE
-- ==========================================================

-- Create cleaned products table with appropriate data types
CREATE TABLE products AS
SELECT
    CAST(product_id AS UNSIGNED) AS product_id,
    STR_TO_DATE(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    product_name
FROM products_staging;

-- Verify the cleaned data
SELECT *
FROM products;

-- Verify column names and data types
DESCRIBE products;

-- Create cleaned orders table with appropriate data types
CREATE TABLE orders AS
SELECT
    CAST(order_id AS UNSIGNED) AS order_id,
    STR_TO_DATE(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    CAST(website_session_id AS UNSIGNED) AS website_session_id,
    CAST(user_id AS UNSIGNED) AS user_id,
    CAST(primary_product_id AS UNSIGNED) AS primary_product_id,
    CAST(items_purchased AS UNSIGNED) AS items_purchased,
    CAST(price_usd AS DECIMAL(10,2)) AS price_usd,
    CAST(cogs_usd AS DECIMAL(10,2)) AS cogs_usd
FROM orders_staging;

-- Verify column names and data types
DESCRIBE orders;

-- Create cleaned order_items table with appropriate data types
CREATE TABLE order_items AS
SELECT
    CAST(order_item_id AS UNSIGNED) AS order_item_id,
    STR_TO_DATE(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    CAST(order_id AS UNSIGNED) AS order_id,
    CAST(product_id AS UNSIGNED) AS product_id,
    CAST(is_primary_item AS UNSIGNED) AS is_primary_item,
    CAST(price_usd AS DECIMAL(10,2)) AS price_usd,
    CAST(cogs_usd AS DECIMAL(10,2)) AS cogs_usd
FROM order_items_staging;

-- Verify column names and data types
DESCRIBE order_items;

-- Create cleaned order_item_refunds table with appropriate data types
CREATE TABLE order_item_refunds AS
SELECT
    CAST(order_item_refund_id AS UNSIGNED) AS order_item_refund_id,
    STR_TO_DATE(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    CAST(order_item_id AS UNSIGNED) AS order_item_id,
    CAST(order_id AS UNSIGNED) AS order_id,
    CAST(refund_amount_usd AS DECIMAL(10,2)) AS refund_amount_usd
FROM order_item_refunds_staging;

-- Verify column names and data types
DESCRIBE order_item_refunds;

-- Create cleaned website_sessions table with appropriate data types
CREATE TABLE website_sessions AS
SELECT
    CAST(website_session_id AS UNSIGNED) AS website_session_id,
    STR_TO_DATE(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    CAST(user_id AS UNSIGNED) AS user_id,
    CAST(is_repeat_session AS UNSIGNED) AS is_repeat_session,
    utm_source,
    utm_campaign,
    utm_content,
    device_type,
    http_referer
FROM website_sessions_staging;

-- Verify column names and data types
DESCRIBE website_sessions;

-- Create cleaned website_pageviews table with appropriate data types
CREATE TABLE website_pageviews AS
SELECT
    CAST(website_pageview_id AS UNSIGNED) AS website_pageview_id,
    STR_TO_DATE(created_at, '%Y-%m-%d %H:%i:%s') AS created_at,
    CAST(website_session_id AS UNSIGNED) AS website_session_id,
    pageview_url
FROM website_pageviews_staging;

-- Verify column names and data types
DESCRIBE website_pageviews;

-- ==========================================================
-- 6. MODIFY DATA TYPES AND DEFINE PRIMARY KEYS
-- ==========================================================

-- Set product_id as INT UNSIGNED and define primary key
ALTER TABLE products
MODIFY COLUMN product_id INT UNSIGNED NOT NULL,
ADD PRIMARY KEY (product_id);

DESCRIBE products;

-- Set order_id as INT UNSIGNED and define primary key
ALTER TABLE orders
MODIFY COLUMN order_id INT UNSIGNED NOT NULL,
ADD PRIMARY KEY (order_id);

DESCRIBE orders;

-- Set order_item_id as INT UNSIGNED and define primary key
ALTER TABLE order_items
MODIFY COLUMN order_item_id INT UNSIGNED NOT NULL,
ADD PRIMARY KEY (order_item_id);

DESCRIBE order_items;

-- Ensure order_id and product_id use compatible data types
ALTER TABLE order_items
MODIFY COLUMN order_id INT UNSIGNED NOT NULL,
MODIFY COLUMN product_id INT UNSIGNED NOT NULL;

DESCRIBE order_items;

-- Set refund ID as primary key and standardise reference ID data types
ALTER TABLE order_item_refunds
MODIFY COLUMN order_item_refund_id INT UNSIGNED NOT NULL,
MODIFY COLUMN order_item_id INT UNSIGNED NOT NULL,
MODIFY COLUMN order_id INT UNSIGNED NOT NULL,
ADD PRIMARY KEY (order_item_refund_id);

DESCRIBE order_item_refunds;

-- Set session ID as primary key and modify related column data types
ALTER TABLE website_sessions
MODIFY COLUMN website_session_id INT UNSIGNED NOT NULL,
MODIFY COLUMN user_id INT UNSIGNED NOT NULL,
MODIFY COLUMN is_repeat_session BOOLEAN NOT NULL,
ADD PRIMARY KEY (website_session_id);

DESCRIBE website_sessions;

-- Set pageview ID as primary key and standardise session ID data type
ALTER TABLE website_pageviews
MODIFY COLUMN website_pageview_id INT UNSIGNED NOT NULL,
MODIFY COLUMN website_session_id INT UNSIGNED NOT NULL,
ADD PRIMARY KEY (website_pageview_id);

DESCRIBE website_pageviews;


-- Standardise orders reference IDs and items_purchased data type
ALTER TABLE orders
MODIFY COLUMN website_session_id INT UNSIGNED NOT NULL,
MODIFY COLUMN user_id INT UNSIGNED NOT NULL,
MODIFY COLUMN primary_product_id INT UNSIGNED NOT NULL,
MODIFY COLUMN items_purchased INT UNSIGNED NOT NULL;

-- Set is_primary_item as BOOLEAN
ALTER TABLE order_items
MODIFY COLUMN is_primary_item BOOLEAN NOT NULL;

-- ==========================================================
-- 7. VERIFY PRIMARY KEY CONFIGURATION
-- ==========================================================

SELECT
	TABLE_NAME,
    COLUMN_NAME,
    COLUMN_TYPE,
    IS_NULLABLE,
    COLUMN_KEY
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'toy_store_analytics'
	AND COLUMN_KEY = 'PRI'
ORDER BY TABLE_NAME;

-- ==========================================================
-- 8. CREATE FOREIGN KEY CONSTRAINTS
-- ==========================================================

-- Link orders to their primary products
ALTER TABLE orders
ADD CONSTRAINT fk_orders_products
FOREIGN KEY (primary_product_id)
REFERENCES products(product_id);

-- Link orders to their corresponding website sessions
ALTER TABLE orders
ADD CONSTRAINT fk_orders_sessions
FOREIGN KEY (website_session_id)
REFERENCES website_sessions(website_session_id);

-- Link order items to their respective orders and products
ALTER TABLE order_items
ADD CONSTRAINT fk_order_items_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id),
ADD CONSTRAINT fk_order_items_products
    FOREIGN KEY (product_id)
    REFERENCES products(product_id);
    
DESCRIBE order_items;

-- Link refunds to their corresponding order items and orders
ALTER TABLE order_item_refunds
ADD CONSTRAINT fk_refunds_order_items
    FOREIGN KEY (order_item_id)
    REFERENCES order_items(order_item_id),
ADD CONSTRAINT fk_refunds_orders
    FOREIGN KEY (order_id)
    REFERENCES orders(order_id);
    
DESCRIBE order_item_refunds;

-- Link website pageviews to their corresponding website sessions
ALTER TABLE website_pageviews
ADD CONSTRAINT fk_pageviews_sessions
FOREIGN KEY (website_session_id)
REFERENCES website_sessions(website_session_id);

DESCRIBE website_pageviews;

-- ==========================================================
-- 9. VERIFY FOREIGN KEY RELATIONSHIPS
-- ==========================================================

SELECT
    TABLE_NAME,
    COLUMN_NAME,
    CONSTRAINT_NAME,
    REFERENCED_TABLE_NAME,
    REFERENCED_COLUMN_NAME
FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE TABLE_SCHEMA = 'toy_store_analytics'
    AND REFERENCED_TABLE_NAME IS NOT NULL
ORDER BY TABLE_NAME;
