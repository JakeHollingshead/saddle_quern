---
name: quern-deep
description: Review cross-component behavior, architecture, concurrency, and recovery with saddle_quern.
---

# Deep review

Read [the agent rules](../../AGENTS.md) and use their output structure, source snapshot, and seven baselines. Keep the reviewed code read-only. Create only Markdown files. Ask for the product name only if the user has not supplied it.

Follow the affected flow across components. Check compatibility, ownership, interrupted writes, retries, and competing workers. Map shared state producers and consumers. Add regression cases for the critical transitions and interleavings.

While reading, build the run-specific regression record using [the regression template](../../regression_testing.md). Record expected behavior, evidence, and execution status. Never mark an unrun check as passed. Keep findings in Bread and end with the agent-required evaluation.
