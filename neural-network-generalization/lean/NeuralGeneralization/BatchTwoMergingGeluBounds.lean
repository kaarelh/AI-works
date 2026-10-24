import NeuralGeneralization.BatchTwoMergingGeluMain
import NeuralGeneralization.BatchTwoMergingBounds
import Mathlib.Analysis.Real.Pi.Bounds

/-! # Polynomial bookkeeping for the explicit population-merging bound -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem geluMergingTeacherEnergy_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S) :
    geluMergingTeacherEnergy d C r≤1000*(C:ℝ)*S := by
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hr0 : (0:ℝ)≤r := Nat.cast_nonneg _
  have hcS := mul_le_mul_of_nonneg_right hC1 (by linarith : 0≤S)
  have hrc := mul_le_mul_of_nonneg_right hr (by positivity : (0:ℝ)≤C)
  unfold geluMergingTeacherEnergy
  nlinarith

theorem geluMergingAmplification_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S) :
    unboundedCylinderAmplification (4*geluMergingTeacherEnergy d C r) ((C:ℝ)+1) (2*(16*((r:ℝ)+1)))≤
      25000*(C:ℝ)*S^2 := by
  have hK := geluMergingTeacherEnergy_le hC hS hd hr
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hSsq : S≤S^2 := by nlinarith
  have hrr : ((r:ℝ)+1)^2≤S^2 := by nlinarith [(Nat.cast_nonneg r : (0:ℝ)≤r)]
  have hcs := mul_le_mul_of_nonneg_left hSsq (Nat.cast_nonneg C : (0:ℝ)≤C)
  have hcs2 := mul_le_mul_of_nonneg_right hC1 (sq_nonneg S)
  have hS2 : (1:ℝ)≤S^2 := by nlinarith
  have hc2 := mul_le_mul_of_nonneg_left hS2 (Nat.cast_nonneg C : (0:ℝ)≤C)
  unfold unboundedCylinderAmplification
  nlinarith

theorem geluMergingOutputFactor_log_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) :
    Real.log (geluCylinderOutputFactor d r (geluMergingTeacherEnergy d C r) ((C:ℝ)+1)
      (16*((r:ℝ)+1))+1)≤40000*S^2 := by
  let K := geluMergingTeacherEnergy d C r
  let A := unboundedCylinderAmplification (4*K) ((C:ℝ)+1) (2*(16*((r:ℝ)+1)))
  let D := cylinderInputFactor d
  have hK0 : 0≤K := by dsimp [K,geluMergingTeacherEnergy]; positivity
  have hA1 : 1≤A := by
    have hh : 0≤4*(4*K+(2*(16*((r:ℝ)+1)))^2+((C:ℝ)+1))+4*((C:ℝ)+1) := by positivity
    dsimp [A,unboundedCylinderAmplification]
    linarith
  have hD1 : 1≤D := by dsimp [D,cylinderInputFactor]; nlinarith [sq_nonneg ((d:ℝ)+1)]
  have hpow : 1≤A^r := one_le_pow₀ hA1
  have hprod : 1≤(4*K+1)*D*A^r := one_le_mul_of_one_le_of_one_le (one_le_mul_of_one_le_of_one_le (by linarith) hD1) hpow
  have hF0 : 0<geluCylinderOutputFactor d r K ((C:ℝ)+1) (16*((r:ℝ)+1))+1 := by
    unfold geluCylinderOutputFactor unboundedCylinderOutputFactor unboundedCylinderAmplification cylinderInputFactor
    positivity
  have hF : geluCylinderOutputFactor d r K ((C:ℝ)+1) (16*((r:ℝ)+1))+1≤
      25*(4*K+1)*D*A^r := by
    change 4*(3*(4*K+1)*D*A^r+3)+1≤_
    nlinarith
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hS1 : 1≤S := by linarith
  have hK : 4*K+1≤4001*(C:ℝ)*S := by
    have hh := geluMergingTeacherEnergy_le hC hS hd hr
    have hcS := mul_le_mul_of_nonneg_right hC1 (by linarith : 0≤S)
    dsimp [K]
    nlinarith
  have hlK := log_le_of_monomial_bound 1 (by linarith : 0<4*K+1)
    (by norm_num : (1:ℝ)≤4001) hC1 hS1 hlogC (by simpa using hK)
  have hAA := geluMergingAmplification_le hC hS hd hr
  have hlA := log_le_of_monomial_bound 2 (by linarith : 0<A)
    (by norm_num : (1:ℝ)≤25000) hC1 hS1 hlogC hAA
  have hDD : D≤2*(C:ℝ)*S^2 := by
    have hh := cylinderInputFactor_le hS hd
    have hc := mul_le_mul_of_nonneg_right hC1 (sq_nonneg S)
    dsimp [D]
    nlinarith
  have hlD := log_le_of_monomial_bound 2 (by linarith : 0<D)
    (by norm_num : (1:ℝ)≤2) hC1 hS1 hlogC hDD
  have hl := Real.log_le_log hF0 hF
  rw [Real.log_mul (by positivity : (25*(4*K+1)*D)≠0) (by positivity : A^r≠0),
    Real.log_mul (by positivity : (25*(4*K+1))≠0) (by positivity : D≠0),
    Real.log_mul (by norm_num : (25:ℝ)≠0) (by positivity : 4*K+1≠0),Real.log_pow] at hl
  have hl7 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<25)
  have hmul := mul_le_mul_of_nonneg_left hlA (Nat.cast_nonneg r : (0:ℝ)≤r)
  have hrs := mul_le_mul_of_nonneg_right hr (by linarith : 0≤S)
  change Real.log (geluCylinderOutputFactor d r K ((C:ℝ)+1) (16*((r:ℝ)+1))+1)≤_
  norm_num only [Nat.cast_ofNat] at hlK hlA hlD
  nlinarith


