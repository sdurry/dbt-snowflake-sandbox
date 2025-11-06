WITH fct_orders AS (
  /* orders fact table */
  SELECT
    *
  FROM {{ ref('stephans_snow_sandbox', 'fct_orders') }}
), dim_customers AS (
  /* Customer dimensions table */
  SELECT
    *
  FROM {{ ref('redshift_dbt_demo', 'dim_customers', v=1) }}
), "join" AS (
  SELECT
    *
  FROM fct_orders
  JOIN dim_customers
    ON fct_orders.CUSTOMER_KEY = dim_customers.customer_key
), untitled_sql AS (
  SELECT
    *
  FROM "join"
)
SELECT
  *
FROM untitled_sql