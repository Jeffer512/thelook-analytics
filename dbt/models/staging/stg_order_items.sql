WITH source AS (

    SELECT * FROM {{ source('thelook', 'order_items') }}

),

renamed AS (

    SELECT
        CAST(id AS BIGINT) AS order_item_id,
        CAST(order_id AS BIGINT) AS order_id,
        CAST(user_id AS BIGINT) AS user_id,
        CAST(product_id AS BIGINT) AS product_id,
        CAST(inventory_item_id AS BIGINT) AS inventory_item_id,
        LOWER(TRIM(CAST(status AS VARCHAR))) AS item_status,
        CAST(created_at AS TIMESTAMPTZ) AS item_created_at,
        CAST(shipped_at AS TIMESTAMPTZ) AS shipped_at,
        CAST(delivered_at AS TIMESTAMPTZ) AS delivered_at,
        CAST(returned_at AS TIMESTAMPTZ) AS returned_at,
        CAST(sale_price AS DECIMAL(12, 2)) AS sale_price
    FROM source

)

SELECT * FROM renamed
