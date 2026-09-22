# Story — Toy Stock Demo

[Back to recursive.md](recursive.md) · [Bread](outputs/bread_001.md)

Two people use this code. A clerk runs the script. An integrator calls the class directly. Only the clerk's path is wired up in this fixture; the integrator's path exists in the code but nothing here calls it yet.

## Priya, the clerk — the implemented path

Priya wants to know what to reorder today.

She runs `python main.py stock.csv` (main.py:23). The script reads `stock.csv` line by line and builds a count for each item (main.py:14, inventory.py:25-33). It sells two fixed demo items — three widgets, twelve gadgets (main.py:9, main.py:15-18) — against those counts. It prints which items are low (main.py:19, report.py:4-11). The process ends. Nothing is written back to `stock.csv`; the next run starts from the same file, unchanged. This is implemented behavior, not a bug — but it means "sold" stock is not persisted anywhere Priya can see tomorrow.

**Main path, success.** The file is well-formed and both demo items are in stock. Priya sees two lines: a stock update (implicit — no line prints for a successful sale) and a low-stock report. She reorders whatever the report names.

**Branch: she forgets the filename.** She runs `python main.py` with nothing after it. `sys.argv[1]` raises immediately (main.py:23). She sees a Python traceback, not a usage message. [Confirmed failure path.](outputs/bread_001.md#p2--mainpy-crashes-with-a-raw-traceback-on-a-missing-argument)

**Branch: the file has a bad line.** Someone hand-edited `stock.csv` and left a stray line with no comma, or a non-numeric count. The load fails partway through (inventory.py:29), and the file handle from inventory.py:26 is never released. Priya sees a traceback and no report at all — including for items that parsed fine before the bad line. [Confirmed failure path.](outputs/bread_001.md#p2--inventorypys-load_counts_from_file-leaks-its-file-handle-on-a-malformed-line)

**Branch: one of the demo items is short or missing.** `sell` returns `None` (inventory.py:23). Priya sees: `Could not sell 3 of widget: insufficient stock or unknown SKU.` The message doesn't say which of the two it was, or whether the real cause was a non-positive amount — a case the message doesn't name at all. [Confirmed failure path.](outputs/bread_001.md#p3--inventorysell-collapses-three-different-failure-causes-into-one-none) There is no retry and no recovery step; Priya's only option is to edit `stock.csv` and run the script again.

## An integrator, calling `Inventory` directly — inferred, not exercised by this fixture

`Inventory` is a public class. Its `restock`, `drain_until_empty`, and `try_restock_from_supplier` methods exist and are reachable by any code that imports the module, even though `main.py` never calls them ([confirmed by the call inventory](outputs/function_calls_001.md#methods-never-reached-from-the-entry-point)). This second journey is inferred from those method bodies, not observed in any script in this manifest.

**Branch: an integrator wires up automatic restocking.** They call `try_restock_from_supplier(sku, amount, supplier)` against a real supplier integration. If the supplier call fails — a timeout, a rejected order — the bare `except: pass` (inventory.py:43-44) discards it. The integrator's code sees a normal return with no exception and no restock. Nothing in the reviewed source signals the failure anywhere. [Confirmed failure path.](outputs/bread_001.md#p1--inventorytry_restock_from_supplier-silently-discards-every-failure)

**Branch: an integrator calls `drain_until_empty` with a caller-supplied batch size.** If that value is zero or negative — a plausible result of an upstream bug, not just a typo — the call never returns. [Confirmed failure path.](outputs/bread_001.md#p1--inventorydrain_until_empty-never-returns-for-batch_size--0) There is no visible response, no error, and no way to abandon the call from inside the reviewed code; whatever called it hangs too.

Neither branch has a recovery step in the reviewed source. Both are entry points a future caller could reach even though today's one shipped entry point, `main.py`, does not.
