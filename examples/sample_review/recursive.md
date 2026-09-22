# recursive.md — Toy Stock Demo

This is a worked example, checked into the repository so a reader can see the shape of a saddle_quern report before running one for real. It reviews the small fixture at [examples/toy_repo/](../toy_repo/) under [quern-standard](../../skills/quern-standard/SKILL.md). Every SHA-256, line citation, and regression-record result below was computed or executed for real against that fixture — see the [CONTRIBUTING.md](../../CONTRIBUTING.md#testing-a-change) note on keeping it that way after an edit.

**Product:** Toy Stock Demo. **Source path:** `examples/toy_repo/`. **Scope:** all four files in the manifest — `inventory.py`, `main.py`, `report.py`, `stock.csv`. **Output location:** `examples/sample_review/`, outside the reviewed source tree.

## Index

- [Products — classes](#products--classes)
- [Ingredients — methods](#ingredients--methods)
- [Bread — the product](#bread--the-product)
- Evidence: [SHA-256 snapshot](outputs/sha256_snapshot_001.md) · [Function measurements](outputs/function_measurements_001.md) · [Loop ceilings](outputs/loop_ceilings_001.md) · [Error handling](outputs/error_handling_001.md) · [Function calls](outputs/function_calls_001.md) · [Regression record](outputs/regression_testing_001.md) · [Story](story.md)

## Products — classes

One first-party class: `Inventory` (inventory.py:4-44).

- **Role:** an in-memory stock tracker for a small shop.
- **State:** a single dict, `self._counts`, mapping SKU to count.
- **Dependencies:** none external; the `supplier` parameter of `try_restock_from_supplier` is an unresolved external dependency (PROC-02), not a class dependency.
- **Promised output:** the current count for a SKU after a mutation, or `None`/a raised exception on failure — see [Ingredients](#ingredients--methods) for which.

Two free functions substitute for a second and third class here: `format_low_stock` (report.py:4-11) and `main` (main.py:12-19). Neither owns state; see the [SHA-256 quick snapshot](outputs/sha256_snapshot_001.md) for the manifest this inventory was built from.

## Ingredients — methods

Six methods on `Inventory`, plus the two free functions, were traced from input to output, call, state change, and error path. The full measurements — length, nesting, assertion count — are in [function_measurements_001.md](outputs/function_measurements_001.md); the call graph and side-effect table are in [function_calls_001.md](outputs/function_calls_001.md); loop bounds are in [loop_ceilings_001.md](outputs/loop_ceilings_001.md); exception handling is in [error_handling_001.md](outputs/error_handling_001.md).

In short: `__init__` and `format_low_stock` hold up under CODE-05; `restock`, `sell`, `load_counts_from_file`, `drain_until_empty`, and `try_restock_from_supplier` do not. `sell` alone fails CODE-01. `load_counts_from_file` fails CODE-03. `try_restock_from_supplier` fails CODE-06. Both loops in the manifest fail CODE-02, and one of the two is a confirmed hang, not a hypothesis — see [regression_testing_001.md](outputs/regression_testing_001.md) for the executed evidence behind every one of those claims.

The [run-specific regression record](outputs/regression_testing_001.md) was built case by case while these methods were read, per PROC-13, and distinguishes the four executed passes, five executed failures, and one blocked check from any notion of a historical baseline — there isn't one for a first run.

## Bread — the product

A clerk runs one script. It loads stock from a file, sells a fixed order, and prints what's low. It works on a clean file and a normal order; it stops working — with a hang, a silent no-op, a leaked handle, or a raw traceback — on five specific, demonstrated inputs.

Full findings, severity, evidence, and the standards evaluation: [bread_001.md](outputs/bread_001.md). The user's path through both the shipped script and the class's unreached public methods: [story.md](story.md).
