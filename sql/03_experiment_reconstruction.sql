-- 1. Первое появление новой посадочной страницы /lander-1
SELECT *
FROM website_pageviews
WHERE pageview_url = '/lander-1'
ORDER BY created_at
LIMIT 1;


-- 2. Определение первой страницы каждой сессии
WITH row_number_table AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY website_session_id 
            ORDER BY website_pageview_id
        ) AS rn
    FROM website_pageviews
),
first_page AS (
    SELECT *
    FROM row_number_table
    WHERE rn = 1
)

SELECT *
FROM first_page
LIMIT 10;


-- 3. Распределение посадочных страниц по источникам и рекламным кампаниям
WITH row_number_table AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY website_session_id 
            ORDER BY website_pageview_id
        ) AS rn
    FROM website_pageviews
),
first_page AS (
    SELECT *
    FROM row_number_table
    WHERE rn = 1
)

SELECT 
    ws.utm_source, 
    ws.utm_campaign, 
    fp.pageview_url,
    COUNT(*) AS sessions
FROM first_page fp
JOIN website_sessions ws
    ON ws.website_session_id = fp.website_session_id
WHERE fp.pageview_url IN ('/home', '/lander-1')
GROUP BY 
    ws.utm_source, 
    ws.utm_campaign, 
    fp.pageview_url
ORDER BY 
    ws.utm_source, 
    ws.utm_campaign, 
    fp.pageview_url;


-- 4. Определение начала A/B-теста
WITH row_number_table AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY website_session_id 
            ORDER BY website_pageview_id
        ) AS rn
    FROM website_pageviews
),
first_page AS (
    SELECT *
    FROM row_number_table
    WHERE rn = 1
),
tabl AS (
    SELECT 
        fp.*,
        ws.utm_source,
        ws.utm_campaign
    FROM first_page fp
    JOIN website_sessions ws
        ON fp.website_session_id = ws.website_session_id
    WHERE ws.utm_source = 'gsearch'
      AND ws.utm_campaign = 'nonbrand'
)

SELECT MIN(created_at) AS "start_AB"
FROM tabl
WHERE pageview_url = '/lander-1';


-- 5. Определение окончания A/B-теста
WITH row_number_table AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY website_session_id 
            ORDER BY website_pageview_id
        ) AS rn
    FROM website_pageviews
),
first_page AS (
    SELECT *
    FROM row_number_table
    WHERE rn = 1
),
tabl AS (
    SELECT 
        fp.*,
        ws.utm_source,
        ws.utm_campaign
    FROM first_page fp
    JOIN website_sessions ws
        ON fp.website_session_id = ws.website_session_id
    WHERE ws.utm_source = 'gsearch'
      AND ws.utm_campaign = 'nonbrand'
)

SELECT MAX(created_at) AS "end_AB"
FROM tabl
WHERE pageview_url = '/home';


-- 6. Проверка распределения трафика между вариантами в период A/B-теста
WITH row_number_table AS (
    SELECT 
        *,
        ROW_NUMBER() OVER (
            PARTITION BY website_session_id 
            ORDER BY website_pageview_id
        ) AS rn
    FROM website_pageviews
),
first_page AS (
    SELECT *
    FROM row_number_table
    WHERE rn = 1
)

SELECT 
    ws.utm_source, 
    ws.utm_campaign, 
    fp.pageview_url,
    COUNT(*) AS sessions
FROM first_page fp
JOIN website_sessions ws
    ON ws.website_session_id = fp.website_session_id
WHERE fp.pageview_url IN ('/home', '/lander-1') AND
    ws.utm_source = 'gsearch' AND 
    ws.utm_campaign = 'nonbrand' AND
    fp.created_at >= '2012-06-19' AND 
    fp.created_at < '2012-07-30'
GROUP BY 
    ws.utm_source, 
    ws.utm_campaign, 
    fp.pageview_url
ORDER BY 
    ws.utm_source, 
    ws.utm_campaign, 
    fp.pageview_url;


-- 7.0 Проверка, какие страницы использовались как landing page до A/B-теста
WITH row_number_table AS (
    SELECT 
        wp.website_pageview_id,
        wp.website_session_id,
        wp.pageview_url,
        wp.created_at AS pageview_created_at,
        ws.created_at AS session_created_at,
        ws.utm_source,
        ws.utm_campaign,
        ROW_NUMBER() OVER (
            PARTITION BY wp.website_session_id 
            ORDER BY wp.website_pageview_id
        ) AS rn
    FROM website_pageviews wp 
    JOIN website_sessions ws
        ON ws.website_session_id = wp.website_session_id
),
first_page AS (
    SELECT *
    FROM row_number_table
    WHERE rn = 1
      AND utm_source = 'gsearch'
      AND utm_campaign = 'nonbrand'
      AND session_created_at < '2012-06-19'
)

SELECT 
    pageview_url,
    COUNT(*) AS count
FROM first_page
GROUP BY pageview_url;


-- 7.1 Определение первоначального уровня bounce rate
WITH pretest_sessions AS (
    SELECT
        ws.website_session_id,
        COUNT(wp.website_pageview_id) AS pageviews
    FROM website_sessions ws
    JOIN website_pageviews wp
        ON ws.website_session_id = wp.website_session_id
    WHERE ws.utm_source = 'gsearch'
      AND ws.utm_campaign = 'nonbrand'
      AND ws.created_at < '2012-06-19'
    GROUP BY ws.website_session_id
)

SELECT
    COUNT(*) FILTER (WHERE pageviews = 1)::NUMERIC / COUNT(*) AS "bounce_rate"
FROM pretest_sessions;


-- 8. Использовалась ли старая версия посадочной страницы после эксперимента? (нет)
SELECT *
FROM website_sessions ws
JOIN website_pageviews wp
    ON ws.website_session_id = wp.website_session_id
WHERE ws.utm_source = 'gsearch' AND 
    ws.utm_campaign = 'nonbrand' AND 
    ws.created_at >= '2012-07-30' AND
    wp.pageview_url = '/home';

-- 9. Использовалась ли старая версия посадочной страницы после эксперимента на общем трафике?
SELECT COUNT(*)
FROM website_sessions ws
JOIN website_pageviews wp
    ON ws.website_session_id = wp.website_session_id
WHERE
    ws.created_at >= '2012-07-30' AND
    wp.pageview_url = '/home';