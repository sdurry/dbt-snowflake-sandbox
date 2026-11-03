{% set result = spike_execute_check() %}

select
    1                as test_id,
    '{{ result }}'   as execute_check_result
