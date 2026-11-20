# Quantitative sensitivity of "AGI by year n" forecasts: robust, or lucky?

Scope: reproducible computations testing how much each forecast's date moves under reasonable changes of inputs, and how likely hits near 2027 are by chance. Everything below was computed on 20 Nov 2026 by the scripts in `agi-timeline-arguments/analysis/` (run `bash run_all.sh`; data provenance and pinned commits in [analysis/README.md](../../analysis/README.md)). Links to `outputs/` and `figures/` point at the generated tables and PNGs.

Network constraint that shapes all sections: this session could reach only GitHub, arXiv and package registries. ourworldindata.org, epoch.ai, metr.org, aiimpacts.org and Google Docs were blocked, and the web-search quota ran out early. So: population/GDP data come from Roodman's GitHub archive and OWID's GitHub dataset repo; METR data from METR's GitHub repo (raw runs, horizons recomputed); Epoch data from a third-party GitHub snapshot (models to Sep 2024); the AI-predictions list is hand-built (the MIRI dataset could not be downloaded). Values transcribed from books/papers that could not be re-opened are flagged.

## A. How robust is the hyperbolic "singularity date" (von Foerster 2026.87; Roodman-style GWP fits)?

### Takeaway
The date 2026.87 is not a robust property of the population data: refitting N = C/(t0 − t)^k to modern compilations of the data von Foerster could have had (to 1940/1958) gives a median t0 of 2036 with a 10–90% range of 1985–2127, and only 8% of 144 plausible fits land in 2025–2030 (3% with k free, 14% with k fixed at 1). For GWP, the deterministic fitted singularity recedes almost one-for-one with the data cutoff (≈1 year of t0 per year of data since 1960), so it has always looked 10–25 years away; with data to 2019 it lands anywhere from 2023 to 2108 depending on start date, source and weighting.

