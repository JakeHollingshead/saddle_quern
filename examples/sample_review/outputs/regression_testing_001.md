# Regression testing — run 001

[Purpose](#purpose) · [Run record](#run-record) · [Case record](#case-record) · [Results](#results)

[Back to recursive.md](../recursive.md)

## Purpose

This is a completed regression record for the saddle_quern worked example, built from [the regression template](../../../regression_testing.md) while reading `examples/toy_repo/`. Unlike the template itself, every case below was actually executed or explicitly marked otherwise — see [Results](#results).

## Run record

- **Product:** Toy Stock Demo
- **Source root:** `examples/toy_repo/`
- **Revision:** untracked working copy (see [sha256_snapshot_001.md](sha256_snapshot_001.md))
- **Manifest digest:** `58d48d252f63ae1552dfc909f67073c439678a60b26ac5b75d8fdbe24ea9852c`
- **Review mode:** quern-standard
- **Environment:** Python 3.13.14, executed locally with `PYTHONDONTWRITEBYTECODE=1` to keep implicit imports from writing cache files, per FS-01.
- **Scope:** all four files in the manifest.
- **Baseline:** none. This is the first run against this fixture; no earlier pass/fail history exists, so no finding below is a proven regression — each is a current defect.

## Case record

| ID | Behavior / symbol | Expected result (source) | Layer | State | Outcome | Actual result |
|---|---|---|---|---|---|---|
| REG-01 | `Inventory.sell` success path | Decrements stock and returns the new count (inventory.py:21-22) | extracted function | executed | pass | `sell('widget', 3)` on `{'widget': 10}` returned `7`; `_counts` became `{'widget': 7}` |
| REG-02 | `Inventory.sell` insufficient stock | Returns `None` without mutating state (inventory.py:23) | extracted function | executed | pass | `sell('widget', 5)` on `{'widget': 2}` returned `None`; `_counts` unchanged |
| REG-03 | `Inventory.sell` unknown SKU | Returns `None` (inventory.py:23) — same value as REG-02 | extracted function | executed | pass | `sell('unknown-sku', 1)` returned `None`, indistinguishable from REG-02's result. Not a code fault by itself; flagged in Bread as a design gap since both failure reasons collapse to one signal |
| REG-04 | `Inventory.drain_until_empty` with `batch_size <= 0` | Undocumented; inferred intent is "reach zero and stop" | extracted function | executed | **fail** | `drain_until_empty('widget', 0)` on a positive count did not return within 2 seconds (`timeout 2`, exit 124) — confirmed non-terminating |
| REG-05 | `Inventory.try_restock_from_supplier` on a failing supplier | Undocumented; a failed shipment should not restock silently (inferred from function name) | extracted function | executed | **fail** | A supplier whose `ship()` raised `ConnectionError` produced no exception and no state change; the failure was silently discarded |
| REG-06 | `Inventory.load_counts_from_file` on a malformed line | Undocumented; the file handle opened at inventory.py:26 should close on every path | extracted function | executed | **fail** | A malformed CSV line raised `ValueError` from inventory.py:29; `gc.get_objects()` immediately after showed the file object still open (`closed == False`) |
| REG-07 | `main.py` invoked with no CLI argument | Undocumented; a CLI entry point should not crash with a raw traceback on missing input | integration (subprocess) | executed | **fail** | `python main.py` with no arguments raised `IndexError` from main.py:23 and exited 1 with a full traceback printed to the user |
| REG-08 | `format_low_stock` on both branches | Returns a formatted low-stock list, or the healthy-stock message (report.py:9-11) | extracted function | executed | pass | `{'a': 1, 'b': 9}` at threshold 5 produced `"Low stock:\na: 1 left"`; `{'a': 9}` at threshold 5 produced `"All stock levels are healthy."` |
| REG-09 | CODE-07 — zero compiler/runtime warnings | AGENTS.md CODE-07 | source trace / compile | blocked | unverified | `python -m py_compile` reported no warnings and exit code 0, but it wrote `__pycache__/*.pyc` regardless of `PYTHONDONTWRITEBYTECODE`, violating FS-01 — the cache was deleted immediately after and the check is not counted as run. A cache-free `ast.parse()` of all three modules found no `SyntaxError`, which is recorded but is a weaker check than a real compiler/lint pass |
| REG-10 | `main` reaching into `Inventory._counts` directly (main.py:19) | Undocumented; expected a public accessor instead of a private-by-convention attribute | source trace | executed | **fail** | Confirmed by direct source inspection: no `get_counts`-style method exists on `Inventory`; `main.py:19` is the only read of stock state and it reaches past the class boundary |

## Results

- **Executed:** 9 of 10 cases (REG-01 through REG-08, REG-10).
- **Blocked:** 1 (REG-09 — full compiler/warning check blocked by the FS-01 no-bytecode boundary; a weaker cache-free substitute was executed instead and is recorded above, not substituted as a pass).
- **Pass:** 4 (REG-01, REG-02, REG-03, REG-08).
- **Fail:** 5 (REG-04, REG-05, REG-06, REG-07, REG-10).
- **Unverified:** 1 (REG-09, for the reason stated in its row).
- **Historical baseline:** none exists for this fixture, so none of the failing cases above are labeled a "regression" — they are first-observation defects. A future rerun against a fix would compare against this run's results as the baseline.
- **Concurrent consumers:** not applicable. Nothing in this fixture is shared across threads or processes.
- **Uncovered paths:** `Inventory.restock` and `Inventory.try_restock_from_supplier`'s success path are covered only by source trace, not by a dedicated executed case beyond REG-05's failure path; `Inventory.drain_until_empty`'s terminating case (`batch_size > 0`) was not executed, only the non-terminating case.

Confirmed findings mapped from these cases, with severity and corrective direction, are in [bread_001.md](bread_001.md).
