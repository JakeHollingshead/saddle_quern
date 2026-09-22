# Function call inventory — run 001

[Back to recursive.md](../recursive.md) · [SHA-256 snapshot](sha256_snapshot_001.md)

## Call graph from the only entry point

`main.py:23` (`if __name__ == "__main__"`) is the sole entry point in this fixture.

```
main.main (main.py:12)
├── Inventory.__init__ (inventory.py:7)                [state: sets self._counts]
├── Inventory.load_counts_from_file (inventory.py:25)   [side effect: opens a file; mutates self._counts]
├── Inventory.sell (inventory.py:17), called once per DEMO_ORDER entry (2 calls)
│                                                        [state: mutates self._counts on the success path]
└── format_low_stock (report.py:4)                       [reads main.py:19 shop._counts directly, bypassing Inventory's own interface]
```

`main` also reads `shop._counts` directly at main.py:19 rather than calling a method on `Inventory` — a direct attribute reach-through, not a resolved method call. Flagged in [bread_001.md](bread_001.md).

## Methods never reached from the entry point

- `Inventory.restock` (inventory.py:12) — called only by `Inventory.try_restock_from_supplier`, which is itself never called from `main.py`.
- `Inventory.try_restock_from_supplier` (inventory.py:39) — not called anywhere in this manifest. It calls `supplier.ship`, an external dependency injected by the caller; that dependency's behavior is unresolved and out of scope (PROC-02: stopped at the stated boundary).
- `Inventory.drain_until_empty` (inventory.py:35) — not called anywhere in this manifest.

These three are dead code from the perspective of the shipped entry point. They are still reviewed on their own terms (see [function_measurements_001.md](function_measurements_001.md) and [loop_ceilings_001.md](loop_ceilings_001.md)), since a public method on a class can be called by code outside this fixture's `main.py` — the class, not the entry point, is the trust boundary. PROC-09: this file inventory reflects symbols that were semantically traced; none in this fixture required behavior-testing beyond what [error_handling_001.md](error_handling_001.md) and [loop_ceilings_001.md](loop_ceilings_001.md) already executed.

## Unresolved / external

- `supplier.ship(sku, amount)` (inventory.py:41) — `supplier` is a parameter of unknown concrete type; its `ship` method is called but not defined anywhere in this manifest. Marked unresolved per PROC-02.

## Side-effect summary

| Symbol | Reads | Writes | External effects |
|---|---|---|---|
| `Inventory.__init__` | `initial_counts` argument | `self._counts` | none |
| `Inventory.restock` | `self._counts` | `self._counts` | none |
| `Inventory.sell` | `self._counts` | `self._counts` (success path only) | none |
| `Inventory.load_counts_from_file` | file at `path` | `self._counts` | opens a file handle; leaks it on a malformed line (see [error_handling_001.md](error_handling_001.md)) |
| `Inventory.drain_until_empty` | `self._counts` | `self._counts` | none (but see the non-termination finding) |
| `Inventory.try_restock_from_supplier` | — | `self._counts` (via `restock`, success path only) | calls `supplier.ship`, an unresolved external effect |
| `format_low_stock` | `counts` argument | none | none |
| `main` | `sys.argv`, `shop._counts` | none directly | calls `print`; drives all of the above |
