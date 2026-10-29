import CanonicalProgramState

/-! Canonical anchor states at the literal physical scaling 0<t≤1.
Only preactivation coefficients are multiplied by t; the hidden feature
states and original per-layer entropy charges remain unchanged. -/
noncomputable section
set_option maxHeartbeats 2500000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
def CanonicalProgramState.physicalAnchorInvariant {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (S : Finset (Cube d)) (j : ℕ)
    (B : CanonicalProgramState d) : Prop :=
  ∀x∈S,∀y∈S,inner ℝ (B.feature x) (B.feature y)=inner ℝ (P.feature j x) (P.feature j y)

/-- One actual canonical layer: Gaussian-coordinate control, original anchor
law, cost bound, and exact canonical-map evaluation (up to an isometry). -/
def PhysicalCanonicalProgramStep {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (S : Finset (Cube d)) (j : ℕ)
    (B C : CanonicalProgramState d) : Prop :=
  ∃L : Measure (B.Index → ℝ), ∃hprob : IsProbabilityMeasure L,
    letI := hprob;
    ∃hKL : klDiv L (standardLaw B.Index)≠∞,
      (klDiv L (standardLaw B.Index)).toReal≤
        (klDiv (P.law j) (fieldLaw (scaledFeatureCoefficients t (P.feature j)))).toReal ∧
      L.map (maskCoordinates S ∘ fieldLinear (scaledFeatureCoefficients t B.feature))=
        (P.law j).map (maskCoordinates S) ∧
      L.map (fieldLinear (scaledFeatureCoefficients t B.feature))=
        fieldAnchorReplacement (P.law j) (fieldLaw (scaledFeatureCoefficients t B.feature))
          (maskCoordinates S) ∧
      ∃e : EuclideanSpace ℝ (CanonicalIndex L hKL (fun x:S => t • B.feature x)) →ₗᵢ[ℝ]
          EuclideanSpace ℝ C.Index,
        ∀x,C.feature x=e (canonicalGaussianMap L hKL (fun u:S => t • B.feature u) (t • B.feature x))

/-- Every anchor-consistent state can be extended by an actual finite-KL
canonical layer, preserving the next anchor block exactly. -/
theorem physical_canonical_program_step_exists {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) (S : Finset (Cube d)) (j : ℕ) (hj : j<H)
    (B : CanonicalProgramState d) (hB : B.physicalAnchorInvariant P S j) :
    ∃C : CanonicalProgramState d, PhysicalCanonicalProgramStep P S j B C ∧
      C.physicalAnchorInvariant P S (j+1) ∧ C.dimension≤B.dimension+S.card+1 := by
  letI := P.probability j hj
  obtain ⟨L,hL,hKL,hcost,hmap,hreplacement⟩ := canonical_anchor_control
    (scaledFeatureCoefficients t (P.feature j)) (fun x => t • B.feature x) (P.law j) (P.finiteKL j hj) S (by
      intro x hx y hy
      have hh := hB x hx y hy
      rw [scaledFeatureCoefficients_gram,real_inner_smul_left,real_inner_smul_right]
      rw [hh]
      ring)
  letI := hL
  let C : CanonicalProgramState d :=
    { Index := CanonicalIndex L hKL (fun u:S => t • B.feature u)
      feature := fun x => canonicalGaussianMap L hKL (fun u:S => t • B.feature u) (t • B.feature x) }
  obtain ⟨hmom,hdim⟩ := canonical_anchor_step_moments (fun x => t • B.feature x) (P.law j) S L hKL hmap
  refine ⟨C,?_,?_,hdim⟩
  · refine ⟨L,hL,hKL,hcost,hmap,hreplacement,LinearIsometry.id,?_⟩
    intro x
    rfl
  · intro x hx y hy
    exact (hmom x hx y hy).trans (P.recursion j hj x y).symm

#print axioms physical_canonical_program_step_exists
end ConditionalNonpolynomial.Analytic
