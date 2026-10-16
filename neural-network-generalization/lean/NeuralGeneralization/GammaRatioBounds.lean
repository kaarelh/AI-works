import NeuralGeneralization.GammaHalfBounds

/-! Uniform Gamma-ratio estimates from elementary log-convexity, with
explicit constants valid for all fractional exponents in `(0,1)`. -/
noncomputable section
namespace NeuralGeneralization

/-- Gautschi's upper shift bound follows directly from Gamma log-convexity. -/
theorem gamma_shift_upper {x s : ℝ} (hx : 0 < x) (hs0 : 0 < s) (hs1 : s < 1) :
    Real.Gamma (x+s) ≤ x^s*Real.Gamma x := by
  have hG := (Real.Gamma_pos_of_pos hx).le
  have h := Real.Gamma_mul_add_mul_le_rpow_Gamma_mul_rpow_Gamma hx
    (show 0 < x+1 by positivity) (show 0 < 1-s by linarith) hs0 (by ring)
  rw [show (1-s)*x+s*(x+1)=x+s by ring,
    Real.Gamma_add_one (ne_of_gt hx),Real.mul_rpow hx.le hG] at h
  have he : Real.Gamma x^(1-s)*(x^s*Real.Gamma x^s) = x^s*Real.Gamma x := by
    calc
      _ = x^s*(Real.Gamma x^(1-s)*Real.Gamma x^s) := by ring
      _ = _ := by rw [← Real.rpow_add (Real.Gamma_pos_of_pos hx),sub_add_cancel,Real.rpow_one]
  rwa [he] at h

/-- The companion lower shift bound, written without division. -/
theorem gamma_shift_lower {x s : ℝ} (hx : 0 < x) (hs0 : 0 < s) (hs1 : s < 1) :
    x*Real.Gamma x ≤ (x+s)^(1-s)*Real.Gamma (x+s) := by
  have h := gamma_shift_upper (show 0 < x+s by positivity)
    (show 0 < 1-s by linarith) (show 1-s < 1 by linarith)
  rw [show x+s+(1-s)=x+1 by ring,Real.Gamma_add_one (ne_of_gt hx)] at h
  exact h

/-- Sharp power order with explicit constants, without Stirling asymptotics. -/
theorem gamma_coefficient_power_bounds {m : ℕ} (hm : 1 ≤ m) {β : ℝ}
    (hβ0 : 0 < β) (hβ1 : β < 1) :
    1 ≤ (m : ℝ)^(1+β)*(Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ)) ∧
      (m : ℝ)^(1+β)*(Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ)) ≤ 1/(1-β) := by
  have hm1 : (1 : ℝ) ≤ m := by exact_mod_cast hm
  have hm0 : (0 : ℝ) < m := by linarith
  have hx : (0 : ℝ) < m-β := by linarith
  have hG : 0 < Real.Gamma (m : ℝ) := Real.Gamma_pos_of_pos hm0
  have hA : 0 < Real.Gamma ((m : ℝ)-β) := Real.Gamma_pos_of_pos hx
  have hU := gamma_shift_upper hx hβ0 hβ1
  rw [sub_add_cancel] at hU
  have hp : ((m : ℝ)-β)^β ≤ (m : ℝ)^β :=
    Real.rpow_le_rpow hx.le (by linarith) hβ0.le
  have hlow : Real.Gamma (m : ℝ) ≤ (m : ℝ)^β*Real.Gamma ((m : ℝ)-β) :=
    hU.trans (mul_le_mul_of_nonneg_right hp hA.le)
  have hL := gamma_shift_lower hx hβ0 hβ1
  rw [sub_add_cancel] at hL
  have hR : 0 ≤ (m : ℝ)^β := Real.rpow_nonneg hm0.le _
  have hscaled := mul_le_mul_of_nonneg_left hL hR
  have hpow : (m : ℝ)^β*(m : ℝ)^(1-β) = (m : ℝ) := by
    rw [← Real.rpow_add hm0,show β+(1-β)=1 by ring,Real.rpow_one]
  have hscaled' : ((m : ℝ)-β)*((m : ℝ)^β*Real.Gamma ((m : ℝ)-β)) ≤
      (m : ℝ)*Real.Gamma (m : ℝ) := by
    calc
      _ = (m : ℝ)^β*(((m : ℝ)-β)*Real.Gamma ((m : ℝ)-β)) := by ring
      _ ≤ (m : ℝ)^β*((m : ℝ)^(1-β)*Real.Gamma (m : ℝ)) := hscaled
      _ = _ := by rw [← mul_assoc,hpow]
  have hcoef : (1-β)*(m : ℝ) ≤ (m : ℝ)-β := by nlinarith
  have hupp : (1-β)*((m : ℝ)^β*Real.Gamma ((m : ℝ)-β)) ≤ Real.Gamma (m : ℝ) := by
    apply (mul_le_mul_iff_right₀ hm0).mp
    calc
      _ = ((1-β)*(m : ℝ))*((m : ℝ)^β*Real.Gamma ((m : ℝ)-β)) := by ring
      _ ≤ ((m : ℝ)-β)*((m : ℝ)^β*Real.Gamma ((m : ℝ)-β)) :=
        mul_le_mul_of_nonneg_right hcoef (mul_nonneg hR hA.le)
      _ ≤ _ := hscaled'
  have hfact : (m.factorial : ℝ) = (m : ℝ)*Real.Gamma (m : ℝ) := by
    rw [← Real.Gamma_nat_eq_factorial m,Real.Gamma_add_one (ne_of_gt hm0)]
  have hid : (m : ℝ)^(1+β)*(Real.Gamma ((m : ℝ)-β)/(m.factorial : ℝ)) =
      ((m : ℝ)^β*Real.Gamma ((m : ℝ)-β))/Real.Gamma (m : ℝ) := by
    rw [Real.rpow_add hm0,Real.rpow_one,hfact]
    field_simp
  rw [hid]
  constructor
  · exact (one_le_div hG).mpr hlow
  · apply (le_div_iff₀ (show 0 < 1-β by linarith)).mpr
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hG).mpr
    simpa only [one_mul,mul_comm] using hupp

end NeuralGeneralization
