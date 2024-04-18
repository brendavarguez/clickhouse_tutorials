{{
    config(
        materialized = "incremental",
        unique_key = "reservation_id",
        primary_key = '(reservation_q, transaction_payment_result, transaction_type, user_id, reservation_id)',
        order_by = '(reservation_q,  transaction_payment_result, transaction_type, user_id, reservation_id)',
        settings = {'allow_nullable_key': 1,
                    'replicated_can_become_leader': True,
                    'max_suspicious_broken_parts': 1},
        partition_by = 'reservation_year',
        incremental_strategy = 'delete+insert',
    )
}}

SELECT
    id AS reservation_id,
    last_mod,
    user_id,
    added AS reservation_added,
    date_trunc('year', added) AS reservation_year,
    date_trunc('quarter', added) AS reservation_q,
    card_id,
    is_cancelled,
    is_failed,
    processed_at,
    amount,
    CASE
        WHEN result = 0 THEN 'APPROVED'
        WHEN result = 1 THEN 'DECLINED'
        WHEN result = 2 THEN 'ERROR'
        WHEN result = 3 THEN 'TIMEOUT'
        ELSE 'UNKNOWN_RESULT'
    END AS transaction_payment_result,
    CASE
        WHEN type = 0 THEN 'CASH'
        WHEN type = 1 THEN 'CHIP'
        WHEN type = 2 THEN 'SWIPE'
        WHEN type = 6 THEN 'CONTACTLESS'
        ELSE 'UNKNOWN_TYPE'
    END AS transaction_type,
    commissions
FROM postgresql('db_host:5432', 'db_name', 'reservations',
        "{{ env_var('PROD_DB_USER') }}", "{{ env_var('PROD_DB_PASS') }}",
        'public')
{% if is_incremental() %}

    WHERE last_mod > (
        SELECT MAX(last_mod) FROM {{ this }}
        WHERE
            reservation_year
            >= date_trunc(
                'year', now('America/Mexico_City') - INTERVAL '365 day'
            )
            -- no record can have an smaller last_mod value than
            -- its reservation_added val. '-1 day' for update every new year
            -- or '-365 day' for all reservations added last year
    )

{% endif %}
