-- ==========================================================
-- PROJECT: TOY STORE E-COMMERCE ANALYTICS
-- SCRIPT: 02A - DATA IMPORT USING MYSQL WORKBENCH
-- PURPOSE: Create staging tables and document CSV imports
-- ==========================================================

USE toy_store_analytics;

-- ==========================================================
-- 1. CREATE PRODUCTS STAGING TABLE
-- ==========================================================

CREATE TABLE products_staging (
	product_id VARCHAR(50),
    created_at VARCHAR(50),
    product_name VARCHAR(250)
);

-- Verify table structure
DESCRIBE products_staging;

-- Import products.CSV using Table Data Import Wizard

-- Verify imported record count
SELECT COUNT(*) AS total_records
FROM products_staging;

-- ==========================================================
-- 2. CREATE ORDERS STAGING TABLE
-- ==========================================================

CREATE TABLE orders_staging (
	order_id VARCHAR(50),
    created_at VARCHAR(50),
    website_session_id VARCHAR(50),
    user_id VARCHAR(50),
    primary_product_id VARCHAR(50),
    items_purchased VARCHAR(50),
    price_usd VARCHAR(50),
    cogs_usd VARCHAR(50)
);

-- Verify table structure
DESCRIBE orders_staging;

-- Import orders.CSV using Table Data Import Wizard

-- Verify imported record count
SELECT COUNT(*) AS total_records
FROM orders_staging;

-- ==========================================================
-- 3. CREATE ORDER_ITEMS STAGING TABLE
-- ==========================================================

CREATE TABLE order_items_staging (
	order_item_id VARCHAR(50),
    created_at VARCHAR(50),
    order_id VARCHAR(50),
    product_id VARCHAR(50),
    is_primary_item VARCHAR(50),
    price_usd VARCHAR(50),
    cogs_usd VARCHAR(50)
);

-- Verify table structure
DESCRIBE order_items_staging;

-- Import order_items.CSV using Table Data Import Wizard

-- Verify imported record count
SELECT COUNT(*) AS total_records
FROM order_items_staging;

-- ==========================================================
-- 4. CREATE ORDER_ITEM_REFUNDS STAGING TABLE
-- ==========================================================

CREATE TABLE order_item_refunds_staging (
	order_item_refund_id VARCHAR(50),
    created_at VARCHAR(50),
    order_item_id VARCHAR(50),
    order_id VARCHAR(50),
    refund_amount_usd VARCHAR(50)
);

-- Verify table structure
DESCRIBE order_item_refunds_staging;

-- Import order_item_refunds.CSV using Table Data Import Wizard

-- Verify imported record count
SELECT COUNT(*) AS total_records
FROM order_item_refunds_staging;

-- ==========================================================
-- 5. CREATE WEBSITE_SESSIONS STAGING TABLE
-- ==========================================================

CREATE TABLE website_sessions_staging (
	website_session_id VARCHAR(50),
    created_at VARCHAR(50),
    user_id VARCHAR(50),
    is_repeat_session VARCHAR(50),
    utm_source VARCHAR(50),
    utm_campaign VARCHAR(50),
    utm_content VARCHAR(50),
    device_type VARCHAR(50),
    http_referer VARCHAR(50)
);

-- Verify table structure
DESCRIBE website_sessions_staging;

-- Import website_sessions.csv using LOAD DATA LOCAL INFILE
-- Refer to script 02B_Data_Import_Load_Data_Local_Infile.sql

-- Verify imported record count
SELECT COUNT(*) AS total_records
FROM website_sessions_staging;

-- ==========================================================
-- 6. CREATE WEBSITE_PAGEVIEWS STAGING TABLE
-- ==========================================================

CREATE TABLE website_pageviews_staging (
	website_pageview_id VARCHAR(50),
    created_at VARCHAR(50),
    website_session_id VARCHAR(50),
    pageview_url VARCHAR(1000)
);

-- Verify table structure
DESCRIBE website_pageviews_staging;

-- Import website_pageviews.csv using LOAD DATA LOCAL INFILE
-- Refer to script 02B_Data_Import_Load_Data_Local_Infile.sql

-- Verify imported record count
SELECT COUNT(*) AS total_records
FROM website_pageviews_staging;
