---
name: quern-standard
description: Perform the default saddle_quern review of correctness, dependencies, edge cases, and test coverage.
---

# Standard review

Read [the agent rules](../../AGENTS.md) and use their output structure, source snapshot, and seven baselines. Keep the reviewed code read-only. Create only Markdown files. Ask for the product name only if the user has not supplied it.

Trace inputs through callers, shared helpers, state changes, and outputs. Check boundary inputs, failure recovery, and existing tests. Add regression cases for the main path and meaningful failure branches.

While reading, build the run-specific regression record using [the regression template](../../regression_testing.md). Record expected behavior, evidence, and execution status. Never mark an unrun check as passed. Keep findings in Bread and end with the agent-required evaluation.
