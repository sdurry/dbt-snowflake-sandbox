WITH fct_orders AS (
  SELECT
    CUSTOMER_KEY,
    NET_ITEM_SALES_AMOUNT
  FROM {{ ref('fct_orders') }}
), aggregate_1 AS (
  SELECT
    CUSTOMER_KEY,
    SUM(NET_ITEM_SALES_AMOUNT) AS TOTAL_NET_SALES
  FROM fct_orders
  GROUP BY
    CUSTOMER_KEY
), generated AS (
  SELECT
    *
  FROM aggregate_1
)
SELECT
  *
FROM generated