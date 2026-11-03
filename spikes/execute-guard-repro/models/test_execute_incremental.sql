{{ config(materialized='incremental') }}

{% set result = test_execute_incremental_guard() %}

-- This model tests the combination Mario described:
-- run_query() is only called on incremental runs (is_incremental()=True),
-- not on full refresh or new models.
--
-- Compile BEFORE the relation exists → is_incremental()=False → run_query skipped
-- Compile AFTER dbt run (relation exists) → is_incremental()=True → run_query fires?

select
    1                as test_id,
    '{{ result }}'   as execute_check_result
