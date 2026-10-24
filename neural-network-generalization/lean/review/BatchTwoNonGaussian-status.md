# Non-Gaussian formalization: status and exact scope

Date: 2026-10-22. Owner: `/root/finish_nongaussian`.

## Main status

Both paper main statements are now **fully proved for the actual prior**. `BatchTwoNonGaussianStrongMain.strongPrior : StrongPriorGeneralization` proves Theorem 2.1. `BatchTwoNonGaussianMain.finiteScale : FiniteScaleGeneralization` proves Theorem 2.2, using separate complete endpoints `NonGaussianMeanField.meanField` and `NonGaussianAbove.aboveMeanField`. `BatchTwoNonGaussianMain.mainResults` proves their conjunction. No theorem assumes a main proposition, concentration property, target-mass bound, or compression conclusion as an additional model field.

Completed substantive analytic components:

- Exact even variance-one C² density model with positive two-sided curvature, and actual independent scaled-coordinate network priors.
- Quadratic Taylor envelopes and density integrability derived from curvature.
- Exact scalar/product density formulas, reflection symmetry, and zero mean.
- Exact translation bound for every measurable symmetric event of the actual finite product measure: μ(E+a) ≥ μ(E) exp(-M Σaᵢ²/2).
- Finiteness of the cubic exponential moment, plus Jensen lower bound used in relative normalization.
- Actual tanh first/second/third directional derivatives, with dimension-free 2Gb, 6Gb², 24Gb³ bounds.
- Actual third derivative and relative Taylor remainder of exp(tanh(z)^T Γ tanh(z)), with P(G)=24G+36G²+8G³.
- Actual one-coordinate expectation replacement, random residual integration via coordinate splitting/Fubini, hybrid product telescoping, and the full relative Lindeberg estimate cν P(G)/sqrt(N).
- A concrete standardGaussian instance of CoordinateLaw using mathlib’s gaussianReal 0 1.
- Two-sided density comparison with actual Gaussian product laws, transported to the anisotropic small-scale network prior.
- The strict non-Gaussian energy-gap mass-ratio limit, an actual compressed finite energy class and its cardinality bound, and the exact strong-prior posterior theorem with the paper's width and scale quantifier order.
- Actual non-Gaussian field-law and row-certificate tails, transfer of the full bounded dual objective by relative Lindeberg, and extraction of Gaussian proxy covariance tilts.
- Actual non-Gaussian first-layer tilt realization and mixed-tower finite reconstruction. Explicit natural polynomial bounds discharge every covariance and coordinate probability budget. The first-layer law remains the actual law; subsequent sampled layers realize the auxiliary Gaussian tower.
- Actual scalar sub-Gaussian MGF, independent-product linear tails, rectangular operator-norm tails, scaled squared-norm tails, and the non-Gaussian low-rank operator-approximation tail, all derived from the density model.
- Large-group normalized-sum small balls: probability at least ρ²/1024 for 0<ρ≤1/2 once group size exceeds the displayed polynomial threshold. This follows from the completed relative Lindeberg proof and a bounded tanh small-ball kernel, without assuming a central-limit or log-concavity theorem.

- Actual all-width target mass for every prior scale with Nσ²≤1, hence every γ≥1: `smallPrior_target_mass_all_width` / `powerPrior_target_mass_all_width`. The construction uses exact equal clone groups with zero padding, group-average small balls, unconditioned operator-tail subtraction, symmetric-event translation, and a coordinate-box fallback at small widths. No rotated independence or conditioned concentration theorem is assumed.
- A polynomial envelope for that width-independent target cost, `targetMassCost_polynomial_envelope`, derived from explicit constants.
- Joint continuity of the actual non-Gaussian dual objective and the recursive whole-network hidden-certificate tail, `NonGaussianMeanField.goodHidden_compl_tail`, under the original independent coordinates.

`lake build NeuralGeneralization.BatchTwoNonGaussianAudit` completed successfully (3374 build jobs). The audit prints exactly `[propext, Classical.choice, Quot.sound]` for both complete main statements, their conjunction, all three regime endpoints, target mass, translation, moments, Lindeberg, and matrix-tail results. No `sorry`, `admit`, or new axiom declaration occurs in the non-Gaussian files. The successful build log is `/tmp/batch-two-nongaussian-complete-audit.log`.

Completed finite-scale assembly:

- At γ=1, actual recursive hidden-row events and the actual readout tail produce an aggregate prior-mass bound outside the counted mixed-tower class. Explicit polynomial width budgets discharge relative Lindeberg, covariance approximation, finite support, coefficient bounds, and union entropy.
- At γ>1, exact coordinate marginals of the original non-Gaussian power prior transfer the proved squared-norm and low-rank matrix tails. An energy-independent width threshold absorbs the finite matrix-witness entropy, and the deterministic spectral compression gives the finite relevant class.
- A direct statistical splice treats all smaller widths using the all-width target mass. Both endpoints prove the original exact posterior, risk ≤ε/3, confidence-failure probability ≤ε, positive training denominators, and an explicit polynomial envelope independent of learner width.

The formal proofs use a less sharp all-width target cylinder than the paper: a large-group small-ball estimate and a coordinate-box fallback suffice because the Boolean theorem has a fixed output margin. This still yields the paper’s stated unspecified polynomial. It does **not** by itself supply a continuous-output theorem with logarithmic dependence on a vanishing tube radius.

The paper’s broader quadratic-tail extension and every auxiliary proposition have not separately been catalogued as complete theorem matches; the verification claim here is the two main theorems, with the necessary analytic proof chain.

## Independent catalog recommendation

Current catalog has 52 entries. Existing exact main gates cover five main manuscripts only; the listed side-paper statements do not follow merely from importing those gates. Ranked by mathematical interest: unbounded activations; ReLU/GELU polynomial depth; non-Gaussian priors; continuous domains; online mistake upper; circuit mistake converse; depth-polynomial neural converse; robust improved all scales; continuous-depth lower bound; critical-depth/noisy interpolation. Root selected shallow improved polynomials as the tenth, which is a mathematically distinct and reasonable alternative. The catalog currently lists critical-depth at 106 pages.

## Exact reviewed source hashes

- `above.tex`: `588f3d97d98eb770616fe86d549d12067b8e5f825e7b9a73068ff962602f802b`
- `meanfield.tex`: `520690b06c54ebf5af202c94e1c583d4691918bbe1c90e5e3ad1b54b1d64ed1c`
- `norm-compression.tex`: `38d7a5ba12d9f54eea127afc61c161acf54747dd90da6511bff72b4b3c0ab669`
- `paper.tex`: `eab00b715bc50d13948336f3b02eb730e6b0baccc4bde8b1d54db51e5cc54fc7`
- `prior-complexity.tex`: `56eff44c35368de7ad6a2cdc0980b94e56d868327f95c73d1c2b1cbe55ffe3ba`
- `sparse-dual.tex`: `6d3a44dcd4114c74426af7159a5f876e1147e0dabef8d79140dd9794f2af97ca`
- `strong.tex`: `ad88a112a91c65896c9083060742c45899f6074aebfed3c025488face7389f8d`
- `target-mass.tex`: `d1861b2ad81541b54e5720fba088207e7bad35d406d04025b70044879a3672c9`
- `tilt-compression.tex`: `07c541380367a2c262bf07579b0227b074012065f4d97550a85b7d0526673707`
