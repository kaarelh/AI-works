import CanonicalAnchorStep
import ControlledMarginPath

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

/-- A finite-dimensional query program state. It need not preserve the full
query-query covariance of the underlying genuine controlled path. -/
structure CanonicalProgramState (d : ℕ) where
  Index : Type
  [finite : Fintype Index]
  feature : Cube d → EuclideanSpace ℝ Index

attribute [instance] CanonicalProgramState.finite

def CanonicalProgramState.dimension {d : ℕ} (B : CanonicalProgramState d) : ℕ :=
  Fintype.card B.Index

def CanonicalProgramState.anchorInvariant {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (S : Finset (Cube d)) (j : ℕ)
    (B : CanonicalProgramState d) : Prop :=
  ∀x∈S,∀y∈S,inner ℝ (B.feature x) (B.feature y)=inner ℝ (P.feature j x) (P.feature j y)

/-- One actual canonical layer: Gaussian-coordinate control, original anchor
law, cost bound, and exact canonical-map evaluation (up to an isometry). -/
def CanonicalProgramStep {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (S : Finset (Cube d)) (j : ℕ)
    (B C : CanonicalProgramState d) : Prop :=
  ∃L : Measure (B.Index → ℝ), ∃hprob : IsProbabilityMeasure L,
    letI := hprob;
    ∃hKL : klDiv L (standardLaw B.Index)≠∞,
      (klDiv L (standardLaw B.Index)).toReal≤
        (klDiv (P.law j) (fieldLaw (scaledFeatureCoefficients 1 (P.feature j)))).toReal ∧
      L.map (maskCoordinates S ∘ fieldLinear (fun x i => B.feature x i))=
        (P.law j).map (maskCoordinates S) ∧
      L.map (fieldLinear (fun x i => B.feature x i))=
        fieldAnchorReplacement (P.law j) (fieldLaw (fun x i => B.feature x i))
          (maskCoordinates S) ∧
      ∃e : EuclideanSpace ℝ (CanonicalIndex L hKL (fun x:S => B.feature x)) →ₗᵢ[ℝ]
          EuclideanSpace ℝ C.Index,
        ∀x,C.feature x=e (canonicalGaussianMap L hKL (fun u:S => B.feature u) (B.feature x))

/-- Every anchor-consistent state can be extended by an actual finite-KL
canonical layer, preserving the next anchor block exactly. -/
theorem canonical_program_step_exists {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) (S : Finset (Cube d)) (j : ℕ) (hj : j<H)
    (B : CanonicalProgramState d) (hB : B.anchorInvariant P S j) :
    ∃C : CanonicalProgramState d, CanonicalProgramStep P S j B C ∧
      C.anchorInvariant P S (j+1) ∧ C.dimension≤B.dimension+S.card+1 := by
  letI := P.probability j hj
  obtain ⟨L,hL,hKL,hcost,hmap,hreplacement⟩ := canonical_anchor_control
    (scaledFeatureCoefficients 1 (P.feature j)) B.feature (P.law j) (P.finiteKL j hj) S (by
      intro x hx y hy
      have hh := hB x hx y hy
      rw [scaledFeatureCoefficients_gram,one_pow,one_mul]
      exact hh.symm)
  letI := hL
  let C : CanonicalProgramState d :=
    { Index := CanonicalIndex L hKL (fun u:S => B.feature u)
      feature := fun x => canonicalGaussianMap L hKL (fun u:S => B.feature u) (B.feature x) }
  obtain ⟨hmom,hdim⟩ := canonical_anchor_step_moments B.feature (P.law j) S L hKL hmap
  refine ⟨C,?_,?_,hdim⟩
  · refine ⟨L,hL,hKL,hcost,hmap,hreplacement,LinearIsometry.id,?_⟩
    intro x
    rfl
  · intro x hx y hy
    exact (hmom x hx y hy).trans (P.recursion j hj x y).symm

#print axioms canonical_program_step_exists
end ConditionalNonpolynomial.Analytic
