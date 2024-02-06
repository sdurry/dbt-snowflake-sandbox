with source as (

    select *
    from {{ ref('fct_orders') }}

)

, count_orders as (

    select 
        count(order_key) as order_count
    from source

)

select *
from count_orders