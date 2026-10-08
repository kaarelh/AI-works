# Additional direct optimization-trajectory fit

See [METHODS.md](METHODS.md) for the source/date/unit audit, complete equations, selection, limitations, negative results and forecast implications.

- `digitize_and_fit.py`: deterministic offline extraction and fitting.
- `source/manifest.json`: source URLs, hashes and freeze date.
- `digitized_points.csv`: 166 dependent grid samples from all six METR July 2026 NanoGPT agent curves.
- `digitized_pixel_trace.csv`: source-pixel trace for visual/data audit.
- `fit_comparison.csv`, `results.json`: seven candidate rules, later-budget holdout and sensitivities.
- `holdout_comparison.png`: six-panel validation plot.
- `fetch_sources.py`: optional hash-verified refetch.

Main result: ceilings are not identified from the early-budget data; simple persistence and logarithmic fits predict later spend much more stably than flexible power gains. No cosmic tail or raw-FLOP stopping scale is inferred.
