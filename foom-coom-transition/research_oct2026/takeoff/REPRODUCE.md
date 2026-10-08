# Reproduce the October 2026 takeoff contribution

Run commands from the `foom-coom-transition` package root. The saved results can be read without running anything. These supporting analyses informed the report; they are not separate empirical forecasts of the ultimate stopping point.

## Included investigations

- [REPORT.md](REPORT.md): results and implications for the stopping forecast.
- [ORIGINAL_AI2027.md](ORIGINAL_AI2027.md): original milestone simulation, exact interpolation, and limits of the transfer.
- [aifm_current/REPORT.md](aifm_current/REPORT.md): current AI Futures Model equations, historical calibration, research-taste cap, and source/default discrepancies.
- [forethought/REPORT.md](forethought/REPORT.md): software-explosion calibration, headroom, and continuous versus discrete tail sensitivity.
- [brain_audit/REPORT.md](brain_audit/REPORT.md): independent learning/inference/hardware audit and undertraining replication.
- [TOY_TRANSFER.md](TOY_TRANSFER.md): common-multiplier sensitivity calculations.

## Offline calculations

Install NumPy and SciPy in your Python environment, then run:

```sh
python research_oct2026/takeoff/reproduce_original.py
python research_oct2026/takeoff/headroom_sensitivity.py
python research_oct2026/takeoff/forethought/reproduce.py
python research_oct2026/takeoff/brain_audit/reproduce.py
node research_oct2026/takeoff/forethought/source_crosscheck.js
```

The brain arithmetic uses only Python's standard library. The last command needs Node.js and compares 81 parameter cases against the retained official simulator. The original-model replication samples one million scenarios using an exact continuous-time phase integral. The Forethought near-term replication uses 50,000 draws with an explicit seed. These are replications of stipulated probability models, not empirical posterior estimation. Scripts write outputs beside themselves.

## Optional current AI Futures Model replication

The large upstream checkout and its environment are intentionally omitted. Retrieve the exact MIT-licensed upstream revision in the expected location:

```sh
git clone https://github.com/AI-Futures-Project/aifm-public.git research_oct2026/takeoff/aifm_current/aifm-public
git -C research_oct2026/takeoff/aifm_current/aifm-public checkout --detach 1c40ecdb246c25980515441a66571931c5604e11
python -m venv .venv-aifm
.venv-aifm/bin/python -m pip install numpy==2.4.1 scipy==1.17.0 pandas PyYAML==6.0.3
.venv-aifm/bin/python research_oct2026/takeoff/aifm_current/reproduce.py
```

The recorded run used Python 3.13.2. The reproduction checks the expected commit and saved source hashes before running. It executes median parameter cases, not the full production Monte Carlo. The source README recommended Python 3.14; the recorded Python 3.13.2 run passed its checks. Numerical changes across other dependency versions are possible.

## Saved results and provenance

- `original_replication.json`: original AI2027 milestone distributions, daily-versus-continuous checks, and calibration arithmetic.
- `headroom_sensitivity.json` and `.csv`: thirty effective-cost-gap scenarios and alternative marginal laws.
- `aifm_current/calibrations.json` and `.csv`: executed configurations and diagnostics; `lag_doubling_check.json` independently checks the asymptotic training lag.
- `forethought/results.json` and `source_crosscheck.json`: arithmetic, Monte Carlo replication, stopping calculations, discretization sensitivity, and official-source comparisons.
- `brain_audit/results.json` and `undertraining_sensitivity.csv`: analytic versus grid undertraining calculations and coefficient sensitivity.
- `sources/original_code/manifest.json`: pinned original AI2027 code URLs and hashes.
- `aifm_current/provenance.json`: pinned current AIFM commit, source hashes, and runtime versions.
- `forethought/sources/download_manifest.json` and `repo_commits.json`: official simulator retrieval and commit provenance.
- `brain_audit/sources/manifest.json`: public notebook and primary references.

Small source-code snapshots and the public brain-undertraining notebook are retained for reproduction and attribution. They retain their original authorship and any source license; this package does not relicense them. The Forethought manifest records original retrieval URLs, including moving `main` URLs; the retained file hashes identify the actual frozen bytes.

Downloaded article HTML, PDFs, extracted article text, raw execution logs, and the full AIFM repository are omitted. Their original source URLs and SHA-256 hashes remain in the source manifests as a record of the research; those entries do not claim that the corresponding files are bundled. The AIFM reproduction preserves the archived-document hashes from the saved provenance when those optional snapshots are absent. The original handoff artifact manifest is omitted because the package edits reproduction instructions and paths.

## Validation and interpretation

The original phase integrator is exercised directly at representative inputs. Common-multiplier optima solve the exact remaining-budget condition. Forethought continuous integrals are checked against an independent positive series. Brain same-loss optima satisfy both the loss constraint and first-order condition and agree with the notebook grid search. Current-model calculations execute the pinned source and inspect calibration and preset behavior.

No real-world data in this contribution spans the 91-order decline from `k0=10^-29` to a `10^-120` marginal return. Long-run outputs are conditional extrapolations. This contribution supplies no new probability weights over tail families and does not solve adaptive research under uncertain improvement laws.
