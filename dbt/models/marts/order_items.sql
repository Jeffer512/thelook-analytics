WITH order_items AS (

    SELECT * FROM {{ ref('stg_order_items') }}

),

orders AS (

    SELECT * FROM {{ ref('stg_orders') }}

),

products AS (

    SELECT * FROM {{ ref('stg_products') }}

),

users AS (

    SELECT * FROM {{ ref('int_users') }}

)

SELECT
    oi.order_item_id,
    oi.order_id,
    oi.user_id,
    oi.product_id,

    o.ordered_at,
    o.order_status,
    o.order_status IN ('complete', 'shipped') AS is_realized,
    oi.item_created_at,
    o.returned_at,

    u.country,
    u.age,
    u.gender,

    p.product_name,
    p.product_sku,
    p.product_brand,
    p.product_category,
    p.product_department,
    p.distribution_center_id,
    p.retail_price,
    p.unit_cost,

    oi.sale_price,
    oi.sale_price AS gross_revenue,
    CASE WHEN o.order_status IN ('complete', 'shipped') THEN oi.sale_price ELSE 0 END AS realized_revenue,
    CASE WHEN o.order_status = 'returned' THEN oi.sale_price ELSE 0 END AS returned_revenue,
    oi.sale_price - p.unit_cost AS gross_margin

FROM order_items AS oi
JOIN orders AS o USING (order_id)
JOIN products AS p USING (product_id)
JOIN users AS u ON u.user_id = oi.user_id
