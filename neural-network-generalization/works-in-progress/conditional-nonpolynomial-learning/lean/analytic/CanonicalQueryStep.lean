import ExtendAnchorQueryCoupling
import AnchorGaussianFeatures
import CanonicalQueryMoments

noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.GaussianFieldCovariance

variable {X E F : Type*} [Fintype X] [DecidableEq X]
variable [NormedAddCommGroup E] [InnerProductSpace ℝ E]
variable [NormedAddCommGroup F] [InnerProductSpace ℝ F]

/-- A coupling for one query with all anchors exactly identified. Each
endpoint's full Gram matrix is retained, but only this query is close. -/
def QueryFeatureClose (P : X → E) (B : X → F) (S : Finset X) (x : X) (ε : ℝ) : Prop :=
  ∃U V : X → EuclideanSpace ℝ (X ⊕ X),
    (∀i j,inner ℝ (U i) (U j)=inner ℝ (P i) (P j)) ∧
    (∀i j,inner ℝ (V i) (V j)=inner ℝ (B i) (B j)) ∧
    (∀s∈S,U s=V s) ∧ ‖U x-V x‖≤ε

theorem queryFeatureClose_of_gram_eq (P : X → E) (B : X → F)
    (hgram : ∀i j,inner ℝ (P i) (P j)=inner ℝ (B i) (B j))
    (S : Finset X) (x : X) : QueryFeatureClose P B S x 0 := by
  let u := compressHilbertFeatures (Sum.elim P P)
  refine ⟨fun i => u (.inl i),fun i => u (.inl i),?_,?_,?_,?_⟩
  · intro i j
    exact compressHilbertFeatures_inner (Sum.elim P P) (.inl i) (.inl j)
  · intro i j
    exact (compressHilbertFeatures_inner (Sum.elim P P) (.inl i) (.inl j)).trans (hgram i j)
  · intro s hs
    rfl
  · simp only [sub_self,norm_zero,le_refl]

variable {I J K M : Type*} [Fintype I] [Fintype J] [Fintype K] [Fintype M]

