WITH source AS (

    SELECT * FROM {{ source('thelook', 'events') }}

),

renamed AS (

    SELECT
        CAST(id AS BIGINT) AS event_id,
        TRY_CAST(user_id AS BIGINT) AS user_id,
        LOWER(TRIM(CAST(session_id AS VARCHAR))) AS session_id,
        CAST(sequence_number AS INTEGER) AS sequence_number,
        CAST(created_at AS TIMESTAMPTZ) AS event_at,
        TRIM(CAST(ip_address AS VARCHAR)) AS ip_address,
        TRIM(CAST(city AS VARCHAR)) AS city,
        TRIM(CAST(state AS VARCHAR)) AS state,
        TRIM(CAST(postal_code AS VARCHAR)) AS postal_code,
        LOWER(TRIM(CAST(browser AS VARCHAR))) AS browser,
        LOWER(TRIM(CAST(traffic_source AS VARCHAR))) AS traffic_source,
        TRIM(CAST(uri AS VARCHAR)) AS uri,
        LOWER(TRIM(CAST(event_type AS VARCHAR))) AS event_type,
    FROM source

)

SELECT * FROM renamed
