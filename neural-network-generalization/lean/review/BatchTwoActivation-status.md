**Current status:** Both main learning statements, including the literal strong-prior capacity formula and the uniform sample formula with valid polynomial envelopes, have closed Lean proofs. See [the final theorem map](BatchTwoActivation-manuscript-map.md). The development notes below retain earlier intermediate gaps; the final-completion section supersedes them.

# Unified unbounded activations: formalization status and theorem map

Updated 22 October 2026. The manuscript's **simultaneous all-width/all-scale
existential polynomial learning guarantee is proved** for the actual Gaussian
posterior. The manuscript is **not yet fully quantitatively formalized**:
the sharper displayed capacity and sample-budget formulas in its main strong
and uniform theorems have not been recovered. Do not describe the current
looser bounds as verification of those formulas.

## Complete learning endpoints

- `BatchTwoActivationUniformMain.uniform_unbounded_activation_learning`
  inhabits `UniformUnboundedActivationLearning`. For every fixed depth and
  activation Lipschitz bound, it produces a polynomial sample budget in
  dimension, specified teacher width and log inverse accuracy. One event of
  sample probability at least `1-δ` gives posterior average sign error at
  most `ε`, simultaneously for **every `N ≥ C` and `0 < t ≤ 1`**. The actual
  first/internal/readout variances are `t²/d`, `t²/N`, `t²/N²`. The learner
  uses one fixed zero-at-zero globally Lipschitz activation throughout. The
  teacher and global strict-margin conventions match the manuscript.
  Posterior denominators are proved positive for every training sample.
  No concentration, reconstruction, target-mass or capacity conclusion is
  assumed as an extra hypothesis. This proves the mathematical guarantee
  in `thm:summary`, with an explicitly constructed but looser polynomial.
- `BatchTwoActivationStrongPrior.strong_prior_learning` proves actual
  Gaussian strong-prior learning at each width above teacher complexity.
  Its variance threshold precedes the input distribution, confidence level
  and sample count. Its displayed polynomial is looser than `thm:strong`.
- `BatchTwoActivationGelu.exact_same_depth_gelu_compilation` proves exactly
  `prop:gelu-circuit`: same depth, width `2*C`, every weight bounded by `4`,
  exact real output `+1` or `-1`. `gelu_zeroLipschitz` proves exact CDF GELU
  is zero at zero and globally 2-Lipschitz; `relu_zeroLipschitz` handles ReLU.

## Actual analytic bridges behind the uniform endpoint

- `TargetMass.activation_target_polynomial_mass`: actual Gaussian target
  cylinder with polynomial cost independent of learner width whenever
  `N*σ² ≤ 1`.
- `PolynomialStep.polynomial_gaussian_one_step`: actual bounded bulk and
  residual-neuron covariance reconstruction, from incoming accuracy
  `k⁻¹⁶⁰` to outgoing accuracy `k⁻¹`, using `k⁴⁸+k²⁰` neurons.
- `PolynomialEvents.polynomialLayerBad_tail`: actual exceptional probability
  at most `2*exp(-N*K)` above a polynomial width threshold. The events are
  jointly measurable in the incoming feature matrix and Gaussian source.
- `Tower.finite_gaussian_tower_reconstruction`, `ActualTower`, `TowerReadout`
  and `EndpointClass`: finite-depth iteration as ordinary auxiliary
  networks and actual readout reconstruction, with polynomially bounded
  finite weights, physical hidden states and output scale.
- `FullNetworkEvents.ActivationGoodNetwork.compl_tail`: actual Gaussian
  product-law adaptive conditional union bound, at most
  `(2*(r+1)+1)*exp(-N*K)`. `EndpointTail` converts it into excluded function
  mass using the actual global-margin events.
- `SpectralNetwork.bandPrior_energyFunctions_spectral_tail`: uniform
  all-width spectral branch with an explicit inverse-polynomial cutoff;
  actual same-activation truncated representatives have energy at most
  `(r+5)*K`. `SpectralGaussian` proves the dimension-free matrix tail from
  actual operator-ball projection and Gaussian concentration.
- `SmallWidth.bandPrior_smallWidth_relative_tail`: actual total-energy
  chi-square tail closes the remaining bounded learner widths.
