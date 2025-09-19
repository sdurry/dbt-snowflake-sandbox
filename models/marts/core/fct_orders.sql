WITH stg_tpch_orders AS (
  SELECT
    *
  FROM {{ ref('stg_tpch_orders') }}
), order_items AS (
  SELECT
    *
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
), rename_1 AS (
  SELECT
    *
    RENAME (ORDER_KEY AS ORDERS_ORDER_KEY)
  FROM filter
), rename_2 AS (
  SELECT
    ORDER_KEY AS ORDER_ITEM_SUMMARY_ORDER_KEY,
    GROSS_ITEM_SALES_AMOUNT,
    ITEM_DISCOUNT_AMOUNT,
    ITEM_TAX_AMOUNT,
    NET_ITEM_SALES_AMOUNT
  FROM aggregate_1
), join_1 AS (
  SELECT
    *
  FROM rename_1
  JOIN rename_2
    ON rename_1.ORDERS_ORDER_KEY = rename_2.ORDER_ITEM_SUMMARY_ORDER_KEY
), formula_1 AS (
  SELECT
    *,
    1 AS ORDER_COUNT
  FROM join_1
), rename_3 AS (
  SELECT
    ORDERS_ORDER_KEY AS ORDER_KEY,
    ORDER_DATE,
    CUSTOMER_KEY,
    STATUS_CODE,
    PRIORITY_CODE,
    CLERK_NAME,
    SHIP_PRIORITY,
    ORDER_COUNT,
    GROSS_ITEM_SALES_AMOUNT,
    ITEM_DISCOUNT_AMOUNT,
    ITEM_TAX_AMOUNT,
    NET_ITEM_SALES_AMOUNT
  FROM formula_1
), order_1 AS (
  SELECT
    *
  FROM rename_3
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