import NeuralGeneralization.BatchTwoImprovedTargetGeometry
import NeuralGeneralization.RobustTargetParameterFacts

/-! Logarithmic Boolean gains, constant-in-width readout amplification, and an
explicit original-support cylinder cost. -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.BatchTwoMerging

def improvedError (C:ℕ):ℝ := 1/(64*Real.sqrt C)
def improvedNoise (C:ℕ):ℝ := improvedError C/8
def improvedGain (C r:ℕ):ℝ :=
  128*(sharpBulkBound r+1)+2*Real.log (1024*Real.sqrt C)
def improvedReadout (c:ℝ):ℝ := 4+4096*c
def improvedRadius (d C:ℕ):ℝ := improvedError C/(64*((d:ℝ)+1)*((C:ℝ)+1))
def improvedTeacherCost (d C r:ℕ) (c:ℝ):ℝ :=
  9*d*(improvedGain C r)^2+18*r*C*(improvedGain C r)^2+2*C*(improvedReadout c)^2
def improvedTargetCost (d C r:ℕ) (c:ℝ):ℝ :=
  sharpCylinderCost d r (improvedTeacherCost d C r c) ((C:ℝ)+1) (improvedRadius d C)

theorem improvedError_bounds {C:ℕ} (hC:0<C):0< improvedError C ∧ improvedError C≤1/64 := by
  have hc:(1:ℝ)≤C := by exact_mod_cast hC
  have hs:1≤Real.sqrt C := by simpa using Real.sqrt_le_sqrt hc
  constructor
  · unfold improvedError;positivity
  · unfold improvedError
    apply (div_le_div_iff₀ (by positivity) (by norm_num : (0:ℝ)<64)).mpr
    nlinarith

theorem improvedRadius_bounds (d:ℕ) {C:ℕ} (hC:0<C):
    0< improvedRadius d C ∧ improvedRadius d C≤ improvedError C ∧
    ((d:ℝ)+1)*improvedRadius d C≤ improvedError C ∧
    improvedRadius d C*((C:ℝ)+1)≤ improvedError C := by
  have he:=improvedError_bounds hC
  have hd0:0≤(d:ℝ):=Nat.cast_nonneg d
  have hc0:0≤(C:ℝ):=Nat.cast_nonneg C
  have hden:0<64*((d:ℝ)+1)*((C:ℝ)+1):=by positivity
  have hidentity:improvedRadius d C*(64*((d:ℝ)+1)*((C:ℝ)+1))=improvedError C := by
    unfold improvedRadius
    field_simp
  have hp:0< improvedRadius d C := by exact div_pos he.1 hden
  have hh:1≤64*((d:ℝ)+1)*((C:ℝ)+1) := by nlinarith [mul_nonneg hd0 hc0]
  have hd:(d:ℝ)+1≤64*((d:ℝ)+1)*((C:ℝ)+1) := by nlinarith [mul_nonneg hd0 hc0]
  have hc:(C:ℝ)+1≤64*((d:ℝ)+1)*((C:ℝ)+1) := by nlinarith [mul_nonneg hd0 hc0]
  exact ⟨hp,by nlinarith [mul_le_mul_of_nonneg_left hh hp.le],
    by nlinarith [mul_le_mul_of_nonneg_left hd hp.le],
    by nlinarith [mul_le_mul_of_nonneg_left hc hp.le]⟩

theorem improvedGain_bounds {C:ℕ} (r:ℕ) (hC:0<C):
    64≤ improvedGain C r ∧ 64*sharpBulkBound r≤ improvedGain C r ∧
    2*Real.exp (-improvedGain C r/2)≤ improvedError C/8 := by
  have hc:(1:ℝ)≤C := by exact_mod_cast hC
  have hs:1≤Real.sqrt C := by simpa using Real.sqrt_le_sqrt hc
  have hsp:0<Real.sqrt C := by linarith
  have hl:0≤Real.log (1024*Real.sqrt C) := Real.log_nonneg (by nlinarith)
  have hb:=sharpBulkBound_nonneg r
  have ha:64≤ improvedGain C r := by unfold improvedGain;linarith
  have hab:64*sharpBulkBound r≤ improvedGain C r := by unfold improvedGain;linarith
  refine ⟨ha,hab,?_⟩
  have harg:0<1024*Real.sqrt C := by positivity
  have hg:-improvedGain C r/2≤ -Real.log (1024*Real.sqrt C) := by unfold improvedGain;linarith
  have he:=Real.exp_le_exp.mpr hg
  rw [Real.exp_neg,Real.exp_log harg] at he
  have heq:2*(1024*Real.sqrt C)⁻¹=improvedError C/8 := by unfold improvedError;field_simp <;> norm_num
  rw [←heq]
  exact mul_le_mul_of_nonneg_left he (by norm_num)

