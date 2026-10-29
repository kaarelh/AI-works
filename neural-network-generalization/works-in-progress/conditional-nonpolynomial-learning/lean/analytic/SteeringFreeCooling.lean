import SteeringTotalVariance
import NeuralGeneralization.BatchTwoContinuousDepthCriticalFreeLayers

/-! Actual two-component Gaussian cooling: the diagonal decays inversely in
depth and the tracked target loses only a polynomial factor. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def freeCoolingState (v r : ℝ) : ℕ → ℝ×ℝ
  | 0 => (v,r)
  | n+1 => (steeringSignal (freeCoolingState v r n).1 (freeCoolingState v r n).2,
      steeringResidual (freeCoolingState v r n).1 (freeCoolingState v r n).2)

theorem freeCoolingState_nonneg {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r) (n : ℕ) :
    0 ≤ (freeCoolingState v r n).1 ∧ 0 ≤ (freeCoolingState v r n).2 := by
  cases n with
  | zero => exact ⟨hv,hr⟩
  | succ n => exact ⟨steeringSignal_nonneg _ _,steeringResidual_nonneg _ _⟩

theorem freeCoolingState_total {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r) (n : ℕ) :
    (freeCoolingState v r n).1+(freeCoolingState v r n).2 = coolingOrbit (v+r) n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    have hn := freeCoolingState_nonneg hv hr n
    change steeringSignal _ _+steeringResidual _ _ = _
    rw [steeringSignal_add_residual hn.1 hn.2,ih]
    exact (Function.iterate_succ_apply' _ _ _).symm

theorem freeCoolingState_residual_le {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r) (n : ℕ) :
    (freeCoolingState v r n).2 ≤ r := by
  induction n with
  | zero => rfl
  | succ n ih =>
    exact (steeringResidual_le (freeCoolingState_nonneg hv hr n).2 _).trans ih

theorem steeringSignal_gaussian_lower {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r) :
    v*(coolingDerivative (v+r))^2 ≤ steeringSignal v r := by
  have hh := steeringSignal_ge_correlation v r
  rwa [steering_correlation hv hr,mul_pow,Real.sq_sqrt hv] at hh

theorem freeCoolingState_signal_lower {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r) (n : ℕ) :
    v*(freeSeedMultiplier (v+r) n)^2 ≤ (freeCoolingState v r n).1 := by
  induction n with
  | zero => simp [freeCoolingState,freeSeedMultiplier]
  | succ n ih =>
    have hnon := freeCoolingState_nonneg hv hr n
    have hs := steeringSignal_gaussian_lower hnon.1 hnon.2
    rw [freeCoolingState_total hv hr n] at hs
    have hm := mul_le_mul_of_nonneg_right ih (sq_nonneg (coolingDerivative (coolingOrbit (v+r) n)))
    apply (le_trans ?_ hs)
    change v*(freeSeedMultiplier (v+r) (n+1))^2 ≤ _
    simp only [freeSeedMultiplier,Finset.prod_range_succ,mul_pow]
    simpa only [freeSeedMultiplier,mul_assoc] using hm

theorem freeCoolingState_signal_exp_lower {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hqr : v+r ≤ 1) (n : ℕ) :
    v*Real.exp (-2*(1+Real.log ((n : ℝ)+1))/(coolingConstant*derivativeFloor)) ≤
      (freeCoolingState v r n).1 := by
  have hh := freeSeedMultiplier_lower (add_nonneg hv hr) hqr n
  have hs := pow_le_pow_left₀ (Real.exp_pos _).le hh 2
  have hm := mul_le_mul_of_nonneg_left hs hv
  have he : (Real.exp (-(1+Real.log ((n : ℝ)+1))/(coolingConstant*derivativeFloor)))^2 =
      Real.exp (-2*(1+Real.log ((n : ℝ)+1))/(coolingConstant*derivativeFloor)) := by
    rw [← Real.exp_nat_mul]
    congr 1
    norm_num
    ring
  rw [he] at hm
  exact hm.trans (freeCoolingState_signal_lower hv hr n)

theorem freeCoolingState_small {v r p : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hqr : v+r ≤ 1) (hp : 0 < p) (H : ℕ)
    (hbudget : 1 ≤ p*(1+coolingConstant*(H : ℝ))) :
    (freeCoolingState v r H).1+(freeCoolingState v r H).2 ≤ p := by
  rw [freeCoolingState_total hv hr H]
  apply (coolingOrbit_bound (add_nonneg hv hr) hqr H).trans
  have hc := coolingConstant_pos
  apply (div_le_iff₀ (by positivity : 0<1+coolingConstant*(H : ℝ))).mpr
  exact hbudget

#print axioms freeCoolingState_signal_exp_lower
#print axioms freeCoolingState_small
end ConditionalNonpolynomial.Analytic
