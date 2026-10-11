-- Итоговая таблица эксперимента
DROP TABLE IF EXISTS experiment;

CREATE TABLE experiment AS

WITH row_number_table AS (
    SELECT 
        ws.website_session_id,
        ws.created_at AS session_created_at,
        ws.is_repeat_session,
        ws.device_type,
        wp.pageview_url AS landing_page,

        ROW_NUMBER() OVER (
            PARTITION BY wp.website_session_id 
            ORDER BY wp.website_pageview_id
        ) AS rn,

        COUNT(*) OVER (
            PARTITION BY wp.website_session_id 
        ) AS pageviews

    FROM website_pageviews wp 
    JOIN website_sessions ws
        ON ws.website_session_id = wp.website_session_id

    WHERE ws.utm_source = 'gsearch'
      AND ws.utm_campaign = 'nonbrand'
      AND ws.created_at >= '2012-06-19'
      AND ws.created_at < '2012-07-30'
),
order_table AS (
    SELECT 
        website_session_id,
        1 AS "is_order",
        SUM(price_usd) AS "revenue"
    FROM orders
    GROUP BY website_session_id
)

SELECT 
    rnt.website_session_id,
    rnt.session_created_at,
    rnt.is_repeat_session,
    rnt.device_type,
    rnt.landing_page,
    rnt.pageviews,
    CASE 
    WHEN pageviews = 1 THEN 1
    ELSE 0 
    END as "bounced",
    COALESCE(ot.is_order, 0) AS "is_order",
    COALESCE(ot.revenue, 0)  AS "revenue"
FROM row_number_table rnt
LEFT JOIN order_table ot
    ON ot.website_session_id = rnt.website_session_id
WHERE rnt.rn = 1
  AND rnt.landing_page IN ('/home', '/lander-1');


-- Проверим результат
SELECT
    landing_page,
    COUNT(*) AS sessions
FROM experiment
GROUP BY landing_page;

-- Количество строк и уникальных сессий
SELECT
    COUNT(*) AS rows,
    COUNT(DISTINCT website_session_id) AS unique_sessions
FROM experiment;

