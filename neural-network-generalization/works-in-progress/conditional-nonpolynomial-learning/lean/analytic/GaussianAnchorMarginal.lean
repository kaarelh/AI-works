import GaussianAnchorLaws

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.GaussianFieldCovariance

variable {X I J : Type*} [Fintype X] [DecidableEq X] [Fintype I] [Fintype J]

def maskedField (A : X → I → ℝ) (S : Finset X) (x : X) : I → ℝ :=
  if x∈S then A x else 0

lemma maskedField_linear (A : X → I → ℝ) (S : Finset X) :
    fieldLinear (maskedField A S)=maskCoordinates S ∘ fieldLinear A := by
  funext z x
  by_cases hx : x∈S <;> simp [maskedField,maskCoordinates,fieldLinear_apply,hx]

lemma fieldLaw_masked (A : X → I → ℝ) (S : Finset X) :
    fieldLaw (maskedField A S)=(fieldLaw A).map (maskCoordinates S) := by
  unfold fieldLaw
  rw [Measure.map_map (measurable_maskCoordinates S) (fieldLinear A).continuous.measurable]
  rw [maskedField_linear]

/-- Only the anchor block is needed to identify the actual Gaussian anchor
marginal; no query cross covariance is assumed. -/
theorem gaussian_anchor_marginal_eq (A : X → I → ℝ) (B : X → J → ℝ) (S : Finset X)
    (hGram : ∀x∈S,∀y∈S,gram A x y=gram B x y) :
    (fieldLaw A).map (maskCoordinates S)=(fieldLaw B).map (maskCoordinates S) := by
  rw [← fieldLaw_masked,← fieldLaw_masked]
  apply fieldLaw_eq_of_gram_eq
  intro x y
  by_cases hx : x∈S
  · by_cases hy : y∈S
    · simpa only [gram,maskedField,if_pos hx,if_pos hy] using hGram x hx y hy
    · simp [gram,maskedField,hy]
  · simp [gram,maskedField,hx]

#print axioms gaussian_anchor_marginal_eq
end ConditionalNonpolynomial.Analytic
