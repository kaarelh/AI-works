# Computational cosmology

**What computations can we run in this universe, from now onward?**

A standalone research report by **Codex (OpenAI AI assistant)**, 8 October 2026. Kaarel Hänni proposed the topic and contributed questions and editorial feedback.

- [Read the report](report.md)
- [Download the PDF](output/pdf/computational-cosmology.pdf)
- [View the five scientific figures](figures/), supplied as PNG and SVG

The report describes a region of possible computations using work, sequential depth, memory, entropy, communication, specification, and reliability. It combines a literature review with explicit calculations: finite-processing extensions of cosmological conversation bounds; storage and depletion checks; a memory-maintenance frontier; reversible checkpointing and archive costs; and a counting bound for classically selected quantum targets.

The familiar order-10^120 estimate is treated as a conditional erasure-equivalent budget, not a universal number of FLOPs or sequential steps. Cosmic numerical examples assume an eternally continuing flat ΛCDM reference model. The hardware examples declare their own assumptions; none establishes an attainable ultimate cosmic computer.

## Reproduce the calculations and PDF

Use Python 3.12 or newer. From this project directory on macOS or Linux:

```sh
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt

python research/cosmology/calculate_access.py
python research/cosmology/calculate_feedback.py
python research/thermodynamics/frontier_calculations.py
python analysis/synthesis.py
python analysis/specification.py
python analysis/feasible_region.py
python analysis/additional_checks.py
python analysis/validate.py
python scripts/render_math.py
python scripts/build_report.py
python analysis/check_document.py
```

On Windows, activate the environment using `.venv\Scripts\Activate.ps1` in PowerShell. After dependencies are installed, the calculations and PDF build require no network access or TeX installation. The final command writes `output/pdf/computational-cosmology.pdf`. A custom DejaVu font directory can be supplied with `python scripts/build_report.py --font-directory PATH`.

The scripts resolve project paths from their own locations. Dependency versions are lower bounds rather than a frozen environment, so numerical agreement is expected within ordinary floating-point tolerances; byte-identical images or PDFs are not promised. Rebuildable formulas and font caches are written under `tmp/` or `.matplotlib/` and are not publication sources.

| Script | Reproduces |
|---|---|
| `research/cosmology/calculate_access.py` | Horizons, photon-return energy, erasure equivalents, storage scales, launch delay, and the pure-de-Sitter coefficient comparison. |
| `research/cosmology/calculate_feedback.py` | Adaptive conversations with finite processing time and their causal limits. |
| `research/thermodynamics/frontier_calculations.py` | Reversible block-checkpoint examples and the independent-record archive bound. |
| `analysis/synthesis.py` | Thermal-channel, memory-latency, and reserve examples; causal-domain, storage-window, erasure-budget, and entropy-export figures. |
| `analysis/specification.py` | Classical program budget versus pure quantum target coverage. |
| `analysis/feasible_region.py` | The hardware-conditioned depth–memory–duration figure and numerical optimization checks. |
| `analysis/additional_checks.py` | Anchor depletion, reserve communication depth, black-hole lifetime, thermal barriers, and mixed-output specification examples. |
| `analysis/validate.py`, `analysis/check_document.py` | Independent numerical consistency checks, followed by PDF/source, citation-link, formula, and metadata checks. |
| `scripts/render_math.py`, `scripts/build_report.py` | Formula images and the linked PDF assembled from `report.md`. |

Each numerical script writes its results to an adjacent JSON file or to `analysis/`. Primary scientific sources are linked at the relevant claims in the report.

## Validation and scope

See [the validation record](analysis/VALIDATION.md) and the machine-readable results in `analysis/`. Checks include analytic limits, dimensional and numerical consistency, independent scalar optimization of the hardware frontier, coding-bound thresholds, and document rendering. **Passing these checks validates the calculations under their assumptions; it does not establish the physical feasibility of a speculative architecture.** The constants are declared inputs, not a new empirical fit to observations.

The [main project](https://github.com/kaarelh/AI-works/tree/main/computational-cosmology) contains the report, figures, reproduction code, results, and validation records. Exploratory notes and review history are retained separately on the working branch [`codex/computational-cosmology-2026-10-08`](https://github.com/kaarelh/AI-works/tree/codex/computational-cosmology-2026-10-08/computational-cosmology). The assembled report is the statement of conclusions; exploratory examples may use different assumptions or inventories.

Working-branch-only source paths are `research/model/`, all research Markdown notes except `research/cosmology/KS_CONSTANT_AUDIT.md`, `research/cosmology/retention_results.json`, and `research/thermodynamics/calculations.py` plus its JSON output. Caches, temporary formula images, environments, and ZIP bundles are excluded from publication.
