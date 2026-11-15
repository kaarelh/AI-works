import NeuralGeneralization.BatchTwoImprovedTargetParameters

/-! The literal target-cylinder constants of the original-support-all-scales paper. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoManuscriptTarget
open ConcreteModel BatchTwoMerging

def targetError (C : ℕ) : ℝ := 1/(16*Real.sqrt (2*(C:ℝ)))
def targetNoise (C : ℕ) : ℝ := targetError C/4
def targetGain (C r : ℕ) : ℝ := max (32*sharpBulkBound r) (2*Real.log (8/targetError C))
def targetReadout (c : ℝ) : ℝ := max 2 (256*c)
def targetRadius (d C r : ℕ) : ℝ :=
  min (1/4) (min (targetGain C r/(4*((d:ℝ)+1)))
    (targetGain C r*targetError C/(64*Real.sqrt C)))
def targetTeacherCost (d C r : ℕ) (c : ℝ) : ℝ :=
  9*d*(targetGain C r)^2+18*r*C*(targetGain C r)^2+2*C*(targetReadout c)^2
def targetCost (d C r : ℕ) (c : ℝ) : ℝ :=
  sharpCylinderCost d r (targetTeacherCost d C r c) (C:ℝ) (targetRadius d C r)

theorem targetError_bounds {C : ℕ} (hC : 0<C) :
    0<targetError C ∧ targetError C≤1/16 ∧ (targetError C)^2*(C:ℝ)=1/512 := by
  have hc : (1:ℝ)≤C := by exact_mod_cast hC
  have hp : 0<Real.sqrt (2*(C:ℝ)) := by positivity
  have hs : 1≤Real.sqrt (2*(C:ℝ)) := by
    apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
    nlinarith
  have hsq := Real.sq_sqrt (show 0≤2*(C:ℝ) by positivity)
  refine ⟨by unfold targetError; positivity,?_,?_⟩
  · unfold targetError
    apply (div_le_iff₀ (by positivity)).mpr
    linarith
  · unfold targetError
    field_simp
    nlinarith

theorem targetGain_bounds {C : ℕ} (hC : 0<C) (r : ℕ) :
    0<targetGain C r ∧ 32*sharpBulkBound r≤targetGain C r ∧
      2*Real.exp (-targetGain C r/2)≤targetError C/4 := by
  obtain ⟨he,he16,_⟩ := targetError_bounds hC
  have harg : 1<8/targetError C := by
    apply (lt_div_iff₀ he).mpr
    linarith
  have hl := Real.log_pos harg
  have ha := le_max_right (32*sharpBulkBound r) (2*Real.log (8/targetError C))
  refine ⟨by unfold targetGain; linarith,le_max_left _ _,?_⟩
  have hh : -targetGain C r/2≤ -Real.log (8/targetError C) := by
    change 2*Real.log (8/targetError C)≤targetGain C r at ha
    linarith
  have hh' := Real.exp_le_exp.mpr hh
  rw [Real.exp_neg,Real.exp_log (lt_trans (by norm_num) harg)] at hh'
  have hid : 2*(8/targetError C)⁻¹=targetError C/4 := by field_simp; ring
  rw [←hid]
  exact mul_le_mul_of_nonneg_left hh' (by norm_num)

theorem targetRadius_bounds (d r : ℕ) {C : ℕ} (hC : 0<C) :
    0<targetRadius d C r ∧ targetRadius d C r≤1/4 ∧
      ((d:ℝ)+1)*targetRadius d C r≤targetGain C r/4 ∧
      targetRadius d C r*Real.sqrt C≤targetGain C r*targetError C/64 := by
  have hA := (targetGain_bounds hC r).1
  have he := (targetError_bounds hC).1
  have hC' : (0:ℝ)<C := by exact_mod_cast hC
  have hs : 0<Real.sqrt C := by positivity
  have hd : 0<4*((d:ℝ)+1) := by positivity
  have hr1 : targetRadius d C r≤targetGain C r/(4*((d:ℝ)+1)) :=
    (min_le_right _ _).trans (min_le_left _ _)
  have hr2 : targetRadius d C r≤targetGain C r*targetError C/(64*Real.sqrt C) :=
    (min_le_right _ _).trans (min_le_right _ _)
  refine ⟨by unfold targetRadius; positivity,min_le_left _ _,?_,?_⟩
  · have hh := (le_div_iff₀ hd).mp hr1
    nlinarith
  · have hh := (le_div_iff₀ (show 0<64*Real.sqrt C by positivity)).mp hr2
    nlinarith

