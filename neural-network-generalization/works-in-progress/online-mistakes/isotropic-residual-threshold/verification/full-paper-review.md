# Independent full-manuscript mathematical review

Reviewed on 6 November 2026 by a separate research agent (`wide_gelu`). This is an informal mathematical audit, not a Lean formalization.

The complete assembled paper and its included selector proof were checked at these frozen snapshots:

- `source/paper.tex`: SHA256 `5eb9104f73f0f07de0605d0f6bc653ad904104b81d73e69bfb1ded52d6cf0a3e`.
- `source/selector.tex`: SHA256 `244bdd04e4000f67356b36032208e70ba5783e6b6f42139aa01fdbc74194f522`.

No mathematical gap was found in the stated results.

## Scope and quantifiers

The activations are the fixed **discontinuous** functions `sign(t)+t` and `sign(t)+tanh(t)`, with the stated extension to `sign(t)+c tanh(t)` for every fixed `0<c<=1`. The Gaussian prior, its relative layer normalization, and first-layer coordinate isotropy are unchanged. The domain is the full Boolean cube with an appended constant coordinate, and the posterior uses exact labels and the global absolute output margin greater than one half.

The theorem correctly separates three claims: the strong-prior limit at each fixed width; the direct width limit for every fixed `gamma>1` and positive prefactor; and a sufficiently small common prefactor that works at every width and every `gamma>=1`. The unit-prefactor mean-field case is not asserted. The proof uses the activation jump and does not establish the corresponding statement for ordinary tanh, ReLU, or hardtanh.

## Exact energy reductions

For the linear residual, the KKT mean identity makes the residual's active-data average exactly linear. The sign contribution is bounded in absolute value by one. The two Cauchy--Schwarz estimates give the stated scalar profile at every width, and the cloned network attains it. Its radius is positive, the profile lies strictly below one quarter, and strict monotonicity in the affine margin norm follows by evaluating at the larger norm's positive minimizing radius.

For the bounded residual, the proof's local tangent envelope is valid on the whole interval `[-sqrt(2),sqrt(2)]`, including negative scores and zero. The Boolean input norm and the unit-margin lower bound on Q justify both the small-atom radius and `dQ>=1/2`. The square-completion coefficients satisfy the stated stationarity relation, the resulting quadratic has positive leading coefficient, and its exact floor is negative. Large atoms have nonnegative floor because the activation is bounded by two. Thus every atom is covered; the proof does not restrict competitors to affine sign functions or cloned representations.

The proposed clones attain the bounded scalar profile too. The strict monotonicity and the gap below one quarter follow exactly as stated. The extension to arbitrarily small fixed positive c is valid; setting c to zero would remove the strict energy order and is not covered by this argument.

## Nonthreshold functions

The convex-hull separation argument is valid on the finite input set: a Boolean labeling is not an affine threshold precisely when its signed augmented inputs have zero in their convex hull. For the linear residual, this annihilates the residual average and forces the readout energy alone to be at least one quarter.

For the bounded residual, the tangent envelope at radius zero bounds the active average by one for small atoms, while the global activation bound controls large atoms. Square completion with coefficient one gives the same total energy lower bound of one quarter. This argument covers the union of every nonthreshold output cell, so no unproved restriction of posterior support or count of nonthreshold functions enters the IID proof.

## Selector construction and teacher

The diagonal and carry calibration constraints imply the stated lower bounds on the affine coefficient variables. The minimum is unique, its full-cube scores are odd integers, and adding the next correct label changes the minimum from Q_t to Q_(t+1), with exact gap `4(t+1)`. The input order has no duplicates after the specified removal and contains exactly `2^k-k-1` designated rounds after at most `4k+3` calibration examples.

The comparator has a linear-size bounded-fan-in Boolean circuit, and every raw input is essential, giving the matching lower bound. Positive scaling of the final affine representation gives a width-one teacher with all coefficients at most one in magnitude. The activation jump preserves signed output strictly greater than one even after this scaling. This teacher claim would fail for an ordinary continuous tanh activation; the manuscript correctly keeps the discontinuity explicit.

## Actual Gaussian probabilities and growing width

The physical neuron coordinates `(sqrt(d)u_j,b_j)` are independent isotropic Gaussians of variance `N sigma²`, and the network energy is their average squared norm. A small readout amplification followed by a fixed coordinate box preserves every preactivation sign and every strict output margin. Its volume is positive and its maximum neuron energy is strictly below the competing energy threshold.

The product-box lower bound for the posterior denominator and the optimized chi-square upper bound for the numerator are correct. On division, all logarithmic variance factors cancel, leaving the claimed bound

`exp[-delta/(2sigma²)+C N]`.

The chi-square tail condition is exactly `(d+2)N sigma²<e1`. Both this condition and the exponential comparison give the three stated variance/width regimes. The all-width small-prefactor assertion follows because `N^gamma>=N` for `gamma>=1`. Taking common constants over finitely many histories and a union bound gives the joint prediction statement without requiring independent posterior samples at different rounds.

This is an actual posterior comparison. In particular, any globally admissible network that predicts the next true label satisfies the enlarged training margin constraints and is included in the competing energy event.

## IID guarantee

The target's complete-cell witness supplies a denominator independently of the observed sample. The one-quarter nonthreshold energy threshold and the product-box lemma therefore suppress all nonthreshold posterior mass uniformly over target-consistent histories and input distributions in the specified regimes.

The threshold truth-table count is bounded by the hyperplane-region estimate used in the paper. The consistency union bound with the displayed sample size gives population error at most `epsilon/4` for every consistent threshold function. Adding nonthreshold posterior mass at most `epsilon/12` gives posterior-average error at most `epsilon/3`. Markov's inequality then bounds the input mass where correct-label posterior probability is at most two thirds by epsilon, exactly matching the theorem's confidence convention.

The variance thresholds in this IID conclusion may depend on the requested accuracy and target, as stated by the separate sufficiently-small/sufficiently-large qualifications. They are independent of the realized training sample and its input distribution.

Whitespace-only source normalization: one trailing space was removed from `source/selector.tex`; the isolated rebuilt PDF has identical extracted text to the reviewed publication PDF. The source hash above includes that normalization.