theorem geluMergingRadius_log_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) :
    |Real.log (2*geluMergingCylinderRadius d r (geluMergingTeacherEnergy d C r) ((C:ℝ)+1)/
      Real.sqrt (2*Real.pi))|≤50000*S^2 := by
  have hK : 0≤geluMergingTeacherEnergy d C r := by unfold geluMergingTeacherEnergy; positivity
  have hG : (0:ℝ)≤C+1 := by positivity
  obtain ⟨hρ,hρ16,_⟩ := geluMergingCylinderRadius_bounds (d:=d) (r:=r) hK hG
  let ρ := geluMergingCylinderRadius d r (geluMergingTeacherEnergy d C r) ((C:ℝ)+1)
  have hρ1 : ρ≤1 := by dsimp [ρ]; linarith
  have hlρ : Real.log ρ≤0 := Real.log_nonpos hρ.le hρ1
  have hlog := geluMergingOutputFactor_log_le hC hS hd hr hlogC
  have he : -Real.log ρ = Real.log 16+
      Real.log (geluCylinderOutputFactor d r (geluMergingTeacherEnergy d C r) ((C:ℝ)+1)
        (16*((r:ℝ)+1))+1) := by
    dsimp [ρ,geluMergingCylinderRadius]
    rw [Real.log_div (by norm_num) (by unfold geluCylinderOutputFactor unboundedCylinderOutputFactor unboundedCylinderAmplification cylinderInputFactor; positivity),Real.log_one,
      Real.log_mul (by norm_num) (by unfold geluCylinderOutputFactor unboundedCylinderOutputFactor unboundedCylinderAmplification cylinderInputFactor; positivity)]
    ring
  have hl16 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<16)
  have hprod : 2*ρ/Real.sqrt (2*Real.pi)=(2/Real.sqrt (2*Real.pi))*ρ := by ring
  change |Real.log (2*ρ/Real.sqrt (2*Real.pi))|≤_
  rw [hprod,Real.log_mul (by positivity) hρ.ne']
  have habs := abs_add_le (Real.log (2/Real.sqrt (2*Real.pi))) (Real.log ρ)
  rw [abs_of_nonpos hlρ] at habs
  have hbase := gaussian_log_normalization_abs_le
  nlinarith

theorem geluMergingTargetCost_le {d C r : ℕ} {S : ℝ}
    (hC : 0<C) (hS : 2≤S) (hd : (d:ℝ)+2≤S) (hr : (r:ℝ)+2≤S)
    (hlogC : Real.log (C:ℝ)≤2*S) :
    geluMergingTargetCost d C r≤200000*(C:ℝ)*S^3 := by
  have hC1 : (1:ℝ)≤C := by exact_mod_cast hC
  have hC0 : (0:ℝ)≤C := Nat.cast_nonneg _
  have hS0 : 0≤S := by linarith
  have hK := geluMergingTeacherEnergy_le hC hS hd hr
  have hK0 : 0≤geluMergingTeacherEnergy d C r := by unfold geluMergingTeacherEnergy; positivity
  have hG0 : (0:ℝ)≤C+1 := by positivity
  obtain ⟨hρ,hρ16,_⟩ := geluMergingCylinderRadius_bounds (d:=d) (r:=r) hK0 hG0
  have hρsq : (geluMergingCylinderRadius d r (geluMergingTeacherEnergy d C r) ((C:ℝ)+1))^2≤1 := by nlinarith
  have hl := geluMergingRadius_log_le hC hS hd hr hlogC
  have hq : (d:ℝ)+2+(r:ℝ)*((C:ℝ)+1)≤3*(C:ℝ)*S := by
    have hrs := mul_le_mul_of_nonneg_right hr (by positivity : (0:ℝ)≤C+1)
    have hcs := mul_le_mul_of_nonneg_right hC1 hS0
    nlinarith
  have hmul := mul_le_mul hq (add_le_add hρsq hl)
    (by positivity : 0≤(geluMergingCylinderRadius d r (geluMergingTeacherEnergy d C r) ((C:ℝ)+1))^2+
      |Real.log (2*geluMergingCylinderRadius d r (geluMergingTeacherEnergy d C r) ((C:ℝ)+1)/Real.sqrt (2*Real.pi))|)
    (by positivity : 0≤3*(C:ℝ)*S)
  have hS3 : S≤S^3 := by nlinarith [sq_nonneg (S-1)]
  have hcs3 := mul_le_mul_of_nonneg_left hS3 hC0
  have hcS := mul_le_mul_of_nonneg_right hC1 hS0
  unfold geluMergingTargetCost mergingCylinderCost
  nlinarith

end NeuralGeneralization.BatchTwoMerging
