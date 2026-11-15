# Ordinary tanh: main-theorem correspondence and verification

**Coverage update (2026-11-14):** This dated review records the original main-theorem verification. The [full-paper inventory](OnlineLowerTanh-full-paper-coverage.md) records the subsequent formalization of independent appendix results and is the current source for coverage status.

Checked on 2026-11-08 with Lean 4.32.0 and the repository's pinned mathlib revision. This record concerns [Superpolynomial online mistakes for isotropic Bayesian tanh networks](../../works-in-progress/online-mistakes/isotropic-tanh-allwidth/paper.pdf), including the improved `exp(Ω(√C/log C))` exponent.

## Public endpoints

All three endpoints in [OnlineLowerTanhMain.lean](../NeuralGeneralization/OnlineLowerTanhMain.lean) have **no hypotheses**:

| Paper conclusion | Exact Lean proposition | Proof |
| --- | --- | --- |
| Concrete tanh family, bounded teacher, small Boolean circuit, fixed order, and actual posterior limit | `TanhConcreteMainStatement` | `OnlineLower.tanh_concrete_main` |
| Logarithmic rails, dimension `Θ(k log² k)`, teacher width `O(k² log² k)`, and exponential count | `TanhPathLogarithmicRailStatement` | `OnlineLower.tanh_path_logarithmic_rail_main` |
| Count at least `exp(c √C/log(C+2))` for arbitrarily large displayed teacher widths | `TanhSquareRootLogLossStatement` | `OnlineLower.tanh_square_root_log_loss_lower_bound` |

[CheckOnlineLowerTanh.lean](../CheckOnlineLowerTanh.lean) assigns the proofs to these exact propositions. Its transitive `#print axioms` checks report only `propext`, `Classical.choice`, and `Quot.sound`, including for the finite-scale consequence and the identification with the globally conditioned posterior. There is no `sorryAx` or project axiom.

## Model and quantifiers

The definitions use `Real.tanh`, a one-hidden-layer network with a linear readout, and the full Boolean cube with a constant incoming coordinate. All incoming Gaussian coordinates have variance `N σ²/d`; each readout coordinate has variance `σ²/N`. Their independence is part of the actual finite product measure. These are the paper's variances, equivalently `t²/d` and `t²/N²` at `t=√N σ`.

The posterior first imposes `|F(x)|>1/2` on **every** cube input and then the correct sign and margin at each revealed label. It includes all parameter realizations and mixtures. It does not condition on exact real outputs or restrict networks to the finite atoms used to construct witnesses. The normalizing mass is positive at every positive scale and every position of the input permutation.

The theorem first chooses the target, a bounded teacher, and one complete nonrepeating input permutation with its designated positions. It next chooses a sufficient finite width threshold. For **every** fixed width above that threshold, correct-label confidence at each designated position tends to zero as `σ↓0`. No exchange of width and scale limits occurs. `TanhConcreteProtocol.finite_scale` supplies a common sufficiently small positive scale for majority failure, confidence below `1/3`, and the simultaneous fresh-posterior-sampling conclusion. `designatedAtLeastProbability` is the actual normalized finite product law for the independent prediction draws.

The exact family is `m=6k+6`, `R=2⌈K log²(m+2)⌉`, and `H=2⌈m log(m+2)⌉`, for one fixed positive integer `K` and every sufficiently large `k`. The designated count is exactly `2^(k−1)`. The teacher width is `(m+1)(d+1)`, with margin at least one and every coefficient bounded by that width. The NAND circuit has at most `17d+5` gates. The rate statement is about the displayed teacher width; it does not identify the minimum teacher width or promise a construction at every integer value of `C`.

## Proof map

The formal dependency chain proves the following steps, in this order:

1. Actual global tanh maximizers, localization, empirical classification, exact bulk equality, phase alignment, and outlier exclusion, culminating in `OnlineLowerTanh.eventual_intrinsicParityBound` in the `OnlineLowerTanhSharpParity` module.
2. The sharp physical affine bound and code localization for arbitrary neurons, in the support, `CodeExact`, and `CodeNetwork` modules.
3. The actual optimized balanced cost, high-order derivative and mixed-difference bounds, scalar Walsh coefficients, and strict path ordering, assembled in `ScalarCertificate`.
4. The actual family, bounded teacher and circuit, full-cube permutation, compact correct-score separation, and strict finite-width witnesses, assembled in `ConstructionAssembly` and `FamilyAssembly`.
5. The Gaussian posterior comparison, followed by final composition through `AnalyticAssembly`, with its last hypothesis discharged in `Main`.

Module names above have prefix `OnlineLowerTanh`. The accompanying source-closure manifest gives exact filenames and hashes. Intermediate types with intrinsic, scalar, geometric, or posterior hypotheses are proof interfaces: the main endpoint constructs and proves every such input. In particular, `eventual_intrinsicParityBound` proves the actual unrestricted parity inequality rather than assuming it.

The formal proof preserves the mathematical conclusions while allowing different intermediate arguments. Its high-order derivative and mixed-difference estimates replace the manuscript's inverse-Laplace route to the scalar signs. Its posterior comparison uses the shared finite-dimensional Gaussian open-event rate theorem. Neither substitution changes the learning model or the bound.

## Scope and independent review

The [independent statement audit](OnlineLowerTanh-independent-statement-audit.md) traces the actual posterior, all-network lower bounds, calibration, teacher resources, and quantifiers. The [independent global analytic audit](OnlineLowerTanh-global-independent-audit.md) checks the unrestricted single-parity argument and its physical-code interface.

This is a complete proof of the main online theorem and its stated finite-scale consequences. It is not a claim that every additional appendix equality/uniqueness assertion is separately exported in exactly the same form. In particular, the main proof uses the required residual estimates of orders zero and two; the unused order-one statement is not separately certified here.

## Reproduction record

The coherent main dependency build completed successfully (4143 Lake jobs). Reproduce from the Lean project directory:

```sh
lake build NeuralGeneralization.OnlineLowerTanhMain
lake env lean CheckOnlineLowerTanh.lean
```

[Source closure and hashes](OnlineLowerTanh-source-manifest.json) · [Main axiom-check output](OnlineLowerTanh-axioms.txt).
