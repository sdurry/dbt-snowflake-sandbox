{{
    config(
        materialized = 'table'
    )
}}

with orders as (

    select * from {{ ref('fct_orders') }}

),
customers as (

    select * from {{ ref('dim_customers') }}

),
customer_ltv as (

    select
        customer_key,
        sum(net_item_sales_amount) as lifetime_value
    from orders
    group by customer_key

),
percentile_thresholds as (

    select
        percentile_cont(0.25) within group (order by lifetime_value) as p25,
        percentile_cont(0.90) within group (order by lifetime_value) as p90
    from customer_ltv

),
final as (

    select
        c.customer_key,
        c.name as customer_name,
        c.market_segment,
        c.nation,
        c.region,
        ltv.lifetime_value,
        case
            when ltv.lifetime_value <= p.p25 then 'bronze'
            when ltv.lifetime_value >= p.p90 then 'gold'
            else 'silver'
        end as ltv_segment
    from customer_ltv as ltv
    inner join customers as c
        on ltv.customer_key = c.customer_key
    cross join percentile_thresholds as p

)

select * from final
order by customer_key
