# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a dbt project for Snowflake using the TPCH sample dataset. The project name is `stephans_snow_sandbox` and uses the `tpch` profile.

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

### Key Configurations

- Warehouse auto-scales: `small` during runs, `xsmall` otherwise (see `on-run-start`/`on-run-end`)
- `static_analysis` controlled via `DBT_STATIC_ANALYSIS` env var
- Groups: `data_engineering` for staging, `bi_team` for marts
- Unit tests defined in `models/marts/intermediate/int_unit_tests.yml`

### Targets

- `dev` - SDURRY_DEV database, dbt_sdurry schema
- `uat` - SDURRY_UAT database, analytics schema

## External Packages

- dbt_utils (1.3.3)
- codegen (0.14.0)
- dbt_expectations (0.10.10)
