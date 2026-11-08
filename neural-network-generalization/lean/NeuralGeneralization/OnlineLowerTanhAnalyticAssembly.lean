import NeuralGeneralization.OnlineLowerTanhConstructionAssembly
import NeuralGeneralization.OnlineLowerTanhScalarCertificate

/-! The concrete tanh theorem reduced to the sole remaining intrinsic
single-parity theorem. All scalar path, teacher, full-code, protocol,
finite-width and actual Gaussian posterior statements are discharged. -/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLower
open ConcreteModel OnlineLowerTanh

/-- This is the final assembly interface, with its one analytic hypothesis
stated explicitly. The unconditional main theorem instantiates that
hypothesis with the global intrinsic proof. -/
theorem tanh_concrete_of_intrinsic
    (hsharp:∃r₀:ℕ,∀r:ℕ,r₀≤r → IntrinsicParityBound (2*r+1) (balancedCost r)) :
    TanhConcreteMainStatement := by
  obtain ⟨K,hK,hprotocol⟩:=Family.eventual_construction_protocols_of_intrinsic_and_scalar hsharp
  have hscalar:=Family.construction_rectangle_scalar_certificate_eventually actualGainBranch K hK
  have hp:=hprotocol K le_rfl hK (by
    filter_upwards [hscalar] with k hk
    exact ⟨_,_,hk.2⟩)
  obtain ⟨k₀,hk₀⟩:=eventually_atTop.mp hp
  refine ⟨K,hK,max 3 k₀,le_max_left _ _,?_⟩
  intro k hk
  exact hk₀ k ((le_max_right _ _).trans hk)

end NeuralGeneralization.OnlineLower
