import NeuralGeneralization.JacobianStackBounds
import NeuralGeneralization.ValidStateSupport

/-! The clean linearization and exact quadratic remainder of the actual
finite feedforward tanh network, with postactivation injections. -/
noncomputable section
open scoped BigOperators
open WithLp
namespace NeuralGeneralization.JacobianCertificate
open ConcreteModel TanhDifferential ValidState
variable {d N r : ℕ}

def internalWeights (w : Weights d N r) : Fin r → Fin N → Fin N → ℝ :=
  fun s i j => w (.inr (.inl (s,i,j)))

def cleanPreactivation (w : Weights d N r) (x : Cube d) (s : Fin r) (i : Fin N) : ℝ :=
  ∑ j, internalWeights w s i j * trajectory Real.tanh w x 0 s.castSucc j

def cleanBlocks (w : Weights d N r) (x : Cube d) : Fin r → Fin N → Fin N → ℝ :=
  fun s i j => tanhFirst (cleanPreactivation w x s i) * internalWeights w s i j

def hiddenInjection (η : NetworkDisturbance N r) : Stack N r :=
  toLp 2 (fun p => η.1 p.1 p.2)

def hiddenDifference (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) : Stack N r :=
  toLp 2 (fun p => trajectory Real.tanh w x η p.1 p.2 - trajectory Real.tanh w x 0 p.1 p.2)

def nonlinearRemainder (w : Weights d N r) (x : Cube d) (X : Stack N r) : Stack N r :=
  toLp 2 (fun p => Fin.cases 0 (fun s =>
    Real.tanh (cleanPreactivation w x s p.2 + shift (internalWeights w) X (s.succ,p.2)) -
    Real.tanh (cleanPreactivation w x s p.2) -
    tanhFirst (cleanPreactivation w x s p.2) * shift (internalWeights w) X (s.succ,p.2)) p.1)

@[simp] lemma hiddenDifference_zero (w : Weights d N r) (x : Cube d) :
    hiddenDifference w x 0 = 0 := by ext p; simp [hiddenDifference]

lemma hiddenDifference_first (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r)
    (i : Fin N) : hiddenDifference w x η (0,i) = η.1 0 i := by
  simp [hiddenDifference,trajectory_zero,noisyFirstHidden]

lemma cleanBlocks_action (w : Weights d N r) (x : Cube d) (X : Stack N r)
    (s : Fin r) (i : Fin N) :
    shift (cleanBlocks w x) X (s.succ,i) =
      tanhFirst (cleanPreactivation w x s i) * shift (internalWeights w) X (s.succ,i) := by
  simp only [shift_succ,cleanBlocks,Finset.mul_sum,mul_assoc]

lemma preactivation_difference (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) (s : Fin r) (i : Fin N) :
    cleanPreactivation w x s i + shift (internalWeights w) (hiddenDifference w x η) (s.succ,i) =
      ∑ j, internalWeights w s i j * trajectory Real.tanh w x η s.castSucc j := by
  simp only [shift_succ,hiddenDifference,cleanPreactivation,mul_sub,Finset.sum_sub_distrib]
  ring

/-- The Taylor identity holds exactly, before any norm estimate. -/
theorem network_expansion (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) :
    hiddenDifference w x η = shift (cleanBlocks w x) (hiddenDifference w x η) +
      hiddenInjection η + nonlinearRemainder w x (hiddenDifference w x η) := by
  ext ⟨s,i⟩
  induction s using Fin.cases with
  | zero => simp [hiddenDifference_first,nonlinearRemainder,hiddenInjection]
  | succ s =>
    change hiddenDifference w x η (s.succ,i) =
      shift (cleanBlocks w x) (hiddenDifference w x η) (s.succ,i) + η.1 s.succ i +
      (Real.tanh (cleanPreactivation w x s i + shift (internalWeights w) (hiddenDifference w x η) (s.succ,i)) -
       Real.tanh (cleanPreactivation w x s i) -
       tanhFirst (cleanPreactivation w x s i) * shift (internalWeights w) (hiddenDifference w x η) (s.succ,i))
    rw [cleanBlocks_action,preactivation_difference]
    simp only [hiddenDifference,trajectory_succ,noisyHiddenStep,hiddenStep,
      cleanPreactivation,internalWeights,Prod.fst_zero,Pi.zero_apply,add_zero]
    ring

/-- This is the paper's nonlinear remainder bound for the actual network. -/
theorem network_remainder_bound (w : Weights d N r) (x : Cube d) (X : Stack N r) :
    ‖nonlinearRemainder w x X‖ ≤
      maxBlockNorm (internalWeights w)*maxRowNorm (internalWeights w)/2*‖X‖^2 := by
  apply stacked_remainder_bound
  rintro ⟨s,i⟩
  induction s using Fin.cases with
  | zero => simp [nonlinearRemainder]
  | succ s => exact quadratic_remainder _ _

/-- The inverse identity is instantiated with the actual clean Jacobian. -/
theorem network_transport_identity (w : Weights d N r) (x : Cube d) (η : NetworkDisturbance N r) :
    hiddenDifference w x η = transport (cleanBlocks w x)
      (hiddenInjection η + nonlinearRemainder w x (hiddenDifference w x η)) :=
  transport_identity _ _ _ _ (network_expansion w x η)

/-- A homotopy of disturbances induces a continuous full hidden trajectory. -/
theorem continuous_trajectory_scale (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) (s : Fin (r+1)) (i : Fin N) :
    Continuous (fun t : ℝ => trajectory Real.tanh w x (scaleDisturbance t η) s i) := by
  induction s using Fin.induction generalizing i with
  | zero =>
    simp only [trajectory_zero,noisyFirstHidden,scaleDisturbance]
    fun_prop
  | succ s ih =>
    simp only [trajectory_succ,noisyHiddenStep,hiddenStep,scaleDisturbance]
    apply Continuous.add
    · apply continuous_tanh.comp
      exact continuous_finsetSum _ fun j _ => continuous_const.mul (ih j)
    · fun_prop

theorem continuous_hiddenDifference_scale (w : Weights d N r) (x : Cube d)
    (η : NetworkDisturbance N r) :
    Continuous (fun t : ℝ => hiddenDifference w x (scaleDisturbance t η)) := by
  apply (PiLp.continuous_toLp 2 (fun _ : Fin (r+1) × Fin N => ℝ)).comp
  apply continuous_pi
  intro p
  exact (continuous_trajectory_scale w x η p.1 p.2).sub continuous_const

end NeuralGeneralization.JacobianCertificate
