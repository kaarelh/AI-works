import NeuralGeneralization.BatchTwoOnlineTanhTarget
import NeuralGeneralization.BatchTwoMergingBounds

/-! A target-cost envelope linear in teacher width and polynomial in depth and logarithmic width. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoOnlineTanhMerging
open ConcreteModel BatchTwoMerging

theorem tanh_parameters_le {C r : ℕ} (hC : 0<C) {c S : ℝ}
    (hc : 0≤c) (hS : 10000000000≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤S/4) (hcS : 4100*(c+1)≤S) :
    0≤ improvedGain C r ∧ improvedGain C r≤S ∧
    0≤ improvedReadout c ∧ improvedReadout c≤S ∧ sharpBulkBound r≤S := by
  have hS0 : 0≤S := by linarith
  have hb0 := sharpBulkBound_nonneg r
  have hb : (sharpBulkBound r)^2≤32*(r:ℝ)+184 := by
    rw [sharpBulkBound_sq]
    have h1 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<9)
    have h2 := Real.log_le_sub_one_of_pos (show 0<4*((r:ℝ)+2) by positivity)
    nlinarith
  have hbS : sharpBulkBound r≤S/512 := by
    apply (sq_le_sq₀ hb0 (by positivity)).mp
    nlinarith [mul_nonneg hS0 (sub_nonneg.mpr hS)]
  have hCp : (0:ℝ)<C := by exact_mod_cast hC
  have hl : Real.log (1024*Real.sqrt C)≤1023+S/8 := by
    rw [Real.log_mul (by norm_num) (Real.sqrt_pos.mpr hCp).ne',Real.log_sqrt hCp.le]
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<1024)
    linarith
  have hA0 : 0≤ improvedGain C r := by linarith [(improvedGain_bounds r hC).1]
  refine ⟨hA0,?_,?_,?_,by linarith⟩
  · unfold improvedGain
    linarith
  · unfold improvedReadout
    positivity
  · unfold improvedReadout
    linarith

theorem tanh_teacher_cost_le {d C r : ℕ} (hC : 0<C) {c S : ℝ}
    (hc : 0≤c) (hS : 10000000000≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤S/4) (hcS : 4100*(c+1)≤S) :
    improvedTeacherCost d C r c≤31*(C:ℝ)*S^3 := by
  obtain ⟨hA0,hA,ha0,ha,_⟩ := tanh_parameters_le hC hc hS hr hlogC hcS
  have hS0 : 0≤S := by linarith
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hA2 := (sq_le_sq₀ hA0 hS0).mpr hA
  have ha2 := (sq_le_sq₀ ha0 hS0).mpr ha
  have hdA := mul_le_mul (show (d:ℝ)≤S by linarith) hA2 (sq_nonneg _) hS0
  have hrA := mul_le_mul (show (r:ℝ)≤S by linarith) hA2 (sq_nonneg _) hS0
  have hrCA := mul_le_mul_of_nonneg_left hrA (Nat.cast_nonneg C : (0:ℝ)≤C)
  have hCa := mul_le_mul_of_nonneg_left ha2 (Nat.cast_nonneg C : (0:ℝ)≤C)
  have hCS3 := mul_le_mul_of_nonneg_right hC1 (pow_nonneg hS0 3)
  have hS23 : S^2≤S^3 := by nlinarith [mul_nonneg (sq_nonneg S) (show 0≤S-1 by linarith)]
  have hCS23 := mul_le_mul_of_nonneg_left hS23 (Nat.cast_nonneg C : (0:ℝ)≤C)
  unfold improvedTeacherCost
  nlinarith