- `UniformBudgetsTarget`, `UniformBudgets`, `UniformBudgetBounds`,
  `UniformClass`: explicit natural polynomial envelopes and a **single**
  finite class independent of learner width and prior scale.
- `UniformTail.activation_uniform_relative_tail`: excluded raw function
  mass divided by target mass is at most `ε/2`, uniformly over every
  eligible width and scale.
- `UniformLearning.uniform_prior_family_learning`: one finite-class sample
  event simultaneously controls an arbitrary indexed family of priors.

All analytic tools used by these endpoints are proved in the dependency
closure: Gaussian transport/concentration, measurable projections, smooth
cutoffs and smoothing, Gaussian interpolation, covariance duality and finite
ordinary-network realization. Auxiliary heterogeneous activations are used
only for counting; the actual learner always retains its fixed activation.

## Exact remaining quantitative mismatch

Write `L=r+2` and `H=L-1`. The manuscript defines

`v(K) = ceil([16 H λ^H sqrt((d+1)/d) (K/L)^(L/2)]^3)`

and `B(K)=v(K) log(2^d+1)`.

- `thm:strong` uses `(2/ε)[B(B_*+1)+log(1/δ)]`, where
  `B_*=d(d+1)C²+L C⁴`, and a common event across widths with width-specific
  small-variance thresholds. The current fixed-width theorem instead uses
  `strongEnergyBudget = 2[d(d+1)C²+(r+1)C⁴]+1` and
  `activationLogCapacity`. The latter is derived from output normalization
  `K(λK)^(r+1)` and a coarse polynomial covering bound. It is larger than the
  printed bound; a downward comparison is not available.
- `thm:uniform-all-scales` uses `(2/ε)[B(J_*)+log(1/δ)]` with its particular
  target-cylinder, spectral-cutoff and combined class-energy formulas.
  The current theorem supplies a different, larger polynomial via
  `activationUniformCapacity`. Its simultaneous quantifiers and all prior
  and teacher assumptions match; its explicit sample threshold does not.
- `prop:product-rad` and `cor:count` contain the optimized Rademacher and
  capacity formulas needed to close these quantitative gaps. Current
  activation covering uses all grid codes and a quadratic entropy estimate,
  whereas the paper uses adjacent increments for linear entropy. Current
  input MGF uses a coordinate union bound rather than the sharper bounded
  difference estimate. Current normalization bounds each layer separately
  rather than using the sharp product and arithmetic–geometric mean.

Recovering these displayed formulas therefore needs sharper estimates, not
just renaming the current theorem. They remain on the formalization task.

## Proof choices and checking

The finite-scale proof uses signed log-sum-exp and support cap `4*T`, two
uniform interval averages for smoothing arbitrary Lipschitz activations,
Gaussian projection constants `8,3`, and deliberately loose fixed-depth
polynomial budgets. These prove the existential guarantee; they do not
verify every sharper intermediate formula in the paper.

Targeted `lake build NeuralGeneralization.BatchTwoActivationUniformMain`
and the strong/GELU endpoint builds pass with Lean 4.32.0 and the pinned
project dependencies. Kernel axiom inspection of all three endpoints reports
only `propext`, `Classical.choice`, and `Quot.sound`. There are no `sorry`,
`admit`, or user-declared axioms in these proofs. The audit output is recorded
in `/tmp/activation-final-axioms.log` during this session.

## Final sharp main endpoints

The earlier quantitative gaps recorded above have been closed. `BatchTwoActivationStrongManuscript.strong_prior_manuscript_learning` uses the literal `B(B_*+1)` formula. `BatchTwoActivationManuscriptMain.uniform_manuscript_learning` uses the displayed `B(J_*)` formula with enlarged existential endpoint polynomials; it also supplies actual polynomial width and reconstructed-energy envelopes. Sharp increment covers, the dimension-free input MGF, product normalization/AMGM, and the physical reconstructed-energy witness are proved. Both endpoints build and report only the three standard axioms. The older paragraphs describe intermediate progress, not remaining main-theorem gaps. See [coverage](BatchTwo-coverage.md).
