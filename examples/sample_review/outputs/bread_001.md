# Bread — Toy Stock Demo, run 001

[Back to recursive.md](../recursive.md) · [SHA-256 snapshot](sha256_snapshot_001.md) · [Function measurements](function_measurements_001.md) · [Loop ceilings](loop_ceilings_001.md) · [Error handling](error_handling_001.md) · [Function calls](function_calls_001.md) · [Regression record](regression_testing_001.md) · [Story](../story.md)

## The product

A clerk runs one script. It loads stock counts from a CSV, sells a fixed demo order, and prints what's running low. It works, for a clean file and a normal order. Feed it a bad line, an empty argument list, or a zero batch size, and it stops giving answers and starts giving tracebacks or silence.

## Confirmed findings and concrete failure paths

### P1 — `Inventory.drain_until_empty` never returns for `batch_size <= 0`

- **Source:** inventory.py:35-37
- **Trigger:** call `drain_until_empty(sku, batch_size)` with `batch_size` zero or negative while `self._counts[sku]` is positive.
- **Result:** the `while` loop's condition never becomes false, since the count never decreases. The call does not return.
- **Evidence:** executed directly — `drain_until_empty('widget', 0)` against a positive starting count did not complete within a 2-second bound (`timeout 2 python3 ...`, exit code 124). See [REG-04](regression_testing_001.md#case-record).
- **Corrective direction:** assert `batch_size > 0` on entry (this simultaneously closes the CODE-05 assertion gap on this method) and/or cap iterations explicitly.

### P1 — `Inventory.try_restock_from_supplier` silently discards every failure

- **Source:** inventory.py:39-44
- **Trigger:** `supplier.ship(sku, amount)` raises any exception.
- **Result:** the bare `except: pass` discards it. `self.restock` is skipped, `self._counts` is unchanged, and the caller receives no return value, no exception, and no other signal that the restock did not happen.
- **Evidence:** executed directly — a stub supplier whose `ship()` raised `ConnectionError` produced no exception and left `Inventory._counts` unchanged. See [REG-05](regression_testing_001.md#case-record).
- **Corrective direction:** catch the specific exception type(s) the supplier integration can raise, log or re-raise, and let unrelated exceptions (including `restock`'s own assertion) propagate.

### P2 — `Inventory.load_counts_from_file` leaks its file handle on a malformed line

- **Source:** inventory.py:25-33
- **Trigger:** any line in the CSV that doesn't split into exactly two comma-separated fields, or whose second field isn't an integer.
- **Result:** `line.strip().split(",")` or `int(amount)` raises before `f.close()` (line 32) is reached. The handle stays open for the lifetime of the `f` reference.
- **Evidence:** executed directly — a two-line CSV with one malformed row raised `ValueError` from line 29; `gc.get_objects()` immediately after showed the file object still referencing that path with `closed == False`. See [REG-06](regression_testing_001.md#case-record).
- **Corrective direction:** open the file with a `with` statement so the handle closes on every exit path, including the exception path.

### P2 — `main.py` crashes with a raw traceback on a missing argument

- **Source:** main.py:23 (`main(sys.argv[1])`)
- **Trigger:** run `python main.py` with no arguments.
- **Result:** `sys.argv[1]` raises `IndexError`, uncaught, printing a Python traceback and exiting 1.
- **Evidence:** executed directly. See [REG-07](regression_testing_001.md#case-record).
- **Corrective direction:** check `len(sys.argv)` and print a one-line usage message before calling `main`.

### P3 — `Inventory.sell` collapses three different failure causes into one `None`

- **Source:** inventory.py:17-23, consumed at main.py:17-18
- **Trigger:** call `sell` with an unknown SKU, a non-positive amount, or an amount exceeding stock.
- **Result:** all three return `None`. The only caller in this fixture (main.py:17-18) prints the same generic message — `"insufficient stock or unknown SKU"` — regardless of which of the three actually happened, including the non-positive-amount case, which that message doesn't even name.
- **Evidence:** executed directly — REG-02 and REG-03 in the regression record produced the identical `None` for two different causes.
- **Corrective direction:** raise a small set of distinct exceptions, or return a result type that carries the reason, instead of collapsing every failure to `None`.

## Conditional risks

These have not been triggered by anything in this fixture, but nothing in the reviewed source prevents them:

- **`Inventory.load_counts_from_file`'s read loop (inventory.py:28) has no enforced ceiling.** A very large input file is read and processed in full; nothing bounds line count, byte count, or elapsed time. No failure was demonstrated at the fixture's current input size (2 lines), so this is conditional, not confirmed. See [loop_ceilings_001.md](loop_ceilings_001.md).
- **`main.py:19` reaches into `Inventory._counts` directly** instead of calling a method. If `Inventory`'s internal attribute is ever renamed, `main.py` breaks with an `AttributeError` that nothing in either file's own tests would catch, because the coupling isn't expressed through `Inventory`'s public interface.
- **`format_low_stock`'s second assertion (report.py:7) is always true as written**, since `low` is built by the list comprehension directly above it. It currently provides no protection against a genuinely invalid input; it would need to check something about the input (e.g., that `counts` values are numeric) to satisfy the intent of CODE-05.

## Evaluation

### Assessment against each standard

| Standard | Verdict | Basis |
|---|---|---|
| CODE-01 (nesting ≤ 2) | **Fail** | `Inventory.sell` nests three levels deep (inventory.py:18-20). All 7 other functions pass. See [function_measurements_001.md](function_measurements_001.md). |
| CODE-02 (explicit loop ceilings) | **Fail** | Both loops in the manifest lack an enforced ceiling; one is confirmed non-terminating for a specific input. See [loop_ceilings_001.md](loop_ceilings_001.md). |
| CODE-03 (close what you open) | **Fail** | `load_counts_from_file` leaks its file handle on the error path. See [error_handling_001.md](error_handling_001.md). |
| CODE-04 (~60-line functions, one job) | **Pass** | Longest function measured is 9 lines. Not meaningfully exercised by a fixture this small. |
| CODE-05 (≥2 meaningful assertions) | **Fail** | 5 of 8 functions have zero assertions; `restock` has one; `format_low_stock` has two but the second is vacuous. Only `__init__` fully passes. See [function_measurements_001.md](function_measurements_001.md). |
| CODE-06 (never swallow an error) | **Fail** | `try_restock_from_supplier`'s bare `except: pass`. See [error_handling_001.md](error_handling_001.md). |
| CODE-07 (zero compiler/runtime warnings) | **Unverified** | A full compile/lint pass would write `.pyc` bytecode under this Python version regardless of `PYTHONDONTWRITEBYTECODE`, which FS-01 forbids. A cache-free `ast.parse()` of all three modules found no `SyntaxError`, which is weaker evidence than a real warnings pass and is recorded as such, not as a pass. See [REG-09](regression_testing_001.md#case-record). |

### Assessment of the added standards

- **REVIEW-01 through REVIEW-16:** satisfied by this report's own structure — the product name was supplied by the person running the example (REVIEW-01), each class/function was traced input to output (REVIEW-02, REVIEW-03), every finding above cites a failure path (REVIEW-04), the snapshot is hashed and linked (REVIEW-09), planned vs. executed is distinguished throughout the regression record (REVIEW-10), and this evaluation sits last in its own file (REVIEW-12, REVIEW-13).
- **REVIEW-05, REVIEW-06, REVIEW-07 (state recovery, safe retries, concurrent writes):** **Not applicable.** This fixture has no persisted state machine, no retry logic, and no concurrency.
- **REVIEW-08 (no secrets in source or reports):** **Pass.** No credentials or customer data appear anywhere in the fixture or this report.
- **PROC-03 (challenge safety claims):** applied directly to `try_restock_from_supplier`'s implicit safety claim ("errors during restock are handled") and to `drain_until_empty`'s implicit claim ("this loop terminates") — both failed under a concrete counterexample.
- **PROC-05 (test the interrupted step):** applied to `load_counts_from_file` — the "interruption" is the malformed line, and the check confirmed the resource is not released.
- **PROC-11 (prove resource ownership):** applied — `gc.get_objects()` was used to confirm the file object was still open, rather than inferring closure from the presence of a `f.close()` line that the code never reaches on this path.

### Quality verdict

**Not ready.** Two P1 defects — a caller-reachable infinite loop and a silently swallowed integration failure — are enough to block release on their own. The P2 file-handle leak and unhandled CLI crash should also be fixed before this leaves toy status. None of this requires a rewrite: every fix identified above is local to the function it's in.
