# Regression testing

[Purpose](#purpose) · [Run record](#run-record) · [Case record](#case-record) · [Results](#results)

## Purpose

This is the agent's reusable template. It is not a completed product test report. No tests have run in this document.

For each review, create `outputs/regression_testing_<run>.md` outside the source tree. Use the same run suffix and source-manifest SHA-256 as the review. Link it from recursive.md. Build it as code is read, not only after findings are written. Preserve previous runs.

## Run record

Record the user-supplied product name, source root, revision, manifest digest, snapshot link, review mode, environment, scope, and baseline. If no earlier baseline exists, say so. A current defect is not a proven regression without evidence that it previously worked.

## Case record

Give each case a stable ID. Record:

- Behavior and source symbol or user-story step.
- Expected result and its source. Mark uncertain expectations for clarification.
- Preconditions, synthetic inputs, and repeatable steps.
- Existing test reference or proposed check. Link the related finding when present.
- Layer: source trace, extracted function, integration, rendered UI, or native control.
- State: planned, executed, skipped, or blocked.
- Outcome: unverified, pass, or fail. Only executed checks receive pass or fail.
- Actual result, command or in-memory probe method, environment, and limits.

Include relevant success, boundary, failure, retry, and recovery cases. Check concurrent consumers and visible UI when those behaviors exist. Do not add irrelevant cases to fill a checklist. Distinguish observed code behavior from the intended contract.

## Results

Summarize case counts by state and outcome. Separate historical results from this run. Map confirmed defects to regression cases. Record uncovered paths and blocked checks. A source trace is not a passing runtime test.

Before execution, inspect imports, fixtures, plugins, and cleanup for side effects. Use read-only or in-memory checks. Do not write test code, databases, caches, logs, screenshots, or other non-Markdown artifacts. Do not contact real providers or alter services. If a check cannot obey AGENTS.md, record the limit and leave it unverified.
