CampusShop SQL Analytics Project
Project Overview
CampusShop is a university-based e-commerce platform (Bugema University) that sells branded merchandise including T-shirts, notebooks, bags, pens, bottles, and wall clocks. The platform also features an Innovation Hub where students can list and sell their own creative projects.
This project performs a complete SQL data analysis of the CampusShop database to uncover sales trends, customer behavior, inventory health, and business performance.
Database: `campusshop_db`
 
`users`  Registered customers and admins 
`products` Campus merchandise for sale 
`orders` Customer purchase orders
`order_items` Individual items within each order
`pending_deliveries` Delivery tracking records
`product_movements` Stock movement log (sales, gifts, damage)
`favorites` Products saved by customers
`cart` Items in customers' active shopping carts
`feedback` Customer messages and admin replies
`notifications` System notifications sent to users
`innovation_hub_products` Student-created products
`innovation_cart` Carts for innovation products
`innovation_favorites` Wishlists for innovation products
`abandoned_carts` Carts that were not checked out
`coupons` Discount coupons

Project Structure
campusshop_sql_project/
│
├── phase1_exploration/
│   └── explore database.sql       Know your data first
│
├── phase2_cleaning/
│   └── data cleaning.sql          Find and flag data issues
│
├── phase3_analysis/
│   └── core analysis.sql          Answer basic business questions
│
├── phase4_advanced/
│   └── advanced queries.sql       JOINs, CTEs, Window Functions
│
├── phase5_business_insights/
│   └── business_insights.sql      Final reports for management
│
└── docs/
    └── README.md                      This file (project documentation)
Analysis Phases

Phase 1 – Database Exploration
- View all tables and their structure (`SHOW TABLES`, `DESCRIBE`)
- Preview sample data from each table
- Count total records per table
SQL Skills Practiced: `SHOW TABLES`, `DESCRIBE`, `SELECT *`, `LIMIT`, `UNION ALL`, `COUNT()`

Phase 2 – Data Cleaning
- Find missing values (NULL checks)
- Detect duplicate records
- Identify pricing errors (zero price)
- Flag out-of-stock active products
SQL Skills Practiced: `IS NULL`, `GROUP BY`, `HAVING`, `COUNT()`, conditional `WHERE`

Phase 3 – Core Analysis
- Total revenue and average order value
- Revenue by order status and payment method
- Monthly sales trends
- Product popularity by category
- Best-selling products
- Customer order frequency
- Delivery location breakdown
SQL Skills Practiced: `SUM()`, `AVG()`, `COUNT()`, `GROUP BY`, `ORDER BY`, `DATE_FORMAT()`, `LEFT JOIN`

Phase 4 – Advanced Queries
- Multi-table JOINs (4 tables in one query)
- Subqueries (queries inside queries)
- CTEs – Common Table Expressions (`WITH` clause)
- Window Functions: `RANK()`, `ROW_NUMBER()`, `SUM() OVER()`
- Running totals and category rankings
SQL Skills Practiced:`JOIN`, `LEFT JOIN`, `WITH`, `RANK()`, `ROW_NUMBER()`, `PARTITION BY`, `OVER()`

Phase 5 – Business Insights
- Executive dashboard summary
- Category revenue performance
- Urgent stock restock report
- Customer loyalty tiers (VIP, Loyal, Regular)
- Product movement & loss analysis
- Innovation Hub performance
- Order fulfillment rate
- Customer feedback response analysis
SQL Skills Practiced:`CASE WHEN`, `COALESCE()`, `TIMESTAMPDIFF()`, `DATEDIFF()`, advanced aggregations
Key Business Findings
1. Bags and T-Shirts are the highest revenue categories.
2. Several products like **Tote bags and Laptop bags** have very low stock and high cart demand.
3. User 1 (Tendo) is the most active customer with the most orders and highest spend.
4. Mobile Money is the dominant payment method used by customers.
5. The fulfillment rate (orders that reached Delivered status) needs monitoring.
6. Customer feedback response time ranged widely some replies took many hours.
7. The Innovation Hub has 4 student projects, 3 approved, 1 pending.

Tools Used
- Database: MySQL 
- Query Editor: MySQL Workbench
- SQL Version: Compatible with MySQL 5.7+

Author
Nakanjako Tendo Jackline
Data Analytics Learner | SQL Project Portfolio
(https://github.com/JACKIETendo)

Project Date
21/April/2026
