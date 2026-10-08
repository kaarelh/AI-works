# NanoGPT agent optimization curves: an additional empirical validation

Analysis frozen 2 October 2026. The folder name `rebench` reflects the original search assignment; the implemented dataset is METR's **July 2026 NanoGPT expenditure experiment**, not the original 2024 RE-Bench benchmark. Nothing in the prior `empirical_methods` report fitted these trajectories.

**Finding:** Short observed plateaus do not identify a permanent efficiency ceiling. In six current published optimization runs, curve fits trained through $1,000 give unstable predictions for later spend. Two finite-ceiling forms run to their effectively linear limit on every nonflat early trajectory. Using the entire trajectory makes finite ceilings fit some runs, but those ceilings remain conditional descriptions of a single fixed-model search process. They do not measure the attainable efficiency of future researchers or algorithms.

## Source and selection

Primary source: Tom Cunningham, Manish Shetty, Vincent Cheng and Nate Rush, [“Expenditure Horizon: Measuring Optimization Ability, with an Application to NanoGPT”](https://metr.org/blog/2026-07-21-expenditure-horizon/), METR, **21 July 2026**. Data are recovered from the [published revalidated cumulative-return figure](https://metr.org/assets/images/expenditure-horizon/returns-to-expenditure_mobile_1.png), labeled CC-BY by its authors. The article and three original figures are frozen under `source/`; `manifest.json` gives original URLs, retrieval date, SHA-256 and byte lengths. The analysis does not require further network access.

I use **all six curves shown**; there is no best-model selection. All runs start from record #78. Spend is the sum of model API and experimental GPU expenditure. The hardware target is an eight-H100 training run; the agent harness has four such nodes. The output is training-runtime improvement at the benchmark's fixed loss target. It is neither a FLOP count nor an efficiency gain at an invariant algorithm/hardware utilization. The source uses repeated post-run checks of apparent improvements. These checks do not remove every possible selection, threshold-tuning, or generalization issue. In particular, the plotted gain and the maintainer's estimate of what is worth merging are different quantities.

The analysis begins at **$100**. This avoids crowded/overlapping early lines and treats the first quick improvements as sunk. The first point is the fixed baseline for subsequent curve fitting. This is an analyst choice; the work does not estimate the return to the first $100. Endpoints differ by agent, so each model is predicted only through its own plotted endpoint. Within-run expenditure order, not model-release calendar time, defines the holdout.

| Published model label | Digitized endpoint spend, approximate USD | Plotted cumulative speedup, % |
|---|---:|---:|
| Opus 4.8 | 10,009 | 1.501 |
| GPT 5.5 | 5,674 | 0.952 |
| Opus 4.5 | 2,068 | 0.350 |
| GPT 5.2 | 3,630 | 0.507 |
| Opus 4.1 | 2,388 | 0.222 |
| GPT 5 | 4,935 | 0.000 |

These are pixels converted back to values, not extra precision supplied by METR. The paper describes GPT 5 and Opus 4.1 as having no meaningful improvement; retaining the small positive Opus 4.1 plotted value does **not** assert its statistical or practical significance. The other curves also should not be read as six independent representative draws from future agents.

## Digitization and audit

No numerical curve file was linked in the article when checked. I also inspected the public METR repository listing, RE-Bench and evaluation-resources repository trees, and the public evaluation-analysis data listing; I did not find a released NanoGPT expenditure-trajectory table. This is a record of the search, not proof that none exists elsewhere. Instead of inventing timestamps or treating a visual estimate as a raw log, this analysis freezes the raster evidence and an executable extractor.

The original mobile panel is 1880 × 1735 pixels. The horizontal ticks at $10, $100, $1,000 and $10,000 have centers at x = 307.5, 803.5, 1298.0, 1792.5. Least squares gives

```
x_pixel = -187.0 + 494.95 * log10(expenditure_usd).
```

The nine y ticks from 0 to 1.6 in steps of 0.2 yield

```
y_pixel = 1494.3888889 - 728.125 * speedup_percentage_points.
```

The script records six manually audited legend RGB values and endpoint-marker centers. At each column it takes a contiguous exact-color segment of at least three pixels, excludes the legend and a series-specific upper region, and uses its center. At a vertical transition, the upper edge plus two pixels represents the achieved, right-side improvement. Marker endpoints use their audited center rather than the marker radius. GPT 5's early zero line is covered by another zero line, so it is filled with zero, consistent with its visible later trace and the authors' null result. Gains below 0.002 percentage points are rounded to zero to suppress subpixel baseline artifacts.

The long trace is frozen in `digitized_pixel_trace.csv`. A common log-spend grid, **16 points per expenditure decade**, plus each final endpoint creates 166 response samples in `digitized_points.csv`. They are grid samples of six dependent step functions, **not 166 independent experiments**. This grid prevents a visually long plateau from gaining weight simply because an author logged it more frequently. It does give equal weight to intervals in log expenditure; a linear-dollar weighting would answer a different question. I inspected the generated six-panel plot against the source figure.

One vertical pixel is 0.00137 percentage points; a two-pixel vertical ambiguity is about 0.00275 percentage points. Two horizontal pixels change implied expenditure by about 0.94%. This digitization uncertainty is much smaller than the largest prediction errors, but it is not the source's experimental uncertainty. The source's shaded error bands are not digitized or used as independent error bars. The source has run-level measurement noise and within-run multiple comparisons that pixels cannot recover.

## Curve definitions and validation

Let E denote total run expenditure in USD, E0 = 100, s(E) the **published speedup in percentage points**, and s0 = s(100). The primary fits minimize squared errors in s, with s0 fixed. I deliberately do not convert the displayed speedup into a supposed universal efficiency multiplier. For these sub-2% gains, the ordinary speed-ratio versus runtime-reduction convention would only make a small numerical difference, but the universal-multiplier interpretation is unjustified.

The compared functions are:

| Name | s(E) − s0 | Parameters |
|---|---|---|
| No progress after $100 | 0 | none |
| Last observation | s(1000) − s0 for predictions | persistence benchmark |
| Constant marginal gain | b(E−100)/1000 | b ≥ 0 |
| Logarithmic | b ln(E/100) | b ≥ 0 |
| Power gain | b[(E/100)^p−1] | b ≥ 0, 0.02 ≤ p ≤ 3 |
| Exponential ceiling | A[1−exp(−(E−100)/τ)] | A ≥ 0, exp(−2) ≤ τ ≤ exp(20) dollars |
| Hyperbolic ceiling | A(E−100)/(τ+E−100) | same bounds |

For each candidate shape parameter, amplitude has a nonnegative least-squares closed form. A 300-point search followed by bounded scalar optimization picks the shape. Endpoint-boundary solutions are flagged in `results.json`. Zero-amplitude curves have unidentified shape parameters regardless of the optimizer's arbitrary returned parameter. The power bound allows short-run accelerating gains, and reaching it is retained as a failed fit rather than suppressed.

Train on **E ≤ $1,000** and predict all later grid points. This cutoff and curve list were chosen after seeing the source figure, so this is exploratory out-of-sample validation within the run, not a preregistered or blinded test. `fit_comparison.csv` reports each model and curve; `results.json` additionally retains training-only parameters, full-budget fits, boundaries, endpoints and four deterministic sensitivity analyses. RMSE is measured in percentage points of the plotted speedup. The aggregate metric is the arithmetic mean of the six per-agent RMSEs, giving each run equal weight. No information criterion, p-value, bootstrap over pixels, or population confidence interval is reported.

## Results and failed fits

| Candidate | Mean per-agent later-budget RMSE, percentage points |
|---|---:|
| Last observed result | 0.212 |
| Logarithmic | 0.226 |
| Constant marginal gain | 0.302 |
| Exponential ceiling | 0.302 |
| Hyperbolic ceiling | 0.302 |
| No progress after $100 | 0.354 |
| Flexible power gain | 35.999 |

The persistence baseline is slightly better than the logarithmic curve on the primary grid. This tiny ranking difference is not robust: on eight points per decade their errors are 0.224 and 0.223. Logarithmic versus persistence selection therefore should **not** determine a forecast family. Both are more stable here than the highly flexible power gain. The per-run comparison is:

| Agent | Persistence | Logarithmic | Constant marginal | Power gain |
|---|---:|---:|---:|---:|
| Opus 4.8 | 0.601 | 0.661 | 1.045 | 210.417 |
| GPT 5.5 | 0.420 | 0.425 | 0.573 | 4.485 |
| Opus 4.5 | 0.089 | 0.089 | 0.089 | 0.089 |
| GPT 5.2 | 0.100 | 0.107 | 0.041 | 0.539 |
| Opus 4.1 | 0.060 | 0.074 | 0.063 | 0.463 |
| GPT 5 | 0 | 0 | 0 | 0 |

The largest flexible-power error is physically nonsensical as a long-run runtime-reduction forecast. That is an intended recorded failure: several flat early sections followed by a late step induce an apparent accelerating power. At $1,000, its Opus 4.8 exponent is at the upper bound 3. Expanding or changing that bound would change a catastrophic forecast, not create sound evidence about the tail.

The ceiling models find τ ≈ $485 million, the imposed upper boundary, for all four nonflat training curves. Over the available spend these fits are effectively linear. The two flat training curves (Opus 4.5 and GPT 5) identify zero incremental amplitude and provide no shape information. **Thus these curve families do not estimate a finite plateau for any run from the early data.** Additional observations subsequently change the fit substantially.

For illustration, fitting all available Opus 4.8 points gives an exponential-ceiling increment A = 1.510 percentage points with τ = $3,816; a hyperbolic ceiling gives A = 2.166 with τ = $5,065. For GPT 5.5 the corresponding A values are 0.884 and 1.213, with τ of $1,537 and $1,941. These amplitudes are increments above s($100), not total gains. Each family can describe the observed local slowdown, while their unseen residual gains differ appreciably. These full-data parameters are descriptive fits, not additional holdout evidence.

Changing the sample density from 8 to 32 points per decade leaves aggregate log-curve error around 0.220–0.223, ceiling error around 0.286–0.395, and flexible-power error around 10.8–28.6. Shifting source columns by ±2 pixels gives log error 0.223–0.226 and ceiling error 0.302–0.307. The qualitative findings survive; fine rankings and precise parameters do not. GPT 5 remains a null rather than being excluded.

## Implication for the foom–coom forecast

This evidence is closer to research input versus output than a benchmark score regressed on calendar date. Nevertheless, expenditure includes changing API prices, GPU provisioning, idle time and the harness's search policy. The acquired optimization changes a specific training task; it does not automatically improve the thinking efficiency of the researchers who made it. Therefore **E is not x (raw FLOPs), not F (effective research), and s is not the shared universal multiplier a** in the specified model.

The observations support a local possibility: a fixed agent and search procedure can exhaust accessible improvements, and better agents can find further improvements. They also show why one should not infer a stable research-production law from a short plateau or a late jump. They do not identify a cosmic ceiling, a human-brain ceiling, a tail exponent, or a probability weight on those possibilities. The source's task is already optimized and may contain past agent contributions; selection onto this particular starting point is material.

I make **no numerical update** to the distribution of the optimal raw-FLOP stop from these curves alone. To combine them with k0 ≈ 10^-29/FLOP, N = 10^120 and dF/dx = a would require an explicit, separately defended mapping from spending to F, task runtime efficiency to a, and current fixed-agent exhaustion to future improving-agent research. Normalizing a local curve to k0 cannot supply these missing identifications. If a report uses this experiment to justify tail mass, that step is a model judgment rather than an empirical estimate.

## Searches that did not become fits

- The 2024 RE-Bench public repository provides environments, scoring definitions and baseline summaries. Its time-budget figures aggregate best-of-k attempts and adapt the allocation across budgets; they are not automatically a single accumulating research trajectory. I did not extract those older figures after finding this more direct 2026 source.
- The NanoGPT article includes human-effort estimates partly inferred by an LLM from successful contributions. I did not treat inferred effort as directly measured research FLOPs or fit it as a second independent dataset. Its two contributor interviews cover six selected records and are too limited and heterogeneous to identify a general tail law.
- Numerical NanoGPT run logs were not obtained; raw measurement/replicate uncertainty and maintainer-mergeability adjustments cannot be reconstructed from the six plotted mean curves. Their absence is explicitly preserved.
- No Stockfish CPU-year Google Sheet was fetched.

## Reproduction

From this folder, in an environment with `requirements.txt` installed:

```bash
python digitize_and_fit.py
```

It reads only the frozen PNG, rewrites the two digitized CSVs, `fit_comparison.csv`, `results.json`, and `holdout_comparison.png`. Before importing dependencies it directs Matplotlib and XDG caches into this folder's `.cache/` directory and disables dependency bytecode writes. An optional `python fetch_sources.py` retrieves the four manifest sources and checks their exact hashes; it fails if a source changed. The executed environment used numpy 2.5.3, scipy 1.18.1, matplotlib 3.11.2 and Pillow 12.3.0 in the original frozen analysis environment.
