---
name: cost-and-health-sweep
description: >-
  Audits this dbt project (or a selection) for cost, performance, and health
  problems, then proposes concrete, safe fixes. Composes the dbt MCP
  performance/health tools with each model's materialization and clustering
  config to rank findings by impact. Use when the user asks to speed up a
  slow model, cut warehouse spend, find stale/failing/untested models, review
  materialization or clustering strategy, or do a general "health check" of
  the project. Read-only by default — it recommends, it does not rewrite
  models unless explicitly told to.
---

# Cost & health sweep

A pre-flight auditor for a dbt project running on Snowflake. It answers three
questions: **what's slow, what's expensive, and what's unhealthy** — and for
each finding proposes a specific fix grounded in the model's current config.

This goes beyond the stock dbt skills: it doesn't build or run a single model,
it *reasons across the whole graph* using the MCP discovery tools plus the
project's governance/materialization settings.

## When to use

Triggers: "why is this model slow", "our Snowflake bill went up", "find stale
/ failing / untested models", "should this be incremental", "is clustering
helping here", "do a health check on the project", "which models are worth
optimizing".

Not for: answering business questions (use
`answering-natural-language-questions-with-dbt`), building models
(`using-dbt-for-analytics-engineering`), or diagnosing a specific failed job
run (`troubleshooting-dbt-job-errors`).

## Tools this skill uses

All via the `dbt-snowflake-sandbox` MCP server:

- `get_all_models` / `get_mart_models` — enumerate scope.
- `get_model_performance` — execution time and run history per model.
- `get_model_health` — freshness, test coverage, last-run status, errors.
- `get_model_details` — materialization, tags, config, compiled SQL.
- `get_model_children` / `get_lineage` — how often a model is depended on (blast
  radius = how much a fix pays off).
- `list_jobs_runs` / `get_job_run_details` — corroborate timing with real run data.

## Workflow

1. **Scope.** Default to marts + staging. If the user names a model or a
   `dbt` selector, restrict to it (plus its ancestors for context). Confirm scope
   before a full-project sweep — it can be a lot of tool calls.

2. **Gather signals** (batch the read-only calls in parallel where possible):
   - Performance: `get_model_performance` for run duration and trend.
   - Health: `get_model_health` for stale/errored/untested/warning states.
   - Config: `get_model_details` for `materialized`, `tags`, incremental
     settings, and whether `automatic_clustering` applies.
   - Usage: `get_model_children` — a slow model with 20 dependents is a far
     better optimization target than an equally slow leaf.

3. **Cross-reference against this repo's known config** (`dbt_project.yml`):
   - `staging` is `view`; `marts/core` is `table`; `automatic_clustering: true`
     is set project-wide; the warehouse resizes small→xsmall around runs.
   - So flag mismatches against these defaults, not against a generic baseline.

4. **Apply the heuristics** (below) to turn raw signals into findings.

5. **Rank** findings by `impact = cost-or-time-saved × how-often-it-runs / effort`,
   most valuable first.

6. **Report**, don't rewrite. Emit the report format below. Only edit a model
   if the user explicitly asks — and even then, materialization strategy is a
   human-owned decision per `AGENTS.md`, so surface the trade-off and get a nod
   first.

## Heuristics

**Cost / performance**
- Full-refresh `table` model that is large, append-mostly, and has a natural
  event date (e.g. `fct_orders` on `order_date`) → candidate for **incremental**.
- Expensive transform materialized as a `view` but queried repeatedly by many
  children → candidate for `table` (or a materialized view).
- `automatic_clustering: true` on a **small** table → wasted reclustering spend;
  recommend disabling clustering for that model.
- Large, consistently **filtered/joined** table missing a useful cluster key →
  recommend a clustering key aligned to the common filter column.
- A model whose runtime dominates the critical path (long chain of children) →
  optimize here first.

**Health**
- Stale beyond its expected cadence, or last run **errored/warned**.
- **No tests** on a mart or on any primary/foreign key — flag; a PK needs
  `unique` + `not_null` per project convention.
- Contracted model (e.g. core dims) whose columns/types drift from the enforced
  contract.
- Orphaned model: no children and no exposure → possible dead model, flag for
  review (don't auto-delete).

## Report format

```
# Cost & health sweep — <scope>  (<date>)

## Top findings (ranked)
1. <model>  [cost | perf | health]  impact: <high/med/low>
   Signal:   <e.g. 42s full-refresh, 6 dependents, runs 4×/day>
   Fix:      <specific, e.g. switch to incremental on order_date>
   Trade-off:<what to watch, e.g. late-arriving records, backfill needed>

## Health issues
- <model>: <stale | errored | untested | contract drift> — <action>

## Quick wins (low effort)
- <model>: <e.g. drop clustering on small dim, saves reclustering cost>

## Not worth it (checked, leave alone)
- <model>: <why it's fine>
```

Always include the "leave alone" section — telling the user what *not* to
touch is as valuable as the fixes, and it shows the sweep was thorough.

## Guardrails

- Read-first. Never change materialization, clustering, or config without
  explicit sign-off; these are architecture decisions humans own.
- Validate column/table names via MCP against the real relation before
  suggesting a cluster key or incremental predicate — don't infer them.
- Quantify claims where you can (seconds, run frequency, dependent count).
  "This looks slow" is not a finding; "42s, 4×/day, 6 dependents" is.