/-- The squared-error recurrence retains sufficient slack at the displayed gain. -/
theorem literal_contraction {ε τ A β ρ G s : ℝ}
    (hε : 0≤ε) (hεsmall : ε≤1/2) (hτ : 0≤τ) (hτsmall : τ≤ε/4)
    (hs : 0≤s) (hssmall : s≤ε/4) (hA : 0<A)
    (hβ : 0≤β) (hβA : 32*β≤A)
    (hR : (8/A)^2*ρ^2*G≤ε^2/64) :
    3*(s^2+(8/A)^2*(4*ρ^2*G*(1+ε^2)+2*β^2*ε^2)+τ^2)≤ε^2 := by
  have hs2 : s^2≤(ε/4)^2 := (sq_le_sq₀ hs (by positivity)).mpr hssmall
  have hτ2 : τ^2≤(ε/4)^2 := (sq_le_sq₀ hτ (by positivity)).mpr hτsmall
  have hb : 8*β/A≤1/4 := by apply (div_le_iff₀ hA).mpr; nlinarith
  have hb2 : (8*β/A)^2≤(1/4:ℝ)^2 := (sq_le_sq₀ (by positivity) (by norm_num)).mpr hb
  have he2 : ε^2≤1/4 := by nlinarith
  have hr := mul_le_mul_of_nonneg_right hR (show 0≤4*(1+ε^2) by positivity)
  have hr' := mul_le_mul_of_nonneg_left (show 4*(1+ε^2)≤5 by linarith)
    (show 0≤ε^2/64 by positivity)
  have hrr : (8/A)^2*(4*ρ^2*G*(1+ε^2))≤5*ε^2/64 := by nlinarith only [hr,hr']
  have hbb := mul_le_mul_of_nonneg_right hb2 (show 0≤2*ε^2 by positivity)
  have hid : (8/A)^2*(2*β^2*ε^2)=(8*β/A)^2*(2*ε^2) := by ring
  rw [←hid] at hbb
  nlinarith only [hs2,hτ2,hrr,hbb,sq_nonneg ε]

theorem target_parameter_conditions (d r : ℕ) {C : ℕ} (hC : 0<C) {c : ℝ} (hc : 0<c) :
    let ε:=targetError C
    let τ:=targetNoise C
    let A:=targetGain C r
    let a:=targetReadout c
    let ρ:=targetRadius d C r
    0<A ∧ 0≤a ∧ 0≤ε ∧ ε≤1 ∧ 0≤τ ∧ 0≤ρ ∧ ρ≤a/4 ∧
    ((d:ℝ)+1)*ρ≤A/2 ∧ 2*(C:ℝ)*ε^2≤(1/16:ℝ)^2 ∧
    3*((2*Real.exp (-A/2))^2+τ^2)≤ε^2 ∧
    3*((2*Real.exp (-A/2))^2+(8/A)^2*(4*ρ^2*(C:ℝ)*(1+ε^2)+
      2*(sharpBulkBound r)^2*ε^2)+τ^2)≤ε^2 ∧
    1<15*a/16-2*ρ-τ ∧ 8*c^2≤τ^2*a^2*(C:ℝ) := by
  dsimp
  obtain ⟨he,he16,heC⟩ := targetError_bounds hC
  obtain ⟨hA,hAb,hAs⟩ := targetGain_bounds hC r
  obtain ⟨hρ,hρ4,hρd,hρC⟩ := targetRadius_bounds d r hC
  have ha : 2≤targetReadout c := le_max_left _ _
  have hac : 256*c≤targetReadout c := le_max_right _ _
  have hτ : 0≤targetNoise C := by unfold targetNoise; positivity
  have hs2 : (2*Real.exp (-targetGain C r/2))^2≤(targetError C/4)^2 :=
    (sq_le_sq₀ (by positivity) (by positivity)).mpr hAs
  have hCsq := Real.sq_sqrt (Nat.cast_nonneg C : (0:ℝ)≤C)
  have h8 : 0≤8/targetGain C r := by positivity
  have hr : 8/targetGain C r*targetRadius d C r*Real.sqrt C≤targetError C/8 := by
    have hh := mul_le_mul_of_nonneg_left hρC h8
    have heq : (8/targetGain C r)*(targetGain C r*targetError C/64)=targetError C/8 := by field_simp; ring
    rw [heq] at hh
    nlinarith only [hh]
  have hr2 := (sq_le_sq₀ (show 0≤8/targetGain C r*targetRadius d C r*Real.sqrt C by positivity)
    (show 0≤targetError C/8 by positivity)).mpr hr
  have hR : (8/targetGain C r)^2*(targetRadius d C r)^2*(C:ℝ)≤(targetError C)^2/64 := by
    simp only [mul_pow] at hr2
    rw [hCsq] at hr2
    nlinarith only [hr2]
  refine ⟨hA,by linarith,he.le,by linarith,hτ,hρ.le,by linarith,by linarith,?_,?_,?_,?_,?_⟩
  · nlinarith only [heC]
  · unfold targetNoise
    nlinarith only [hs2,sq_nonneg (targetError C)]
  · exact literal_contraction he.le (by linarith) hτ le_rfl (by positivity) hAs hA
      (sharpBulkBound_nonneg r) hAb hR
  · unfold targetNoise
    linarith
  · have hac2 : (256*c)^2≤(targetReadout c)^2 :=
      (sq_le_sq₀ (by positivity) (by linarith)).mpr hac
    have hmul := mul_le_mul_of_nonneg_right hac2 (show 0≤(targetError C)^2*(C:ℝ) by positivity)
    rw [heC] at hmul
    unfold targetNoise
    nlinarith only [hmul,heC]

end NeuralGeneralization.BatchTwoManuscriptTarget
