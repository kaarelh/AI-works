import NeuralGeneralization.RobustCompressionParameters

/-! # Explicit scalar allocations used by the actual compressor

These elementary inequalities connect the finite resource formulas to the
analytic error and failure budgets. They do not assume a compression law.
-/

noncomputable section

namespace NeuralGeneralization.ConcreteModel.RobustCompressionInput

theorem small_width_energy_allocation (p : RobustCompressionInput)
    (hA : 0 < p.inverseFailure) {α : ℝ}
    (hα : (p.inverseFailure : ℝ)⁻¹ ≤ α) :
    4 * (p.widthBound : ℝ) * p.energy + 2 * p.smallParameterCount ≤
      α * (p.weightBound : ℝ)^2 := by
  let J : ℝ := 4 * (p.widthBound : ℝ) * p.energy + 2 * p.smallParameterCount
  have hAR : (0 : ℝ) < p.inverseFailure := by exact_mod_cast hA
  have hJ : 0 ≤ J := by dsimp [J]; positivity
  have hB : 4 * J * p.inverseFailure ≤ (p.weightBound : ℝ) := by
    have h : p.smallSquaredBound ≤ p.weightBound := by unfold weightBound; omega
    dsimp [J]
    exact_mod_cast h
  have hBone : (1 : ℝ) ≤ p.weightBound := by
    exact_mod_cast p.weightBound_pos
  have hBsquare : (p.weightBound : ℝ) ≤ (p.weightBound : ℝ)^2 := by nlinarith
  have hJmul : J * p.inverseFailure ≤ (p.weightBound : ℝ)^2 := by
    nlinarith [mul_nonneg hJ hAR.le]
  calc
    J ≤ (p.weightBound : ℝ)^2 / p.inverseFailure := (le_div_iff₀ hAR).mpr hJmul
    _ = (p.inverseFailure : ℝ)⁻¹ * (p.weightBound : ℝ)^2 := by ring
    _ ≤ α * (p.weightBound : ℝ)^2 :=
      mul_le_mul_of_nonneg_right hα (sq_nonneg _)

end NeuralGeneralization.ConcreteModel.RobustCompressionInput

namespace NeuralGeneralization.RobustCompressionAllocations

/-- The exact source and kernel choices give a small active-feature error. -/
theorem feature_error_allocation {e q b : ℝ} (he : 0 < e)
    (hq : 0 ≤ q) (hb : 0 ≤ b) :
    q / (128 * (q+1) * (b+1) / e) + 2 * (e / (128 * (b+1))) ≤
      3 * e / (128 * (b+1)) := by
  have hqp : 0 < q+1 := by linarith
  have hbp : 0 < b+1 := by linarith
  have hden : 0 < 128 * (q+1) * (b+1) := by positivity
  rw [div_div_eq_mul_div]
  have hqterm : q * e / (128 * (q+1) * (b+1)) ≤ e / (128 * (b+1)) := by
    apply (div_le_div_iff₀ hden (by positivity : 0 < 128 * (b+1))).mpr
    nlinarith
  calc
    _ ≤ e / (128 * (b+1)) + 2 * (e / (128 * (b+1))) :=
      add_le_add hqterm le_rfl
    _ = _ := by ring

/-- The scalar Gaussian reconstruction error is at most one eighth of the
layer allocation. The active mean error and residual variance error are both
included. -/
theorem scalar_reconstruction_allocation {e b ζ a : ℝ}
    (he : 0 < e) (he1 : e ≤ 1) (hb : 0 ≤ b) (hζ : 0 ≤ ζ)
    (hζbound : ζ ≤ 3 * e / (128 * (b+1)))
    (ha : a ≤ e / (128 * (b+1))) :
    b * ζ^2 + a + 2*ζ ≤ e/8 := by
  have hbp : 0 < b+1 := by linarith
  have hzscaled : 128*(b+1)*ζ ≤ 3*e := by
    have h := (le_div_iff₀ (show 0 < 128*(b+1) by positivity)).mp hζbound
    nlinarith
  have hascaled : 128*(b+1)*a ≤ e := by
    have h := (le_div_iff₀ (show 0 < 128*(b+1) by positivity)).mp ha
    nlinarith
  have hz : ζ ≤ 3*e/128 := by nlinarith [mul_nonneg hb hζ]
  have hba : a ≤ e/128 := by
    by_cases hapos : 0 ≤ a
    · nlinarith [mul_nonneg hb hapos]
    · linarith
  have hbz : b*ζ ≤ 3*e/128 := by nlinarith
  have hsq : b*ζ^2 ≤ 9*e^2/16384 := by
    have h := mul_le_mul hbz hz hζ (by positivity : 0 ≤ 3*e/128)
    nlinarith
  nlinarith [mul_nonneg he.le (sub_nonneg.mpr he1)]

