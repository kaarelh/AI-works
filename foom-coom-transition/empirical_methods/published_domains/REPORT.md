# Additional published-domain and 2025 R&D fits

Sources retrieved 2026-09-11; joint-posterior likelihood audited and recalculated 2026-09-12. This report is one component of the larger empirical-method comparison.

The newer estimates change the answer qualitatively: all three 2025 publication-proxy median fits imply runaway improvement in the unlimited Jones extrapolation. A different input proxy, OpenAI compute and staff growth, instead gives an interior optimum of approximately **8.9 × 10^119 raw research FLOPs**, under the extra cumulative-effort closure.

## Shared translation to the toy model

Keep the original calibration k0 = 10^-27.5 per raw FLOP and remaining lifetime budget N = 10^120 raw FLOPs. None of the empirical studies measures k0 for universal AI research; this calibration comes from the original note.

Let a = alpha/alpha0, x = additional raw research FLOPs. If fixed raw throughput and the whole research input receive multiplier a, the Jones law becomes

    d ln(a)/dx = k0 a^(lambda-beta).
    b = beta - lambda.
    k(x) = 1 / (1/k0 + b x).

For b>0 the optimal stop is x* = (N - 1/k0)/(1+b), and the k=10^-120 crossing is x_cross = (10^120 - 1/k0)/b. The exact single-FLOP multiplier is [1+b/(1/k0+b x)]^(1/b), with the exponential limit at b=0. At these scales k and multiplier-minus-one agree to the stated precision.

For b<0 the mathematical law diverges at x_sing = -1/(b k0), before reaching the diminishing-gain threshold. This is a failure of the unrestricted extrapolation to furnish a finite answer; infinity at that finite research budget is not a physical prediction.

For the *additional* cumulative-effort model a proportional to F^r, dF/dx proportional to a, b=1/r-1 and x* approximately rN when 0<r<1. The growth ratio r=lambda/beta alone does not identify b in the full Jones model. These closures must not be conflated.

## Published parameter plug-ins

