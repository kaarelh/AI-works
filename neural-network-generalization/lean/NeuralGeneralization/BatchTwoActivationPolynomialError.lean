import NeuralGeneralization.BatchTwoActivationPolynomialJets

/-! Explicit polynomial precision parameters for one reconstruction step. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoActivation

theorem reciprocal_power_mono {x a : ℝ} (hx : 1≤x) (ha : 0≤a) {m n : ℕ} (hmn : m≤n) :
    a/x^n≤a/x^m := by
  exact div_le_div_of_nonneg_left ha (pow_pos (by linarith : 0<x) m)
    (pow_le_pow_right₀ hx hmn)

theorem polynomial_one_step_error {x ℓ B M A q : ℝ} (hx : 128≤x)
    (hℓ0 : 0≤ℓ) (hB0 : 0≤B) (hM0 : 0≤M) (hA0 : 0≤A)
    (hℓ : ℓ≤x) (hB : B≤x) (hM : M≤x) (hA : A≤x) (hq : q≤x) :
    6*ℓ^2*B*M*A/x^8+2*(16*ℓ^2*x^8*(1/x^12))+q/x^4+
      (1/x^160)*boundedCovarianceModulus (x^16) (x^16) (x^16) (x^4)+1/x^2+
      1/x^2+A*(5*ℓ*(1/x^10)/4)*(2*ℓ*Real.sqrt M+5*ℓ*(1/x^10)/4)≤1/x := by
  have hx0 : 0<x := by linarith
  have hx1 : 1≤x := by linarith
  have hp2 : ℓ^2≤x^2 := pow_le_pow_left₀ hℓ0 hℓ 2
  have htail : 6*ℓ^2*B*M*A/x^8≤6/x^2 := by
    calc
      _ ≤ 6*x^2*x*x*x/x^8 := by gcongr
      _ = 6/x^3 := by field_simp <;> ring
      _ ≤ _ := reciprocal_power_mono hx1 (by norm_num) (by omega)
  have hsmooth : 2*(16*ℓ^2*x^8*(1/x^12))≤32/x^2 := by
    calc
      _ ≤ 2*(16*x^2*x^8*(1/x^12)) := by gcongr
      _ = _ := by field_simp <;> ring
  have hdual : q/x^4≤1/x^2 := by
    calc
      _ ≤ x/x^4 := (div_le_div_iff_of_pos_right (pow_pos hx0 _)).2 hq
      _ = 1/x^3 := by field_simp <;> ring
      _ ≤ _ := reciprocal_power_mono hx1 (by norm_num) (by omega)
  have hmod : boundedCovarianceModulus (x^16) (x^16) (x^16) (x^4)≤32*x^128 := by
    have hh := boundedCovarianceModulus_coarse (one_le_pow₀ hx1 : 1≤x^16)
      (by positivity : 0≤x^16) (by positivity : 0≤x^16) (by positivity : 0≤x^16)
      (by positivity : 0≤x^4) le_rfl le_rfl le_rfl
      (pow_le_pow_right₀ hx1 (show 4≤16 by omega))
    simpa only [←pow_mul] using hh
  have hprice : (1/x^160)*boundedCovarianceModulus (x^16) (x^16) (x^16) (x^4)≤32/x^2 := by
    calc
      _ ≤ (1/x^160)*(32*x^128) := mul_le_mul_of_nonneg_left hmod (by positivity)
      _ = 32/x^32 := by field_simp <;> ring
      _ ≤ _ := reciprocal_power_mono hx1 (by norm_num) (by omega)
  have hsqrt : Real.sqrt M≤x := by
    have hs := Real.sq_sqrt hM0
    nlinarith [Real.sqrt_nonneg M]
  let δ := 5*ℓ*(1/x^10)/4
  have hδ0 : 0≤δ := by dsimp [δ]; positivity
  have hδ : δ≤2/x^9 := by
    calc
      _ ≤ 5*x*(1/x^10)/4 := by dsimp [δ]; gcongr
      _ ≤ 2/x^9 := by
        have he : 5*x*(1/x^10)/4=(5/4:ℝ)/x^9 := by field_simp <;> ring
        rw [he]
        apply (div_le_div_iff_of_pos_right (pow_pos hx0 _)).2
        norm_num
  have hδ2 : δ≤2*x^2 := by
    have hh : 2/x^9≤2 := div_le_self (by norm_num) (one_le_pow₀ hx1)
    have hx2 : 1≤x^2 := one_le_pow₀ hx1
    linarith
  have hcore : 2*ℓ*Real.sqrt M+δ≤4*x^2 := by
    have hh := mul_le_mul hℓ hsqrt (Real.sqrt_nonneg _) hx0.le
    nlinarith
  have hatom : A*δ*(2*ℓ*Real.sqrt M+δ)≤8/x^2 := by
    calc
      _ ≤ x*(2/x^9)*(4*x^2) := by
        exact mul_le_mul (mul_le_mul hA hδ hδ0 hx0.le) hcore (by positivity) (by positivity)
      _ = 8/x^6 := by field_simp <;> ring
      _ ≤ _ := reciprocal_power_mono hx1 (by norm_num) (by omega)
  have hsum : 6/x^2+32/x^2+1/x^2+32/x^2+1/x^2+1/x^2+8/x^2≤1/x := by
    have he : 6/x^2+32/x^2+1/x^2+32/x^2+1/x^2+1/x^2+8/x^2=81/x^2 := by ring
    rw [he]
    apply (div_le_div_iff₀ (pow_pos hx0 2) hx0).2
    nlinarith
  change 6*ℓ^2*B*M*A/x^8+2*(16*ℓ^2*x^8*(1/x^12))+q/x^4+
    (1/x^160)*boundedCovarianceModulus (x^16) (x^16) (x^16) (x^4)+1/x^2+
    1/x^2+A*δ*(2*ℓ*Real.sqrt M+δ)≤1/x
  linarith

end NeuralGeneralization.BatchTwoActivation
