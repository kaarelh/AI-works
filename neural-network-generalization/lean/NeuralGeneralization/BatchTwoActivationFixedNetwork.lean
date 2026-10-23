import NeuralGeneralization.BatchTwoActivationFiniteNormalization
import NeuralGeneralization.BatchTwoActivationLayerPadding

/-! Finite networks with a common auxiliary width and heterogeneous activations.
Updating layer s preserves every preceding state exactly. -/
noncomputable section
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def fixedInputWidth (d F : ℕ) : ℕ → ℕ
  | 0 => d+1
  | _+1 => F

structure FixedActivationNetwork (d F : ℕ) (ℓ K : ℝ) where
  activation : ℕ → Fin F → ℝ → ℝ
  activation_class : ∀s i,zeroLipschitzActivation ℓ (activation s i)
  rows : ∀s,Fin F → EuclideanSpace ℝ (Fin (fixedInputWidth d F s))
  row_energy : ∀s,(∑i,‖rows s i‖^2)≤K^2

def fixedActivationState {d F : ℕ} {ℓ K : ℝ}
    (W : FixedActivationNetwork d F ℓ K) (x : Cube d) :
    ∀s,EuclideanSpace ℝ (Fin (fixedInputWidth d F s))
  | 0 => concreteInput x
  | s+1 => WithLp.toLp 2 (fun i => W.activation s i ⟪W.rows s i,fixedActivationState W x s⟫)

def zeroFixedActivationNetwork (d F : ℕ) (ℓ K : ℝ) (hℓ : 0≤ℓ) :
    FixedActivationNetwork d F ℓ K where
  activation := fun _ _ _ => 0
  activation_class := fun _ _ => ⟨rfl,fun x y => by
    simpa only [sub_self,abs_zero] using mul_nonneg hℓ (abs_nonneg (x-y))⟩
  rows := fun _ _ => 0
  row_energy := by intro s; simpa using sq_nonneg K

def FixedActivationNetwork.update {d F : ℕ} {ℓ K : ℝ}
    (W : FixedActivationNetwork d F ℓ K) (s : ℕ)
    (ψ : Fin F → ℝ → ℝ)
    (R : Fin F → EuclideanSpace ℝ (Fin (fixedInputWidth d F s)))
    (hψ : ∀i,zeroLipschitzActivation ℓ (ψ i))
    (hR : (∑i,‖R i‖^2)≤K^2) : FixedActivationNetwork d F ℓ K where
  activation := Function.update W.activation s ψ
  activation_class := by
    intro t i
    by_cases ht : t=s
    · subst t; simpa using hψ i
    · simpa [Function.update_of_ne ht] using W.activation_class t i
  rows := Function.update W.rows s R
  row_energy := by
    intro t
    by_cases ht : t=s
    · subst t; simpa using hR
    · simpa [Function.update_of_ne ht] using W.row_energy t

theorem FixedActivationNetwork.update_state_le {d F : ℕ} {ℓ K : ℝ}
    (W : FixedActivationNetwork d F ℓ K) (s : ℕ)
    (ψ : Fin F → ℝ → ℝ)
    (R : Fin F → EuclideanSpace ℝ (Fin (fixedInputWidth d F s)))
    (hψ : ∀i,zeroLipschitzActivation ℓ (ψ i))
    (hR : (∑i,‖R i‖^2)≤K^2) (x : Cube d) (t : ℕ) (ht : t≤s) :
    fixedActivationState (W.update s ψ R hψ hR) x t=fixedActivationState W x t := by
  induction t with
  | zero => rfl
  | succ t ih =>
    have hts : t≠s := by omega
    change WithLp.toLp 2 (fun i => (Function.update W.activation s ψ t) i
      ⟪Function.update W.rows s R t i,fixedActivationState (W.update s ψ R hψ hR) x t⟫)=_
    rw [Function.update_of_ne hts,Function.update_of_ne hts,ih (by omega)]
    rfl

theorem FixedActivationNetwork.update_state_succ {d F : ℕ} {ℓ K : ℝ}
    (W : FixedActivationNetwork d F ℓ K) (s : ℕ)
    (ψ : Fin F → ℝ → ℝ)
    (R : Fin F → EuclideanSpace ℝ (Fin (fixedInputWidth d F s)))
    (hψ : ∀i,zeroLipschitzActivation ℓ (ψ i))
    (hR : (∑i,‖R i‖^2)≤K^2) (x : Cube d) (i : Fin F) :
    fixedActivationState (W.update s ψ R hψ hR) x (s+1) i=
      ψ i ⟪R i,fixedActivationState W x s⟫ := by
  change (Function.update W.activation s ψ s) i
    ⟪Function.update W.rows s R s i,fixedActivationState (W.update s ψ R hψ hR) x s⟫=_
  rw [Function.update_self,Function.update_self,W.update_state_le s ψ R hψ hR x s (le_refl _)]

def FixedActivationNetwork.toRaw {d F : ℕ} {ℓ K : ℝ}
    (W : FixedActivationNetwork d F ℓ K) (hF : 0<F) (H : ℕ)
    (v : EuclideanSpace ℝ (Fin (fixedInputWidth d F H))) (hv : ‖v‖≤K) :
    RawAuxiliaryNetwork d H ℓ K where
  width := fun _ => F
  width_pos := fun _ => hF
  activation := W.activation
  activation_class := W.activation_class
  rows := W.rows
  row_energy := W.row_energy
  readout := v
  readout_norm := hv

theorem FixedActivationNetwork.toRaw_state {d F : ℕ} {ℓ K : ℝ}
    (W : FixedActivationNetwork d F ℓ K) (hF : 0<F) (H : ℕ)
    (v : EuclideanSpace ℝ (Fin (fixedInputWidth d F H))) (hv : ‖v‖≤K)
    (x : Cube d) (s : ℕ) :
    rawAuxiliaryState (W.toRaw hF H v hv) x s=fixedActivationState W x s := by
  induction s with
  | zero => rfl
  | succ s ih =>
    change WithLp.toLp 2 (fun i => W.activation s i
      ⟪W.rows s i,rawAuxiliaryState (W.toRaw hF H v hv) x s⟫)=_
    rw [ih]
    rfl

end NeuralGeneralization.BatchTwoActivation
