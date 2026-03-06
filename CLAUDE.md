# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dbt project for Snowflake using the TPCH sample dataset. The project name is `stephans_snow_sandbox` and uses the `tpch` profile.

`dbtf` is an alias for `~/.local/bin/dbt` — always use `dbtf` for dbt commands, not `dbt`.

## Common Commands

```bash
# Run all models
dbtf run

# Run specific model
dbtf run --select model_name

# Run models and their downstream dependencies
dbtf run --select model_name+

# Run tests
dbtf test

# Run tests for a specific model
dbtf test --select model_name

# Run unit tests only
dbtf test --select test_type:unit

# Preview model results (no materialization)
dbtf show --select model_name --limit 10

# Generate and serve documentation
dbt docs generate && dbt docs serve

# Install dependencies
dbtf deps

# Compile models (useful for debugging SQL)
dbtf compile --select model_name
```

## Architecture

### Data Flow
Sources (RAW.TPCH_SF001) → Staging → Intermediate → Marts (Core)

### Model Layers

- **staging/** - Light transformations from raw sources. Materialized as views. Contains `tpch` (internal sources) and `tpch_external` (external sources).
- **marts/intermediate/** - Business logic transformations (e.g., `order_items`, `part_suppliers`). Joins staging models and calculates derived fields.
- **marts/core/** - Final dimension and fact tables. Materialized as tables. Contains `dim_*` (customers, parts, suppliers) and `fct_*` (orders, order_items).
- **utils/** - Supporting models not in the main DAG (e.g., `all_days` date spine used by the Semantic Layer).
- **viz/** - Exposures only (`exposures.yml`), no SQL models.

### Other Directories

- **snapshots/** - SCD Type 2 snapshots (e.g., `snap_customers.sql`). Schema is `snaps` in prod, otherwise `target.schema`.
- **data/** - Seeds (e.g., `snowflake_contract_rates.csv`). The `effective_date` column is typed as `DATE`, `rate` as `NUMBER`.
- **tests/** - Singular data tests (e.g., `stg_tpch_orders_assert_positive_price.sql`).
- **macros/** - Custom macros including `limit_data_in_dev` (adds a `WHERE` clause in dev to limit lookback), `cents_to_dollars`, `create_udfs` (run on-run-start), and `grant_all_on_schemas`.

### Key Configurations

- Warehouse auto-scales: `small` during runs, `xsmall` otherwise (see `on-run-start`/`on-run-end`)
- `static_analysis` controlled via `DBT_STATIC_ANALYSIS` env var; individual models can override with `{{ config(static_analysis='off') }}`
- Groups: `data_engineering` for staging, `bi_team` for marts
- Unit tests defined in `models/marts/intermediate/int_unit_tests.yml`
- `limit_data_in_dev` macro: use in staging/intermediate models to restrict rows in dev target only

### Project Variables

- `start_date` - Default `'1999-01-01'`, used to filter historical data
- `test` - Set to `'true'` to enable unit test mode (swaps model refs for mock sources)
- `fct_order_items` - Points to `mock_source__fct_order_items` when in test mode
- `dbt_metrics_calendar_model` - Set to `all_days` (the date spine in `utils/`)

### Targets

- `dev` - SDURRY_DEV database, dbt_sdurry schema
- `uat` - SDURRY_UAT database, analytics schema

## External Packages

- dbt_utils (1.3.3)
- codegen (0.14.0)
- dbt_expectations (0.10.10)
