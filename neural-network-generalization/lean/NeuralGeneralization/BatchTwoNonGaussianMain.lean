import NeuralGeneralization.BatchTwoNonGaussianStrongMain
import NeuralGeneralization.BatchTwoNonGaussianMeanFieldMain
import NeuralGeneralization.BatchTwoNonGaussianAboveMain

/-! Both main theorems of the non-Gaussian paper, for the actual independent
coordinate network prior. The endpoint γ=1 uses relative Lindeberg covariance
compression; γ>1 uses spectral approximation. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoNonGaussian

/-- Paper Theorem 2.2, with exactly the predeclared full statement. -/
theorem finiteScale : FiniteScaleGeneralization := by
  intro r ν γ hγ
  rcases eq_or_lt_of_le hγ with h | h
  · subst γ
    exact NonGaussianMeanField.meanField r ν
  · exact NonGaussianAbove.aboveMeanField r ν γ h

/-- Both paper main statements, without analytic side assumptions. -/
theorem mainResults : StrongPriorGeneralization ∧ FiniteScaleGeneralization :=
  ⟨strongPrior,finiteScale⟩

end NeuralGeneralization.BatchTwoNonGaussian