lemma fieldAnchorReplacement_congr_reference
    (Q G G' : Measure (X → ℝ)) [IsFiniteMeasure G] [IsFiniteMeasure G']
    (S : Finset X) (h : G=G') :
    fieldAnchorReplacement Q G (maskCoordinates S)=
      fieldAnchorReplacement Q G' (maskCoordinates S) := by
  subst G'
  rfl

/-- One complete query-error update: remove the nonanchor control, transport
the resulting anchor law along the coupled Gaussian references, and retain
the canonical output's exact anchor/query moments. -/
theorem actual_canonical_query_step
    (P : X → EuclideanSpace ℝ I) (B : X → EuclideanSpace ℝ J)
    (P' : X → EuclideanSpace ℝ K) (B' : X → EuclideanSpace ℝ M)
    (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw (fun x i => P x i))≠∞)
    (S : Finset X) (x : X) {ε δ : ℝ} (hε : 0≤ε) (hδ : 0<δ)
    (hclose : QueryFeatureClose P B S x ε)
    (hgap : coordinateEntropy Q (fieldLaw (fun x i => P x i)) (insert x S)-
      coordinateEntropy Q (fieldLaw (fun x i => P x i)) S≤δ)
    (hP' : ∀i j,inner ℝ (P' i) (P' j)=∫z,Real.tanh (z i)*Real.tanh (z j) ∂Q)
    (hB' : ∀i j:S ⊕ Unit,
      inner ℝ (B' (anchorQueryIndex S x i)) (B' (anchorQueryIndex S x j))=
        ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x j))
          ∂fieldAnchorReplacement Q (fieldLaw (fun x i => B x i)) (maskCoordinates S)) :
    QueryFeatureClose P' B' S x
      (Real.sqrt (8*Real.sqrt δ)+
        (1+Real.sqrt (2*(klDiv Q (fieldLaw (fun x i => P x i))).toReal))*ε) := by
  obtain ⟨U,V,hU,hV,hanchor,hquery⟩ := hclose
  have hGU : fieldLaw (fun x i => U x i)=fieldLaw (fun x i => P x i) := by
    apply fieldLaw_eq_of_gram_eq
    intro i j
    rw [gram_euclidean_coefficients,gram_euclidean_coefficients,hU]
  have hGV : fieldLaw (fun x i => V x i)=fieldLaw (fun x i => B x i) := by
    apply fieldLaw_eq_of_gram_eq
    intro i j
    rw [gram_euclidean_coefficients,gram_euclidean_coefficients,hV]
  have hKLU : klDiv Q (fieldLaw (fun x i => U x i))≠∞ := by rw [hGU]; exact hKL
  obtain ⟨a,b,ha,hb,hab,hdab⟩ := coordinate_anchor_replacement_features Q
    (fieldLaw (fun x i => P x i)) hKL S x hδ hgap
  obtain ⟨c,e,hc,he,hce,hdce⟩ := anchor_gaussian_feature_coupling U V Q hKLU S
    hanchor x hε hquery
  rw [fieldAnchorReplacement_congr_reference Q _ _ S hGU] at hc
  rw [fieldAnchorReplacement_congr_reference Q _ _ S hGV] at he
  rw [hGU] at hdce
  have hmid : ∀i j,inner ℝ (c (anchorQueryIndex S x i)) (c (anchorQueryIndex S x j))=
      inner ℝ (b i) (b j) := by
    intro i j
    rw [hc,hb]
  obtain ⟨A,C,hmatch⟩ := equal_gram_common_embedding b
    (fun i => c (anchorQueryIndex S x i)) hmid
  let l := fun i => A (a i)
  let r := fun i => C (e (anchorQueryIndex S x i))
  have hl : ∀i j,inner ℝ (l i) (l j)=
      inner ℝ (P' (anchorQueryIndex S x i)) (P' (anchorQueryIndex S x j)) := by
    intro i j
    change inner ℝ (A (a i)) (A (a j))=_
    rw [A.inner_map_map,ha,hP']
  have hr : ∀i j,inner ℝ (r i) (r j)=
      inner ℝ (B' (anchorQueryIndex S x i)) (B' (anchorQueryIndex S x j)) := by
    intro i j
    change inner ℝ (C (e (anchorQueryIndex S x i))) (C (e (anchorQueryIndex S x j)))=_
    rw [C.inner_map_map,he,hB']
  have hanchors : ∀s:S,l (.inl s)=r (.inl s) := by
    intro s
    dsimp [l,r]
    rw [hab,hmatch]
    exact congrArg C (hce s s.property)
  have herr : ‖l (.inr ())-r (.inr ())‖≤
      Real.sqrt (8*Real.sqrt δ)+
        (1+Real.sqrt (2*(klDiv Q (fieldLaw (fun x i => P x i))).toReal))*ε := by
    have hm := hmatch (.inr ())
    change A (b (.inr ()))=C (c x) at hm
    change ‖A (a (.inr ()))-C (e x)‖≤_
    calc
      _ ≤ ‖A (a (.inr ()))-A (b (.inr ()))‖+‖A (b (.inr ()))-C (e x)‖ := by
        simpa only [dist_eq_norm] using dist_triangle
          (A (a (.inr ()))) (A (b (.inr ()))) (C (e x))
      _ = ‖a (.inr ())-b (.inr ())‖+‖c x-e x‖ := by
        rw [← A.map_sub,A.norm_map,hm,← C.map_sub,C.norm_map]
      _ ≤ _ := add_le_add hdab hdce
  exact extend_anchor_query_coupling P' B' S x l r hl hr hanchors herr

#print axioms actual_canonical_query_step
end ConditionalNonpolynomial.Analytic
