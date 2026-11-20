# Steelmanning AGI timeline arguments

A research report on the quantitative arguments for "AGI by year n", written by Claude for Kaarel Hänni, dated 20 November 2026. For each argument family it gives the argument as made, the strongest steelman, where it breaks, and its track record. It then asks whether the forecasts that now look prescient were luck.

The argument families covered:

- **Scaling laws (2020).** What step people took from falling log loss to AGI, and whether that step survives the fact that pretraining alone did not get there.
- **Brain-compute extrapolations.** Moravec, Vinge, Bostrom, Kurzweil and Legg, and why their dates landed near the mid-to-late 2020s.
- **METR time horizons and the AI Futures Project forecasts.** How these are tracking as of November 2026.
- **Hyperbolic growth.** Von Foerster's 1960 singularity on 13 November 2026, Kremer, Hanson and Roodman, and whether any of it can be read as an AGI prediction.
- **Other trend extrapolations.** Revenue, capex, compute deadlines, takeoff models, benchmarks and milestone hyperbolas.
- **Failed forecasts.** Ones that missed badly in both directions, plus a base-rate and luck analysis.

**Start with [the report](reports/Steelmanning%20AGI%20timeline%20arguments.md).** Its opening section gives short answers to each question.

## Contents

- `reports/Steelmanning AGI timeline arguments.md` is the report (about 12,000 words, 8 figures).
- `research_notes/Steelmanning AGI timeline arguments/` holds the seven research notes the report synthesizes, with sources and verification flags:
  - scaling-law arguments
  - brain-compute forecasts
  - time horizons
  - hyperbolic growth
  - other quantitative arguments
  - wrong forecasts and base rates
  - the quantitative analysis
- `analysis/` holds the sensitivity analyses behind every number the report labels "analysis A–E". [`analysis/README.md`](analysis/README.md) lists the scripts, data sources and pinned commits. The analyses are:
  - A. Hyperbolic fits to population and GWP.
  - B. Brain-compute and training-anchor dates.
  - C. METR horizons recomputed from METR's raw runs.
  - D. Base rates of historical predictions.
  - E. A luck model.

## Reproduce

```sh
cd analysis
bash fetch_data.sh   # re-downloads data/raw/, including METR's run files (~38 MB, not committed)
bash run_all.sh      # writes outputs/ and figures/
```

Requirements: Python 3 with numpy, pandas, matplotlib, scipy and openpyxl.

## Caveats

The session that did the research could reach GitHub, arXiv and package registries, but not metr.org, epoch.ai, lesswrong.com, metaculus.com, aiimpacts.org or ourworldindata.org. As a result:

- **Recomputed from raw data:** the METR horizons up to February 2026 and the population and GWP fits.
- **Taken from search-result summaries or the press:** most claims about 2026 events. The report labels these inline ("search summary", "secondary", "unverified").
- **Transcribed from memory:**
  - the forecasters' brain-compute parameters in analysis B;
  - the 13-prediction list behind analyses D and E, which stands in for the MIRI predictions dataset, since that dataset could not be downloaded.

The report was researched, written and checked by AI; no human has checked it.

## Branches

The working branch is `claude/upbeat-knuth-dcnswm`. Nothing in this folder stays only on the working branch, apart from the large raw METR run files, which `.gitignore` excludes and `analysis/fetch_data.sh` re-downloads.
