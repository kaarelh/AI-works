import CoordinateAnchorCoupling
import ControlledL2Features
import AnchoredFeatureGluing

noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic

variable {X : Type*} [Fintype X] [DecidableEq X]

def anchorQueryIndex (S : Finset X) (x : X) : S ⊕ Unit → X :=
  Sum.elim Subtype.val (fun _ => x)

def anchorQueryTanh (S : Finset X) (i : S ⊕ Unit) (p : (X → ℝ) × ℝ) : ℝ :=
  match i with
  | .inl s => Real.tanh (p.1 s)
  | .inr _ => Real.tanh p.2

lemma measurable_anchorQueryTanh (S : Finset X) (i : S ⊕ Unit) :
    Measurable (anchorQueryTanh S i) := by
  cases i <;> unfold anchorQueryTanh <;> fun_prop

lemma abs_anchorQueryTanh_le_one (S : Finset X) (i : S ⊕ Unit) (p : (X → ℝ) × ℝ) :
    |anchorQueryTanh S i p| ≤ 1 := by
  cases i <;> exact (Real.abs_tanh_lt_one _).le

lemma anchorQueryTanh_coordinatePair (S : Finset X) (x : X) (i : S ⊕ Unit) (z : X → ℝ) :
    anchorQueryTanh S i (coordinatePair S x z)=Real.tanh (z (anchorQueryIndex S x i)) := by
  cases i with
  | inl s => simp [anchorQueryTanh,coordinatePair,maskCoordinates,s.property,anchorQueryIndex]
  | inr u => rfl

/-- Turn an actual common-anchor probability coupling into finite-dimensional
Hilbert features. This retains all endpoint anchor/query Gram entries, but
does not claim to retain cross-Grams between different queries. -/
theorem anchor_query_coupling_features
    (Q R : Measure (X → ℝ)) [IsProbabilityMeasure Q] [IsProbabilityMeasure R]
    (S : Finset X) (x : X)
    (M : Measure ((X → ℝ) × (ℝ × ℝ))) [IsProbabilityMeasure M]
    (hleft : M.map (fun p => (p.1,p.2.1))=Q.map (coordinatePair S x))
    (hright : M.map (fun p => (p.1,p.2.2))=R.map (coordinatePair S x))
    {ε : ℝ} (hε : 0≤ε)
    (herror : (∫p,(Real.tanh p.2.1-Real.tanh p.2.2)^2 ∂M)≤ε^2) :
    ∃U V : S ⊕ Unit → EuclideanSpace ℝ ((S ⊕ Unit) ⊕ (S ⊕ Unit)),
      (∀i j,inner ℝ (U i) (U j)=
        ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x j)) ∂Q) ∧
      (∀i j,inner ℝ (V i) (V j)=
        ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x j)) ∂R) ∧
      (∀s:S,U (.inl s)=V (.inl s)) ∧ ‖U (.inr ())-V (.inr ())‖≤ε := by
  let l : S ⊕ Unit → Lp ℝ 2 M := fun i =>
    boundedL2Feature M (fun p => anchorQueryTanh S i (p.1,p.2.1))
      ((measurable_anchorQueryTanh S i).comp (by fun_prop))
      (fun p => abs_anchorQueryTanh_le_one S i (p.1,p.2.1))
  let r : S ⊕ Unit → Lp ℝ 2 M := fun i =>
    boundedL2Feature M (fun p => anchorQueryTanh S i (p.1,p.2.2))
      ((measurable_anchorQueryTanh S i).comp (by fun_prop))
      (fun p => abs_anchorQueryTanh_le_one S i (p.1,p.2.2))
  obtain ⟨U,V,hU,hV,hUV,hdist⟩ := compress_feature_pair l r
  refine ⟨U,V,?_,?_,?_,?_⟩
  · intro i j
    rw [hU,boundedL2Feature_inner]
    have hm := congrArg (fun μ : Measure ((X → ℝ) × ℝ) =>
      ∫p,anchorQueryTanh S i p*anchorQueryTanh S j p ∂μ) hleft
    rw [integral_map (μ := M) (φ := fun p => (p.1,p.2.1))
      (f := fun p => anchorQueryTanh S i p * anchorQueryTanh S j p) (by fun_prop)
      ((measurable_anchorQueryTanh S i).mul (measurable_anchorQueryTanh S j)).aestronglyMeasurable,
      integral_map (f := fun p => anchorQueryTanh S i p * anchorQueryTanh S j p)
        (measurable_coordinatePair S x).aemeasurable
        ((measurable_anchorQueryTanh S i).mul (measurable_anchorQueryTanh S j)).aestronglyMeasurable] at hm
    simpa only [anchorQueryTanh_coordinatePair] using hm
  · intro i j
    rw [hV,boundedL2Feature_inner]
    have hm := congrArg (fun μ : Measure ((X → ℝ) × ℝ) =>
      ∫p,anchorQueryTanh S i p*anchorQueryTanh S j p ∂μ) hright
    rw [integral_map (μ := M) (φ := fun p => (p.1,p.2.2))
      (f := fun p => anchorQueryTanh S i p * anchorQueryTanh S j p) (by fun_prop)
      ((measurable_anchorQueryTanh S i).mul (measurable_anchorQueryTanh S j)).aestronglyMeasurable,
      integral_map (f := fun p => anchorQueryTanh S i p * anchorQueryTanh S j p)
        (measurable_coordinatePair S x).aemeasurable
        ((measurable_anchorQueryTanh S i).mul (measurable_anchorQueryTanh S j)).aestronglyMeasurable] at hm
    simpa only [anchorQueryTanh_coordinatePair] using hm
  · intro s
    apply sub_eq_zero.mp
    apply norm_eq_zero.mp
    rw [hdist]
    have he : l (.inl s)=r (.inl s) := rfl
    rw [he,sub_self,norm_zero]
  · rw [hdist]
    apply (sq_le_sq₀ (norm_nonneg _) hε).mp
    change ‖boundedL2Feature M _ _ _-boundedL2Feature M _ _ _‖^2≤ε^2
    rw [boundedL2Feature_norm_sub_sq]
    exact herror

