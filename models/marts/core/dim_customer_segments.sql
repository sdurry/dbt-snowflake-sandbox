{{
    config(
        materialized='table'
    )
}}

with customer_ltv as (

    select
        customer_key,
        sum(net_item_sales_amount) as lifetime_value
    from {{ ref('fct_orders') }}
    group by customer_key

),

ltv_percentiles as (

    select
        percentile_cont(0.25) within group (order by lifetime_value) as p25,
        percentile_cont(0.90) within group (order by lifetime_value) as p90
    from customer_ltv

),

final as (

    select
        ltv.customer_key,
        ltv.lifetime_value,
        case
            when ltv.lifetime_value <= p.p25 then 'bronze'
            when ltv.lifetime_value >= p.p90 then 'gold'
            else 'silver'
        end as customer_segment
    from customer_ltv ltv
    cross join ltv_percentiles p

)

select * from final
