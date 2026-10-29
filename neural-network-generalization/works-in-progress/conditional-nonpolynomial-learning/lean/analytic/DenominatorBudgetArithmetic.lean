import UniformFinalBudget
import CriticalWidthResources

noncomputable section
set_option maxHeartbeats 2200000
namespace ConditionalNonpolynomial.Analytic

def denominatorBudget (C t R : ℝ) (r : ℕ) : ℝ :=
  (r:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
    C*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/(r:ℝ))

theorem denominatorBudget_nonneg {C t R : ℝ} {r : ℕ}
    (hC : 0≤C) (ht : 0<t) (ht1 : t≤1) (hR : 2≤R) :
    0≤denominatorBudget C t R r := by
  have hu : 0<t^2 := sq_pos_of_pos ht
  have hz : 0≤(t^2)⁻¹-1 := sub_nonneg.mpr ((one_le_inv₀ hu).mpr (by nlinarith))
  have hlog : 0≤Real.log R := Real.log_nonneg (by linarith)
  have hct := subcriticalCostBaseline_nonneg (t^2).toNNReal
    (Real.toNNReal_pos.mpr hu).ne'
  unfold denominatorBudget
  positivity

/-- The raw denominator action can grow as t tends to zero, but its normalized
budget remains polynomial with a coefficient independent of t. -/
theorem denominatorBudget_normalized {C t R : ℝ} {r : ℕ}
    (hC : 0≤C) (ht : 0<t) (ht1 : t≤1) (hr : 1≤r) (hR : 2≤R)
    (hrR : (r:ℝ)+1≤R) :
    t^2*(denominatorBudget C t R r+2/(t^2*(r:ℝ)))≤(2*C+260)*R^2 := by
  have hu : 0<t^2 := sq_pos_of_pos ht
  have hu1 : t^2≤1 := by nlinarith
  have hrr : (1:ℝ)≤r := by exact_mod_cast hr
  have hr0 : (0:ℝ)<r := by linarith
  have hR0 : 0<R := by linarith
  have hRR : R≤R^2 := by nlinarith
  have hR2 : 1≤R^2 := by nlinarith
  have hl0 : 0≤Real.log R := Real.log_nonneg (by linarith)
  have hl : Real.log R≤R := by linarith [Real.log_le_sub_one_of_pos hR0]
  have hlsq : (Real.log R)^2≤R^2 := pow_le_pow_left₀ hl0 hl 2
  have hlogpart : (1-t^2)*Real.log R≤R^2 := by
    have hh : (1-t^2)*Real.log R≤Real.log R := by nlinarith [mul_nonneg hu.le hl0]
    exact hh.trans (hl.trans hRR)
  have hdiv : t^2*((Real.log R)^2/(r:ℝ))≤R^2 := by
    have hp : 0≤(Real.log R)^2/(r:ℝ) := by positivity
    have hh : (Real.log R)^2/(r:ℝ)≤R^2 := (div_le_self (sq_nonneg _) hrr).trans hlsq
    nlinarith
  have herror := mul_le_mul_of_nonneg_left (add_le_add hlogpart hdiv) hC
  have hbase := mul_le_mul_of_nonneg_left (scaled_subcriticalCostBaseline_le_half ht ht1)
    (Nat.cast_nonneg (α:=ℝ) r)
  have hb : t^2*scalarBaseline.toReal≤257 := by
    have hb0 : 0≤scalarBaseline.toReal := ENNReal.toReal_nonneg
    have hble := scalarBaseline_le
    nlinarith
  have hslack : 2/(r:ℝ)≤2 := div_le_self (by norm_num) hrr
  have hid : t^2*(denominatorBudget C t R r+2/(t^2*(r:ℝ)))=
      (r:ℝ)*(t^2*subcriticalCostBaseline (t^2).toNNReal)+t^2*scalarBaseline.toReal+
      C*((1-t^2)*Real.log R+t^2*((Real.log R)^2/(r:ℝ)))+2/(r:ℝ) := by
    unfold denominatorBudget
    field_simp
  rw [hid]
  nlinarith only [herror,hbase,hb,hslack,hrR,hRR,hR2]

