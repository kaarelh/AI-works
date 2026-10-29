import NeuralGeneralization.Activation
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith

/-! Normalized tanh features have bounds independent of their scalar scale.
The statements cover arbitrarily large or small scales, including the zero
branch used for a zero row vector in the canonical construction. -/

noncomputable section
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def normalizedTanh (a s : ℝ) : ℝ := if a=0 then 0 else Real.tanh (a*s)/a

@[simp] theorem normalizedTanh_zero (a : ℝ) : normalizedTanh a 0 = 0 := by
  simp [normalizedTanh]

theorem normalizedTanh_lipschitz (a s t : ℝ) :
    |normalizedTanh a s-normalizedTanh a t| ≤ |s-t| := by
  by_cases ha : a=0
  · simp [normalizedTanh, ha]
  · simp only [normalizedTanh, if_neg ha]
    rw [← sub_div, abs_div]
    apply (div_le_iff₀ (abs_pos.mpr ha)).mpr
    have h := tanh_lipschitzWith.dist_le_mul (a*s) (a*t)
    simp only [NNReal.coe_one, one_mul, Real.dist_eq] at h
    calc
      |Real.tanh (a*s)-Real.tanh (a*t)| ≤ |a*s-a*t| := h
      _ = |s-t| *|a| := by rw [← mul_sub, abs_mul, mul_comm]

theorem normalizedTanh_bound (a s : ℝ) : |normalizedTanh a s| ≤ |s| := by
  simpa using normalizedTanh_lipschitz a s 0

/-- The normalized square feature has a scale-independent Lipschitz bound
on a bounded scalar interval. -/
theorem normalizedTanh_square_lipschitz (a s t U : ℝ)
    (hs : |s| ≤ U) (ht : |t| ≤ U) :
    |(normalizedTanh a s)^2-(normalizedTanh a t)^2| ≤ 2*U*|s-t| := by
  have hs' := (normalizedTanh_bound a s).trans hs
  have ht' := (normalizedTanh_bound a t).trans ht
  have hsum := (abs_add_le (normalizedTanh a s) (normalizedTanh a t)).trans (add_le_add hs' ht')
  have hid : (normalizedTanh a s)^2-(normalizedTanh a t)^2 =
      (normalizedTanh a s-normalizedTanh a t)*(normalizedTanh a s+normalizedTanh a t) := by ring
  rw [hid, abs_mul]
  calc
    |normalizedTanh a s-normalizedTanh a t| * |normalizedTanh a s+normalizedTanh a t|
      ≤ |s-t| *(U+U) := mul_le_mul (normalizedTanh_lipschitz a s t) hsum
        (abs_nonneg _) (abs_nonneg _)
    _ = 2*U*|s-t| := by ring

#print axioms normalizedTanh_lipschitz
#print axioms normalizedTanh_square_lipschitz
end ConditionalNonpolynomial.Analytic
