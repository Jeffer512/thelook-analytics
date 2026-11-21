WITH source AS (

    SELECT * FROM {{ source('thelook', 'distribution_centers') }}

),

renamed AS (

    SELECT
        CAST(id AS BIGINT) AS distribution_center_id,
        TRIM(CAST(name AS VARCHAR)) AS distribution_center_name,
        CAST(latitude AS DOUBLE) AS latitude,
        CAST(longitude AS DOUBLE) AS longitude
    FROM source

)

SELECT * FROM renamed
