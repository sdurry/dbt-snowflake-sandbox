{% macro test_execute_guard() %}
    {% if execute %}
        {% set query %}
            select current_timestamp() as ts, 'run_query_fired' as status
        {% endset %}
        {% set results = run_query(query) %}
        {% do log("REPRO execute=True: run_query fired — timestamp=" ~ results.columns[0].values()[0], info=True) %}
        {{ return("execute_was_true") }}
    {% else %}
        {% do log("REPRO execute=False: run_query skipped", info=True) %}
        {{ return("execute_was_false") }}
    {% endif %}
{% endmacro %}
