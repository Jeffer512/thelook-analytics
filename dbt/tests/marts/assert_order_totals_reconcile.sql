WITH item_totals AS (

    SELECT
        order_id,
        SUM(gross_revenue) AS gross_revenue,
        SUM(realized_revenue) AS realized_revenue,
        COUNT(*) AS item_count
    FROM {{ ref('order_items') }}
    GROUP BY 1

),

compare AS (

    SELECT
        o.order_id,
        o.gross_revenue AS order_gross,
        i.gross_revenue AS item_gross,
        o.realized_revenue AS order_realized,
        i.realized_revenue AS item_realized,
        o.item_count AS order_item_count,
        i.item_count AS counted_item_count
    FROM {{ ref('orders') }} AS o
    LEFT JOIN item_totals AS i USING (order_id)

)

SELECT *
FROM compare
WHERE order_gross IS DISTINCT FROM item_gross
   OR order_realized IS DISTINCT FROM item_realized
   OR order_item_count IS DISTINCT FROM counted_item_count
