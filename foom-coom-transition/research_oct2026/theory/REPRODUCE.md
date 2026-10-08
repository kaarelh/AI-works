# Reproduce the theory diagnostics

Run from the project root:

```sh
PYTHONDONTWRITEBYTECODE=1 python -B research_oct2026/theory/calculate_theory.py
```

Install NumPy and SciPy in your Python environment. This script does not fetch or fit data. It writes `theory_results.json` and the compact table `rival_stopping_scenarios.csv` beside itself, and prints the key prior sensitivities. Reproduction requires the read-only inputs `forecast_revision/math_model.py` and `calibration_revision/calibration_draws.csv`; the results record their SHA-256 hashes.

The saved calibration file contains 1,024 scenarios in each of five families at fixed `log10_k0=-29`. The script preserves these draws and weights for the baseline. For the ablation, it removes only the slow component of the heterogeneous family and recalibrates its existing fast component to the same initial slope. It does not alter the continuum, single-power, rapid, or scale-free families. Weighted quantiles interpolate the sorted empirical cumulative distribution, matching the prior calculation's convention. Values with more than one decimal place document numerical reproduction, not forecast accuracy.

The rival-law table uses exact logarithmic roots for the existing smooth cost families, an independently derived logistic raw law for the exponential efficiency-gap model, and the analytic minimum of the uncapped optimum and cap-reaching input for the capped raw-power model. Numerical checks compare the logistic effective/raw derivatives, verify the inverse-square marginal case gives `log10_x=74.5`, and check the capped linear case gives `log10_x=41` at `H=1e12`.

The largest absolute natural-log economic-root residual is below `3e-12`; the independent logistic feedback derivative check is below `5e-11`. The delayed-breakthrough examples check the exact utility comparison giving a unique global optimum. They are mathematical counterexamples with an identical finite prefix, not fitted predictions.

The reset calculation returns only the probability mass in which the old mechanism survives until its former optimum. A no-reset probability is not an updated stopping distribution. The code deliberately does not manufacture stopping values for the missing post-reset mass.

The script writes only within this folder. The report and independent audit notes identify primary sources inline. These supporting notes describe the research process and older-prior diagnostics; the current stopping distribution is in `../synthesis/`.
