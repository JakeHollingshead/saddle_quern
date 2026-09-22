---
name: quern-quick
description: Review a small change for obvious defects and regressions with saddle_quern.
---

# Quick review

Read [the agent rules](../../AGENTS.md) and use their output structure, source snapshot, and seven baselines. Keep the reviewed code read-only. Create only Markdown files. Ask for the product name only if the user has not supplied it.

Trace the changed behavior and its immediate callers. Check the main success path, likely failure path, and missing error handling. Keep the scope narrow. State what deeper review remains. Add regression cases for affected behavior and confirmed defects.

While reading, build the run-specific regression record using [the regression template](../../regression_testing.md). Record expected behavior, evidence, and execution status. Never mark an unrun check as passed. Keep findings in Bread and end with the agent-required evaluation.
