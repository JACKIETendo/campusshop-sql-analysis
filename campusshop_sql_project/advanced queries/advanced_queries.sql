-- CAMPUSSHOP SQL PROJECT
-- Phase 4: Advanced SQL Queries
-- File: advanced_queries.sql
-- Description: JOINs, Subqueries, CTEs, and Window Functions

-- SECTION A: JOINS (Connecting Multiple Tables)

-- A1. Full order details: customer name + order + product + price
--     (This combines 4 tables in one query)
SELECT
    u.name AS customer_name,
    o.order_number,
    o.order_date,
    oi.product_name,
    oi.quantity,
    oi.price AS unit_price,
    oi.quantity * oi.price AS line_total,
    o.status AS order_status,
    o.payment_method
FROM orders o
JOIN users u        ON o.user_id = u.id
JOIN order_items oi ON o.id = oi.order_id
ORDER BY o.order_date DESC;

-- A2. Products with their total units sold and stock remaining
SELECT
    p.name AS product_name,
    p.category,
    p.price,
    p.stock AS current_stock,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    p.stock + COALESCE(SUM(oi.quantity), 0) AS estimated_original_stock
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.id, p.name, p.category, p.price, p.stock
ORDER BY units_sold DESC;

-- A3. Customers with their favorite products and whether it was ordered
SELECT
    u.name AS customer_name,
    p.name AS favorited_product,
    p.category,
    p.price,
    CASE
        WHEN oi.product_id IS NOT NULL THEN 'Yes - Ordered'
        ELSE 'Not yet ordered'
    END AS did_they_buy_it
FROM favorites f
JOIN users u        ON f.user_id = u.id
JOIN products p     ON f.product_id = p.id
LEFT JOIN order_items oi ON p.id = oi.product_id
    AND oi.order_id IN (SELECT id FROM orders WHERE user_id = f.user_id)
ORDER BY u.name;

-- A4. Delivery records matched with order and customer details
SELECT
    pd.customer_name,
    pd.phone_number,
    pd.payment_method,
    pd.amount_paid,
    pd.delivery_location,
    pd.delivery_status,
    pd.product_name AS product_in_delivery,
    o.order_number,
    o.status AS order_status
FROM pending_deliveries pd
LEFT JOIN orders o ON pd.order_id = o.id
ORDER BY pd.created_at DESC;

-- SECTION B: SUBQUERIES (Query inside a Query)

-- B1. Products whose price is above the average product price
SELECT
    name,
    category,
    price,
    ROUND(price - (SELECT AVG(price) FROM products), 2) AS price_above_avg
FROM products
WHERE price > (SELECT AVG(price) FROM products)
ORDER BY price DESC;

-- B2. Customers who spent more than the average customer spending
SELECT
    u.name,
    u.email,
    SUM(o.total_amount) AS total_spent
FROM users u
JOIN orders o ON u.id = o.user_id
GROUP BY u.id, u.name, u.email
HAVING SUM(o.total_amount) > (
    SELECT AVG(customer_total)
    FROM (
        SELECT user_id, SUM(total_amount) AS customer_total
        FROM orders
        GROUP BY user_id
    ) AS avg_calc
);

-- B3. Most expensive product in each category
SELECT
    category,
    name AS most_expensive_product,
    price
FROM products p1
WHERE price = (
    SELECT MAX(price)
    FROM products p2
    WHERE p2.category = p1.category
)
ORDER BY price DESC;

-- B4. Products in the cart that are running low on stock (urgent!)
SELECT
    p.name AS product_name,
    p.category,
    p.stock AS current_stock,
    SUM(c.quantity) AS qty_in_customers_carts,
    p.stock - SUM(c.quantity) AS stock_after_cart_reserved
FROM cart c
JOIN products p ON c.product_id = p.id
GROUP BY p.id, p.name, p.category, p.stock
HAVING p.stock - SUM(c.quantity) < 5
ORDER BY stock_after_cart_reserved ASC;

