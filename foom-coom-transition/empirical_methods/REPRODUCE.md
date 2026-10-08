GPT-6 (Codex) — 2026-09-12

The stored outputs can be read without installing anything. `all_methods.csv` is the complete flat inventory; `all_methods.json` embeds source result records and diagnostics. The 214 rows are 213 correlated analyses/proxy/closure/uncertainty variants plus one unavailable CPU-year attempt, not 214 independent fits.

For a fresh run, create a Python virtual environment and install `requirements.txt`. Exact input CSVs and their source manifests are saved in the method directories. Run scripts from the `foom-coom-transition` directory after activating that environment:

```
python empirical_methods/stockfish/prepare_stockfish.py
python empirical_methods/stockfish/fit_stockfish.py
python empirical_methods/stockfish/stopping_stockfish.py
python empirical_methods/vision_lm/fit.py
python empirical_methods/vision_lm/bootstrap.py
python empirical_methods/vision_lm/reanchor_floor.py
python empirical_methods/published_domains/analyze.py
python empirical_methods/published_domains/posterior_qmc.py
python empirical_methods/inference/fit_inference.py
python empirical_methods/consolidate_results.py
```

The bootstrap and posterior integrations take longer than the deterministic regressions. `build_report.py` is deliberately omitted: it was an old document assembler with a private notes-vault destination, and is unnecessary to reproduce any fit. Read the current report in the project root; the frozen older `REPORT.md` and comparison figure remain here for research history.

The analysis audit independently checked Stockfish stopping transformations, LM fit/uncertainty optimization, inference units/selection/grouping/source dates, and posterior-likelihood numerical stability. The consolidator verifies 134 constant-b cases, complete method coverage, source pointers, finite outputs, and separation of conditional summaries from unconditional point answers. Numerical verification does not validate the assumed extrapolation beyond the data.

## Publication copy

Virtual environments, dependency caches, Python bytecode, and local execution logs are omitted. Frozen source CSVs, notebooks, source code, manifests, result tables, and provenance are retained. The notebooks and upstream scripts under `sources/` and `source/` are provenance, not programs executed by the reproduction commands, and may require additional dependencies to run themselves. Source files retain their original licenses and hashes.
