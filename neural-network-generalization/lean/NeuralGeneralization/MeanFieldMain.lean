import NeuralGeneralization.MeanFieldAggregate
import NeuralGeneralization.MeanFieldLearning

/-!
# The all-width mean-field main theorem

Actual Gaussian layer laws and sparse covariance certificates, backward
budgets, dimension-independent Price stability, a finite bounded network
realization, exact class counting, all-width target mass, and the concrete
Bayesian sampling argument are assembled into the exact main statement.
-/

namespace NeuralGeneralization.MainProofs

/-- Mean-field paper, Theorem 1.1, with every width above the target complexity
and the strict posterior-confidence threshold greater than two thirds. -/
theorem meanField : MainStatements.MeanFieldGeneralization :=
  MeanFieldLearning.main_of_aggregate_tail MeanFieldAggregate.aggregate_tail

end NeuralGeneralization.MainProofs
