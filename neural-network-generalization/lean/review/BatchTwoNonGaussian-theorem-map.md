# Non-Gaussian priors: main theorem correspondence

Reviewed paper: `side-results/non-gaussian-priors/source/paper.tex`, SHA-256 `eab00b715bc50d13948336f3b02eb730e6b0baccc4bde8b1d54db51e5cc54fc7`.

| Paper statement | Formal proposition | Proof |
|---|---|---|
| Theorem 2.1, Strong-prior learning | `BatchTwoNonGaussian.StrongPriorGeneralization` | `BatchTwoNonGaussian.strongPrior` |
| Theorem 2.2, finite-scale learning for every γ≥1 | `BatchTwoNonGaussian.FiniteScaleGeneralization` | `BatchTwoNonGaussian.finiteScale` |
| Both main statements | conjunction of the two propositions | `BatchTwoNonGaussian.mainResults` |

The statement file is `NeuralGeneralization/BatchTwoNonGaussianStatements.lean`; the combined proof file is `NeuralGeneralization/BatchTwoNonGaussianMain.lean`. The γ=1 endpoint is `NonGaussianMeanField.meanField`, and γ>1 is `NonGaussianAbove.aboveMeanField`.

## Semantic correspondence

- `r : ℕ` counts internal hidden-to-hidden matrices, so the paper's depth is `L=r+2`. Every depth L≥2 is covered.
- `CoordinateLaw` specifies an actual even C² potential, positive two-sided curvature, its positive normalized density on ℝ, and finite second moment equal to one. Evenness and integrability imply mean zero, so this is the paper's variance-one law. The structure has no concentration, compression, or learning conclusion field.
- `productPrior` is the actual finite product of independent scaled copies of this law. `smallScale` and `powerScale` exactly match the displayed strong-prior and finite-exponent scales in the model; `powerPrior_eq_smallPrior_standardDeviation` proves their equivalence at σ=N^(−γ/2).
- `Cube d` is the Boolean input cube, `Real.tanh` is the actual activation, the existing concrete model uses one constant input coordinate and no internal biases, and its readout is linear.
- `isComplexity` is minimum width C≥1 admitting a depth-r+2 implementation with every coefficient bounded by C and strict output margin 1/2. This matches C_L(f), including the weight bound.
- `functionMass`, `posteriorDenominator`, and `networkPosterior` use the actual parameter measure of each strict global-margin Boolean-function region and exact training-label consistency. The common global-margin normalization cancels from the posterior. This is not an abstract proxy prior or a selected minimizer.
- `posteriorRisk` averages the error of a posterior-sampled function. `ConcreteModel.confidenceFailure` counts inputs whose posterior correct-label probability is at most 2/3. Thus the formal conclusion requires probability strictly greater than 2/3 outside the failure set, including mixture/tie cases.
- The strong-prior scale threshold is chosen after fixed N and ε but before D, δ, and n. The sample polynomial is chosen before d,C,N and is independent of N.
- The finite-scale polynomial is chosen after r, coordinate law, and γ but before d,C,N,D,ε,δ,n. It is uniform over every N≥C. The theorem does not claim uniform constants as γ↓1.
- `polynomialEnvelope A m d C t = A(1+d+C+t)^m` supplies a particular admissible polynomial. The displayed factors 6/ε and logarithmic terms match the paper's two sample bounds.

## Proof correspondence and permitted differences

The strong-prior proof uses curvature-derived density envelopes, the weighted-energy gap, an actual finite compressed function class, and exact posterior learning estimates. The γ>1 proof uses actual non-Gaussian coordinate tails, matrix witness entropy, spectral approximation, and the same deterministic network compression. The γ=1 proof uses actual non-Gaussian first-layer tilts, relative Lindeberg for later finite covariance tests, a Gaussian proxy tower, and finite ordinary-network reconstruction.

The actual all-width target-mass lower bound uses clone-group average constraints and a coordinate-box fallback when clone groups are small. This differs from the paper's sharper concentration argument but preserves its stated polynomial Boolean sample guarantee. No theorem with logarithmic dependence on a continuously shrinking output tolerance follows from this fallback.

## Verification

Command: `lake build NeuralGeneralization.BatchTwoNonGaussianAudit`.

Result: success, with every audited main theorem depending only on `propext`, `Classical.choice`, and `Quot.sound`. `rg` found no `sorry`, `admit`, or new axiom declarations in `BatchTwoNonGaussian*.lean`. These checks certify the formal proof terms; the semantic mapping above records what those terms say about the manuscript.
