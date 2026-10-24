import NeuralGeneralization.BatchTwoContinuousFiniteQueryRealization
import NeuralGeneralization.BatchTwoNonGaussianMeanFieldBudget

/-! Polynomial width and row bounds for real-query covariance realization. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.FiniteQuery
open ConcreteModel BatchTwoNonGaussian

theorem sampling_budgets (ν : CoordinateLaw) (d q E T : ℕ) (hE : 0<E)
    {G : ℝ} (hG : 0≤G) (hT : G≤(T : ℝ)) :
    let N := TowerSamplingBudget.width (d+q) E
    let B := (actualRowBound ν (d+q) E T : ℝ)
    (2*(Fintype.card (Cube q) : ℝ)^2*Real.exp (-(N : ℝ)*(1/(E : ℝ))^2/2)+
      2*ν.comparisonFactor ν.lowerCurvature*(N : ℝ)*(d+1 : ℝ)*
        Real.exp (2*G-ν.lowerCurvature*B^2/2)<1) ∧
    (2*(Fintype.card (Cube q) : ℝ)^2*Real.exp (-(N : ℝ)*(1/(E : ℝ))^2/2)+
      2*(N : ℝ)*(N : ℝ)*Real.exp (2*G-B^2/2)<1) := by
  have hh := actual_sampling_budgets ν (d+q) E T hE hG hT
  dsimp only at hh ⊢
  have hc : (Fintype.card (Cube q) : ℝ)≤Fintype.card (Cube (d+q)) := by
    simp only [Cube,Fintype.card_fun,Fintype.card_bool,Fintype.card_fin]
    exact_mod_cast Nat.pow_le_pow_right (by omega : 0<2) (by omega : q≤d+q)
  have hcov := mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (Nat.cast_nonneg _) hc 2) (by norm_num : (0 : ℝ)≤2))
    (Real.exp_nonneg (-((TowerSamplingBudget.width (d+q) E : ℕ) : ℝ)*(1/(E : ℝ))^2/2))
  have hdim : (d+1 : ℝ)≤(d+q : ℕ)+1 := by push_cast; linarith [Nat.cast_nonneg q (α := ℝ)]
  have hcoef := mul_le_mul_of_nonneg_right
    (mul_le_mul_of_nonneg_left hdim (by
      have := (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le
      positivity : 0≤2*ν.comparisonFactor ν.lowerCurvature*(TowerSamplingBudget.width (d+q) E : ℝ)))
    (Real.exp_nonneg (2*G-ν.lowerCurvature*(actualRowBound ν (d+q) E T : ℝ)^2/2))
  exact ⟨(add_le_add hcov hcoef).trans_lt hh.1,(add_le_add hcov le_rfl).trans_lt hh.2⟩

def regressionResource (K R : ℕ) : ℕ := 12*K*R^2

def compressedWidth (d q r K R : ℕ) : ℕ :=
  TowerCompression.compressedWidth (d+q) r (regressionResource K R)
    (MeanFieldBudgets.maxTiltBudget r (2*regressionResource K R))

def compressedBound (ν : CoordinateLaw) (d q r K R : ℕ) : ℕ :=
  mixedCompressedBound ν (d+q) r (regressionResource K R)
    (MeanFieldBudgets.maxTiltBudget r (2*regressionResource K R))

end NeuralGeneralization.BatchTwoContinuous.FiniteQuery
