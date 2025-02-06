select
    points_amount
from {{ ref('dim_customer_loyalty') }}
having points_amount < 0