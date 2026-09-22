---
name: quern-sec
description: Review trust boundaries, access control, input validation, and sensitive data with saddle_quern.
---

# Sec review

Read [the agent rules](../../AGENTS.md) and use their output structure, source snapshot, and seven baselines. Keep the reviewed code read-only. Create only Markdown files. Ask for the product name only if the user has not supplied it.

Trace untrusted input to privileged actions and sensitive outputs. Check identity, authorization, session state, and validation. Challenge safety claims with bounded counterexamples. Do not expose secrets or probe live services. Add regression cases for denied access and invalid inputs. Mark unverified dependency risks as such.

While reading, build the run-specific regression record using [the regression template](../../regression_testing.md). Record expected behavior, evidence, and execution status. Never mark an unrun check as passed. Keep findings in Bread and end with the agent-required evaluation.
