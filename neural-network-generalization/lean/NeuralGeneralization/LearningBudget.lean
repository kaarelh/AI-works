import NeuralGeneralization.FiniteLearning
import Mathlib.Analysis.SpecialFunctions.Log.Basic

/-!
# Explicit logarithmic sample budgets

These algebraic bounds translate finite-class and target-mass exponential
estimates into the sample-size expressions used by the neural model.
-/

noncomputable section
namespace NeuralGeneralization

/-- The logarithmic sample-size condition implies the exponential failure bound. -/
theorem exponential_sample_bound (M H a δ : ℝ) (n : ℕ)
    (hM : M ≤ Real.exp H) (hδ : 0 < δ)
    (hsize : H + Real.log (1 / δ) ≤ (n : ℝ) * a) :
    M * Real.exp (-(n : ℝ) * a) ≤ δ := by
  have hlog : H - (n : ℝ) * a ≤ Real.log δ := by
    rw [one_div, Real.log_inv] at hsize
    linarith
  calc
    M * Real.exp (-(n : ℝ) * a) ≤
        Real.exp H * Real.exp (-(n : ℝ) * a) :=
      mul_le_mul_of_nonneg_right hM (Real.exp_pos _).le
    _ = Real.exp (H - (n : ℝ) * a) := by
      rw [← Real.exp_add]
      congr 1
      ring
    _ ≤ Real.exp (Real.log δ) := Real.exp_le_exp.mpr hlog
    _ = δ := Real.exp_log hδ


/-- Converting a quantitative target-mass lower bound and a logarithmic sample
budget into the target-mass failure estimate. -/
lemma target_mass_exponential_bound (mass B a b δ : ℝ) (n : ℕ)
    (hmass : Real.exp (-B) ≤ mass) (hb : 0 < b) (hδ : 0 < δ)
    (hsize : B + Real.log (1 / (δ * b)) ≤ (n : ℝ) * a) :
    Real.exp (-(n : ℝ) * a) / (mass * b) ≤ δ := by
  have hm : 0 < mass := lt_of_lt_of_le (Real.exp_pos _) hmass
  have he := exponential_sample_bound (Real.exp B) B a (δ * b) n
    (le_refl _) (mul_pos hδ hb) hsize
  apply (div_le_iff₀ (mul_pos hm hb)).mpr
  calc
    Real.exp (-(n : ℝ) * a) = Real.exp (-B) *
        (Real.exp B * Real.exp (-(n : ℝ) * a)) := by
      rw [← mul_assoc, ← Real.exp_add]
      simp
    _ ≤ Real.exp (-B) * (δ * b) :=
      mul_le_mul_of_nonneg_left he (Real.exp_pos _).le
    _ ≤ mass * (δ * b) :=
      mul_le_mul_of_nonneg_right hmass (mul_pos hδ hb).le
    _ = δ * (mass * b) := by ring


end NeuralGeneralization
