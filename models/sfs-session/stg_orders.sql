{{ config(
    materialized='view'
    ) 
}}

with raw_orders as (

    select *
    from {{ source('orders', 'orders_table') }}

), cleaned as (

    select
        order_key as order_id
        ,customer_key as customer_id
        ,status_code as order_status_code
        ,case 
            when status_code = 'O' then 'ordered'
            when status_code = 'F' then 'filled'
            when status_code = 'P' then 'pending'
        else 'err' end as order_status
        ,total_price as total_price_in_usd
        ,order_date
        ,priority_code
        ,ship_priority
    from raw_orders

)

select * from cleaned