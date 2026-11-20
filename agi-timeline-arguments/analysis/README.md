# Sensitivity analyses for "AGI by year n" forecasts

Supporting computations for the report *Steelmanning AGI timeline arguments*. Each script
answers one question: how far does a forecast's date move under reasonable changes to its
inputs, and how likely is a forecast to land near 2027 by chance? The scripts measure
sensitivity. They do not make a new forecast.

The results and their caveats are written up in
`../research_notes/Steelmanning AGI timeline arguments/quantitative_analysis.md`.

## Reproduce

```
bash fetch_data.sh      # optional: re-download data/raw/ (pinned commits; ~42 MB)
bash run_all.sh         # ~45 s; writes outputs/*.txt|csv and figures/*.png
```

Requirements: Python 3 with numpy, pandas, matplotlib, scipy and openpyxl (to read `.xlsx`).
All scripts run with `python3 -I`, because they read downloaded files. Data paths are passed as
arguments, and `run_all.sh` shows the exact calls. `common.py` holds the shared loaders, the
hyperbola fit and the plot style.

| script | analysis | main outputs | figures |
|---|---|---|---|
| `a_hyperbolic_fits.py` | A. Fits N = C/(t0 − t)^k to world population and GWP for several sources, start dates, cutoffs and weightings, with k free and with k = 1. Reproduces von Foerster's set-up. Compares growth rates with the rate 1/(2026.87 − t) that a hyperbola needs. | `a_t0_table_*.txt`, `a_von_foerster_reproduction.txt`, `a_1960_analyst_ensemble.txt`, `a_t0_spread_summary.txt`, `a_gwp_t0_minus_cutoff.txt`, `a_growth_rates_selected.txt`, `a_hyperbolic_fits_all.csv` | `a1_t0_vs_cutoff.png`, `a2_growth_vs_hyperbola.png`, `a3_implied_singularity_date.png` |
| `b_brain_compute.py` | B. Year in which $1000 buys B FLOP/s, for B = 1e13–1e17, under the forecasters' own trends and under the realized trend. Year in which frontier training compute reaches k × B × 1e9 s. Years moved per order of magnitude (OOM) of each input, an OOM ledger of cancellations, and how strongly fast growth compresses date uncertainty. | `b1_dollar1000_dates.txt`, `b2_training_anchor_grid.txt`, `b2_training_anchor_dates.txt`, `b3_years_per_oom.txt`, `b4_oom_ledger.txt`, `b5_compression_of_dates.txt` | `b1_brain_compute.png` |
| `c_metr_horizons.py` | C. Recomputes the 50% and 80% time horizons from METR's raw runs (TH1.0 and TH1.1). Fits exponential models (several windows), quadratic-in-log models and "shrinking doubling time" superexponential models. Gives the dates for 40 h, 167 h and 2000 h, a bootstrap over models, and a 2026 hindcast. | `c_agent_horizons_table.txt`, `c_trend_fits.txt`, `c_bootstrap_exponential.txt`, `c_hindcast_2026.txt`, `c_spread_summary.txt` | `c1_metr_horizon_extrapolations.png`, `c2_metr_date_spread.png` |
| `d_prediction_base_rates.py` | D. Distribution of (predicted year − year made) for pre-2012 predictions, the share that falls in 2025–2032, and hardware-based predictions against the rest. | `d_predictions_list.txt`, `d_delta_summary.txt` | `d1_prediction_horizons.png` |
| `e_luck_model.py` | E. Chance of landing in 2025–2030 (±2 years of 2027–28) if the forecast horizon Δ is drawn from a base rate. Per forecaster, at least m of N (Poisson-binomial), the four headline hits, and the expected number of hits in a 65–95-prediction pool. | `e1_per_forecaster_hit_prob.txt`, `e2_m_of_n.txt`, `e3_four_hits.txt`, `e4_pool_expected_hits.txt` | `e1_luck_model.png` |

Each script also writes its console output to `outputs/<letter>_log.txt`.

## Data sources (all accessed 20 Nov 2026)

This session could reach only GitHub, arXiv and package registries.
ourworldindata.org, epoch.ai, metr.org, aiimpacts.org, Google Docs, population.un.org and
rug.nl were blocked by the network policy. Every raw file therefore comes from a public GitHub
repository, pinned to a commit in `fetch_data.sh`.

