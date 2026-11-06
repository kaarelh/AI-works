# Isotropic online learning: publication and scope record

Date: 6 November 2026.

This research session adds six independently reviewed manuscripts. These are conventional mathematical proofs, not Lean formalizations. The online lower bounds have different, explicitly stated assumptions; none proves the unchanged isotropic result for ordinary tanh with the initial global margin restriction.

## Bounded threshold residual: every width and short calibration

[Paper and package](../works-in-progress/online-mistakes/isotropic-residual-threshold/) · [Detailed verification](../works-in-progress/online-mistakes/isotropic-residual-threshold/verification/README.md)

For the fixed bounded activation sign(t)+c tanh(t), with any fixed 0<c<=1, the unchanged isotropic Gaussian prior makes exponentially many online mistakes after linear calibration at every width in the strong-prior limit. The target has Boolean circuit size Theta(k) and a width-one teacher with unit-bounded weights. The theorem covers the actual posterior, including mixtures. It also gives direct gamma>1 limits and one sufficiently small positive mean-field prefactor that works at every width. The same learner has polynomial IID sample complexity.

The proof first establishes the exact all-width energy profile for sign(t)+t by KKT averaging and Cauchy--Schwarz. A tangent dual proves the bounded version, including all nonlinear competitors. A convex-hull certificate puts every nonthreshold function above energy 1/4, while every threshold function has strictly smaller optimal energy. A product-box Gaussian estimate handles the activation's discontinuity and the growing parameter dimension without interchanging limits. Two independent final-source reviews and a root review checked the statements, proofs, and quantifiers. The jump at zero is a substantive assumption; ordinary tanh is not covered.

## Arbitrarily small jumps added to tanh

[Paper and package](../works-in-progress/online-mistakes/isotropic-small-jump-tanh/) · [Detailed verification](../works-in-progress/online-mistakes/isotropic-small-jump-tanh/verification/README.md)

For every fixed epsilon>0, the bounded activation tanh(t)+epsilon sign(t), uniformly epsilon-close to tanh, gives an unchanged-prior isotropic counterexample at every width. The target has Boolean circuit size Theta(k) and a unit-bounded teacher of width ceil(1/epsilon). Dimension must be sufficiently large depending on epsilon. Initial calibration takes O(k^2) examples, and each of the exponentially many designated queries has O(k) accompanying examples.

The proof establishes an exact scalar energy minimum from an active affine KKT certificate with second-moment matrix at most 2I. An explicit pairwise-independent selector calibration supplies that certificate. A compact relaxation on neuron distributions, including possible jump values at zero, yields a strictly positive correct-query energy gap uniform over every width, even before the next calibration block is complete. A separate layer-cake/Hoeffding compression lemma for bounded monotone activations proves polynomial IID learning without assuming that all low-energy functions are thresholds. Independent reviews checked these components and the assembled final source; the root reviewed the dual, compactness, probability comparison, and compression proofs as well.

The theorem retains a fixed nonzero jump. It proves neither a counterexample for ordinary tanh nor stability under continuous smoothing. Its covariance condition is a verified certificate of the chosen histories, not a restriction added to the neural prior.

## Threshold activation with the unchanged prior

[Paper and package](../works-in-progress/online-mistakes/isotropic-threshold-allwidth/) · [Detailed verification](../works-in-progress/online-mistakes/isotropic-threshold-allwidth/verification/README.md)

For fixed sign activation, one hidden layer, the full Boolean cube, a constant input coordinate, global absolute output margin, and exact label conditioning, the paper constructs a linear-size Boolean target with a width-one, unit-bounded teacher. One fixed input permutation forces exponentially many mistakes at every sufficiently large width. The result concerns the actual Bayesian posterior, including mixtures, and covers the strong-prior limit, every fixed exponent gamma greater than one, and exponent one with a sufficiently small fixed scale. The Gaussian coordinate variances are unchanged and exactly equal within each layer.

The proof controls all wide-network Boolean functions by a finite-width Gaussian-tail estimate. The remaining threshold-function probabilities are ordered by integrating their isotropic Gaussian cones. Three independent final-source reviews checked the scaffold, cone ordering, finite-width estimate, posterior limits, teacher, and IID bound. The calibration prefix and sufficient width can be exponential. The activation is discontinuous; no transfer to ordinary tanh is asserted.

