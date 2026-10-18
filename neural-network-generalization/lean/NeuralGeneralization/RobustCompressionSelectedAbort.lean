import NeuralGeneralization.RobustCompressionCanonicalLayerAbort
import NeuralGeneralization.RobustCompressionSelectedStepLaw
import NeuralGeneralization.RobustCompressionSelectedOldMarginal

/-! # Actual accumulated abort mass of one selected transition -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustEntropy RobustCompressionCanonicalLayer

section Generic
variable {A B : Type*} [MeasurableSpace A] [MeasurableSpace B]

theorem comp_event_le_two_exceptions
    (μ : Measure A) [IsProbabilityMeasure μ]
    (κ : Kernel A B) [IsMarkovKernel κ]
    (old rank : Set A) (hold : MeasurableSet old) (hrank : MeasurableSet rank)
    (bad : Set B) (hbad : MeasurableSet bad) (η : ℝ≥0∞)
    (hpoint : ∀ a, a ∉ old → a ∉ rank → κ a bad ≤ η) :
    (κ ∘ₘ μ) bad ≤ μ old + μ rank + η := by
  rw [Measure.bind_apply hbad κ.aemeasurable]
  have hp : ∀ a, κ a bad ≤ old.indicator (fun _ => 1) a +
      rank.indicator (fun _ => 1) a + η := by
    intro a
    have hprob : κ a bad ≤ 1 := prob_le_one
    by_cases ho : a ∈ old
    · rw [Set.indicator_of_mem ho]
      exact hprob.trans ((le_add_right le_rfl).trans (le_add_right le_rfl))
    · rw [Set.indicator_of_notMem ho,zero_add]
      by_cases hr : a ∈ rank
      · rw [Set.indicator_of_mem hr]
        exact hprob.trans (le_add_right le_rfl)
      · rw [Set.indicator_of_notMem hr,zero_add]
        exact hpoint a ho hr
  calc
    _ ≤ ∫⁻ a, old.indicator (fun _ => 1) a + rank.indicator (fun _ => 1) a + η ∂μ :=
      lintegral_mono hp
    _ = _ := by
      rw [lintegral_add_left (by fun_prop),lintegral_add_left (by fun_prop),
        lintegral_indicator_fun_one hold,lintegral_indicator_fun_one hrank]
      simp
end Generic

variable {d N m s r M q : ℕ} [NeZero N]
  [MeasurableSpace (Finset (Fin M))] [MeasurableSingletonClass (Finset (Fin M))]
  [MeasurableSpace (QueryMessage (Fin M) q)]
  [MeasurableSingletonClass (QueryMessage (Fin M) q)]

theorem selectedStep_abort_le
    (Q : Measure (ActivePrefix d N m s × FutureWeights N (r+1))) [IsProbabilityMeasure Q]
    (J : ActivePrefix d N m s × FutureWeights N r → Finset (Fin M)) (hJ : Measurable J)
    (χ : Kernel ((ActivePrefix d N m s × InternalBlock N) × QueryMessage (Fin M) q)
      (ActivePrefix d N m (s+1))) [IsMarkovKernel χ]
    (η : ℝ≥0∞)
    (hbank : ∀ z, z.1.1.1=true → z.2 ≠ none → χ z {next | next.1=false} ≤ η) :
    (canonicalStepLaw Q (selectedMessageKernel (q:=q) J hJ) χ) {z | z.1.1=false} ≤
      Q {z | z.1.1=false} +
      (currentRowJoint (prefixCurrentLaw Q)).fst {θ | abortQueryMessage q (J θ)=none} + η := by
  let old : Set (DirectRowState d N m s r) := {z | z.1.1.1=false}
  let rank : Set (DirectRowState d N m s r) := {z | abortQueryMessage q (J z.1)=none}
  have hold : MeasurableSet old := measurableSet_eq_fun (by fun_prop) measurable_const
  have hrank : MeasurableSet rank := measurableSet_eq_fun
    ((measurable_abortQueryMessage J hJ).comp measurable_fst) measurable_const
  have hbad : MeasurableSet {z : ActivePrefix d N m (s+1) × FutureWeights N r | z.1.1=false} :=
    measurableSet_eq_fun (by fun_prop) measurable_const
  rw [canonicalStepLaw_eq_direct_rows]
  have h := comp_event_le_two_exceptions (currentRowJoint (prefixCurrentLaw Q))
    (directSelectedRowKernel J hJ χ) old rank hold hrank _ hbad η (by
      intro z ho hr
      rw [directSelectedRowKernel_apply,Measure.map_apply (by fun_prop) hbad]
      apply hbank
      · have hne : z.1.1.1 ≠ false := ho
        cases hz : z.1.1.1 <;> simp_all
      · exact hr)
  have ho : (currentRowJoint (prefixCurrentLaw Q)) old = Q {z | z.1.1=false} := by
    have he := congrArg (fun μ : Measure (ActivePrefix d N m s × FutureWeights N (r+1)) =>
      μ {z | z.1.1=false}) (currentRowJoint_restore Q)
    rw [Measure.map_apply measurable_restoreCurrentRowState
      (measurableSet_eq_fun (by fun_prop) measurable_const)] at he
    exact he
  have hr : (currentRowJoint (prefixCurrentLaw Q)) rank =
      (currentRowJoint (prefixCurrentLaw Q)).fst {θ | abortQueryMessage q (J θ)=none} := by
    rw [Measure.fst,Measure.map_apply measurable_fst
      (measurableSet_eq_fun (measurable_abortQueryMessage J hJ) measurable_const)]
    rfl
  simpa only [ho,hr] using h

