# NanoGPT speedrun: controlled hardware and target, uncertain research input

Snapshot: 2 October 2026. This is one additional empirical series, with correlated curve and sampling variants. It is not an independent measurement of universal research productivity. It is related to any agent benchmark that uses NanoGPT optimization, including RE-Bench: those should not be counted as independent task domains.

**Result.** The accepted post-rule-change frontier improves from roughly three minutes in May 2025 to 39.9 seconds in September 2026 on eight H100 GPUs at the same nominal FineWeb loss target. A calendar-time exponential fit has a natural-log efficiency slope of **0.924/year**, or **2.52× per year**, with material timing and sampling sensitivity. The finite-floor and shifted-power fits do not identify additional curvature: they approach the no-floor exponential limit. An older, apparently good finite-floor fit is overtaken by subsequent observations. This supports caution about inferring permanent saturation from a local plateau. It does not identify a cosmic tail or a human-brain efficiency ceiling.

## Sources and the measured quantity

The source is the project-maintained [NanoGPT record table](https://github.com/KellerJordan/modded-nanogpt/blob/4ea6b937337a4889b8cfe3f38a93d120048d8f71/README.md), frozen at commit `4ea6b937337a4889b8cfe3f38a93d120048d8f71`, committed 28 September 2026. The archived file is `README.upstream.md`; `upstream_head.json` records the retrieved commit, and the source manifests contain SHA-256 hashes. All numbered rows of the main track are retained in `records.csv`: 92 numbered records plus two retimings of record 21. No other track or fork is mixed in.

The target is mean cross-entropy at most 3.28 on the prescribed FineWeb validation tokens, using eight NVIDIA H100 GPUs. Define the observed cost **C** as the source-reported *timed training seconds*, converted from decimal minutes by multiplying by 60. Local efficiency relative to a reference recipe is `C_reference / C`. GPU-seconds equal `8 C`, so they yield the same ratios. Neither seconds nor GPU-seconds are raw FLOPs. The source's same-node comparison requirement controls hardware more strongly than a regression over unrelated models, but memory access, precision, GPU utilization and software versions vary. Compilation, warmup and final evaluation are not all in the headline timed region. No peak-FLOP conversion is applied.

The benchmark permits architecture, optimizer, kernel and evaluation-context changes. It is thus fixed target loss and hardware family, **not fixed model, context length, active parameter count, data consumption or inference cost**. The latest recipe uses a very large sparse embedding table. A lower number is real progress on the stated benchmark; transfer to general model utility, other datasets, efficient inference, or a universal shared multiplier requires evidence outside this series. The fixed public validation target also permits adaptive benchmark specialization.

## Date and timing audit

Three versions of recipe 21 are reported: 2.933 minutes on 26 January 2025, 2.997 after timing changes on 1 February, and 3.014 after a PyTorch retiming on 24 May. The rule change counted previously untimed training steps and restricted expensive compiler tuning. These rows are not three discoveries. The primary analysis begins with the **24 May 2025 retiming at 180.84 seconds** plus records 22–92: 72 candidate rows. It does not splice earlier measurements into this fit by inventing a constant overhead correction.

The public table's dates often precede final validation or acceptance. We froze primary GitHub metadata for **all 65 linked post-rule record PRs**, extracting `created_at`, `merged_at`, identifying fields and URLs into `pr_metadata.json`. Sixty-two of the 65 merge dates differ from the table dates; lags range from zero to 89 days. `date_audit.csv` retains every difference. Examples:

| Record | Table date | Acceptance date | Why it matters |
|---|---|---|---|
| 90 | 2026-08-03 | 2026-09-18 | Maintainer shortened the training run during final validation. |
| 91 | 2026-08-06 | 2026-09-18 | Mask construction was moved into timed work, then step count changed. |
| 92 | 2026-08-30 | 2026-09-28 | The final accepted version followed a month of review. |

For the primary chronology, use merge date where present and the reported date otherwise. Sort these observations, take the lowest cost on each date, then retain the running minimum. This avoids treating out-of-order merges or inferior same-day recipes as new frontier records. It yields **46 dated frontier points**. Same-day collapsing drops the 180.84-second anchor in favor of record 22's 179.4 seconds, so the fitted frontier's first point is 179.4 seconds. The explicitly retimed reference improves 4.532× to 39.9 seconds; the first daily frontier point improves 4.496×.

Merge date measures accepted availability, not the time an idea was discovered. Review queues can create artificial bursts. The **source-date chronology** (66 daily frontier points) is retained as a sensitivity, not treated as equivalent ground truth. Neither is a formally preregistered, contemporaneous forecast dataset: the history was recovered retrospectively from the present repository. No post-snapshot date is included.

The independent [source audit](AUDIT.md) documents the relevant PR discussions. In particular, the latest record's 1.85× same-node result compares **record 92 with record 89**, not with record 91. Its archived statistics report 18 runs at 39.914 seconds, sample SD 0.120, interleaved with nine baseline runs at 73.889 seconds, SD 0.137. One candidate raw log was lost; its ledger entry is included in the source's 18-run summary, and only 17 logs are archived upstream. We freeze the source statistics and one representative full log per group, not all 26 extant logs. We did not rerun the GPU experiment. [Archived record-92 report](https://github.com/KellerJordan/modded-nanogpt/blob/4ea6b937337a4889b8cfe3f38a93d120048d8f71/records/track_1_short/2026-08-30_ANVIL2/README.md)

The maintained HEAD differs from that measured trainer. A later maintainer check reports 40.60 seconds for the record trainer and 40.90 for the refactor. We therefore retain a **40.60-second endpoint sensitivity**. The full-sample exponential slope changes only from 0.9236 to 0.9206/year. This is version sensitivity, not an independent progress observation. [PR 373](https://github.com/KellerJordan/modded-nanogpt/pull/373)

## Fit definition, optimization and holdouts

Let `t` be elapsed days since the first point of the fitted series, divided by 365.25. Fit all curves by unweighted least squares in **log C**, so errors reflect proportional runtime error:

1. Exponential: `C(t) = B exp(-r t)`, with `r ≥ 0`.
2. Shifted power: `C(t) = B (1+t/τ)^(-p)`, with `τ > 0, p > 0`.
3. Exponential approach to a floor: `C(t) = c + A exp(-r t)`, with `c > 0, A > 0, r > 0`.

These are competing local descriptions. A decaying runtime exponential is not a statement that physical cost can go to zero. A constant fitted floor is not a measured lower bound. Monotonicity is imposed because the observation is a record frontier, not an arbitrary single submission.

`fit.py` profiles the shifted-power likelihood over log τ; conditional on τ, the intercept and exponent are an ordinary linear fit. It evaluates a 151-point grid and refines near the best cell, also checking both boundaries. Allowed τ is one day through 1,000 years, and p is at most 1,000. The other models use deterministic multi-start bounded nonlinear least squares. Positive floor parameters are evaluated through a stable `logaddexp` expression. The lower numerical floor bound is `exp(-25)` times the smallest training cost. Large τ with p/τ finite is the exponential limit; the corresponding boundary is reported as nonidentification, not as a 1,000-year measured scale.

Fits use three predetermined calendar splits: through 31 December 2025, 31 March 2026, and 30 June 2026, evaluating all later observations without refitting. These cutoffs span year-end, later integration, and the final burst. The final record is in every holdout. Log RMSE is the root mean square of `ln(predicted seconds / observed seconds)`. A single chronological trajectory, selected successes and shared code violate iid assumptions, so the displayed errors are descriptive holdout errors, not confidence intervals from independent observations.

| Accepted-date training cutoff | Train / holdout points | Exponential rate, log/year | Holdout log RMSE | Predicted final seconds | Actual final seconds |
|---|---:|---:|---:|---:|---:|
| 2025-12-31 | 20 / 26 | 0.6505 | 0.2133 | 76.03 | 39.90 |
| 2026-03-31 | 37 / 9 | 0.9593 | 0.1485 | 54.94 | 39.90 |
| 2026-06-30 | 42 / 4 | 0.9180 | 0.2106 | 56.96 | 39.90 |
| Full sample | 46 / 0 | 0.9236 | — | 56.78 fitted endpoint | 39.90 |

The alternatives collapse close to the exponential limit for these main fits: their holdout errors differ by less than 0.00011. The shifted-power shift reaches the 1,000-year bound, and the floor estimates are of order `10^-9` seconds, effectively zero at this dataset's resolution. These are failed identifications of extra curvature, not evidence for an enormous power exponent or near-zero physical runtime limit. The full exponential log RMSE is 0.09263. The saved AICc values count all curve parameters plus one estimated Gaussian residual-variance parameter: `K = k + 1`, with correction `2K(K+1)/(n−K−1)`. AICc is undefined when `n ≤ K+1`. These are conventional descriptive penalties and must not be used as independent-observation Bayes factors. This variance-parameter bookkeeping was corrected during the statistical review; the curves and holdout errors did not change.

Monthly-end sampling retains the last available accepted record each month plus the final record date, producing 17 points; repeated months are not additional experiments. Its full exponential rate is **0.9603/year**, versus **1.0051/year** on source dates and **0.8534/year** when the final record is removed. This 0.85–1.01 spread describes the selected sensitivity set, not a statistical coverage interval. Removing the final record cuts the December-fit holdout error from 0.2133 to 0.1752 but leaves subsequent gains. Dropping record 91 alone would leave the final record and broad conclusion intact; it is flagged in the audit because its mechanism changes validation.

## What the floor results fail to establish

A fixed-floor profile reoptimizes the exponential gap while varying the floor from zero to 99% of the latest observed runtime. The best profile is at zero, but **a 19.95-second floor gives log RMSE 0.09618**, only slightly above 0.09263; a 35.91-second floor gives 0.10253. Thus the point optimum at zero does not exclude finite residual headroom. `floor_profile.csv` reports the complete profile without interpreting its SSE differences as calibrated probability mass.

As a separate diagnostic, fitting the same exponential-floor form to the 19 older records from 4 October 2024 through 26 January 2025 gives a **169.59-second floor** and log RMSE **0.09556**. Later costs, measured under rules that add timed work, are far below that floor: 67.56 seconds by record 91 and 39.9 by record 92. The timing change of a few seconds cannot explain this gap. This historical extrapolation is not a pooled fit across timing regimes and is not counted as another domain. It demonstrates how an apparently good local saturation fit can be falsified by later innovations or changes in the available design space.

## Selection, nulls and implications for the foom–coom forecast

Only accepted records are observed. Failed experiments, rejected PRs, training runs used in search, labor and agent inference compute are missing. We do **not** rename successful-record count as research input. These data are stronger evidence for task-level software efficiency progress than for decreasing returns to research. They cannot estimate `d ln a / dF`, `dF/dx = a`, or a raw-FLOP research-production exponent without an additional research-input model. They also do not discriminate between human and agent contributions despite several records naming AI collaborators.

Null and unfavorable findings are retained: two retimings; 62 date discrepancies; nonidentified shifted-power curvature; no positive fitted floor in the modern sample; a weak floor profile; a falsified older plateau extrapolation; endpoint-version sensitivity; one missing final-record raw log; and a partial validation check for record 90. That last check uses three printed final losses and gives one-sided Student-t p≈0.071, so those three observations alone do not reproduce the nominal p<0.01 gate. This is incomplete validation evidence, not proof that the accepted record is invalid, because other runs may exist. The earlier, longer recipe's p-value must not be copied to the shorter final recipe. See `AUDIT.md` for exact arithmetic and source links.

For `N=10^120` and `k0≈10^-29/FLOP`, no new numerical stopping distribution is fitted here. Mapping this calendar trend into cumulative raw research FLOPs would require an assumed growth rate and constant research share; mapping it into effective research would require specifying the shared feedback without double-counting it. Either operation adds unidentified assumptions. There are vastly many improvement laws that match these observations and the starting calibration but diverge over the roughly 91 orders of marginal-return decline relevant to the stopping condition `d ln a/dx = 1/(N−x)`.

The appropriate forecast update is qualitative and limited: add a recent, fixed-target/fixed-hardware case of substantial software headroom and a concrete failed local-ceiling extrapolation; retain broad uncertainty about future research-effort returns. It supplies no reason to cap universal efficiency at human-brain efficiency, no empirically calibrated probability of unlimited improvement, and no basis for moving a subjective `10^110` median to a new precise exponent.

## Artifacts

`records.csv` preserves all 94 table rows; `main_records.csv` selects 72 post-rule rows; `date_audit.csv` exposes date differences. The five derived series CSVs, `fit_summary.csv`, `results.json`, `floor_profile.csv` and `holdouts.png` contain all reported numerical results. `fit.py` reruns offline; `fetch_sources.py`, `fetch_audit.py` and `fetch_pr_dates.py` document retrieval. `REPRODUCE.md` gives commands. All files are under `research_oct2026/empirical/controlled_vintage/`.
