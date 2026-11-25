SELECT
    order_id,
    ordered_at,
    shipped_at,
    delivered_at,
    returned_at
FROM {{ ref('stg_orders') }}
WHERE (shipped_at IS NOT NULL AND shipped_at < ordered_at)
    OR (delivered_at IS NOT NULL AND (shipped_at IS NULL OR delivered_at < shipped_at))
    OR (returned_at IS NOT NULL AND (delivered_at IS NULL OR returned_at < delivered_at))