/-- Rank selection and literal source-bank concentration each contribute one
declared reciprocal layer-failure budget. -/
theorem selectedStep_abort_resource_le (p : RobustCompressionInput)
    [MeasurableSpace (QueryMessage (Fin M) p.activeRank)]
    [MeasurableSingletonClass (QueryMessage (Fin M) p.activeRank)]
    (Q : Measure (ActivePrefix p.dimension N p.bankSize s × FutureWeights N (r+1)))
    [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hφbound : ∀ z, |φ z|≤1)
    (b : ActivePrefix p.dimension N p.bankSize s → Fin M → EuclideanSpace ℝ (Fin N))
    (hb : Measurable b) (t : ℝ)
    (J : ActivePrefix p.dimension N p.bankSize s × FutureWeights N r → Finset (Fin M))
    (hJ : Measurable J) (hE : 0 < p.inverseLayerError) (hη : 0 < p.inverseLayerFailure)
    (hrank : (currentRowJoint (prefixCurrentLaw Q)).fst.real
      {θ | abortQueryMessage p.activeRank (J θ)=none} ≤ (p.inverseLayerFailure : ℝ)⁻¹) :
    (canonicalStepLaw Q (selectedMessageKernel (q:=p.activeRank) J hJ)
      (canonicalLayerKernel hφ b hb (p.inverseKernelPrecision : ℝ)⁻¹ t p.sourceClip
        (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound))) {z | z.1.1=false} ≤
      Q {z | z.1.1=false} + 2*ENNReal.ofReal ((p.inverseLayerFailure : ℝ)⁻¹) := by
  have hbank : ∀ z : CanonicalLayerInput p.dimension N p.bankSize s p.activeRank (Fin M),
      z.1.1.1=true → z.2 ≠ none →
      (canonicalLayerKernel hφ b hb (p.inverseKernelPrecision : ℝ)⁻¹ t p.sourceClip
        (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound) z) {next | next.1=false} ≤
          ENNReal.ofReal ((p.inverseLayerFailure : ℝ)⁻¹) := by
    intro z halive hmessage
    have h := ENNReal.ofReal_le_ofReal
      (canonicalLayerKernel_abort_resource_le p hφ hφbound b hb t z halive hmessage hE hη)
    have hfin : (canonicalLayerKernel hφ b hb (p.inverseKernelPrecision : ℝ)⁻¹ t p.sourceClip
        (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound) z) {next | next.1=false} ≠ ∞ :=
      measure_ne_top _ _
    rw [measureReal_def,ENNReal.ofReal_toReal hfin] at h
    exact h
  have hr := ENNReal.ofReal_le_ofReal hrank
  rw [ofReal_measureReal] at hr
  have h := selectedStep_abort_le Q J hJ _ _ hbank
  calc
    _ ≤ Q {z | z.1.1=false} +
      (currentRowJoint (prefixCurrentLaw Q)).fst {θ | abortQueryMessage p.activeRank (J θ)=none} +
        ENNReal.ofReal ((p.inverseLayerFailure : ℝ)⁻¹) := h
    _ ≤ Q {z | z.1.1=false} + ENNReal.ofReal ((p.inverseLayerFailure : ℝ)⁻¹) +
        ENNReal.ofReal ((p.inverseLayerFailure : ℝ)⁻¹) := add_le_add (add_le_add le_rfl hr) le_rfl
    _ = _ := by rw [two_mul,add_assoc]

end NeuralGeneralization.RobustCompressionInduction
