---
name: quern-test
description: Review test quality and regression coverage with saddle_quern.
---

# Test review

Read [the agent rules](../../AGENTS.md) and use their output structure, source snapshot, and seven baselines. Keep the reviewed code read-only. Create only Markdown files. Ask for the product name only if the user has not supplied it.

Map existing tests to user behavior and failure paths. Check that assertions catch a real change in behavior. Inspect fixture side effects before running anything. Identify missing boundary, retry, recovery, and visual checks. Build the regression record and run only permitted checks. Do not equate test discovery with execution.

While reading, build the run-specific regression record using [the regression template](../../regression_testing.md). Record expected behavior, evidence, and execution status. Never mark an unrun check as passed. Keep findings in Bread and end with the agent-required evaluation.