### Cited Findings
- von Foerster, Mora & Amiot (1960) fitted N = 1.79×10^11/(2026.87 − t)^0.99 to population estimates from 1 AD to 1958, quoting t0 = 2026.87 ± 5.50 — [Science 132:1291](https://doi.org/10.1126/science.132.3436.1291) (values as widely quoted; the paper was not re-opened in this session). Their curve implies only ≈95 million people in 1 AD and 2.7 billion in 1958 (computed from the formula), versus 168–235 million (Kremer composite 168, Cohen average 235, HYDE 232) and ≈2.9 billion in modern compilations — [Roodman GWP.xlsx](https://github.com/droodman/Modeling-Human-Trajectory), [outputs/a_von_foerster_reproduction.txt](../../analysis/outputs/a_von_foerster_reproduction.txt).
- **Reproduction attempt (1 AD–1958, three modern sources × three weightings):** with k free, t0 = 1975–2002 and k = 0.59–0.76, not 2027 and 0.99; with k fixed at 1, t0 = 2062–2225 — [outputs/a_von_foerster_reproduction.txt](../../analysis/outputs/a_von_foerster_reproduction.txt). In-sample, k = 1 fits markedly worse (RMSE in log N 0.10–0.19 vs 0.05–0.13).
- **Closest reproductions** need a later start: HYDE/UN 1500–1958, k free → t0 = 2028.3, k = 0.96 (rough 95% profile interval 2006–2062); Kremer/McEvedy-Jones composite 1700–1958, k = 1 → 2029.3 (2024–2035); HYDE 1700–1958, k = 1 → 2031.1 — [outputs/a_hyperbolic_fits_all.csv](../../analysis/outputs/a_hyperbolic_fits_all.csv).
- **"1960 analyst" ensemble** (cutoff 1940 or 1958; start 1, 1000, 1500, 1700 AD; 3 sources; 3 weightings; k free or 1; 144 fits) — [outputs/a_1960_analyst_ensemble.txt](../../analysis/outputs/a_1960_analyst_ensemble.txt):

  | k | fits | t0 p10 | t0 median | t0 p90 | share in 2025–2030 | share within ±10 yr of 2027.5 |
  |---|---|---|---|---|---|---|
  | free | 72 | 1974 | 2001 | 2072 | 2.8% | 14% |
  | 1 | 72 | 2029 | 2051 | 2140 | 13.9% | 24% |
  | both | 144 | 1985 | 2036 | 2127 | 8.3% | 19% |

- **Start date dominates; cutoff matters too.** Population, k free, thinned weighting: start 1 AD gives t0 ≈ 1943–2041 across cutoffs 1900–2019; start 10,000 BCE gives 2150–4100 (an exponential-like fit with k ≈ 2–5); start 1700 gives 2013–2810 (one fit with no finite t0) — [outputs/a_t0_table_pop_free.txt](../../analysis/outputs/a_t0_table_pop_free.txt), [outputs/a_t0_table_pop_k1.txt](../../analysis/outputs/a_t0_table_pop_k1.txt). Across all 714 population fits (3 sources × 5 starts × up to 9 cutoffs × 3 weightings × k free or 1), fitted k ranges 0.44–5.2 and t0 1912 to ~6900 (or infinite); only 0–14% of fits per source × k-mode land in 2025–2030 — [outputs/a_t0_spread_summary.txt](../../analysis/outputs/a_t0_spread_summary.txt).
- **Population fits with later data also recede:** start 1 AD, k free: Kremer/McEvedy-Jones composite t0 = 1999.6 (cutoff 1958) → 2021.0 (2000) → 2040.6 (2019); HYDE/UN 1985.0 (1958) → 2027.6 (2015) — [outputs/a_t0_by_cutoff_start1_kfree.txt](../../analysis/outputs/a_t0_by_cutoff_start1_kfree.txt).
- **Growth rates against the hyperbola's requirement** (for t0 = 2026.87 the growth rate must be 1/(2026.87 − t)): world population grew 1.78%/yr in 1952 and 2.05%/yr in 1968 (requirement 1.35% and 1.68%), but 1.19%/yr around 2012 (requirement 7.0%). The implied singularity date t + 1/g moved from 2009 (1952) to 2016 (1968), 2043 (1988) and 2097 (2012) — [outputs/a_growth_rates_selected.txt](../../analysis/outputs/a_growth_rates_selected.txt), figures [a2_growth_vs_hyperbola.png](../../analysis/figures/a2_growth_vs_hyperbola.png), [a3_implied_singularity_date.png](../../analysis/figures/a3_implied_singularity_date.png). Data: HYDE 2016 + UN WPP 2017 via [owid/owid-datasets](https://github.com/owid/owid-datasets).
- GWP growth was ≈3.4%/yr in 2008–2017, against a vF-hyperbola requirement of 5–10%/yr. Frontier AI training compute grows at ≈1.4–1.7 per year in natural-log terms (4–5×/yr) and METR's frontier 50% horizon grew ≈2.3/yr in 2025. Both are far above the requirement, but their implied date t + 1/g sits only 0.4–0.7 years ahead of each observation: they behave as fast exponentials, not as a hyperbola converging on a fixed date — [outputs/a_growth_rates_selected.txt](../../analysis/outputs/a_growth_rates_selected.txt). Compute data: Epoch "Notable AI Models" snapshot ([GitHub mirror](https://github.com/ManoHarshaSappa/Tracking_State_of_the_Art_AI-Models_and_Performance-), original [epoch.ai](https://epoch.ai/data/notable-ai-models)).
- **GWP, Roodman-style deterministic fits, data to 2019** (Roodman's GWP series in [GWP.xlsx](https://github.com/droodman/Modeling-Human-Trajectory), from DeLong, then Maddison, then the World Bank): with k free, t0 = 2036.0 / 2038.7 / 2087.7 from 10,000 BCE (thinned / all points / time-weighted), 2029.6 / 2036.1 / 2022.5 from 1 AD, and 2043.2 / 2053.5 / 2031.0 from 1500. Fitted k is 1.2–2.3, i.e. growth ∝ level^(1/k) with exponent ≈0.45–0.8. Maddison Project 2020 (1820–2018) gives 2069–2086 with k ≈ 3–3.6. With k fixed at 1, every GWP fit with data to 2019 gives t0 ≤ 2024, i.e. already passed — [outputs/a_hyperbolic_fits_all.csv](../../analysis/outputs/a_hyperbolic_fits_all.csv), [outputs/a_t0_table_gdp_free.txt](../../analysis/outputs/a_t0_table_gdp_free.txt).
- **Receding GWP singularity:** "t0 minus cutoff" for the 1 AD start (k free) stayed at 10–18 years for every cutoff from 1940 to 2019. The drift dt0/dcutoff over 1960–2019 is 0.96 (start 1 AD), 1.00 (1000), 1.09 (1500) and 1.26 (1820) years per year for the Roodman series, and 1.28 for Maddison 2020. The 10,000 BCE start is the exception (−0.90/yr, falling from 2100 at the 1960 cutoff to 2036 at 2019) — [outputs/a_gwp_t0_minus_cutoff.txt](../../analysis/outputs/a_gwp_t0_minus_cutoff.txt), [a_log.txt](../../analysis/outputs/a_log.txt), figure [a1_t0_vs_cutoff.png](../../analysis/figures/a1_t0_vs_cutoff.png).
- Fit check on synthetic data: points drawn from von Foerster's own curve with 3% lognormal noise recover k = 1.00 and t0 = 2033 (profile interval 2026–2041). Small noise alone moves t0 by about 6 years, consistent with von Foerster's ±5.5 — computed in-session with `common.fit_hyperbola` (not saved as an output).

### Inferences
- The 2026.87 date came from three choices: the 1960 vintage of the estimates (low ancient populations), the window, and the near-unit exponent. Modern data favour k < 1 over 1 AD–1958, which pushes t0 into the 1980s–2000s, while forcing k = 1 pushes it to the 2060s+. The "near 2027" result appears only for start dates of 1500–1700 or the 1960 data. In this sense it is a lucky draw: about 1 in 12 under a reasonable ensemble.
- Population growth peaked about a decade after the fit and then fell, so the hyperbola failed for population specifically. The steelman has to rest on a different series. GWP and AI series are the candidates, and none of them currently tracks a hyperbola aimed at 2026.87. Compute and METR horizons grow far faster than required, but with roughly constant (exponential) rates.
- Deterministic GWP singularity dates are poorly identified. They depend on the start date, the weighting and the dataset, a span of about 2023–2108 for data to 2019, and they recede with each decade of new data. Roodman's 2047 comes from a stochastic model and is a different object. Our deterministic analogues bracket it (2023–2054 for the Roodman series with 1 AD–1500 starts) but do not pin it down.

### Gaps
- von Foerster's original 24 data points were not available, so the reproduction uses modern compilations: Kremer/McEvedy & Jones via Roodman, Cohen 1995's average of estimates, and HYDE 2016/UN 2017. The UN WPP (2024) and Kremer's 1993 table were not downloaded directly (population.un.org and JSTOR blocked). Kremer's values appear inside Roodman's composite.
- Roodman's stochastic (Feller-diffusion) model was not re-estimated. Only deterministic power-law fits were run.
- No installed-computing-capacity series could be obtained: the OWID TOP500 and transistor CSVs in the GitHub repo are empty files, and Hilbert & López data were not reachable.
- The 95% t0 intervals assume iid residuals and understate the uncertainty.

## B. Brain-compute forecasts (Moravec / Kurzweil) and a training-corrected version: how far does the date move per OOM of input?

### Takeaway
Under the forecasters' assumed trend (price-performance doubling yearly), each OOM of brain-compute uncertainty moves the "$1000 buys a brain" date by 3.3 years. Under the realized trend (doubling ≈2.2 years), it moves the date by 7.4 years, and the realized date for Kurzweil's 10^16 FLOP/s is ≈2040 rather than ≈2023. The training-corrected criterion moves only ≈1.4 years per OOM while frontier compute grows 5×/yr. Its omissions also largely cancel: ignoring the 10^9 s lifetime multiplier (+9 OOM) is offset by real budgets and rental economics (≈−12 OOM). At 2023 budgets the $1000 criterion therefore equals a training criterion of ≈700 × the lifetime anchor. For 10^16 FLOP/s × 10^9 s at k = 1, frontier compute crossed the anchor in 2023 (GPT-4), the very year Kurzweil (2005) gave for $1000 hardware.

### Cited Findings
- Forecasters' parameters (transcribed from memory; primary texts not re-opened this session): Moravec (1998) put the brain at ≈10^14 instructions/s (100 million MIPS), with $1000 machines reaching it "in the 2020s" — [J. Evolution & Technology](https://www.jetpress.org/volume1/moravec.htm). Kurzweil (1999) used ≈2×10^16 cps reached for $1000 ≈2020; Kurzweil (2005) used ≈10^16 cps for $1000 ≈2023 — [data/manual/brain_compute_forecasts.csv](../../analysis/data/manual/brain_compute_forecasts.csv).
- Realized price-performance from 152 models (2015–2023) with training cost in Epoch's notable-models data: training FLOP per dollar grew ×1.36/yr (doubling 2.24 years). The trend value in mid-2023 is 9.2×10^17 FLOP/$, which converts to ≈5.5×10^13 peak FLOP/s per $1000 of hardware (assuming utilization 0.35 and a purchase-price-to-rental ratio of 1.5 years) — [outputs/b_log.txt](../../analysis/outputs/b_log.txt). This agrees with Epoch's published ≈2.1-year doubling of FLOP/s per $ for ML GPUs — [Epoch, Trends in ML hardware](https://epoch.ai/blog/trends-in-machine-learning-hardware) (via search summary). The ≈2.5-year figure for all GPUs, 2006–2021, is quoted from memory of [Epoch, Trends in GPU price-performance](https://epoch.ai/blog/trends-in-gpu-price-performance).
- **Year in which $1000 buys B FLOP/s** — [outputs/b1_dollar1000_dates.txt](../../analysis/outputs/b1_dollar1000_dates.txt), figure [b1_brain_compute.png](../../analysis/figures/b1_brain_compute.png):

  | brain FLOP/s | Moravec 98 own trend | Kurzweil 05 own trend | realized (2.1–2.5 yr doubling) | realized + 4× low-precision credit |
  |---|---|---|---|---|
  | 1e13 | 2021.7 | 2013 | 2017–2018 | 2013.5 |
  | 1e14 | **2025** | 2016.4 | **2025.3–2025.6** | 2020.9 |
  | 1e15 | 2028.3 | 2019.7 | 2032–2034 | 2028.4 |
  | 1e16 | 2031.6 | **2023** | **2039–2042** | 2035.8 |
  | 1e17 | 2035 | 2026.3 | 2046–2051 | 2043.2 |

  Moravec's hardware date for his own estimate (10^14) matches the realized trend almost exactly. Kurzweil's date for his own estimate (10^16) is about 17 years early. The realized dates are sensitive to the conversion assumptions: each factor of 2 in utilization or hardware economics moves them by 2.24 years.
- **Training-corrected (frontier compute ≥ k × B × 10^9 s).** Frontier training compute (top 5 per trailing year, 2010–Sep 2024) grows ×5.35/yr. Epoch's own frontier flag gives ×5.0/yr. Sevilla et al. found a 6-month doubling over 2010–2022 — [arXiv:2202.05924](https://arxiv.org/abs/2202.05924). Crossing years, with observed crossings to Sep 2024 and extrapolation after that — [outputs/b2_training_anchor_grid.txt](../../analysis/outputs/b2_training_anchor_grid.txt):

  | k \ B (FLOP/s) | 1e13 | 1e14 | 1e15 | 1e16 | 1e17 |
  |---|---|---|---|---|---|
  | 1 | 2017 | 2017 | 2021.7 | **2023.2** | 2024.9 |
  | 10 | 2017 | 2021.7 | 2023.2 | 2024.9 | 2026.3 |
  | 100 | 2021.7 | 2023.2 | 2024.9 | 2026.3 | 2027.7 |
  | 1000 | 2023.2 | 2024.9 | 2026.3 | **2027.7** | 2029.0 |
  | 10^4 | 2024.9 | 2026.3 | 2027.7 | 2029.0 | 2030.4 |

  If growth slows to ×2.5/yr after 2026, the 10^28 FLOP cell moves from 2027.7 to 2029.0 and 10^29 from 2029.0 to 2031.5. At ×1.5/yr they move to 2032.8 and 2038.5 — [outputs/b2_training_anchor_dates.txt](../../analysis/outputs/b2_training_anchor_dates.txt).
- **Years moved per OOM of input** (brain FLOP/s, k, lifetime seconds, or budget) — [outputs/b3_years_per_oom.txt](../../analysis/outputs/b3_years_per_oom.txt): the $1000 criterion moves 3.3 yr at 1-year doubling (the forecasters' assumption), 5.0 yr at 1.5-year doubling, 7.4 yr at the realized 2.24 years and 8.3 yr at 2.5 years. The training criterion moves 1.37 yr at ×5.35/yr, 2.5 yr at ×2.5/yr and 5.7 yr at ×1.5/yr.
- **Cancellation ledger (log10 of the training threshold over the $1000 threshold)** — [outputs/b4_oom_ledger.txt](../../analysis/outputs/b4_oom_ledger.txt): lifetime 10^9 s (+9); spending $10^3 instead of a budget (+3); GPT-4's training cost of $4.1×10^7 in Epoch's data (−7.61); utilization 0.35 (+0.46); renting rather than owning, 1.5 yr = 4.7×10^7 s (−7.68). The net is **−2.8 OOM** at k = 1: the training criterion is reached ≈21 years earlier at the realized hardware trend with the budget held fixed. The two criteria coincide at k ≈ 670.
- **Fast growth compresses date uncertainty** — [outputs/b5_compression_of_dates.txt](../../analysis/outputs/b5_compression_of_dates.txt). With required training FLOP log-uniform over 10^24–10^30, 61% of the probability falls in 2025–2030 if ×5.35/yr continues. The share is 39% if growth slows to ×2.5/yr after 2026 and 24% at ×1.5/yr. For 10^22–10^32 the shares are 36%, 23% and 14%.

### Inferences
- Kurzweil's 2029 looks "right for the wrong reason". His hardware trend was too fast: a yearly doubling against a realized ≈2.2 years puts his $1000 date ≈17 years early for 10^16. But his criterion omitted both the 10^9 s training multiplier and frontier-scale spending, and these roughly offset each other. The realized training-compute path reached the 10^16 × 10^9 s anchor in 2023 and reaches 1000× that anchor around 2027–28. On this reading his date is approximately robust to the error, a cancellation more than a lucky draw. The cancellation is itself contingent, though: it depends on budgets growing about 2.5×/yr, on k ≈ 10^2–10^3, and on B ≈ 10^15–10^17.
- Moravec's 10^14 hardware forecast was accurate on the realized trend. That says nothing about whether 10^14 FLOP/s suffices for AGI.
- Any compute-threshold argument made now will tend to land near 2027–2030, because growth of ×5/yr means wide uncertainty about the threshold maps onto a narrow band of dates (about 1.4 years per OOM). "Near 2027" is therefore the expected output of the method, not evidence of luck or of insight, and it is fragile to a slowdown in spending growth: at ×1.5/yr the date moves 5.7 years per OOM.

### Gaps
- The Epoch data end in Sep 2024. Frontier runs from 2025–26 (reportedly above 10^26 FLOP) are extrapolated, not observed. The GPU price-performance dataset (Epoch ML hardware) could not be downloaded, so price-performance is inferred from training costs, using two stated conversion assumptions (u = 0.35, τ = 1.5 yr).
- The Kurzweil and Moravec numbers (brain estimates, forecast years, assumed doubling times) were transcribed from memory and should be checked against the books and paper before the report quotes them.
- FLOP versus "instructions" or "calculations per second" are not strictly comparable, and the numerical precision (FP32 vs 16-bit vs 8-bit) changes levels by 2–8×. That uncertainty is shown only as a "4× low-precision credit" column.

## C. METR time-horizon extrapolation: how much do the 1-week / 1-month / 1-year dates move with the trend model and window?

### Takeaway
Across 16 fits (two METR task suites; exponential models over five windows; quadratic-in-log and shrinking-doubling superexponential models), the 50% horizon reaches 1 month (167 h) between 2026.7 and 2029.3 (median 2027.7) and 1 year (2000 h) between 2027.0 and 2031.2 (median 2029). For the 80% horizon the ranges are 2027.1–2033.1 for 1 month and 2027.4–2036.3 for 1 year. The task suite matters as much as the trend shape: for the same window, TH1.1 dates come out 0.8–1.6 years earlier than TH1.0. Both of the 2026 releases pull the fits in different directions.

### Cited Findings
- Data: METR raw runs, Time Horizon 1.0 (33 agents, GPT-2 to Claude Opus 4.5) and 1.1 (20 agents, GPT-4 0314 to Claude Opus 4.6 / GPT-5.3-Codex, Feb 2026) — [METR/eval-analysis-public](https://github.com/METR/eval-analysis-public) (commit 52cb829, 5 Mar 2026). Horizons were recomputed with METR's method: weighted logistic regression of success on log2(human minutes), with `invsqrt_task_weight` and regularization 1e-5 as in the repo's `figs.yaml`.
- Recomputed values match the published ones: TH1.1 Claude Opus 4.6 has 11.98 h (50%) and 69.9 min (80%), while METR/aggregators report ≈11h59m and ≈1h10m after a 3 Mar 2026 correction — [METR TH1.1 post](https://metr.org/blog/2026-1-29-time-horizon-1-1/), [datalearner aggregator](https://www.datalearner.com/en/benchmarks/metr-time-horizons-v1-1). TH1.0 GPT-5 is 2.18 h, against ≈2h17m reported, and o1 is 41.5 min, against the paper's 39 min — [outputs/c_agent_horizons_table.txt](../../analysis/outputs/c_agent_horizons_table.txt), [arXiv:2503.14499](https://arxiv.org/abs/2503.14499).
- METR's own March-2025 statement: the doubling time is ≈7 months (207 days, 95% CI 166–240) over 2019–2025, and a 1-month 50% horizon arrives between mid-2028 and mid-2031 (central mid-2029), "or even as soon as early 2027 if the 2024–2025 trend continues" — [arXiv:2503.14499](https://arxiv.org/abs/2503.14499).
- Selected fits (dates as decimal years) — [outputs/c_trend_fits.txt](../../analysis/outputs/c_trend_fits.txt):

  | suite | horizon | model, window | doubling now (days) | 1 week | 1 month | 1 year | implied horizon at 20 Nov 2026 |
  |---|---|---|---|---|---|---|---|
  | TH1.0 | 50% | exp 2019–2025.9 | 201 | 2028.1 | 2029.3 | 2031.2 | 8.3 h |
  | TH1.0 | 50% | exp 2024–2025.9 | 140 | 2027.2 | 2028.0 | 2029.4 | 21 h |
  | TH1.1 | 50% | exp 2023–2026.1 | 129 | 2027.0 | 2027.7 | 2029.0 | 33 h |
  | TH1.1 | 50% | exp 2024–2026.1 | 105 | 2026.7 | 2027.3 | 2028.3 | 64 h |
  | TH1.1 | 50% | quadratic in log h | 66 | 2026.5 | 2026.9 | 2027.5 | 167 h |
  | TH1.1 | 50% | superexp (each doubling 13% shorter; blow-up 2027.6) | 31 | 2026.4 | 2026.7 | 2027.0 | 567 h |
  | TH1.0 | 80% | exp 2019–2025.9 | 211 | 2029.5 | 2030.7 | 2032.8 | 1.7 h |
  | TH1.0 | 80% | exp 2025–2025.9 | 326 | 2031.3 | 2033.1 | 2036.3 | 1.3 h |
  | TH1.1 | 80% | exp 2023–2026.1 | 133 | 2028.0 | 2028.7 | 2030.0 | 5.2 h |

- Bootstrap over frontier models (exponential, 10–90%) for the 50% horizon reaching 1 month: TH1.0 2019+ gives 2028.8–2029.5, TH1.0 2024+ 2027.8–2028.3, TH1.1 2019+ 2027.3–2028.0 and TH1.1 2024+ 2027.2–2027.4. Within one specification the uncertainty is narrow, which shows that the specification is the main uncertainty — [outputs/c_bootstrap_exponential.txt](../../analysis/outputs/c_bootstrap_exponential.txt).
- 2026 hindcast (TH1.1, trained on frontier models released before 2026). For Claude Opus 4.6, the exponential predicted 366 min at 50% against 719 actual (×0.51), and the superexponential models predicted 600–616 min (×0.84–0.86). For GPT-5.3-Codex, the exponential predicted 366 against 350 actual (×1.05) and the superexponential 600–616 (×1.7). At 80%, the exponential predicted Opus 4.6 exactly (70 vs 70 min) and the superexponential models over-predicted ×1.8–2.4 — [outputs/c_hindcast_2026.txt](../../analysis/outputs/c_hindcast_2026.txt).
- Caveats reported by others: METR reportedly treats TH1.1 estimates above ≈16 h as unreliable, and an early "Claude Mythos Preview" was reported at "at least 16 hours" — secondary sources via search summary ([METR TH1.1 post](https://metr.org/blog/2026-1-29-time-horizon-1-1/), [Longterm Wiki](https://www.longtermwiki.com/source/45370a5153534152)). These values are not in our data and were not verified.
- Figures: [c1_metr_horizon_extrapolations.png](../../analysis/figures/c1_metr_horizon_extrapolations.png), [c2_metr_date_spread.png](../../analysis/figures/c2_metr_date_spread.png).

### Inferences
- The 50% "1 month" date is fairly robust to the trend model. All fits fall in 2026.7–2029.3, because the horizon is only about 3.5–4 doublings away from Feb-2026 levels (12 h → 167 h), so even a 2× change in doubling time shifts the date by about 1–2 years. The 80% horizon and the 1-year threshold spread more widely (to 2033–2036).
- The near-2027 dates come from TH1.1 and the 2024+ windows. The full-history TH1.0 exponential (METR's original method) gives mid-2029, matching the March-2025 paper. So whether this argument "lands near 2027" depends on which suite and window one believes, a choice worth about 1.5 years.
- Superexponential fits currently look over-fitted: they put today's horizon at 167–567 h and blow up in 2027.6. The 2026 hindcast is mixed: they catch Opus 4.6 at 50% but over-predict GPT-5.3-Codex and both 80% values. Neither model family is clearly vindicated by the two 2026 points.

### Gaps
- No METR measurements after Feb 2026 were available, so the fits cannot be checked against the models of Mar–Nov 2026.
- The fits ignore per-model confidence intervals (METR's bootstrap over tasks) and the reported unreliability of horizons above 16 h. They also say nothing about how the horizon on METR's software tasks maps onto "AGI".

## D. Base rates of historical AI predictions: horizon distribution and share landing in 2025–2032

### Takeaway
On a small hand-built list of 13 well-known dated pre-2012 predictions (the MIRI/Armstrong–Sotala data could not be downloaded), predictions typically pointed 20–35 years ahead (median 30). 31% of the point predictions fall in 2025–2032: all four are hardware-extrapolation forecasts made 1998–2009, and none of the seven judgment or survey predictions does.

### Cited Findings
- The MIRI AI predictions dataset contained ≈95 predictions (Armstrong & Sotala 2012), and AI Impacts produced an edited version of ≈65 with a "median" year per statement — [AI Impacts: MIRI AI Predictions Dataset](https://aiimpacts.org/miri-ai-predictions-dataset/) (via search summary). It could not be downloaded, because aiimpacts.org and Google Docs were blocked.
- Hand-built list, with quotes and citations in [data/manual/ai_predictions.csv](../../analysis/data/manual/ai_predictions.csv). Its members are Turing 1950→2000, Good 1965→2000, Simon 1965→1985, Minsky 1967→~1997, Minsky 1970→~1975, Michie survey 1973→~2023, Vinge 1993→2023 (2005–2030), Moravec 1998→2020s, Bostrom 1998→≤2033, Kurzweil 1999→2029, Moravec 1999→2040, Kurzweil 2005→2029 and Legg 2009→2028. Sources include [Turing 1950](https://doi.org/10.1093/mind/LIX.236.433), [Good 1965](https://doi.org/10.1016/S0065-2458(08)60418-0), [Vinge 1993](https://ntrs.nasa.gov/citations/19940022856), [Moravec 1998](https://www.jetpress.org/volume1/moravec.htm) and [Bostrom 1998](https://nickbostrom.com/superintelligence). Quotes and URLs come from memory and were not re-opened this session.
- Horizon (predicted year − year made) — [outputs/d_delta_summary.txt](../../analysis/outputs/d_delta_summary.txt):

  | group | n | median | IQR | range | point in 2025–2032 | range overlaps 2025–2032 |
  |---|---|---|---|---|---|---|
  | all pre-2012 | 13 | 30 | 24–35 | 5.5–50 | 31% | 46% |
  | hardware extrapolation | 6 | 28.5 | 25–34 | 19–41 | 67% | 83% |
  | other (judgment/survey) | 7 | 30 | 25–42.5 | 5.5–50 | 0% | 14% |
  | made before 1990 | 6 | 32.5 | 22.5–46 | 5.5–50 | 0% | 0% |
  | made 1990–2011 | 7 | 30 | 25.5–32.5 | 19–41 | 57% | 86% |
  | earliest per person | 10 | 30 | 28–35 | 19–50 | 30% | 50% |

- An OLS fit of horizon on year made has a slope of −0.15 yr per yr (n = 13): later forecasters pointed slightly nearer — [outputs/d_log.txt](../../analysis/outputs/d_log.txt). Figure: [d1_prediction_horizons.png](../../analysis/figures/d1_prediction_horizons.png).

### Inferences
- In this list, landing in 2025–2032 depends almost entirely on when and how a prediction was made: hardware extrapolations made in 1998–2009. Every pre-1990 prediction pointed to 1975–2023 and missed. That fits B: the hardware method, with brain ≈10^14–10^16 and yearly doubling, mechanically yields the mid-2020s for a forecaster working around 2000.
- The 30-year median is longer than the 15–25-year clustering Armstrong & Sotala reported for the full dataset (recalled from their paper, not re-checked). The difference is consistent with a list biased towards famous, long-range statements.

### Gaps
- The main gap: neither the MIRI/Armstrong–Sotala dataset nor AI Impacts' compiled timeline predictions could be obtained. The list is small (n = 13), was selected for fame (which correlates with apparent success), and its transcriptions are partly from memory (4 of 13 flagged as moderate confidence). The hardware-versus-other comparison (4/6 vs 0/7) is suggestive only.

## E. Luck model: how likely is a hit within ±2 years of 2027–28 (2025–2030) by chance?

### Takeaway
For a single forecaster writing in 1993–2009 with a typical 20–35-year horizon, the chance of a hit is 7–25%, so any one hit is unremarkable. Four hits among the 11 well-known forecasters tested (von Foerster, Moravec, Kurzweil, Legg) would be quite unlikely as independent luck (p ≈ 0.002–0.015). It becomes unremarkable once we allow for selection (5–10 chance hits are expected in a pool the size of the MIRI dataset) and for the shared hardware method, which made those hits correlated rather than independent.

### Cited Findings
- Model: a forecaster at year y predicts y + Δ, with Δ drawn from (i) the empirical distribution of D (a kernel density with 3-year bandwidth, leaving out the person's own predictions, or using all 13), (ii) a lognormal with median 20 yr (sd log 0.5) or median 30 yr (sd log 0.4), or (iii) uniform 10–50 yr. For von Foerster, whose date came from a curve fit, P(hit) is also taken from analysis A's 1960-analyst ensemble — [e_luck_model.py](../../analysis/e_luck_model.py).
- Per-forecaster P(hit, 2025–2030) — [outputs/e1_per_forecaster_hit_prob.txt](../../analysis/outputs/e1_per_forecaster_hit_prob.txt), figure [e1_luck_model.png](../../analysis/figures/e1_luck_model.png):

  | forecaster (predicted) | hit | P, empirical leave-out | P, lognormal med 20 | P, lognormal med 30 | P, uniform 10–50 |
  |---|---|---|---|---|---|
  | von Foerster 1960 (2026.87) | yes | ≈0 (Δ = 67); **0.083 from fit ensemble** | 0.004 | 0.012 | 0 |
  | Vinge 1993 (2023) | no | 0.18 | 0.08 | 0.16 | 0.15 |
  | Moravec 1998 (2025) | yes | 0.24 | 0.12 | 0.20 | 0.15 |
  | Bostrom 1998 (2033) | no | 0.25 | 0.12 | 0.20 | 0.15 |
  | Kurzweil 1999 (2029) | yes | 0.20 | 0.13 | 0.21 | 0.15 |
  | Legg 2009 (2028) | yes | 0.07 | 0.25 | 0.15 | 0.15 |
  | Turing, Good, Simon, Minsky, Michie (1950–73) | no | ≤0.03 | ≤0.012 | ≤0.036 | 0 |

- At least m of N = 11 (earliest prediction per person, plus von Foerster), Poisson-binomial. The expected number of hits is 0.74–1.17, against 4 observed. P(≥4) = 0.002–0.015 across Δ models, with P(≥3) = 0.025–0.09 and P(≥2) = 0.16–0.33. For a ±1-year window (2026–2029), 3 hits are observed and p = 0.018–0.026 under the empirical model. For ±5 years (2022–2033), 7 hits are observed and p < 10^-4 — [outputs/e2_m_of_n.txt](../../analysis/outputs/e2_m_of_n.txt), [outputs/e2_m_of_n_all_windows.csv](../../analysis/outputs/e2_m_of_n_all_windows.csv).
- The four headline hits jointly (von Foerster from the fit ensemble): P(all four) = 0.0003–0.0006; P(Moravec, Kurzweil and Legg all hit) = 0.003–0.007 — [outputs/e3_four_hits.txt](../../analysis/outputs/e3_four_hits.txt).
- Selection: with the list's mix of years made, the mean per-prediction P(hit) is 0.07–0.11. That gives 7–10 chance hits expected in a 95-prediction pool (the original MIRI dataset size) and 5–7 in a 65-prediction pool (the AI Impacts edit) — [outputs/e4_pool_expected_hits.txt](../../analysis/outputs/e4_pool_expected_hits.txt).

### Inferences
- "They just got lucky" holds individually but strains collectively, under the assumptions of independence and an unselected sample. Both assumptions fail. (a) The famous hits are drawn after the fact from a pool in which 5–10 chance hits are expected. (b) Moravec, Kurzweil and Legg share a method (hardware extrapolation around 2000, brain ≈10^14–10^16, roughly yearly doubling), and Legg explicitly built on such arguments. B shows that this method mechanically outputs the mid-to-late 2020s for forecasters writing in 1998–2009. Their hits are one correlated draw, not three independent ones.
- The defensible statement for the report: the near-2027 cluster is better explained by method plus timing than by insight or by pure chance. Hardware-trend arguments made around 2000 had to land in the 2020s. Kurzweil's hardware-trend error was largely offset by ignoring training cost and spending (B). von Foerster's date is a ≈1-in-12 draw from plausible 1960 fits (A). None of these "hits" is yet a verified success: as of 20 Nov 2026 they are coincidences of predicted dates, not confirmed arrivals.

### Gaps
- The Δ base rate comes from the same small, fame-selected list, or from parametric stand-ins for Armstrong & Sotala's reported 15–25-year clustering (recalled, not re-checked). With the real MIRI dataset (≈95 predictions, many from the 1990s–2000s) the per-forecaster probabilities and pool expectations should be recomputed.
- Dependence between forecasters is not modelled. A shared-method model, such as a mixture over methods, would be the next step.
