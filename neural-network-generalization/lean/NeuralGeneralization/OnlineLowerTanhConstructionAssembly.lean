import NeuralGeneralization.OnlineLowerTanhFamilyAssembly
import NeuralGeneralization.OnlineLowerTanhConstructionThresholds
import NeuralGeneralization.OnlineLowerTanhConcreteStatement

/-! # Concrete logarithmic-rail tanh protocol assembly

The analytic single-parity and scalar path statements remain explicit inputs
here. Every teacher, integer rail threshold, actual neural score constraint,
width limit and Gaussian posterior consequence is proved from those inputs.
-/
noncomputable section
open scoped BigOperators Classical Topology
open Filter
namespace NeuralGeneralization.OnlineLowerTanh.Family
open ConcreteModel OnlineLower OnlineLowerGeometry

/-- The only remaining inputs are the literal eventual intrinsic parity
inequality and the actual scalar path certificate. No construction or
posterior property is assumed. -/
theorem eventual_construction_protocols_of_intrinsic_and_scalar
    (hsharp:∃r₀:ℕ,∀r:ℕ,r₀≤r → IntrinsicParityBound (2*r+1) (balancedCost r)) :
    ∃K₀:ℕ,1≤K₀ ∧ ∀K:ℕ,∀hK:K₀≤K,∀hK1:1≤K,
      (∀ᶠk:ℕ in atTop,∃W Bcap:ℝ,∀hk:3≤k,
        RectangleScalarCertificate (constructionBaseline K k) (constructionIncrement k) k
          (constructionBaseline_pos K k (by omega)) (constructionIncrement_pos k) hk W Bcap) →
      ∀ᶠk:ℕ in atTop,
        BoundedTeacher Real.tanh (constructionTarget K k) (constructionTeacherWidth K k) ∧
        HasCircuitAtMost (constructionTarget K k) (17*constructionDimension K k+5) ∧
        ∃π:InputOrder (constructionDimension K k),
        ∃J:Finset (Fin (Fintype.card (Cube (constructionDimension K k)))),
          TanhConcreteProtocol K k π J := by
  obtain ⟨k₀,p₀,hk₀,hp₀,hgaps⟩:=concrete_stage_gaps_of_intrinsic_and_scalar
  refine ⟨max 1 (2*k₀),le_max_left _ _,?_⟩
  intro K hK hK1 hscalar
  have hK₂:2*k₀≤K:=(le_max_right _ _).trans hK
  filter_upwards [construction_resources_eventually K hK1,
    construction_code_thresholds_eventually k₀ p₀ K hK1 hK₂,
    construction_intrinsic_eventually hsharp K hK1,hscalar,eventually_ge_atTop 3]
    with k hresources hthreshold hsharpk hscalark hk
  obtain ⟨W,Bcap,hcert⟩:=hscalark
  obtain ⟨π,J,hcount,hstage⟩:=hgaps
    (constructionBaseline K k) (constructionIncrement k) k hthreshold.2.1
    (constructionBaseline_even K k) (constructionIncrement_pos k) (constructionIncrement_even k)
    hk hthreshold.1 hthreshold.2.2.1 hthreshold.2.2.2 hsharpk W Bcap (hcert hk)
  refine ⟨hresources.2.2.1,hresources.2.2.2.1,π,J,hcount,?_⟩
  apply allLargeWidthsFail_of_eventual_energy_gaps (constructionDimension_pos K k)
    TanhDifferential.continuous_tanh hresources.2.2.1 π J
  intro j hj
  obtain ⟨N₀,_,hN⟩:=hstage j hj
  exact ⟨N₀,hN⟩

end NeuralGeneralization.OnlineLowerTanh.Family
