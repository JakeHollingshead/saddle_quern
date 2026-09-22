---
name: quern-deps
description: Review dependency, license, and supply-chain risk with saddle_quern.
---

# Deps review

Read [the agent rules](../../AGENTS.md) and use their output structure, source snapshot, and seven baselines. Keep the reviewed code read-only. Create only Markdown files. Ask for the product name only if the user has not supplied it.

Inventory declared dependencies from manifest and lock files. Record each dependency's declared version range, resolved version when a lock file pins one, and license when stated in the manifest, lock file, or package metadata present in the source tree. Flag unpinned or wide version ranges, dependencies with no lock entry, and licenses that are missing, incompatible with the product's own license, or copyleft where the product is proprietary. Do not query package registries or fetch license text from the network; cite only what the reviewed source tree contains, and mark anything else unverified. Trace how a vulnerable or unmaintained dependency's code is actually reached before calling it a live risk; an unused import is a smaller finding than a dependency on the main path. Add regression cases for missing locks, license conflicts, and unreachable-vs-reachable dependency code.

While reading, build the run-specific regression record using [the regression template](../../regression_testing.md). Record expected behavior, evidence, and execution status. Never mark an unrun check as passed. Keep findings in Bread and end with the agent-required evaluation.
