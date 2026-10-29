import FieldAnchorReplacement
import CoordinatePairEntropy

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy
open ConditionalAnalytic

variable {X : Type*} [Fintype X] [DecidableEq X]

/-- Explicit shared-anchor coupling of one actual field coordinate with its
query under the single field replacement. -/
def coordinateAnchorCoupling (Q G : Measure (X → ℝ)) [IsFiniteMeasure Q] [IsFiniteMeasure G]
    (S : Finset X) (x : X) : Measure ((X → ℝ) × (ℝ × ℝ)) :=
  sharedAnchorCoupling (Q.map (coordinatePair S x)) (G.map (coordinatePair S x))

lemma coordinateAnchorCoupling_probability (Q G : Measure (X → ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (S : Finset X) (x : X) :
    IsProbabilityMeasure (coordinateAnchorCoupling Q G S x) := by
  letI : IsProbabilityMeasure (Q.map (coordinatePair S x)) :=
    Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  letI : IsProbabilityMeasure (G.map (coordinatePair S x)) :=
    Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  unfold coordinateAnchorCoupling
  infer_instance

theorem coordinateAnchorCoupling_left (Q G : Measure (X → ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (S : Finset X) (x : X) :
    (coordinateAnchorCoupling Q G S x).map (fun p => (p.1,p.2.1))=Q.map (coordinatePair S x) := by
  letI : IsProbabilityMeasure (Q.map (coordinatePair S x)) :=
    Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  letI : IsProbabilityMeasure (G.map (coordinatePair S x)) :=
    Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  exact sharedAnchorCoupling_left _ _

theorem coordinateAnchorCoupling_right (Q G : Measure (X → ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (hKL : klDiv Q G≠∞)
    (S : Finset X) (x : X) :
    (coordinateAnchorCoupling Q G S x).map (fun p => (p.1,p.2.2))=
      (fieldAnchorReplacement Q G (maskCoordinates S)).map (coordinatePair S x) := by
  letI : IsProbabilityMeasure (Q.map (coordinatePair S x)) :=
    Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  letI : IsProbabilityMeasure (G.map (coordinatePair S x)) :=
    Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  have hh := sharedAnchorCoupling_right (Q.map (coordinatePair S x)) (G.map (coordinatePair S x))
  have hc := fieldAnchorReplacement_query Q G (measurable_maskCoordinates S) hKL (measurable_pi_apply x)
  exact hh.trans hc.symm

/-- Each selected-coordinate entropy increment directly controls the actual
coupling's tanh squared error. Both coordinate laws come from full measures. -/
theorem coordinateAnchorCoupling_tanh_error (Q G : Measure (X → ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (hKL : klDiv Q G≠∞)
    (S : Finset X) (x : X) {δ : ℝ} (hδ : 0<δ)
    (hgap : coordinateEntropy Q G (insert x S)-coordinateEntropy Q G S≤δ) :
    (∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂coordinateAnchorCoupling Q G S x)≤8*Real.sqrt δ := by
  letI : IsProbabilityMeasure (Q.map (coordinatePair S x)) :=
    Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  letI : IsProbabilityMeasure (G.map (coordinatePair S x)) :=
    Measure.isProbabilityMeasure_map (measurable_coordinatePair S x).aemeasurable
  have hfinite : klDiv (Q.map (coordinatePair S x)) (G.map (coordinatePair S x))≠∞ :=
    ne_top_of_le_ne_top hKL (klDiv_map_le Q G (measurable_coordinatePair S x))
  apply sharedAnchorCoupling_tanh_error _ _ hfinite hδ
  rw [coordinatePair_klDiv,coordinatePair_fst,coordinatePair_fst]
  exact hgap

/-- Finite-KL field laws admit one small common anchor set whose reference
conditional replacements preserve anchors exactly and approximate every
bounded tanh query through explicit shared-anchor couplings. -/
theorem actual_common_anchor_replacement {J : Type*} [Fintype J]
    (Q G : J → Measure (X → ℝ))
    (hQ : ∀j,IsProbabilityMeasure (Q j)) (hG : ∀j,IsProbabilityMeasure (G j))
    (hKL : ∀j,klDiv (Q j) (G j)≠∞) (δ : J → ℝ) (hδ : ∀j,0<δ j) :
    ∃S : Finset X, (S.card:ℝ)≤∑j,(klDiv (Q j) (G j)).toReal/δ j ∧
      ∀j, letI := hQ j; letI := hG j;
        (fieldAnchorReplacement (Q j) (G j) (maskCoordinates S)).map (maskCoordinates S)=
          (Q j).map (maskCoordinates S) ∧
        klDiv (fieldAnchorReplacement (Q j) (G j) (maskCoordinates S)) (G j)=
          klDiv ((Q j).map (maskCoordinates S)) ((G j).map (maskCoordinates S)) ∧
        ∀x,(∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂coordinateAnchorCoupling (Q j) (G j) S x)
          ≤8*Real.sqrt (δ j) := by
  obtain ⟨S,hcard,hinc⟩ := actual_entropy_anchors Q G hQ hG hKL δ hδ
  refine ⟨S,hcard,?_⟩
  intro j
  letI := hQ j
  letI := hG j
  refine ⟨fieldAnchorReplacement_anchors (Q j) (G j) (measurable_maskCoordinates S) (hKL j),
    fieldAnchorReplacement_kl (Q j) (G j) (measurable_maskCoordinates S) (hKL j),?_⟩
  intro x
  exact coordinateAnchorCoupling_tanh_error (Q j) (G j) (hKL j) S x (hδ j) (hinc j x)

#print axioms coordinateAnchorCoupling_right
#print axioms coordinateAnchorCoupling_tanh_error
#print axioms actual_common_anchor_replacement
end ConditionalNonpolynomial.Analytic