-- SECTION C: CTEs - Common Table Expressions
-- (CTEs make long queries easier to read - like naming a step)

-- C1. Using a CTE to find the top customer per month
WITH monthly_spending AS (
    SELECT
        u.name AS customer_name,
        DATE_FORMAT(o.order_date, '%Y-%m') AS month,
        SUM(o.total_amount) AS total_spent,
        RANK() OVER (
            PARTITION BY DATE_FORMAT(o.order_date, '%Y-%m')
            ORDER BY SUM(o.total_amount) DESC
        ) AS spending_rank
    FROM orders o
    JOIN users u ON o.user_id = u.id
    WHERE o.status NOT IN ('Canceled', 'Refunded')
    GROUP BY u.name, DATE_FORMAT(o.order_date, '%Y-%m')
)
SELECT month, customer_name, total_spent
FROM monthly_spending
WHERE spending_rank = 1
ORDER BY month;

-- C2. CTE: Revenue contribution by product category
WITH category_revenue AS (
    SELECT
        p.category,
        SUM(oi.price * oi.quantity) AS revenue
    FROM order_items oi
    JOIN products p ON oi.product_id = p.id
    GROUP BY p.category
),
total AS (
    SELECT SUM(revenue) AS grand_total FROM category_revenue
)
SELECT
    cr.category,
    cr.revenue,
    ROUND(cr.revenue * 100.0 / t.grand_total, 2) AS percentage_of_total
FROM category_revenue cr, total t
ORDER BY cr.revenue DESC;

-- C3. CTE: Flag high-demand products (in cart AND low stock)
WITH cart_demand AS (
    SELECT product_id, SUM(quantity) AS cart_qty
    FROM cart
    GROUP BY product_id
),
stock_levels AS (
    SELECT id, name, category, stock, price
    FROM products
    WHERE is_active = 1
)
SELECT
    sl.name AS product_name,
    sl.category,
    sl.stock AS current_stock,
    cd.cart_qty AS demand_in_carts,
    CASE
        WHEN sl.stock <= cd.cart_qty THEN 'CRITICAL - Restock Now'
        WHEN sl.stock < 5            THEN 'LOW STOCK - Watch Closely'
        ELSE                              'OK'
    END AS stock_alert
FROM stock_levels sl
LEFT JOIN cart_demand cd ON sl.id = cd.product_id
WHERE cd.cart_qty IS NOT NULL
ORDER BY sl.stock ASC;

-- SECTION D: WINDOW FUNCTIONS (Ranking and Running Totals)

-- D1. Rank products by revenue within each category
SELECT
    p.category,
    p.name AS product_name,
    p.price,
    COALESCE(SUM(oi.quantity), 0) AS units_sold,
    COALESCE(SUM(oi.price * oi.quantity), 0) AS total_revenue,
    RANK() OVER (
        PARTITION BY p.category
        ORDER BY COALESCE(SUM(oi.price * oi.quantity), 0) DESC
    ) AS rank_in_category
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
GROUP BY p.category, p.name, p.price
ORDER BY p.category, rank_in_category;

-- D2. Running total of revenue over time (cumulative sales)
SELECT
    DATE_FORMAT(order_date, '%Y-%m-%d')  AS order_day,
    SUM(total_amount) AS daily_revenue,
    SUM(SUM(total_amount)) OVER (
        ORDER BY DATE_FORMAT(order_date, '%Y-%m-%d')
    ) AS running_total_revenue
FROM orders
WHERE status NOT IN ('Canceled', 'Refunded')
GROUP BY DATE_FORMAT(order_date, '%Y-%m-%d')
ORDER BY order_day;

-- D3. Each customer's order ranked from first to most recent
SELECT
    u.username AS customer_name,
    o.order_date,
    o.total_amount,
    o.status,
    ROW_NUMBER() OVER (
        PARTITION BY o.user_id
        ORDER BY o.order_date ASC
    ) AS order_number_sequence
FROM orders o
JOIN users u ON o.user_id = u.id
ORDER BY u.username, order_number_sequence;