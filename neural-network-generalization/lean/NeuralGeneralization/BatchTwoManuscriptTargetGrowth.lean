import NeuralGeneralization.BatchTwoManuscriptTargetMain
import NeuralGeneralization.BatchTwoImprovedTargetGrowth
import NeuralGeneralization.BatchTwoImprovedTargetBudget

/-! Growth of the literal target cost, by comparison with the certified larger cylinder. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
open Filter Asymptotics
namespace NeuralGeneralization.BatchTwoManuscriptTarget
open ConcreteModel BatchTwoMerging

theorem targetGain_ge_one {C : ℕ} (hC : 0<C) (r : ℕ) : 1≤targetGain C r := by
  have hl2 : (1/2:ℝ)≤Real.log 2 := by
    have hh := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at hh
    exact hh
  have hl9 : Real.log 2≤Real.log 9 := Real.log_le_log (by norm_num) (by norm_num)
  have hl : 0≤Real.log (4*((r:ℝ)+2)) := Real.log_nonneg (by nlinarith [Nat.cast_nonneg (α:=ℝ) r])
  have hs := sharpBulkBound_sq r
  have hb := sharpBulkBound_nonneg r
  have hb1 : 1≤sharpBulkBound r := by nlinarith
  linarith [(targetGain_bounds hC r).2.1]

theorem targetError_comparison {C : ℕ} (hC : 0<C) : improvedError C≤targetError C := by
  have hc : (0:ℝ)<C := by exact_mod_cast hC
  have hs := Real.sq_sqrt hc.le
  have hs2 := Real.sq_sqrt (show 0≤2*(C:ℝ) by positivity)
  have h1 : 0<Real.sqrt C := by positivity
  have h2 : 0<Real.sqrt (2*(C:ℝ)) := by positivity
  unfold improvedError targetError
  apply (div_le_div_iff₀ (by positivity) (by positivity)).mpr
  nlinarith

theorem targetGain_comparison {C : ℕ} (hC : 0<C) (r : ℕ) : targetGain C r≤ improvedGain C r := by
  have he := (targetError_bounds hC).1
  have hs := Real.sq_sqrt (Nat.cast_nonneg C : (0:ℝ)≤C)
  have hs2 := Real.sq_sqrt (show 0≤2*(C:ℝ) by positivity)
  have hroot : 0<Real.sqrt C := by
    have : (0:ℝ)<C := by exact_mod_cast hC
    positivity
  have hroot2 := Real.sqrt_nonneg (2*(C:ℝ))
  have harg : 8/targetError C≤1024*Real.sqrt C := by
    have hid : 8/targetError C=128*Real.sqrt (2*(C:ℝ)) := by unfold targetError; field_simp; norm_num
    rw [hid]
    nlinarith
  have hlog := Real.log_le_log (show 0<8/targetError C by positivity) harg
  have hold := improvedGain_bounds r hC
  unfold targetGain
  apply max_le
  · linarith [sharpBulkBound_nonneg r]
  · unfold improvedGain
    linarith [sharpBulkBound_nonneg r]

theorem targetRadius_comparison (d r : ℕ) {C : ℕ} (hC : 0<C) :
    improvedRadius d C≤targetRadius d C r := by
  obtain ⟨hr,hrE,hrd,hrC⟩ := improvedRadius_bounds d hC
  have he := improvedError_bounds hC
  have hA := targetGain_ge_one hC r
  have hε := targetError_comparison hC
  have hε0 := (targetError_bounds hC).1
  have hc : (1:ℝ)≤C := by exact_mod_cast hC
  have hs0 := Real.sqrt_nonneg (C:ℝ)
  have hs := Real.sq_sqrt (Nat.cast_nonneg C : (0:ℝ)≤C)
  have hroot : 0<Real.sqrt C := by positivity
  have hrootle : Real.sqrt C≤((d:ℝ)+1)*((C:ℝ)+1) := by
    have hd := Nat.cast_nonneg (α:=ℝ) d
    have hprod := mul_nonneg hd (show 0≤(C:ℝ)+1 by positivity)
    have hsle : Real.sqrt C≤(C:ℝ)+1 := by nlinarith
    nlinarith
  unfold targetRadius
  apply le_min
  · linarith
  · apply le_min
    · apply (le_div_iff₀ (by positivity)).mpr
      nlinarith
    · apply (le_div_iff₀ (by positivity)).mpr
      have hid : improvedRadius d C*(64*((d:ℝ)+1)*((C:ℝ)+1))=improvedError C := by
        unfold improvedRadius
        field_simp
      have hh := mul_le_mul_of_nonneg_left hrootle (show 0≤64*improvedRadius d C by positivity)
      have heA := mul_le_mul_of_nonneg_right hA hε0.le
      nlinarith