/-- A deliberately loose four-term squared-triangle allocation. -/
theorem hidden_layer_allocation {e A R G C : ℝ}
    (he : 0 ≤ e) (hA : A ≤ e) (hR : R ≤ 14*(e/100))
    (hG : G ≤ e/8) (hC : C ≤ e/4) :
    4*(A+R+G+C) ≤ 10*e := by linarith

/-- A finite-bank exponential tail is at most the chosen reciprocal failure
budget whenever the logarithm of its actual prefactor is covered. -/
theorem exponential_failure_le_inverse {J H E : ℝ}
    (hJ : 0 < J) (hH : 0 < H) (hE : Real.log (2*H*J) ≤ E) :
    J * (2 * Real.exp (-E)) ≤ H⁻¹ := by
  have h := Real.exp_le_exp.mpr hE
  rw [Real.exp_log (by positivity : 0 < 2*H*J)] at h
  have hm := mul_le_mul_of_nonneg_right h (Real.exp_pos (-E)).le
  have heq : Real.exp E * Real.exp (-E) = 1 := by
    rw [← Real.exp_add]
    simp
  rw [heq] at hm
  rw [inv_eq_one_div]
  apply (le_div_iff₀ hH).mpr
  nlinarith

theorem source_bank_log_prefactor_le (d q : ℕ) {H : ℝ} (hH : 1 ≤ H) :
    Real.log (2*H*((q : ℝ)^2 + q*2^d + (2^d : ℝ)^2)) ≤
      4*((d : ℝ)+q+H+1) := by
  have hHpos : 0 < H := by linarith
  have hq : (0 : ℝ) ≤ q := by positivity
  have hqp : (0 : ℝ) < q+1 := by positivity
  have hx : (1 : ℝ) ≤ 2^d := one_le_pow₀ (by norm_num)
  have hxpos : (0 : ℝ) < 2^d := by positivity
  have hJ : 0 < (q : ℝ)^2 + q*2^d + (2^d : ℝ)^2 := by positivity
  have hb : (q : ℝ)^2 + q*2^d + (2^d : ℝ)^2 ≤
      (q+1)^2 * (2^d : ℝ)^2 := by
    have hx2 : (1 : ℝ) ≤ (2^d : ℝ)^2 := by nlinarith
    have h₁ := mul_le_mul_of_nonneg_left hx2 (sq_nonneg (q : ℝ))
    have h₂ := mul_le_mul_of_nonneg_left (show (2^d : ℝ) ≤ 2*(2^d : ℝ)^2 by nlinarith) hq
    nlinarith
  have hlog := Real.log_le_log (by positivity : 0 < 2*H*((q : ℝ)^2+q*2^d+(2^d : ℝ)^2))
    (mul_le_mul_of_nonneg_left hb (by positivity : 0 ≤ 2*H))
  have hl2 : Real.log 2 ≤ 1 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
    linarith
  have hlH := Real.log_le_sub_one_of_pos hHpos
  have hlq := Real.log_le_sub_one_of_pos hqp
  have heq : Real.log (2*H*((q+1)^2 * (2^d : ℝ)^2)) =
      Real.log 2 + Real.log H + 2*Real.log ((q : ℝ)+1) +
        2*(d : ℝ)*Real.log 2 := by
    rw [Real.log_mul (by positivity) (by positivity),
      Real.log_mul (by norm_num) hHpos.ne', Real.log_mul (by positivity) (by positivity),
      Real.log_pow, Real.log_pow, Real.log_pow]
    push_cast
    ring
  rw [heq] at hlog
  have hld := mul_le_mul_of_nonneg_left hl2 (by positivity : 0 ≤ 2*(d : ℝ))
  nlinarith

theorem source_bank_failure_allocation (d q : ℕ) {H E : ℝ}
    (hH : 1 ≤ H) (hE : 4*((d : ℝ)+q+H+1) ≤ E) :
    ((q : ℝ)^2 + q*2^d + (2^d : ℝ)^2) * (2*Real.exp (-E)) ≤ H⁻¹ := by
  apply exponential_failure_le_inverse (by positivity) (by linarith)
  exact (source_bank_log_prefactor_le d q hH).trans hE

theorem readout_failure_allocation (d : ℕ) {H E : ℝ}
    (hH : 1 ≤ H) (hE : (d : ℝ)+H+1 ≤ E) :
    (2^d : ℝ) * (2*Real.exp (-E)) ≤ H⁻¹ := by
  apply exponential_failure_le_inverse (by positivity) (by linarith)
  have hHpos : 0 < H := by linarith
  have hl2 : Real.log 2 ≤ 1 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0 : ℝ) < 2)
    linarith
  have hlH := Real.log_le_sub_one_of_pos hHpos
  rw [Real.log_mul (by positivity) (by positivity),
    Real.log_mul (by norm_num) hHpos.ne', Real.log_pow]
  have hld := mul_le_mul_of_nonneg_left hl2 (by positivity : 0 ≤ (d : ℝ))
  nlinarith

end NeuralGeneralization.RobustCompressionAllocations
