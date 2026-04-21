-- CAMPUSSHOP SQL PROJECT
-- Phase 3: Core Data Analysis
-- File: core_analysis.sql
-- Description: Answer key business questions using SQL

-- SECTION A: SALES ANALYSIS

-- A1. Total revenue from all completed orders
SELECT
    SUM(total_amount) AS total_revenue,
    COUNT(*) AS total_orders,
    ROUND(AVG(total_amount), 2) AS average_order_value,
    MIN(total_amount) AS smallest_order,
    MAX(total_amount) AS largest_order
FROM orders
WHERE status NOT IN ('Canceled', 'Refunded');

-- A2. Revenue breakdown by order status
SELECT
    status,
    COUNT(*) AS number_of_orders,
    SUM(total_amount) AS total_value,
    ROUND(AVG(total_amount), 2) AS avg_value
FROM orders
GROUP BY status
ORDER BY total_value DESC;

-- A3. Monthly revenue trend
SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS month,
    COUNT(*) AS orders_placed,
    SUM(total_amount) AS monthly_revenue
FROM orders
WHERE status NOT IN ('Canceled', 'Refunded')
GROUP BY DATE_FORMAT(order_date, '%Y-%m')
ORDER BY month ASC;

-- A4. Revenue by payment method
SELECT
    payment_method,
    COUNT(*) AS number_of_orders,
    SUM(total_amount) AS total_revenue,
    ROUND(AVG(total_amount), 2) AS avg_order_value
FROM orders
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- SECTION B: PRODUCT ANALYSIS

-- B1. How many products exist per category?
SELECT
    category,
    COUNT(*) AS number_of_products,
    ROUND(AVG(price), 2) AS avg_price,
    MIN(price) AS cheapest_price,
    MAX(price) AS most_expensive_price,
    SUM(stock) AS total_stock_units
FROM products
WHERE is_active = 1
GROUP BY category
ORDER BY number_of_products DESC;

-- B2. Best-selling products (by quantity sold from order_items)
SELECT
    oi.product_name,
    p.category,
    p.price,
    SUM(oi.quantity) AS total_units_sold,
    SUM(oi.price * oi.quantity) AS total_revenue_generated
FROM order_items oi
JOIN products p ON oi.product_id = p.id
GROUP BY oi.product_name, p.category, p.price
ORDER BY total_units_sold DESC
LIMIT 10;

-- B3. Most favorited products (customers wishlist insights)
SELECT
    p.name AS product_name,
    p.category,
    p.price,
    COUNT(f.id) AS times_favorited
FROM favorites f
JOIN products p ON f.product_id = p.id
GROUP BY p.name, p.category, p.price
ORDER BY times_favorited DESC;

-- B4. Products currently in customers' carts (demand signals)
SELECT
    p.name AS product_name,
    p.category,
    p.price,
    SUM(c.quantity) AS total_cart_quantity,
    COUNT(DISTINCT c.user_id) AS customers_with_in_cart
FROM cart c
JOIN products p ON c.product_id = p.id
GROUP BY p.name, p.category, p.price
ORDER BY total_cart_quantity DESC;

-- B5. Product movement summary (what happened to stock)
SELECT
    p.name AS product_name,
    pm.movement_type,
    SUM(pm.quantity) AS total_quantity,
    COUNT(pm.id) AS number_of_movements
FROM product_movements pm
JOIN products p ON pm.product_id = p.id
GROUP BY p.name, pm.movement_type
ORDER BY p.name, pm.movement_type;

-- SECTION C: CUSTOMER ANALYSIS

-- C1. Top customers by number of orders
SELECT
    u.id AS user_id,
    u.name AS customer_name,
    u.email,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amount) AS total_spent
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.email
ORDER BY total_spent DESC;

-- C2. Customer order history (detailed per customer)
SELECT
    u.name AS customer_name,
    o.order_number,
    o.order_date,
    o.total_amount,
    o.status,
    o.payment_method
FROM users u
JOIN orders o ON u.id = o.user_id
ORDER BY u.name, o.order_date DESC;

-- C3. How many orders has each customer made?
SELECT
    total_orders,
    COUNT(*) AS number_of_customers
FROM (
    SELECT user_id, COUNT(*) AS total_orders
    FROM orders
    GROUP BY user_id
) AS order_counts
GROUP BY total_orders
ORDER BY total_orders DESC;

-- C4. Customers who have never placed an order (registered but inactive)
SELECT
    u.id,
    u.name,
    u.email,
    u.created_at AS registered_on
FROM users u
LEFT JOIN orders o ON u.id = o.user_id
WHERE o.id IS NULL;

-- SECTION D: DELIVERY ANALYSIS

-- D1. Delivery status breakdown
SELECT
    delivery_status,
    COUNT(*) AS number_of_deliveries,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM pending_deliveries), 2) AS percentage
FROM pending_deliveries
GROUP BY delivery_status
ORDER BY number_of_deliveries DESC;

-- D2. Most popular delivery locations / dorm blocks
SELECT
    delivery_location,
    COUNT(*) AS deliveries_count,
    SUM(amount) AS total_collected
FROM pending_deliveries
GROUP BY delivery_location
ORDER BY deliveries_count DESC;

-- D3. Revenue collected per payment method in deliveries
SELECT
    payment_method,
    COUNT(*) AS deliveries,
    SUM(amount) AS total_collected,
    ROUND(AVG(amount), 2) AS avg_per_delivery
FROM pending_deliveries
WHERE amount IS NOT NULL
GROUP BY payment_method
ORDER BY total_collected DESC;