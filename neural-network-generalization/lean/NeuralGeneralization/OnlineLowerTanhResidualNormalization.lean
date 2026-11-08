import NeuralGeneralization.OnlineLowerTanhResidualParameters
import NeuralGeneralization.OnlineLowerTanhResidualSeries

/-! # Exact constants in the signed residual central limit formula -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma residual_gaussian_normalization {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) {A : ℝ} (hA : 0 < A) :
    residualScale A q*Real.sqrt (2*Real.pi)*(A/Real.pi) =
      Real.sqrt (2/(Real.pi*residualVariance q)) := by
  have hV := residualVariance_pos hn q hq
  have hr := Real.sqrt_pos.mpr hV
  have hp := Real.sqrt_pos.mpr Real.pi_pos
  unfold residualScale
  rw [Real.sqrt_div (by norm_num : (0:ℝ)≤2),Real.sqrt_mul Real.pi_pos.le,
    Real.sqrt_mul (by norm_num : (0:ℝ)≤2)]
  field_simp
  nlinarith [Real.sq_sqrt Real.pi_pos.le]

lemma residual_gaussian_exponent {n : ℕ} (hn : 0 < n) (q : Fin n → ℕ)
    (hq : ∀ i, 0 < q i) {A : ℝ} (hA : 0 < A) (B : ℝ) :
    -(B*residualScale A q)^2/2 = -B^2/(2*A^2*residualVariance q) := by
  have hV := residualVariance_pos hn q hq
  have hr := Real.sqrt_pos.mpr hV
  unfold residualScale
  rw [mul_pow,inv_pow,mul_pow,Real.sq_sqrt hV.le]
  ring

end NeuralGeneralization.OnlineLowerTanh
