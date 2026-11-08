import NeuralGeneralization.OnlineLowerTanhPrefixEnvelope
import NeuralGeneralization.OnlineLowerTanhWalshColumns

/-! Concrete support preimages for strict all-prefix Fourier positivity. -/
noncomputable section
open scoped BigOperators Classical symmDiff
namespace NeuralGeneralization.OnlineLowerTanh
open OnlineLower OnlineLowerGeometry OnlineLowerRelu ConcreteModel

lemma columnScore_eq_increment_pullback {m p:ℕ} (n:ℝ)
    (column:Fin p→Finset (Fin m)) (δ:Fin p→ℝ) (cost:ℝ→ℝ) (x:ClippingCube m) :
    cost (columnDegree n column δ x)=incrementScore δ cost n (generatedSyndrome column x) := by
  unfold columnDegree incrementScore incrementLinear
  congr 2
  apply Finset.sum_congr rfl
  intro i _
  rw [←generatedSyndrome_sign column x i]
  cases generatedSyndrome column x i <;> simp [cubeCoordinateSign] <;> ring

lemma generatedSupport_singleton_column {m p:ℕ} (column:Fin p→Finset (Fin m)) (i:Fin p) :
    generatedSupport ∅ column {i}=column i := by
  rw [show ({i}:Finset (Fin p))=insert i ∅ by rfl,
    generatedSupport_insert _ _ _ _ (by simp),generatedSupport_empty]
  simp

lemma generatedSupport_preimage_card_ge_two {m p:ℕ}
    (column:Fin p→Finset (Fin m)) (hcolumn:∀i,(column i).card≤2)
    (T:Finset (Fin m)) (hT:3≤T.card) (I:Finset (Fin p))
    (hI:generatedSupport ∅ column I=T) : 2≤I.card := by
  by_contra h
  have hsmall:I.card≤1:=by omega
  rcases Nat.eq_zero_or_pos I.card with hz|hp
  · have he:I=∅:=Finset.card_eq_zero.mp hz
    rw [he,generatedSupport_empty] at hI
    subst T
    simp at hT
  · have hone:I.card=1:=by omega
    obtain ⟨i,rfl⟩:=Finset.card_eq_one.mp hone
    rw [generatedSupport_singleton_column] at hI
    have hc:=hcolumn i
    rw [hI] at hc
    omega

lemma generatedSupport_of_singleton_section {m p:ℕ}
    (column:Fin p→Finset (Fin m)) (sectionMap:Fin m→Fin p)
    (hsection:∀i,column (sectionMap i)={i}) (T:Finset (Fin m)) :
    generatedSupport ∅ column (T.image sectionMap)=T := by
  have hinj:Function.Injective sectionMap:=by
    intro i j hij
    have hh:=congrArg column hij
    rw [hsection,hsection] at hh
    exact Finset.singleton_injective hh
  induction T using Finset.induction_on with
  | empty => simp
  | @insert i T hi ih =>
    rw [Finset.image_insert,generatedSupport_insert]
    · rw [hsection,ih]
      ext j
      by_cases hji:j=i
      · subst j
        simp [Finset.mem_symmDiff,hi]
      · simp [Finset.mem_symmDiff,hji]
    · intro hmem
      obtain ⟨j,hj,hji⟩:=Finset.mem_image.mp hmem
      exact hi ((hinj hji) ▸ hj)

lemma old_prefix_preimage_card (k:ℕ)
    (T:Finset (Fin (OnlineLowerRelu.Family.pathDim k)))
    (I:Finset (Fin (OnlineLowerRelu.Family.pairDim k)))
    (hI:generatedSupport ∅ (OnlineLowerRelu.Family.column k) I=
      joinedSyndromeSupport (OnlineLowerRelu.Family.prefixDim k) (OnlineLowerRelu.Family.pathDim k) T) :
    2≤I.card := by
  apply generatedSupport_preimage_card_ge_two _ (OnlineLowerRelu.Family.column_card_le k) _ _ I hI
  have hp:=joinedSyndromeSupport_card_ge (OnlineLowerRelu.Family.prefixDim k)
    (OnlineLowerRelu.Family.pathDim k) T
  have hp3:3≤OnlineLowerRelu.Family.prefixDim k:=by
    unfold OnlineLowerRelu.Family.prefixDim
    omega
  exact hp3.trans hp

