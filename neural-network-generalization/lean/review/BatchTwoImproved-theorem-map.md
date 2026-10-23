# Original robustness support with improved polynomials: theorem map

Paper: `works-in-progress/improved-polynomials/original-support-all-scales`.

The actual analytic compressor, finite-sample learning theorem, the paper's `C^6 log^13(C+2)` fixed-parameter rate, and its universal degree-46 polynomial bound are kernel checked. Both the base prior and the optional globally margin-conditioned prior are covered.

## Exact analytic and learning statements

| Paper content | Lean theorem / module | Scope |
|---|---|---|
| Original-support Boolean target cylinder | `ConcreteModel.improved_target_mass_all_widths` in `BatchTwoImprovedTargetMain` | Actual product Gaussian, every learner width at least the layered Boolean circuit width, every positive scale with `N*σ²≤1`; original calibrated finite-perturbation support and strict all-input target margin. |
| Sharp target rate | `improvedTargetCost_isBigO` in `BatchTwoImprovedTargetGrowth`; `improvedTargetCost_budget` in `BatchTwoImprovedTargetBudget` | `O(C log²(C+2))` for fixed remaining parameters and a universal cubic multivariate envelope. |
| Actual entropy compressor | `BatchTwoImprovedInduction.sharp_large_width_raw` in `BatchTwoImprovedLargeWidth` | From literal Gaussian KL alone to one common bounded candidate-network law; actual selected-query histories and readout sampler, with exact original and candidate marginals. |
| Common finite class, all widths | `BatchTwoImprovedInduction.all_width_score_compression` in `BatchTwoImprovedAllWidths` | Actual original robustness support and its calibrated radius; includes the small-width branch. No compression, covariance approximation, conditional coupling, or target-mass oracle is assumed. |
| Finite-sample main learning theorem | `BatchTwoImprovedLearning.all_width_all_scale_learning` in `BatchTwoImprovedLearningMain` | One measurable IID-sample event works simultaneously for all `N≥C` and all `0<t≤1`. Positive normalization, expected posterior error at signed output `≤1/4`, and the `2/3` posterior-confidence criterion. Budget `200*(entropy+log(1/δ))≤n*ε`. |
| Literal scale conventions | `learning_scaled_variance`, `learning_power`, `normalizers_positive` in `BatchTwoImprovedLearningScales` | Same conclusion for `N*σ²≤1`, hence every `γ≥1`; positivity of both prior and likelihood conditioning stages. |
| Fixed-depth sharp circuit-width rate | `entropy_isBigO` and `all_width_six_thirteen_learning` in `BatchTwoImprovedLearningWidthGrowth` | The actual parameter/resource functions yield `C^6 log^13(C+2)` and the actual posterior conclusion at that rate. |
| Universal degree-46 sample bound | `universal_polynomial_depth_learning` in `BatchTwoImprovedLearningPolynomial` and `BatchTwoImprovedLearningGlobalPolynomial` | A universal constant times `(2+d+C+L+c+c⁻¹+ε⁻¹+log(1/δ))^46` suffices for the actual posterior conclusions, simultaneously for all admissible widths and scales. |
| Compressed resource rates | `BatchTwoImprovedResourceGrowth` and `BatchTwoImprovedResourceWidthGrowth` | Global width/weight envelopes of degrees 21/24, and fixed-parameter width `C^3 log^6(C+2)` and weight `C^6 log^12(C+2)`. |
| Optional global clean-margin condition | The corresponding theorems in `BatchTwoImprovedGlobalMain` and `BatchTwoImprovedGlobalScales` | The actual prior is conditioned on `robustEvent tanh c ∩ globalMarginEvent tanh (1/2)`. The finite class and scalar sample budget are identical to those above. |

## Formal model conventions

Lean's circuit `LayeredBooleanCircuit d C r` has `r+1` hidden stages and the learner has depth `L=r+2`. It counts the constant wire. The physical Gaussian scale in the paper is `t=σ*sqrt(N)`; the literal first/internal/readout variances are `t²/d`, `t²/N`, and `t²/N²`. Training conditions on strict signed output greater than `1/2`. Test loss uses signed output at most `1/4`, which is stronger than sign error. The original robustness event quantifies over finite perturbations of every hidden activation and the readout, with the original RMS budget and output clipping at `±1/2`.

## Proof differences

The formal proof uses larger universal internal constants, without changing the compressed-width or target-width exponents. In particular, the sample-size resource contains `2^256`; this pays for the fully proved finite-matrix concentration estimate. The terminal readout uses the original uniform sampler with a fixed-input variance bound, rather than requiring an unnecessary simultaneous all-input readout event. Its candidate law remains independent of the test input. Finite-grid learning uses a relative finite-class concentration estimate, with sample dependence linear in inverse accuracy.

**The particular numerical sufficient condition in `source/explicit-budget.tex`
is outside the verified scope.** That section displays a threshold of
`(16/epsilon) * (J + log(1/delta))`, with its particular definitions of
`J` and failure allocations such as `beta=epsilon/4`. The formal development
instead proves `200*(entropy+log(1/delta)) <= n*epsilon`, using larger internal
constants and different failure allocations. It verifies the headline main
theorems' existential polynomial, `C^6 log^13(C+2)` rate and universal degree-46
bound. It does **not** establish that every printed explicit sufficient
sample threshold in that section is valid. The difference is allowed by the
headline existential universal constants; it would not be a literal proof of
the separately displayed numerical formula.

The main learning theorem is an actual posterior theorem. None of its premises asserts the result through an abstract `ScoreCompression`, local-volume hypothesis, or conditional-coupling hypothesis. Such intermediate objects are constructed in the imported proofs.

## Verification

The following commands pass:

```
lake build NeuralGeneralization.BatchTwoImprovedAllWidths
lake build NeuralGeneralization.BatchTwoImprovedLearningScales
lake build NeuralGeneralization.BatchTwoImprovedGlobalScales
lake build NeuralGeneralization.BatchTwoImprovedLearningWidthGrowth
lake build NeuralGeneralization.BatchTwoImprovedLearningPolynomial
lake build NeuralGeneralization.BatchTwoImprovedLearningGlobalPolynomial
```

Axiom checks for the common finite-grid compressor, raw compressor, original Gaussian-history construction, Gram allocation, optional-global-margin main learning theorem, its power-prior specialization, and its normalizer theorem report only `propext`, `Classical.choice`, and `Quot.sound`. No `sorryAx` or project-specific axioms occur in these endpoints. These checks establish kernel validity; the theorem-to-paper comparison above separately records the semantic conventions.
