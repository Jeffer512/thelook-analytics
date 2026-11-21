WITH source AS (

    SELECT * FROM {{ source('thelook', 'inventory_items') }}

),

renamed AS (

    SELECT
        CAST(id AS BIGINT) AS inventory_item_id,
        CAST(product_id AS BIGINT) AS product_id,
        CAST(created_at AS TIMESTAMPTZ) AS stocked_at,
        CAST(sold_at AS TIMESTAMPTZ) AS sold_at,
        CAST(cost AS DECIMAL(12, 2)) AS unit_cost,
        LOWER(TRIM(CAST(product_category AS VARCHAR))) AS product_category,
        TRIM(CAST(product_name AS VARCHAR)) AS product_name,
        LOWER(TRIM(CAST(product_brand AS VARCHAR))) AS product_brand,
        CAST(product_retail_price AS DECIMAL(12, 2)) AS product_retail_price,
        LOWER(TRIM(CAST(product_department AS VARCHAR))) AS product_department,
        TRIM(CAST(product_sku AS VARCHAR)) AS product_sku,
        CAST(product_distribution_center_id AS BIGINT) AS product_distribution_center_id
    FROM source

)

SELECT * FROM renamed
