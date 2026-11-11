import NeuralGeneralization.BatchTwoImprovedPathCost
import NeuralGeneralization.BatchTwoImprovedSelectedRawCostActivation
import NeuralGeneralization.RobustCouplingActualCost

/-! General bounded 1-Lipschitz activation extension.
 The actual sharp layer joint satisfies the normalized live path bound. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 700000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace Classical
namespace NeuralGeneralization.BatchTwoImprovedSelectedBank
open ConcreteModel RobustEntropy RobustGaussianGeometry RobustCompressionInduction
open RobustCompressionCanonicalLayer BatchTwoImprovedCanonicalLayer BatchTwoImprovedWeightedSampling
open RobustCompressionSelectedBank RobustCompressionLayerGaussian RobustCoupling
variable {d N m s r q : ℕ} [NeZero N]
local notation "P" => ActivePrefix d N m s
local notation "Base" => P × FutureWeights N r
local notation "Rows" => Fin N → EuclideanSpace ℝ (Fin N)
local notation "Raw" => Base × ((Rows × (Fin N → ℝ)) × ((Fin m → Fin N) × (Fin N → Fin m → ℝ)))
local notation "M" => Fintype.card (Cube d)
variable [MeasurableSpace (Finset (Fin (Fintype.card (Cube d))))]
  [MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube d))))]
  [MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube d))) q)]
  [MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube d))) q)]

