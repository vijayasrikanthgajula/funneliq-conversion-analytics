-- ============================================================================
-- FunnelIQ — E-Commerce User Journey & Conversion Analytics
-- Author: Vijaya Srikanth Gajula
-- Dataset: website_events (4,975 deduplicated events across 2,205 sessions)
-- Note: All funnel metrics are computed using DISTINCT session_id denominators.
-- ============================================================================

-- 1. Total Website Sessions & Event Volume
SELECT
    COUNT(*) AS total_clean_events,
    COUNT(DISTINCT session_id) AS total_sessions,
    COUNT(DISTINCT visitor_id) AS unique_visitors,
    ROUND(COUNT(*) * 1.0 / COUNT(DISTINCT session_id), 2) AS avg_events_per_session
FROM website_events;

-- 2. Sessions Involving Product Views
SELECT
    COUNT(DISTINCT session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN session_id END) AS product_view_sessions,
    ROUND(
        COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN session_id END) * 100.0 /
        COUNT(DISTINCT session_id), 2
    ) AS product_view_rate_pct
FROM website_events;

-- 3. Sessions Reaching Add to Cart
SELECT
    COUNT(DISTINCT session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN session_id END) AS add_to_cart_sessions,
    ROUND(
        COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN session_id END) * 100.0 /
        COUNT(DISTINCT session_id), 2
    ) AS add_to_cart_rate_pct
FROM website_events;

-- 4. Sessions Reaching Checkout
SELECT
    COUNT(DISTINCT session_id) AS total_sessions,
    COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN session_id END) AS checkout_sessions,
    ROUND(
        COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN session_id END) * 100.0 /
        COUNT(DISTINCT session_id), 2
    ) AS checkout_rate_pct
FROM website_events;

-- 5. Sessions Completing Purchases & Complete Stage-to-Stage Drop-Off Funnel
WITH session_funnel AS (
    SELECT
        session_id,
        MAX(CASE WHEN event_name = 'session_start' THEN 1 ELSE 0 END) AS visited,
        MAX(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS carted,
        MAX(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS checkout,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchased
    FROM website_events
    GROUP BY session_id
)
SELECT
    SUM(visited) AS total_sessions,
    SUM(viewed) AS view_item_sessions,
    SUM(carted) AS add_to_cart_sessions,
    SUM(checkout) AS checkout_sessions,
    SUM(purchased) AS purchase_sessions,
    ROUND(SUM(purchased) * 100.0 / SUM(visited), 2) AS purchase_conversion_rate_pct,
    ROUND((SUM(viewed) - SUM(carted)) * 100.0 / SUM(viewed), 2) AS view_to_cart_dropoff_pct,
    ROUND((SUM(carted) - SUM(checkout)) * 100.0 / SUM(carted), 2) AS cart_to_checkout_dropoff_pct,
    ROUND((SUM(checkout) - SUM(purchased)) * 100.0 / SUM(checkout), 2) AS checkout_to_purchase_dropoff_pct
FROM session_funnel;

-- 6. Conversion Rates & Revenue by Device Type
WITH session_device AS (
    SELECT
        session_id,
        MAX(device_type) AS device_type,
        MAX(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS carted,
        MAX(CASE WHEN event_name = 'begin_checkout' THEN 1 ELSE 0 END) AS checkout,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchased,
        COALESCE(SUM(purchase_amount_usd), 0) AS revenue
    FROM website_events
    GROUP BY session_id
)
SELECT
    device_type,
    COUNT(*) AS total_sessions,
    SUM(viewed) AS view_sessions,
    SUM(carted) AS cart_sessions,
    SUM(checkout) AS checkout_sessions,
    SUM(purchased) AS purchase_sessions,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS purchase_conv_rate_pct,
    ROUND(SUM(revenue), 2) AS total_revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(purchased), 0), 2) AS avg_order_value_usd
FROM session_device
GROUP BY device_type
ORDER BY purchase_conv_rate_pct DESC;

-- 7. Conversion Rates & Revenue by Traffic Source
WITH session_source AS (
    SELECT
        session_id,
        MAX(traffic_source) AS traffic_source,
        MAX(CASE WHEN event_name = 'view_item' THEN 1 ELSE 0 END) AS viewed,
        MAX(CASE WHEN event_name = 'add_to_cart' THEN 1 ELSE 0 END) AS carted,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchased,
        COALESCE(SUM(purchase_amount_usd), 0) AS revenue
    FROM website_events
    GROUP BY session_id
)
SELECT
    traffic_source,
    COUNT(*) AS total_sessions,
    SUM(viewed) AS view_sessions,
    SUM(carted) AS cart_sessions,
    SUM(purchased) AS purchase_sessions,
    ROUND(SUM(carted) * 100.0 / COUNT(*), 2) AS add_to_cart_rate_pct,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS purchase_conv_rate_pct,
    ROUND(SUM(revenue), 2) AS total_revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(purchased), 0), 2) AS avg_order_value_usd
FROM session_source
GROUP BY traffic_source
ORDER BY purchase_conv_rate_pct DESC;

-- 8. Monthly Purchase Revenue & Conversion Trends
WITH session_monthly AS (
    SELECT
        session_id,
        SUBSTR(MIN(event_date), 1, 7) AS year_month,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchased,
        COALESCE(SUM(purchase_amount_usd), 0) AS revenue
    FROM website_events
    GROUP BY session_id
)
SELECT
    year_month,
    COUNT(*) AS total_sessions,
    SUM(purchased) AS completed_orders,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS conversion_rate_pct,
    ROUND(SUM(revenue), 2) AS purchase_revenue_usd,
    ROUND(SUM(revenue) / NULLIF(SUM(purchased), 0), 2) AS avg_order_value_usd
FROM session_monthly
GROUP BY year_month
ORDER BY year_month;

-- 9. Weekly Website Sessions & Conversion Velocity
WITH session_weekly AS (
    SELECT
        session_id,
        STRFTIME('%Y-W%W', MIN(event_date)) AS year_week,
        MAX(CASE WHEN event_name = 'purchase' THEN 1 ELSE 0 END) AS purchased,
        COALESCE(SUM(purchase_amount_usd), 0) AS revenue
    FROM website_events
    GROUP BY session_id
)
SELECT
    year_week,
    COUNT(*) AS sessions,
    SUM(purchased) AS purchases,
    ROUND(SUM(purchased) * 100.0 / COUNT(*), 2) AS conv_rate_pct,
    ROUND(SUM(revenue), 2) AS revenue_usd
FROM session_weekly
GROUP BY year_week
ORDER BY year_week;

-- 10. Product Category Funnel & Revenue Performance
SELECT
    product_category,
    COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN session_id END) AS view_sessions,
    COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN session_id END) AS cart_sessions,
    COUNT(DISTINCT CASE WHEN event_name = 'begin_checkout' THEN session_id END) AS checkout_sessions,
    COUNT(DISTINCT CASE WHEN event_name = 'purchase' THEN session_id END) AS purchase_sessions,
    ROUND(
        COUNT(DISTINCT CASE WHEN event_name = 'add_to_cart' THEN session_id END) * 100.0 /
        NULLIF(COUNT(DISTINCT CASE WHEN event_name = 'view_item' THEN session_id END), 0), 2
    ) AS view_to_cart_pct,
    ROUND(COALESCE(SUM(purchase_amount_usd), 0), 2) AS total_revenue_usd
FROM website_events
WHERE product_category <> 'Not Applicable'
GROUP BY product_category
ORDER BY total_revenue_usd DESC;
