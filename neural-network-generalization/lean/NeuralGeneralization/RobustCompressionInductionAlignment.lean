import NeuralGeneralization.RobustCompressionInductionSupport
import NeuralGeneralization.RobustCouplingActualHistory

/-! # Actual history alignment is preserved almost everywhere -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustStatistics

theorem initialHistory_ae_aligned {d N m r : ℕ} (hd : 0 < d) (hN : 0 < N)
    {σ : ℝ} (hσ : 0 < σ) (B : ℝ) {φ : ℝ → ℝ} (hφ : Continuous φ)
    (x : Cube d) (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q] :
    ∀ᵐ z ∂(initialHistory m σ B hφ x Q).joint,
      HistoryAligned (by omega : 0+r ≤ r) σ φ x z.1 z.2 := by
  change ∀ᵐ z ∂Q.map (initialHistoryMap σ B φ x),HistoryAligned _ σ φ x z.1 z.2
  apply (ae_map_iff (measurable_initialHistoryMap σ B hφ x).aemeasurable
    (measurableSet_historyAligned (by omega : 0+r ≤ r) σ hφ x)).mpr
  exact Filter.Eventually.of_forall (fun w => initialHistory_aligned hd hN hσ B φ x w)

/-- The actual full original weights and their unconsumed standardized future
stay aligned after a pointwise comparison is glued to the canonical next law. -/
theorem advanceHistory_ae_aligned {d N m r s k : ℕ} (h : s+(k+1) ≤ r)
    (σ : ℝ) {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d)
    {Q : Measure (Weights d N r)}
    {Γ : Measure (ActivePrefix d N m s × FutureWeights N (k+1))}
    {Γ' : Measure (ActivePrefix d N m (s+1) × FutureWeights N k)}
    (P : CanonicalHistoryComparison Q Γ
      (Prod.fst : OriginalHistory d N r s → Weights d N r))
    (R : ProbabilityCoupling Γ Γ')
    (hAligned : ∀ᵐ z ∂P.joint,HistoryAligned h σ φ x z.1 z.2)
    (hFuture : ∀ᵐ z ∂R.joint,z.2.2=(splitFuture N k z.1.2).2) :
    ∀ᵐ z ∂(advanceHistory P R (appendOriginalHistory φ x)
      (measurable_appendOriginalHistory hφ x) measurable_fst measurable_fst
      (appendOriginalHistory_original φ x)).joint,
      HistoryAligned (by omega : (s+1)+k ≤ r) σ φ x z.1 z.2 := by
  apply advanceHistory_ae P R (appendOriginalHistory φ x)
    (measurable_appendOriginalHistory hφ x) measurable_fst measurable_fst
    (appendOriginalHistory_original φ x)
    (fun z => HistoryAligned h σ φ x z.1 z.2)
    (fun z => z.2.2=(splitFuture N k z.1.2).2)
    (fun z => HistoryAligned (by omega : (s+1)+k ≤ r) σ φ x z.1 z.2)
    (measurableSet_historyAligned (by omega : (s+1)+k ≤ r) σ hφ x) hAligned hFuture
  exact fun u old next hu ht => appendOriginalHistory_aligned h σ φ x u old next hu ht

end NeuralGeneralization.RobustCompressionInduction
