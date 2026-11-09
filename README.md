# Toy Store E-commerce Analytics | MySQL

### Project Overview

This project focuses on analysing an e-commerce business using MySQL 8.0. The objective is to evaluate sales performance, profitability, customer purchasing behaviour, website conversion and product performance to generate meaningful business insights.

The project uses the Maven Fuzzy Factory e-commerce dataset and demonstrates an end-to-end SQL workflow, from database setup and data validation to cleaning, exploratory data analysis and business-oriented reporting.

### Business Objectives

The analysis aims to answer the following business questions:

How is the business performing in terms of revenue, orders and profitability?

How do sales and order volumes change over time?

What proportion of customers are repeat purchasers?

How effectively does the website convert sessions into orders?

Do conversion rates differ between new and returning visitors or across devices?

Which products generate the highest revenue and profit?

How do refunds affect product-level profitability?

### Dataset Overview

The project uses six datasets containing information about products, orders, customers' website sessions and website activity.

Table

Records

Description

### Products

4

Product catalogue and cost information

### Orders

32,313

Order-level sales and customer information

### Order Items

40,025

Individual products purchased within orders

### Order Item Refunds

1,731

Refund transactions associated with order items

### Website Sessions

472,871

Website visitor session information

### Website Pageviews

1,188,124

Individual website pageview activity

## Database: toy_store_analytics

The original CSV files are not included in this repository. The SQL scripts document the database setup, import process and subsequent analysis.

## Tools & Technologies

Database: MySQL Community Server 8.0

SQL Environment: MySQL Workbench

Language: SQL

## Project Workflow

### 1. Database Setup

Created the project database.

Selected the database for subsequent operations.

### 2. Data Import & Staging

Created staging tables for all six datasets.

Used MySQL Workbench Table Data Import Wizard for smaller datasets.

Used LOAD DATA LOCAL INFILE for larger website session and pageview datasets.

### 3. Data Validation & Cleaning

Checked for missing values and duplicate records.

Validated numeric and Boolean fields.

Checked date formats and data consistency.

Created cleaned tables with appropriate data types.

Established primary key and foreign key relationships to maintain referential integrity.

### 4. Exploratory Data Analysis (EDA)

The analysis covers the following areas:

Sales Performance

Total revenue and order volume.

Average order value.

Monthly sales trends.

Month-over-month order growth.

Profitability Analysis

Revenue, cost of goods sold (COGS) and profit.

Profit margin analysis.

Monthly profitability trends.

Customer Behaviour

Unique customer count.

Average orders per customer.

One-time versus repeat customers.

Distribution of orders by customer.

Website Performance

Session-to-order conversion analysis.

Conversion rates for new and returning visitors.

Conversion performance across device types.

Product Performance

Product-level revenue and profitability.

Comparison of product margins.

Product contribution to overall sales.

Refund Analysis

Overall refund activity.

Product-level refund analysis.

Estimated net revenue and profitability after refunds.

SQL Concepts Demonstrated

The project applies practical SQL concepts, including:

SELECT, WHERE, ORDER BY and GROUP BY

Aggregate functions: COUNT, SUM, AVG

Joins: INNER JOIN and LEFT JOIN

CASE WHEN and conditional aggregation

Common Table Expressions (CTEs)

Subqueries

Window functions: LAG()

Date and time functions

Data type conversion and date parsing

Data validation and cleaning

Primary and foreign key constraints

## Repository Structure

```text
Toy-Store-Ecommerce-Analytics/
│
├── SQL/
│   ├── README.md
│   ├── 01_Database_Setup.sql
│   ├── 02A_Data_Import_Wizard.sql
│   ├── 02B_Data_Import_Load_Data_Local_Infile.sql
│   ├── 03_Data_Validation_Cleaning.sql
│   └── 04_Exploratory_Data_Analysis.sql
│
└── README.md
```

## How to Run the Project

1. Install MySQL Community Server and MySQL Workbench.

2. Obtain the original CSV datasets and organise them in a local Data folder.

3. Execute 01_Database_Setup.sql to create the database.

4. Execute the staging table creation statements in 02A_Data_Import_Wizard.sql.

5. Follow the import instructions in the script to load the smaller datasets using MySQL Workbench.

6. Update the local file paths in 02B_Data_Import_Load_Data_Local_Infile.sql and use it to load the larger website datasets.

7. Execute 03_Data_Validation_Cleaning.sql to validate, clean and establish relationships between the tables.

8. Execute 04_Exploratory_Data_Analysis.sql to perform the business analysis.

Note: The import scripts are provided for reproducibility. If the data has already been imported, there is no need to repeat the import process.

### Important Note on Profitability

The product-level net profit after refunds is an estimate based on available product cost, sales and refund information. It does not account for other operating expenses such as marketing, shipping, payment processing fees, salaries, overheads or taxes.

## Project Outcome

This project demonstrates the application of SQL to transform raw e-commerce data into structured, analysis-ready tables and investigate key business performance areas.

It showcases practical database management, data cleaning, relational modelling and exploratory data analysis skills relevant to Data Analyst and Business Intelligence roles.
