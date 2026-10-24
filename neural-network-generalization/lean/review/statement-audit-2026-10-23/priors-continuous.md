# Statement audit: non-Gaussian priors and continuous domains

Date: 23 October 2026. Reviewed snapshot: `7c69c4abe5f93476d59c95b4d04d13b33ff01301`.

This is a fresh AI review of the manuscript statements against the Lean source,
including the definitions used in the final statements. It is not human peer
review or a new independent proof. Existing correspondence records were consulted
only after inspecting the manuscript and formal source. Kernel/build verification
is recorded separately in the collection verification record.

**Finding: no mismatch found in the seven main learning statements of these three
papers.** The qualifications below delimit which ancillary statements are not
included and explain the equivalent representations used in Lean.

## Non-Gaussian weight priors

Paper: `side-results/non-gaussian-priors/source/paper.tex`, Theorems
`thm:strong-main` (line 154) and `thm:finite-main` (line 171).

Formal targets: `BatchTwoNonGaussianStatements.lean`,
`StrongPriorGeneralization` (line 13) and `FiniteScaleGeneralization` (line 33).
Closed endpoints: `BatchTwoNonGaussian.strongPrior`, `finiteScale`, and
`mainResults`.

- **Coordinate law:** `BatchTwoNonGaussianModel.lean:21` specifies a probability
  measure with density `exp(-V)/Z`, positive `Z`, an even C² potential, positive
  lower and finite upper bounds on its second derivative, and second moment one.
  Evenness gives mean zero, so the second moment is the paper's variance-one
  requirement. These fields do not assume a concentration, compression, or
  learning theorem. `BatchTwoNonGaussianGaussianInstance.lean:20` constructs a
  standard Gaussian member; the class is not an empty or inconsistent placeholder.
- **Actual prior:** `productPrior` at line 77 is a product of the supplied scalar
  law's pushforwards by multiplication. `smallScale` and `powerScale` (lines
  90 and 95) give exactly the first/internal/readout standard deviations printed
  in the paper. No Gaussian law replaces the non-Gaussian learner.
- **Architecture and teacher:** the common network uses one constant input
  coordinate, tanh hidden layers and a linear readout. Formal `r` means `r+2`
  total layers. `Network.lean:135` and `:141` define a strict-margin bounded-weight
  implementation and its minimum width. Thus `isComplexity` is the paper's
  `C_L(f)`, with width and weight magnitude both counted.
- **Conditioning and prediction:** `FunctionPrior.lean:73` assigns actual measure
  to each all-input strict-margin region; `networkPosterior` at line 92 normalizes
  those masses after exact label consistency. The global normalizer cancels,
  as in the paper. `posteriorRisk` at line 134 averages errors under the entire
  function posterior. `confidenceFailure` at line 143 includes equality at 2/3.
  The formal endpoints also explicitly assert positive training denominators.
- **Strong-prior quantifiers:** depth and scalar law precede the existential
  polynomial coefficient and degree. Dimension, target, finite learner width
  and accuracy precede the scale threshold. The threshold precedes the input
  law, confidence parameter and sample count. This is the printed order, with
  no uniform small-scale threshold across widths added or silently assumed.
- **Finite-scale quantifiers:** every fixed exponent at least one has one
  polynomial independent of the teacher and learner width. Every width at least
  `C_L(f)` is included. The endpoint branches into the proved critical and
  supercritical theorems; it assumes neither an infinite-width limit nor one
  common polynomial as the exponent approaches one.
- **Budgets:** both `6/epsilon` factors, both confidence logarithms, the
  `epsilon/3` Gibbs risk conclusion and `epsilon` confidence-failure conclusion
  agree. The positive constant times a natural power of a sum is a legitimate
  polynomial of the permitted variables and can majorize an arbitrary polynomial
  on these nonnegative arguments.

The more general quadratic-tail strong-prior extension and the separate
prior-complexity comparison discussion are not automatically certified by these
two endpoints. Their omission is already identified in the coverage table.

## Continuous-domain regression

Paper: `side-results/continuous-domains/source/paper.tex`, Theorems `thm:strong`
(line 155) and `thm:finite` (line 176).
Formal targets: `BatchTwoContinuousStatements.lean:31` and `:52`.
Closed endpoints: `BatchTwoContinuous.strongPriorRegression` and
`finiteScaleRegression`.

- **Domain:** `admissibleDomain` (line 19) is nonempty, compact, and satisfies
  the exact Euclidean unit-ball inequality `sum_i x_i^2 <= 1`. A probability
  measure on the domain is represented by a Borel probability measure on the
  ambient finite-dimensional real space with zero mass outside it. This is
  equivalent to the manuscript's convention, not a restriction to discrete data.
- **Teacher:** the statement quantifies over every actual width-`C` teacher at
  the learner's depth and every independent weight bound `B >= 1`. It adds no
  minimum-complexity, Boolean-label, input-margin, Lipschitz-certificate or
  robustness premise. `r+2` is again the total depth.
- **Prior and likelihood:** the same literal non-Gaussian product prior is used.
  `BatchTwoContinuousModel.lean:94` requires absolute training discrepancy
  strictly below `rho`; `posterior` at line 98 conditions only on that event.
  There is no condition on unobserved inputs. The exact teacher's real output
  supplies the labels.
- **Risk and confidence:** lines 110–125 define error as absolute discrepancy
  strictly greater than `tau`, correct probability using discrepancy at most
  `tau`, and confidence failure using correct probability at most 2/3. The risk
  is the product-measure probability under the whole posterior, not posterior
  mean squared error or error of a selected minimizer.