theorem tanh_merge_radius_log_le {d C r : ℕ} (hC : 0<C) {c S : ℝ}
    (hc : 0≤c) (hS : 10000000000≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤S/4) (hcS : 4100*(c+1)≤S) :
    -Real.log (tanhMergeRadius d C r c)≤5000*S^2 := by
  obtain ⟨hA0,hA,ha0,ha,hbulk⟩ := tanh_parameters_le hC hc hS hr hlogC hcS
  have hS1 : 1≤S := by linarith
  have hS0 : 0≤S := by linarith
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hCp : (0:ℝ)<C := by exact_mod_cast hC
  have hC0 := hCp.le
  have hA2 := (sq_le_sq₀ hA0 hS0).mpr hA
  have ha2 := (sq_le_sq₀ ha0 hS0).mpr ha
  have hSsq : 1≤S^2 := one_le_pow₀ hS1
  have hS12 : S≤S^2 := by nlinarith
  have hκ : tanhMergeKappa C r c≤21*S^2 := by unfold tanhMergeKappa; nlinarith
  let G : ℝ := (C:ℝ)+1
  let K := tanhMergeKappa C r c
  let R := Real.sqrt (K*G)
  let U := sharpInputBudget 1 d r G
  let A := sharpAmplification 1 K G (sharpBulkBound r)
  have hK : 1≤K := tanhMergeKappa_one_le C r c
  have hG : 1≤G := by dsimp [G]; linarith
  have hKG : 1≤K*G := one_le_mul_of_one_le_of_one_le hK hG
  have hR1 : 1≤R := by simpa [R] using Real.sqrt_le_sqrt hKG
  have hR : R≤42*(C:ℝ)*S^2 := by
    have hs : Real.sqrt (K*G)≤K*G := by
      nlinarith [Real.sq_sqrt (show 0≤K*G by positivity),Real.sqrt_nonneg (K*G)]
    have hh := mul_le_mul hκ (show G≤2*(C:ℝ) by dsimp [G]; linarith) (by positivity : 0≤G)
      (by positivity : 0≤21*S^2)
    dsimp [R,K] at *
    nlinarith
  have hrootG : Real.sqrt G≤2*(C:ℝ) := by
    have hg0 : 0≤G := by linarith
    nlinarith [Real.sq_sqrt hg0,Real.sqrt_nonneg G]
  have hU0 : 0<U := by dsimp [U,sharpInputBudget]; positivity
  have hU : U≤3*(C:ℝ)*S := by
    have hh := mul_le_mul (show (r:ℝ)+1≤S by linarith) hrootG (Real.sqrt_nonneg G) hS0
    have hcS := mul_le_mul_of_nonneg_right hC1 hS0
    dsimp [U,sharpInputBudget]
    nlinarith
  have hA1 : 1≤A := (sharpRadius_control d r (by norm_num : (1:ℝ)≤1) hK hG
    (sharpBulkBound_nonneg r)).2.2.1
  have hAb : A≤90*(C:ℝ)*S^2 := by
    have hcS := mul_le_mul_of_nonneg_right hC1 (sq_nonneg S)
    dsimp [A,sharpAmplification]
    change R≤_ at hR
    nlinarith
  have hlR := log_le_of_monomial_bound 2 (by linarith : 0<R) (by norm_num : (1:ℝ)≤42)
    hC1 hS1 (by linarith : Real.log (C:ℝ)≤2*S) hR
  have hlU := log_le_of_monomial_bound 1 hU0 (by norm_num : (1:ℝ)≤3)
    hC1 hS1 (by linarith : Real.log (C:ℝ)≤2*S) (by simpa using hU)
  have hlA := log_le_of_monomial_bound 2 (by linarith : 0<A) (by norm_num : (1:ℝ)≤90)
    hC1 hS1 (by linarith : Real.log (C:ℝ)≤2*S) hAb
  norm_num only [Nat.cast_ofNat] at hlR hlU hlA
  have hlA0 : 0≤Real.log A := Real.log_nonneg hA1
  have hmul := mul_le_mul (show (r:ℝ)+1≤S by linarith) hlA hlA0 hS0
  have hden : 0<256*R*U*A^(r+1) := by positivity
  have hsharp : -Real.log (sharpRadius 1 K G (sharpBulkBound r) d r)≤500*S^2 := by
    unfold sharpRadius
    change -Real.log (min (1/16) (1/(256*R*U*A^(r+1))))≤_
    rw [min_def]
    split_ifs with hh
    · have hl16 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<16)
      rw [one_div,Real.log_inv]
      nlinarith
    · rw [one_div,Real.log_inv,neg_neg,
        Real.log_mul (by positivity : 256*R*U≠0) (by positivity : A^(r+1)≠0),
        Real.log_mul (by positivity : 256*R≠0) hU0.ne',
        Real.log_mul (by norm_num : (256:ℝ)≠0) (show R≠0 by linarith),Real.log_pow]
      have hl256 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<256)
      push_cast
      nlinarith
  have hi : -Real.log (improvedRadius d C)≤5000*S := by
    have he : improvedRadius d C=(4096*Real.sqrt C*((d:ℝ)+1)*((C:ℝ)+1))⁻¹ := by
      unfold improvedRadius improvedError
      field_simp <;> ring
    rw [he,Real.log_inv,neg_neg,
      Real.log_mul (by positivity : 4096*Real.sqrt C*((d:ℝ)+1)≠0) (by positivity : (C:ℝ)+1≠0),
      Real.log_mul (by positivity : 4096*Real.sqrt C≠0) (by positivity : (d:ℝ)+1≠0),
      Real.log_mul (by norm_num : (4096:ℝ)≠0) (Real.sqrt_pos.mpr hCp).ne',Real.log_sqrt hC0]
    have hl4096 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<4096)
    have hld := Real.log_le_sub_one_of_pos (show (0:ℝ)<d+1 by positivity)
    have hlC : Real.log ((C:ℝ)+1)≤Real.log 2+Real.log (C:ℝ) := by
      rw [←Real.log_mul (by norm_num) hCp.ne']
      exact Real.log_le_log (by positivity) (by linarith)
    have hl2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    linarith
  unfold tanhMergeRadius
  rw [min_def]
  split_ifs
  · exact hi.trans (by nlinarith)
  · exact hsharp.trans (by nlinarith)

theorem tanhMergeTargetCost_le {d C r : ℕ} (hC : 0<C) {c S : ℝ}
    (hc : 0≤c) (hS : 10000000000≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤S/4) (hcS : 4100*(c+1)≤S) :
    tanhMergeTargetCost d C r c≤200000*(C:ℝ)*S^3 := by
  have hK := tanh_teacher_cost_le hC hc hS hd hr hlogC hcS
  have hlρ := tanh_merge_radius_log_le hC hc hS hd hr hlogC hcS
  have hρ := (tanhMergeRadius_bounds d r hC c).1
  have hroot : 0<Real.sqrt (2*Real.pi) := by positivity
  have hroot3 : Real.sqrt (2*Real.pi)≤3 := by
    nlinarith [Real.sq_sqrt (show 0≤2*Real.pi by positivity),Real.pi_lt_four,Real.sqrt_nonneg (2*Real.pi)]
  have hl : Real.log (Real.exp 1*Real.sqrt (2*Real.pi)/(2*tanhMergeRadius d C r c))≤6000*S^2 := by
    rw [Real.log_div (by positivity) (by positivity),Real.log_mul (Real.exp_ne_zero _) hroot.ne',
      Real.log_mul (by norm_num) hρ.ne',Real.log_exp]
    have hrootlog := Real.log_le_sub_one_of_pos hroot
    have hl2 := Real.log_nonneg (by norm_num : (1:ℝ)≤2)
    nlinarith [sq_nonneg (S-1)]
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hS0 : 0≤S := by linarith
  have hq : (d:ℝ)+2+(r:ℝ)*((C:ℝ)+1)≤3*(C:ℝ)*S := by
    have hh := mul_le_mul (show (r:ℝ)≤S by linarith) (show (C:ℝ)+1≤2*(C:ℝ) by linarith)
      (by positivity : (0:ℝ)≤C+1) hS0
    have hCS := mul_le_mul_of_nonneg_right hC1 hS0
    nlinarith
  have hprod := mul_le_mul_of_nonneg_left hl (show 0≤(d:ℝ)+2+(r:ℝ)*((C:ℝ)+1) by positivity)
  have hprod' := mul_le_mul_of_nonneg_right hq (show 0≤6000*S^2 by positivity)
  have hl2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  have hS3 : 1≤S^3 := one_le_pow₀ (by linarith)
  have hCS3 := mul_le_mul_of_nonneg_right hC1 (pow_nonneg hS0 3)
  unfold tanhMergeTargetCost sharpCylinderCost
  nlinarith

end NeuralGeneralization.BatchTwoOnlineTanhMerging
