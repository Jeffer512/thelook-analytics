SELECT
    oi.order_item_id,
    oi.product_id,
    oi.sale_price,
    p.retail_price
FROM {{ ref('stg_order_items') }} AS oi
JOIN {{ ref('stg_products') }} AS p USING (product_id)
WHERE oi.sale_price IS DISTINCT FROM p.retail_price
