import NeuralGeneralization.OnlineLowerGeometryCore
import NeuralGeneralization.OnlineLowerGeometryRounding
import NeuralGeneralization.OnlineLowerGeometryMinimum
import NeuralGeneralization.OnlineLowerGeometryDualParameters
import NeuralGeneralization.OnlineLowerGeometryCompact
import NeuralGeneralization.OnlineLowerGeometryWalsh
import NeuralGeneralization.OnlineLowerGeometryCoset
import NeuralGeneralization.OnlineLowerGeometryCode
import NeuralGeneralization.OnlineLowerGeometryCalibration
import NeuralGeneralization.OnlineLowerGeometryProjection
import NeuralGeneralization.OnlineLowerGeometryObservability
import NeuralGeneralization.OnlineLowerGeometryReluDual
import NeuralGeneralization.OnlineLowerGeometryReluStar
import NeuralGeneralization.OnlineLowerGeometryReluCalibration
import NeuralGeneralization.OnlineLowerGeometryOrder

/-!
# Shared finite geometry for the neural online lower bounds

The imported modules prove the finite weighted-dual inequalities, the
common-dual scalar parameters, the affine-coset Fourier identity, the
factor-two independent-set mass inequality, margin/variance conversion,
the `11 η + 4 V` live-candidate rounding theorem, calibrated minimum
classification, and the compact correct-score cost gap. They also derive
uniform physical fibers, conditional margins and variance, orthogonal
code projections, the explicit ReLU dual and star costs, the physical
calibrated cost identity, and complete finite fiber input orders.

This is a dependency module, not an unconditional neural lower-bound
theorem.  In particular, the physical rail-code first-defect decomposition,
the full tanh common-dual pointwise constraints, and the analytic neural
atomic estimates must still be connected to these results.  The network
model and actual Gaussian posterior are defined in separate modules.
-/
