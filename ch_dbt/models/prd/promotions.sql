{{
    config(
		    materialized = "table",
        pre_hook = "TRUNCATE TABLE IF EXISTS {{ this }} ON CLUSTER default",
    )
}}

SELECT
    id AS promotion_id,
    uuid,
    shipping_delay_days AS shipment_days,
    amount_shipping / 100 AS shipping_amount,
    amount_net / 100 AS item_price,
    description_short AS promo_name,
    round(discount_percentage_display * 100 / (amount_net / 100), 2)
        AS discount_percentage,
    discount_percentage_display AS discount_amount
FROM postgresql('host.db:5432', 'database_name', 'promotions',
        "{{ env_var('PROD_DB_USER') }}", "{{ env_var('PROD_DB_PASS') }}",
        'public')
