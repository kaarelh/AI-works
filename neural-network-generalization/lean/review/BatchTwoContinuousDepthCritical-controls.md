# Actual finite-width Gaussian controls for the critical continuous-depth case

All files are in `neural-network-generalization/lean/NeuralGeneralization`;
namespace `NeuralGeneralization.BatchTwoContinuousDepthCritical`.

This component proves the actual local transition probabilities required by the
critical (`gamma=1`) continuous-depth lower bound. It does not itself prove the
whole network denominator: the actual network-product induction, free-depth
tracking and final logarithmic cost assembly are separate components.

## Verified endpoints

* `BatchTwoContinuousDepthCriticalControlSeedMain.diluted_seed_probability`:
  finite separated unit-ball sample in `RealInput 2`; actual first-layer standard
  Gaussian rows of dimension three. For every sufficiently large width, an event
  with every signed empirical feature mean larger than
  `7/(32*n*ceil(1+10*seedSlope(n,delta)^2))` has mass at least
  `exp(-2*N-4)/2`. The proof constructs literal deterministic shifted rows,
  with total standardized squared shift at most `N`. No population large-
  deviation or mean-field convergence theorem is a hypothesis.
* `BatchTwoContinuousDepthCriticalControlFree.freeRowEvent_probability`:
  for any finite source dimension and unit projected direction, actual iid
  Gaussian rows jointly approximate the second feature moment, projected
  feature mean, and projected-channel squared norm to within `epsilon`.
  Probability is at least `3/4` if
  `4*(64+2*number_of_inputs) <= width*epsilon^2`.
* `BatchTwoContinuousDepthCriticalControlNormalize.freeRowEvent_normalized`:
  the explicitly normalized projected Gaussian channel has exact empirical
  RMS norm one; projected correlations incur error less than `4*epsilon`.
* `BatchTwoContinuousDepthCriticalControlMean.amplification_matrix_probability`:
  under the original iid standard Gaussian matrix law, an empirical feature
  mean can approximate the actually shifted Gaussian row mean at probability
  at least `exp(-2*width*amplitude^2-4)/2`. This is a genuine parameter event,
  with arbitrary conditional unit-norm source direction.
* `BatchTwoContinuousDepthCriticalControlReadout.critical_readout_control_probability`:
  under the original critical readout Gaussian law in standardized coordinates,
  the readout can approximate amplitude times the empirical projected feature,
  at probability at least `exp(-2*width*amplitude^2-4)/2`.

## Supporting proofs

`ControlShift`: actual Gaussian density comparison for arbitrary measurable
high-probability sets; does not require symmetry or convexity.

`ControlMatrix`: transports the shift inequality through the actual Gaussian
curry measurable equivalence, and calculates rank-one matrix-shift cost.

`ControlLLN`, `ControlIndependent`: finite-sample Chebyshev bounds for iid and
independent nonidentical rows, from actual product-law expectations/variances.

`ControlRows`: actual Gaussian moment calculations, exact Stein projected
feature identity, and dimension-independent second/fourth moment bounds.

`ControlDilution`: deterministic integer allocation of finitely many shifted
row types into arbitrary sufficiently large widths. `ControlSeed` combines
those shifts with a nonidentical-row law of large numbers.

## Audit

All endpoint modules compile under Lean 4.32.0. `#print axioms` for the five
endpoints above reports only `propext`, `Classical.choice`, and `Quot.sound`.
The audit output is `/tmp/critical-control-audit.log`.

## Actual physical-network bridge

`BatchTwoContinuousDepthCriticalProductStateBounds` proves bounded real-input
hidden features, membership of the actual empirical moments in the compact
moment box, and exact identities for standardized feature/channel coefficients.

`BatchTwoContinuousDepthCriticalProductStateBoundsFree.free_empirical_step`
identifies the actual physical network after appending a matrix with the finite
Gaussian row construction. It proves exact auxiliary RMS one and empirical
moment error less than `4*epsilon` in the finite-product metric. Controlled layers
and the initial layer have exact unit auxiliary RMS as well.

`BatchTwoContinuousDepthCriticalControlSeedBudget.dilutedSeedGain_log_budget`
proves the exact seed logarithm bound
`log(1/g) <= 14+3*log(n)+2*log(1/delta)` for `n>=1` and `0<delta<=1`.
