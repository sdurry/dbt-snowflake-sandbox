{{
    config(
        materialized='table',
        transient='false'
    )
}}

with 

source as (

    select * from {{ source('tpch_external', 'orders') }}

),

renamed as (

    select
        o_orderkey as order_id,
        o_custkey as customer_id,
        o_orderstatus::varchar as order_status,
        {{ cents_to_dollars('o_totalprice') }} as order_price,
        TO_DATE(TRIM(o_orderdate, '\"'),'YYYY-MM-DD') as order_date,
        SPLIT_PART(TRIM(o_orderpriority, '\"'),'-',1)::integer as order_priority_value,
        SPLIT_PART(TRIM(o_orderpriority, '\"'),'-',2)::varchar as order_priority,
        o_clerk as clerk_name,
        o_shippriority as ship_priority

    from source

)

select * from renamed
