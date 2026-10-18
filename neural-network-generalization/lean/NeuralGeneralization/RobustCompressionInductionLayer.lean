import NeuralGeneralization.RobustCompressionSelectedLayerFiberLaw
import NeuralGeneralization.RobustCompressionSelectedLayerAlignment
import NeuralGeneralization.RobustCompressionSelectedPathCost
import NeuralGeneralization.RobustCompressionInductionResources

/-! # The actual one-layer probability coupling of a selected run -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy RobustStatistics RobustCompressionCanonicalLayer
open RobustCompressionSelectedBank

variable (p : RobustCompressionInput) {N s k : ℕ} [NeZero N]
  [hFin : MeasurableSpace (Finset (Fin (Fintype.card (Cube p.dimension))))]
  [hFinS : MeasurableSingletonClass (Finset (Fin (Fintype.card (Cube p.dimension))))]
  [hMsg : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]
  [hMsgS : MeasurableSingletonClass (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank)]

/-- A pointwise comparison with the complete old canonical state and the
literal common new law as its two exact marginals. -/
def resourceLayerComparison (t : ℝ)
    (Γ : CanonicalStateLaw p.dimension N p.bankSize s (k+1))
    (S : ActualPrefixSelection Γ Real.tanh tanh_lipschitzWith.continuous p.activeRank t
      ((p.inverseSelectionError : ℝ)⁻¹) ((p.inverseLayerFailure : ℝ)⁻¹))
    (x : Cube p.dimension) :
    ProbabilityCoupling Γ.law
      (selectedNext (q:=p.activeRank) tanh_lipschitzWith.continuous
        (p.inverseKernelPrecision : ℝ)⁻¹ t p.sourceClip
        (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound)
        (p.inverseSelectionError : ℝ)⁻¹ (p.inverseLayerFailure : ℝ)⁻¹ Γ S).law := by
  letI : NeZero p.bankSize := ⟨p.bankSize_pos.ne'⟩
  let b := indexedPrefixQueries (d:=p.dimension) (N:=N) (m:=p.bankSize) (s:=s) Real.tanh
  let hb := measurable_indexedPrefixQueries (d:=p.dimension) (N:=N) (m:=p.bankSize)
    (s:=s) tanh_lipschitzWith.continuous
  let h := indexedPrefixHidden (d:=p.dimension) (N:=N) (m:=p.bankSize) (s:=s) Real.tanh
  let hh := measurable_indexedPrefixHidden (d:=p.dimension) (N:=N) (m:=p.bankSize)
    (s:=s) tanh_lipschitzWith.continuous
  let i := (Fintype.equivFin (Cube p.dimension)) x
  refine ⟨selectedLayerJoint (q:=p.activeRank) Γ.law Real.tanh b hb S.queries S.measurable_queries
    h hh (p.inverseKernelPrecision : ℝ)⁻¹ t p.sourceClip
    (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound) i,?_,?_,?_⟩
  · exact selectedLayerJoint_probability Γ.law tanh_lipschitzWith.continuous b hb
      S.queries S.measurable_queries h hh _ _ _ _ _ i
  · exact selectedLayerJoint_left Γ.law tanh_lipschitzWith.continuous b hb
      S.queries S.measurable_queries h hh _ _ _ _ _ i
  · exact selectedLayerJoint_right (Fintype.equivFin (Cube p.dimension)).symm
      Γ.law tanh_lipschitzWith.continuous b hb S.queries S.measurable_queries
      h hh (fun _ _ => rfl) (by positivity) _ _ _ _ i

theorem resourceLayerComparison_future (t : ℝ)
    (Γ : CanonicalStateLaw p.dimension N p.bankSize s (k+1))
    (S : ActualPrefixSelection Γ Real.tanh tanh_lipschitzWith.continuous p.activeRank t
      ((p.inverseSelectionError : ℝ)⁻¹) ((p.inverseLayerFailure : ℝ)⁻¹))
    (x : Cube p.dimension) :
    ∀ᵐ z ∂(resourceLayerComparison p t Γ S x).joint,z.2.2=(splitFuture N k z.1.2).2 := by
  have h := selectedLayerJoint_future (q:=p.activeRank) Γ.law tanh_lipschitzWith.continuous
    (indexedPrefixQueries Real.tanh) (measurable_indexedPrefixQueries tanh_lipschitzWith.continuous)
    S.queries S.measurable_queries (indexedPrefixHidden Real.tanh)
    (measurable_indexedPrefixHidden tanh_lipschitzWith.continuous)
    (p.inverseKernelPrecision : ℝ)⁻¹ t p.sourceClip
    (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound)
    ((Fintype.equivFin (Cube p.dimension)) x)
  exact h.mono (fun _ hz => hz.symm)

theorem resourceLayerComparison_alive (t : ℝ)
    (Γ : CanonicalStateLaw p.dimension N p.bankSize s (k+1))
    (S : ActualPrefixSelection Γ Real.tanh tanh_lipschitzWith.continuous p.activeRank t
      ((p.inverseSelectionError : ℝ)⁻¹) ((p.inverseLayerFailure : ℝ)⁻¹))
    (x : Cube p.dimension) :
    ∀ᵐ z ∂(resourceLayerComparison p t Γ S x).joint,z.2.1.1=true → z.1.1.1=true := by
  exact selectedLayerJoint_alive_imp Γ.law tanh_lipschitzWith.continuous
    (indexedPrefixQueries Real.tanh) (measurable_indexedPrefixQueries tanh_lipschitzWith.continuous)
    S.queries S.measurable_queries (indexedPrefixHidden Real.tanh)
    (measurable_indexedPrefixHidden tanh_lipschitzWith.continuous)
    (p.inverseKernelPrecision : ℝ)⁻¹ t p.sourceClip
    (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound)
    ((Fintype.equivFin (Cube p.dimension)) x)

end NeuralGeneralization.RobustCompressionInduction
