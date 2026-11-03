# execute-guard repro

Minimal dbt project reproducing the `{% if execute %}` / `run_query()` / `is_incremental()`
compile-time behavior reported in support ticket #139016 / #139823.

## The finding

`{% if execute %}` guards against *parse*-time execution only. During `dbt compile`
`execute` is `True`, so `run_query()` fires — **in both dbt Core v1 and dbt Fusion v2**.

The additional factor that explains the customer's experience: `run_query()` is typically
called only when `is_incremental()` is also `True`. That means:

| When does `run_query()` fire during `dbt compile`? | |
|---|---|
| Model is **new** (relation doesn't exist yet) | **No** — `is_incremental()=False` |
| Model **already exists** (subsequent incremental compile) | **Yes** — `is_incremental()=True` |

This is why the customer's full-refresh run was safe but a later compile triggered DML.
With Defer to Prod enabled, that DML targeted the production relation.

## Setup

1. Fill in your Snowflake credentials in `profiles.yml` (update profile name to `tpch` or set `profile: repro` in `dbt_project.yml`).
2. No external packages required.

## Test 1 — unconditional execute check

```bash
dbt compile --select test_execute_model
```

Expected log output:
```
REPRO execute=False: run_query skipped          ← parse phase
REPRO execute=True: run_query fired — timestamp=…  ← compile phase
```
Compiled SQL: `'execute_was_true'`

## Test 2 — is_incremental() + execute (Mario's scenario)

```bash
# Step 1: compile before the relation exists
dbt compile --select test_execute_incremental
# → is_incremental=False, run_query skipped — safe

# Step 2: create the relation
dbt run --select test_execute_incremental

# Step 3: compile again — now the relation exists
dbt compile --select test_execute_incremental
# → is_incremental=True, run_query FIRES during compile
```

## Tested versions

| Version | execute during parse | execute during compile | run_query fires (new model) | run_query fires (relation exists) |
|---|---|---|---|---|
| dbt Core 1.12.3 | False | **True** | No | **Yes** |
| dbt Fusion 2.0.9 | False | **True** | No | **Yes** |

**Behavior is identical across versions.** This is not a v2 regression.

## Workaround

Check the active command explicitly:

```jinja
{% if execute and flags.WHICH_COMMAND in ('run', 'build') %}
    {% do run_query(dml_statement) %}
{% endif %}
```
