# SHA-256 snapshot — run 001

[Back to recursive.md](../recursive.md)

- **Product:** Toy Stock Demo (this name was supplied by the person running the example; see [recursive.md](../recursive.md))
- **Source root:** `examples/toy_repo/` (relative to the repository root)
- **Revision:** untracked working copy — this example predates the repository's first commit, so no git SHA exists. Re-running this review against a committed copy should record the commit hash here instead.
- **File count:** 4
- **Method:** sort relative paths lexically; for each file write `path<TAB>sha256<LF>` in UTF-8; hash the resulting manifest bytes with SHA-256. Hashes were computed with `sha256sum` against the files exactly as they sit in `examples/toy_repo/`.
- **Exclusions:** none. All four files in the source root are in scope, including the data file `stock.csv`, since `load_counts_from_file` treats it as an input contract, not a build artifact.
- **Drift check:** not applicable to a first run. On a rerun, recompute the manifest digest and flag any path whose hash changed since this snapshot.

## Manifest

| Path | SHA-256 |
|---|---|
| `inventory.py` | `7407d9512e076a70f964ec936d9802729276093248cc5330ccfa7343b85a4588` |
| `main.py` | `e46e4b417c97c387a6e34c64a3b3cd91c248710fe5b58d601a33fe70d6e6d710` |
| `report.py` | `9bf3e0c7cca61e1f66c310bc7e2de1c44ffa5f7f05493915fa529c64c5090631` |
| `stock.csv` | `64c614da6bb05545045b8411fe96704d03bc4e4761cedc888e0f4100d596d8a3` |

## Manifest digest

```
58d48d252f63ae1552dfc909f67073c439678a60b26ac5b75d8fdbe24ea9852c
```

This digest identifies the exact bytes reviewed. It says nothing about quality; the quality verdict is in [bread_001.md](bread_001.md).
