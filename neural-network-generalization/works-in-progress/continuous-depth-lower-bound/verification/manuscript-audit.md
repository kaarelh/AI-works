# Independent mathematical audit of the assembled manuscript

Manuscript: *Exponential depth dependence in Bayesian neural-network regression*.

I independently checked all four assembled source files: `paper.tex`, `memorization.tex`, `posterior.tex`, and `meanfield.tex`. I found no substantive mathematical gap. This is an AI-agent mathematical review, not a Lean formalization.

## Statements and quantifiers checked

The main construction has input dimension two, teacher width three, weights bounded by thirty, and a single fixed nonatomic Cantor distribution on an arc of the unit circle. Padding the teacher to width thirty respects the convention that the weight bound is at most the width. Training and testing tolerances are **1/8 and 1/4**, respectively. The confidence criterion is correct-output posterior probability greater than **2/3**. The good-sample probability is at least **49/50**.

- In the strong-prior limit, width and depth are fixed before the prior scale tends to zero. The probability that confidence-error mass is at least one half has limiting lower bound 49/50. The sample range is `n <= exp(r/100)` at teacher depth `r+1`, with every learner width above the stated polynomial sample-dependent threshold.
- For each fixed exponent above one, the actual finite-scale posterior has confidence-error mass at least one half on every separated sample, once width exceeds the explicit polynomial threshold in sample size and depth. The polynomial degree may depend on the exponent's distance above one.
- At the mean-field exponent, width tends to infinity with depth and sample fixed. On a set of samples of probability at least 49/50, the **liminf** of confidence-error mass is at least one half. The exponential sample exponent is a sufficiently small universal positive constant; it is not asserted to equal 1/100. No growing-depth width threshold is quantified here.
- Every minimum-energy exact interpolant fails, as do all mixtures of such minimizers and the stated iterated strong-prior, zero-tolerance limits. This is not an assertion about conditioning on exact real values at a fixed prior scale.

## Main proof checks

**Expanding teacher and distribution.** The explicit two-tanh map has inverse branches with contraction at most 1/3 and co-contraction at least 1/20. Endpoint and derivative bounds have elementary exponential-series certificates. The constant rail implements iteration without internal biases. The fixed Bernoulli inverse-branch measure is nonatomic, invariant under the teacher map, and satisfies the stated interval-mass estimate. Its small-ball bound yields the 49/50 sample-separation probability. The sphere embedding remains two-Lipschitz on the support.

**Exact low-energy memorizer.** The approximate tanh-step evaluation matrix is invertible by a Neumann series. Inverse calibration through the bounded, increasing scalar channel preserves exact real-valued labels. The channel is concave on the positive half-interval, so its inverse does not enlarge label magnitudes. This ensures the exact interpolant stays globally bounded. Balanced cloning is used only in the first shallow layer; all later matrices are exactly rank one. Thus the energy bound has leading term one per depth layer, rather than an unwanted constant multiple per layer. The artanh and reciprocal-ratio sum estimates, depth count, energy bound, and depth-independent product-norm ceiling all check.

**Strong-prior posterior.** A strict open neighborhood of the exact memorizer gives the denominator lower exponential rate. The radial Gaussian energy tail gives the numerator upper rate. Their comparison is at fixed finite parameter dimension. Weighted energy normalization cancels correctly in the product-of-layer-norms bound. The conversion from samplewise eventual posterior concentration to a limiting sample-probability statement uses Fatou's lemma, without assuming a prior-scale threshold uniform in the sample.

**Finite exponents above one.** The symmetric convex typical Gaussian set has the claimed probability by chi-square and sphere-net bounds. Its normalized blocks have small operator norms at the stated width threshold. The telescoping perturbation estimate uses a polynomial product-norm ceiling and yields a uniform output approximation. Gaussian symmetry gives the shifted-set denominator; Gaussian isoperimetry bounds the distance tail. Subtracting the metric projection produces a low-energy representative. The proof does not incorrectly assert that the actual finite-scale posterior parameters have small total Frobenius energy.

**Posterior mixtures.** Each good predictor fails at least one member of every paired input. Integrating this pointwise fact bounds the sum of the two correctness probabilities. Therefore mixtures and ties cannot remove the lower bound. For finite exponents, uniform approximation to a low-Lipschitz function suffices; all tolerance constants have slack.

**Mean-field endpoint.** The finite-domain LDP is a continuous contraction of independent Gaussian empirical measures and a Gaussian readout. It applies to arbitrary finite input sets, including singular initial covariance. Gaussian quadratic transport gives the stated rate-dependent pairwise metric bound. The low-rate training witness uses genuine weight-space seed laws, so its rank-one covariance lower bound is defined on the full finite input set. Dilution reduces seed entropy to a constant; free cooling loses only an inverse polynomial signal; logarithmically many final Gaussian shifts amplify it. The allocation of initial, free, amplification, and final layers totals exactly `L-1`. Approximating the observed labels by signs times 3/5 produces total training error below 53/500, strictly below 1/8.

For the endpoint posterior, the finite training marginal supplies the denominator lower bound and each two-point test marginal supplies the numerator upper bound. The ratio tends to zero for each fixed test pair. Bounded convergence over the pairing then proves the confidence-error liminf. No functional LDP or test-pair-uniform convergence is assumed. The theorem correctly states a liminf of one half, rather than asserting eventual error at least exactly one half.

**Additional conclusions.** Coercivity and continuity justify the exact-minimizer and iterated-limit assertions. Smoothing the Cantor law at a depth-dependent exponentially small scale preserves the separation estimate and paired-input barrier, giving the stated smooth-density variant for all three prior regimes and the exact-interpolation conclusions. For the mean-field extension, the enlarged label deviation is at most 0.11 and the witness adds less than 0.006, totaling less than 1/8. The reduced paired target gap is 0.98, still sufficient for the entropy-based metric obstruction. The first-feature construction uses only bounded scalar inputs and extends unchanged to the slightly enlarged arc.

## Scope checks

The theorem disproves distribution-free, learner-width-uniform polynomial dependence on teacher depth for these continuous-domain regression learners. It does not establish the original Boolean-cube classification claim, a uniform-sphere lower bound, failure at every narrower width, efficient-computation limitations, or a result for non-Gaussian priors. The fixed input law is singular; the smooth-density variant varies with depth.

## Reviewed source hashes

The following SHA-256 hashes identify the final assembled sources reviewed. The wrapper's final endpoint-summary, scope, and smooth-density additions have also been checked.

```text
96b0fa9f28ba23f6cf53981056e0e2ef874fc063a3142eda4e21e874a83dcd7c  paper.tex
527e7655a3cc6c3ac9dca578ad08693fbe9c333e73b42cc9f56558877c76151d  memorization.tex
d6a585be821e158746c09e2acf5686a0344540e44688fde3a62bf2cf2ea92814  posterior.tex
032d8d3a5febf5c841096f320b971368f0f3caeac6ad2428c7ff1954c6fbd05e  meanfield.tex
```
