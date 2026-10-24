import NeuralGeneralization.BatchTwoImprovedBankError
import NeuralGeneralization.BatchTwoImprovedLayerFiber
import NeuralGeneralization.RobustCompressionSelectedPathCost

/-! Pointwise path-noise identity for the actual sharp reconstruction. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 700000
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace Classical
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompressionCanonicalLayer BatchTwoImprovedCanonicalLayer BatchTwoImprovedWeightedSampling
open RobustCompressionSelectedBank
variable {d N m s q : ℕ} {Y : Type*} [MeasurableSpace Y]
local notation "P" => ActivePrefix d N m s
local notation "Rows" => Fin N → EuclideanSpace ℝ (Fin N)
local notation "M" => Fintype.card (Cube d)
variable [MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))]
  [MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]

def sharpPathSuccess (φ : ℝ → ℝ) (J : P × Y → Finset (Fin M))
    (θ : P × Y) (I : Fin m → Fin N) : Prop :=
  θ.1.1=true ∧ (J θ).card≤q ∧ ¬sourceBad (selectedMessageBasis (q:=q) (indexedPrefixQueries φ) J θ) I

theorem sharpSelectedStateFromH_alive_iff (φ : ℝ → ℝ)
    (J : P × Y → Finset (Fin M)) (t BH BG : ℝ) (θ : P × Y)
    (H : Fin N → EuclideanSpace ℝ (Fin q)) (I : Fin m → Fin N)
    (ξ : Fin N → Fin m → ℝ) :
    (sharpSelectedStateFromH (indexedPrefixQueries φ) J t BH BG θ (H,(I,ξ))).1=true ↔
      sharpPathSuccess (q:=q) φ J θ I := by
  unfold sharpSelectedStateFromH
  rw [stepActive_alive_iff]
  unfold sharpCanonicalSuccess sharpPathSuccess
  rw [decide_eq_true_eq]
  change (θ.1.1=true ∧ (abortQueryMessage q (J θ) ≠ none ∧ _)) ↔ _
  have hm : abortQueryMessage q (J θ) ≠ none ↔ (J θ).card≤q := by
    rw [ne_eq,abortQueryMessage_eq_none,not_lt]
  rw [hm]
  rfl

theorem sharp_selected_clipped_eq_rows {φ : ℝ → ℝ} (hφ : Continuous φ)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J)
    (t BH BG : ℝ) (i : Fin M) (θ : P × Y) (H : Fin N → EuclideanSpace ℝ (Fin q))
    (I : Fin m → Fin N) (ξ : Fin N → Fin m → ℝ) (j : Fin N) :
    let data := selectedSharpBankData (m:=m) (q:=q) (indexedPrefixQueries φ)
      (measurable_indexedPrefixQueries hφ) J hJ (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ) i
    (data.sharpParameters t BH).clippedFiniteObservable BG (((θ,H),I),ξ) j =
      ∑ k,sharpSourceRowsDraw t BH BG ((selectedSources (indexedPrefixQueries φ) J θ,H),I) ξ j k*
        indexedPrefixHidden φ θ.1 i (I k) := by
  dsimp only
  rw [SharpBankData.sharpParameters_clippedFiniteObservable]
  rfl

theorem sharp_selected_original_preactivation {φ : ℝ → ℝ} (hφ : Continuous φ)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J)
    {t : ℝ} (ht : 0≤t) (BH : ℝ) (i : Fin M) (θ : P × Y) (hcard : (J θ).card≤q)
    (g : Rows) (dummy : Fin N → ℝ) (I : Fin m → Fin N) (j : Fin N) :
    let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
    let o := selectedHObservation (q:=q) b J t i (θ,(g,dummy))
    let data := selectedSharpBankData (m:=m) (q:=q) b
      (measurable_indexedPrefixQueries hφ) J hJ (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ) i
    ⟪o.1 j,activeCoordinateVector (selectedMessageBasis (q:=q) b J θ)
      (normalizedFeature (indexedPrefixHidden φ θ.1 i))⟫+
      Real.sqrt ((data.sharpParameters t BH).idealVariance ((θ,o.1),I) j:ℝ)*o.2 j =
        t*⟪b θ.1 i,g j⟫ := by
  dsimp only
  let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
  have he := selectedHObservation_evaluation b J θ hcard t i g dummy j
  change _+Real.sqrt (((t^2*‖queryResidual (selectedMessageBasis (q:=q) b J θ)
    (normalizedFeature (indexedPrefixHidden φ θ.1 i))‖^2).toNNReal):ℝ)*_= _
  rw [Real.coe_toNNReal _ (mul_nonneg (sq_nonneg _) (sq_nonneg _)),←mul_pow,
    Real.sqrt_sq (mul_nonneg ht (norm_nonneg _))]
  exact he

