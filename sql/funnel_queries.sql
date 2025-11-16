
-- Query 1: Overall Funnel Metrics
-- Calculate user counts at each funnel stage
SELECT
    COUNT(DISTINCT CASE WHEN event = 'view' THEN visitorid END) as viewers,
    COUNT(DISTINCT CASE WHEN event = 'addtocart' THEN visitorid END) as cart_users,
    COUNT(DISTINCT CASE WHEN event = 'transaction' THEN visitorid END) as purchasers,
    ROUND(COUNT(DISTINCT CASE WHEN event = 'addtocart' THEN visitorid END) * 100.0 /
          COUNT(DISTINCT CASE WHEN event = 'view' THEN visitorid END), 2) as view_to_cart_pct,
    ROUND(COUNT(DISTINCT CASE WHEN event = 'transaction' THEN visitorid END) * 100.0 /
          COUNT(DISTINCT CASE WHEN event = 'addtocart' THEN visitorid END), 2) as cart_to_purchase_pct,
    ROUND(COUNT(DISTINCT CASE WHEN event = 'transaction' THEN visitorid END) * 100.0 /
          COUNT(DISTINCT CASE WHEN event = 'view' THEN visitorid END), 2) as overall_conversion_pct
FROM read_csv_auto('../data/events.csv');


-- Query 2: Top Converting Items
-- Find items with highest view-to-purchase conversion rates
WITH item_metrics AS (
    SELECT
        itemid,
        COUNT(DISTINCT CASE WHEN event = 'view' THEN visitorid END) as views,
        COUNT(DISTINCT CASE WHEN event = 'transaction' THEN visitorid END) as purchases
    FROM read_csv_auto('../data/events.csv')
    GROUP BY itemid
    HAVING views >= 100  -- Statistical significance filter
)
SELECT
    itemid,
    views,
    purchases,
    ROUND(purchases * 100.0 / views, 2) as conversion_rate
FROM item_metrics
ORDER BY conversion_rate DESC
LIMIT 10;


-- Query 3: Cohort Analysis - User Cohorts by Week
-- Group users by their first visit week
WITH user_cohorts AS (
    SELECT
        visitorid,
        DATE_TRUNC('week', MIN(epoch_ms(timestamp))) as cohort_week
    FROM read_csv_auto('../data/events.csv')
    GROUP BY visitorid
),
cohort_metrics AS (
    SELECT
        uc.cohort_week,
        COUNT(DISTINCT uc.visitorid) as total_users,
        COUNT(DISTINCT CASE WHEN e.event = 'addtocart' THEN e.visitorid END) as cart_users,
        COUNT(DISTINCT CASE WHEN e.event = 'transaction' THEN e.visitorid END) as purchasers
    FROM user_cohorts uc
    LEFT JOIN read_csv_auto('../data/events.csv') e ON uc.visitorid = e.visitorid
    GROUP BY uc.cohort_week
)
SELECT
    cohort_week,
    total_users,
    cart_users,
    purchasers,
    ROUND(cart_users * 100.0 / total_users, 2) as view_to_cart_pct,
    ROUND(purchasers * 100.0 / NULLIF(cart_users, 0), 2) as cart_to_purchase_pct,
    ROUND(purchasers * 100.0 / total_users, 2) as overall_conversion_pct
FROM cohort_metrics
ORDER BY cohort_week;


-- Query 4: Cohort Retention Analysis
-- Track user activity in weeks following their first visit
WITH user_cohorts AS (
    SELECT
        visitorid,
        DATE_TRUNC('week', MIN(epoch_ms(timestamp))) as cohort_week
    FROM read_csv_auto('../data/events.csv')
    GROUP BY visitorid
),
user_activity AS (
    SELECT
        e.visitorid,
        uc.cohort_week,
        DATE_TRUNC('week', epoch_ms(e.timestamp)) as activity_week,
        DATE_DIFF('week', uc.cohort_week, DATE_TRUNC('week', epoch_ms(e.timestamp))) as weeks_since_cohort
    FROM read_csv_auto('../data/events.csv') e
    JOIN user_cohorts uc ON e.visitorid = uc.visitorid
)
SELECT
    cohort_week,
    weeks_since_cohort,
    COUNT(DISTINCT visitorid) as active_users
FROM user_activity
WHERE weeks_since_cohort <= 12  -- First 12 weeks
GROUP BY cohort_week, weeks_since_cohort
ORDER BY cohort_week, weeks_since_cohort;


-- Query 5: Daily Event Distribution
-- Analyze events by day of week and hour
SELECT
    DAYNAME(epoch_ms(timestamp)) as day_of_week,
    HOUR(epoch_ms(timestamp)) as hour,
    event,
    COUNT(*) as event_count,
    COUNT(DISTINCT visitorid) as unique_users
FROM read_csv_auto('../data/events.csv')
GROUP BY day_of_week, hour, event
ORDER BY day_of_week, hour, event;


-- Query 6: Time to Conversion Analysis
-- Calculate median time between funnel stages
WITH user_events AS (
    SELECT
        visitorid,
        MIN(CASE WHEN event = 'view' THEN epoch_ms(timestamp) END) as first_view,
        MIN(CASE WHEN event = 'addtocart' THEN epoch_ms(timestamp) END) as first_cart,
        MIN(CASE WHEN event = 'transaction' THEN epoch_ms(timestamp) END) as first_purchase
    FROM read_csv_auto('../data/events.csv')
    GROUP BY visitorid
)
SELECT
    ROUND(MEDIAN(DATE_DIFF('minute', first_view, first_cart)), 1) as median_view_to_cart_minutes,
    ROUND(MEDIAN(DATE_DIFF('minute', first_cart, first_purchase)), 1) as median_cart_to_purchase_minutes,
    ROUND(MEDIAN(DATE_DIFF('minute', first_view, first_purchase)), 1) as median_total_journey_minutes
FROM user_events
WHERE first_cart IS NOT NULL AND first_purchase IS NOT NULL;
