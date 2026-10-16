import NeuralGeneralization.GaussianModelRate

/-! # Exact scale conversion for the actual width-exponent Gaussian prior -/

noncomputable section

namespace NeuralGeneralization.ConcreteModel

/-- The common standard deviation in whitened coordinates. -/
def powerStandardDeviation (N : ℕ) (γ : ℝ) : ℝ := Real.sqrt ((N : ℝ) ^ (-γ))

lemma powerStandardDeviation_pos {N : ℕ} (hN : 0 < N) (γ : ℝ) :
    0 < powerStandardDeviation N γ := by
  exact Real.sqrt_pos.mpr (Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _)

lemma powerStandardDeviation_sq {N : ℕ} (hN : 0 < N) (γ : ℝ) :
    powerStandardDeviation N γ ^ 2 = (N : ℝ) ^ (-γ) := by
  exact Real.sq_sqrt (Real.rpow_pos_of_pos (Nat.cast_pos.mpr hN) _).le

lemma powerStandardDeviation_inv_sq {N : ℕ} (hN : 0 < N) (γ : ℝ) :
    1 / powerStandardDeviation N γ ^ 2 = (N : ℝ) ^ γ := by
  rw [powerStandardDeviation_sq hN, Real.rpow_neg (Nat.cast_nonneg N)]
  simp

/-- The mean-field scale condition holds throughout the complete `γ≥1` regime. -/
theorem width_mul_powerStandardDeviation_sq_le_one {N : ℕ}
    (hN : 0 < N) {γ : ℝ} (hγ : 1 ≤ γ) :
    (N : ℝ) * powerStandardDeviation N γ ^ 2 ≤ 1 := by
  have hNR : 0 < (N : ℝ) := Nat.cast_pos.mpr hN
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  rw [powerStandardDeviation_sq hN]
  have heq : (N : ℝ) * (N : ℝ) ^ (-γ) = (N : ℝ) ^ (1 - γ) := by
    rw [sub_eq_add_neg, Real.rpow_add hNR, Real.rpow_one]
  rw [heq]
  exact Real.rpow_le_one_of_one_le_of_nonpos hN1 (by linarith)

lemma width_le_power {N : ℕ} (hN : 0 < N) {γ : ℝ} (hγ : 1 ≤ γ) :
    (N : ℝ) ≤ (N : ℝ) ^ γ := by
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le hN1 hγ

lemma one_le_width_power {N : ℕ} (hN : 0 < N) {γ : ℝ} (hγ : 1 ≤ γ) :
    (1 : ℝ) ≤ (N : ℝ) ^ γ := by
  have hN1 : (1 : ℝ) ≤ N := by exact_mod_cast hN
  exact hN1.trans (width_le_power hN hγ)

/-- The actual equality of prior measures, packaged at the shared scale. -/
theorem powerPrior_eq_smallPrior_standardDeviation {d N r : ℕ}
    (hN : 0 < N) (γ : ℝ) :
    powerPrior d N r γ = smallPrior d N r (powerStandardDeviation N γ) :=
  powerPrior_eq_smallPrior hN γ

end NeuralGeneralization.ConcreteModel
