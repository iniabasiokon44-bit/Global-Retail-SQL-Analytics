-- Global Retail Analytics Database Setup (MySQL)
CREATE DATABASE retail_analytics;
USE retail_analytics;
-- Date Dimension
CREATE TABLE dim_date (
    date DATE PRIMARY KEY,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    year INT,
    fiscal_period VARCHAR(20)
);
-- Product Dimension
CREATE TABLE dim_product (
    product_id VARCHAR(10) PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    sub_category VARCHAR(50),
    unit_cost DECIMAL(10,2)
);
-- Store Dimension
CREATE TABLE dim_store (
    store_id VARCHAR(10) PRIMARY KEY,
    store_name VARCHAR(100),
    region VARCHAR(50),
    city VARCHAR(50),
    country VARCHAR(50),
    store_size VARCHAR(20),
    open_date DATE
);
-- Promotions
CREATE TABLE promotions (
    promotion_id VARCHAR(20) PRIMARY KEY,
    product_id VARCHAR(10),
    discount_pct DECIMAL(5,2),
    start_date DATE,
    end_date DATE,
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);
-- Store Expenses
CREATE TABLE store_expenses (
    store_id VARCHAR(10),
    month DATE,
    rent DECIMAL(12,2),
    utilities DECIMAL(12,2),
    labor DECIMAL(12,2),
    other_costs DECIMAL(12,2),
    PRIMARY KEY (store_id, month),
    FOREIGN KEY (store_id) REFERENCES dim_store(store_id)
);
-- Sales Transactions 
CREATE TABLE sales_transactions (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    date_id DATE,
    store_id VARCHAR(10),
    product_id VARCHAR(10),
    quantity INT,
    sales_amount DECIMAL(12,2),
    FOREIGN KEY (date_id) REFERENCES dim_date(date),
    FOREIGN KEY (store_id) REFERENCES dim_store(store_id),
    FOREIGN KEY (product_id) REFERENCES dim_product(product_id)
);


