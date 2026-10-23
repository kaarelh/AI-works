import NeuralGeneralization.BatchTwoMergingMain
import Mathlib.Analysis.Real.Pi.Bounds

/-! # Polynomial bookkeeping for the explicit population-merging bound -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem log_le_of_monomial_bound {a k C S : ℝ} (p : ℕ)
    (ha : 0<a) (hk : 1≤k) (hC : 1≤C) (hS : 1≤S)
    (hlogC : Real.log C≤2*S) (hbound : a≤k*C*S^p) :
    Real.log a≤(k+p+2)*S := by
  have hk0 : 0<k := by linarith
  have hC0 : 0<C := by linarith
  have hS0 : 0<S := by linarith
  have hl := Real.log_le_log ha hbound
  rw [Real.log_mul (mul_ne_zero hk0.ne' hC0.ne') (pow_ne_zero p hS0.ne'),
    Real.log_mul hk0.ne' hC0.ne', Real.log_pow] at hl
  have hkl := Real.log_le_sub_one_of_pos hk0
  have hSl := Real.log_le_sub_one_of_pos hS0
  have hp : (0:ℝ)≤p := Nat.cast_nonneg _
  have hmul := mul_le_mul_of_nonneg_left hSl hp
  have hks := mul_le_mul_of_nonneg_left hS (by linarith : 0≤k)
  nlinarith

theorem mergingTeacherEnergy_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S) :
    mergingTeacherEnergy d C r≤200*(C:ℝ)*S := by
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hr0 : (0:ℝ)≤r := Nat.cast_nonneg _
  have hcS := mul_le_mul_of_nonneg_right hC1 (by linarith : 0≤S)
  have hrc := mul_le_mul_of_nonneg_right hr (by positivity : (0:ℝ)≤C)
  unfold mergingTeacherEnergy
  nlinarith

theorem mergingAmplification_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S) :
    unboundedCylinderAmplification (mergingTeacherEnergy d C r) ((C:ℝ)+1) (16*((r:ℝ)+1))≤
      2000*(C:ℝ)*S^2 := by
  have hK := mergingTeacherEnergy_le hC hS hd hr
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hSsq : S≤S^2 := by nlinarith
  have hrr : ((r:ℝ)+1)^2≤S^2 := by nlinarith [(Nat.cast_nonneg r : (0:ℝ)≤r)]
  have hcs := mul_le_mul_of_nonneg_left hSsq (Nat.cast_nonneg C : (0:ℝ)≤C)
  have hcs2 := mul_le_mul_of_nonneg_right hC1 (sq_nonneg S)
  have hS2 : (1:ℝ)≤S^2 := by nlinarith
  have hc2 := mul_le_mul_of_nonneg_left hS2 (Nat.cast_nonneg C : (0:ℝ)≤C)
  unfold unboundedCylinderAmplification
  nlinarith

theorem cylinderInputFactor_le {d : ℕ} {S : ℝ} (hS : 2≤S) (hd : (d:ℝ)+2≤S) :
    cylinderInputFactor d≤2*S^2 := by
  unfold cylinderInputFactor
  nlinarith [(Nat.cast_nonneg d : (0:ℝ)≤d)]

