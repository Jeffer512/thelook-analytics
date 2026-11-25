WITH actual AS (

    SELECT
        o.order_id,
        o.item_count,
        COUNT(oi.order_item_id) AS actual_item_count
    FROM {{ ref('stg_orders') }} AS o
    LEFT JOIN {{ ref('stg_order_items') }} AS oi USING (order_id)
    GROUP BY 1, 2

)

SELECT *
FROM actual
WHERE item_count <> actual_item_count
