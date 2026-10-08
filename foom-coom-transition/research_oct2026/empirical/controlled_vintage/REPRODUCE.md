# Reproduce the controlled-vintage fit

All analysis inputs are frozen beside this file. No download is needed to rerun.

```sh
python3 -m venv .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python fit.py
```

Run these commands from this directory, or use the package-level runner documented in `../REPRODUCE.md`.

This run used Python 3.13, numpy 2.5.3, scipy 1.18.1 and matplotlib 3.11.2. The script writes only to its own directory, resolves inputs relative to itself, runs deterministic multi-start or profiled nonlinear fits, and saves all results and the plot. The script checks the input row count, retiming count, endpoint units, and primary sample size. No GPU reproduction was performed.

Optional source refresh/verification (public network access needed): `python3 fetch_sources.py`, `python3 fetch_audit.py`, `python3 fetch_pr_dates.py`. The README and log downloads are pinned to commit `4ea6b937337a4889b8cfe3f38a93d120048d8f71`; their hashes are in `source_manifest.json` and `audit_manifest.json`. PR metadata is a projected freeze of current API metadata for 65 linked records, with original response hashes and projection fields in `pr_metadata_manifest.json`. Unlike the immutable file downloads, running the PR fetch in the future can change metadata, so the archived `pr_metadata.json` is the analysis input. Files here are a compact dataset, an analysis, and an audit; the whole source project is not vendored.

Read `METHODS.md` for all selection and inference qualifications, and `AUDIT.md` for the independent primary-source audit.
