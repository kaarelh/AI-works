import NeuralGeneralization.RobustCompressionSelectedLayerCoupling
import NeuralGeneralization.RobustCompressionSelectedPathCost
import NeuralGeneralization.RobustCompressionSelectedRawCostResources
import NeuralGeneralization.RobustCouplingActualCost

/-! # The actual selected-layer coupling has the declared live noise cost -/
noncomputable section
set_option maxHeartbeats 900000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace Classical
namespace NeuralGeneralization.RobustCompressionSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompressionCanonicalLayer RobustCompressionLayerParameters RobustCompressionLayerComparison
variable {d N m s r q : ℕ} [NeZero N]
local notation "P" => ActivePrefix d N m s
local notation "Base" => P × FutureWeights N r
local notation "Rows" => Fin N → EuclideanSpace ℝ (Fin N)
local notation "Raw" => Base × ((Rows × (Fin N → ℝ)) × ((Fin m → Fin N) × (Fin N → Fin m → ℝ)))
variable [MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))]
  [MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]

theorem liveLocalCost_selectedStatePair
    (J : Base → Finset (Fin (Fintype.card (Cube d)))) (hJ : Measurable J)
    {t : ℝ} (ht : 0 ≤ t) (a T BH BG : ℝ) (i : Fin (Fintype.card (Cube d))) (z : Raw) :
    let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) Real.tanh
    let obs := selectedHObservation (q:=q) b J t i
    let data := selectedBankData (m:=m) (q:=q) b
      (measurable_indexedPrefixQueries tanh_lipschitzWith.continuous) J hJ
      (indexedPrefixHidden Real.tanh) (measurable_indexedPrefixHidden tanh_lipschitzWith.continuous)
    liveLocalCost (t/Real.sqrt (N:ℝ)) Real.tanh ((Fintype.equivFin (Cube d)).symm i)
      (selectedStatePair (q:=q) Real.tanh b J a t T BH BG z) =
      ENNReal.ofReal ((N:ℝ)⁻¹) *
        (if selectedPathSuccess (q:=q) Real.tanh J a T z.1 z.2.2.1 then
          ENNReal.ofReal (bankSquaredError data a t T BH BG i
            ((z.1,(obs (z.1,z.2.1)).1),z.2.2.1)
            ((obs (z.1,z.2.1)).2,z.2.2.2)) else 0) := by
  dsimp only
  have he := selectedStateFromH_masked_path_cost (q:=q) tanh_lipschitzWith.continuous
    J hJ ht a T BH BG i z.1 z.2.1.1 z.2.1.2 z.2.2.1 z.2.2.2
  have he' := congrArg ENNReal.ofReal he
  rw [apply_ite ENNReal.ofReal,apply_ite ENNReal.ofReal] at he'
  simp only [ENNReal.ofReal_zero] at he'
  unfold liveLocalCost selectedStatePair restoreCurrentRowState
  simp only [MeasurableEquiv.apply_symm_apply]
  change (if _ then ENNReal.ofReal (localPathCost Real.tanh
    (fun j k => t/Real.sqrt (N:ℝ)*z.2.1.1 j k)
    (indexedPrefixHidden Real.tanh z.1.1 i) _) else 0) = _
  dsimp only [selectedHObservation] at he'
  simp only [Prod.eta] at he'
  rw [he']
  by_cases hs : selectedPathSuccess (q:=q) Real.tanh J a T z.1 z.2.2.1
  · rw [if_pos hs,if_pos hs]
    rw [div_eq_mul_inv,ENNReal.ofReal_mul (by positivity)]
    rw [mul_comm]
    rfl
  · rw [if_neg hs,if_neg hs,mul_zero]



/-- The literal old/new joint constructed from the actual selected queries has
normalized successful hidden-noise cost at most `10 / inverseLayerError`. -/
theorem selectedLayerJoint_liveLocalCost_le
    (res : RobustCompressionInput)
    [MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) res.activeRank)]
    [MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) res.activeRank)]
    (Q : Measure (ActivePrefix d N res.bankSize s × FutureWeights N (r+1)))
    [IsProbabilityMeasure Q]
    {t : ℝ} (hE : 0 < res.inverseLayerError) (ht : 0 < t) (ht1 : t^2 ≤ 1)
    (S : PrefixSelection Q (indexedPrefixQueries Real.tanh)
      (measurable_indexedPrefixQueries tanh_lipschitzWith.continuous)
      res.activeRank t (res.inverseSelectionError : ℝ)⁻¹ (res.inverseLayerFailure : ℝ)⁻¹)
    (hentropy : futureEntropy Q (futurePrior N (r+1)) ≤
      ENNReal.ofReal (2*N*res.energy/t^2))
    (i : Fin (Fintype.card (Cube d))) :
    (∫⁻ z, liveLocalCost (t/Real.sqrt (N:ℝ)) Real.tanh
      ((Fintype.equivFin (Cube d)).symm i) z
      ∂selectedLayerJoint (q:=res.activeRank) Q Real.tanh (indexedPrefixQueries Real.tanh)
        (measurable_indexedPrefixQueries tanh_lipschitzWith.continuous)
        S.queries S.measurable_queries (indexedPrefixHidden Real.tanh)
        (measurable_indexedPrefixHidden tanh_lipschitzWith.continuous)
        (res.inverseKernelPrecision : ℝ)⁻¹ t res.sourceClip
        (Real.sqrt (res.activeSquaredBound : ℝ)) (Real.sqrt (res.gaussianSquaredBound : ℝ)) i) ≤
      ENNReal.ofReal (10/(res.inverseLayerError : ℝ)) := by
  let b := indexedPrefixQueries (d:=d) (N:=N) (m:=res.bankSize) (s:=s) Real.tanh
  let hb := measurable_indexedPrefixQueries (d:=d) (N:=N) (m:=res.bankSize) (s:=s)
    tanh_lipschitzWith.continuous
  let h := indexedPrefixHidden (d:=d) (N:=N) (m:=res.bankSize) (s:=s) Real.tanh
  let hh := measurable_indexedPrefixHidden (d:=d) (N:=N) (m:=res.bankSize) (s:=s)
    tanh_lipschitzWith.continuous
  let a : ℝ := (res.inverseKernelPrecision : ℝ)⁻¹
  let T : ℝ := res.sourceClip
  let BH := Real.sqrt (res.activeSquaredBound : ℝ)
  let BG := Real.sqrt (res.gaussianSquaredBound : ℝ)
  let success : Set (SelectedBankState (ActivePrefix d N res.bankSize s)
      (FutureWeights N r) N res.bankSize res.activeRank) :=
    {θ | selectedPathSuccess (q:=res.activeRank) Real.tanh S.queries a T θ.1.1 θ.2}
  have hsuccess : MeasurableSet success :=
    measurableSet_selectedPathSuccess tanh_lipschitzWith.continuous
      S.queries S.measurable_queries a T
  have hgood : ∀ θ ∈ success,
      RobustCompressionSourceBank.sourceBankGood
        (sourceRows (selectedMessageBasis (q:=res.activeRank) b S.queries θ.1.1))
          (h θ.1.1.1) a T θ.2 := by
    intro θ hθ
    exact selectedPathSuccess_good_indexed Real.tanh S.queries a T θ.1.1 θ.2 hθ
  have hbounded : ∀ p x j, |h p x j| ≤ 1 := fun p x j =>
    activeHidden_bounded Real.tanh (fun u => (Real.abs_tanh_lt_one u).le)
      p ((Fintype.equivFin (Cube d)).symm x) j
  have hraw := actual_selected_raw_cost_resources res (prefixCurrentLaw Q) (futurePrior N r)
    b hb S.queries S.measurable_queries h hh hbounded hE ht ht1
    ((splitRowsState_futureEntropy_le Q).trans hentropy) i (S.residual_bound i)
    success hsuccess hgood
  let obs := selectedHObservation (q:=res.activeRank) b S.queries t i
  let data := selectedBankData (m:=res.bankSize) (q:=res.activeRank) b hb
    S.queries S.measurable_queries h hh
  let F := fun z : (ActivePrefix d N res.bankSize s × FutureWeights N r) ×
      (((Fin N → EuclideanSpace ℝ (Fin N)) × (Fin N → ℝ)) ×
        ((Fin res.bankSize → Fin N) × (Fin N → Fin res.bankSize → ℝ))) =>
    if selectedPathSuccess (q:=res.activeRank) Real.tanh S.queries a T z.1 z.2.2.1 then
      ENNReal.ofReal (bankSquaredError data a t T BH BG i
        ((z.1,(obs (z.1,z.2.1)).1),z.2.2.1) ((obs (z.1,z.2.1)).2,z.2.2.2)) else 0
  let κ := actualSelectedLayerKernel (q:=res.activeRank) Q b hb S.queries S.measurable_queries
    h hh a t T BH i
  have hraw' : (∫⁻ θ, ∫⁻ w, F (θ,w) ∂κ θ ∂(currentRowJoint (prefixCurrentLaw Q)).fst) ≤
      ENNReal.ofReal (10*(N:ℝ)/res.inverseLayerError) := hraw
  have hpoint : ∀ z, liveLocalCost (t/Real.sqrt (N:ℝ)) Real.tanh
      ((Fintype.equivFin (Cube d)).symm i)
      (selectedStatePair (q:=res.activeRank) Real.tanh b S.queries a t T BH BG z) =
      ENNReal.ofReal ((N:ℝ)⁻¹)*F z :=
    fun z => liveLocalCost_selectedStatePair S.queries S.measurable_queries ht.le a T BH BG i z
  rw [selectedLayerJoint,lintegral_map
    (measurable_liveLocalCost _ tanh_lipschitzWith.continuous _)
    (measurable_selectedStatePair (q:=res.activeRank) tanh_lipschitzWith.continuous b hb
      S.queries S.measurable_queries a t T BH BG)]
  have hfubini := Measure.lintegral_compProd
    (μ := (currentRowJoint (prefixCurrentLaw Q)).fst) (κ := κ)
    ((measurable_liveLocalCost (t/Real.sqrt (N:ℝ)) tanh_lipschitzWith.continuous
      ((Fintype.equivFin (Cube d)).symm i)).comp
      (measurable_selectedStatePair (q:=res.activeRank) tanh_lipschitzWith.continuous b hb
        S.queries S.measurable_queries a t T BH BG))
  simp only [Function.comp_def] at hfubini
  rw [hfubini]
  change (∫⁻ θ, ∫⁻ w, liveLocalCost (t/Real.sqrt (N:ℝ)) Real.tanh
    ((Fintype.equivFin (Cube d)).symm i)
    (selectedStatePair (q:=res.activeRank) Real.tanh b S.queries a t T BH BG (θ,w))
    ∂κ θ ∂(currentRowJoint (prefixCurrentLaw Q)).fst) ≤ _
  simp_rw [hpoint,lintegral_const_mul' _ _ ENNReal.ofReal_ne_top]
  calc
    ENNReal.ofReal ((N:ℝ)⁻¹)*(∫⁻ θ,∫⁻ w,F (θ,w) ∂κ θ ∂(currentRowJoint (prefixCurrentLaw Q)).fst)
        ≤ ENNReal.ofReal ((N:ℝ)⁻¹)*ENNReal.ofReal (10*(N:ℝ)/res.inverseLayerError) :=
      mul_le_mul_left' hraw' _
    _ = ENNReal.ofReal (10/(res.inverseLayerError : ℝ)) := by
      rw [← ENNReal.ofReal_mul (by positivity)]
      congr 1
      have hN : (N:ℝ) ≠ 0 := by exact_mod_cast NeZero.ne N
      field_simp

end NeuralGeneralization.RobustCompressionSelectedBank