## Ordinary tanh with stronger readout regularization

[Paper and package](../works-in-progress/online-mistakes/isotropic-tanh-readout/) · [Detailed verification](../works-in-progress/online-mistakes/isotropic-tanh-readout/verification/README.md)

For ordinary shallow tanh, divide the usual readout variance by any factor A_N tending to infinity. The first-layer coordinate variances remain exactly equal. Every fixed gamma at least one and every fixed positive scale then admit exponentially many online mistakes after linear calibration, at all sufficiently large widths. The same target has a linear-size Boolean circuit, a same-depth teacher of width O(k^4) with unit-bounded weights, and a polynomial IID sample bound.

An exact all-width energy dual excludes arbitrary nonlinear competitors once the readout penalty is sufficiently large. A growing-dimensional Gaussian-volume estimate proves the posterior conclusion for arbitrarily slowly diverging A_N. This is a substantive prior change: its variance ratio tends to zero even when the power-law exponents are unchanged. The unchanged factor A_N=1 remains open. The paper also proves that the scalar witnesses used by this construction cannot remain optimal under that unchanged prior at large width.

Two independent final-source mathematical reviews checked the scalar dual, calibration, uniform Gaussian-volume argument, Fourier teacher, IID bound, and canonical-prior obstruction.

## Exact ReLU energy and the width needed to attain it

[Paper and package](../works-in-progress/online-mistakes/relu-parity-energy-width/) · [Detailed verification](../works-in-progress/online-mistakes/relu-parity-energy-width/verification/README.md)

For even parity degree r at least four, the exact all-width minimum of the unchanged isotropic shallow ReLU Gaussian energy is attained if and only if N is at least 2^(r-1). The same function has a unit-bounded teacher of width O(r^2). The proof identifies the sharp single-neuron parity correlation and its equality cases, then uses Fourier coefficients to force mass on every antipodal orientation pair. Two independent final-source reviews checked the argument, including the separate degree-two case.

This is an exact energy and representation-width result. It makes no exponential online-mistake, sample-complexity, or approximate-energy claim.

## Mean-field tanh with training-only margins

[Paper and package](../works-in-progress/online-mistakes/meanfield-without-global-support/) · [Detailed verification](../works-in-progress/online-mistakes/meanfield-without-global-support/verification/README.md)

For ordinary shallow tanh at fixed positive mean-field prefactor, omit the initial absolute-margin restriction at unobserved inputs and condition only on strict training margins. This changed learner has a polynomial total-mistake bound at every sufficiently large width, uniformly over arbitrary input orders, including adaptive orders. At fixed teacher weight bound and prefactor, the count is O(d^4+C^4). The result covers actual posterior confidence failures and posterior sampling, as well as test-output thresholds strictly below the training margin.

The proof uses a finite-dimensional Cramer large-deviation theorem for the complete output vector, identifies the unique relative-entropy projection onto the training constraints, and charges every limiting bad prediction to a definite increase in relative entropy. A Gaussian mixture around the bounded teacher supplies an explicit polynomial budget. Independent reviews checked concentration, entropy identities and constants, the teacher certificate, finite-history uniformity, and adaptive sampling. The width threshold is unquantified. This is the joint scaling sigma_N=tau/sqrt(N) at fixed tau, not a bound uniform in a subsequent cold limit; the nonconvex global-margin support would invalidate the projection argument.

## Research records for the unresolved continuous-activation case

The [research notes](../works-in-progress/online-mistakes/isotropic-research-notes/) preserve independently checked obstructions to several proof strategies. In particular, a reduction to successive minimum-norm affine separators cannot give the desired canonical shallow counterexample with a polynomial bounded teacher. These are statements about specific proof mechanisms, not a general online upper bound for NNbayes.

## Publication checks

Each package records source and PDF hashes, an isolated three-pass rebuild with matching extracted PDF text, resolved references, representative-page visual inspection, and the alphabetical author order with its explanatory footnote. The catalog and collection links were updated without changing the existing main-result classifications. The collection inventory/link/checksum verifier passes for all 82 manuscripts. No pre-existing paper source or Lean source was changed by this update.

The unrelated growing-depth norm-ball formalization published concurrently on main was retained when updating this checkout. The collection checksum manifest includes those files as well.
