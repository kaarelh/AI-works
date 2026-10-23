# Polynomial-depth neural mistake converse: formalization map

Manuscript: `neural-network-generalization/works-in-progress/online-mistakes/depth-polynomial-converse/source/paper.tex`.
Lean source prefix: `neural-network-generalization/lean/NeuralGeneralization/BatchTwoNeuralConverse`.
Namespace: `NeuralGeneralization.BatchTwoNeuralConverse`.

## Main theorem statements completed

| Manuscript statement | Lean theorem | File suffix |
|---|---|---|
| Polynomial-depth pathwise mistake converse, exact displayed ceiling | `polynomial_depth_mistake_converse` | `Main` |
| Literal sampled predictions, arbitrary minimum-action ties | `sampled_mistake_converse` | `Main` |
| Literal majority predictions | `majority_mistake_converse` | `Main` |
| Correct posterior label mass at most θ counts as failure | `confidence_mistake_converse` | `Main` |
| Expected sampled total mistakes over arbitrary random/adaptive complete reveals | `expected_sampled_mistake_converse` | `Main` |
| Expected majority mistakes | `expected_majority_mistake_converse` | `Main` |
| Expected θ-confidence failures | `expected_confidence_mistake_converse` | `Main` |
| Literal infinite total errors on any complete stream | `infinite_mistake_converse` | `Infinite` |
| Expected literal infinite total errors on any a.s. complete stream | `expected_infinite_mistake_converse` | `Infinite` |
| Every arbitrary full-support iid input law, no lower bound on atom masses | `iid_mistake_converse` | `Infinite` |
| Actual parameter conditioning equals finite sign-function posterior | `functionPosterior_eq_parameter_posterior` | `Conditioning` |
| Actual σ→0, then N→∞ posterior accumulation points are probability mixtures on minimum action | `iterated_limit_minimum_mixture` | `PriorLimit` |
| Sharp robust compression lemma, actual finite network and exact width 256K/ρ² budget | `robust_energy_compression` | `CompressionExistence` |
| Exact supported-energy-to-bounded-weight reconstruction | `supported_energy_reconstruction` | `Reconstruction` |

The generic infinite-count theorem uses `SuccessHasMinimizer` and `ErrorsAreFresh`; both conditions have been proved for each literal sampling, majority, and θ-confidence convention in `Prediction`, `Conventions`, and `Counts`. They are learner conditions, not unproved neural analytic hypotheses. The finite expected theorem wrappers explicitly discharge them. The infinite expected count is the integral of the actual infinite sum of 0/1 errors (converted from ENNReal), proven almost surely at most the finite Boolean-domain cardinality and equal to the count at full revelation.

## Exact objects and numerical constants

- `d≥1`; Lean `r` means **r internal hidden-to-hidden matrices**, so manuscript depth L=r+2 and hidden-layer count H=r+1.
- Inputs are the existing `ConcreteModel.Cube d = Fin d → Bool`, mapped to ±1 by the existing network model. This is the same Boolean cube as the manuscript under the canonical encoding.
- `Weights d N r`, `networkOutput Real.tanh`, `weightedSquaredNorm`, `smallPrior`, `marginEvent` are the original actual finite-network definitions. No idealized kernel or assumed representation theorem is substituted.
- `gainSq` is the supremum of the actual N-scaled sum of squared suffix path rows over every diagonal slope array in [0,1]. Its continuity and finite-noise certificate are proved. `gainSupport Λ U` imposes precisely 1/2<|z(x)|<U at every cube input and G_N²<Λ²H E_v.
- `functionSupport` intersects that support with the strict target sign margin. Actual Gaussian prior is conditioned first on `gainSupport`, then on training signs. The normalization equivalence is proved, including support masses.
- `neuralSqrtAction` is the infimum of √κ over **all actual positive finite widths and supported implementations**. This is √a∞; `fixedSqrtAction_eq_sqrt_inf` proves the fixed-width infimum identity, and `fixedSqrtAction_tendsto` proves the N→∞ convergence. The square root is strictly increasing, so it has the same minimizing functions.
- `repairBudget d r U` is exactly P=D+Q(U+1)² from the manuscript, with A=(1/2)log(4(d+1)), F=1+A²d(d+1), D=dF+(r+1), Q=4((r+1)+65).
- `mistakeConverseWidth d r Λ U m` is exactly the manuscript's ceiling `ceil(65536 Λ² K (1+(r+1)K) [d+log(400(r+2))])`, with K=1+P(m+1)².
- Conclusion `realizesAtComplexity Real.tanh f width` supplies an actual same-depth network of exactly that width, all weights bounded by its width, and strict signed margin >1/2. Hence it directly implies the paper's C_L(f) upper bound.
- No tie uniqueness, infimum attainment, finite stopping-time bound, query uniformity, or reversal of Jensen is assumed.