theorem mergingOutputFactor_log_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) :
    Real.log (unboundedCylinderOutputFactor d r (mergingTeacherEnergy d C r) ((C:ℝ)+1)
      (16*((r:ℝ)+1))+1)≤2300*S^2 := by
  let K := mergingTeacherEnergy d C r
  let A := unboundedCylinderAmplification K ((C:ℝ)+1) (16*((r:ℝ)+1))
  let D := cylinderInputFactor d
  have hK0 : 0≤K := by dsimp [K,mergingTeacherEnergy]; positivity
  have hA1 : 1≤A := by
    have hh : 0≤4*(K+(16*((r:ℝ)+1))^2+((C:ℝ)+1))+4*((C:ℝ)+1) := by positivity
    dsimp [A,unboundedCylinderAmplification]
    linarith
  have hD1 : 1≤D := by dsimp [D,cylinderInputFactor]; nlinarith [sq_nonneg ((d:ℝ)+1)]
  have hpow : 1≤A^r := one_le_pow₀ hA1
  have hprod : 1≤(K+1)*D*A^r := one_le_mul_of_one_le_of_one_le (one_le_mul_of_one_le_of_one_le (by linarith) hD1) hpow
  have hF0 : 0<unboundedCylinderOutputFactor d r K ((C:ℝ)+1) (16*((r:ℝ)+1))+1 := by
    unfold unboundedCylinderOutputFactor
    positivity
  have hF : unboundedCylinderOutputFactor d r K ((C:ℝ)+1) (16*((r:ℝ)+1))+1≤
      7*(K+1)*D*A^r := by
    change 3*(K+1)*D*A^r+3+1≤_
    nlinarith
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hS1 : 1≤S := by linarith
  have hK : K+1≤201*(C:ℝ)*S := by
    have hh := mergingTeacherEnergy_le hC hS hd hr
    have hcS := mul_le_mul_of_nonneg_right hC1 (by linarith : 0≤S)
    dsimp [K]
    nlinarith
  have hlK := log_le_of_monomial_bound 1 (by linarith : 0<K+1)
    (by norm_num : (1:ℝ)≤201) hC1 hS1 hlogC (by simpa using hK)
  have hAA := mergingAmplification_le hC hS hd hr
  have hlA := log_le_of_monomial_bound 2 (by linarith : 0<A)
    (by norm_num : (1:ℝ)≤2000) hC1 hS1 hlogC hAA
  have hDD : D≤2*(C:ℝ)*S^2 := by
    have hh := cylinderInputFactor_le hS hd
    have hc := mul_le_mul_of_nonneg_right hC1 (sq_nonneg S)
    dsimp [D]
    nlinarith
  have hlD := log_le_of_monomial_bound 2 (by linarith : 0<D)
    (by norm_num : (1:ℝ)≤2) hC1 hS1 hlogC hDD
  have hl := Real.log_le_log hF0 hF
  rw [Real.log_mul (by positivity : (7*(K+1)*D)≠0) (by positivity : A^r≠0),
    Real.log_mul (by positivity : (7*(K+1))≠0) (by positivity : D≠0),
    Real.log_mul (by norm_num : (7:ℝ)≠0) (by positivity : K+1≠0),Real.log_pow] at hl
  have hl7 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<7)
  have hmul := mul_le_mul_of_nonneg_left hlA (Nat.cast_nonneg r : (0:ℝ)≤r)
  have hrs := mul_le_mul_of_nonneg_right hr (by linarith : 0≤S)
  change Real.log (unboundedCylinderOutputFactor d r K ((C:ℝ)+1) (16*((r:ℝ)+1))+1)≤_
  norm_num only [Nat.cast_ofNat] at hlK hlA hlD
  nlinarith