- **Budgets:** `inverseGap = 1/min(1,tau-rho)` and
  `logInverseTolerance = log(1/min(1,rho))` are exactly the printed parameters.
  The strong theorem has no training-tolerance term in its sample polynomial;
  the finite-scale theorem has the stated logarithmic tolerance and accuracy
  terms. Both exact factors and confidence logarithms match.
- **Quantifiers:** the strong-prior threshold precedes input law, sample count
  and delta, while allowing dependence on the fixed width and tolerances. The
  finite theorem is for every fixed exponent at least one, every `N >= C` and
  every common training/test law. It does not assert one simultaneous sample
  event for all widths or exponents; neither does the paper.
- **Normalization:** the final proposition does not repeat positivity as a
  separate conjunct, but the actual proofs establish positive teacher-tube
  mass and use probability measures for the conditioned posterior. In particular
  the stated confidence bound cannot be obtained from a zero conditional measure:
  that measure has zero correct probability and confidence-failure mass one.

Ancillary classification, exact-interpolation and iterated-limit statements,
and the bounded-coordinate-domain extension are not all included in this
formalization claim. The FAQ should preserve that distinction.

## Exponential depth dependence in continuous regression

Paper: `works-in-progress/continuous-depth-lower-bound/source/paper.tex`,
Theorems `thm:strong` (line 142), `thm:finite` (line 167), and
`source/meanfield.tex`, Theorem `thm:critical-regression-depth-lower` (line 11).

Closed endpoints:

- `BatchTwoContinuousDepthLower.strong_prior_depth_lower_bound`
  (`BatchTwoContinuousDepthStrongMain.lean:134`);
- `BatchTwoContinuousDepthPower.finite_power_manuscript_depth_lower_bound`
  (`BatchTwoContinuousDepthPowerManuscript.lean:30`);
- `BatchTwoContinuousDepthCritical.critical_manuscript_depth_lower_bound`
  (`BatchTwoContinuousDepthCriticalMain.lean:14`).

The following witness facts are separate proved declarations, rather than
extra assumptions on the main endpoints:

- `BatchTwoContinuousDepthSphere.lean:65` defines the one fixed input law as
  the pushforward of the fair infinite-bit product measure under the explicit
  Cantor coding onto a circle arc. Its probability instance, null-singleton
  instance and `inputLaw_sphere` prove that it is a nonatomic Borel probability
  law concentrated on the unit circle. It has no depth or sample-size argument.
- `depthTarget` at line 88 is exactly the iterated expanding map on the first
  input coordinate. `target_implementation_all_depths` in
  `BatchTwoContinuousDepthStrongMain.lean:161` proves the width-three teacher,
  bound thirty on every weight, and the output bound 13/20 on the law's support,
  at every positive target depth index.

The three endpoints match as follows:

1. **Strong prior:** target index `R` gives teacher/learner depth `R+1`, since
   the formal internal-layer index is `R-1`. The formal width resource
   `interpolationWidth n` is exactly the manuscript's ceiling defining `M_n`:
   its slope and separation unfold to the printed `a_n` and `Delta_n`.
   The sample range is precisely `1 <= n <= exp(R/100)`, the width assumption
   is `N >= max(30,M_n)`, and the conclusion is a lower limit, as positive
   scale tends to zero, of sample probability at least 49/50 for confidence
   failure mass at least one half. Width is fixed before this limit.
2. **Finite exponent above one:** the endpoint proves a sufficient polynomial
   width `B*(n+R)^(161*ceil(1/zeta))`, with `B` allowed to depend on positive
   `zeta`. It covers every positive scale with squared scale at most
   `N^(-(1+zeta))`, exactly the manuscript's scale interval. It uses the same
   fixed law and targets, the same exponential sample range, and the same
   finite probability conclusion. This proves the headline existential
   polynomial threshold; it is not a claim that the larger formal polynomial
   is the smallest or identical to every intermediate explicit threshold in
   the manuscript. The two positive depth cutoffs can be replaced by their
   maximum when reading the manuscript's shared `r_0` convention.
3. **Mean field:** `criticalPosterior` unfolds to the actual independent
   Gaussian `powerPrior 2 N (h-1) 1`, with variances 1/2, 1/N and 1/N²,
   conditioned only on training discrepancy below 1/8. One universal `c>0`
   and cutoff precede `h,n`. On the same sample event of probability at least
   49/50, both lower limits as width tends to infinity are at least one half:
   Gibbs error at test tolerance 1/4 and the mass with correct-output
   probability **strictly below** 2/3. That strict inequality is exactly the
   one printed in the critical theorem. The other two theorems use `<=2/3`,
   also exactly as printed. No uniform width threshold in growing depth is
   inferred from the critical endpoint.

All three statements concern full posterior mixtures. No unique minimizer,
posterior-mean prediction, Gaussian-process surrogate, or unproved denominator
estimate is an assumption of a final endpoint. Their fixed nonatomic law is
not uniform circle measure. The ancillary LDP, exact-interpolation,
iterated-limit and varying smooth-density statements remain outside the stated
main-endpoint coverage.

## FAQ implications

The FAQ already correctly identifies the two main non-Gaussian learning
statements and both continuous regression statements as Lean verified. Its
continuous-depth discussion can state explicitly that all three main lower-bound
regimes are verified, while leaving exact interpolation, iterated limits and
smooth-density variants outside that certification. The non-Gaussian section's
broader tail and prior-ordering paragraphs should likewise not inherit a Lean
label from the two verified main learning theorems.
