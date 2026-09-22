# Error handling — run 001

[Back to recursive.md](../recursive.md) · [SHA-256 snapshot](sha256_snapshot_001.md)

Two functions touch error handling, and they fail in opposite directions: one suppresses every error, the other guards none.

## `inventory.py:39-44` — `Inventory.try_restock_from_supplier` swallows everything

```python
try:
    supplier.ship(sku, amount)
    self.restock(sku, amount)
except:
    pass
```

A bare `except:` catches every exception, including ones unrelated to the supplier call — for example, `self.restock`'s own `assert amount > 0` (inventory.py:13) firing on bad input would also be silently discarded here.

**Test evidence (executed):** a `FailingSupplier.ship` that raises `ConnectionError` was passed to `try_restock_from_supplier`. No exception propagated, and `Inventory._counts` was unchanged afterward — the restock silently did not happen and the caller received no signal that anything went wrong.

**Verdict:** CODE-06 **Fail**. This is not observable, deliberate recovery; it is suppression.

## `inventory.py:25-33` — `Inventory.load_counts_from_file` guards nothing

```python
f = open(path, "r")
counts = {}
for line in f:
    sku, amount = line.strip().split(",")
    counts[sku] = int(amount)
self._counts.update(counts)
f.close()
return counts
```

`f.close()` (line 32) sits after the loop with no `try`/`finally` and no context manager. Any malformed line — a row without exactly one comma, or a non-integer amount — raises before line 32 runs.

**Test evidence (executed):** a two-line CSV (`widget,10` / `malformed-line-no-comma`) was loaded. The second line raised `ValueError: not enough values to unpack (expected 2, got 1)` from line 29, propagating out of the function. Inspecting live objects (`gc.get_objects()`) immediately after the exception found the file object for that path still present with `closed == False` — the handle was not released.

**Verdict:** CODE-03 **Fail**. The function does not close what it opens on its error path.

## `main.py` — no handling at either call site

`main()` calls `shop.load_counts_from_file(counts_path)` (main.py:14) and reads `sys.argv[1]` (main.py:23) with no `try`/`except` at either site. Both of the failures above, plus a missing CLI argument, surface as raw Python tracebacks to whoever runs the script.

**Test evidence (executed):** running `python main.py` with no arguments raised `IndexError: list index out of range` from `sys.argv[1]` (main.py:23) and exited with status 1 — an unhandled crash rather than a usable error message.

Findings, severity, and corrective direction for all three are in [bread_001.md](bread_001.md).