Sources: [Erdil, Besiroglu and Ho, 2024, Tables 7–8](https://arxiv.org/html/2405.10494v1#S5.T7), [Ho and Whitfill, 14 November 2025, empirical analysis and appendix](https://epoch.ai/gradient-updates/the-software-intelligence-explosion-debate-needs-experiments), and the [2025 authors' notebook](https://github.com/parkerwhitfill/epoch_RRD/blob/main/code/bayesian.ipynb).

**The beta-minus-lambda columns below use separate marginal medians. They are parameter plug-ins, not posterior median b values.** The discrepancy in linear programming between this plug-in and median r is a concrete reason not to treat those medians as one joint estimate.

| Published fit | beta median | lambda median | r median | Full Jones result using separate-median plug-in | Cumulative-effort result using median r |
|---|---:|---:|---:|---|---|
| 2024 computer vision | .985 | 1.410 | 1.437 | Singular at 7.44e27 FLOPs | Singular; no diminishing threshold |
| 2024 Atari RL | 1.023 | 1.482 | 1.583 | Singular at 6.89e27 | Singular; no diminishing threshold |
| 2024 SAT | .648 | 2.143 | 3.542 | Singular at 2.12e27 | Singular; no diminishing threshold |
| 2024 linear programming | 1.290 | 1.259 | 1.077 | Stop 9.699e119; exact threshold 3.226e121 | Singular; no diminishing threshold |
| 2025 computer vision | 1.038 | 1.302 | 1.262 | Singular at 1.198e28 | Singular; no diminishing threshold |
| 2025 Atari RL | 1.165 | 1.299 | 1.201 | Singular at 2.360e28 | Singular; no diminishing threshold |
| 2025 NLP | .835 | 1.586 | 1.892 | Singular at 4.211e27 | Singular; no diminishing threshold |

The 2025 code uses a November 12, 2025 OpenAlex snapshot. It converts annual publication flows to **cumulative publication counts** before fitting the research input I(t). Those counts are neither FLOPs nor measured researcher hours. RL loads six annual flows but uses the first five in the stated five-year fit. The local reproduction preserves that choice.

These Bayesian fits condition on one efficiency-growth endpoint per domain, rather than a detailed efficiency trajectory. The published repositories contain printed quantiles and code, but no saved joint posterior sample files. Quantile-only bounds on P(beta>lambda), valid for the published posterior, appear in `published_results.json`; they are [5%,25%], [25%,50%], and [0%,5%] for the 2025 vision, RL, NLP fits respectively.

## Independent joint Bayesian refit

`posterior_qmc.py` performs an additional fit using the authors' stated endpoint data, normalization, and four independent unit half-Cauchy priors. It evaluates the Feller transition via its noncentral chi-square form and integrates by scrambled Sobol importance sampling. This is an independent posterior calculation, not a recovery of the authors' MCMC draws.

Two independently scrambled runs use 524,288 prior points each per domain. Effective sample sizes are roughly 1,700–22,300. The noncentral-chi-square identity agrees with a direct 20,000-term gamma-series calculation within 7e-14 in log density on the original checked points. An audit found that SciPy's Bessel-based `ncx2.logpdf` can return negative infinity even near the mean at large degrees of freedom. The corrected calculation recovers those densities using the separately implemented Boost-backed `ncx2.pdf`, checked against a centered Poisson–gamma mixture within 2e-10 in log density. These corrections restore approximately 3%–13% of posterior mass, depending on domain and run. A direct centered-mixture fallback resolves three further Boost NaNs across all fourteen runs.

The independent refits broadly reproduce published quantiles; some tail quantiles differ, and the rare finite-stop branch is sensitive to numerical sampling. The following values are approximate numerical estimates conditional on the model and prior. Probability ranges and median ranges show the two scrambled runs; interval endpoints span their two conditional central-90% intervals. They are neither convergence guarantees nor real-world probabilities that universal research stops. Extremely large arguments outside the supported numerical range are still assigned zero weight, and approximately 0.2%–1.0% of prior draws are excluded this way. JSON diagnostics distinguish argument exclusions, recovered likelihoods, and residual underflow. There are no unresolved NaNs. Conditional on Boost correctly rounding its zero densities, an explicit bound puts their omitted posterior mass below 10^-42 in every run; that bound does not apply to the argument exclusions.

| Fit | Posterior probability of finite Jones stop | Conditional median x*/N, given a finite stop | Approximate conditional central 90% x*/N interval |
|---|---:|---:|---:|
| 2024 vision | 12.2%–12.7% | .902–.914 | .63–.992 |
| 2024 RL | 22.3%–22.6% | .794–.804 | .41–.985 |
| 2024 SAT | 3.7%–4.2% | .868–.910 | .53–.994 |
| 2024 linear programming | 45.0%–45.4% | .695–.696 | .31–.970 |
| 2025 vision | 18.3%–19.1% | .900–.909 | .67–.992 |
| 2025 RL | 35.9%–36.2% | .782–.787 | .42–.981 |
| 2025 NLP | 4.9%–5.5% | .918–.934 | .67–.994 |

Multiplying a fraction by 10^120 gives FLOPs. For example, the conditional NLP median is about 9.3e119, **but approximately 95% of that posterior is on the singular branch**, so 9.3e119 must not be reported as its unconditional prediction. Joint sample dependence matters: linear programming's median b is negative in this refit, even though the difference of its published marginal medians is positive.

Complete replicate-specific quantiles, numerical integration diagnostics, and exact-threshold distributions are in `posterior_qmc_results.json`. The repaired posterior calculation supersedes the initial results that silently assigned failed Bessel evaluations zero weight.

## Current lab-growth proxy: actual data refits

The [2025 authors' growth-ratio code](https://github.com/parkerwhitfill/epoch_RRD/blob/main/code/steady_state.py) and [input FLOP file](https://github.com/parkerwhitfill/epoch_RRD/blob/main/data/openai_rd_spend_flops.csv) let us refit

    r = g_A / [epsilon_K g_K + (1-epsilon_K) g_L].

The local fit uses 5 staff reports, January 2023–July 2025, and 3 estimated R&D compute observations for 2022, 2024, 2025. Forecast rows for 2026–2030 are excluded. The output growth assumption is g_A=ln(3) per year. These data imply OLS g_L=.84106/year and g_K=1.42967/year. This differs from the article's rounded 1.3/year compute figure, so the rounded-text estimate r=.9553 differs from the actual-data refit r=.8893. The FLOP observations are themselves spend-derived estimates rather than a direct total-research accounting.

The following FLOP predictions use the additional cumulative-effort model. **A full Jones stopping fraction is not identified by these growth ratios alone.**

| Growth-rate estimator | Compute share | Fitted r | Optimal stop FLOPs | Exact 10^-120 threshold FLOPs |
|---|---:|---:|---:|---:|
| OLS | .59 | .92449 | 9.245e119 | 1.224e121 |
| OLS | .67 | .88926 | 8.893e119 | 8.030e120 |
| OLS | .75 | .85661 | 8.566e119 | 5.974e120 |
| Endpoint | .59 | .92204 | 9.220e119 | 1.183e121 |
| Endpoint | .67 | .88664 | 8.866e119 | 7.821e120 |
| Endpoint | .75 | .85385 | 8.539e119 | 5.842e120 |
| Theil–Sen | .59 | .92864 | 9.286e119 | 1.301e121 |
| Theil–Sen | .67 | .89154 | 8.915e119 | 8.220e120 |
| Theil–Sen | .75 | .85730 | 8.573e119 | 6.008e120 |

These correlated estimators should not be counted as independent evidence. They check robustness to fitting method and the authors' .59–.75 compute-share uncertainty. All of their exact threshold crossings are beyond the budget, while their economically optimal stops are within it.

Reproducing the source's additional uncertainty assumptions (Gaussian slope uncertainty, a triangular compute share, and a software multiplier with assumed 90% range 2–5×/year) yields r median .932, central 95% interval [.489,1.378], and 38.2% of draws above r=1. Conditional on 0<r<1, the cumulative-model stop is .819N at the median, with central 90% interval [.511N,.982N]. The simulated distribution is centered at ln(sqrt(10)), whereas the displayed point uses ln(3), matching the source's convention. This is an assumption-driven sensitivity distribution, not a calibrated universal-fooming posterior.

## Compute bottleneck evidence changes the model, not just the fitted number

[Whitfill and Wu, August 2025](https://arxiv.org/html/2507.23181v2) fit a 27-observation AI-lab panel. Their baseline substitution estimate is 2.583, whereas adding frontier experiment scale gives -0.103, outside the CES parameter domain and interpreted as close to perfect complementarity. Those results do not estimate beta and lambda, so they do **not** supply an independent FLOP stopping number. They show that empirically plausible input definitions support incompatible feedback assumptions.

If experimental inputs fail to receive the universal multiplier assumed by the original toy model, the prior feedback law changes. `published_results.json` includes a clearly labeled cognitive-only cumulative-effort sensitivity with dF/dx proportional to a^(1-epsilon_K). Its b=1/r-(1-epsilon_K), hence x*/N=r/(1+epsilon_K r), approximately .52–.60 for these lab-growth fits. This changes the toy model and is not an additional fit of its original full-feedback law.

## Reproduction

From the workspace root:

    python empirical_methods/published_domains/analyze.py
    python empirical_methods/published_domains/posterior_qmc.py

`published_results.json` contains every source quantile, all plug-in stopping and divergence results, all nine lab-growth fits, and uncertainty propagation. `sources/` preserves the retrieved notebooks and CSV inputs; `source_manifest.json` records hashes and source URLs.
