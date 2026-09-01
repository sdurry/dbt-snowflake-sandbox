@AGENTS.md

## The `dbt-wizard` subagent

`.claude/agents/dbt-wizard.md` defines a subagent that delegates to **wizard**,
dbt Labs' standalone terminal agent. Wizard has a native dbt metadata engine —
it reads the manifest, the DAG, and run artifacts directly — so it answers
project-shaped questions that generic code search handles badly.

**Use it for:**
- Lineage and impact analysis ("what breaks if I change `stg_tpch_orders`?")
- Test and documentation coverage gaps
- Source freshness and model health
- Debugging failed dbt runs
- Reviewing dbt changes for correctness (`wizard review --uncommitted` / `--base <ref>`)

**Read the project directly instead when** the question is about file text, SQL
style, or a single model you already know the path to. Spawning a subagent to
read one file is slower than reading it.

**Auth:** wizard authenticates via `wizard login` against the dbt-routed provider
on `dbt/glm-5.2`. There are **no API keys** — do not add `ANTHROPIC_API_KEY`,
`OPENAI_API_KEY`, or any provider key to this project. If wizard fails on auth,
re-authenticating is an **interactive step a human must run** in their own
terminal; agents must not attempt it.

The subagent defaults to read-only `wizard exec` and escalates to
`-s workspace-write` only when a task genuinely requires writing files or running
dbt commands.
