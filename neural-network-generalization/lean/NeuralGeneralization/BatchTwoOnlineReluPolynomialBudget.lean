import NeuralGeneralization.BatchTwoOnlineReluGrowthBounds
import NeuralGeneralization.BatchTwoOnlineReluBoundedTeacher

/-! Natural polynomial envelopes for the actual finite-variance ReLU capacity. -/
noncomputable section
set_option autoImplicit false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoActivation
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

def reluNatMass (d r k : ℕ) : ℕ :=
  (k+2)^2+(d+r+2)*3*(d+r+3)*(8*(r+2)*(k+2)^(r+1))
def reluNatThreshold (d r k : ℕ) : ℕ := 4*(reluNatMass d r k+(d+r+2)+d)
def reluNatLogCount (d r k : ℕ) : ℕ :=
  (4*(d+1)*(reluNatThreshold d r k)^(r+2)*(2*r+3)^2)*(d+1)
def reluNatTeacherEnergy (d C r : ℕ) : ℕ :=
  (r+2)*(1+4*d*((d+1)*C^(4*(r+2)-2)))
def reluNatTeacherLogCount (r d C : ℕ) : ℕ := reluNatLogCount d r (reluNatTeacherEnergy d C r)

theorem reluMassMajorant_mono (d r : ℕ) {K k : ℝ} (hK : 0≤K) (hKk : K≤k) :
    reluMassMajorant d r K≤reluMassMajorant d r k := by
  unfold reluMassMajorant reluRadiusMajorant
  apply add_le_add (pow_le_pow_left₀ (by positivity) (by linarith) 2)
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  apply mul_le_mul_of_nonneg_left _ (by positivity)
  exact pow_le_pow_left₀ (by positivity) (by linarith) (r+1)

theorem reluMassMajorant_nat (d r k : ℕ) : reluMassMajorant d r k=(reluNatMass d r k:ℝ) := by
  simp only [reluMassMajorant,reluRadiusMajorant,reluNatMass,Nat.cast_add,Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat]
  ring

theorem reluTeacherThreshold_nat_le (d r : ℕ) (P : ℝ) {k : ℕ}
    (hK : reluTeacherEnergy d r P≤k) : reluTeacherThreshold d r P≤(reluNatThreshold d r k:ℝ) := by
  have hK0 : 0≤reluTeacherEnergy d r P := by unfold reluTeacherEnergy; positivity
  have hB : reluTeacherMassBudget d r P≤(reluNatMass d r k:ℝ) :=
    ((relu_mass_budget_majorant d r hK0).trans (reluMassMajorant_mono d r hK0 hK)).trans_eq (reluMassMajorant_nat d r k)
  have htwo : Real.log 2≤1 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)]
  have hs := mul_le_mul_of_nonneg_left htwo (show 0≤((d:ℝ)+(r+2:ℝ))/2 by positivity)
  have hm := mul_le_mul_of_nonneg_left htwo (Nat.cast_nonneg d : (0:ℝ)≤d)
  unfold reluTeacherThreshold reluGaussianThreshold
  rw [Real.log_pow]
  simp only [reluNatThreshold,Nat.cast_mul,Nat.cast_add,Nat.cast_ofNat]
  nlinarith [Nat.cast_nonneg d (α:=ℝ),Nat.cast_nonneg r (α:=ℝ)]

theorem reluDepthFactor_linear_le (r : ℕ) : reluDepthFactor (r+1)≤(2*r+3:ℝ) := by
  have htwo : Real.log 2≤1 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)]
  have htwo0 : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  have hr : (1:ℝ)≤r+1 := by linarith [Nat.cast_nonneg r (α:=ℝ)]
  have hh := mul_le_mul_of_nonneg_left htwo (show 0≤2*(r+1:ℝ) by positivity)
  have hs := Real.sq_sqrt (show 0≤2*(r+1:ℝ)*Real.log 2 by positivity)
  unfold reluDepthFactor
  simp only [Nat.cast_add,Nat.cast_one]
  nlinarith [Real.sqrt_nonneg (2*(r+1:ℝ)*Real.log 2)]

