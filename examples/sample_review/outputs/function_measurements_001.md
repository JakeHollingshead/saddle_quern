# Function measurements — run 001

[Back to recursive.md](../recursive.md) · [SHA-256 snapshot](sha256_snapshot_001.md)

## Counting rules

- **Length:** last line of the `def` block minus the `def` line, inclusive of the signature line; blank lines and the docstring line count.
- **Nesting:** count compound statements (`if`/`for`/`while`/`try`) nested inside one another within a single function body, starting at 0 for the function's own top level. A guard clause that returns still counts as one level while its body executes.
- **Assertions:** only `assert` statements with a message and a condition that can be false for some reachable input. An assertion that is always true by construction (e.g. asserting the type of a value just built by a list comprehension) is counted here but flagged separately, per AGENTS.md CODE-05's instruction not to pad compliance with vacuous assertions.
- **Totals** below include every function and method in the four-file manifest. There are no nested functions, test helpers, generated files, or parameterized tests in this fixture (PROC-12).

## Measurements

| Symbol | File:lines | Length | Nesting | Assertions | CODE-01 | CODE-04 | CODE-05 |
|---|---|---|---|---|---|---|---|
| `Inventory.__init__` | inventory.py:7-10 | 4 | 0 | 2 | Pass | Pass | Pass |
| `Inventory.restock` | inventory.py:12-15 | 4 | 0 | 1 | Pass | Pass | **Fail** — only one assertion; nothing guards `sku` |
| `Inventory.sell` | inventory.py:17-23 | 7 | 3 | 0 | **Fail** — three nested `if` statements (lines 18-20) | Pass | **Fail** — no assertions |
| `Inventory.load_counts_from_file` | inventory.py:25-33 | 9 | 1 | 0 | Pass | Pass | **Fail** — no assertions |
| `Inventory.drain_until_empty` | inventory.py:35-37 | 3 | 1 | 0 | Pass | Pass | **Fail** — no assertion that `batch_size > 0` |
| `Inventory.try_restock_from_supplier` | inventory.py:39-44 | 6 | 1 | 0 | Pass | Pass | **Fail** — no assertions |
| `format_low_stock` (free function) | report.py:4-11 | 8 | 1 | 2 | Pass | Pass | **Partial** — two assertions present, but the second (`isinstance(low, list)`, line 7) is always true given how `low` is built on line 6; it does not guard a reachable invalid input |
| `main` (free function) | main.py:12-19 | 8 | 2 | 0 | Pass | Pass | **Fail** — no assertions; `counts_path` and the demo order are used unchecked |

## Totals

- Functions/methods measured: 8 — 6 methods on `Inventory`, plus 1 free function each in `report.py` and `main.py`.
- CODE-01 (nesting ≤ 2): 7 Pass, 1 Fail (`Inventory.sell`).
- CODE-04 (≈60-line ceiling): 8 Pass. Nothing in this fixture approaches the ceiling; CODE-04 is not exercised by this example.
- CODE-05 (≥2 meaningful assertions): 2 Pass, 5 Fail, 1 Partial.

Confirmed findings drawn from this table are in [bread_001.md](bread_001.md).
