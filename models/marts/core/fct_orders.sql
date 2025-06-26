WITH stg_tpch_orders AS (
  SELECT
    *
  FROM {{ ref('stg_tpch_orders') }}
), order_items AS (
  SELECT
    ORDER_KEY,
    GROSS_ITEM_SALES_AMOUNT,
    ITEM_DISCOUNT_AMOUNT,
    ITEM_TAX_AMOUNT,
    NET_ITEM_SALES_AMOUNT
  FROM {{ ref('order_items') }}
), filter AS (
  SELECT
    *
  FROM stg_tpch_orders
  WHERE
    STATUS_CODE <> 'P'
), aggregate_1 AS (
  SELECT
    ORDER_KEY,
    SUM(GROSS_ITEM_SALES_AMOUNT) AS GROSS_ITEM_SALES_AMOUNT,
    SUM(ITEM_DISCOUNT_AMOUNT) AS ITEM_DISCOUNT_AMOUNT,
    SUM(ITEM_TAX_AMOUNT) AS ITEM_TAX_AMOUNT,
    SUM(NET_ITEM_SALES_AMOUNT) AS NET_ITEM_SALES_AMOUNT
  FROM order_items
  GROUP BY
    ORDER_KEY
), join_1 AS (
  SELECT
    filter.ORDER_KEY,
    filter.ORDER_DATE,
    filter.CUSTOMER_KEY,
    filter.STATUS_CODE,
    filter.PRIORITY_CODE,
    filter.CLERK_NAME,
    filter.SHIP_PRIORITY,
    aggregate_1.GROSS_ITEM_SALES_AMOUNT,
    aggregate_1.ITEM_DISCOUNT_AMOUNT,
    aggregate_1.ITEM_TAX_AMOUNT,
    aggregate_1.NET_ITEM_SALES_AMOUNT
  FROM filter
  JOIN aggregate_1
    ON filter.ORDER_KEY = aggregate_1.ORDER_KEY
), formula_1 AS (
  SELECT
    ORDER_KEY,
    ORDER_DATE,
    CUSTOMER_KEY,
    STATUS_CODE,
    PRIORITY_CODE,
    CLERK_NAME,
    SHIP_PRIORITY,
    GROSS_ITEM_SALES_AMOUNT,
    ITEM_DISCOUNT_AMOUNT,
    ITEM_TAX_AMOUNT,
    NET_ITEM_SALES_AMOUNT,
    1 AS ORDER_COUNT
  FROM join_1
), order_1 AS (
  SELECT
    *
  FROM formula_1
  ORDER BY
    ORDER_DATE ASC
), fct_orders AS (
  SELECT
    *
  FROM order_1
)
SELECT
  *
FROM fct_orders