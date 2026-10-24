# Statement audit: original three positive learning results

Reviewed on 23 October 2026 against the public snapshot `7c69c4abe5f93476d59c95b4d04d13b33ff01301`.

**Finding:** no substantive mismatch found between the three main manuscript learning statements and their closed Lean theorem statements. The review read the manuscript statements and unfolded the shared network, prior, posterior, complexity, sampling, and risk definitions. It did not infer correspondence merely from the theorem names or earlier review records.

## Shared model checked directly

The relevant definitions are in [Network.lean](../../NeuralGeneralization/Network.lean), [Model.lean](../../NeuralGeneralization/Model.lean), [FunctionPrior.lean](../../NeuralGeneralization/FunctionPrior.lean), and [FinitePosterior.lean](../../NeuralGeneralization/FinitePosterior.lean).

- `Cube d = Fin d → Bool`, with `labelReal true = 1` and `labelReal false = -1`, is an encoding of the full signed Boolean cube. `inputVector` appends exactly one constant input coordinate. `WeightIndex` supplies one input matrix, `r` internal matrices, and one linear readout. Thus manuscript depth is `L = r + 2`, with `r + 1 = L - 1` hidden layers and no extra hidden biases.
- `admissibleActivation` means bounded in absolute value by one and globally 1-Lipschitz, exactly as in the first two manuscripts. No assumption of nonconstant activation has been silently added; representability of the target is the stated hypothesis. Mean-field learning fixes the activation to `Real.tanh`.
- `marginEvent φ (1/2) f` requires the strict inequality `1/2 < f(x) z(x)` at **every** input. It is not a training-only constraint. The union of sign events is proved equal to the all-input absolute-margin event. Distinct sign events are disjoint at this margin.
- `realizesAtComplexity` requires positive integer width `C`, a strict-margin realization at that width, and every individual coefficient bounded by `C`. `isComplexity` additionally requires that `C` be the least such integer. This is exactly the bounded-weight network complexity used in the papers, rather than circuit gate count or unrestricted network width. It implies `N ≥ C ≥ 1`, avoiding a zero-width or degenerate-variance loophole.
- `productGaussian` is the product measure of the actual weight coordinates. `smallVariance` gives variances `N σ²/d`, `σ²`, and `σ²/N`; `powerVariance` gives `N^(1-γ)/d`, `N^(-γ)`, and `N^(-γ-1)`. These are the squares of the printed standard deviations. With the positive dimension, width, and scale hypotheses, `.toNNReal` does not change them.
- `functionMass` is actual Gaussian mass of the strict global sign event. `networkPosterior` divides surviving function masses by their sum. The common global-margin normalizer cancels by `posterior_div_const`; this is the specified conditional prior and consistency posterior, not a posterior-mean model or an arbitrary distribution over surviving functions. All three main conclusions also assert that the denominator is positive for every sample of the specified size.
- `InputLaw` is an arbitrary probability mass function on the cube. `sampleProbability` sums the independent product masses over ordered length-`n` samples, allowing repeats. It is exactly the IID law in the papers, not sampling without replacement. `posteriorRisk` is posterior-average classification error under the same input law.
- `confidenceFailure` counts correct-label probability **at most** `2/3`. Its complement is therefore the strict `>2/3` success event, including the intended treatment of equality and arbitrary posterior mixtures.

## Main statements and quantifier order

| Manuscript statement | Lean statement and closed proof | Direct comparison |
|---|---|---|
| Strong-prior paper, `thm:learning`, [source](../../../main-results/strong-prior-generalization/source/paper.tex) | `MainStatements.StrongPriorGeneralization`, proved by `MainProofs.strongPrior` | For each fixed depth, one polynomial is chosen before activation, dimension, target, and width. For every finite `N ≥ C` and requested error, a positive `σ₀` is chosen **before** the distribution, sample size, and failure probability. Every `0 < σ < σ₀` obeys the printed `2/ε [p_L(d,C) + log(1/δ)]` sufficient-sample rule and risk bound. In particular, the formal statement does not claim a width-uniform scale threshold or silently allow `σ₀` to depend on the data distribution or sample size. |
| Above-mean-field paper, `thm:all-width-gamma-gt-one`, [source](../../../main-results/gamma-above-one/source/source/gamma-gt1-main.tex) | `MainStatements.AboveMeanFieldGeneralization`, proved by `MainProofs.aboveMeanField` | For each fixed depth and fixed `γ > 1`, the polynomial precedes activation, dimension, target, width, distribution, and statistical parameters. The exact finite prior is used at every `N ≥ C`. The displayed `2/ε [p(d,C,log(1/ε)) + log(2/(εδ))]` formula matches. There is no extra large-width assumption or limit. The polynomial may depend on `γ`, as the paper permits. |
| Mean-field paper, `thm:main`, [source](../../../main-results/meanfield-all-width/source/meanfield-all-width.tex) | `MainStatements.MeanFieldGeneralization`, proved by `MainProofs.meanField` | For each fixed depth, one polynomial works for every dimension, tanh target, `N ≥ C`, and common training/test law. It uses `powerPrior ... 1`, with the correct input/internal/readout variances. The displayed `6/ε [p(d,C,log(1/ε)) + log(6/(εδ))]` rule gives risk at most `ε/3` **and** strict-confidence failure mass at most `ε`, on the same sample event of probability at least `1-δ`. |

The Lean statements represent an unspecified polynomial by `A(1+d+C+t)^m`, with `A > 0` and natural `m`. All arguments are nonnegative in their stated ranges, so a sufficiently large such envelope dominates any fixed polynomial, and conversely is itself a polynomial. This is equivalent for these existential polynomial claims; it does not certify every sharper intermediate numerical formula printed elsewhere in the papers.

The first two main theorems concern average posterior error. Their strict-confidence corollaries are separately proved in [CheckConfidence.lean](../../CheckConfidence.lean): they apply the main bounds at error `ε/3`, changing the outer factor to `6/ε` and making the corresponding substitutions inside the logarithms. This distinction preserves, rather than conflates, the two prediction guarantees.

## Proof boundary and machine recheck

The final proofs have exactly the named proposition types and no additional compression, target-mass, or analytic premises. Their final assemblies were inspected: the strong-prior and above-mean-field proofs construct polynomial envelopes and discharge their concrete model estimates; the mean-field proof supplies the proved aggregate-tail theorem to the learning theorem.

On the already-built verification project `/workspace/nnbayes-lean-batch-two-clean`, the following commands were rerun successfully with the pinned Lean 4.32.0 toolchain:

```text
lake env lean CheckMain.lean
All four exact main statements have closed proofs using only the standard axioms.

lake env lean CheckConfidence.lean
Strict >2/3 confidence corollaries of the strong-prior and above-mean-field theorems verified.
```

The eight reviewed definition/endpoint files and the two gate files were compared byte-for-byte with the public-source worktree; all matched. This is a statement review plus rerun of the exact-type and axiom gates using the existing checked build, not another clean rebuild of the entire proof library. The permitted axioms remain `propext`, `Classical.choice`, and `Quot.sound`.

This finding concerns the three main learning claims and the named confidence corollaries. It does not extend their verification label to every ancillary prior-complexity comparison, Boolean-circuit compilation claim, optimized constant, or appendix.
