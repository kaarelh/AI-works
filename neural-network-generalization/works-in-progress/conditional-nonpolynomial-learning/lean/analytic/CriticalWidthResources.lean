import ScalarPathEntropyLog
import CriticalMemorizerProgram

noncomputable section
set_option maxHeartbeats 1600000
namespace ConditionalNonpolynomial.Analytic

theorem constant_le_power {R C : ℝ} {p : ℕ} (hR : 2≤R) (hp : 2*C≤(p:ℝ)) : C≤R^p := by
  have hl := logarithm_half_le hR
  have hp0 : 0≤(p:ℝ) := Nat.cast_nonneg _
  have he : C≤(p:ℝ)*Real.log R := by nlinarith
  have hc : C≤Real.exp C := by linarith [Real.add_one_le_exp C]
  exact hc.trans (exp_log_bound_to_power (by linarith) he le_rfl)

theorem critical_action_polynomial {H p : ℕ} {R C : ℝ}
    (hH : 1≤H) (hR : 2≤R) (hC : 0≤C) (hconst : C+259≤R^p) :
    scalarBaseline.toReal+C*(Real.log R)^2/(H:ℝ)+1/(H:ℝ)+1≤R^(p+2) := by
  have hHr : (1:ℝ)≤H := by exact_mod_cast hH
  have hH0 : (0:ℝ)<H := by linarith
  have hR0 : 0<R := by linarith
  have hl0 : 0≤Real.log R := Real.log_nonneg (by linarith)
  have hl : Real.log R≤R := by linarith [Real.log_le_sub_one_of_pos hR0]
  have hlsq : (Real.log R)^2≤R^2 := pow_le_pow_left₀ hl0 hl 2
  have hdiv : C*(Real.log R)^2/(H:ℝ)≤C*R^2 := by
    apply (div_le_iff₀ hH0).mpr
    have hm := mul_le_mul_of_nonneg_left hlsq hC
    have hh : C*R^2≤C*R^2*(H:ℝ) := by nlinarith [mul_nonneg hC (sq_nonneg R)]
    exact hm.trans hh
  have hi : 1/(H:ℝ)≤1 := (div_le_one hH0).mpr hHr
  have hr2 : 1≤R^2 := by nlinarith
  have hb := scalarBaseline_le
  have hres : scalarBaseline.toReal+C*(Real.log R)^2/(H:ℝ)+1/(H:ℝ)+1≤(C+259)*R^2 := by
    nlinarith
  exact hres.trans (by rw [pow_add]; exact mul_le_mul_of_nonneg_right hconst (sq_nonneg R))

theorem critical_slack_inverse_polynomial {H p : ℕ} {R A : ℝ}
    (hH : 1≤H) (hR : 2≤R) (hHR : (H:ℝ)≤R)
    (hA : A+1/(H:ℝ)+1≤R^(p+2)) :
    1/channelSlackProbability A (1/(H:ℝ))≤R^(p+7) := by
  have hH0 : (0:ℝ)<H := by exact_mod_cast (show 0<H by omega)
  rw [channelSlackProbability_inverse (one_div_pos.mpr hH0)]
  have he : 16*(A+1/(H:ℝ)+1)/(1/(H:ℝ))=16*(A+1/(H:ℝ)+1)*(H:ℝ) := by field_simp
  rw [he]
  have h16 : (16:ℝ)≤R^4 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 4
    norm_num at hh
    exact hh
  calc
    _ ≤ 16*R^(p+2)*R := by gcongr
    _ ≤ R^4*R^(p+2)*R := by gcongr
    _ = R^(p+7) := by rw [pow_add,pow_add]; ring

#print axioms critical_action_polynomial
#print axioms critical_slack_inverse_polynomial
end ConditionalNonpolynomial.Analytic