theorem cube_log_one_add_le (d : ℕ) : Real.log ((2:ℝ)^d+1)≤(d:ℝ)+1 := by
  have hp : (1:ℝ)≤(2:ℝ)^d := one_le_pow₀ (by norm_num)
  have hh := Real.log_le_log (show 0<(2:ℝ)^d+1 by positivity)
    (show (2:ℝ)^d+1≤(2:ℝ)^(d+1) by rw [pow_succ]; linarith)
  rw [Real.log_pow,Nat.cast_add,Nat.cast_one] at hh
  have htwo : Real.log 2≤1 := by linarith [Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)]
  have hm := mul_le_mul_of_nonneg_left htwo (show 0≤(d:ℝ)+1 by positivity)
  linarith

theorem reluFiniteLogCount_nat_le {d r : ℕ} (hd : 0<d) (P : ℝ) {k : ℕ}
    (hK : reluTeacherEnergy d r P≤k) : reluFiniteLogCount d r P≤(reluNatLogCount d r k:ℝ) := by
  have hdR : (1:ℝ)≤d := by exact_mod_cast hd
  have hT := reluTeacherThreshold_nat_le d r P hK
  have hTpos := reluTeacherThreshold_pos d r P
  have hdiv : reluTeacherThreshold d r P/(r+2:ℝ)≤(reluNatThreshold d r k:ℝ) := by
    apply le_trans _ hT
    apply (div_le_iff₀ (by positivity)).mpr
    exact le_mul_of_one_le_right hTpos.le (by linarith [Nat.cast_nonneg r (α:=ℝ)])
  have hfirst : 4*((d:ℝ)+1)/d≤4*((d:ℝ)+1) := (div_le_iff₀ (Nat.cast_pos.mpr hd)).mpr
    (le_mul_of_one_le_right (by positivity) hdR)
  have hfactor0 : 0≤reluDepthFactor (r+1) := by unfold reluDepthFactor; positivity
  have hcapacity : reluEnergyCapacity d r (reluTeacherThreshold d r P)≤
      4*(d+1)*(reluNatThreshold d r k)^(r+2)*(2*r+3)^2 := by
    apply Nat.ceil_le.mpr
    push_cast
    exact mul_le_mul
      (mul_le_mul hfirst (pow_le_pow_left₀ (by positivity) hdiv (r+2)) (by positivity) (by positivity))
      (pow_le_pow_left₀ hfactor0 (reluDepthFactor_linear_le r) 2) (by positivity) (by positivity)
  have hc : (reluEnergyCapacity d r (reluTeacherThreshold d r P):ℝ)≤
      (4*(d+1)*(reluNatThreshold d r k)^(r+2)*(2*r+3)^2:ℕ) := by exact_mod_cast hcapacity
  have hh := mul_le_mul hc (cube_log_one_add_le d)
    (Real.log_nonneg (by have hp:=pow_nonneg (by norm_num : (0:ℝ)≤2) d; linarith)) (by positivity)
  simpa only [reluFiniteLogCount,reluNatLogCount,Nat.cast_mul,Nat.cast_add,Nat.cast_one] using hh

/-- A natural polynomial budget dominates the exact capacity of every
bounded-weight margin teacher; its coefficients depend only on depth. -/
theorem relu_bounded_teacher_logCount {d C r : ℕ} (hd : 0<d) (hC : 0<C)
    (w : Weights d C r) (hw : boundedWeights C w) :
    reluFiniteLogCount d r (physicalProduct hC relu_zeroLipschitz w)≤(reluNatTeacherLogCount r d C:ℝ) := by
  apply reluFiniteLogCount_nat_le hd
  have hh := relu_teacher_energy_majorant d r (physicalProduct hC relu_zeroLipschitz w)
    (physical_relu_bounded_teacher_product hC w hw)
  simpa only [reluNatTeacherEnergy,Nat.cast_mul,Nat.cast_add,Nat.cast_one,Nat.cast_ofNat,Nat.cast_pow] using hh

end NeuralGeneralization.BatchTwoOnlineReluFinite
