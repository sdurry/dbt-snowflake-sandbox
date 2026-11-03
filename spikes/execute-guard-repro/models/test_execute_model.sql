{% set result = test_execute_guard() %}

-- compile this model and watch the log output.
-- Expected in BOTH dbt Core v1 (tested: 1.12.3) and dbt Fusion v2 (tested: 2.0.9):
--   Parse phase:   "execute=False: run_query skipped"
--   Compile phase: "execute=True: run_query fired"
-- The if-execute guard only blocks parse-time execution, not compile-time.
-- The compiled value of execute_check_result below shows which branch ran.

select
    1                as test_id,
    '{{ result }}'   as execute_check_result
