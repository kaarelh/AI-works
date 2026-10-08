# Independently fitted vision and language-model methods

Analysis date: 2026-09-11; numerical audit and current-anchor update 2026-09-12. These are fresh fits of publicly downloadable observations; the vision observations end in 2019 and language-model observations end in 2023. They are not measurements of universal intelligence or of research FLOPs. The time-to-research-compute bridge below is an explicit additional assumption.

## Sources and frozen inputs

- [Hernandez and Brown, Measuring the Algorithmic Efficiency of Neural Networks (2020)](https://arxiv.org/abs/2005.04305); [authors' observation CSV](https://raw.githubusercontent.com/openai/ai-and-efficiency/master/efficiency_sota.csv). `efficiency_sota.csv` is the downloaded original. Only the six AlexNet-performance rows are used. Compute values, rather than the rounded improvement column, give the final improvement 3.1/0.069 = 44.9275. Input dates are retained exactly as in the source.
- [Ho et al., Algorithmic Progress in Language Models (NeurIPS 2024)](https://proceedings.neurips.cc/paper_files/paper/2024/file/6b066da6a23bc55f9b887e7298102884-Paper-Conference.pdf); [authors' public dataset](https://docs.google.com/spreadsheets/d/11m8O_mU0cUkOB_5wluPne4PNsuvsKNbbVAzbYNy-NXY/edit#gid=91564213); [authors' code repository](https://github.com/epoch-research/lm-algorithmic-progress). `lm_data_analysis.csv` freezes the worksheet used in their notebook. Original notebooks are saved for provenance. The dataset has 408 input rows; cleaning below gives 245 benchmark evaluations from 144 distinct papers.
- [Epoch's current trends page](https://epoch.ai/trends), accessed 2026-09-11: aggregate AI compute capacity growth 3.4x/year, 90% CI 3.2–3.7; frontier model training compute 5x/year, 90% CI 4–6. These are different measures, not interchangeable estimates of exactly the same quantity.
- [Sevilla and Roldán, Training compute of frontier AI models grows by 4–5x/year (2024)](https://epoch.ai/publications/training-compute-of-frontier-ai-models-grows-by-4-5x-per-year): notable-model training compute 4.1x/year over 2010–May 2024, 90% CI 3.7–4.6. This overlaps the historical algorithmic-efficiency observations, but remains a proxy for aggregate R&D compute.
- [Gundlach et al., On the Origin of Algorithmic Progress in AI (2025)](https://arxiv.org/html/2511.21622v1) supplies a relevant conceptual caution, not additional fitted observations here: algorithmic efficiency depends strongly on capability scale and on the reference algorithm. This makes extrapolation to a universal efficiency multiplier especially uncertain.

## The bridge and normalization

Fit calendar efficiency `ln alpha = constant + s*t`. Assume cumulative raw research input `X` scales as `exp(gamma*t)`, giving `alpha proportional to X^p`, with `p=s/gamma`. For the aggregate capacity proxy this additionally assumes a constant research allocation and utilization fraction and an approximately exponential prehistory. For the single-model training-compute proxy, it assumes total research spending tracks training-run size. Historical human R&D and future automated recursive R&D need not obey the same relationship.

Every power-law projection uses the given toy-model normalization `k0=10^-27.5` and total budget `N=10^120`. It does not estimate k0 from these datasets. If x is additional raw research FLOPs, then

`alpha(x)/alpha(0) = (1 + k0*x/p)^p`,

`k(x) = d ln alpha / dx = 1/(1/k0+x/p)`,

`x_stop = p/(1+p) * (N - 1/k0)`,

`x_exact = p * (N - 1/k0)` for the exact `k=10^-120` crossing.

At the economically optimal stop, `k=(1+p)*10^-120` to negligible correction. No extra recursive efficiency factor is applied to p, because X was already defined as raw research compute. A different interpretation as effective research input would require a different law.

## Fits of the observed vision series

Six observations: AlexNet 2012-06-01, GoogLeNet 2014-09-17, MobileNet 2017-04-17, ShuffleNet 2017-07-03, ShuffleNet v2 2018-06-30, EfficientNet 2019-05-28. These all reach the same 79.1% ImageNet top-5 accuracy target.

OLS of log efficiency on date gives s=0.530345/year and R²=0.9823, a 1.700x/year improvement. Theil–Sen gives s=0.544573, a 1.724x/year improvement. OLS on the first three observations gives s=0.490335, and on the last three s=0.405918. These overlap only in calendar adjacency, not observations; each split is extremely small. Fitting the first three and predicting the last three gives log-efficiency RMSE 0.2946 and predicts the last point's efficiency as 34.70x versus actual 44.93x.

| Method | s per year | Stop with aggregate 3.4x proxy | Stop with frontier 5x proxy | Stop with historical 4.1x proxy |
|---|---:|---:|---:|---:|
| All-six OLS | 0.5303 | 3.023e119 | 2.478e119 | 2.732e119 |
| All-six Theil–Sen | 0.5446 | 3.080e119 | 2.528e119 | 2.785e119 |
| First-three OLS | 0.4903 | 2.861e119 | 2.335e119 | 2.579e119 |
| Last-three OLS | 0.4059 | 2.491e119 | 2.014e119 | 2.234e119 |

Exact-threshold values and p for every cell are in `results.json`; `all_answers.csv` gives a flat table. These estimator/subperiod variants are correlated sensitivity checks, not independent studies.

## Independently fitted language-model scaling surface

The 408-row input is filtered to numeric positive parameter count and dataset size, `Include?=1`, `Outlier? !=1`, `uncertain=0`, and dated records. Four models excluded in the authors' notebook are also excluded; the two explicit Gopher parameter-count corrections are retained. Each nonmissing benchmark receives its own actual perplexity, not another benchmark's perplexity. Up to the best three evaluations per paper and benchmark are retained, giving 245 evaluations dated 2012-06-27 to 2023-05-23 from 144 papers. This is an independent re-fit, not an exact reproduction of the published regularized fit/ensemble.

The loss surface is

`L_b = A_b exp(-u*t) P^-a + B_b exp(-v*t) D^-b`,

where L is cross entropy (`ln perplexity`), P is parameter count, D is dataset size, and each benchmark has its own A and B. (The subscript b indexes benchmark; the exponent b is the data-scaling exponent.) At compute-optimal allocation with training compute proportional to P*D, the equivalent compute-efficiency trend is

`s = u/a + v/b`.

This inherits the limitation of dataset size as a proxy for training tokens: varying epochs, caching, adaptation, and data quality are not separately controlled. Model training compute is not the same as research compute. Least squares and robust soft-L1 loss are fitted with positive scale exponents and multiple deterministic starting points. The least-squares fit has R²=0.9094 and cross-entropy RMSE 0.2179. The robust fit has R²=0.9088. Positivity bounds are not active in these reported full-data fits.

| Method | n | s per year | Stop with aggregate 3.4x proxy | Stop with frontier 5x proxy | Stop with historical 4.1x proxy |
|---|---:|---:|---:|---:|---:|
| Nonlinear least squares, all years | 245 | 0.9328 | 4.325e119 | 3.669e119 | 3.980e119 |
| Nonlinear robust soft-L1, all years | 245 | 0.9209 | 4.294e119 | 3.639e119 | 3.949e119 |
| Nonlinear least squares, post-June-2017 | 213 | 0.7548 | 3.815e119 | 3.192e119 | 3.485e119 |
| Nonlinear least squares, pre-2020 only | 133 | 1.4061 | 5.347e119 | 4.663e119 | 4.991e119 |

The pre-2020 fit predicts 112 later evaluations with cross-entropy RMSE 0.2998, versus training RMSE 0.2084. Some benchmark-specific components are nearly absent in that early fit, making extrapolation less stable. Its larger s is a warning about time-window dependence, not strong evidence for a faster future rate. The other post-2017 fit is a robustness/subperiod fit and is not an independent data source.

`bootstrap.py` resamples whole papers to retain dependence between multiple evaluations from a paper, and re-fits the all-years least-squares model 200 times. Each replicate now uses seven deterministic starting points: the six full-data fitting starts plus the main fitted solution, selects the smallest objective, and refines that basin. This corrects a single-start local-minimum problem discovered by an independent audit; the resampled-paper sequence is unchanged. Per-start costs and selected parameters are saved for review. It reports empirical 5th/50th/95th percentile s in `bootstrap_results.json`. This captures sampling variability conditional on the surface, cleaning, and input proxy; it does not address the much larger extrapolation and functional-form uncertainty.

The corrected multistart s percentiles are **0.6236, 0.9794, and 1.5154/year**. The 5th–95th percentile interval maps to stopping at approximately **3.38e119–5.53e119 FLOPs** under the 3.4x proxy. Twenty-three of 200 resampled fits hit at least one parameter bound, although none failed to converge; the interval should therefore be read as a rough model-conditional sensitivity summary. These replace the superseded single-start bootstrap statistics; the full-data fitted parameters are unchanged.

## A genuinely different fitted law: a nonzero compute floor

Fit the vision observations to `C(t)=C_floor+A exp(-s*t)` in log-compute residuals. The best fit has `C_floor` equal to 11.71% of the last observed compute value and 11.24% of fitted compute at the **last observation, 2019-05-28**, with s=0.54507. This is an estimated floor parameter, not an assumed cap matched only to a starting derivative. However, the six data points barely constrain it: allowing a floor reduces the profile deviance by only 0.0636, while adding a parameter. The floor fit's AIC is 1.936 higher (worse). Leave-one-out log-compute RMSE is 0.2952 for the floor model versus 0.2391 for the exponential. Thus the data do not justify selecting the floor model over the no-floor law.

Its normalized forecast is `alpha(x)/alpha(0) = 1/[f+(1-f)(1+x/x0)^(-p)]`, with `p=s/gamma`, `x0=p(1-f)/k0`, and f the floor fraction at the forecast anchor. The historical anchor has `f=0.112414`; the projected current anchor below has `f=0.870932`. This gives

`k(x)=k0*z^(-p-1) / [f+(1-f)*z^(-p)]`, where `z=1+x/x0`.

To start the forecast on **2026-09-12**, project the same fitted calendar curve forward by 7.2936 years, without refitting or adding observations. Then `f_now=f_2019/[f_2019+(1-f_2019)exp(-s*7.2936)] = 0.870932`. Reimpose the user's `k0=10^-27.5` at that projected current anchor, rather than at the historical observation date. The fitted historical parameters remain unchanged. This yields:

| Proxy | log10 stopping FLOPs, projected current anchor | Stopping FLOPs |
|---|---:|---:|
| Aggregate capacity, 3.4x/year | 90.2972 | 1.98e90 |
| Frontier single-run compute, 5x/year | 95.2838 | 1.92e95 |
| Historical notable-model compute, 4.1x/year | 92.9652 | 9.23e92 |

This anchor is a projection of 2019 data, **not a new 2026 efficiency measurement**. Exact-threshold and utility-optimal stopping coincide at the displayed precision because almost the entire 10^120-FLOP budget remains. The prior values are retained below as an explicitly **2019-05-28 anchor sensitivity**, with the same k0 instead imposed in 2019:

| Proxy | log10 stopping FLOPs | Stopping FLOPs |
|---|---:|---:|
| Aggregate capacity, 3.4x/year | 91.7497 | 5.62e91 |
| Frontier single-run compute, 5x/year | 96.7854 | 6.10e96 |
| Historical notable-model compute, 4.1x/year | 94.4440 | 2.78e94 |

The profile makes the non-identification clear: fixing floors at 0%, 1%, 10%, 50%, and 90% of the latest observed compute yields profile-deviance differences from no floor of 0, -0.010, -0.062, +0.682, and +2.780. Under the 3.4x proxy, with the historical 2019 anchor, their predicted stopping scales range from ~10^119 with no floor to ~10^87–10^93 with the positive floors. With six time-series points, these numbers do not constitute a calibrated confidence interval, and no positive lower bound on the floor is supported. A floor on one fixed computer-vision task is also not an empirically measured ceiling on general thinking efficiency.

## Reproduction

From the workspace root, run `python empirical_methods/vision_lm/fit.py`, `python empirical_methods/vision_lm/bootstrap.py`, and `python empirical_methods/vision_lm/reanchor_floor.py`. The third script adds the explicitly projected current floor and creates the combined 30-row `all_answers.csv`, without changing historical fit parameters. Dependencies: numpy, pandas, scipy. The original source data are left intact, and processed observations, deterministic fit parameters, all three proxy variants, optimal stops, exact thresholds, and floor profiles are saved separately.
