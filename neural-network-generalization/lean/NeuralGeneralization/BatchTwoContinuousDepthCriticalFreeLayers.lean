import NeuralGeneralization.BatchTwoContinuousDepthCriticalCooling
import Mathlib.NumberTheory.Harmonic.Bounds

/-! Iterated genuine Gaussian cooling preserves a polynomial fraction of the
first-feature signal. -/
noncomputable section
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical

def coolingOrbit (q : ℝ) (h : ℕ) : ℝ := coolingSecondMoment^[h] q

theorem coolingConstant_le_half : coolingConstant≤1/2 := by
  have hm : coolingMass≤1 := measureReal_le_one
  unfold coolingConstant
  linarith

theorem coolingOrbit_bounds {q:ℝ} (hq:0≤q) (hq1:q≤1) (h:ℕ) :
    0≤coolingOrbit q h ∧ coolingOrbit q h≤1 := by
  induction h with
  | zero => exact ⟨hq,hq1⟩
  | succ h ih =>
    have he : coolingOrbit q (h+1)=coolingSecondMoment (coolingOrbit q h) := Function.iterate_succ_apply' _ _ _
    rw [he]
    exact ⟨coolingSecondMoment_nonneg _,(coolingSecondMoment_le _ ih.1).trans ih.2⟩

theorem coolingOrbit_bound {q:ℝ} (hq:0≤q) (hq1:q≤1) (h:ℕ) :
    coolingOrbit q h≤1/(1+coolingConstant*h) := by
  induction h with
  | zero => simpa [coolingOrbit] using hq1
  | succ h ih =>
    let c:=coolingConstant
    let x:=coolingOrbit q h
    let u:=1/(1+c*(h:ℝ))
    let v:=1/(1+c*((h:ℝ)+1))
    have hc : 0<c := coolingConstant_pos
    have hc1 : c≤1/2 := coolingConstant_le_half
    have hx:=coolingOrbit_bounds hq hq1 h
    have hu : 0<u := by dsimp[u];positivity
    have hu1 : u≤1 := by dsimp[u];apply (div_le_one (by positivity)).mpr;nlinarith [Nat.cast_nonneg h (α:=ℝ)]
    have hxu : x≤u := ih
    have hm : x-c*x^2≤u-c*u^2 := by
      have hp : 0≤(u-x)*(1-c*(u+x)) := mul_nonneg (sub_nonneg.mpr hxu) (by
        have hxx : x≤1 := hx.2
        have hcx := mul_le_mul_of_nonneg_left (show u+x≤2 by linarith) hc.le
        nlinarith)
      nlinarith
    have hv : u-c*u^2≤v := by
      have hd : 0<1+c*(h:ℝ) := by positivity
      have hd' : 0<1+c*((h:ℝ)+1) := by positivity
      dsimp[u,v]
      apply (le_div_iff₀ hd').mpr
      field_simp
      nlinarith [sq_nonneg c]
    have he : coolingOrbit q (h+1)=coolingSecondMoment x := Function.iterate_succ_apply' _ _ _
    rw [he]
    have ht:=coolingSecondMoment_quadratic hx.1 hx.2
    have hh := ht.trans (hm.trans hv)
    simpa only [Nat.cast_add,Nat.cast_one] using hh

theorem cooling_sum_bound {q:ℝ} (hq:0≤q) (hq1:q≤1) (h:ℕ) :
    (∑s∈Finset.range h,coolingOrbit q s)≤(1+Real.log (h+1))/coolingConstant := by
  have hc:=coolingConstant_pos
  have hc1 : coolingConstant≤1 := le_trans coolingConstant_le_half (by norm_num)
  have hp (s:ℕ) : coolingOrbit q s≤1/coolingConstant*((s:ℝ)+1)⁻¹ := by
    have hs:=coolingOrbit_bound hq hq1 s
    have hden : 0<coolingConstant*((s:ℝ)+1) := by positivity
    have hh:=one_div_le_one_div_of_le hden (show coolingConstant*((s:ℝ)+1)≤1+coolingConstant*s by nlinarith)
    have he : 1/(coolingConstant*((s:ℝ)+1))=1/coolingConstant*((s:ℝ)+1)⁻¹ := by field_simp <;> ring
    rw [he] at hh
    exact hs.trans hh
  have hsum := Finset.sum_le_sum (s:=Finset.range h) (fun s _=>hp s)
  rw [←Finset.mul_sum] at hsum
  have hharm : (∑s∈Finset.range h,((s:ℝ)+1)⁻¹)=(harmonic h:ℝ) := by
    simp [harmonic]
  rw [hharm] at hsum
  have hlog : Real.log (h:ℝ)≤Real.log ((h:ℝ)+1) := by
    rcases Nat.eq_zero_or_pos h with rfl|hh
    · simp
    · exact Real.log_le_log (by exact_mod_cast hh) (by linarith)
  have hH : (harmonic h:ℝ)≤1+Real.log ((h:ℝ)+1) := (harmonic_le_one_add_log h).trans (by linarith)
  exact hsum.trans (by simpa only [one_div,mul_comm,div_eq_mul_inv,mul_one] using mul_le_mul_of_nonneg_left hH (by positivity : 0≤1/coolingConstant))


def freeSeedMultiplier (q:ℝ) (h:ℕ) : ℝ :=
  ∏s∈Finset.range h,coolingDerivative (coolingOrbit q s)

theorem freeSeedMultiplier_lower {q:ℝ} (hq:0≤q) (hq1:q≤1) (h:ℕ) :
    Real.exp (-(1+Real.log (h+1))/(coolingConstant*derivativeFloor))≤freeSeedMultiplier q h := by
  have hpoint (s:ℕ) : Real.exp (-coolingOrbit q s/derivativeFloor)≤coolingDerivative (coolingOrbit q s) := by
    have hb:=coolingOrbit_bounds hq hq1 s
    have hl:=cooling_log_loss hb.1 hb.2
    have hh:=Real.exp_le_exp.mpr (show -coolingOrbit q s/derivativeFloor≤Real.log (coolingDerivative (coolingOrbit q s)) by rw [neg_div];linarith)
    rwa [Real.exp_log (coolingDerivative_pos _)] at hh
  have hp:=Finset.prod_le_prod (s:=Finset.range h)
    (fun s _ => (Real.exp_pos (-coolingOrbit q s/derivativeFloor)).le) (fun s _=>hpoint s)
  rw [←Real.exp_sum] at hp
  have hs:=cooling_sum_bound hq hq1 h
  have he : (∑s∈Finset.range h,-coolingOrbit q s/derivativeFloor)=
      -(∑s∈Finset.range h,coolingOrbit q s)/derivativeFloor := by
    rw [←Finset.sum_div,←Finset.sum_neg_distrib]
  rw [he] at hp
  have hh:=div_le_div_of_nonneg_right hs derivativeFloor_pos.le
  have ha : -(1+Real.log ((h:ℝ)+1))/(coolingConstant*derivativeFloor)≤
      -(∑s∈Finset.range h,coolingOrbit q s)/derivativeFloor := by
    have hi : ((1+Real.log ((h:ℝ)+1))/coolingConstant)/derivativeFloor=
      (1+Real.log ((h:ℝ)+1))/(coolingConstant*derivativeFloor) := by ring
    rw [hi] at hh
    simp only [neg_div]
    linarith
  exact (Real.exp_le_exp.mpr ha).trans hp

end NeuralGeneralization.BatchTwoContinuousDepthCritical
