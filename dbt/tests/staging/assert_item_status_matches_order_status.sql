SELECT
    oi.order_item_id,
    oi.order_id,
    oi.item_status,
    o.order_status
FROM {{ ref('stg_order_items') }} AS oi
JOIN {{ ref('stg_orders') }} AS o USING (order_id)
WHERE oi.item_status IS DISTINCT FROM o.order_status
