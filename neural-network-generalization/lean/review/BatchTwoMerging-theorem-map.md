# ReLU/GELU polynomial-depth paper: theorem correspondence

Paper: `works-in-progress/relu-gelu-polynomial-depth/source/paper.tex`.
Lean namespace: `NeuralGeneralization.BatchTwoMerging`.
Lean depth variable `r` counts internal hidden matrices, so paper `L=r+2` and `H=r+1`.

| Paper statement | Checked endpoint |
|---|---|
| Theorem 1, exact explicit budget (equations target, budget, sample) | `BatchTwoMergingSharpMain.manuscript_relu_learning` |
| Theorem 1, literal paper scale `t/sqrt(N)`, all `0<t<=1` simultaneously | `BatchTwoMergingSharpScales.manuscript_relu_learning_meanfield` |
| Every `gamma>=1` power scaling | `BatchTwoMergingSharpScales.manuscript_relu_learning_power` |
| Both stages of prior/posterior normalization, for every sample | `BatchTwoMergingSharpScales.manuscript_relu_normalizers_positive` |
| Corollary 1, universal `A/epsilon [C² S⁹ + log(1/delta)]` | `BatchTwoMergingPolynomialMain.quadratic_polynomial_depth_relu`; its `_meanfield` and `_power` endpoints |
| GELU main theorem, literal explicit GELU budgets and `N>=2C` | `BatchTwoMergingSharpMain.manuscript_gelu_learning`; corresponding `_meanfield` and `_power` endpoints in SharpScales |
| GELU normalizer positivity | `BatchTwoMergingSharpScales.manuscript_gelu_normalizers_positive` |
| GELU universal `C² S⁹` corollary | `BatchTwoMergingGeluPolynomialMain.quadratic_polynomial_depth_gelu`; its `_meanfield` and `_power` endpoints |
| Fixed other parameters, sufficient sample budget `O(C² log³(C+2))` | `BatchTwoMergingSharpWidthAsymptotics.manuscript_relu_sample_bound_isBigO` and `.manuscript_gelu_sample_bound_isBigO` |

Every main learning endpoint uses the concrete finite Gaussian network, actual population-merging restriction, strict training margin `1/2`, posterior Gibbs test-margin loss at `1/4`, arbitrary input distribution on the Boolean cube, and one measurable IID sample event common to all widths, scales and both optional global-margin conventions. No target-mass, compression, or learning assumption is left at these endpoints.

`smallPrior` has isotropic standard deviation `sigma` in the existing weighted-energy coordinates. Substituting `sigma=t/sqrt(N)` gives exactly first-layer variance `t²/d`, hidden variance `t²/N`, and readout variance `t²/N²`. SharpScales makes that substitution explicitly. `powerPrior` is connected by the checked prior-equality theorem.

Exact explicit constants are in SharpTarget (`sharpReluTargetCost`, `sharpGeluTargetCost`) and SharpBudgets (`sharpReadoutBound`, `sharpPopulationBound`, `sharpEnergyBound`, `sharpGridMesh`, `sharpReluEntropy`, `sharpGeluEntropy`). They reproduce the paper's constants, including `b_L`, `rho`, `D_*`, and the leading `2/epsilon`. The C²S⁹ proof uses an independently proved, more conservative cover and explicit universal constants `10^25` and `10^30`; it proves the corollary's stated existential-constant conclusion.

The checked proof may differ from the manuscript: it uses equal clone groups plus zero padding instead of balanced groups. Only the active C-dimensional clone span is constrained. The projected free Gaussian bulk need not vanish identically after population averaging; its operator norm is bounded and it annihilates the actual teacher state. This gives the same explicit constants. GELU is exactly `x * Phi(x)`, where Phi is the standard normal CDF; its global Lipschitz-2 property and exact paired Boolean compiler are proved. The compressed GELU perspective uses only positive mass coordinates, including harmless positive scales on zero-padded coordinates.

The Gaussian per-layer bulk estimate and exact logarithmic target-cylinder mass were independently implemented by the root agent in SharpBulk and SharpMass. Same-depth pruning was implemented by the converse agent in BatchTwoMergingPruning.

Validation: `lake build NeuralGeneralization.BatchTwoMergingSharpWidthAsymptotics NeuralGeneralization.BatchTwoMergingPolynomialMain NeuralGeneralization.BatchTwoMergingGeluPolynomialMain`; endpoint axiom audit only `propext`, `Classical.choice`, `Quot.sound`. No sorry or custom axiom.
