import NeuralGeneralization.RobustCompressionLargeWidthProof
import NeuralGeneralization.RobustCompressionExplicitDegree

/-!
# Polynomial-depth generalization for the robustness-restricted Gaussian prior

This closes the exact learning proposition for the actual finite network model.
The raw compression construction, target mass, posterior conditioning, finite
code, and statistical bounds are all instantiated. No analytic or compression
premise is retained in the theorem's type.

The explicit-degree module additionally checks a conservative degree 10974 for
the sample-budget formulas used by this proof. It is not an optimized exponent.
-/

namespace NeuralGeneralization.RobustMainProofs

/-- A universal polynomial sample bound, jointly in depth and target resources,
on one sample event for every eligible width and Gaussian scale. -/
theorem robustPolynomialDepth :
    RobustMainStatements.RobustPolynomialDepthGeneralization :=
  robustPolynomialDepth_of_largeWidthRawCompression largeWidthRawCompression

end NeuralGeneralization.RobustMainProofs
