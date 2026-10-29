import CoordinateEntropyAnchors

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
namespace ConditionalAnalytic
open NeuralGeneralization
variable {X : Type*} [Fintype X] [DecidableEq X]

def coordinatePair (S : Finset X) (x : X) (z : X → ℝ) : (X → ℝ) × ℝ :=
  (maskCoordinates S z,z x)

def mergeCoordinate (x : X) (p : (X → ℝ) × ℝ) : X → ℝ :=
  fun y => if y=x then p.2 else p.1 y

@[fun_prop] lemma measurable_coordinatePair (S : Finset X) (x : X) :
    Measurable (coordinatePair S x) :=
  (measurable_maskCoordinates S).prodMk (measurable_pi_apply x)

@[fun_prop] lemma measurable_mergeCoordinate (x : X) : Measurable (mergeCoordinate x) := by
  apply measurable_pi_lambda
  intro y
  by_cases hy : y=x <;> simp only [mergeCoordinate,hy,ite_true,ite_false] <;> fun_prop

lemma merge_coordinatePair (S : Finset X) (x : X) :
    mergeCoordinate x ∘ coordinatePair S x = maskCoordinates (insert x S) := by
  funext z y
  by_cases hy : y=x
  · subst y
    simp [mergeCoordinate,coordinatePair,maskCoordinates]
  · simp [mergeCoordinate,coordinatePair,maskCoordinates,hy]

lemma coordinatePair_mask_insert (S : Finset X) (x : X) :
    coordinatePair S x ∘ maskCoordinates (insert x S) = coordinatePair S x := by
  funext z
  apply Prod.ext
  · exact congrFun (maskCoordinates_comp (Finset.subset_insert x S)) z
  · simp [coordinatePair,maskCoordinates]

/-- The anchor-plus-one-query joint law carries exactly the same information
as all coordinates in the augmented anchor set, with no nonsingularity
assumption on either measure. -/
theorem coordinatePair_klDiv (Q G : Measure (X → ℝ))
    [IsProbabilityMeasure Q] [IsProbabilityMeasure G] (S : Finset X) (x : X) :
    klDiv (Q.map (coordinatePair S x)) (G.map (coordinatePair S x)) =
      klDiv (Q.map (maskCoordinates (insert x S))) (G.map (maskCoordinates (insert x S))) := by
  have hp := measurable_coordinatePair S x
  have hm := measurable_maskCoordinates (insert x S)
  have hr := measurable_mergeCoordinate x
  letI : IsProbabilityMeasure (Q.map (coordinatePair S x)) := Measure.isProbabilityMeasure_map hp.aemeasurable
  letI : IsProbabilityMeasure (G.map (coordinatePair S x)) := Measure.isProbabilityMeasure_map hp.aemeasurable
  letI : IsProbabilityMeasure (Q.map (maskCoordinates (insert x S))) := Measure.isProbabilityMeasure_map hm.aemeasurable
  letI : IsProbabilityMeasure (G.map (maskCoordinates (insert x S))) := Measure.isProbabilityMeasure_map hm.aemeasurable
  apply le_antisymm
  · have h := RobustEntropy.klDiv_map_le (Q.map (maskCoordinates (insert x S)))
      (G.map (maskCoordinates (insert x S))) hp
    simpa only [Measure.map_map hp hm,coordinatePair_mask_insert] using h
  · have h := RobustEntropy.klDiv_map_le (Q.map (coordinatePair S x))
      (G.map (coordinatePair S x)) hr
    simpa only [Measure.map_map hr hp,merge_coordinatePair] using h

lemma coordinatePair_fst (Q : Measure (X → ℝ)) (S : Finset X) (x : X) :
    (Q.map (coordinatePair S x)).fst=Q.map (maskCoordinates S) := by
  unfold coordinatePair
  rw [Measure.fst_map_prodMk (measurable_pi_apply x)]

#print axioms coordinatePair_klDiv
end ConditionalAnalytic
