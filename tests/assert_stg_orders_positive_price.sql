{{
    config(
        severity='warn',
    )
}}

with orders as (

    select * from {{ ref('stg_orders') }} 

)

select *
from   orders 
where  total_price_in_usd < 0