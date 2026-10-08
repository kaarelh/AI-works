# Final reproducibility and publication audit

8 October 2026.

The recommended curated publication set is enumerated in `curated_publication_files.json` beside this audit. It contains 37 files: the report and PDF, README and requirements, five figures in both PNG and SVG, the calculation and build scripts, their numerical outputs, validation records, and the Krauss–Starkman coefficient derivation. Exploratory research memos and obsolete alternative-inventory calculations remain working-branch material.

## Changes made

- Replaced the stale README with a standalone project description, Codex author attribution, report and figure links, the complete reproduction pipeline, script/output mapping, and the distinction between numerical checks and physical feasibility.
- Added `analysis/additional_checks.py` and its JSON output to reproduce anchor depletion, the reserve's communication timescale, black-hole storage estimates, the thermal memory barrier, pure/mixed specification cutoffs, and full/partial checkpoint-block accounting. These examples previously lacked a complete script-backed record.
- Removed local virtual-environment references from two script docstrings.
- Removed orchestration and prior-chat wording from the opening and final qualification of `KS_CONSTANT_AUDIT.md`; its scientific derivation is unchanged.
- Identified stale document metadata and a document-checker environment-directory scan; both were corrected during final preparation.

## Reproduction result

A fresh temporary project copied only the current source files, without figures, numerical results, formula caches, or PDF. All eleven calculation, figure, rendering, PDF-build, and document-check commands passed. All eight numerical JSON outputs match the publication sources exactly. The process regenerated five PNG figures, five SVG figures, and a 26-page PDF whose automated document checks passed. `analysis/reproducibility_results.json` records commands, package versions, source hash, and comparisons.

The available numerical and document dependencies were in separate Python installations, so the fresh-source test used the numerical runtime for calculation and formula rendering and the document runtime for PDF assembly and checks, with the Matplotlib font directory supplied explicitly. A newly pip-installed unified environment was not separately tested. The README's dependencies include both sets. This distinction is recorded rather than hidden.

The staged PDF was used only for reproduction; the final publication PDF and its separately verified hash were not replaced. Final visual page review remains a separate validation activity.

## Publication exclusions

Exclude `tmp/`, `.matplotlib/`, `.venv/`, `__pycache__/`, ZIP bundles, and other caches or preview artifacts. Exclude `research/cosmology/retention_results.json` from the curated package because it is an exploratory output without its original standalone generator; the report's relevant values are now reproducible in the included scripts. Exclude `research/thermodynamics/calculations.py` and `calculations.json`, which use an older illustrative energy inventory not adopted in the report. Retain these materials on the working branch if desired.

Apart from the published coefficient audit, research Markdown files are exploratory or review records and need not be part of the public main project. The report itself links the primary scientific sources at the claims they support.

The curated text/code/results scan found no user-specific absolute paths or orchestration instructions. Dependencies use declared lower bounds, so reproduction means agreement of scientific results within floating-point tolerance rather than byte-identical artifacts across environments.
