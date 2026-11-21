WITH source AS (

    SELECT * FROM {{ source('thelook', 'users') }}

),

renamed AS (

    SELECT
        CAST(id AS BIGINT) AS user_id,
        TRIM(CAST(first_name AS VARCHAR)) AS first_name,
        TRIM(CAST(last_name AS VARCHAR)) AS last_name,
        LOWER(TRIM(CAST(email AS VARCHAR))) AS email,
        CAST(age AS INTEGER) AS age,
        LOWER(TRIM(CAST(gender AS VARCHAR))) AS gender,
        TRIM(CAST(state AS VARCHAR)) AS state,
        TRIM(CAST(street_address AS VARCHAR)) AS street_address,
        TRIM(CAST(postal_code AS VARCHAR)) AS postal_code,
        TRIM(CAST(city AS VARCHAR)) AS city,
        TRIM(CAST(country AS VARCHAR)) AS country,
        CAST(latitude AS DOUBLE) AS latitude,
        CAST(longitude AS DOUBLE) AS longitude,
        LOWER(TRIM(CAST(traffic_source AS VARCHAR))) AS traffic_source,
        CAST(created_at AS TIMESTAMPTZ) AS registered_at
    FROM source

)

SELECT * FROM renamed
