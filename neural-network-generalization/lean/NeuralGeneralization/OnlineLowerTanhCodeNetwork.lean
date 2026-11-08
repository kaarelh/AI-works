import NeuralGeneralization.OnlineLowerTanhBalancedCode
import NeuralGeneralization.OnlineLowerTanhOddProjection
import NeuralGeneralization.OnlineLowerNetworkActivation

/-! Actual finite tanh-network Fourier cost and odd-downward deficit bounds.
The single-parity theorem is explicit until the global intrinsic proof is
instantiated; no posterior or minimum-cost premise is used here. -/
noncomputable section
open scoped BigOperators Classical
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerRelu OnlineLowerGeometry ConcreteModel

/-- Literal costs on the actual physical supports of a column code. -/
def codeBalancedCost {d m:ℕ} (C:WalshCodeMap d m) (s:Finset (Fin m)):ℝ:=
  balancedCost ((C.support s).card/2)

lemma codeBalancedCost_pos {d m:ℕ} (C:WalshCodeMap d m) (s:Finset (Fin m)):
    0<codeBalancedCost C s:=balancedCost_pos _

lemma carrier_orientation_injective {p m:ℕ} (size:Fin p→Bool→ℕ)
    (column:Fin p→Finset (Fin m)) (C:WalshCodeMap (carrierDimension size) m)
    (hsupport:∀s,C.support s=carrierSupport size column s):
    Function.Injective (railOrientation column) := by
  intro s t h
  apply C.support_injective
  rw [hsupport,hsupport,carrierSupport_eq_transversal,carrierSupport_eq_transversal,h]

lemma codeBalancedCost_orientation {p m:ℕ} (size:Fin p→Bool→ℕ)
    (column:Fin p→Finset (Fin m)) (C:WalshCodeMap (carrierDimension size) m)
    (hsupport:∀s,C.support s=carrierSupport size column s) (s:Finset (Fin m)):
    codeBalancedCost C s=carrierBalancedCost size (railOrientation column s) := by
  unfold codeBalancedCost carrierBalancedCost
  rw [hsupport,carrierSupport_eq_transversal]

lemma carrierCodeMass_retained_image {p m:ℕ} (size:Fin p→Bool→ℕ)
    (column:Fin p→Finset (Fin m)) (C:WalshCodeMap (carrierDimension size) m)
    (hsupport:∀s,C.support s=carrierSupport size column s)
    (bias:ℝ) (u:Fin (carrierDimension size)→ℝ):
    carrierCodeMass size (Finset.univ.image (railOrientation column)) (carrierBalancedCost size) bias u =
      retainedFourierMass C.support (codeBalancedCost C)
        (fun x=>Real.tanh (cubeAffine bias u x)) := by
  unfold carrierCodeMass retainedFourierMass
  rw [Finset.sum_image]
  · apply Finset.sum_congr rfl
    intro s _
    rw [codeBalancedCost_orientation size column C hsupport,
      hsupport,carrierSupport_eq_transversal]
    rfl
  · exact fun s _ t _ h=>carrier_orientation_injective size column C hsupport h

/-- The actual shallow network has a learner-width-independent normalized
Fourier budget and a polynomial odd-downward residual bound. -/
theorem actual_tanh_network_bounds_of_intrinsic :
    ∃k₀ p₀:ℕ,1≤k₀ ∧ 3≤p₀ ∧
      ∀p r m:ℕ,p₀≤p → (k₀:ℝ)*(Real.log ((p:ℝ)+2))^2≤(2*r:ℕ) →
      ∀size:Fin p→Bool→ℕ,(∀i s,2*r≤size i s) → (∀i s,size i s≤4*r) →
      (∀i s,Even (size i s)) → ∀column:Fin p→Finset (Fin m),
      ∀C:WalshCodeMap (carrierDimension size) m,
      (∀s,C.support s=carrierSupport size column s) →
      (∀s,IntrinsicParityBound (C.support s).card (codeBalancedCost C s)) →
      ∀N:ℕ,0<N → ∀net:Weights (carrierDimension size) N 0,
      weightedWalshCost (codeBalancedCost C) (C.logicalProjection (networkOutput Real.tanh net))≤
        networkVariationBudget net ∧
      uniformCubeMean (fun x=>(networkOutput Real.tanh net x-
        fourierProject (carrierOddDownwardSupports size column) (networkOutput Real.tanh net) x)^2)≤
        (82948*((p*(2*r):ℕ):ℝ)^2)*networkVariationBudget net*
          (networkVariationBudget net-
            weightedWalshCost (codeBalancedCost C) (C.logicalProjection (networkOutput Real.tanh net))) := by
  obtain ⟨k₀,p₀,hk,hp,hcode⟩:=carrierBalancedCode_exact_of_intrinsic
  refine ⟨k₀,p₀,hk,hp,?_⟩
  intro p r m hpp hR size hlo hhi heven column C hsupport hsharp N hN net
  let A:=Finset.univ.image (railOrientation column)
  have hA:A.Nonempty:=Finset.Nonempty.image ⟨∅,Finset.mem_univ _⟩ _
  have hsharpA:∀θ∈A,IntrinsicParityBound (carrierTransversal size θ).card (carrierBalancedCost size θ):=by
    intro θ hθ
    obtain ⟨s,_,rfl⟩:=Finset.mem_image.mp hθ
    have ht:=hsharp s
    rw [codeBalancedCost_orientation size column C hsupport,hsupport,carrierSupport_eq_transversal] at ht
    exact ht
  have hrow (bias:ℝ) (u:Fin (carrierDimension size)→ℝ):=
    hcode p r hpp hR size hlo hhi heven A hA hsharpA bias u
  apply network_logical_cost_and_deficit (by unfold carrierDimension;omega) hN C
    (codeBalancedCost C) (fun s=>(codeBalancedCost_pos C s).le)
    (carrierOddDownwardSupports size column) Real.tanh net
    (82948*((p*(2*r):ℕ):ℝ)^2) (by positivity)
  · intro j
    have ht:=(hrow (incomingBias net j) (incomingPhysical net j)).1
    rw [carrierCodeMass_retained_image size column C hsupport] at ht
    exact ht
  · intro j
    obtain ⟨θ,hθ,hθbound⟩:=(hrow (incomingBias net j) (incomingPhysical net j)).2
    obtain ⟨s,_,rfl⟩:=Finset.mem_image.mp hθ
    have hpj:=tanh_carrier_projection_le_support_energy size column s
      (incomingBias net j) (incomingPhysical net j)
    rw [carrierSupport_eq_transversal] at hpj
    have htotal:=hpj.trans hθbound
    rw [carrierCodeMass_retained_image size column C hsupport] at htotal
    exact htotal

end NeuralGeneralization.OnlineLowerTanh