/-- The actual selected-coordinate entropy increment gives an anchored
finite-dimensional feature coupling for the full replacement law. -/
theorem coordinate_anchor_replacement_features
    (Q G : Measure (X → ℝ)) [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G≠∞) (S : Finset X) (x : X) {δ : ℝ} (hδ : 0<δ)
    (hgap : coordinateEntropy Q G (insert x S)-coordinateEntropy Q G S≤δ) :
    ∃U V : S ⊕ Unit → EuclideanSpace ℝ ((S ⊕ Unit) ⊕ (S ⊕ Unit)),
      (∀i j,inner ℝ (U i) (U j)=
        ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x j)) ∂Q) ∧
      (∀i j,inner ℝ (V i) (V j)=
        ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x j))
          ∂fieldAnchorReplacement Q G (maskCoordinates S)) ∧
      (∀s:S,U (.inl s)=V (.inl s)) ∧
      ‖U (.inr ())-V (.inr ())‖≤Real.sqrt (8*Real.sqrt δ) := by
  letI := coordinateAnchorCoupling_probability Q G S x
  letI := fieldAnchorReplacement_probability Q G (measurable_maskCoordinates S)
  apply anchor_query_coupling_features Q _ S x (coordinateAnchorCoupling Q G S x)
    (coordinateAnchorCoupling_left Q G S x) (coordinateAnchorCoupling_right Q G hKL S x)
    (Real.sqrt_nonneg _)
  rw [Real.sq_sqrt (by positivity : 0≤8*Real.sqrt δ)]
  exact coordinateAnchorCoupling_tanh_error Q G hKL S x hδ hgap

#print axioms coordinate_anchor_replacement_features
end ConditionalNonpolynomial.Analytic
