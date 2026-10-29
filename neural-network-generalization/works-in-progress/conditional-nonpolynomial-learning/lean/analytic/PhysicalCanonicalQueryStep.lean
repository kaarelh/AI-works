import CanonicalQueryStep
import AnchorGaussianSharpFeatures
import PhysicalGainProducts

/-! Sharp query transport and its literal physical-scale specialization. -/
noncomputable section
set_option maxHeartbeats 2500000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.GaussianFieldCovariance
variable {X I J K M : Type*} [Fintype X] [DecidableEq X]
variable [Fintype I] [Fintype J] [Fintype K] [Fintype M]
theorem actual_canonical_query_step_sharp
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
        Real.sqrt (gaussianEntropyGain ((klDiv Q (fieldLaw (fun x i => P x i))).toReal))*ε) := by
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
  obtain ⟨c,e,hc,he,hce,hdce⟩ := anchor_gaussian_feature_coupling_sharp U V Q hKLU S
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
        Real.sqrt (gaussianEntropyGain ((klDiv Q (fieldLaw (fun x i => P x i))).toReal))*ε := by
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


theorem queryFeatureClose_smul
    (P : X → EuclideanSpace ℝ I) (B : X → EuclideanSpace ℝ J)
    (S : Finset X) (x : X) {ε t : ℝ} (ht : 0≤t)
    (hclose : QueryFeatureClose P B S x ε) :
    QueryFeatureClose (fun x => t • P x) (fun x => t • B x) S x (t*ε) := by
  obtain ⟨U,V,hU,hV,ha,hq⟩ := hclose
  refine ⟨fun x => t • U x,fun x => t • V x,?_,?_,?_,?_⟩
  · intro i j
    simp only [real_inner_smul_left,real_inner_smul_right,hU]
  · intro i j
    simp only [real_inner_smul_left,real_inner_smul_right,hV]
  · intro s hs
    exact congrArg (fun z => t • z) (ha s hs)
  · rw [← smul_sub,norm_smul,Real.norm_eq_abs,abs_of_nonneg ht]
    exact mul_le_mul_of_nonneg_left hq ht

theorem physical_canonical_query_step
    (P : X → EuclideanSpace ℝ I) (B : X → EuclideanSpace ℝ J)
    (P' : X → EuclideanSpace ℝ K) (B' : X → EuclideanSpace ℝ M)
    (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q] {t : ℝ} (ht : 0≤t)
    (hKL : klDiv Q (fieldLaw (scaledFeatureCoefficients t P))≠∞)
    (S : Finset X) (x : X) {ε δ : ℝ} (hε : 0≤ε) (hδ : 0<δ)
    (hclose : QueryFeatureClose P B S x ε)
    (hgap : coordinateEntropy Q (fieldLaw (scaledFeatureCoefficients t P)) (insert x S)-
      coordinateEntropy Q (fieldLaw (scaledFeatureCoefficients t P)) S≤δ)
    (hP' : ∀i j,inner ℝ (P' i) (P' j)=∫z,Real.tanh (z i)*Real.tanh (z j) ∂Q)
    (hB' : ∀i j:S ⊕ Unit,
      inner ℝ (B' (anchorQueryIndex S x i)) (B' (anchorQueryIndex S x j))=
        ∫z,Real.tanh (z (anchorQueryIndex S x i))*Real.tanh (z (anchorQueryIndex S x j))
          ∂fieldAnchorReplacement Q (fieldLaw (scaledFeatureCoefficients t B)) (maskCoordinates S)) :
    QueryFeatureClose P' B' S x
      (Real.sqrt (8*Real.sqrt δ)+
        (t*Real.sqrt (gaussianEntropyGain ((klDiv Q (fieldLaw (scaledFeatureCoefficients t P))).toReal)))*ε) := by
  have hh := actual_canonical_query_step_sharp (fun x => t • P x) (fun x => t • B x) P' B'
    Q hKL S x (mul_nonneg ht hε) hδ (queryFeatureClose_smul P B S x ht hclose) hgap hP' hB'
  change QueryFeatureClose P' B' S x
    (Real.sqrt (8*Real.sqrt δ)+
      Real.sqrt (gaussianEntropyGain ((klDiv Q (fieldLaw (scaledFeatureCoefficients t P))).toReal))*(t*ε)) at hh
  convert hh using 1 <;> ring

#print axioms physical_canonical_query_step
end ConditionalNonpolynomial.Analytic
