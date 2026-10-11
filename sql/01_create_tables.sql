CREATE TABLE website_sessions (
    website_session_id BIGINT PRIMARY KEY,
    created_at TIMESTAMP,
    user_id BIGINT,
    is_repeat_session INTEGER,
    utm_source TEXT,
    utm_campaign TEXT,
    utm_content TEXT,
    device_type TEXT,
    http_referer TEXT
);

CREATE TABLE website_pageviews (
    website_pageview_id BIGINT PRIMARY KEY,
    created_at TIMESTAMP,
    website_session_id BIGINT,
    pageview_url TEXT
);

CREATE TABLE products (
    product_id BIGINT PRIMARY KEY,
    created_at TIMESTAMP,
    product_name TEXT
);

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY,
    created_at TIMESTAMP,
    website_session_id BIGINT,
    user_id BIGINT,
    primary_product_id BIGINT,
    items_purchased INTEGER,
    price_usd NUMERIC,
    cogs_usd NUMERIC
);

CREATE TABLE order_items (
    order_item_id BIGINT PRIMARY KEY,
    created_at TIMESTAMP,
    order_id BIGINT,
    product_id BIGINT,
    is_primary_item INTEGER,
    price_usd NUMERIC,
    cogs_usd NUMERIC
);

CREATE TABLE order_item_refunds (
    order_item_refund_id BIGINT PRIMARY KEY,
    created_at TIMESTAMP,
    order_item_id BIGINT,
    order_id BIGINT,
    refund_amount_usd NUMERIC
);