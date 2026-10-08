# October 2026 empirical additions

**Three additional analyses are complete, covering two related empirical domains. They strengthen evidence for local software headroom and heterogeneous returns, but do not identify a cosmic stopping distribution.** The two NanoGPT analyses concern the same task and must not be counted as independent domains. The controlled-pretraining experiment was mentioned in the prior calibration; the new contribution is numerical refitting, checkpoint validation, holdouts and a source audit.

The analysis files are in `research_oct2026/empirical`. Sources and small datasets are frozen, analyses run offline, failed fits remain in the results, and the previously aborted Stockfish CPU-year sheet was not accessed.

## Findings suitable for the report

| Analysis | What is measured | Main result | What remains unidentified |
|---|---|---|---|
| Accepted NanoGPT recipe frontier | Timed training seconds at a prescribed loss on eight H100s; 46 accepted-date frontier observations after a timing-rule change | Log-efficiency trend 0.924/year (2.52× annually). A historical fitted 170-second floor was overtaken by a 39.9-second record. | Total research input, universal transfer, permanent cost floor |
| METR agent optimization | Six revalidated runtime-gain curves against cumulative API/GPU expenditure; reproducibly digitized from the primary figure | Training through $1,000 poorly identifies later returns. Mean later-budget error: persistence 0.212, log 0.226, finite ceilings 0.302 percentage points. Flexible power extrapolation fails badly. | Raw FLOPs, measurement covariance, future-agent opportunity set, asymptotic tail |
| Controlled pretraining vintages | Fourteen printed compute-multiplier estimates and 50 checkpoint records across selected 2019–2025 recipes/corpora | Apparent recipe saturation reverses with one flagged extrapolation; corpus progress and mixed-domain loss move differently. | Full crossing pipeline, research costs, common multiplier, universal ceiling |

**A concrete failed ceiling forecast.** A floor fit to 19 NanoGPT records from October 2024–January 2025 put the asymptote at 169.6 seconds, with log RMSE 0.0956. Later accepted recipes reach 39.9 seconds. Rules added timed work, so a few-second timing correction cannot explain the gap. In the modern sample, exponential-floor fits instead push the floor near zero; nevertheless a 20-second floor only raises log RMSE from 0.0926 to 0.0962. A local plateau neither proves permanent exhaustion nor excludes a finite eventual floor. [Primary record source](https://github.com/KellerJordan/modded-nanogpt/blob/4ea6b937337a4889b8cfe3f38a93d120048d8f71/README.md)

**A direct research-expenditure comparison.** METR's July 2026 NanoGPT experiment includes agent inference and experimental GPU costs, making it closer to research input/output than a calendar regression. Early-budget exponential and hyperbolic ceiling fits reach their effectively linear limits. Full-run fits can recover local plateaus, but the fitted unseen residual gains differ. GPT 5's null and Opus 4.1's small, author-described non-meaningful gain are retained. Persistence versus logarithmic model rankings change with digitization-grid density. These are exploratory held-out-budget checks on six dependent curves, not sampling confidence intervals. [Primary experiment](https://metr.org/blog/2026-07-21-expenditure-horizon/)

**A selection-sensitive controlled result.** Fitting every pretraining vintage gives recipe and corpus log-efficiency trends of 0.096 and 0.237 per vintage-year, with both positive-floor estimates at zero. Removing the authors' extrapolated NeoX crossing makes a recipe floor predict 2024–2025 better: holdout log RMSE 0.0378 versus 0.3462 for exponential progress. For corpora, removing the flagged Pile crossing still favors exponential progress: 0.4986 versus 0.8778 for a floor. At the same nominal compute, 2025 versus 2023 data improves OLMES but worsens mixed-domain NLL by 0.1403 nats. This is evidence for target-dependent progress, not one scalar productivity law. [Frozen author release](https://huggingface.co/j23h67/compute-multipliers-checkpoints/tree/d92bd43970d5fb20a2c987025ae5892343bdb2db)

## Material source corrections and nulls

- **Recipe dates:** 62 of 65 NanoGPT PR merge dates differ from the leaderboard dates. The newest three records were finally accepted in September 2026 despite August table dates. Main fits use acceptance-date running frontiers and retain proposal-date sensitivity.
- **Efficiency units:** NanoGPT seconds and research dollars are not physical FLOPs. Pretraining uses nominal 6ND; its run records' fuller arithmetic counts are 1.166–1.589 times nominal, varying by recipe.
- **Pretraining source discrepancy:** the September 8 article reports marginal recipe/data gains 3.7×/12.0×; the September 13 checkpoint card gives 1.82×/5.39×. Both retain joint 1.57×/year. This conflict is unresolved, and the card contains an inconsistent sentence about multiplying the marginals. The full campaign GitHub link returned 404; released tables and checkpoint records remain available.
- **Dependence:** the 50 checkpoint rows contain 45 cell/seed combinations. Repeated seed labels are clustered. Conditional three-seed sensitivity is much narrower than uncertainty from targets and recipe selection.
- **Unavailable evidence:** no numerical METR trajectory logs were found; its source figure is frozen and digitized explicitly. One latest NanoGPT raw run log is missing upstream. Three public validation losses for another shortened recipe alone do not reproduce its usual acceptance threshold; that is incomplete evidence, not a determination that the record is invalid.

## What likelihood these data can supply

Each fit evaluates a local relationship in its measured units. It can assess whether a candidate curve predicts a small later interval in that same experiment. AICc and least-squares differences here cannot be used directly as likelihood ratios over the report's cosmic-tail families: observations are selected and dependent, error covariance is incomplete, and the link to the common multiplier is unmeasured.

Even perfect measurement of a universal improvement curve over a finite initial interval would leave its remote continuation unidentified. One can construct smooth continuations agreeing throughout that interval and then approaching a ceiling exponentially, approaching it algebraically, or continuing approximately scale-free. Their likelihood on the observed interval is identical. Selecting one globally fixed parametric family rules out those continuations by assumption; it does not obtain evidence against them from the early points.

The scalar model has `dF/dx=a` and hence `k=d ln(a)/dx=da/dF`. None of these experiments identifies both F and a in that equation. Applying the existing k0≈10^-29/FLOP normalization cannot fill this gap. The stopping condition at N=10^120 asks about roughly 91 orders of marginal-return decline, compared with a few vintage years or two expenditure decades in these fits.

**Forecast implication:** use these analyses to support heterogeneous opportunities, possible regime changes, and caution about low ceilings inferred from local plateaus. They provide no human-brain-based headroom cap. They neither empirically recover the previous 10^110 median nor justify replacing it with a precise new exponent. Any revised family weights, tail exponents, and headroom distribution remain explicit model judgments. No numerical cosmic-tail update is made in this package.

## Detailed appendices and outputs

- [NanoGPT vintage methods](controlled_vintage/METHODS.md), [independent source audit](controlled_vintage/AUDIT.md), [results](controlled_vintage/results.json).
- [Agent expenditure methods](rebench/METHODS.md), [digitized data](rebench/digitized_points.csv), [results](rebench/results.json).
- [Controlled pretraining methods](pretraining/METHODS.md), [released multiplier values](pretraining/multipliers.csv), [results](pretraining/results/results.json).
- [Offline reproduction](REPRODUCE.md), [one-command runner](reproduce_all.py), [environment versions](requirements.txt), [machine-readable summary](results_summary.json).

These appendices contain more detail than a short report needs; the preceding results and identification limits are the intended synthesis.
