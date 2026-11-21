WITH source AS (

    SELECT * FROM {{ source('thelook', 'products') }}

),

renamed AS (

    SELECT
        CAST(id AS BIGINT) AS product_id,
        CAST(cost AS DECIMAL(12, 2)) AS unit_cost,
        LOWER(TRIM(CAST(category AS VARCHAR))) AS product_category,
        TRIM(CAST(name AS VARCHAR)) AS product_name,
        LOWER(TRIM(CAST(brand AS VARCHAR))) AS product_brand,
        CAST(retail_price AS DECIMAL(12, 2)) AS retail_price,
        LOWER(TRIM(CAST(department AS VARCHAR))) AS product_department,
        TRIM(CAST(sku AS VARCHAR)) AS product_sku,
        CAST(distribution_center_id AS BIGINT) AS distribution_center_id
    FROM source

)

SELECT * FROM renamed
