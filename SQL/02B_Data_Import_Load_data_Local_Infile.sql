-- ==========================================================
-- PROJECT: TOY STORE E-COMMERCE ANALYTICS
-- SCRIPT: 02B - DATA IMPORT USING LOAD DATA LOCAL INFILE
-- PURPOSE: Import large CSV files into staging tables
-- ==========================================================

USE toy_store_analytics;

-- Check whether LOCAL INFILE is enabled
SHOW GLOBAL VARIABLES LIKE 'local_infile';

-- ==========================================================
-- 1. IMPORT WEBSITE SESSIONS
-- ==========================================================

LOAD DATA LOCAL INFILE
-- Update the file paths below to match your local Data folder
'C:/YOUR/PATH/TO/Data/website_sessions.csv'
INTO TABLE website_sessions_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(
	website_session_id,
	created_at,
    user_id,
    is_repeat_session,
    utm_source,
    utm_campaign,
    utm_content,
    device_type,
    http_referer
);

-- Verify imported record count
SELECT COUNT(*) AS total_records
FROM website_sessions_staging;

-- ==========================================================
-- 2. IMPORT WEBSITE PAGEVIEWS
-- ==========================================================

LOAD DATA LOCAL INFILE
-- Update the file paths below to match your local Data folder
'C:/YOUR/PATH/TO/Data/website_pageviews.csv'
INTO TABLE website_pageviews_staging
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
ESCAPED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
	website_pageview_id,
    created_at,
    website_session_id,
    pageview_url
);

-- Verify imported record count
SELECT COUNT(*) AS total_records
FROM website_pageviews_staging;
