-- CAMPUSSHOP SQL PROJECT
-- Phase 5: Business Insights & Final Reports
-- File: business_insights.sql
-- Description: Answer real business questions for the shop manager

-- INSIGHT 1: EXECUTIVE DASHBOARD SUMMARY
-- A one-look snapshot of how the business is doing

SELECT
    (SELECT COUNT(*) FROM users)                                          AS total_registered_users,
    (SELECT COUNT(*) FROM products WHERE is_active = 1)                   AS active_products,
    (SELECT COUNT(*) FROM orders)                                         AS total_orders_placed,
    (SELECT COUNT(*) FROM orders WHERE status = 'Delivered')              AS orders_delivered,
    (SELECT COUNT(*) FROM orders WHERE status IN ('Canceled', 'Refunded')) AS orders_lost,
    (SELECT SUM(total_amount) FROM orders
     WHERE status NOT IN ('Canceled', 'Refunded'))                        AS total_revenue_ugx,
    (SELECT COUNT(*) FROM pending_deliveries
     WHERE delivery_status = 'Completed')                                 AS deliveries_completed,
    (SELECT COUNT(*) FROM pending_deliveries
     WHERE delivery_status = 'Pending')                                   AS deliveries_still_pending;

-- INSIGHT 2: WHICH PRODUCT CATEGORIES MAKE THE MOST MONEY?
-- Helps the manager know where to invest more stock

SELECT
    p.category,
    COUNT(DISTINCT p.id)                 AS products_in_category,
    SUM(oi.quantity)                     AS units_sold,
    SUM(oi.price * oi.quantity)          AS total_revenue,
    ROUND(AVG(p.price), 2)              AS avg_product_price,
    SUM(p.stock)                         AS remaining_stock
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
WHERE p.is_active = 1
GROUP BY p.category
ORDER BY total_revenue DESC;

-- INSIGHT 3: WHICH PRODUCTS SHOULD BE RESTOCKED URGENTLY?
-- Combines current stock + cart demand + historical sales

SELECT
    p.name                               AS product_name,
    p.category,
    p.price,
    p.stock                              AS current_stock,
    COALESCE(SUM(c.quantity), 0)         AS units_in_carts_now,
    COALESCE(sold.total_sold, 0)         AS units_already_sold,
    CASE
        WHEN p.stock = 0                              THEN '🔴 OUT OF STOCK'
        WHEN p.stock <= COALESCE(SUM(c.quantity), 0) THEN '🟠 CANNOT FULFILL CARTS'
        WHEN p.stock < 5                              THEN '🟡 LOW STOCK'
        ELSE                                               '🟢 OK'
    END                                  AS stock_status
FROM products p
LEFT JOIN cart c ON p.id = c.product_id
LEFT JOIN (
    SELECT product_id, SUM(quantity) AS total_sold
    FROM order_items
    GROUP BY product_id
) sold ON p.id = sold.product_id
WHERE p.is_active = 1
GROUP BY p.id, p.name, p.category, p.price, p.stock, sold.total_sold
ORDER BY p.stock ASC;

-- INSIGHT 4: CUSTOMER LOYALTY REPORT
-- Who are the best customers and how loyal are they?

SELECT
    u.name                               AS customer_name,
    u.email,
    COUNT(DISTINCT o.id)                 AS total_orders,
    SUM(o.total_amount)                  AS total_spent_ugx,
    ROUND(AVG(o.total_amount), 2)        AS avg_order_value,
    MIN(o.order_date)                    AS first_order_date,
    MAX(o.order_date)                    AS last_order_date,
    DATEDIFF(MAX(o.order_date), MIN(o.order_date)) AS days_as_customer,
    COUNT(DISTINCT f.id)                 AS products_on_wishlist,
    CASE
        WHEN COUNT(DISTINCT o.id) >= 5  THEN 'VIP Customer'
        WHEN COUNT(DISTINCT o.id) >= 3  THEN 'Loyal Customer'
        WHEN COUNT(DISTINCT o.id) >= 1  THEN 'Regular Customer'
        ELSE                                 'Inactive'
    END                                  AS customer_tier
