import NeuralGeneralization.BatchTwoActivationProductNormalization
import NeuralGeneralization.SamplingNetwork

/-! The original same-activation network is a product-normalized auxiliary
network with exactly its product of actual Frobenius norms. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel CompressionSampling

def physicalRows {d N r : ℕ} (w:Weights d N r) :
    ∀s,Fin N→EuclideanSpace ℝ (Fin (auxiliaryWidth d (fun _=>N) s))
  | 0=>fun i=>WithLp.toLp 2 (fun j=>w (.inl (i,j)))
  | s+1=>if hs:s<r then fun i=>WithLp.toLp 2 (fun j=>w (.inr (.inl (⟨s,hs⟩,i,j)))) else fun _=>0

def physicalProductNetwork {d N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (w:Weights d N r):ProductNetwork d (r+1) ℓ where
  width:=fun _=>N
  width_pos:=fun _=>hN
  activation:=fun _ _=>φ
  activation_class:=fun _ _=>hφ
  rows:=physicalRows w
  readout:=WithLp.toLp 2 (fun j=>w (.inr (.inr j)))

theorem physicalProductNetwork_hidden {d N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (w:Weights d N r) (x:Cube d)
    (s:ℕ) (hs:s≤r):
    productNetworkState (physicalProductNetwork hN hφ w) x (s+1)=WithLp.toLp 2 (hiddenPrefix φ w x s):=by
  induction s with
  | zero=>
    apply PiLp.ext
    intro j
    change φ ⟪WithLp.toLp 2 (fun k=>w (.inl (j,k))),concreteInput x⟫=hiddenPrefix φ w x 0 j
    simp only [hiddenPrefix_zero,firstHidden,PiLp.inner_apply,RCLike.inner_apply,conj_trivial,concreteInput,PiLp.toLp_apply]
    congr 1
    apply Finset.sum_congr rfl
    intro k _
    ring
  | succ s ih=>
    have hsr:s<r:=by omega
    have hi:=ih (by omega)
    apply PiLp.ext
    intro j
    change φ ⟪physicalRows w (s+1) j,productNetworkState (physicalProductNetwork hN hφ w) x (s+1)⟫=_
    rw [hi]
    simp only [physicalRows,dif_pos hsr]
    have he:=hiddenPrefix_succ φ w x (⟨s,hsr⟩:Fin r)
    change hiddenPrefix φ w x (s+1)=_ at he
    rw [he]
    simp only [hiddenStep,PiLp.inner_apply,RCLike.inner_apply,conj_trivial,PiLp.toLp_apply]
    congr 1
    apply Finset.sum_congr rfl
    intro k _
    ring

theorem physicalProductNetwork_output {d N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (w:Weights d N r) (x:Cube d):
    productNetworkOutput (physicalProductNetwork hN hφ w) x=networkOutput φ w x:=by
  unfold productNetworkOutput
  rw [physicalProductNetwork_hidden hN hφ w x r le_rfl,hiddenPrefix_last]
  simp only [physicalProductNetwork,PiLp.inner_apply,RCLike.inner_apply,conj_trivial,PiLp.toLp_apply,networkOutput]
  apply Finset.sum_congr rfl
  intro j _
  ring

def physicalProduct {d N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (w:Weights d N r):ℝ:=
  let W:=physicalProductNetwork hN hφ w
  ‖W.readout‖*∏s∈Finset.range (r+1),layerFrobenius W s

theorem physicalProduct_nonneg {d N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (w:Weights d N r):
    0≤physicalProduct hN hφ w:=by
  apply mul_nonneg (norm_nonneg _) (Finset.prod_nonneg _)
  intro s _
  exact layerFrobenius_nonneg _ _

theorem physicalProductNetwork_normalization {d N r : ℕ} {φ:ℝ→ℝ} {ℓ:ℝ}
    (hN:0<N) (hφ:zeroLipschitzActivation ℓ φ) (hℓ:0<ℓ) (w:Weights d N r):
    ∃W:AuxiliaryNetwork d (r+1),∀x,networkOutput φ w x=
      auxiliaryOutput W (ℓ^(r+1)*physicalProduct hN hφ w) x:=by
  refine ⟨normalizeProductNetwork (physicalProductNetwork hN hφ w) hℓ,?_⟩
  intro x
  rw [←physicalProductNetwork_output hN hφ w x]
  have hh:=normalizeProductNetwork_output (physicalProductNetwork hN hφ w) hℓ x
  simpa only [physicalProduct,mul_assoc] using hh

end NeuralGeneralization.BatchTwoActivation