theorem gaussian_log_normalization_abs_le :
    |Real.log (2/Real.sqrt (2*Real.pi))|≤4 := by
  have hspos : 0<Real.sqrt (2*Real.pi) := by positivity
  have hs2 := Real.sq_sqrt (show 0≤2*Real.pi by positivity)
  have hslow : 1≤Real.sqrt (2*Real.pi) := by nlinarith [Real.two_le_pi]
  have hsup : Real.sqrt (2*Real.pi)≤3 := by nlinarith [Real.pi_lt_four,Real.sqrt_nonneg (2*Real.pi)]
  rw [Real.log_div (by norm_num) hspos.ne']
  have hl2 := Real.log_nonneg (by norm_num : (1:ℝ)≤2)
  have hu2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  have hls := Real.log_nonneg hslow
  have hus := Real.log_le_sub_one_of_pos hspos
  exact abs_le.mpr ⟨by linarith,by linarith⟩

theorem mergingRadius_log_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) :
    |Real.log (2*mergingCylinderRadius d r (mergingTeacherEnergy d C r) ((C:ℝ)+1)/
      Real.sqrt (2*Real.pi))|≤2400*S^2 := by
  have hK : 0≤mergingTeacherEnergy d C r := by unfold mergingTeacherEnergy; positivity
  have hG : (0:ℝ)≤C+1 := by positivity
  obtain ⟨hρ,hρ16,_⟩ := mergingCylinderRadius_bounds (d:=d) (r:=r) hK hG
  let ρ := mergingCylinderRadius d r (mergingTeacherEnergy d C r) ((C:ℝ)+1)
  have hρ1 : ρ≤1 := by dsimp [ρ]; linarith
  have hlρ : Real.log ρ≤0 := Real.log_nonpos hρ.le hρ1
  have hlog := mergingOutputFactor_log_le hC hS hd hr hlogC
  have he : -Real.log ρ = Real.log 16+
      Real.log (unboundedCylinderOutputFactor d r (mergingTeacherEnergy d C r) ((C:ℝ)+1)
        (16*((r:ℝ)+1))+1) := by
    dsimp [ρ,mergingCylinderRadius]
    rw [Real.log_div (by norm_num) (by unfold unboundedCylinderOutputFactor unboundedCylinderAmplification cylinderInputFactor; positivity),Real.log_one,
      Real.log_mul (by norm_num) (by unfold unboundedCylinderOutputFactor unboundedCylinderAmplification cylinderInputFactor; positivity)]
    ring
  have hl16 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<16)
  have hprod : 2*ρ/Real.sqrt (2*Real.pi)=(2/Real.sqrt (2*Real.pi))*ρ := by ring
  change |Real.log (2*ρ/Real.sqrt (2*Real.pi))|≤_
  rw [hprod,Real.log_mul (by positivity) hρ.ne']
  have habs := abs_add_le (Real.log (2/Real.sqrt (2*Real.pi))) (Real.log ρ)
  rw [abs_of_nonpos hlρ] at habs
  have hbase := gaussian_log_normalization_abs_le
  nlinarith

theorem mergingTargetCost_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) :
    mergingTargetCost d C r≤10000*(C:ℝ)*S^3 := by
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hC0 : (0:ℝ)≤C := Nat.cast_nonneg _
  have hS0 : 0≤S := by linarith
  have hK := mergingTeacherEnergy_le hC hS hd hr
  have hK0 : 0≤mergingTeacherEnergy d C r := by unfold mergingTeacherEnergy; positivity
  have hG0 : (0:ℝ)≤C+1 := by positivity
  obtain ⟨hρ,hρ16,_⟩ := mergingCylinderRadius_bounds (d:=d) (r:=r) hK0 hG0
  have hρsq : (mergingCylinderRadius d r (mergingTeacherEnergy d C r) ((C:ℝ)+1))^2≤1 := by nlinarith
  have hl := mergingRadius_log_le hC hS hd hr hlogC
  have hq : (d:ℝ)+2+(r:ℝ)*((C:ℝ)+1)≤3*(C:ℝ)*S := by
    have hrs := mul_le_mul_of_nonneg_right hr (by positivity : (0:ℝ)≤C+1)
    have hcs := mul_le_mul_of_nonneg_right hC1 hS0
    nlinarith
  have hmul := mul_le_mul hq (add_le_add hρsq hl)
    (by positivity : 0≤(mergingCylinderRadius d r (mergingTeacherEnergy d C r) ((C:ℝ)+1))^2+
      |Real.log (2*mergingCylinderRadius d r (mergingTeacherEnergy d C r) ((C:ℝ)+1)/Real.sqrt (2*Real.pi))|)
    (by positivity : 0≤3*(C:ℝ)*S)
  have hS3 : S≤S^3 := by nlinarith [sq_nonneg (S-1)]
  have hcs3 := mul_le_mul_of_nonneg_left hS3 hC0
  have hcS := mul_le_mul_of_nonneg_right hC1 hS0
  unfold mergingTargetCost mergingCylinderCost
  nlinarith

end NeuralGeneralization.BatchTwoMerging
