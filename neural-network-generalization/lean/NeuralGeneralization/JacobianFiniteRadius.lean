import NeuralGeneralization.JacobianNetworkExpansion
import NeuralGeneralization.JacobianHomotopy
import NeuralGeneralization.BatchTwoShallowRobust
import NeuralGeneralization.RobustStatisticsCoupling

/-! The finite-radius clean-Jacobian proposition, for the concrete tanh network
and the paper's literal `b`, `b∞`, `k`, `g`, and joint RMS disturbance budget. -/
noncomputable section
open scoped BigOperators
open WithLp Set
namespace NeuralGeneralization.JacobianCertificate
open ConcreteModel ValidState
variable {d N r : ℕ}

/-- Last-hidden-block readout. -/
def readout (w : Weights d N r) : Stack N r →L[ℝ] ℝ :=
  LinearMap.toContinuousLinearMap {
    toFun := fun X => ∑ i, w (.inr (.inr i)) * X (Fin.last r,i)
    map_add' := by intros; simp [mul_add,Finset.sum_add_distrib]
    map_smul' := by intros; simp [Finset.mul_sum,mul_left_comm]
  }

def jacobianNorm (w : Weights d N r) (x : Cube d) : ℝ := ‖transport (cleanBlocks w x)‖
def readoutGain (w : Weights d N r) (x : Cube d) : ℝ := ‖(readout w).comp (transport (cleanBlocks w x))‖
def curvatureRatio (w : Weights d N r) (x : Cube d) (ρ : ℝ) : ℝ :=
  2 * maxBlockNorm (internalWeights w) * maxRowNorm (internalWeights w) *
    (jacobianNorm w x)^2 * (ρ * Real.sqrt N)

lemma curvatureRatio_nonneg (w : Weights d N r) (x : Cube d) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    0 ≤ curvatureRatio w x ρ := by
  unfold curvatureRatio
  have := maxBlockNorm_nonneg (internalWeights w)
  have := maxRowNorm_nonneg (internalWeights w)
  positivity

lemma injection_scale (η : NetworkDisturbance N r) (t : ℝ) :
    hiddenInjection (scaleDisturbance t η) = t • hiddenInjection η := by ext p; rfl

lemma difference_eq_zero_of_injection_zero (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) (hη : hiddenInjection η = 0) : hiddenDifference w x η = 0 := by
  have hcoord (s : Fin (r+1)) (i : Fin N) : η.1 s i = 0 :=
    congrArg (fun X : Stack N r => X (s,i)) hη
  have ht (s : Fin (r+1)) (i : Fin N) :
      trajectory Real.tanh w x η s i = trajectory Real.tanh w x 0 s i := by
    induction s using Fin.induction generalizing i with
    | zero => simp [trajectory_zero,noisyFirstHidden,hcoord]
    | succ s ih => simp [trajectory_succ,noisyHiddenStep,hiddenStep,ih,hcoord]
  ext ⟨s,i⟩
  simp [hiddenDifference,ht]

lemma output_difference (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) :
    noisyNetworkOutput Real.tanh w x η - networkOutput Real.tanh w x =
      readout w (hiddenDifference w x η) + η.2 := by
  change _ = (∑ i,w (.inr (.inr i)) *
    (trajectory Real.tanh w x η (Fin.last r) i-trajectory Real.tanh w x 0 (Fin.last r) i))+η.2
  simp only [trajectory_last,noisyFinalHidden_zero,mul_sub,Finset.sum_sub_distrib,
    noisyNetworkOutput,networkOutput]
  ring

lemma injection_budget (η : NetworkDisturbance N r) :
    ‖hiddenInjection η‖^2/(N : ℝ)+η.2^2 = noiseBudgetSq η := by
  simp only [EuclideanSpace.real_norm_sq_eq,hiddenInjection,Fintype.sum_prod_type,noiseBudgetSq]

lemma injection_norm_le (hN : 0 < N) (η : NetworkDisturbance N r) {ρ : ℝ}
    (hρ : 0 ≤ ρ) (hη : noiseBudgetSq η ≤ ρ^2) :
    ‖hiddenInjection η‖ ≤ ρ * Real.sqrt N := by
  have hNp : (0 : ℝ) < N := Nat.cast_pos.mpr hN
  apply (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hρ (Real.sqrt_nonneg _))).mp
  rw [mul_pow,Real.sq_sqrt hNp.le]
  have hh : ‖hiddenInjection η‖^2/(N : ℝ) ≤ ρ^2 := by
    rw [← injection_budget] at hη
    nlinarith [sq_nonneg η.2]
  exact (div_le_iff₀ hNp).mp hh

