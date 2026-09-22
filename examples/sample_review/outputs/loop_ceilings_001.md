# Loop ceilings — run 001

[Back to recursive.md](../recursive.md) · [SHA-256 snapshot](sha256_snapshot_001.md)

Two loops exist in the reviewed source. Neither has an enforced ceiling.

## `inventory.py:28` — `for line in f:` inside `Inventory.load_counts_from_file`

- **Type:** explicit, bounded by the iterable (file object).
- **Implicit ceiling:** end of file.
- **Enforced ceiling:** none. Nothing in the function checks file size, line count, or elapsed time before iterating. A caller that points this at an arbitrarily large file has the function read and process every line.
- **Limit behavior:** unbounded; the loop simply runs until `f` is exhausted or a line fails to parse (see [error_handling_001.md](error_handling_001.md)).
- **Verdict:** CODE-02 **Fail** — an assumption that input files stay small is not a bound.

## `inventory.py:36` — `while self._counts.get(sku, 0) > 0:` inside `Inventory.drain_until_empty`

- **Type:** explicit, condition-controlled.
- **Implicit ceiling:** none stated by the function; the author's apparent intent is "loop until the count reaches zero."
- **Enforced ceiling:** none. Termination depends entirely on `self._counts[sku]` decreasing by `batch_size` each iteration (line 37), and `batch_size` is a caller-supplied parameter with no validation.
- **Limit behavior:** confirmed non-terminating for `batch_size <= 0`. Verified directly: calling `drain_until_empty("widget", 0)` against a positive starting count did not return within a 2-second bound (process killed by `timeout 2`, exit code 124). This is not a hypothesis — it is an executed, reproducible hang.
- **Verdict:** CODE-02 **Fail**. See [bread_001.md](bread_001.md) for severity and corrective direction.

No other loops (explicit or implicit via recursion, comprehensions with unbounded sources, or generator consumption) exist in the reviewed manifest. The list comprehensions in `report.py:6` and `report.py:10` iterate over `counts`, whose size is already covered by the file-read path above; they introduce no separate ceiling risk.