| local path | content | source |
|---|---|---|
| `data/raw/roodman_gwp/GWP.xlsx` | Roodman's (2020) compiled series. The sheet "Data presentation" gives world population (millions) and GWP (billion 1990 $) from 1,000,000 BCE to 2019. The population series is Deevey, then McEvedy & Jones / Kremer (1993), then Maddison, then UN. The GWP series is DeLong (1998), then Maddison, then the World Bank. The sheet "Cohen 1995" gives the average of historical population estimates from Cohen's *How Many People Can the Earth Support?*, App. 2. | https://github.com/droodman/Modeling-Human-Trajectory (commit 5b7d41a, 13 Jul 2024) |
| `data/raw/owid_datasets/pop_hyde_un/` | World population by region (summed here), HYDE 2016 to 1950, then UN WPP 2017 to 2015. Projections are not used. | https://github.com/owid/owid-datasets, dataset "Global Population by Region with projections - HYDE (2016) & UN (2017)" (commit 6155d4c) |
| `data/raw/owid_datasets/maddison2020/` | Maddison Project Database 2020, "World" rows (GDP, 2011 int. $), 1820–2018 | same repository, dataset "Maddison Project Database 2020 (Bolt and van Zanden (2020))" |
| `data/raw/metr_eval_analysis_public/` | METR raw agent runs for Time Horizon 1.0 and 1.1 (`runs.jsonl`), model release dates and report parameters. Method settings come from `reports/time-horizon-1-1/fig_params/figs.yaml` (weighting `invsqrt_task_weight`, regularization 1e-5, `score_binarized`) and `src/horizon/utils/logistic.py`. | https://github.com/METR/eval-analysis-public (commit 52cb829, 5 Mar 2026). The latest models are Claude Opus 4.6 and GPT-5.3-Codex (Feb 2026). |
| `data/raw/epoch_notable_models_mirror/notable_ai_models.csv` | Epoch AI "Notable AI Models" (CC BY 4.0): 867 models, publication dates up to 19 Sep 2024, with training compute and cost. This is a **third-party snapshot**, because epoch.ai was blocked. | https://github.com/ManoHarshaSappa/Tracking_State_of_the_Art_AI-Models_and_Performance- (commit 6ee90a8, 9 Mar 2025). Original: https://epoch.ai/data/notable-ai-models |
| `data/manual/brain_compute_forecasts.csv` | The brain estimates, forecast years and assumed doubling times of Moravec (1998) and Kurzweil (1999, 2005) | Transcribed from the cited works **from memory**: the primary texts could not be fetched in this session, so the transcriptions are flagged in the file |
| `data/manual/ai_predictions.csv` | 13 well-known dated pre-2012 AI predictions, with quote or paraphrase, citation and transcription confidence | Hand-built, because the MIRI / Armstrong–Sotala dataset (https://aiimpacts.org/miri-ai-predictions-dataset/) could not be downloaded. Citations come from memory and were not re-checked online. |
| `data/manual/famous_forecasts.csv` | Forecasters for the luck test: von Foerster 1960, Roodman 2020, METR 2025 and others | as cited in the file |

Numbers quoted from papers obtained through arXiv: METR, Kwa et al. (2025), arXiv:2503.14499, gives a
doubling time of about 7 months (207 days) and a 1-month horizon between mid-2028 and mid-2031.
Sevilla et al. (2022), arXiv:2202.05924, gives a 6-month doubling of training compute over 2010–2022 and a
10-month doubling for large-scale models.

## Main assumptions (details in each script's docstring)

* **A.** Fits are least squares in log N, profiled over t0. "Thinned" weighting, the headline choice,
  keeps every tabulated point before 1950 and one point per decade after it, plus the last one.
  "All-points" keeps every point. "Time-weighted" weights each point by the interval it
  represents. The 95% t0 intervals assume iid log residuals and are too narrow, because the
  residuals are autocorrelated. Modern compilations are revised estimates, not the 1960 figures
  von Foerster used.
* **B.** Brain = 1e13–1e17 FLOP/s and lifetime = 1e9 s. Realized price-performance is measured
  as training FLOP per dollar of training cost in the Epoch data (152 models, 2015–2023). It is
  converted to peak FLOP/s per $1000 of purchased hardware with utilization u = 0.35 (the median
  in the Epoch data) and purchase-price/rental-rate τ = 1.5 yr. These are assumptions: each
  factor of 2 shifts the $1000 dates by 2.24 years. Frontier compute is the top-5 models in each
  trailing year, fitted over 2010–Sep 2024 and extrapolated after the data end, so it misses
  2025–26 models.
* **C.** Frontier means a new record 50% horizon within the same suite. The two suites are fitted
  separately. METR reports that horizons above ~16 h are unreliable on TH1.1.
* **D/E.** The prediction list is small and selected for fame, which correlates with apparent
  success, and its forecasters are not independent. Δ models: an empirical kernel density
  (bandwidth 3 years, with leave-the-person-out variant), lognormal (median 20 or 30 years) and
  uniform 10–50 years. For von Foerster, the chance of a hit is the share of plausible fits a
  1960 analyst could have made (data to 1940 or 1958, start 1/1000/1500/1700, three sources,
  three weightings, k free or 1) that land in 2025–2030.

## Paths that stay on the working branch

None of this folder is scratch. `data/raw/` holds ~42 MB of third-party data, most of it METR's
`runs.jsonl` files, and `fetch_data.sh` re-creates it. Whoever publishes can leave `data/raw/`
out of `main` and point to `fetch_data.sh`.