/-- The successful path cost is exactly the cost bounded by the Gaussian
comparison; the error is zero whenever the common decoder aborts. -/
theorem sharp_masked_path_cost [NeZero N]
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (J : P × Y → Finset (Fin M)) (hJ : Measurable J)
    {t : ℝ} (ht : 0≤t) (BH BG : ℝ) (i : Fin M)
    (θ : P × Y) (g : Rows) (dummy : Fin N → ℝ) (I : Fin m → Fin N)
    (ξ : Fin N → Fin m → ℝ) :
    let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
    let o := selectedHObservation (q:=q) b J t i (θ,(g,dummy))
    let next := sharpSelectedStateFromH b J t BH BG θ (o.1,(I,ξ))
    let data := selectedSharpBankData (m:=m) (q:=q) b
      (measurable_indexedPrefixQueries hφ) J hJ (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ) i
    (if next.1=true then localPathCost φ (fun j k => (t/Real.sqrt (N:ℝ))*g j k)
      (indexedPrefixHidden φ θ.1 i)
      (activeHidden φ next ((Fintype.equivFin (Cube d)).symm i)) else 0) =
      if sharpPathSuccess (q:=q) φ J θ I then data.squaredError φ t BH BG
        ((θ,o.1),I) (o.2,ξ)/(N:ℝ) else 0 := by
  dsimp only
  let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
  let o := selectedHObservation (q:=q) b J t i (θ,(g,dummy))
  let data := selectedSharpBankData (m:=m) (q:=q) b
      (measurable_indexedPrefixQueries hφ) J hJ (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ) i
  have hlive := sharpSelectedStateFromH_alive_iff φ J t BH BG θ o.1 I ξ
  by_cases hs : sharpPathSuccess (q:=q) φ J θ I
  · rw [if_pos (hlive.mpr hs),if_pos hs]
    have hh := activeHidden_step_of_alive φ ((Fintype.equivFin (Cube d)).symm i) θ.1
      (I,sharpSourceRowsDraw t BH BG ((selectedSources b J θ,o.1),I) ξ)
      (sharpCanonicalSuccess b (selectedCanonicalInput (q:=q) J θ 0) (I,0)) (hlive.mpr hs)
    change activeHidden φ (sharpSelectedStateFromH b J t BH BG θ (o.1,(I,ξ)))
      ((Fintype.equivFin (Cube d)).symm i) = _ at hh
    unfold localPathCost
    rw [hh]
    congr 1
    apply Finset.sum_congr rfl
    intro j hj
    have hold := sharp_selected_original_preactivation hφ J hJ ht BH i θ hs.2.1 g dummy I j
    have hpre : t*⟪b θ.1 i,g j⟫ =
        ∑ k,(t/Real.sqrt (N:ℝ))*g j k*indexedPrefixHidden φ θ.1 i k := by
      simp only [b,indexedPrefixQueries,prefixQueries,indexedPrefixHidden,
        EuclideanSpace.inner_eq_star_dotProduct,dotProduct,star_trivial,Pi.star_apply]
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro k hk
      ring
    have hnew := sharp_selected_clipped_eq_rows hφ J hJ t BH BG i θ o.1 I ξ j
    change (φ _-φ _)^2 =
      (φ (⟪o.1 j,activeCoordinateVector (selectedMessageBasis (q:=q) b J θ)
        (normalizedFeature (indexedPrefixHidden φ θ.1 i))⟫+
        Real.sqrt ((data.sharpParameters t BH).idealVariance ((θ,o.1),I) j:ℝ)*o.2 j)-
        φ ((data.sharpParameters t BH).clippedFiniteObservable BG (((θ,o.1),I),ξ) j))^2
    rw [hold,hpre,hnew]
    simp only [indexedPrefixHidden,b]
    ring
  · rw [if_neg (fun hn => hs (hlive.mp hn)),if_neg hs]

end NeuralGeneralization.BatchTwoImprovedSelectedBank
