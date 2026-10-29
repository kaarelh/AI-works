import SubcriticalMarginGain
import UniformTargetPolynomial
noncomputable section
open scoped NNReal
namespace ConditionalNonpolynomial.Analytic

lemma subcriticalCostBaseline_eq_a {v : ℝ≥0} (hv : v≠0) :
    subcriticalCostBaseline v=
      (((v:ℝ)⁻¹-1)-Real.log (1+((v:ℝ)⁻¹-1)))/2 := by
  unfold subcriticalCostBaseline
  rw [show 1+((v:ℝ)⁻¹-1)=(v:ℝ)⁻¹ by ring,Real.log_inv]
  ring

lemma subcriticalCostBaseline_quadratic {v : ℝ≥0} (hv : v≠0) (hv1 : (v:ℝ)≤1) :
    subcriticalCostBaseline v≤((v:ℝ)⁻¹-1)^2/2 := by
  have hv0 : (0:ℝ)<v := NNReal.coe_pos.mpr (pos_iff_ne_zero.mpr hv)
  let a := (v:ℝ)⁻¹-1
  have ha : 0≤a := by
    dsimp [a]
    have hh : 1≤(v:ℝ)⁻¹ := (one_le_inv₀ hv0).mpr hv1
    linarith
  have hlog := Real.one_sub_inv_le_log_of_pos (show 0<1+a by positivity)
  have hid : (1+a)*(1+a)⁻¹=1 := mul_inv_cancel₀ (by positivity : (1+a)≠0)
  have hlower : a-a^2≤1-(1+a)⁻¹ := by
    have hnon : 0≤a^3/(1+a) := by positivity
    have hid' : 1-(1+a)⁻¹-(a-a^2)=a^3/(1+a) := by field_simp; ring
    linarith
  rw [subcriticalCostBaseline_eq_a hv]
  change (a-Real.log (1+a))/2≤a^2/2
  linarith

/-- In the short nearcritical regime the literal physical action is already
within log-squared-over-depth of the critical baseline. -/
theorem short_scale_action {H a T C V A c : ℝ}
    (hH : 0<H) (ha : 0≤a) (hT : 0≤T) (hC : 0≤C)
    (hc : c≤a^2/2) (hshort : a*H≤T)
    (hA : A≤H*c+V+C*(a*T+T^2/H)) :
    A≤V+(2*C+1)*T^2/H := by
  have hprod : a*T≤T^2/H := by
    apply (le_div_iff₀ hH).mpr
    nlinarith [mul_le_mul_of_nonneg_right hshort hT]
  have hsq : H*a^2≤T^2/H := by
    apply (le_div_iff₀ hH).mpr
    have hh := pow_le_pow_left₀ (mul_nonneg ha hH.le) hshort 2
    nlinarith
  have hcH := mul_le_mul_of_nonneg_left hc hH.le
  have hmain := mul_le_mul_of_nonneg_left hprod hC
  have hratio : 0≤T^2/H := by positivity
  have hid : (2*C+1)*T^2/H=(2*C+1)*(T^2/H) := by ring
  rw [hid]
  nlinarith

/-- In the long regime the adjusted excess divided by a=t⁻²−1 is O(T).
The positive part is explicit, so this also covers a negative raw excess. -/
theorem long_scale_excess {H a T C V A c : ℝ}
    (hH : 0<H) (ha : 0<a) (hT : 1≤T) (hC : 0≤C)
    (hlong : T≤a*H) (hA : A≤H*c+V+C*(a*T+T^2/H)) :
    max 0 (A-H*c+a-V)/a≤(2*C+1)*T := by
  have hratio : T^2/H≤a*T := by
    apply (div_le_iff₀ hH).mpr
    nlinarith [mul_le_mul_of_nonneg_right hlong (by linarith : 0≤T)]
  have hCm := mul_le_mul_of_nonneg_left hratio hC
  apply (div_le_iff₀ ha).mpr
  apply max_le
  · positivity
  · nlinarith [mul_le_mul_of_nonneg_left hT ha.le]

lemma long_scale_dyadic_reach {H : ℕ} {a T : ℝ} (hH : 1≤H)
    (ha : 0≤a) (hT : 1≤T) (hlong : T≤a*(H:ℝ)) :
    1≤(2:ℝ)^(Nat.log2 (H+1)+1)*a := by
  have hp : (H:ℝ)≤(2:ℝ)^(Nat.log2 (H+1)+1) := by
    exact_mod_cast (show H≤2^(Nat.log2 (H+1)+1) by have hh := Nat.lt_log2_self (n:=H+1); omega)
  nlinarith [mul_le_mul_of_nonneg_right hp ha]

#print axioms subcriticalCostBaseline_quadratic
#print axioms short_scale_action
#print axioms long_scale_excess
#print axioms long_scale_dyadic_reach
end ConditionalNonpolynomial.Analytic
