{% macro test_execute_incremental_guard() %}
    {% if execute %}
        {% if is_incremental() %}
            {% set query %}
                select current_timestamp() as ts, 'incremental_run_query_fired' as status
            {% endset %}
            {% set results = run_query(query) %}
            {% do log("REPRO is_incremental=True, execute=True: run_query fired — timestamp=" ~ results.columns[0].values()[0], info=True) %}
            {{ return("incremental_and_execute_true") }}
        {% else %}
            {% do log("REPRO is_incremental=False, execute=True: run_query skipped (new/full-refresh path)", info=True) %}
            {{ return("new_model_no_run_query") }}
        {% endif %}
    {% else %}
        {% do log("REPRO execute=False: parse phase, run_query skipped", info=True) %}
        {{ return("execute_was_false") }}
    {% endif %}
{% endmacro %}