theorem targetCost_comparison (d r : ℕ) {C : ℕ} (hC : 0<C) {c : ℝ} (hc : 0≤c) :
    targetCost d C r c≤ improvedTargetCost d C r c := by
  have hA := targetGain_comparison hC r
  have hA0 := (targetGain_bounds hC r).1.le
  have ha : targetReadout c≤ improvedReadout c := by
    unfold targetReadout improvedReadout
    apply max_le <;> linarith
  have ha0 : 0≤targetReadout c := (by norm_num : (0:ℝ)≤2).trans (le_max_left _ _)
  have hA2 := (sq_le_sq₀ hA0 (hA0.trans hA)).mpr hA
  have ha2 := (sq_le_sq₀ ha0 (ha0.trans ha)).mpr ha
  have hfirst := mul_le_mul_of_nonneg_left hA2 (show 0≤9*(d:ℝ) by positivity)
  have hinner := mul_le_mul_of_nonneg_left hA2 (show 0≤18*(r:ℝ)*C by positivity)
  have hout := mul_le_mul_of_nonneg_left ha2 (show 0≤2*(C:ℝ) by positivity)
  have hK : targetTeacherCost d C r c≤ improvedTeacherCost d C r c := by
    unfold targetTeacherCost improvedTeacherCost
    nlinarith only [hfirst,hinner,hout]
  have hρ := (targetRadius_bounds d r hC).1
  have holdρ := (improvedRadius_bounds d hC).1
  have harg : Real.exp 1*Real.sqrt (2*Real.pi)/(2*targetRadius d C r)≤
      Real.exp 1*Real.sqrt (2*Real.pi)/(2*improvedRadius d C) := by
    apply div_le_div_of_nonneg_left (by positivity) (by positivity)
    linarith [targetRadius_comparison d r hC]
  have hlog := Real.log_le_log (show 0<Real.exp 1*Real.sqrt (2*Real.pi)/(2*targetRadius d C r) by positivity) harg
  have hroot : 1≤Real.sqrt (2*Real.pi) := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    nlinarith only [Real.pi_gt_three]
  have hex := Real.one_le_exp (show (0:ℝ)≤1 by norm_num)
  have harg1 : 1≤Real.exp 1*Real.sqrt (2*Real.pi)/(2*targetRadius d C r) := by
    apply (le_div_iff₀ (by positivity)).mpr
    nlinarith [(targetRadius_bounds d r hC).2.1]
  have hlog0 := Real.log_nonneg harg1
  have hq : (d:ℝ)+2+(r:ℝ)*C≤(d:ℝ)+2+(r:ℝ)*((C:ℝ)+1) := by
    nlinarith [Nat.cast_nonneg (α:=ℝ) r]
  have hprod := mul_le_mul hq hlog hlog0 (show 0≤(d:ℝ)+2+(r:ℝ)*((C:ℝ)+1) by positivity)
  unfold targetCost improvedTargetCost sharpCylinderCost
  linarith

theorem targetCost_width_growth (d r : ℕ) {c : ℝ} (hc : 0≤c) :
    WidthGrowth (fun C=>targetCost d C r c) 1 2 := by
  obtain ⟨a,ha,hg⟩ := improvedTargetCost_width_growth d r c
  refine ⟨a,ha,?_⟩
  intro C hC
  have hp : 0≤targetCost d C r c := (by norm_num : (0:ℝ)≤1).trans (targetCost_ge_one d r (by omega) c)
  rw [abs_of_nonneg hp]
  exact (targetCost_comparison d r (by omega) hc).trans ((le_abs_self _).trans (hg C hC))

theorem targetCost_isBigO (d r : ℕ) {c : ℝ} (hc : 0≤c) :
    (fun C=>targetCost d C r c) =O[atTop] (fun C=>(C:ℝ)*Real.log ((C:ℝ)+2)^2) := by
  simpa only [pow_one] using (targetCost_width_growth d r hc).isBigO

theorem targetCost_budget {d C r : ℕ} (hC : 0<C) {c S : ℝ}
    (hc : 0≤c) (hS : 1≤S) (hd : (d:ℝ)≤S) (hCS : (C:ℝ)≤S)
    (hr : (r:ℝ)≤S) (hcS : c≤S) : targetCost d C r c≤(10000000000:ℝ)*S^3 :=
  (targetCost_comparison d r hC hc).trans (improvedTargetCost_budget hC hc hS hd hCS hr hcS)

end NeuralGeneralization.BatchTwoManuscriptTarget
