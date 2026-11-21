WITH source AS (

    SELECT * FROM {{ source('thelook', 'orders') }}

),

renamed AS (

    SELECT
        CAST(order_id AS BIGINT) AS order_id,
        CAST(user_id AS BIGINT) AS user_id,
        LOWER(TRIM(CAST(status AS VARCHAR))) AS order_status,
        LOWER(TRIM(CAST(gender AS VARCHAR))) AS order_gender,
        CAST(created_at AS TIMESTAMPTZ) AS ordered_at,
        CAST(returned_at AS TIMESTAMPTZ) AS returned_at,
        CAST(shipped_at AS TIMESTAMPTZ) AS shipped_at,
        CAST(delivered_at AS TIMESTAMPTZ) AS delivered_at,
        CAST(num_of_item AS INTEGER) AS item_count
    FROM source

)

SELECT * FROM renamed
