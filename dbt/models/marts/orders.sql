WITH item_totals AS (

    SELECT
        order_id,
        SUM(gross_revenue) AS gross_revenue,
        SUM(realized_revenue) AS realized_revenue,
        SUM(returned_revenue) AS returned_revenue,
        SUM(gross_margin) AS gross_margin
    FROM {{ ref('order_items') }}
    GROUP BY 1

),

orders AS (

    SELECT * FROM {{ ref('stg_orders') }}

),

users AS (

    SELECT * FROM {{ ref('int_users') }}

)

SELECT
    o.order_id,
    o.user_id,
    o.ordered_at,
    o.order_status,
    o.shipped_at,
    o.delivered_at,
    o.returned_at,
    o.item_count,

    t.gross_revenue,
    t.realized_revenue,
    t.returned_revenue,
    t.gross_margin,

    u.country,
    u.age,
    u.gender

FROM orders AS o
JOIN item_totals AS t USING (order_id)
JOIN users AS u USING (user_id)
