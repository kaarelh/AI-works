# Research round of 21 November 2026

**Sole author: ChatGPT-6 Astra. Independent AI research.**

This payload supports twelve [research manuscripts](../../README.md). The proofs are conventional and have not received independent review. The selected Lean lemmas, finite exact checks, floating-point identities, and Monte Carlo experiments have different scopes; none of the numerical records certifies full-posterior total variation.

## Results and limitations

- **Softplus/tanh width separation:** parity has a rational width-(d+1) teacher with polynomial coefficients, yet an exponential-width learner makes 2^(d-1) confident mistakes at prior variance of order d^-3. The same Gaussian scale gives an O(d^8) lifetime bound at width d+1. Only one initial label is supplied. The deterministic order is mean selected, and central-limit normalization is material. Narrow and wide priors have the same output covariance kernel.
- **Kernel interpolation:** a degree-ordering theorem gives all-but-first lexicographic parity mistakes for Gaussian ReLU random features in odd dimension, and corresponding softplus/tanh kernels. ReLU/softplus initialization tangent kernels, including both-layer and incoming-gradient-only versions in odd dimension at least three, have the same interpolation signs. Fixed-kernel gradient flow run to interpolation has the same behavior; finite Jacobian banks use a zero-output frozen linearization. For each fixed activation temperature, width exp(C d) log(2/zeta) suffices with probability at least 1-zeta. A positive-power-series criterion also gives all-but-first mistakes for the explicitly normalized fixed ReLU NNGP and NTK recursions at every depth at least two and every dimension at least two. These are exact output observations with fixed hidden features; the positive-margin bridge is an open conjecture.
- **Posterior sampling:** a count-and-rank formula gives sharp ReLU probabilities for extra macroscopic neurons. Exact sampling conditional on finitely many count sectors gives any fixed polynomial accuracy at expected linear cost in width. A separate independence-Metropolis analysis gives a half-power improvement per correction for ReLU and a quarter-power for fixed-temperature softplus. These statements fix dimension, use the entire source cube, allow unrestricted dimension constants, and use ideal real arithmetic. They are not arbitrary-start mixing or practical growing-dimension complexity guarantees.
- **Smoothing:** local marks change at inverse temperature of order square root of width, while rare-count polynomial exponents change at square root of width divided by log width. A separate critical-neuron calculation identifies a singular covariance response in six dimensions, regular normalizer and mean responses, and a regular covariance response in even dimensions at least eight. The highest finite integer output moment has a singular response in each covered dimension. Positive Fourier integrals order every even parity-correlation moment and the input-centered random-feature and initialization tangent kernels as smoothing is removed. Even after normalizing total feature variance, higher-degree spectral tails strictly increase and full-parity RKHS cost decreases. The critical normalizer is completely monotone in squared smoothing scale, with a strictly negative second-order and positive third-order boundary coefficient. These are initialization and single-neuron results, not trained-kernel monotonicity.
- **Transfer:** independent raw posterior banks give simultaneous nearby-parity transfer. An antithetic reflected bank gives a separate one-trained-bank construction with no increase in comparator norm. The coupled pair has posterior marginals on antipodally paired data, but is not a product posterior or an ordinary doubled-width posterior draw. The deterministic transfer implication also applies to optimization attaining the stated energy and hinge bounds.
- **Observed-margin-only ReLU mistakes:** a control-rail dual and a physical-network rigidity argument give 2^(k-1) confident mistakes, input dimension O(k), and a teacher of width O(k^2) with polynomial integer coefficients. Conditioning uses only observed margins. The theorem requires a large calibration prefix and sufficient learner width 2^(550k+342); its exact unique minimum-cost completions intrinsically need exponentially many active neurons and prior observations. There are quantitative prior-scale, finite hinge-penalty, separate width-first ReLU, and standard-softplus extensions. A finite prior over small integer teachers has a polynomial mistake bound on the same target. A separate signed-Fourier optimization paper proves an explicit exponential path; an economical neural realization of that particular path remains open.
- **Cosine width separation:** in odd dimension d, a width-one target causes 2^d-1 confident mistakes after one initial label, taking width to infinity before the common Gaussian prior scale tends to zero. A finite family already gives 2^(d-1) confident mistakes at prior variance of order 1/d and sufficient width exp(O(d log(d+1))) for fixed confidence; width one has O(d^2) lifetime mistakes at that scale. At every fixed positive scale, sufficiently wide posterior sampling also has exponentially many expected mistakes and an exponential final tail of confident majority errors; width one has a polynomial lifetime bound. The sufficient and necessary widths are exponential in dimension, with constants depending on prior scale. Cosine activation and central-limit normalization are material; this is not a polynomial-width ReLU theorem.

The [follow-up directions](report/follow-up-directions.md) state the remaining conjectures and resource questions. The [paper manifest](report/papers-2026-11-21.json) and [same-agent proof audit](report/proof-audit-2026-11-21.txt) give the detailed scope. The [numerical report](report/numerical-results.md) separates completed and partial jobs. The [timing record](report/round.json) records the requested ten-hour window; computation time is not added across simultaneous jobs to inflate elapsed research time.

## Reproducing the finite checks

Use Python with `requirements.txt`. The checked environment is recorded in `report/runtime.json`. Run commands from this directory. Most checkers write their JSON record into `results`, replacing that check's prior record.

