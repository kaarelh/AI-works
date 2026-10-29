import CoordinateAnchorCoupling
import BoundedTiltLift
import NeuralGeneralization.GaussianFieldCovariance

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice
open NeuralGeneralization.GaussianFieldTilt NeuralGeneralization.GaussianFieldCovariance

variable {X I J : Type*} [Fintype X] [DecidableEq X] [Fintype I] [Fintype J]

def anchorQueryField (A : X → I → ℝ) (S : Finset X) (x : X) : X ⊕ Unit → I → ℝ
  | .inl y => if y∈S then A y else 0
  | .inr _ => A x

def unpackAnchorQuery (z : X ⊕ Unit → ℝ) : (X → ℝ) × ℝ :=
  (fun y => z (.inl y),z (.inr ()))

lemma measurable_unpackAnchorQuery : Measurable (unpackAnchorQuery (X:=X)) := by
  unfold unpackAnchorQuery
  fun_prop

lemma anchorQueryField_linear (A : X → I → ℝ) (S : Finset X) (x : X) :
    unpackAnchorQuery ∘ fieldLinear (anchorQueryField A S x)=coordinatePair S x ∘ fieldLinear A := by
  funext z
  apply Prod.ext
  · funext y
    by_cases hy : y∈S
    · simp [unpackAnchorQuery,anchorQueryField,coordinatePair,maskCoordinates,hy,fieldLinear_apply]
    · simp [unpackAnchorQuery,anchorQueryField,coordinatePair,maskCoordinates,hy,fieldLinear_apply]
  · rfl

lemma fieldLaw_anchorQuery (A : X → I → ℝ) (S : Finset X) (x : X) :
    (fieldLaw (anchorQueryField A S x)).map unpackAnchorQuery=
      (fieldLaw A).map (coordinatePair S x) := by
  unfold fieldLaw
  rw [Measure.map_map measurable_unpackAnchorQuery (fieldLinear _).continuous.measurable,
    Measure.map_map (measurable_coordinatePair S x) (fieldLinear A).continuous.measurable,
    anchorQueryField_linear]

lemma anchorQueryField_gram_eq (A : X → I → ℝ) (B : X → J → ℝ) (S : Finset X) (x : X)
    (hanchor : ∀u∈S,∀v,gram A u v=gram B u v)
    (hdiag : gram A x x=gram B x x) :
    ∀u v,gram (anchorQueryField A S x) u v=gram (anchorQueryField B S x) u v := by
  intro u v
  cases u with
  | inl u =>
    cases v with
    | inl v =>
      by_cases hu : u∈S
      · by_cases hv : v∈S
        · simpa only [gram,anchorQueryField,if_pos hu,if_pos hv] using hanchor u hu v
        · simp [gram,anchorQueryField,hv]
      · simp [gram,anchorQueryField,hu]
    | inr v =>
      by_cases hu : u∈S
      · simpa only [gram,anchorQueryField,if_pos hu] using hanchor u hu x
      · simp [gram,anchorQueryField,hu]
  | inr u =>
    cases v with
    | inl v =>
      by_cases hv : v∈S
      · have hh := hanchor v hv x
        simpa only [gram,anchorQueryField,if_pos hv,mul_comm] using hh
      · simp [gram,anchorQueryField,hv]
    | inr v => exact hdiag

/-- Gaussian anchor-plus-one-query laws depend only on the preserved anchor
cross entries and query variance. Full query-query covariance is not asserted
or needed, including when either Gaussian field is singular. -/
theorem gaussian_anchor_query_law_eq (A : X → I → ℝ) (B : X → J → ℝ)
    (S : Finset X) (x : X)
    (hanchor : ∀u∈S,∀v,gram A u v=gram B u v)
    (hdiag : gram A x x=gram B x x) :
    (fieldLaw A).map (coordinatePair S x)=(fieldLaw B).map (coordinatePair S x) := by
  have hh := fieldLaw_eq_of_gram_eq (anchorQueryField A S x) (anchorQueryField B S x)
    (anchorQueryField_gram_eq A B S x hanchor hdiag)
  have hm := congrArg (fun μ => μ.map unpackAnchorQuery) hh
  rwa [fieldLaw_anchorQuery,fieldLaw_anchorQuery] at hm

/-- An anchor-dependent tilt commutes with the actual anchor/query projection. -/
theorem anchor_tilt_query_law (G : Measure (X → ℝ)) (S : Finset X) (x : X)
    (V : (X → ℝ) → ℝ) (hV : Measurable V) :
    (G.tilted (V ∘ maskCoordinates S)).map (coordinatePair S x)=
      (G.map (coordinatePair S x)).tilted (V ∘ Prod.fst) := by
  exact map_tilted_pullback G (coordinatePair S x) (measurable_coordinatePair S x)
    (V ∘ Prod.fst) (hV.comp measurable_fst)

/-- Exact query-law transfer for arbitrary measurable anchor potentials.
This is the Gaussian factorization statement used by the canonical program. -/
theorem gaussian_anchor_tilt_query_eq (A : X → I → ℝ) (B : X → J → ℝ)
    (S : Finset X) (x : X)
    (hanchor : ∀u∈S,∀v,gram A u v=gram B u v)
    (hdiag : gram A x x=gram B x x)
    (V : (X → ℝ) → ℝ) (hV : Measurable V) :
    ((fieldLaw A).tilted (V ∘ maskCoordinates S)).map (coordinatePair S x)=
      ((fieldLaw B).tilted (V ∘ maskCoordinates S)).map (coordinatePair S x) := by
  rw [anchor_tilt_query_law,anchor_tilt_query_law,
    gaussian_anchor_query_law_eq A B S x hanchor hdiag]
  all_goals exact hV

/-- Under a bounded anchor potential, both full Gaussian tilts have exactly
same KL, even though their uncontrolled query-query covariances may differ. -/
theorem gaussian_anchor_tilt_kl_eq (A : X → I → ℝ) (B : X → J → ℝ)
    (S : Finset X) (x : X)
    (hanchor : ∀u∈S,∀v,gram A u v=gram B u v)
    (hdiag : gram A x x=gram B x x)
    (V : (X → ℝ) → ℝ) (hV : Measurable V) {K : ℝ} (hVbound : ∀z,|V z|≤K) :
    (klDiv ((fieldLaw A).tilted (V ∘ maskCoordinates S)) (fieldLaw A)).toReal=
      (klDiv ((fieldLaw B).tilted (V ∘ maskCoordinates S)) (fieldLaw B)).toReal := by
  have hpair := gaussian_anchor_query_law_eq A B S x hanchor hdiag
  have hm := congrArg Measure.fst hpair
  rw [coordinatePair_fst,coordinatePair_fst] at hm
  rw [klDiv_tilted_pullback (fieldLaw A) (maskCoordinates S) (measurable_maskCoordinates S) V hV hVbound,
    klDiv_tilted_pullback (fieldLaw B) (maskCoordinates S) (measurable_maskCoordinates S) V hV hVbound,hm]

#print axioms gaussian_anchor_query_law_eq
#print axioms gaussian_anchor_tilt_query_eq
#print axioms gaussian_anchor_tilt_kl_eq
end ConditionalNonpolynomial.Analytic
