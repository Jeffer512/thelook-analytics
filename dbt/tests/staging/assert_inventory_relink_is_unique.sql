WITH candidates AS (

    SELECT
        oi.order_item_id,
        COUNT(ii.inventory_item_id) AS matches
    FROM {{ ref('stg_order_items') }} AS oi
    LEFT JOIN {{ ref('stg_inventory_items') }} AS ii
        ON ii.product_id = oi.product_id
        AND ii.sold_at = oi.item_created_at
    GROUP BY 1

)

SELECT *
FROM candidates
WHERE matches <> 1
