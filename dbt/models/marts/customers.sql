WITH order_summary AS (

    SELECT
        user_id,
        COUNT(*) AS count_lifetime_orders,
        COUNT(*) FILTER (WHERE order_status = 'returned') AS count_lifetime_returned_orders,
        MIN(ordered_at) AS first_order_at,
        MAX(ordered_at) AS last_order_at,
        SUM(gross_revenue) AS lifetime_gross_revenue,
        SUM(realized_revenue) AS lifetime_realized_revenue,
        SUM(returned_revenue) AS lifetime_returned_revenue
    FROM {{ ref('orders') }}
    GROUP BY 1

),

users AS (

    SELECT * FROM {{ ref('int_users') }}

)

SELECT
    u.user_id,
    u.city,
    u.state,
    u.country_raw,
    u.country,
    u.postal_code,
    u.latitude,
    u.longitude,
    u.age,
    u.gender,
    u.traffic_source,
    u.registered_at,
    u.registration_date,

    COALESCE(s.count_lifetime_orders, 0) AS count_lifetime_orders,
    COALESCE(s.count_lifetime_orders, 0) > 0 AS has_ordered,
    COALESCE(s.count_lifetime_orders, 0) > 1 AS is_repeat_buyer,
    COALESCE(s.count_lifetime_returned_orders, 0) AS count_lifetime_returned_orders,
    s.first_order_at,
    s.last_order_at,
    COALESCE(s.lifetime_gross_revenue, 0) AS lifetime_gross_revenue,
    COALESCE(s.lifetime_realized_revenue, 0) AS lifetime_realized_revenue,
    COALESCE(s.lifetime_returned_revenue, 0) AS lifetime_returned_revenue

FROM users AS u
-- Keep every registered user. All purchasers are registered users in this
-- snapshot; the 19,956 users with no orders get zeroed lifetime metrics.
LEFT JOIN order_summary AS s USING (user_id)