theorem denominator_slack_absorption {t R : ℝ} {r : ℕ}
    (ht : 0<t) (ht1 : t≤1) (hr : 1≤r) (hR : 2≤R) :
    3/(t^2*(r:ℝ))≤24*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/((r:ℝ)+1)) := by
  have hu : 0<t^2 := sq_pos_of_pos ht
  have hz : 0≤(t^2)⁻¹-1 := sub_nonneg.mpr ((one_le_inv₀ hu).mpr (by nlinarith))
  have hrr : (1:ℝ)≤r := by exact_mod_cast hr
  have hr0 : (0:ℝ)<r := by linarith
  have hr1 : 0<(r:ℝ)+1 := by linarith
  have hlog := logarithm_half_le hR
  have hfirst : 3/(r:ℝ)≤24*((Real.log R)^2/((r:ℝ)+1)) := by
    apply (div_le_iff₀ hr0).mpr
    apply (mul_le_mul_iff_left₀ hr1).mp
    have hid : 24*((Real.log R)^2/((r:ℝ)+1))*(r:ℝ)*((r:ℝ)+1)=
        24*(Real.log R)^2*(r:ℝ) := by field_simp <;> ring
    rw [hid]
    have hsq : 1≤4*(Real.log R)^2 := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_right hsq (show 0≤(r:ℝ) by positivity)]
  have hthree : 3/(r:ℝ)≤24*Real.log R := by
    have hh : 3/(r:ℝ)≤3 := div_le_self (by norm_num) hrr
    linarith
  have hsecond := mul_le_mul_of_nonneg_left hthree hz
  have hid : 3/(t^2*(r:ℝ))=3/(r:ℝ)+((t^2)⁻¹-1)*(3/(r:ℝ)) := by field_simp <;> ring
  rw [hid]
  nlinarith only [hfirst,hsecond]

/-- Moving from r controlled hidden layers to r+1 physical hidden layers only
changes the universal logarithmic-slack coefficient. -/
theorem denominatorBudget_shift_depth {C t R : ℝ} {r : ℕ}
    (hC : 0≤C) (ht : 0<t) (ht1 : t≤1) (hr : 1≤r) (hR : 2≤R) :
    denominatorBudget C t R r+3/(t^2*(r:ℝ))≤
      (r:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
        (2*C+24)*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/((r:ℝ)+1)) := by
  have hu : 0<t^2 := sq_pos_of_pos ht
  have hz : 0≤(t^2)⁻¹-1 := sub_nonneg.mpr ((one_le_inv₀ hu).mpr (by nlinarith))
  have hx : 0≤((t^2)⁻¹-1)*Real.log R := mul_nonneg hz (Real.log_nonneg (by linarith))
  have hrr : (1:ℝ)≤r := by exact_mod_cast hr
  have hr0 : (0:ℝ)<r := by linarith
  have hr1 : 0<(r:ℝ)+1 := by linarith
  have hd : (Real.log R)^2/(r:ℝ)≤2*((Real.log R)^2/((r:ℝ)+1)) := by
    apply (div_le_iff₀ hr0).mpr
    apply (mul_le_mul_iff_left₀ hr1).mp
    have hid : 2*((Real.log R)^2/((r:ℝ)+1))*(r:ℝ)*((r:ℝ)+1)=
        2*(Real.log R)^2*(r:ℝ) := by field_simp <;> ring
    rw [hid]
    nlinarith [mul_nonneg (sq_nonneg (Real.log R)) (show 0≤(r:ℝ)-1 by linarith)]
  have herror := mul_le_mul_of_nonneg_left hd hC
  have hcx := mul_nonneg hC hx
  have hs := denominator_slack_absorption ht ht1 hr hR
  unfold denominatorBudget
  nlinarith only [herror,hcx,hs]

#print axioms denominatorBudget_nonneg
#print axioms denominatorBudget_normalized
#print axioms denominator_slack_absorption
#print axioms denominatorBudget_shift_depth
end ConditionalNonpolynomial.Analytic
