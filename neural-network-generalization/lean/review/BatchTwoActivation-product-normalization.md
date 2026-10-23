# Sharp product normalization and teacher energy

Checked 22 October 2026. The following statements provide the literal
product-of-Frobenius-norm and arithmetic–geometric-mean bridge needed by
the unified activation manuscript's optimized capacity formula.

- `BatchTwoActivation.normalizeProductNetwork_output` is an exact identity
  for a `ProductNetwork` with arbitrary finite positive widths and a
  potentially different zero-at-zero, globally `ell`-Lipschitz activation
  at every neuron. It constructs an `AuxiliaryNetwork` with Frobenius norm
  at most one at each layer, readout norm at most one, and scale
  `ell^H * norm(readout) * product(layer Frobenius norms)`.
  Zero matrices and zero readouts are included. No homogeneity is used:
  the auxiliary activations absorb their actual input scales.
- `exists_sharp_auxiliary_normalization` in
  `BatchTwoActivationProductNormalizationMain` applies this construction
  to the original physical network with its fixed learner activation.
  For positive `d,N,ell,K` and actual weighted energy at most `K`, it gives
  exact equality of all outputs at scale
  `sharpProductScale d r ell K = ell^(r+1)/sqrt(d) * (K/(r+2))^((r+2)/2)`.
  Here the manuscript has `L=r+2`, `H=r+1`.
- `energyFunctions_subset_sharp_auxiliary` proves the resulting actual
  all-width weak-half-margin energy class inclusion. It can be combined
  directly with the sharp heterogeneous auxiliary-class count.
- `lowEnergyFunctions_subset_sharp_auxiliary` gives the class inclusion
  for every learner width at least teacher width at energy `B_*+1`, where
  `sharpTeacherBudget d C r = d*(d+1)*C^2 + (r+2)*C^4` is the exact printed
  `B_*`. Its cloning proof is shared with `BatchTwoOnlineSharpTeacher` and
  does not assume the activation is bounded or homogeneous.

The weighted energy is exactly the original one: first-layer squares
weighted by `d/N`, unweighted internal squares, and readout squares weighted
by `N`. The product identity cancels learner width and leaves precisely the
factor `1/sqrt(d)`. The product bound is an actual AM-GM proof from the sum
of these `L` nonnegative layer energies, not separate bounds on each layer.

`BatchTwoActivationProductNormalizationAudit` checks the generic identity,
physical-network normalization, actual energy-class inclusion, and sharp
teacher-class inclusion. All depend only on `propext`, `Classical.choice`,
and `Quot.sound`. These are supporting statements; the final sharp learning
and capacity endpoints are assembled in the separate `SharpCapacity` and
strong/common-event modules.
