import NeuralGeneralization.BatchTwoNonGaussianGaussianInstance
import NeuralGeneralization.BatchTwoNonGaussianScaleComparison
import NeuralGeneralization.BatchTwoNonGaussianSpectralLaw

/-! Exact specialization of the independent-coordinate laws to the original
Gaussian network priors. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoNonGaussian
open ConcreteModel

theorem standardGaussian_smallPrior {d N r : ℕ} (hd : 0<d) (hN : 0<N) (σ : ℝ) :
    smallPrior standardGaussian d N r σ = ConcreteModel.smallPrior d N r σ := by
  rw [smallPrior,productPrior_eq_map]
  simpa using map_gaussian_smallScale hd hN σ 1 (by norm_num)

end NeuralGeneralization.BatchTwoNonGaussian
