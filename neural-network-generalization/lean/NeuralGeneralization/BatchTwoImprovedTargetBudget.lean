import NeuralGeneralization.BatchTwoImprovedTargetMain

/-! A universal cubic envelope for the improved target cylinder cost. -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel
open NeuralGeneralization.BatchTwoMerging

private theorem log_scaled_sqrt_sq {C:ℕ} (hC:0<C):
    (Real.log (1024*Real.sqrt C))^2≤1050625*(C:ℝ) := by
  have hc:(1:ℝ)≤C := by exact_mod_cast hC
  have hs:1≤Real.sqrt C := by simpa using Real.sqrt_le_sqrt hc
  have hsp:0<Real.sqrt C := by linarith
  have hl0:0≤Real.log (1024*Real.sqrt C) := Real.log_nonneg (by nlinarith)
  have hl:Real.log (1024*Real.sqrt C)≤1025*Real.sqrt C := by
    rw [Real.log_mul (by norm_num) hsp.ne']
    have h1:=Real.log_le_sub_one_of_pos (show (0:ℝ)<1024 by norm_num)
    have h2:=Real.log_le_sub_one_of_pos hsp
    nlinarith
  have hh:=(sq_le_sq₀ hl0 (by positivity)).mpr hl
  nlinarith [Real.sq_sqrt (show (0:ℝ)≤C by positivity)]

private theorem sharpBulkBound_sq_coarse (r:ℕ):
    (sharpBulkBound r)^2≤32*(r:ℝ)+184 := by
  have h9:0≤Real.log (9:ℝ) := Real.log_nonneg (by norm_num)
  have harg:1≤4*((r:ℝ)+2) := by nlinarith [Nat.cast_nonneg (α:=ℝ) r]
  have hl:0≤Real.log (4*((r:ℝ)+2)) := Real.log_nonneg harg
  have h1:=Real.log_le_sub_one_of_pos (show (0:ℝ)<9 by norm_num)
  have h2:=Real.log_le_sub_one_of_pos (show 0<4*((r:ℝ)+2) by positivity)
  unfold sharpBulkBound
  rw [Real.sq_sqrt (by positivity)]
  nlinarith

theorem improvedGain_sq_budget {C r:ℕ} (hC:0<C) {S:ℝ}
    (hS:1≤S) (hCS:(C:ℝ)≤S) (hrS:(r:ℝ)≤S):
    (improvedGain C r)^2≤(67108864:ℝ)*S := by
  have hb0:=sharpBulkBound_nonneg r
  have hb:=sharpBulkBound_sq_coarse r
  have hl:=log_scaled_sqrt_sq hC
  have hs:(sharpBulkBound r+1)^2≤64*(r:ℝ)+370 := by nlinarith [sq_nonneg (sharpBulkBound r-1)]
  have hsum:(128*(sharpBulkBound r+1)+2*Real.log (1024*Real.sqrt C))^2≤
      32768*(sharpBulkBound r+1)^2+8*(Real.log (1024*Real.sqrt C))^2 := by
    nlinarith [sq_nonneg (128*(sharpBulkBound r+1)-2*Real.log (1024*Real.sqrt C))]
  unfold improvedGain
  nlinarith

theorem improvedTeacherCost_budget {d C r:ℕ} (hC:0<C) {c S:ℝ}
    (hc:0≤c) (hS:1≤S) (hdS:(d:ℝ)≤S) (hCS:(C:ℝ)≤S)
    (hrS:(r:ℝ)≤S) (hcS:c≤S):
    improvedTeacherCost d C r c≤(2000000000:ℝ)*S^3 := by
  have hS0:0≤S := by linarith
  have hA:=improvedGain_sq_budget hC hS hCS hrS
  have ha0:0≤ improvedReadout c := by unfold improvedReadout;positivity
  have ha:improvedReadout c≤4100*S := by unfold improvedReadout;linarith
  have ha2:improvedReadout c^2≤16810000*S^2 := by
    have hh:=(sq_le_sq₀ ha0 (by positivity)).mpr ha
    nlinarith
  have hdA:=mul_le_mul hdS hA (sq_nonneg (improvedGain C r)) hS0
  have hrC: (r:ℝ)*(C:ℝ)≤S^2 := by nlinarith [mul_le_mul hrS hCS (Nat.cast_nonneg C) hS0]
  have hrCA:=mul_le_mul hrC hA (sq_nonneg (improvedGain C r)) (sq_nonneg S)
  have hCa:=mul_le_mul hCS ha2 (sq_nonneg (improvedReadout c)) hS0
  have hs23:S^2≤S^3 := by nlinarith [sq_nonneg S,mul_nonneg (sq_nonneg S) (show 0≤S-1 by linarith)]
  unfold improvedTeacherCost
  nlinarith

private theorem improved_log_argument_budget {d C:ℕ} (hC:0<C) {S:ℝ}
    (hS:1≤S) (hdS:(d:ℝ)≤S) (hCS:(C:ℝ)≤S):
    Real.log (Real.exp 1*Real.sqrt (2*Real.pi)/(2*improvedRadius d C))≤4096*S := by
  have hc:(1:ℝ)≤C := by exact_mod_cast hC
  have hs:1≤Real.sqrt C := by simpa using Real.sqrt_le_sqrt hc
  have hsp:0<Real.sqrt C := by linarith
  have hroot:0<Real.sqrt (2*Real.pi) := by positivity
  have hroot3:Real.sqrt (2*Real.pi)≤3 := by
    nlinarith [Real.sq_sqrt (show 0≤2*Real.pi by positivity),Real.pi_lt_four,Real.sqrt_nonneg (2*Real.pi)]
  have hsC:Real.sqrt C≤(C:ℝ) := by
    nlinarith [Real.sq_sqrt (show (0:ℝ)≤C by positivity)]
  have he:Real.exp 1*Real.sqrt (2*Real.pi)/(2*improvedRadius d C)=
      Real.exp 1*Real.sqrt (2*Real.pi)*2048*Real.sqrt C*((d:ℝ)+1)*((C:ℝ)+1) := by
    unfold improvedRadius improvedError
    field_simp <;> ring
  rw [he]
  rw [Real.log_mul (by positivity : Real.exp 1*Real.sqrt (2*Real.pi)*2048*Real.sqrt C*((d:ℝ)+1)≠0)
      (by positivity : (C:ℝ)+1≠0),
    Real.log_mul (by positivity : Real.exp 1*Real.sqrt (2*Real.pi)*2048*Real.sqrt C≠0)
      (by positivity : (d:ℝ)+1≠0),
    Real.log_mul (by positivity : Real.exp 1*Real.sqrt (2*Real.pi)*2048≠0) hsp.ne',
    Real.log_mul (by positivity : Real.exp 1*Real.sqrt (2*Real.pi)≠0) (by norm_num : (2048:ℝ)≠0),
    Real.log_mul (Real.exp_ne_zero _) hroot.ne',Real.log_exp]
  have h1:=Real.log_le_sub_one_of_pos hroot
  have h2:=Real.log_le_sub_one_of_pos (show (0:ℝ)<2048 by norm_num)
  have h3:=Real.log_le_sub_one_of_pos hsp
  have h4:=Real.log_le_sub_one_of_pos (show 0<(d:ℝ)+1 by positivity)
  have h5:=Real.log_le_sub_one_of_pos (show 0<(C:ℝ)+1 by positivity)
  linarith

theorem improvedTargetCost_budget {d C r:ℕ} (hC:0<C) {c S:ℝ}
    (hc:0≤c) (hS:1≤S) (hdS:(d:ℝ)≤S) (hCS:(C:ℝ)≤S)
    (hrS:(r:ℝ)≤S) (hcS:c≤S):
    improvedTargetCost d C r c≤(10000000000:ℝ)*S^3 := by
  have hS0:0≤S := by linarith
  have hK:=improvedTeacherCost_budget hC hc hS hdS hCS hrS hcS
  have hl:=improved_log_argument_budget hC hS hdS hCS
  have hq0:0≤(d:ℝ)+2+(r:ℝ)*((C:ℝ)+1) := by positivity
  have hq:(d:ℝ)+2+(r:ℝ)*((C:ℝ)+1)≤5*S^2 := by
    have hh:=mul_le_mul hrS (show (C:ℝ)+1≤S+1 by linarith) (by positivity) hS0
    nlinarith [sq_nonneg (S-1)]
  have hh:=mul_le_mul_of_nonneg_left hl hq0
  have hh2:=mul_le_mul_of_nonneg_right hq (show 0≤4096*S by positivity)
  have hl2:=Real.log_le_sub_one_of_pos (show (0:ℝ)<2 by norm_num)
  have hs3:1≤S^3 := one_le_pow₀ hS
  unfold improvedTargetCost sharpCylinderCost
  nlinarith

end NeuralGeneralization.ConcreteModel
