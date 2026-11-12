import NeuralGeneralization.BatchTwoOnlineReluTargetMass
import NeuralGeneralization.BatchTwoOnlineReluGaussianTail
import NeuralGeneralization.BatchTwoActivationSmallWidth

/-! Actual function-mass tail at the paper's T_R, without a small-variance limit. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoActivation
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

theorem smallPrior_energy_eq_isotropic {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    {σ : ℝ} (hσ : 0<σ) (T : ℝ) :
    (smallPrior d N r σ).real {w | T≤weightedSquaredNorm w}=
      (Measure.pi fun _i:WeightIndex d N r=>gaussianReal 0 (σ^2).toNNReal).real {u | T≤∑q,(u q)^2} := by
  rw [←map_isotropic_eq_smallPrior hd hN hσ]
  unfold Measure.real
  rw [Measure.map_apply (continuous_unwhiten d N r).measurable
    (measurableSet_le measurable_const (by unfold weightedSquaredNorm; fun_prop))]
  congr 2
  ext u
  simp only [Set.mem_preimage,Set.mem_setOf_eq,weightedSquaredNorm_unwhiten hd hN]

def reluTeacherThreshold (d r : ℕ) (P : ℝ) : ℝ :=
  reluGaussianThreshold (reluTeacherMassBudget d r P) ((d:ℝ)+(r+2:ℝ)) ((2:ℝ)^d)

theorem cube_card_real (d : ℕ) : (Fintype.card (Cube d):ℝ)=(2:ℝ)^d := by
  simp [Cube,Fintype.card_fun]

theorem relu_finite_variance_function_tail {d C N r : ℕ} (hd : 0<d) (hC : 0<C)
    (hCN : C≤N) (w : Weights d C r) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) {σ : ℝ} (hσ : 0<σ) (hσone : σ^2≤1)
    (hdim : (Fintype.card (WeightIndex d N r):ℝ)*σ^2≤(d:ℝ)+(r+2:ℝ)) :
    (∑g∈Finset.univ\energyFunctions d r relu (reluTeacherThreshold d r (physicalProduct hC relu_zeroLipschitz w)),
      functionMass relu (1/2) (smallPrior d N r σ) g) /
      functionMass relu (1/2) (smallPrior d N r σ) f≤1/Fintype.card (Cube d) := by
  have hN : 0<N := hC.trans_le hCN
  let B := reluTeacherMassBudget d r (physicalProduct hC relu_zeroLipschitz w)
  let T := reluTeacherThreshold d r (physicalProduct hC relu_zeroLipschitz w)
  let ν := Measure.pi fun _i:WeightIndex d N r=>gaussianReal 0 (σ^2).toNNReal
  have hmass := relu_finite_variance_target_mass hd hC hCN w f hw hσ hdim
  have hpos : 0<functionMass relu (1/2) (smallPrior d N r σ) f := (Real.exp_pos _).trans_le hmass
  have hmassiso : Real.exp (-B/((σ^2).toNNReal:ℝ))≤ν.real (whitenedMarginEvent relu (1/2) f) := by
    rw [Real.coe_toNNReal _ (sq_nonneg σ)]
    unfold functionMass at hmass
    rwa [smallPrior_marginEvent_eq_isotropic hd hN
      (show Continuous relu from continuous_const.max continuous_id) (1/2) f hσ] at hmass
  have htail := gaussian_relative_energy_tail (σ^2).toNNReal
    (by simpa only [Real.coe_toNNReal _ (sq_nonneg σ)] using sq_pos_of_pos hσ)
    (by simpa only [Real.coe_toNNReal _ (sq_nonneg σ)] using hσone)
    (by simpa only [Real.coe_toNNReal _ (sq_nonneg σ)] using hdim)
    (show (1:ℝ)≤(2:ℝ)^d by exact one_le_pow₀ (by norm_num)) hmassiso
  have hclass := energyFunctions_complement_mass_le_cost_tail (J:=T) hN relu_zeroLipschitz (by norm_num)
    (smallPrior d N r σ)
  rw [smallPrior_energy_eq_isotropic hd hN hσ T] at hclass
  have hmapeq : ν.real (whitenedMarginEvent relu (1/2) f)=functionMass relu (1/2) (smallPrior d N r σ) f := by
    unfold functionMass
    rw [smallPrior_marginEvent_eq_isotropic hd hN
      (show Continuous relu from continuous_const.max continuous_id) (1/2) f hσ]
    rfl
  rw [hmapeq] at htail
  apply (div_le_iff₀ hpos).mpr
  rw [cube_card_real]
  simpa only [one_div,div_eq_mul_inv,mul_comm,one_mul,T] using hclass.trans htail

end NeuralGeneralization.BatchTwoOnlineReluFinite
