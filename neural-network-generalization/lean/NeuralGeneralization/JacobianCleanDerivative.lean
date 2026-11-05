import NeuralGeneralization.JacobianFiniteRadius
import Mathlib.Analysis.Calculus.FDeriv.WithLp
import Mathlib.Analysis.InnerProductSpace.Dual

/-! Identification of the signed clean transport with the actual hidden-
injection derivative, and the exact sum-of-squared-derivatives formula for g. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open WithLp Asymptotics
namespace NeuralGeneralization.JacobianCertificate
open ConcreteModel ValidState TanhDifferential
variable {d N r : ℕ}

def stackDisturbance (v : Stack N r) : NetworkDisturbance N r :=
  (fun s i => v (s,i),0)

@[simp] lemma stackDisturbance_zero : stackDisturbance (0 : Stack N r) = 0 := rfl
@[simp] lemma injection_stackDisturbance (v : Stack N r) : hiddenInjection (stackDisturbance v) = v := rfl

lemma differentiable_trajectory (w : Weights d N r) (x : Cube d) (s : Fin (r+1)) (i : Fin N) :
    Differentiable ℝ (fun v : Stack N r => trajectory Real.tanh w x (stackDisturbance v) s i) := by
  induction s using Fin.induction generalizing i with
  | zero =>
    simp only [trajectory_zero,noisyFirstHidden,stackDisturbance]
    fun_prop
  | succ s ih =>
    simp only [trajectory_succ,noisyHiddenStep,hiddenStep,stackDisturbance]
    apply Differentiable.add
    · have hφ : Differentiable ℝ Real.tanh := fun a => (hasDerivAt_tanh_first a).differentiableAt
      apply hφ.comp
      exact Differentiable.fun_sum fun j _ => (ih j).const_mul _
    · fun_prop

lemma differentiable_hiddenDifference (w : Weights d N r) (x : Cube d) :
    Differentiable ℝ (fun v : Stack N r => hiddenDifference w x (stackDisturbance v)) := by
  apply (differentiable_piLp _).mpr
  intro p
  exact (differentiable_trajectory w x p.1 p.2).sub_const _

lemma remainder_derivative_zero (w : Weights d N r) (x : Cube d) :
    HasFDerivAt (nonlinearRemainder w x) (0 : Stack N r →L[ℝ] Stack N r) 0 := by
  have h : nonlinearRemainder w x =O[𝓝 0] (fun X : Stack N r => ‖X-0‖^2) := by
    apply IsBigO.of_bound (maxBlockNorm (internalWeights w)*maxRowNorm (internalWeights w)/2)
    filter_upwards [] with X
    simpa only [sub_zero,Real.norm_eq_abs,abs_pow,abs_norm] using network_remainder_bound w x X
  exact h.hasFDerivAt (by norm_num)

/-- K is the actual derivative of all hidden states with respect to all hidden
injections at the clean trajectory. -/
theorem hidden_derivative (w : Weights d N r) (x : Cube d) :
    HasFDerivAt (fun v : Stack N r => hiddenDifference w x (stackDisturbance v))
      (transport (cleanBlocks w x)) 0 := by
  let D := fun v : Stack N r => hiddenDifference w x (stackDisturbance v)
  have hD := (differentiable_hiddenDifference w x 0).hasFDerivAt
  have he : HasFDerivAt (nonlinearRemainder w x) (0 : Stack N r →L[ℝ] Stack N r) (D 0) := by
    simpa [D] using remainder_derivative_zero w x
  have h := (transport (cleanBlocks w x)).hasFDerivAt.comp 0
    ((hasFDerivAt_id (0 : Stack N r)).add (he.comp 0 hD))
  have hfun : (fun v : Stack N r => transport (cleanBlocks w x)
      (v+nonlinearRemainder w x (D v))) = D := by
    funext v
    exact (network_transport_identity w x (stackDisturbance v)).symm
  simp only [ContinuousLinearMap.zero_comp,add_zero,ContinuousLinearMap.comp_id] at h
  change HasFDerivAt (fun v => transport (cleanBlocks w x) (v+nonlinearRemainder w x (D v)))
    (transport (cleanBlocks w x)) 0 at h
  rwa [hfun] at h

/-- The clean signed readout transport is the derivative of the actual raw
output as the full hidden injection stack varies. -/
theorem output_derivative (w : Weights d N r) (x : Cube d) :
    HasFDerivAt (fun v : Stack N r => noisyNetworkOutput Real.tanh w x (stackDisturbance v))
      ((readout w).comp (transport (cleanBlocks w x))) 0 := by
  have h := ((readout w).hasFDerivAt.comp 0 (hidden_derivative w x)).add_const
    (networkOutput Real.tanh w x)
  have he : (fun v : Stack N r => readout w (hiddenDifference w x (stackDisturbance v))+
      networkOutput Real.tanh w x) =
      (fun v : Stack N r => noisyNetworkOutput Real.tanh w x (stackDisturbance v)) := by
    funext v
    have hh := output_difference w x (stackDisturbance v)
    change _ = _ + (0 : ℝ) at hh
    linarith
  simp only [Function.comp_def] at h
  rwa [he] at h

/-- A single hidden-injection coordinate derivative, including first and last
hidden layers, is the corresponding row coefficient of the clean transport. -/
theorem coordinate_derivative (w : Weights d N r) (x : Cube d)
    (p : Fin (r+1) × Fin N) :
    HasDerivAt (fun t : ℝ => noisyNetworkOutput Real.tanh w x
      (stackDisturbance (t • EuclideanSpace.basisFun _ ℝ p)))
      (((readout w).comp (transport (cleanBlocks w x))) (EuclideanSpace.basisFun _ ℝ p)) 0 := by
  have hout : HasFDerivAt (fun v : Stack N r => noisyNetworkOutput Real.tanh w x (stackDisturbance v))
      ((readout w).comp (transport (cleanBlocks w x)))
      (id (0 : ℝ) • EuclideanSpace.basisFun _ ℝ p) := by simpa using output_derivative w x
  have h := hout.comp_hasDerivAt 0
    ((hasDerivAt_id (0 : ℝ)).smul_const (EuclideanSpace.basisFun _ ℝ p))
  simpa [Function.comp_def] using! h

/-- Exact g² identity from the paper, now in terms of actual derivatives. -/
theorem readoutGain_sq_sum_derivatives (w : Weights d N r) (x : Cube d) :
    (readoutGain w x)^2 = ∑ p : Fin (r+1) × Fin N,
      (deriv (fun t : ℝ => noisyNetworkOutput Real.tanh w x
        (stackDisturbance (t • EuclideanSpace.basisFun _ ℝ p))) 0)^2 := by
  simp_rw [(coordinate_derivative w x _).deriv]
  exact (EuclideanSpace.basisFun _ ℝ).norm_dual _

end NeuralGeneralization.JacobianCertificate