lemma old_prefix_preimage_exists (k:ℕ)
    (T:Finset (Fin (OnlineLowerRelu.Family.pathDim k))) :
    ∃I:Finset (Fin (OnlineLowerRelu.Family.pairDim k)),
      generatedSupport ∅ (OnlineLowerRelu.Family.column k) I=
        joinedSyndromeSupport (OnlineLowerRelu.Family.prefixDim k) (OnlineLowerRelu.Family.pathDim k) T := by
  refine ⟨(joinedSyndromeSupport (OnlineLowerRelu.Family.prefixDim k)
    (OnlineLowerRelu.Family.pathDim k) T).image (OnlineLowerRelu.Family.privatePair k),?_⟩
  exact generatedSupport_of_singleton_section _ _ (OnlineLowerRelu.Family.column_privatePair k) _

/-- Singleton loop columns give a positive preimage for every target of
cardinality at least three. -/
theorem optimized_column_walsh_positive (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀m p:ℕ,∀column:Fin p→Finset (Fin m),
      (∀i,(column i).card≤2) → ∀sectionMap:Fin m→Fin p,
      (∀i,column (sectionMap i)={i}) → ∀δ:Fin p→ℝ,(∀i,0<δ i) →
      ∀n:ℝ,S*(p+1:ℕ)≤n → ∀T:Finset (Fin m),3≤T.card →
      0<walshCoefficients (fun x=>optimizedRealCost b (columnDegree n column δ x)) T := by
  obtain ⟨S,hS,hpos⟩:=optimized_increment_walsh_positive b
  refine ⟨S,hS,?_⟩
  intro m p column hcolumn sectionMap hsection δ hδ n hn T hT
  have hc:=hpos p δ hδ n hn
  have hI:=generatedSupport_of_singleton_section column sectionMap hsection T
  rw [columnDegree_walsh_pushforward]
  apply column_pushforward_pos _ _ (fun I hi=>(hc I hi).le)
  · intro he
    rw [he] at hT
    simp at hT
  · intro i he
    have hh:=hcolumn i
    rw [he] at hh
    omega
  · exact hI
  · exact hc _ (generatedSupport_preimage_card_ge_two column hcolumn T hT _ hI)

/-- All compulsory-prefix coefficients of the literal path-column cost are
strictly positive; no cancellation or genericity premise is used. -/
theorem optimizedRealCost_old_prefix_positive (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀k:ℕ,∀n:ℝ,
      S*(OnlineLowerRelu.Family.pairDim k+1:ℕ)≤n →
      ∀T:Finset (Fin (OnlineLowerRelu.Family.pathDim k)),
        0<FamilyCost.scalarCost k n (optimizedRealCost b) T := by
  obtain ⟨S,hS,hpos⟩:=optimized_increment_walsh_positive b
  refine ⟨S,hS,?_⟩
  intro k n hn T
  have hδ:∀i:Fin (OnlineLowerRelu.Family.pairDim k),
      0<(OnlineLowerRelu.Family.increment k i:ℝ):=by
    intro i
    have hh:2≤(OnlineLowerRelu.Family.increment k i:ℝ):=by
      exact_mod_cast (OnlineLowerRelu.Family.increment_bounds k i).1
    linarith
  have hc:=hpos _ _ hδ n hn
  obtain ⟨I,hI⟩:=old_prefix_preimage_exists k T
  unfold FamilyCost.scalarCost
  rw [columnDegree_walsh_pushforward]
  apply column_pushforward_pos _ _ (fun I hI=>(hc I hI).le)
  · intro he
    have hh:=joinedSyndromeSupport_card_ge (OnlineLowerRelu.Family.prefixDim k)
      (OnlineLowerRelu.Family.pathDim k) T
    rw [he] at hh
    simp only [Finset.card_empty] at hh
    unfold OnlineLowerRelu.Family.prefixDim at hh
    omega
  · intro i he
    have hh:=OnlineLowerRelu.Family.column_card_le k i
    rw [he] at hh
    have hp:=joinedSyndromeSupport_card_ge (OnlineLowerRelu.Family.prefixDim k)
      (OnlineLowerRelu.Family.pathDim k) T
    have h3:3≤OnlineLowerRelu.Family.prefixDim k:=by
      unfold OnlineLowerRelu.Family.prefixDim
      omega
    omega
  · exact hI
  · exact hc I (old_prefix_preimage_card k T I hI)

namespace Family

lemma joinSupport_card_ge (k:ℕ) (T:Finset (Fin (OldDim k))) (a:Bool) :
    T.card≤(joinSupport k T a).card := by
  have hs:T.map (oldLogical k)⊆joinSupport k T a:=by
    intro i hi
    obtain ⟨j,hj,rfl⟩:=Finset.mem_map.mp hi
    simpa [joinSupport,oldLogical] using hj
  simpa using Finset.card_le_card hs

lemma livePoint_support_card (k:ℕ) (endpoint:Bool) (z:ClippingCube (logicalDim k))
    (hz:cubeTranslation (referencePoint k endpoint) z∈(calibrationSubgroup k).carrier) :
    ∃T:Finset (Fin (logicalDim k)),negativeBitsCube T=z ∧ 3≤T.card := by
  let U:=joinedSyndromeSupport (OnlineLowerRelu.Family.prefixDim k)
    (OnlineLowerRelu.Family.pathDim k) (OnlineLowerRelu.Family.pathSupportOfPoint k (oldPoint k z))
  refine ⟨joinSupport k U true,?_,?_⟩
  · rw [negativeBitsCube_joinSupport]
    simp only [Bool.not_true]
    have hold:=((mem_liveCoset k endpoint z).mp hz).1
    have hp:=OnlineLowerRelu.Family.calibration_prefix_bits k endpoint (oldPoint k z) hold
    rw [OnlineLowerRelu.Family.prefix_point_representation k (oldPoint k z) hp]
    exact (livePoint_eq_extend k endpoint z hz).symm
  · have hp:=joinedSyndromeSupport_card_ge (OnlineLowerRelu.Family.prefixDim k)
      (OnlineLowerRelu.Family.pathDim k) (OnlineLowerRelu.Family.pathSupportOfPoint k (oldPoint k z))
    have h3:3≤OnlineLowerRelu.Family.prefixDim k:=by
      unfold OnlineLowerRelu.Family.prefixDim
      omega
    exact (h3.trans hp).trans (joinSupport_card_ge k U true)

/-- The actual Fourier weight is strictly positive throughout the live coset. -/
theorem codeBalancedCost_live_positive (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀R H k:ℕ,∀hR:0<R,∀hH:0<H,6≤R→Even R→Even H→
      b.threshold<((pairDim R H k*R+1:ℕ):ℝ)→
      S*(pairDim R H k+1:ℕ)≤(pairDim R H k:ℝ)*R+1→
      ∀endpoint:Bool,∀z:ClippingCube (logicalDim k),
      cubeTranslation (referencePoint k endpoint) z∈(calibrationSubgroup k).carrier→
      0<rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH)) z := by
  obtain ⟨S,hS,hpos⟩:=optimized_column_walsh_positive b
  refine ⟨S,hS,?_⟩
  intro R H k hR hH hR6 hRe hHe hbase hn endpoint z hz
  obtain ⟨T,rfl,hT⟩:=livePoint_support_card k endpoint z hz
  rw [codeBalancedCost_eq_scalarSupportWeight b R H k hR hH hRe hHe hbase,
    scalarSupportWeight_transform]
  exact hpos _ _ (column R H k) (column_card_le R H k)
    (privatePair R H k hR hH) (column_privatePair R H k hR hH)
    (fun i=>(increment R H k i:ℝ)) (fun i=>by exact_mod_cast (increment_bounds R H k hR6 i).1)
    _ hn T hT

/-- Every point of the actual live coset has strictly negative effective
rectangle cost for the literal balanced neural weights. -/
theorem codeBalancedCost_live_negative (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀R H k:ℕ,∀hR:0<R,∀hH:0<H,Even R→Even H→
      b.threshold<((pairDim R H k*R+1:ℕ):ℝ)→
      S*(OnlineLowerRelu.Family.pairDim k+1:ℕ)≤(pairDim R H k:ℝ)*R+1+H→
      ∀endpoint:Bool,∀z:ClippingCube (logicalDim k),
      cubeTranslation (referencePoint k endpoint) z∈(calibrationSubgroup k).carrier→
      rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k) z<0 := by
  obtain ⟨S,hS,hpos⟩:=optimizedRealCost_old_prefix_positive b
  refine ⟨S,hS,?_⟩
  intro R H k hR hH hRe hHe hbase hn endpoint z hz
  rw [codeBalancedCost_eq_scalarSupportWeight b R H k hR hH hRe hHe hbase,
    live_rectangle_scalarSupportWeight_eq R H k _ endpoint z hz]
  exact neg_neg_of_pos (hpos k _ hn _)

/-- A single actual dimension threshold gives the strict ordering required
by the common rectangle dual, throughout its entire live affine coset. -/
theorem codeBalancedCost_live_order (b:ActualGainBranch) :
    ∃S:ℝ,0<S ∧ ∀R H k:ℕ,∀hR:0<R,∀hH:0<H,6≤R→Even R→Even H→
      b.threshold<((pairDim R H k*R+1:ℕ):ℝ)→
      S*(pairDim R H k+1:ℕ)≤(pairDim R H k:ℝ)*R+1→
      ∀endpoint:Bool,∀z:ClippingCube (logicalDim k),
      cubeTranslation (referencePoint k endpoint) z∈(calibrationSubgroup k).carrier→
      0<rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH)) z ∧
      rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH)) z<
        rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH))
          (cubeTranslation (shiftPoint k) z) := by
  obtain ⟨S₁,hS₁,hpos⟩:=codeBalancedCost_live_positive b
  obtain ⟨S₂,hS₂,hneg⟩:=codeBalancedCost_live_negative b
  refine ⟨max S₁ S₂,lt_of_lt_of_le hS₁ (le_max_left _ _),?_⟩
  intro R H k hR hH hR6 hRe hHe hbase hn endpoint z hz
  have hn₁:S₁*(pairDim R H k+1:ℕ)≤(pairDim R H k:ℝ)*R+1:=
    (mul_le_mul_of_nonneg_right (le_max_left S₁ S₂) (by positivity)).trans hn
  have hcount:(OnlineLowerRelu.Family.pairDim k+1:ℕ)≤pairDim R H k+1:=by
    unfold pairDim
    omega
  have hcountR:((OnlineLowerRelu.Family.pairDim k+1:ℕ):ℝ)≤(pairDim R H k+1:ℕ):=by
    exact_mod_cast hcount
  have hn₂:S₂*(OnlineLowerRelu.Family.pairDim k+1:ℕ)≤(pairDim R H k:ℝ)*R+1+H:=by
    have hle: S₂*(OnlineLowerRelu.Family.pairDim k+1:ℕ)≤
        max S₁ S₂*(pairDim R H k+1:ℕ):=
      mul_le_mul (le_max_right S₁ S₂) hcountR (by positivity)
        (le_of_lt (lt_of_lt_of_le hS₂ (le_max_right _ _)))
    have hH0:(0:ℝ)≤H:=by positivity
    linarith
  refine ⟨hpos R H k hR hH hR6 hRe hHe hbase hn₁ endpoint z hz,?_⟩
  have hν:=hneg R H k hR hH hRe hHe hbase hn₂ endpoint z hz
  have he:rectangleEffectiveCost (codeBalancedCost (physicalCode R H k hR hH)) (shiftPoint k) z=
      rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH)) z-
      rectangleWeightTransform (codeBalancedCost (physicalCode R H k hR hH))
        (cubeTranslation (shiftPoint k) z):=by
    unfold rectangleEffectiveCost rectangleWeightTransform
    ring
  rw [he] at hν
  linarith

end Family
end NeuralGeneralization.OnlineLowerTanh
