# Reproduce the October empirical package

All datasets required for the fits are frozen locally. Ordinary analysis needs no network, API keys, model inference, training jobs or paid services. The scripts write only within this empirical folder. Sources retain their original licenses; the METR source figure is CC-BY.

From the `foom-coom-transition` directory, with a Python environment active:

```sh
python -m pip install -r research_oct2026/empirical/requirements.txt
PYTHONDONTWRITEBYTECODE=1 python research_oct2026/empirical/reproduce_all.py
```

The runner invokes each script sequentially and sets cache paths within each output folder. The saved environment used Python 3.13.2; the dependency versions are pinned in `requirements.txt`.

| Script | Frozen input | Main output |
|---|---|---|
| `controlled_vintage/fit.py` | Pinned NanoGPT README, PR metadata, source timing records | Frontier CSVs, 60 correlated fits, floor profiles, holdout plot |
| `rebench/digitize_and_fit.py` | METR's July 2026 revalidated six-curve PNG | Pixel trace, expenditure-grid CSV, curve fits, pixel/grid sensitivity, plot |
| `pretraining/analyze.py` | Pinned author model card, 50-row CSV, 50 run records | Multiplier table, unit/seed audits, curve comparisons, metric sensitivity, plots |

The subfolders provide optional `fetch_sources.py` scripts; NanoGPT also has PR/audit retrieval scripts. These document provenance but are unnecessary for offline reproduction. Immutable source URLs and SHA-256 hashes are recorded in their source manifests. The pretraining script verifies 53 source-file hashes on every run. Do not substitute a newer upstream README or plot while claiming the frozen results are unchanged.

The output figures were visually checked against their plotted data/source. Source-date audits, conditional seed sensitivity, and chronological/expenditure holdouts are the appropriate validations here. No statistical interval treats adjacent records or extracted pixels as independent samples. `SUMMARY.md` and the three `METHODS.md` files distinguish observations from analyst choices and unidentifiable extrapolations.

No previously aborted Stockfish CPU-year sheet is used.

## Publication copy

Dependency caches, bytecode, and local execution logs are omitted. The archived METR article HTML is also omitted because the offline analysis only reads its frozen source PNG; its URL and original hash remain in `rebench/source/manifest.json`, and the optional fetcher can retrieve it. NanoGPT upstream timing logs are retained as empirical audit inputs, not local execution logs. All source manifests and source-file hashes are preserved. The offline analyses require no omitted files.

The publication copy of `consolidate.py` emits method-document paths relative to this empirical directory, rather than machine-specific absolute paths. This presentation change does not alter fitted quantities.
