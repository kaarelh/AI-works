# Consolidated empirical-method results

`all_methods.csv` is the flat comparison table. `all_methods.json` contains the same normalized records plus complete original JSON result documents, source hashes, and validation metadata. These rows are correlated fitting methods, proxy assumptions, and structural interpretations; row count is not a count of independent empirical studies.

Run `python empirical_methods/consolidate_results.py` from the workspace root to regenerate. The script reads finalized result files and translates their existing fields; it does not rerun the fits.

## Reading the columns

- `family`, `method`, `closure`: which empirical data, estimator, and mathematical input/feedback interpretation produced the row.
- `anchor`: the empirical or projected point where the user-supplied initial derivative is reset. Unspecified calendar endpoints are labeled instead of invented.
- `N`, `k0`: raw-FLOP budget 10^120 and initial marginal log-efficiency gain 10^-27.5 per raw FLOP. The absolute scale is supplied by the user's toy model, not independently measured by these empirical datasets.
- `stop_flops`, `log10_stop_flops`, `stop_fraction_N`: economically optimal research spending, when the row supports a point answer.
- `remaining_flops`, `log10_remaining_flops`: the reserve at the economic optimum. These are essential when the numeric stop rounds to N. For example, a constant-gain law stops at N−10^27.5 even though floating-point `stop_flops` equals 10^120.
- `exact_threshold_flops`, `log10_exact_threshold_flops`, `exact_threshold_status`: when the marginal log gain reaches 10^-120. This differs from economic stopping, which solves k(x)=1/(N−x). The distinction between log gain and multiplicative gain minus one is negligible at these scales.
- `divergence_flops`, `log10_divergence_flops`: location of a mathematical singularity in unrestricted extrapolation. This is a model failure, not a physically attainable stopping point.
- `b`: constant in k(x)=1/(1/k0+b x), only where that law applies. For a direct raw-input power law, b=1/p. Under a cumulative effective-effort power law with universal feedback, b=1/p−1. Full Jones extrapolations use b=beta−lambda.
- `p`: a fitted power or power-related exponent where available. Its interpretation follows `closure`; it is not interchangeable across models.
- `research_compute_growth_proxy`, `hardware_efficiency_growth`: annual multiplicative G and H assumptions, where relevant.
- `row_type`, `status`: distinguish point fits, conditional posterior/bootstrap summaries, negative trends incompatible with positive k0, insufficient data, unidentified tails, and singular models.
- `probability_finite_stop`: posterior- or assumption-distribution probability under the explicitly selected model and priors. It is not a calibrated real-world probability of fooming stopping.
- `probability_positive_slope`: fraction of bootstrap draws with positive adjusted improvement. This is distinct from a posterior finite-stop probability.
- `conditional_stop_flops_q05/q50/q95`, `conditional_threshold_flops_q05/q50/q95`: distribution summaries explicitly conditional on the finite-stop/positive-slope branch. The ordinary point-stop fields are deliberately blank on distribution-summary rows. A conditional median must not be reported as an unconditional prediction.
- `source_file`, `source_pointer`: trace each normalized row to its complete source record. The JSON `source_documents` mapping embeds the result documents under these relative file names.

CSV empty cells and JSON nulls mean unavailable or inapplicable, not zero. All spending values are additional raw FLOPs after the stated anchor. None of the projections is a claim that the observed benchmark/task-specific gains transfer unchanged to universal intelligence.

## Coverage and validation

The JSON `metadata` gives the exact current row count, family counts, status counts, whether CPU-years results are included, and source hashes. Full source documents preserve fit coefficients, model diagnostics, all LM bootstrap draws, posterior numerical diagnostics, and original source metadata where provided.

The finalized table has **214 rows**, including **one unavailable-data attempt** for Stockfish CPU-years. Its download was interrupted after approximately 500 seconds, before any observations were received. That row contains no fitted law or numerical prediction; the interruption does not establish that the source server was unavailable. Metadata distinguishes this attempted retrieval from included CPU-years fits, of which there are none. The other 213 rows cover completed analyses and their documented unsuccessful/conditional outcomes.

The flat table includes both Stockfish interpretations; every vision/LM estimator and input-growth variant; all eleven historical vision floor profiles under all three growth proxies; the projected-current-anchor floor variants; all published parameter plug-ins and cumulative closures; all nine lab-growth fits under both feedback interpretations; the rounded-input and uncertainty sensitivities; both independently scrambled posterior calculations per domain; every corrected inference projection including non-positive estimates; twelve point sensitivities deliberately retaining independently flagged date errors; and every insufficient-data fit outcome. Successful-bootstrap draws are summarized per input-growth proxy, while their individual records are retained in the JSON.

For each ordinary constant-b point law, the consolidator verifies x*=(N−1/k0)/(1+b) and x_threshold=(N−1/k0)/b when b>0, the remaining budget 1/k0 when b=0, and x_sing=−1/(b k0) for singular b<0 cases. It also checks required floor-profile and posterior coverage, valid finite numeric outputs, and that conditional summary rows never populate unconditional point-stop columns. Plateau and stretched-exponential laws use their source calculations, whose form differs from constant-b laws.
