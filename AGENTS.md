# AGENTS.md

Onboarding for AI agents (and humans) working in this dbt project. Read this
before editing models, tests, or YAML. It describes how *this* project is
actually laid out — not the textbook ideal.

## What this project is

- A Snowflake dbt sandbox (`stephans_snow_sandbox`, profile `tpch`) built on the
  Snowflake **TPCH** sample dataset. It emulates a production analytics project.
- Warehouse: `TRANSFORMING`. Databases per target: `SDURRY_DEV` (dev),
  `SDURRY_UAT` (uat). `on-run-start`/`on-run-end` resize the warehouse small → xsmall.
- Packages in use: `dbt_utils`, `dbt_expectations`, `codegen`, `dbt_date`.

## Layers and where things live

Data flows **staging → intermediate → marts**, plus a few support folders.

```
models/
├── staging/            # 1:1 with sources, light renaming/casting. Materialized as views.
│   ├── tpch/           # core TPCH source: customers, orders, line_items, parts, ...
│   └── tpch_external/  # a separately-loaded external source
├── marts/
│   ├── intermediate/   # reusable joins/reshaping between staging and marts
│   └── core/           # business-facing dims + facts. Materialized as tables.
├── semantic_datasets/  # semantic-layer models (sem_*.yml)
├── utils/              # date spine helpers (dim_date, all_days)
└── viz/                # exposures.yml (downstream BI dependencies)
```

Config lives in `dbt_project.yml`:
- `staging` → group `data_engineering`, materialized `view`.
- `marts/core` → group `bi_team`, materialized `table`.
- Project-wide: `persist_docs`, `automatic_clustering`, `copy_grants`,
  `select` grant to `transformer`, `query_tag: stephan-sandbox`, `static_analysis: strict`.

## Naming conventions

**Heads-up: naming is not uniform in this repo. Match the folder you're working in.**

| Layer / thing | Pattern in this repo | Example |
|---|---|---|
| Staging (tpch) | `stg_tpch_<entity>` (single underscore) | `stg_tpch_orders.sql` |
| Staging (tpch_external) | `stg_<source>__<entity>` (double underscore) | `stg_tpch_external__orders.sql` |
| Intermediate | plain business name, **no `int_` prefix** | `order_items.sql`, `part_suppliers.sql` |
| Dimensions | `dim_<entity>` | `dim_customers.sql` |
| Facts | `fct_<entity>` | `fct_orders.sql` |
| Semantic models | `sem_<entity>` | `sem_orders.yml` |

The `stg_<source>__<entity>` double-underscore form is the dbt-recommended
convention. When adding **new** staging models, prefer that form. Do not
rename existing models to "fix" the style unless explicitly asked — renames
break `ref()`s, exposures, and downstream tooling.

- Columns and identifiers: lowercase `snake_case`.
- Staging renames raw source columns to friendly names (e.g. `o_orderkey → order_key`).

## SQL style

Follow the pattern already in the files you edit:

- **Staging** uses a CTE chain: `source` → `renamed` → final `select * from renamed`.
  `source` selects `* from {{ source(...) }}`; `renamed` does the aliasing/casting.
- **Marts/intermediate** use named CTEs ending in a `final` CTE, then `select from final`.
- Reference upstream models with `ref()` and raw tables with `source()` — never
  hardcode a database/schema/table name.
- One column per line in `select` lists; alias every table in a join; join
  conditions are explicit (`on a.key = b.key`).
- Prefer CTEs over nested subqueries.

## Macros

Project macros live in `macros/`. Reuse them instead of re-implementing:
- `cents_to_dollars(column, precision=2)` — uniform money cast.
- `convert_money(...)`, `standard_account_fields(...)`.

## Testing

- Standard schema tests: `unique`, `not_null`, `accepted_values` (in the model's `.yml`).
- `dbt_expectations` is available for richer data tests.
- Singular tests live in `tests/` (e.g. `stg_tpch_orders_assert_positive_price.sql`).
- Unit tests are defined in `models/marts/intermediate/int_unit_tests.yml`.
- **New or changed models should ship with tests and column descriptions.** At
  minimum, a primary key needs `unique` + `not_null`.

## Contracts, groups, and the semantic layer

- Core dims enforce **model contracts** (`contract.enforced: true`) with declared
  `data_type`s and `constraints` (e.g. `dim_customers` has a `primary_key`). If you
  change a contracted model's columns/types, update the contract in the same edit
  or the build fails.
- Models belong to **groups** (`data_engineering`, `bi_team`) defined in
  `models/marts/_groups.yml`.
- Semantic models, entities, dimensions, and metrics are defined in the model
  `.yml` files (see `dim_customers.yml`) and `semantic_datasets/`. When you add a
  dimension/measure to a model, wire it into the semantic config too.

## Working with the warehouse (use the MCP server)

This project is connected to the **dbt MCP server** (`dbt-snowflake-sandbox`).
Prefer it over guessing — it lets you compile/run/test against the real schema and
avoids hallucinated table or column names. Useful moves:
- `compile` / `parse` a model before claiming it's valid.
- `run` / `build` / `test` a selection to verify changes.
- `get_model_details`, `get_all_sources`, `get_lineage`, `get_model_children`
  to understand dependencies before editing.
- Validate column names against the actual relation rather than inferring them.

Common CLI equivalents:
```
dbt build --select <model>          # run + test a model and its tests
dbt run  --select <model>+          # model and everything downstream
dbt test --select <model>
dbt compile --select <model>        # inspect generated SQL
```

## Guardrails

- **Don't hardcode secrets or connections.** `profiles.yml` in this sandbox
  contains plaintext credentials — do not copy that pattern into new files, and
  do not commit real credentials.
- Don't rename existing models/columns to match a style guide unless asked;
  correctness of `ref()`/exposure/contract links comes first.
- Humans own materialization strategy, business modeling, and architecture.
  Agents should handle the repetitive, rule-based work: naming, tests,
  descriptions, formatting, and boilerplate.
