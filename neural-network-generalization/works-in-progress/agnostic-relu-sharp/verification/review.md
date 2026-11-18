# Independent mathematical review

Reviewed 18 November 2026 (UTC) by a separate mathematical-review agent. This review covers the complete current ReLU manuscript, including the all-canonical-exponent negative extension, the finite positive theorem, and the fixed-width and localized-noise corollaries. It is conventional mathematical review, not Lean verification or external human peer review.

## Reviewed source hashes

| Source | SHA-256 |
|---|---|
| `source/all-canonical.tex` | `0b0c6a7ce335d7ce500cc0f73b2b8e6ea2b24f88783c6f2a7cb504ab3f7ffd83` |
| `source/finite-negative.tex` | `cb062efced5e0d596d579bdc48cc0a694134e36bd1ea8320dd8338b0794b5af4` |
| `source/finite-positive.tex` | `abe39a1507add7febebe56f182f3ac3e2263d81b0b6b7254af354e33ebdd1fee` |
| `source/localized-noise.tex` | `1bd5f088c1dd9d03938392409a49f658e32adcec01f8ffd56900522a52925427` |
| `source/paper.tex` | `ef40e5aade887cbb9d75927298bc8cd441e9e75d2bbf56a6e690186b11bf4f95` |
| `paper.pdf` | `b7a91e8c32634d2a19fcdb962b97b132265795c032a080d5adacb3354ccc225e` |

## Verdict and theorem scope

I found no substantive mathematical gap. The positive and negative strict exponent conditions match at `Ha+(H+1)b=1/2`. The positive theorem treats arbitrary bounded IID labels, raw squared-error likelihoods, every learner width above comparator width, and coefficient-one comparison with the best bounded-weight teacher. The negative theorem uses one law and one sample event for all sufficiently large learner widths and all temperatures, including temperatures selected from the data.

Both conclusions hold for actual finite canonical Gaussian priors at every gamma at least two. For one hidden layer they hold at every gamma at least one. The negative conclusion now extends to every gamma at least one at every hidden depth, at the larger polynomial width threshold proved by the native-covariance construction. The sharp positive boundary for multiple hidden layers at exponents between one and two remains open. Separate strong-prior theorems retain their stated scope. The main negative exponent statement assumes positive width-growth exponent; a separate width-four corollary handles arbitrarily growing coefficient bounds.

The lower-bound dimension is logarithmic in sample count. The matching threshold concerns distribution-uniform guarantees with polynomial dimension dependence; it is not claimed at one fixed dimension. Equality is open. These restrictions appear in the abstract and main statements.

## Positive argument

Exact balanced cloning has the stated first-layer, internal, and readout energies at every integer learner width. Positive homogeneity permits balancing all layer energies without changing the represented function. This gives energy proportional to `m^(2H/(H+1)) B²`, not the unbalanced quadratic width cost.

The capacity argument is valid for the union over all widths. After normalizing hidden Frobenius norms, optimizing the readout gives a Euclidean norm of signed neuron sums. The row sum-of-squares constraint reduces this to one unit-row supremum. Absolute Rademacher contraction removes each ReLU layer with the stated factor two. Iteration ends at the Euclidean linear class. The amplitude bound follows from the same product norm. Rational approximation and slight radial shrinking provide a separable class.

I checked the smooth-loss shell calibration, both absorption coefficients, the teacher Bernstein bound, and the growing-comparator exponents. Weighted Laplace tails with `1+Q^L` justify raw posterior risks in the strong-prior limit; ordinary means follow by Jensen.

For the actual finite theorem, the independently Gaussian perturbation of a balanced clone has the displayed normalized root mean square output error. Gaussian relative entropy preserves coefficient one on teacher energy and retains half the posterior energy penalty. Prior ReLU moments are computed using Gaussian symmetry, rather than an invalid bounded-activation argument. Splitting the low-objective tail changes the Gaussian covariance by a factor two, and its exact chi-square moment bounds the required `Q^L` weight. The statistical calibration absorbs less than the retained energy penalty. The resulting sample event is common to all stated widths and exponents.

## Negative construction

The exact Boolean memorizer's Fourier representation is correct. Each parity uses at most `j+1` ReLU features with bounded augmented row norm and coefficient squared sum at most `4D`. The positive and negative channels can be relayed without approximation. Their layer-energy product yields the stated memorizer energy and the width threshold at every larger integer width.

The four-group tent is exact, odd, globally bounded by one, and zero at the outer anchors. All first-layer biases and subsequent weights satisfy the prescribed cap. Its slope at the close inner pair has the required `m^H B^(H+1)` order.

The mixed data law has the teacher as its conditional mean, the stated Bayes risk, and well-conditioned diagonal covariance. The singleton-occupancy and steep-count concentration bounds give a parameter-independent sample event. At low temperature the memorizer forces a small count-weighted residual on noisy atom means; the reverse triangle inequality then forces nonzero population prediction norm. At high temperature energy limits the difference between the close oppositely labeled signal points.

