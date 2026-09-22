---
name: quern-perform
description: Review algorithms, queries, resource usage, caching, and bottlenecks with saddle_quern.
---

# Perform review

Read [the agent rules](../../AGENTS.md) and use their output structure, source snapshot, and seven baselines. Keep the reviewed code read-only. Create only Markdown files. Ask for the product name only if the user has not supplied it.

Identify input growth, repeated work, query volume, and resource lifetime. Trace enforced bounds. Separate measured cost from a hypothesis. Use bounded in-memory measurements when safe. Add regression cases with stated workloads and justified budgets; do not invent performance thresholds.

While reading, build the run-specific regression record using [the regression template](../../regression_testing.md). Record expected behavior, evidence, and execution status. Never mark an unrun check as passed. Keep findings in Bread and end with the agent-required evaluation.
