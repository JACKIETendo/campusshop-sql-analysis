-- CAMPUSSHOP SQL PROJECT
-- Phase 1: Database Exploration
-- File: explore_database.sql
-- Description: Get familiar with all tables and their structure

-- STEP 1: See all available tables
SHOW TABLES;

-- STEP 2: Understand each table's structure
-- What columns does each table have?
DESCRIBE users;
DESCRIBE products;
DESCRIBE orders;
DESCRIBE order_items;
DESCRIBE pending_deliveries;
DESCRIBE product_movements;
DESCRIBE favorites;
DESCRIBE cart;
DESCRIBE feedback;
DESCRIBE notifications;
DESCRIBE innovation_hub_products;
DESCRIBE innovation_cart;
DESCRIBE innovation_favorites;

-- -----------------------------------------------
-- STEP 3: Preview data in key tables
-- (Always use LIMIT to avoid loading too much at once)
-- -----------------------------------------------

-- See sample users
SELECT * 
FROM users LIMIT 10;

-- See sample products
SELECT * 
FROM products LIMIT 10;

-- See sample orders
SELECT * 
FROM orders LIMIT 10;

-- See order items (what was inside each order)
SELECT * 
FROM order_items LIMIT 10;

-- See delivery records
SELECT * 
FROM pending_deliveries LIMIT 10;

-- See product movement history
SELECT * 
FROM product_movements LIMIT 10;

-- See student innovation products
SELECT * 
FROM innovation_hub_products LIMIT 10;

-- STEP 4: Count records in each table
-- (This tells you how much data you are working with)

SELECT 'users' AS table_name, COUNT(*) AS total_records 
FROM users
UNION ALL
SELECT 'products', COUNT(*) 
FROM products
UNION ALL
SELECT 'orders', COUNT(*) 
FROM orders
UNION ALL
SELECT 'order_items', COUNT(*) 
FROM order_items
UNION ALL
SELECT 'pending_deliveries', COUNT(*) 
FROM pending_deliveries
UNION ALL
SELECT 'product_movements', COUNT(*) 
FROM product_movements
UNION ALL
SELECT 'favorites', COUNT(*) 
FROM favorites
UNION ALL
SELECT 'cart', COUNT(*) 
FROM cart
UNION ALL
SELECT 'feedback', COUNT(*) 
FROM feedback
UNION ALL
SELECT 'innovation_hub_products',COUNT(*) 
FROM innovation_hub_products
UNION ALL
SELECT 'innovation_cart', COUNT(*) 
FROM innovation_cart
UNION ALL
SELECT 'innovation_favorites', COUNT(*) 
FROM innovation_favorites;