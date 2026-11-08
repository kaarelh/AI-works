import NeuralGeneralization.OnlineLowerTanhAnalyticAssembly
import NeuralGeneralization.OnlineLowerTanhSharpParity

/-! # The complete actual-model ordinary-tanh online lower bound

The actual optimized odd-parity inequality, scalar costs, shared-carrier code,
calibration, full-cube permutation, bounded teacher, integer neuron allocation,
and Gaussian posterior are instantiated here. The permutation is fixed before
learner width, and the Gaussian scale tends to zero at each fixed width.
-/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerTanh

/-- The exact tanh construction: exponentially many designated mistakes
under the actual Gaussian sign-conditioned posterior at every sufficiently
large fixed learner width. There are no analytic or construction premises. -/
theorem tanh_concrete_main : TanhConcreteMainStatement :=
  tanh_concrete_of_intrinsic (eventually_atTop.mp eventual_intrinsicParityBound)

/-- The literal logarithmic rails give dimension O(k log² k), bounded
neural teacher width O(k² log² k), and 2^(k-1) designated errors. -/
theorem tanh_path_logarithmic_rail_main : TanhPathLogarithmicRailStatement :=
  tanh_concrete_main.polylogResources

/-- Expressed in the implementing teacher width C, the mistake lower bound
is exponential in sqrt(C)/log(C+2), at all sufficiently large learner widths. -/
theorem tanh_square_root_log_loss_lower_bound : TanhSquareRootLogLossStatement :=
  tanh_concrete_main.widthRate

end NeuralGeneralization.OnlineLower