FROM users u
LEFT JOIN orders o   ON u.id = o.user_id
LEFT JOIN favorites f ON u.id = f.user_id
GROUP BY u.id, u.name, u.email
ORDER BY total_spent_ugx DESC;

-- INSIGHT 5: PRODUCT MOVEMENT & LOSS REPORT
-- What happened to stock? Was any lost to damage or gifts?

SELECT
    p.name                               AS product_name,
    p.category,
    SUM(CASE WHEN pm.movement_type = 'Sale'       THEN pm.quantity ELSE 0 END) AS sold,
    SUM(CASE WHEN pm.movement_type = 'Gift'       THEN pm.quantity ELSE 0 END) AS given_as_gifts,
    SUM(CASE WHEN pm.movement_type = 'Damaged'    THEN pm.quantity ELSE 0 END) AS damaged,
    SUM(CASE WHEN pm.movement_type = 'Return'     THEN pm.quantity ELSE 0 END) AS returned,
    SUM(CASE WHEN pm.movement_type = 'Promotion'  THEN pm.quantity ELSE 0 END) AS promotions,
    SUM(pm.quantity)                     AS total_units_moved,
    p.stock                              AS remaining_stock
FROM product_movements pm
JOIN products p ON pm.product_id = p.id
GROUP BY p.id, p.name, p.category, p.stock
ORDER BY total_units_moved DESC;

-- INSIGHT 6: INNOVATION HUB PERFORMANCE
-- How are student innovation products doing?

SELECT
    ihp.project_name,
    ihp.innovator_name,
    ihp.category,
    ihp.price                            AS listed_price_ugx,
    ihp.status                           AS approval_status,
    COUNT(DISTINCT ic.id)                AS times_added_to_cart,
    COUNT(DISTINCT iff.id)               AS times_favorited,
    ihp.created_at                       AS submitted_on
FROM innovation_hub_products ihp
LEFT JOIN innovation_cart ic     ON ihp.id = ic.product_id
LEFT JOIN innovation_favorites iff ON ihp.id = iff.product_id
GROUP BY ihp.id, ihp.project_name, ihp.innovator_name,
         ihp.category, ihp.price, ihp.status, ihp.created_at
ORDER BY ihp.status, times_favorited DESC;

-- INSIGHT 7: ORDER FULFILLMENT RATE
-- What percentage of orders actually reach the customer?

SELECT
    COUNT(*)                             AS total_orders,
    SUM(CASE WHEN status = 'Delivered'  THEN 1 ELSE 0 END) AS delivered,
    SUM(CASE WHEN status = 'Shipped'    THEN 1 ELSE 0 END) AS shipped,
    SUM(CASE WHEN status = 'Processing' THEN 1 ELSE 0 END) AS processing,
    SUM(CASE WHEN status = 'Canceled'   THEN 1 ELSE 0 END) AS canceled,
    SUM(CASE WHEN status = 'Refunded'   THEN 1 ELSE 0 END) AS refunded,
    ROUND(
        SUM(CASE WHEN status = 'Delivered' THEN 1 ELSE 0 END) * 100.0 / COUNT(*),
        2
    ) AS fulfillment_rate_percent
FROM orders;

-- INSIGHT 8: FEEDBACK RESPONSE ANALYSIS
-- Is customer feedback being handled well?

SELECT
    status,
    COUNT(*)                             AS number_of_feedback,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM feedback), 2) AS percentage
FROM feedback
GROUP BY status;

-- Feedback that got a reply - response time analysis
SELECT
    u.username                               AS customer_name,
    f.message,
    f.status,
    f.created_at                         AS feedback_date,
    f.replied_at,
    TIMESTAMPDIFF(HOUR, f.created_at, f.replied_at) AS hours_to_reply
FROM feedback f
JOIN users u ON f.user_id = u.id
WHERE f.replied_at IS NOT NULL
ORDER BY hours_to_reply DESC;