theorem liveLocalCost_sharpStatePair_le_activation {φ : ℝ → ℝ} (hφ : LipschitzWith 1 φ) (hφb : ∀ z, |φ z| ≤ 1)
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    {t : ℝ} (ht : 0≤t) (BH BG : ℝ) (i : Fin M) (z : Raw) :
    let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
    let obs := selectedHObservation (q:=q) b J t i
    let data := selectedSharpBankData (m:=m) (q:=q) b
      (measurable_indexedPrefixQueries hφ.continuous) J hJ
      (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ.continuous) i
    liveLocalCost (t/Real.sqrt (N:ℝ)) φ ((Fintype.equivFin (Cube d)).symm i)
      (sharpSelectedStatePair (q:=q) b J t BH BG z) ≤ ENNReal.ofReal ((N:ℝ)⁻¹)*
      (if sourceBad (selectedMessageBasis (q:=q) b J z.1) z.2.2.1 then 0 else
        ENNReal.ofReal (data.squaredError φ t BH BG
          ((z.1,(obs (z.1,z.2.1)).1),z.2.2.1) ((obs (z.1,z.2.1)).2,z.2.2.2))) := by
  dsimp only
  have he := sharp_masked_path_cost (q:=q) hφ.continuous
    J hJ ht BH BG i z.1 z.2.1.1 z.2.1.2 z.2.2.1 z.2.2.2
  have he' := congrArg ENNReal.ofReal he
  rw [apply_ite ENNReal.ofReal,apply_ite ENNReal.ofReal] at he'
  simp only [ENNReal.ofReal_zero] at he'
  unfold liveLocalCost sharpSelectedStatePair restoreCurrentRowState
  simp only [MeasurableEquiv.apply_symm_apply]
  change (if _ then ENNReal.ofReal (localPathCost φ
    (fun j k => t/Real.sqrt (N:ℝ)*z.2.1.1 j k) (indexedPrefixHidden φ z.1.1 i) _) else 0) ≤ _
  dsimp only [selectedHObservation] at he'
  simp only [Prod.eta] at he'
  rw [he']
  by_cases hs : sharpPathSuccess (q:=q) φ J z.1 z.2.2.1
  · rw [if_pos hs,if_neg hs.2.2]
    rw [div_eq_mul_inv,ENNReal.ofReal_mul (by unfold SharpBankData.squaredError; positivity),mul_comm]
    exact le_rfl
  · rw [if_neg hs]
    exact bot_le

/-- The complete probability coupling has a sharp actual disturbance bound,
with no coupling or approximation existence premise. -/
theorem sharpLayerJoint_liveLocalCost_le_activation {φ : ℝ → ℝ} (hφ : LipschitzWith 1 φ) (hφb : ∀ z, |φ z| ≤ 1) (hq : 0<q) (hm : 0<m)
    (Q : Measure (P × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (J : Base → Finset (Fin M)) (hJ : Measurable J)
    {K t BH BG : ℝ} (hK : 0≤K) (ht : 0<t) (ht1 : t≤1) (hBH : 0<BH) (hBG : 0<BG)
    (hentropy : futureEntropy Q (futurePrior N (r+1)) ≤ ENNReal.ofReal (2*N*K/t^2))
    (i : Fin M) (D : ℝ≥0∞)
    (hquery : (∫⁻ p, klDiv
      ((safeQueryKernel (currentRowJoint (prefixCurrentLaw Q)).condKernel
        (fun a => indexedPrefixQueries φ a.1)
        ((measurable_indexedPrefixQueries hφ.continuous).comp measurable_fst)
        J hJ i).condKernel p) (standardGaussianVector N)
      ∂(currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ
        (safeQueryKernel (currentRowJoint (prefixCurrentLaw Q)).condKernel
          (fun a => indexedPrefixQueries φ a.1)
          ((measurable_indexedPrefixQueries hφ.continuous).comp measurable_fst) J hJ i).fst) ≤ D) :
    (∫⁻ z, liveLocalCost (t/Real.sqrt (N:ℝ)) φ ((Fintype.equivFin (Cube d)).symm i) z
      ∂sharpLayerJoint hq Q (indexedPrefixQueries φ)
        (measurable_indexedPrefixQueries hφ.continuous) J hJ
        (indexedPrefixHidden φ) (measurable_indexedPrefixHidden hφ.continuous)
        t BH BG i) ≤
      ENNReal.ofReal ((N:ℝ)⁻¹)*(4*(ENNReal.ofReal (4/BH^2)*ENNReal.ofReal (N*(8*K+2*q))+
        ENNReal.ofReal (2*t^2)*D+(ENNReal.ofReal (2/(m:ℝ))*ENNReal.ofReal (N*(8*K+2*q))+
        ENNReal.ofReal (16*(N:ℝ)*((q:ℝ)+1)/m))+ENNReal.ofReal (128*(N:ℝ)*m/BG^2))) := by
  let b := indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) φ
  let hb := measurable_indexedPrefixQueries (d:=d) (N:=N) (m:=m) (s:=s) hφ.continuous
  let h := indexedPrefixHidden (d:=d) (N:=N) (m:=m) (s:=s) φ
  let hh := measurable_indexedPrefixHidden (d:=d) (N:=N) (m:=m) (s:=s) hφ.continuous
  have hbounded : ∀ p x j, |h p x j|≤1 := fun p x j => activeHidden_bounded φ
    hφb p ((Fintype.equivFin (Cube d)).symm x) j
  have hraw := actual_selected_sharp_raw_cost_activation hφ hφb hq hm (prefixCurrentLaw Q) (futurePrior N r)
    b hb J hJ h hh hbounded hK ht ht1 hBH hBG
    ((splitRowsState_futureEntropy_le Q).trans hentropy) i D hquery
  let obs := selectedHObservation (q:=q) b J t i
  let data := selectedSharpBankData (m:=m) (q:=q) b hb J hJ h hh i
  let F := fun z : Raw => if sourceBad (selectedMessageBasis (q:=q) b J z.1) z.2.2.1 then 0 else
    ENNReal.ofReal (data.squaredError φ t BH BG
      ((z.1,(obs (z.1,z.2.1)).1),z.2.2.1) ((obs (z.1,z.2.1)).2,z.2.2.2))
  let κ := actualSharpLayerKernel hq Q b hb J hJ h hh t BH i
  have hpoint : ∀ z, liveLocalCost (t/Real.sqrt (N:ℝ)) φ
      ((Fintype.equivFin (Cube d)).symm i) (sharpSelectedStatePair (q:=q) b J t BH BG z) ≤
      ENNReal.ofReal ((N:ℝ)⁻¹)*F z :=
    liveLocalCost_sharpStatePair_le_activation hφ hφb J hJ ht.le BH BG i
  rw [sharpLayerJoint,lintegral_map (measurable_liveLocalCost _ hφ.continuous _)
    (measurable_sharpSelectedStatePair (q:=q) b hb J hJ t BH BG)]
  have hfubini := Measure.lintegral_compProd (μ:=(currentRowJoint (prefixCurrentLaw Q)).fst) (κ:=κ)
    ((measurable_liveLocalCost (t/Real.sqrt (N:ℝ)) hφ.continuous
      ((Fintype.equivFin (Cube d)).symm i)).comp
      (measurable_sharpSelectedStatePair (q:=q) b hb J hJ t BH BG))
  simp only [Function.comp_def] at hfubini
  rw [hfubini]
  calc
    _ ≤ ∫⁻ θ, ∫⁻ w, ENNReal.ofReal ((N:ℝ)⁻¹)*F (θ,w) ∂κ θ ∂(currentRowJoint (prefixCurrentLaw Q)).fst :=
      lintegral_mono fun θ => lintegral_mono fun w => hpoint (θ,w)
    _ = ENNReal.ofReal ((N:ℝ)⁻¹)*(∫⁻ θ,∫⁻ w,F (θ,w) ∂κ θ ∂(currentRowJoint (prefixCurrentLaw Q)).fst) := by
      simp_rw [lintegral_const_mul' _ _ ENNReal.ofReal_ne_top]
    _ ≤ _ := mul_le_mul' le_rfl hraw

end NeuralGeneralization.BatchTwoImprovedSelectedBank