## Analytic dependency chain

1. `Model`, `Noise`, `Contractive`: actual gain support, continuity, tanh divided differences and finite-disturbance propagation.
2. `Neumann`, `Staircase`, `Shells`, `PointFeatures`, `Relays`, `Allocation`, `Singleton`: actual exact tanh point-indicator networks, finite clone allocation, polynomial depth relay energy. The explicit allocation bound is slightly stronger than the manuscript's limiting-allocation argument.
3. `DirectSum`, `Cloning`, `Parallel`, `Constant`, `Repair`: actual finite parallel composition and exact one-point repair, with cap/margins/gain support preserved.
4. `Action`, `ActualAction`, `Prediction`, `Conventions`, `Counts`: minimum-action potential proof and actual mistakes. Expectations are taken before squaring the deterministic lower bound on mistakes.
5. `WidthLimit`, `Infimum`, `PriorLimit`, `Conditioning`: padded cloning to every sufficiently large width; actual Gaussian open-event rate from `BatchTwoParameterPriorRate`; exact posterior conditioning; both prescribed limits and mixtures.
6. `CompressionVirtual`, `CompressionMoments`, `CompressionTail`, `CompressionPruning`, `CompressionFresh`, `CompressionStages`, `CompressionNoise`: actual forward virtual pass, finite uniform source moments, variance-sensitive Hilbert tail, independent layer-list sections, zero row/zero variance cases, and actual simultaneous finite-disturbance budget.
7. `CompressionBudget`, `CompressionExistence`, `Reconstruction`: full Boolean-domain union bound; energy-good intersection under the actual sampling law; exact ceiling; actual coordinate bounds; final margin-restoring readout scaling.
8. `Main`, `Infinite`: all stated prediction conventions, arbitrary complete reveals, and actual infinite iid total counts.

The Hilbert tail is proved in `BatchTwoHilbertPotential`, `BatchTwoHilbertConcentration`, `BatchTwoHilbertBernstein` (root-agent work). It is not assumed or imported as an axiom. It gives exp(1-min(t²/(6Mv),t/(2b))). The compressor uses sampling tolerance ρ√(Nk/K)/4 rather than the paper proof's /8; the resulting noise is still at most ρ/2, and the **stated compressor theorem and all displayed constants remain unchanged**.

## Build / trust status

Successful builds:

```
PATH=/workspace/lean-toolchains/lean-4.32.0-linux/bin:$PATH lake build NeuralGeneralization.BatchTwoNeuralConverseMain
PATH=/workspace/lean-toolchains/lean-4.32.0-linux/bin:$PATH lake build NeuralGeneralization.BatchTwoNeuralConverseInfinite
```

`#print axioms` on the main pathwise theorem, expected sampled theorem, actual iterated posterior limit, parameter-conditioning identity, and infinite iid theorem reports only `propext`, `Classical.choice`, and `Quot.sound`. No `sorryAx` or custom analytic axiom is used. Benign linter/deprecation warnings remain.

## Explicitly outside this formalization

- The optional paragraph replacing the gain support by **every internal Euclidean operator norm <1** is not formalized as a separate learner. Actual singleton constructions satisfy a stronger Frobenius restriction and are used to prove the gain-support theorem; this does not itself formalize the operator-norm-restricted learner's own action/posterior.
- Interpretive prose about SGD/naturality and big-O simplification is not a separate Lean theorem. The exact numerical polynomial bound is formalized.
- Independent theorem-to-paper audit remains a root-agent obligation before public promotion. This document is the author's map, not independent certification.
