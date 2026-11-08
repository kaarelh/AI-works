import NeuralGeneralization.OnlineLowerReluMain

/-!
Exact statement gates for the concrete ordinary-ReLU online lower bound.
The first gate rejects extra assumptions or a merely abstract posterior theorem.
-/
open NeuralGeneralization.OnlineLower
example : ReLUConcreteMainStatement := relu_concrete_main
example : ReLUSquareRootStatement := relu_square_root_main
example : WidthExponentLowerBound relu (1 / 2) := relu_width_square_root_lower_bound

#print axioms relu_concrete_main
#print axioms relu_square_root_main
#print axioms relu_width_square_root_lower_bound
#print axioms ReluConcreteProtocol.finite_scale
#print axioms designatedAtLeastProbability_ge_allWrong
#print axioms posteriorAt_eq_globalConditioned
