{{
    config(
        materialized='table'
    )
}}

with orders as (
  select *     
   from {{ ref('stg_orders') }}
)

, customer_orders as ( 
    
    select 
        customer_id, 
        sum(total_price_in_usd) as customer_value 
    from orders
    group by 1

)

, customer_segmentation as (
    select 
        customer_id
        ,case 
            when customer_value >= 3500000 then 'gold'
            when customer_value between 2000000 and 3499999 then 'silver'
            else 'bronze'
        end as medallion_level
        ,round(customer_value / 10000) as points_amount
        ,current_timestamp() as loaded_at_ts
   from customer_orders 
)

select * from customer_segmentation
