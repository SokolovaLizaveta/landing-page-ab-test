SELECT COUNT(*) FROM website_sessions;
SELECT COUNT(*) FROM website_pageviews;
SELECT COUNT(*) FROM orders;
SELECT COUNT(*) FROM order_items;
SELECT COUNT(*) FROM order_item_refunds;
SELECT COUNT(*) FROM products;

SELECT *
FROM website_sessions
LIMIT 10;

SELECT *
FROM website_pageviews
LIMIT 10;

SELECT 
    MIN(created_at) AS "first_date",
    MAX(created_at) AS "last_date"
FROM website_pageviews;