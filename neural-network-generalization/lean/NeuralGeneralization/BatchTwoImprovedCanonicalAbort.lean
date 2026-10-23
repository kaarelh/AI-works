import NeuralGeneralization.BatchTwoImprovedCanonicalLayer
import NeuralGeneralization.RobustCompressionSelectedAbort

/-! Actual source-bank and selected-transition abort bounds. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InnerProductSpace WithLp
open scoped BigOperators RealInnerProductSpace ENNReal
namespace NeuralGeneralization.BatchTwoImprovedCanonicalLayer
open ConcreteModel RobustCompressionInduction RobustCompressionCanonicalLayer
open RobustGaussianGeometry RobustCompression BatchTwoImprovedWeightedSampling SquaredSampling Classical
variable {d N m s q r M : ℕ} {I : Type*} [Fintype I]
  [MeasurableSpace (QueryMessage I q)] [MeasurableSingletonClass (QueryMessage I q)]

theorem sharpReconstructionKernel_fst (hN : 0 < N) (hq : 0 < q) (t BH BG : ℝ) :
    (sharpReconstructionKernel (D:=N) (m:=m) hN hq t BH BG).fst =
      (sourceIndicesKernel hN hq m).comap Prod.fst measurable_fst := by
  exact Kernel.fst_compProd _ _

theorem sharpCanonicalLayerKernel_abort (hN : 0 < N) (hq : 0 < q) (hm : 0 < m)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (t BH BG : ℝ) {η : ℝ} (hη : 0 < η) (hη1 : η ≤ 1)
    (hbudget : 256*(268435456:ℝ)^2*(2*q)*restrictionLog m q ≤ η^2*m)
    (z : CanonicalLayerInput d N m s q I) (hz : z.1.1.1=true) (hmsg : z.2 ≠ none) :
    sharpCanonicalLayerKernel hN hq b hb t BH BG z {p | p.1=false} ≤ ENNReal.ofReal η := by
  have hbad : MeasurableSet {p : ActivePrefix d N m (s+1) | p.1=false} :=
    measurableSet_eq_fun measurable_fst measurable_const
  have hmDraw : Measurable (fun p : CanonicalLayerInput d N m s q I ×
      ((Fin m → Fin N) × (Fin N → Fin m → ℝ)) =>
      stepActive p.1.1.1 p.2 (sharpCanonicalSuccess b p.1 p.2)) :=
    measurable_stepActive _ _ _ (by fun_prop) (by fun_prop) (measurable_sharpCanonicalSuccess b hb)
  have hdraw : Measurable (fun p : (Fin m → Fin N) × (Fin N → Fin m → ℝ) =>
      stepActive z.1.1 p (sharpCanonicalSuccess b z p)) := hmDraw.comp measurable_prodMk_left
  rw [sharpCanonicalLayerKernel,parameterMap_apply,Measure.map_apply hdraw hbad]
  have he : (fun p => stepActive z.1.1 p (sharpCanonicalSuccess b z p)) ⁻¹' {p | p.1=false} =
      {p | sourceBad (canonicalBasis b z) p.1} := by
    ext p
    simp only [Set.mem_preimage,Set.mem_setOf_eq,stepActive,sharpCanonicalSuccess,hz,hmsg,
      true_and,Bool.true_and,decide_not,decide_eq_true_eq]
    by_cases hh : sourceBad (canonicalBasis b z) p.1 <;> simp [hh,hmsg]
  rw [he,sharpCanonicalDrawKernel,Kernel.comap_apply]
  have hs : MeasurableSet {p : Fin m → Fin N | sourceBad (canonicalBasis b z) p} :=
    Set.to_countable _ |>.measurableSet
  have hf := congrArg (fun K : Kernel (SharpReconstructionInput N N q) (Fin m → Fin N) =>
      K (sharpCanonicalInput b t z) {p | sourceBad (canonicalBasis b z) p})
    (sharpReconstructionKernel_fst (m:=m) hN hq t BH BG)
  rw [Kernel.fst_apply,Measure.map_apply measurable_fst hs,Kernel.comap_apply] at hf
  change sharpReconstructionKernel hN hq t BH BG (sharpCanonicalInput b t z)
    (Prod.fst ⁻¹' {p | sourceBad (canonicalBasis b z) p}) ≤ _
  rw [hf]
  have hbnd := sourceBank_failure hN hq hm (canonicalBasis b z) hη hη1 hbudget
  exact (ENNReal.toReal_le_toReal (measure_ne_top _ _) ENNReal.ofReal_ne_top).mp
    (by simpa only [Measure.real,ENNReal.toReal_ofReal hη.le,sharpCanonicalInput] using hbnd)

section Selected
variable [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)] [MeasurableSingletonClass (QueryMessage (Fin M) q)]

theorem sharp_selectedStep_abort_le (hq : 0 < q) (hm : 0 < m)
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)) (hJ : Measurable J)
    (t BH BG : ℝ) {η : ℝ} (hη : 0 < η) (hη1 : η ≤ 1)
    (hbudget : 256*(268435456:ℝ)^2*(2*q)*restrictionLog m q ≤ η^2*m) :
    (canonicalStepLaw Q (selectedMessageKernel (q:=q) J hJ)
      (sharpCanonicalLayerKernel (Nat.pos_of_neZero N) hq b hb t BH BG))
        {z | z.1.1=false} ≤ Q {z | z.1.1=false} +
      (RobustEntropy.currentRowJoint (prefixCurrentLaw Q)).fst
        {θ | abortQueryMessage q (J θ)=none} + ENNReal.ofReal η := by
  exact selectedStep_abort_le Q J hJ _ _ (fun z hz hmsg =>
    sharpCanonicalLayerKernel_abort (Nat.pos_of_neZero N) hq hm b hb t BH BG
      hη hη1 hbudget z hz hmsg)

theorem sharp_selectedStep_futureEntropy (hq : 0 < q)
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (b : ActivePrefix d N m s → Fin M → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)) (hJ : Measurable J)
    (t BH BG : ℝ) :
    RobustEntropy.futureEntropy (canonicalStepLaw Q (selectedMessageKernel (q:=q) J hJ)
      (sharpCanonicalLayerKernel (Nat.pos_of_neZero N) hq b hb t BH BG)) (futurePrior N r) ≤
      RobustEntropy.futureEntropy Q (futurePrior N (r+1))+
        ENNReal.ofReal (Real.log (Fintype.card (QueryMessage (Fin M) q))) := by
  exact canonicalStepLaw_futureEntropy_le Q _ _

end Selected
end NeuralGeneralization.BatchTwoImprovedCanonicalLayer
