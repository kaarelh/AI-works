import NeuralGeneralization.BatchTwoOnlineReluFiniteTail
import NeuralGeneralization.BatchTwoOnlineReluVariance
import NeuralGeneralization.BatchTwoOnlineReluEnergyCount

/-! Exact finite-variance ReLU cumulative bounds for the actual posterior learner. -/
noncomputable section
set_option autoImplicit false
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoOnlineReluFinite
open ConcreteModel BatchTwoActivation BatchTwoOnline
set_option maxHeartbeats 1600000
set_option backward.isDefEq.respectTransparency false

theorem gaussianBoxBudget_pos (K : ℝ) {S ρ : ℝ} (hS : 0<S) (hρ : 0<ρ) :
    0<gaussianBoxBudget K S ρ := by
  have hD : 1<3*max 1 (Real.sqrt S/ρ) := by linarith [le_max_left (1:ℝ) (Real.sqrt S/ρ)]
  exact add_pos_of_nonneg_of_pos (by positivity) (mul_pos hS (Real.log_pos hD))

theorem reluTeacherMassBudget_pos (d r : ℕ) (P : ℝ) : 0<reluTeacherMassBudget d r P :=
  gaussianBoxBudget_pos _ (by positivity) (reluPerturbationRadius_pos _ _)

theorem reluTeacherThreshold_pos (d r : ℕ) (P : ℝ) : 0<reluTeacherThreshold d r P := by
  have hB := reluTeacherMassBudget_pos d r P
  have htwo : 0≤Real.log 2 := Real.log_nonneg (by norm_num)
  have hm : 0≤Real.log ((2:ℝ)^d) := Real.log_nonneg (one_le_pow₀ (by norm_num))
  have hprod : 0≤((d:ℝ)+(r+2:ℝ))/2*Real.log 2 := mul_nonneg (by positivity) htwo
  unfold reluTeacherThreshold reluGaussianThreshold
  linarith

def reluFiniteLogCount (d r : ℕ) (P : ℝ) : ℝ :=
  (reluEnergyCapacity d r (reluTeacherThreshold d r P):ℝ)*Real.log ((2:ℝ)^d+1)

theorem reluFiniteLogCount_nonneg (d r : ℕ) (P : ℝ) : 0≤reluFiniteLogCount d r P := by
  unfold reluFiniteLogCount
  exact mul_nonneg (Nat.cast_nonneg _) (Real.log_nonneg (by have hp:=pow_nonneg (by norm_num : (0:ℝ)≤2) d; linarith))

/-- The variance is fixed; all inputs are actual network weights and the
three numerical conditions are checked explicitly by the power-prior corollaries. -/
theorem relu_finite_scale_online_product {d C N r : ℕ} (hd : 0<d) (hC : 0<C)
    (hCN : C≤N) (w : Weights d C r) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) {σ : ℝ} (hσ : 0<σ) (hσone : σ^2≤1)
    (hdim : (Fintype.card (WeightIndex d N r):ℝ)*σ^2≤(d:ℝ)+(r+2:ℝ)) :
    NetworkOnlineBounds relu (1/2) (smallPrior d N r σ) f
      (reluFiniteLogCount d r (physicalProduct hC relu_zeroLipschitz w)) := by
  have hmass := relu_finite_variance_target_mass hd hC hCN w f hw hσ hdim
  have hpos := (Real.exp_pos _).trans_le hmass
  apply network_online_of_randomOrder hd relu (1/2) _ f _ (reluFiniteLogCount_nonneg _ _ _) hpos
  exact bounds_of_relevant_class Fintype.card_pos _ (functionMass_nonneg relu (1/2) _) _ f
    (fun _=>rfl) hpos
    (energyFunctions d r relu (reluTeacherThreshold d r (physicalProduct hC relu_zeroLipschitz w))) _ _
    (reluFiniteLogCount_nonneg _ _ _) (by positivity)
    (relu_energyFunctions_card_le_exp hd (reluTeacherThreshold_pos _ _ _))
    (relu_finite_variance_function_tail hd hC hCN w f hw hσ hσone hdim)

/-- Every width N>=C and every gamma>=2, with exactly h=v_R log(m+1). -/
theorem relu_finite_variance_online_product {d C N r : ℕ} (hd : 0<d) (hC : 0<C)
    (hCN : C≤N) (w : Weights d C r) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) {γ : ℝ} (hγ : 2≤γ) :
    NetworkOnlineBounds relu (1/2) (powerPrior d N r γ) f
      (reluFiniteLogCount d r (physicalProduct hC relu_zeroLipschitz w)) := by
  have hN : 0<N := hC.trans_le hCN
  have hv := relu_variance_budget hN (show 0≤γ by linarith)
  rw [powerPrior_eq_smallPrior hN γ]
  apply relu_finite_scale_online_product hd hC hCN w f hw (Real.sqrt_pos.mpr hv.1)
  · simpa only [Real.sq_sqrt hv.1.le] using hv.2
  · simpa only [Real.sq_sqrt hv.1.le] using relu_dimension_variance_budget (d:=d) (r:=r) hN hγ

/-- The sharper one-hidden-layer endpoint includes the mean-field variance gamma=1. -/
theorem relu_shallow_finite_variance_online_product {d C N : ℕ} (hd : 0<d) (hC : 0<C)
    (hCN : C≤N) (w : Weights d C 0) (f : BooleanFunction d)
    (hw : w∈marginEvent relu (1/2) f) {γ : ℝ} (hγ : 1≤γ) :
    NetworkOnlineBounds relu (1/2) (powerPrior d N 0 γ) f
      (reluFiniteLogCount d 0 (physicalProduct hC relu_zeroLipschitz w)) := by
  have hN : 0<N := hC.trans_le hCN
  have hv := relu_variance_budget hN (show 0≤γ by linarith)
  rw [powerPrior_eq_smallPrior hN γ]
  apply relu_finite_scale_online_product hd hC hCN w f hw (Real.sqrt_pos.mpr hv.1)
  · simpa only [Real.sq_sqrt hv.1.le] using hv.2
  · simpa only [Real.sq_sqrt hv.1.le,Nat.cast_zero,zero_add] using relu_shallow_dimension_variance_budget (d:=d) hN hγ

#print axioms relu_finite_variance_online_product
#print axioms relu_shallow_finite_variance_online_product
end NeuralGeneralization.BatchTwoOnlineReluFinite