theorem exponential_contraction_of_bounds {ε τ A β ρ G s:ℝ}
    (hε:0≤ε) (hε1:ε≤1) (hτ:0≤τ) (hτsmall:τ≤ε/8)
    (hs:0≤s) (hssmall:s≤ε/8) (hA:64≤A)
    (hβ:0≤β) (hβA:64*β≤A) (hρG:0≤ρ^2*G) (hρsmall:ρ^2*G≤ε^2):
    3*(s^2+(8/A)^2*(4*ρ^2*G*(1+ε^2)+2*β^2*ε^2)+τ^2)≤ε^2 := by
  have hAp:0<A := by linarith
  have h8:8/A≤1/8 := by apply (div_le_iff₀ hAp).mpr;nlinarith
  have h8β:8*β/A≤1/8 := by apply (div_le_iff₀ hAp).mpr;nlinarith
  have hs2: s^2≤(ε/8)^2 := (sq_le_sq₀ hs (by positivity)).mpr hssmall
  have hτ2:τ^2≤(ε/8)^2 := (sq_le_sq₀ hτ (by positivity)).mpr hτsmall
  have h8sq: (8/A)^2≤(1/8:ℝ)^2 := (sq_le_sq₀ (by positivity) (by norm_num)).mpr h8
  have hβsq: (8*β/A)^2≤(1/8:ℝ)^2 := (sq_le_sq₀ (by positivity) (by norm_num)).mpr h8β
  have he2:ε^2≤1 := by nlinarith
  have hr:4*ρ^2*G*(1+ε^2)≤8*ε^2 := by
    have hh:=mul_le_mul hρsmall (show 1+ε^2≤2 by linarith) (by positivity) (sq_nonneg ε)
    nlinarith
  have hr0:0≤4*ρ^2*G*(1+ε^2) := by nlinarith [mul_nonneg hρG (by positivity : 0≤1+ε^2)]
  have hrr:=mul_le_mul h8sq hr hr0 (by norm_num : (0:ℝ)≤(1/8)^2)
  have hbb:=mul_le_mul_of_nonneg_right hβsq (show 0≤2*ε^2 by positivity)
  have heq:(8/A)^2*(2*β^2*ε^2)=(8*β/A)^2*(2*ε^2) := by ring
  rw [←heq] at hbb
  nlinarith

theorem improved_parameter_conditions (d r:ℕ) {C:ℕ} (hC:0<C) {c:ℝ} (hc:0<c):
    let ε:=improvedError C
    let τ:=improvedNoise C
    let A:=improvedGain C r
    let a:=improvedReadout c
    let ρ:=improvedRadius d C
    0<A ∧ 0≤a ∧ 0≤ε ∧ ε≤1 ∧ 0≤τ ∧ 0≤ρ ∧ ρ≤a/2 ∧
    ((d:ℝ)+1)*ρ≤A/2 ∧ 2*(C:ℝ)*ε^2≤(1/16:ℝ)^2 ∧
    3*((2*Real.exp (-A/2))^2+τ^2)≤ε^2 ∧
    3*((2*Real.exp (-A/2))^2+(8/A)^2*(4*ρ^2*((C:ℝ)+1)*(1+ε^2)+
      2*(sharpBulkBound r)^2*ε^2)+τ^2)≤ε^2 ∧
    1<15*a/16-2*ρ-τ ∧ 2*c≤τ*a*Real.sqrt C := by
  dsimp
  obtain ⟨he,he64⟩:=improvedError_bounds hC
  obtain ⟨hr,hrE,hrd,hrC⟩:=improvedRadius_bounds d hC
  obtain ⟨hA,hAb,hAe⟩:=improvedGain_bounds r hC
  have hτ:0≤ improvedNoise C := by unfold improvedNoise;positivity
  have ha:4≤ improvedReadout c := by unfold improvedReadout;linarith
  have he1:improvedError C≤1 := by linarith
  have hρsq:(improvedRadius d C)^2*((C:ℝ)+1)≤(improvedError C)^2 := by
    have hh:=mul_le_mul hrC hrE hr.le he.le
    nlinarith
  have hδsq:(2*Real.exp (-improvedGain C r/2))^2≤(improvedError C/8)^2 :=
    (sq_le_sq₀ (by positivity) (by positivity)).mpr hAe
  refine ⟨by linarith,by linarith,he.le,he1,hτ,hr.le,by linarith,by linarith,?_,?_,?_,?_,?_⟩
  · have hCp:(0:ℝ)<C := by exact_mod_cast hC
    have hs:=Real.sq_sqrt hCp.le
    unfold improvedError
    have hsp:0<Real.sqrt C := Real.sqrt_pos.mpr hCp
    field_simp
    nlinarith
  · unfold improvedNoise
    nlinarith
  · exact exponential_contraction_of_bounds he.le he1 hτ le_rfl (by positivity) hAe
      hA (sharpBulkBound_nonneg r) hAb (by positivity) hρsq
  · unfold improvedNoise
    linarith
  · have hCp:(0:ℝ)<C := by exact_mod_cast hC
    have hsp:0<Real.sqrt C := Real.sqrt_pos.mpr hCp
    unfold improvedNoise improvedError improvedReadout
    field_simp
    nlinarith

end NeuralGeneralization.ConcreteModel
