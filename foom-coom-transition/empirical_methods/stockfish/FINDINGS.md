# Stockfish empirical curve fits and extrapolated research stopping points

Retrieved 11 September 2026. This is a **new fit of actual published observations**, not synthetic observations generated from a reported growth rate. The matched observations themselves end in June 2023, so this is a historical-data fit using currently accessible sources, not a claim to cover 2026 research inputs.

## Sources and reconstruction

- [Erdil, Besiroglu and Ho (2024), paper](https://arxiv.org/html/2405.10494v1).
- [Authors' Stockfish notebook](https://github.com/ege-erdil/estimating-returns-to-rnd/blob/main/returns_to_software_rnd_stockfish.ipynb), saved as `source_notebook.ipynb`.
- [Authors' underlying Google Sheet](https://docs.google.com/spreadsheets/d/1_PTiZ1_faoUW4BjRaGA2rx39tGIK2ODa18FJyTHrZh0/edit): gid 0 gives measured Elo table; gid 1742775451 gives cumulative Fishtest test counts. Exact downloaded CSVs saved.
- [Current official Stockfish regression tests](https://official-stockfish.github.io/docs/stockfish-wiki/Regression-Tests.html) were checked; they extend to August 2026, but the input series in the paper ends in July 2023 and later test conditions/opening books change. We do not fabricate current matched inputs or splice incomparable Elo levels.

As in the authors' notebook, each release resets local Elo; add the last prior-release measured Elo at each release separator. Convert cumulative Elo E to estimated compute efficiency A=exp(E/142.987), using the notebook's long-time-control calibration. This conversion is itself a modeling assumption, and chained Elo can have nontransitivity effects. Match each observation date to cumulative Fishtest test count R by linear interpolation.

Result: 258 observations from 2013-03-04 to 2023-06-22. R grows from 67 to 126,479 tests; estimated A grows from 1.1106 to 367.2568 relative to the source benchmark. No claim that tests are FLOPs, that all tests cost the same compute, or that test count measures researcher thought. Tests are a factual research-input proxy.

Fit least squares to y=ln(A), using z=R/126479. Keep the first 206 observations through 2020-11-15 as training for a chronological holdout check; test on the last 52 without refitting. Separately refit all 258 for the reported extrapolation. The holdout metric is RMSE in natural-log efficiency: lower is better. Observations are time-correlated, so this is a useful forecasting check but not an independent-trials uncertainty estimate.

## All fits attempted

Here b is an intercept, s and H and T are positive parameters, and p is positive. Parameters below are rounded; exact optimizer results are in `fit_results.json`.

| Curve | Fitted full-data law y(z) | Full RMSE | Chronological holdout RMSE |
|---|---|---:|---:|
| Power | 5.0381 + 0.924574 ln(z) | 0.544 | 1.294 |
| Shifted power | 5.5422 + 1.66943 ln(z+0.046241) | 0.289 | 0.914 |
| Stretched exponential A | −0.34424 + 6.19075 z^0.367128 | 0.226 | 0.664 |
| Exponential A | 1.34191 + 5.39772 z | 0.553 | 1.010 |
| Linear A | −0.38536 + ln(1+228.081z) | 0.424 | 1.022 |
| Exponential approach to log-efficiency ceiling | 0.85919 + 5.29432[1−exp(−z/0.414393)] | 0.375 | 1.484 |
| Hyperbolic approach, fixed p=1 | 0.71213 + 6.82139[1−(1+z/0.38477)^−1] | 0.342 | 1.253 |
| Hyperbolic approach, fixed p=2 | 0.77126 + 6.03851[1−(1+z/0.77855)^−2] | 0.355 | 1.345 |
| Logarithmic A | b + ln[1+h ln(1+z/s)] | 0.424 | 1.022 |
| Hyperbolic approach, freely fitted p | b+H[1−(1+z/T)^−p] | 0.290 | 0.916 |

The last two fit attempts **do not identify their far tails**. Logarithmic A drives s to the imposed large upper bound (exp(15)), approaching linear A over the observations. Free hyperbolic p reaches the lower bound exp(−6)=0.002479; as p goes to zero with Hp held fixed, this approaches shifted-power A. A finite ceiling or eventual logarithmic regime is not established. The fixed-p ceiling fits are explicit tail assumptions fitted to the same observations; p=1 and p=2 were selected for sensitivity, not estimated from the data.

Allowing initial research stock changes the power estimate from below one to above one. The fits are compatible with very different tails. The best of these short-range forecasts is the stretched exponential, which has no finite stopping point under universal recursive productivity; this is evidence against treating the previous power-law stop as a robust empirical deduction, not evidence for a physical finite-compute singularity.

## Transparent FLOP mapping and two interpretations

Use x for future raw FLOPs, k0=10^−27.5 per FLOP, N=10^120 raw FLOPs, a=A/A(z=1), and h1=y′(1). Reanchor each fitted curve at its final date z=1. Since the dataset does not directly measure total research FLOPs, k0 supplies the absolute scale. The data only calibrates curve shape.

1. **Direct raw-proxy interpretation:** dz/dx=k0/h1. Then x=(h1/k0)(z−1), and k(x)=d ln(a)/dx=k0 y′(z)/h1. This assumes increasing cumulative test count already proxies future raw research spending.
2. **Universal recursive interpretation:** dz/dx=(k0/h1)a. Then x=(h1/k0)∫₁ᶻ exp[y(1)−y(v)]dv and k(x)=k0 exp[y(z)−y(1)]y′(z)/h1. This adds the assumption that an efficiency gain accelerates all research effort by the same factor. The historical data does not identify this assumption.

Economic stop maximizes a(x)(N−x): solve k(x)=1/(N−x). Exact threshold means separately k(x)=10^−120. The multiplicative one-FLOP gain is exp(∫ₓˣ⁺¹k(u)du), approximately 1+k(x) in all tiny-gain stopping regimes.

## All stopping answers

Figures with approximately N spent must be read together with the reserve; floating-point representations cannot distinguish N−10^27 from N.

| Fitted curve | Economic optimum: direct raw proxy | Economic optimum: universal recursion |
|---|---:|---:|
| Power | 4.804×10^119 | 9.246×10^119 |
| Shifted power | 6.254×10^119 | No finite maximum; singularity at 7.886×10^27 |
| Stretched exponential | N−6.531×10^85 | No finite maximum; singularity at 4.142×10^27 |
| Exponential A | N−3.162×10^27 | No finite maximum; singularity at 3.162×10^27 |
| Linear A | 5.000×10^119 | N−3.162×10^27 |
| Exponential ceiling | 3.193×10^29 | 1.997×10^29 |
| Hyperbolic ceiling, p=1 fixed | 1.066×10^74 | 4.132×10^73 |
| Hyperbolic ceiling, p=2 fixed | 4.986×10^58 | 2.305×10^58 |
| Logarithmic A, free scale | Unidentified tail; no defensible extrapolation | Unidentified tail; no defensible extrapolation |
| Hyperbolic ceiling, free p | Unidentified tail; no defensible extrapolation | Unidentified tail; no defensible extrapolation |

“Singularity” is a mathematical failure of indefinite extrapolation: a grows without bound at finite x, before the budget is exhausted. It is not a stop prediction, and it is not a claim about physically attainable computation.

| Fitted curve | Exact k=10^−120 crossing: direct raw proxy | Exact crossing: universal recursion |
|---|---:|---:|
| Power | 9.246×10^119 | 1.226×10^121 |
| Shifted power | 1.669×10^120 | Never decreases to threshold |
| Stretched exponential | 1.037×10^174 | Never decreases to threshold |
| Exponential A | Never; k stays k0 | Never; k increases |
| Linear A | 1.000×10^120 | Never; k stays k0 |
| Exponential ceiling | 3.193×10^29 | 1.997×10^29 |
| Hyperbolic ceiling, p=1 fixed | 1.066×10^74 | 4.132×10^73 |
| Hyperbolic ceiling, p=2 fixed | 4.986×10^58 | 2.305×10^58 |
| Last two unidentified fits | Not reported | Not reported |

For the ceiling fits, x/N is so small that exact threshold and optimum agree to displayed precision. For stretched exponential under raw interpretation, economic stopping happens at k≈10^−85.815, nowhere near 10^−120: diminishing gains alone do not imply reaching the proposed cosmic threshold within the budget.

## Analytic checks

For power or shifted power A∝(z+s)^p:

- Direct: k(x)=1/[k0^−1+x/p], x*≈pN/(1+p), xthreshold≈pN.
- Universal: k(x)=1/[k0^−1+(1−p)x/p]. For p<1, x*≈pN and xthreshold≈pN/(1−p). For p=1, k=k0 and x*=N−1/k0. For p>1, xsing=p/[(p−1)k0] and utility is unbounded approaching xsing when N>xsing.

For exponential ceiling y=b+H(1−exp(−z/T)), define C=H exp(−1/T), d=(z−1)/T. Direct k/k0=exp(−d), x=Cd/k0. Recursive k/k0=exp[C(1−exp(−d))−d] and x=(C/k0)∫₀ᵈexp[−C(1−exp(−u))]du. These were solved numerically at the exact threshold.

For fixed hyperbolic ceiling y=b+H[1−(1+z/T)^−p], define C=H(1+1/T)^−p. At cosmic x:

- log10(xthreshold_direct)=log10(pC)+27.5+92.5/(p+1).
- log10(xthreshold_recursive)=log10(xthreshold_direct)−Cp/[(p+1)ln10].

The latter uses the controlled large-z asymptote, with corrections negligible at reported precision for fixed p=1 and p=2. These formulas also show why selecting a plateau's approach exponent drastically changes the answer.

## Reproduction

Use the shared environment `python`. Run `prepare_stockfish.py`, `fit_stockfish.py`, `stopping_stockfish.py`, and optionally `plot_stockfish.py`. Inputs and exact outputs are saved locally. `fit_stockfish.py` fits all ten listed models, while `stopping_stockfish.py` reports failed tail identification rather than converting optimizer-bound choices into empirical claims.
