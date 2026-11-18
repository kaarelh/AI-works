# Independent mathematical review

Reviewed 18 November 2026 (UTC) by a separate mathematical-review agent. This review covers the complete current ReLU manuscript, including both actual finite-prior extensions and the fixed-width corollary. It is conventional mathematical review, not Lean verification or external human peer review.

## Reviewed source hashes

| Source | SHA-256 |
|---|---|
| `source/paper.tex` | `f8041282d7d747de0b8065c38d45374e731072f4bc7273ac381a296fcbd20b4d` |
| `source/finite-positive.tex` | `abe39a1507add7febebe56f182f3ac3e2263d81b0b6b7254af354e33ebdd1fee` |
| `source/finite-negative.tex` | `cb062efced5e0d596d579bdc48cc0a694134e36bd1ea8320dd8338b0794b5af4` |

Localized-noise source SHA-256: `1bd5f088c1dd9d03938392409a49f658e32adcec01f8ffd56900522a52925427`.

## Verdict and theorem scope

I found no substantive mathematical gap. The positive and negative strict exponent conditions match at `Ha+(H+1)b=1/2`. The positive theorem treats arbitrary bounded IID labels, raw squared-error likelihoods, every learner width above comparator width, and coefficient-one comparison with the best bounded-weight teacher. The negative theorem uses one law and one sample event for all sufficiently large learner widths and all temperatures, including temperatures selected from the data.

Both conclusions hold for actual finite canonical Gaussian priors at every gamma at least two. For one hidden layer they hold at every gamma at least one. Separate strong-prior theorems remain available outside these finite regimes. The main negative exponent statement assumes positive width-growth exponent; a separate width-four corollary handles arbitrarily growing coefficient bounds.

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

This does not prove an exponential-in-depth lower bound at one fixed teacher width. The laws vary with sample size, so consistency on one fixed law is not refuted. Scaling labels scales both signal and noise; the small-noise remark does not claim a small flip probability or an excess independent of noise magnitude. Mixing posteriors across temperatures is outside the individual-temperature result. Deep finite exponents between one and two remain outside this manuscript's conclusions.

The theorem statements, proof conventions, abstract, comparison table, and corollaries are consistent about these limits. The exact computational construction checks are useful corroboration but are not assumptions of the mathematical proofs.


## Final biased-teacher extension

The added ReLU comparator remark was independently checked. An ordinary teacher with all weights and hidden/readout biases bounded by B at least one compiles into the specified architecture by adding one constant-one neuron per hidden layer. The first bias and subsequent self-edges are one, and every original bias becomes an incoming edge of that value. Width increases from m to m+1, while depth and coefficient cap are unchanged. All positive theorems consequently apply with m+1; the learner prior remains the same.

Reviewed PDF SHA-256: `9665ea57ec490250c962d4ad5d57873c56c270cc51b2bd50971554e473013dd6`.


## Localized unit-amplitude noise

The final `localized-noise.tex` corollary was independently checked. Its noise component has mass p, its inner signal pair has mass `r=p exp(-p)/32`, and the remaining probability is assigned to zero-labeled outer anchors. The teacher and its weights are unchanged. The stated diagonal covariance and lower eigenvalue bound are correct.

The same singleton concentration event applies with singleton rate at least `p exp(-p)`. The exact memorizer is zero on the entire negative-tag component, so its residual comparison cost tends to r. For sufficiently large sample count the residual is at most `p exp(-p)/16`, while singleton mass is at least `p exp(-p)/2`. Reverse triangle and Jensen give noisy excess exceeding `p² exp(-p)/5`. In the large-temperature branch the unit-amplitude close pair gives excess at least `p exp(-p)/128`, exceeding the stated common constant `p² exp(-p)/256`. The finite Gaussian comparison and stochastic-energy estimates remain uniform over the asserted widths, exponents, and temperatures.

The corollary keeps signal amplitude one while making noisy input mass arbitrarily small. It correctly allows its excess constant, covariance lower bound, and sufficiently-large-sample threshold to depend on p, and does not describe this as an independent fixed-probability label-flip model. No substantive mathematical issue was found.
