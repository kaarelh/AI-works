# Isotropic online learning: publication and scope record

Date: 6 November 2026.

This update adds three independently reviewed manuscripts. These are conventional mathematical proofs, not Lean formalizations. The first two prove online lower bounds under different, explicitly stated assumptions; neither proves the unchanged isotropic tanh result.

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

## Publication checks

Each package records source and PDF hashes, an isolated three-pass rebuild with matching extracted PDF text, resolved references, representative-page visual inspection, and the alphabetical author order with its explanatory footnote. The catalog and collection links were updated without changing the existing main-result classifications. The collection inventory/link/checksum verifier passes for all 79 manuscripts. No pre-existing paper source or Lean source was changed by this update.

The unrelated growing-depth norm-ball formalization published concurrently on main was retained when updating this checkout. The collection checksum manifest includes those files as well.
