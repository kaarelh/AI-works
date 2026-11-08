import Mathlib.Analysis.Real.Sqrt
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# A moment proof of positivity for the ReLU cost's Laplace kernel

For `Q_j(t) = ∫₀¹ u^j exp(-ut) du`, the scalar function used in the
Bernstein representation is `k = 1 / sqrt Q₀`. Its derivatives have the
forms below. The elementary moment inequalities `Q₁² ≤ Q₀Q₂` and
`0 < Q₁ < Q₀` imply `k'' < k'/2`. This file checks that algebraic step;
the integral and derivative identifications are separate obligations.
-/

noncomputable section

namespace NeuralGeneralization.OnlineLowerBernstein

def firstKernelDerivative (q₀ q₁ : ℝ) : ℝ := q₁ / (2 * Real.sqrt q₀ ^ 3)
def secondKernelDerivative (q₀ q₁ q₂ : ℝ) : ℝ :=
  3 * q₁ ^ 2 / (4 * Real.sqrt q₀ ^ 5) - q₂ / (2 * Real.sqrt q₀ ^ 3)

theorem firstKernelDerivative_pos (q₀ q₁ : ℝ) (h₀ : 0 < q₀) (h₁ : 0 < q₁) :
    0 < firstKernelDerivative q₀ q₁ :=
  div_pos h₁ (mul_pos (by norm_num) (pow_pos (Real.sqrt_pos.mpr h₀) 3))

theorem secondKernelDerivative_lt_half_first (q₀ q₁ q₂ : ℝ)
    (h₀ : 0 < q₀) (h₁ : 0 < q₁) (h₁₀ : q₁ < q₀)
    (hcs : q₁ ^ 2 ≤ q₀ * q₂) :
    secondKernelDerivative q₀ q₁ q₂ < firstKernelDerivative q₀ q₁ / 2 := by
  have hs : 0 < Real.sqrt q₀ := Real.sqrt_pos.mpr h₀
  have hs2 : Real.sqrt q₀ ^ 2 = q₀ := Real.sq_sqrt h₀.le
  have hstrict : q₁ ^ 2 < q₀ * q₁ := by nlinarith [mul_pos h₁ (sub_pos.mpr h₁₀)]
  calc
    secondKernelDerivative q₀ q₁ q₂ =
        (3 * q₁ ^ 2 - 2 * q₀ * q₂) / (4 * Real.sqrt q₀ ^ 5) := by
      unfold secondKernelDerivative
      field_simp
      rw [hs2]
      ring
    _ < (q₀ * q₁) / (4 * Real.sqrt q₀ ^ 5) := by
      apply (div_lt_div_iff_of_pos_right (mul_pos (by norm_num) (pow_pos hs 5))).mpr
      linarith
    _ = firstKernelDerivative q₀ q₁ / 2 := by
      unfold firstKernelDerivative
      field_simp
      rw [hs2]
      ring

theorem firstKernelDerivative_le_half_kernel (q₀ q₁ : ℝ) (h₀ : 0 < q₀)
    (h₁ : q₁ ≤ q₀) :
    firstKernelDerivative q₀ q₁ ≤ (1 / Real.sqrt q₀) / 2 := by
  have hs := Real.sqrt_pos.mpr h₀
  have hs2 := Real.sq_sqrt h₀.le
  unfold firstKernelDerivative
  have he : (1 / Real.sqrt q₀) / 2 = q₀ / (2 * Real.sqrt q₀ ^ 3) := by
    field_simp
    rw [hs2]
  rw [he]
  exact div_le_div_of_nonneg_right h₁ (mul_pos (by norm_num) (pow_pos hs 3)).le

theorem abs_secondKernelDerivative_le (q₀ q₁ q₂ : ℝ) (h₀ : 0 < q₀)
    (h₁ : 0 ≤ q₁) (h₁₀ : q₁ ≤ q₀) (h₂ : 0 ≤ q₂) (h₂₀ : q₂ ≤ q₀) :
    |secondKernelDerivative q₀ q₁ q₂| ≤ (5 / 4) * (1 / Real.sqrt q₀) := by
  have hs := Real.sqrt_pos.mpr h₀
  have hs2 := Real.sq_sqrt h₀.le
  have hq1 : q₁ ^ 2 ≤ q₀ ^ 2 := sq_le_sq₀ h₁ h₀.le |>.mpr h₁₀
  have ha : 3 * q₁ ^ 2 / (4 * Real.sqrt q₀ ^ 5) ≤
      (3 / 4) * (1 / Real.sqrt q₀) := by
    have hden : (0 : ℝ) ≤ 4 * Real.sqrt q₀ ^ 5 :=
      (mul_pos (by norm_num) (pow_pos hs 5)).le
    have := div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_left hq1 (by norm_num : (0 : ℝ) ≤ 3))
      hden
    calc
      _ ≤ 3 * q₀ ^ 2 / (4 * Real.sqrt q₀ ^ 5) := this
      _ = _ := by field_simp; nlinarith [hs2]
  have hb : q₂ / (2 * Real.sqrt q₀ ^ 3) ≤ (1 / 2) * (1 / Real.sqrt q₀) := by
    have := firstKernelDerivative_le_half_kernel q₀ q₂ h₀ h₂₀
    simpa [firstKernelDerivative, div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc] using this
  unfold secondKernelDerivative
  calc
    _ ≤ |3 * q₁ ^ 2 / (4 * Real.sqrt q₀ ^ 5)| +
        |q₂ / (2 * Real.sqrt q₀ ^ 3)| := by
      rw [sub_eq_add_neg]
      calc
        _ ≤ |3 * q₁ ^ 2 / (4 * Real.sqrt q₀ ^ 5)| +
          |-(q₂ / (2 * Real.sqrt q₀ ^ 3))| := abs_add_le _ _
        _ = _ := by rw [abs_neg]
    _ = 3 * q₁ ^ 2 / (4 * Real.sqrt q₀ ^ 5) + q₂ / (2 * Real.sqrt q₀ ^ 3) := by
      rw [abs_of_nonneg (by positivity), abs_of_nonneg (by positivity)]
    _ ≤ _ := by linarith

end NeuralGeneralization.OnlineLowerBernstein