These are direct bounds on posterior predictions. The proof does not infer a bad posterior mean from bad individual predictors. Jensen preserves the residual bound for means, while expected sensitivity controls their close-pair difference.

## Canonical finite lower bound

The low-temperature comparison is a full-dimensional Gaussian around the exact balanced memorizer. Its perturbation error and entropy are uniform over all eligible widths and exponents; the added entropy term is only logarithmic in sample count. It therefore preserves the constant noisy residual gap.

At high temperature, the evidence lower bound and exact Gaussian energy moment stochastically dominate posterior energy by a deterministic shift plus an exponential variable. Minkowski bounds its `L/2` moment. This yields the close-pair sensitivity bound directly for the ordinary raw mean, with no unspecified small-scale limit and no concentration-on-minimizers assumption. The clipped conventions are separately controlled, and Jensen gives their Gibbs-risk bounds. All constants used here are uniform in the stated widths and exponents.

## Corollaries and limitations

The width-four corollary follows by taking one neuron per tent group and a coefficient cap growing faster than `n^(1/(2L))`. Its dimension qualification is stated explicitly. The obstruction to one joint polynomial in teacher width, depth, and dimension follows by fixing a depth larger than the proposed width degree and then taking sufficiently large sample counts along the lower-bound sequence.

This does not prove an exponential-in-depth lower bound at one fixed teacher width. The laws vary with sample size, so consistency on one fixed law is not refuted. The localized-noise corollary does not claim a small independent flip probability or an excess independent of noise magnitude. Mixing posteriors across temperatures is outside the individual-temperature result. At deep finite exponents between one and two, the negative conclusion is proved here while the sharp positive boundary remains open.

The theorem statements, proof conventions, abstract, comparison table, and corollaries are consistent about these limits. The exact computational construction checks are useful corroboration but are not assumptions of the mathematical proofs.


## Final biased-teacher extension

The added ReLU comparator remark was independently checked. An ordinary teacher with all weights and hidden/readout biases bounded by B at least one compiles into the specified architecture by adding one constant-one neuron per hidden layer. The first bias and subsequent self-edges are one, and every original bias becomes an incoming edge of that value. Width increases from m to m+1, while depth and coefficient cap are unchanged. All positive theorems consequently apply with m+1; the learner prior remains the same.

Reviewed PDF SHA-256: `b7a91e8c32634d2a19fcdb962b97b132265795c032a080d5adacb3354ccc225e`.


## Localized unit-amplitude noise

The final `localized-noise.tex` corollary was independently checked. Its noise component has mass p, its inner signal pair has mass `r=p exp(-p)/32`, and the remaining probability is assigned to zero-labeled outer anchors. The teacher and its weights are unchanged. The stated diagonal covariance and lower eigenvalue bound are correct.

The same singleton concentration event applies with singleton rate at least `p exp(-p)`. The exact memorizer is zero on the entire negative-tag component, so its residual comparison cost tends to r. For sufficiently large sample count the residual is at most `p exp(-p)/16`, while singleton mass is at least `p exp(-p)/2`. Reverse triangle and Jensen give noisy excess exceeding `p² exp(-p)/5`. In the large-temperature branch the unit-amplitude close pair gives excess at least `p exp(-p)/128`, exceeding the stated common constant `p² exp(-p)/256`. The finite Gaussian comparison and stochastic-energy estimates remain uniform over the asserted widths, exponents, and temperatures.

The corollary keeps signal amplitude one while making noisy input mass arbitrarily small. It correctly allows its excess constant, covariance lower bound, and sufficiently-large-sample threshold to depend on p, and does not describe this as an independent fixed-probability label-flip model. No substantive mathematical issue was found.

## Final all-canonical-exponent integration

The integrated `all-canonical.tex` is byte-identical to the independently reviewed frozen native-covariance source. Its exact shifted-half-integer Boolean features, balanced mean energies, Gaussian-smoothed first-layer bias, signed-pair conditional mean identity, total-variance recursion, Gaussian relative entropy, and high-temperature operator moment all check. The detailed native-covariance review is retained separately in this verification folder.

The final theorem gives the negative result simultaneously for every finite gamma>=1, every temperature, and every learner width at least O_H(m+n^(2-1/L) polylog n). The localized-noise and fixed-width-four variants have the same enlarged threshold and respective constants. This does not change the positive theorem's finite-prior range.

The abstract, introductory regime statement, README, and final limitations correctly distinguish negative all-gamma coverage from the still-open sharp positive boundary for deep finite1<=gamma<2. The corollary excluding one joint polynomial in dimension, teacher width, and teacher depth now correctly cites the all-canonical negative theorem. Its exponent selection and logarithmically growing dimension justify the stated extension to each fixed gamma>=1. The source and PDF hashes above describe this final integrated package. No new mathematical gap was found.
