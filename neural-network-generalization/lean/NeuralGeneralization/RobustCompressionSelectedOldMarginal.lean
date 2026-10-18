import NeuralGeneralization.RobustCompressionInductionSelected
import NeuralGeneralization.RobustCompressionSampledLayer

/-! # Exact restoration of the original state from the layer comparison

The actual current-row disintegration is integrated against its own marginal.
Discarding the independent dummy and the candidate leaves precisely the old
state law, including its dependencies on the remaining future.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionInduction
open RobustEntropy RobustCompressionLayerComparison RobustCompressionLayerGaussian

variable {d N m s r q : ℕ}
local notation "Rows" => Fin N → EuclideanSpace ℝ (Fin N)
local notation "Base" => ActivePrefix d N m s × FutureWeights N r
local notation "Dummy" => Fin N → ℝ

def restoreCurrentRowState (z : Base × Rows) :
    ActivePrefix d N m s × FutureWeights N (r+1) :=
  (z.1.1,(splitFuture N r).symm (flattenRows N z.2,z.1.2))

theorem measurable_restoreCurrentRowState :
    Measurable (restoreCurrentRowState (d:=d) (N:=N) (m:=m) (s:=s) (r:=r)) :=
  measurable_fst.fst.prodMk ((splitFuture N r).symm.measurable.comp
    (((measurable_flattenRows N).comp measurable_snd).prodMk measurable_fst.snd))

theorem currentRowJoint_restore
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) :
    (currentRowJoint (prefixCurrentLaw Q)).map restoreCurrentRowState = Q := by
  unfold currentRowJoint prefixCurrentLaw
  rw [Measure.map_map measurable_currentGivenFuture (measurable_splitRowsState N r),
    Measure.map_map measurable_restoreCurrentRowState
      (measurable_currentGivenFuture.comp (measurable_splitRowsState N r))]
  have he : restoreCurrentRowState ∘ currentGivenFuture ∘ splitRowsState N r =
      (id : ActivePrefix d N m s × FutureWeights N (r+1) → _) := by
    funext z
    simp only [Function.comp_def,restoreCurrentRowState,currentGivenFuture,splitRowsState,
      flattenRows_internalRows,MeasurableEquiv.symm_apply_apply,Prod.mk.eta,id_eq]
  rw [he,Measure.map_id]

def currentRowDummyKernel
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q] :
    Kernel Base (Rows × Dummy) :=
  (currentRowJoint (prefixCurrentLaw Q)).condKernel ×ₖ
    Kernel.const Base (RobustCoupling.standardGaussianVector N)

instance currentRowDummyKernel_markov
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q] :
    IsMarkovKernel (currentRowDummyKernel Q) := by
  unfold currentRowDummyKernel
  infer_instance

theorem currentRowDummyKernel_fst
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q] :
    (currentRowDummyKernel Q).fst = (currentRowJoint (prefixCurrentLaw Q)).condKernel := by
  ext a : 1
  rw [Kernel.fst_apply,currentRowDummyKernel,Kernel.prod_apply,Kernel.const_apply]
  simp only [Measure.map_fst_prod,measure_univ,one_smul]

section General
variable {A Ω C : Type*} [MeasurableSpace A] [MeasurableSpace Ω] [MeasurableSpace C]

theorem integrated_kernel_original (μ : Measure A) [SFinite μ]
    (K : Kernel A (Ω × C)) [IsMarkovKernel K]
    (κ : Kernel A Ω) (hκ : K.fst=κ) :
    (μ ⊗ₘ K).map (Prod.map id Prod.fst) = μ ⊗ₘ κ := by
  rw [← Measure.compProd_map measurable_fst, ← Kernel.fst_eq, hκ]
end General

/-- Any actual layer comparison retaining the complete row-and-dummy kernel
has the exact original state law after removing its new candidate. -/
theorem layer_comparison_restores_old {C : Type*} [MeasurableSpace C]
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (K : Kernel Base ((Rows × Dummy) × C)) [IsMarkovKernel K]
    (hK : K.fst = currentRowDummyKernel Q) :
    ((currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ K).map
      (fun z => restoreCurrentRowState (z.1,z.2.1.1)) = Q := by
  have h₁ := integrated_kernel_original (currentRowJoint (prefixCurrentLaw Q)).fst
    K (currentRowDummyKernel Q) hK
  have h₂ := integrated_kernel_original (currentRowJoint (prefixCurrentLaw Q)).fst
    (currentRowDummyKernel Q) (currentRowJoint (prefixCurrentLaw Q)).condKernel
      (currentRowDummyKernel_fst Q)
  rw [Measure.disintegrate] at h₂
  have h := congrArg (fun μ => μ.map (Prod.map id Prod.fst)) h₁
  rw [Measure.map_map (by fun_prop) (by fun_prop),h₂] at h
  have h' := congrArg (fun μ => μ.map restoreCurrentRowState) h
  rw [Measure.map_map measurable_restoreCurrentRowState (by fun_prop),currentRowJoint_restore] at h'
  exact h'

/-- The full sampled-layer coupling has the restoration property outright;
no candidate-marginal or contraction premise is used on this side. -/
theorem fullSampledLayerCoupling_restores_old [NeZero N]
    {H : Type*} [MeasurableSpace H] [StandardBorelSpace H]
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (o : Base × (Rows × Dummy) → H × Dummy) (ho : Measurable o)
    (ρ : Kernel Base (H × Dummy)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((Base × H) × (Fin m → Fin N)) N m q) :
    ((currentRowJoint (prefixCurrentLaw Q)).fst ⊗ₘ
      fullSampledLayerCoupling (currentRowDummyKernel Q) o ho ρ p).map
        (fun z => restoreCurrentRowState (z.1,z.2.1.1)) = Q :=
  layer_comparison_restores_old Q _
    (fullSampledLayerCoupling_original (currentRowDummyKernel Q) o ho ρ p)

end NeuralGeneralization.RobustCompressionInduction
