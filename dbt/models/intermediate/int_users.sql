WITH users AS (

    SELECT * FROM {{ ref('stg_users') }}

)

SELECT
    user_id,
    city,
    state,
    country AS country_raw,
    CASE country
        WHEN 'Deutschland' THEN 'Germany'
        WHEN 'España' THEN 'Spain'
        ELSE country
    END AS country,
    postal_code,
    latitude,
    longitude,
    age,
    gender,
    traffic_source,
    registered_at,
    CAST(registered_at AT TIME ZONE 'UTC' AS DATE) AS registration_date

FROM users
