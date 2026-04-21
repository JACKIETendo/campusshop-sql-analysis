-- CAMPUSSHOP SQL PROJECT
-- Phase 2: Data Cleaning & Quality Checks
-- File: data_cleaning.sql
-- Description: Find and document data quality issues

-- STEP 1: Check for NULL values in important columns

-- Orders with missing order_number
SELECT id, order_number, user_id, order_date, total_amount, status
FROM orders
WHERE order_number IS NULL;

-- Orders with missing or empty status
SELECT id, order_number, user_id, total_amount, status
FROM orders
WHERE status IS NULL OR status = '';

-- Products with missing category
SELECT id, name, price, category, stock
FROM products
WHERE category IS NULL;

-- Pending deliveries with missing payment amount (Pay on Delivery)
SELECT id, username, payment_method, status
FROM pending_deliveries
WHERE amount IS NULL;


-- STEP 2: Check for duplicate records

-- Are there duplicate order numbers?
SELECT order_number, COUNT(*) AS occurrences
FROM orders
WHERE order_number IS NOT NULL
GROUP BY order_number
HAVING COUNT(*) > 1;

-- Are there products with the same SKU?
SELECT sku, COUNT(*) AS occurrences
FROM products
WHERE sku IS NOT NULL
GROUP BY sku
HAVING COUNT(*) > 1;

-- Are there users who favorited the same product more than once?
SELECT user_id, product_id, COUNT(*) AS times_favorited
FROM favorites
GROUP BY user_id, product_id
HAVING COUNT(*) > 1;

-- STEP 3: Check for zero or negative prices

-- Products with zero or negative price (data error)
SELECT id, name, price, category, stock
FROM products
WHERE price <= 0;

-- Order items with zero price
SELECT oi.id, oi.order_id, oi.product_name, oi.quantity, oi.price
FROM order_items oi
WHERE oi.price <= 0;

-- STEP 4: Check stock issues

-- Products with zero stock (out of stock)
SELECT id, name, category, stock, is_active
FROM products
WHERE stock = 0;

-- Products with very low stock (less than 5 units)
SELECT id, name, category, stock, is_active
FROM products
WHERE stock < 5
ORDER BY stock ASC;

-- Active products with no stock (problem: active but unavailable)
SELECT id, name, category, stock
FROM products
WHERE stock = 0 AND is_active = 1;

-- STEP 5: Check date consistency in orders

-- Orders where created_at is after updated_at (should not happen)
SELECT id, order_number, created_at, updated_at
FROM orders
WHERE created_at > updated_at;

-- Orders with future dates (beyond today's reasonable range)
SELECT id, order_number, order_date, created_at
FROM orders
ORDER BY order_date DESC
LIMIT 10;

-- STEP 6: Data summary - Overall quality snapshot

SELECT
    (SELECT COUNT(*) FROM orders WHERE order_number IS NULL) AS orders_missing_number,
    (SELECT COUNT(*) FROM orders WHERE status = '' OR status IS NULL) AS orders_missing_status,
    (SELECT COUNT(*) FROM products WHERE stock = 0) AS products_out_of_stock,
    (SELECT COUNT(*) FROM products WHERE price <= 0) AS products_zero_price,
    (SELECT COUNT(*) FROM pending_deliveries WHERE amount IS NULL) AS deliveries_no_payment;