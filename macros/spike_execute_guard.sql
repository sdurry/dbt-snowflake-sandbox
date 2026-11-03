{% macro spike_execute_check() %}
    {% if execute %}
        {% set query %}
            select current_timestamp() as ts, 'run_query_fired' as status
        {% endset %}
        {% set results = run_query(query) %}
        {% do log("SPIKE: execute=True — run_query fired during this phase", info=True) %}
        {{ return("execute_was_true") }}
    {% else %}
        {% do log("SPIKE: execute=False — run_query skipped", info=True) %}
        {{ return("execute_was_false") }}
    {% endif %}
{% endmacro %}