/-- Nonlinear hidden readout bound, retaining the signed clean transport. -/
theorem hidden_readout_bound (hN : 0 < N) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hsmall : curvatureRatio w x ρ < 1) (hη : noiseBudgetSq η ≤ ρ^2) :
    |readout w (hiddenDifference w x η)| ≤
      readoutGain w x * (1+curvatureRatio w x ρ) * ‖hiddenInjection η‖ := by
  let X : ℝ → Stack N r := fun t => hiddenDifference w x (scaleDisturbance t η)
  let e : ℝ → Stack N r := fun t => nonlinearRemainder w x (X t)
  have h0 : scaleDisturbance 0 η = 0 := by ext <;> simp [scaleDisturbance]
  have h := readout_bound (transport (cleanBlocks w x)) (readout w) X e (hiddenInjection η)
    (β := maxBlockNorm (internalWeights w)*maxRowNorm (internalWeights w))
    (R := ρ*Real.sqrt N)
    (mul_nonneg (maxBlockNorm_nonneg _) (maxRowNorm_nonneg _))
    (injection_norm_le hN η hρ hη)
    (by simpa [curvatureRatio,jacobianNorm,mul_assoc] using hsmall)
    (by intro hz; simpa [X] using difference_eq_zero_of_injection_zero w x η hz)
    (continuous_hiddenDifference_scale w x η).continuousOn
    (by simp [X,h0])
    (by intro t _; simpa only [X,e,injection_scale] using
      network_transport_identity w x (scaleDisturbance t η))
    (by intro t _; exact network_remainder_bound w x (X t))
  simpa [X,readoutGain,curvatureRatio,jacobianNorm,mul_assoc] using h

/-- Proposition (Finite-radius Jacobian certificate), with the exact constants
and simultaneous hidden/output RMS budget in the paper. -/
theorem finite_radius_bound (hN : 0 < N) (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (hsmall : curvatureRatio w x ρ < 1) (hη : noiseBudgetSq η ≤ ρ^2) :
    |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤
      ρ * Real.sqrt (1+(N : ℝ)*(readoutGain w x)^2*(1+curvatureRatio w x ρ)^2) := by
  let a := readoutGain w x*(1+curvatureRatio w x ρ)
  have ha : 0 ≤ a := mul_nonneg (norm_nonneg _) (by linarith [curvatureRatio_nonneg w x hρ])
  have hc := BatchTwoShallow.weighted_cauchy (fun _ : Unit => a)
    (fun _ : Unit => ‖hiddenInjection η‖) |η.2| (Nat.cast_pos.mpr hN)
  simp only [Fintype.sum_unique,sq_abs] at hc
  rw [injection_budget] at hc
  have hraw : |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤
      a*‖hiddenInjection η‖+|η.2| := by
    rw [output_difference]
    exact (abs_add_le _ _).trans (add_le_add (hidden_readout_bound hN w x η hρ hsmall hη) le_rfl)
  have hn : 0 ≤ 1+(N : ℝ)*a^2 := by positivity
  have hs := (sq_le_sq₀ (abs_nonneg _) (by positivity)).mpr hraw
  have hfinal := hs.trans (hc.trans (mul_le_mul_of_nonneg_left hη hn))
  apply (sq_le_sq₀ (abs_nonneg _) (mul_nonneg hρ (Real.sqrt_nonneg _))).mp
  rw [mul_pow,Real.sq_sqrt (by positivity)]
  simpa [a,mul_pow,mul_assoc,mul_comm,mul_left_comm] using hfinal

/-- A small finite-radius raw bound certifies the original clipped support. -/
theorem finite_radius_support_at (hN : 0 < N) (w : Weights d N r) (x : Cube d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) (hsmall : curvatureRatio w x ρ < 1)
    (hcert : ρ*Real.sqrt (1+(N : ℝ)*(readoutGain w x)^2*(1+curvatureRatio w x ρ)^2) ≤ 1/16)
    (η : NetworkDisturbance N r) (hη : noiseBudgetSq η ≤ ρ^2) :
    |clippedScore (noisyNetworkOutput Real.tanh w x η)-clippedScore (networkOutput Real.tanh w x)| ≤ 1/16 :=
  (RobustStatistics.clippedScore_lipschitz _ _).trans
    ((finite_radius_bound hN w x η hρ hsmall hη).trans hcert)

/-- Instantiate the certificate at the actual readout-calibrated support radius. -/
theorem finite_radius_support (hN : 0 < N) (w : Weights d N r) {c : ℝ} (hc : 0 < c)
    (hsmall : ∀ x,curvatureRatio w x (robustRadius c w) < 1)
    (hcert : ∀ x,robustRadius c w * Real.sqrt
      (1+(N : ℝ)*(readoutGain w x)^2*(1+curvatureRatio w x (robustRadius c w))^2) ≤ 1/16) :
    w ∈ robustEvent Real.tanh c := by
  intro x η hη
  exact finite_radius_support_at hN w x (robustRadius_pos hc w).le (hsmall x) (hcert x) η hη

end NeuralGeneralization.JacobianCertificate