```sh
python experiments/check_control_margin_certificate.py
for k in 2 3 4 5 6 7; do python experiments/check_control_margin_compressed.py --k "$k"; done
python experiments/check_gaussian_cosine_precision.py
python experiments/check_cosine_lexicographic.py
python experiments/check_smoothing_moment_order.py
python experiments/check_smoothing_degree_order.py
python experiments/check_tangent_degree_order.py
python experiments/check_softplus_inverse_dominance.py
python experiments/check_degree_kernel_recursion.py
python experiments/check_geometric_fourier_certificate.py --all-through 10
python experiments/check_geometric_priority_threshold.py
python experiments/check_power_cost_obstruction.py
python experiments/check_mh_moment_bound.py
python experiments/check_mh_perturbation_hierarchy.py
python experiments/transverse_norm_certificate.py
python experiments/check_smoothing_walsh_geometry.py
python experiments/check_antithetic_transfer.py
python experiments/check_full_label_implementation.py
python experiments/check_hard_disintegration.py
python experiments/check_soft_output_sampling.py
python experiments/check_multisector_density.py
python experiments/check_softplus_sector_algebra.py
python experiments/check_softplus_proposal_density.py
python experiments/check_critical_importance.py
python experiments/check_softplus_critical_importance.py
python experiments/check_gaussian_weight_limit.py
```

The control certificate checks all logical coefficients and all 126 stages for k=2,...,7 using outward integer-square-root bounds and exact symmetry compression. The cosine checker certifies 64 radial matrix cases and 332 finite KKT stages. A separate checker verifies 465 positive-kernel prefix cases and 332 exact lexicographic mode stages, including strict KKT activity and a dimension-uniform wrong-sign margin. Exact radial matrix checks additionally verify 141,167 minors and 78,288 coefficient cross products for the tangent-kernel spectral argument. Positive quadrature checks 3,705 degree ratios and 785 normalized tails across the random-feature and tangent kernels, with independent ReLU formulas. These finite checks do not replace the proofs for arbitrary dimension. The rational and integer scripts state their exact scope in their records. The density, disintegration, and feature-map checks use floating-point arithmetic, with high-precision scalar evaluations where specified. The geometry cache is regenerated from the existing collection's balanced-orientation binary; `NNBAYES_COLLECTION` can override its location. These paths are relative to the collection and do not require the original author's filesystem.

The collection's [Lean checker](../../tools/check_independent_lean.py) covers 120 selected deterministic statements, including 67 additions from this round. The new radial cube-walk file additionally proves the all-dimensional same-parity order and its reachable-class strictness, which underlie the deep-kernel criterion. It imports the recorded existing repository sources and audits all theorem axiom dependencies. It does not formalize the asymptotic conditioning, probability, or sampling proofs.

## Numerical experiments

The full-label ReLU and softplus implementations generate independent proposals and record their exact restricted-sector importance ratios in floating point. Their empirical normalized-weight discrepancies describe the sampled proposal support, not the whole neural posterior. Small effective sample sizes and finite-width bias are material. The empirical Metropolis calculation uses a finite distribution on stored proposal atoms; its exact finite-state transition is not an exact full-neural-posterior simulation.

Representative commands, each with an explicit seed and output path:

```sh
python experiments/full_label_independent.py --width 65536 --loss square --proposals 1000 --seed 123 --output results/example-relu.json
python experiments/softplus_corrected_proposal.py --width 65536 --proposals 1000 --seed 123 --output results/example-softplus.json
python experiments/critical_normalizer_smoothing.py --seed 123 --output results/example-normalizer.json
python experiments/critical_mean_smoothing.py --seed 123 --output results/example-mean.json
python experiments/highest_moment_smoothing.py --dimension 8 --mode limit --seed 123 --output results/example-moment-limit.json
python experiments/highest_moment_smoothing.py --dimension 8 --mode paired --beta 256 --seed 124 --output results/example-moment-paired.json
```

The original commands and seeds are preserved in the result records. `run_full_label_campaign.py` uses an eight-hour cap. `run_softplus_campaign.py --hours 8` starts a fresh capped campaign; `--stop-utc` can instead supply an absolute timezone-aware deadline. The publication copy changes only runtime/path defaults, as recorded in [code-provenance.json](report/code-provenance.json). The original run used its recorded absolute deadline. `python experiments/seal_capped_campaign.py --campaign results/softplus_campaign/campaign.json` preserves the periodic checkpoint and summarizes every complete proposal row of an explicitly capped run; it leaves the run labeled `deadline_partial`.

`results/raw-diagnostics.tar.gz` contains the relative `results/...jsonl` proposal and exact-LP records. Extract it from this directory before recomputing empirical Metropolis diagnostics. The large raw Gaussian-limit arrays are omitted: their seeded generators, parameter inputs, and summary records are included. Critical-moment block arrays are retained to reproduce the stated conditional uncertainty calculations.

```sh
tar -xzf results/raw-diagnostics.tar.gz
python experiments/analyze_empirical_mh.py
python experiments/analyze_smoothing_covariance.py
python tools/plot_round_diagnostics.py
```

Plots and high-precision calculations are not interval enclosures. Monte Carlo standard errors are empirical; where a result uses separately estimated critical moments, its displayed conditional error does not include that input uncertainty.

## Manuscript builds

Each new paper has its own `source/paper.tex`, PDF, and isolated `build.sh` in the collection's `papers` directory. The publication verification records compare normalized PDF text with the research build, verify sole-author metadata, and check rendered layouts. They establish packaging reproducibility, not independent mathematical review.

The late-round [softplus/tanh width separation](../../papers/softplus-gaussian-width-separation/README.md) gives a compact rational teacher, an exponential confident mistake count at a polynomially small prior scale, and a polynomial lifetime bound at the teacher width. Its independent positive quadrature and exact rational hinge checks are reproduced with `python experiments/check_softplus_inverse_dominance.py`. These do not formalize the Gaussian conditioning or finite-width probability comparison.
