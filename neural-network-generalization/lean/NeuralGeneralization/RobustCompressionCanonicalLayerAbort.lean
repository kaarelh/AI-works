import NeuralGeneralization.RobustCompressionCanonicalLayer
import NeuralGeneralization.RobustCompressionSourceBankGoodEvent

/-! # Actual source-bank abort probabilities for the canonical update -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionCanonicalLayer
open ConcreteModel RobustCompressionInduction RobustCompressionReconstruction
open RobustCompressionSourceBank RobustCompression CompressionSampling

variable {d N m s q : ℕ} {I : Type*} [Fintype I]
  [MeasurableSpace (QueryMessage I q)] [MeasurableSingletonClass (QueryMessage I q)]

/-- The source-index marginal remains exactly the independent uniform draw,
although all coefficient rows depend on the same source bank. -/
theorem reconstructionKernel_source_marginal [NeZero N] (a t T BH BG : ℝ)
    (p : ReconstructionInput N q) :
    (reconstructionKernel (m:=m) a t T BH BG p).map Prod.fst =
      iidSamples (uniformIndexLaw N) m := by
  rw [reconstructionKernel_factor]
  exact Measure.fst_compProd _ _

theorem canonicalDrawKernel_source_marginal [NeZero N]
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a t T BH BG : ℝ) (z : CanonicalLayerInput d N m s q I) :
    (canonicalDrawKernel b hb a t T BH BG z).map Prod.fst =
      iidSamples (uniformIndexLaw N) m := by
  exact reconstructionKernel_source_marginal a t T BH BG (canonicalReconstructionInput b t z)

/-- On a live prefix with a present finite query message, abort is precisely
failure of the literal shared source-bank test. -/
theorem canonicalLayerKernel_abort_eq_source_failure [NeZero N]
    {φ : ℝ → ℝ} (hφ : Continuous φ)
    (b : ActivePrefix d N m s → I → EuclideanSpace ℝ (Fin N)) (hb : Measurable b)
    (a t T BH BG : ℝ) (z : CanonicalLayerInput d N m s q I)
    (halive : z.1.1.1=true) (hmessage : z.2 ≠ none) :
    (canonicalLayerKernel hφ b hb a t T BH BG z).real {p | p.1=false} =
      (iidSamples (uniformIndexLaw N) m).real
        {J | ¬sourceBankGood (RobustGaussianGeometry.sourceRows (canonicalBasis b z))
          (activeHidden φ z.1.1) a T J} := by
  classical
  have hmap : Measurable (fun draw : ReconstructionOutput N m =>
      stepActive z.1.1 draw (canonicalLayerSuccess φ b a T z draw)) := by
    apply measurable_stepActive (fun _ => z.1.1) id
      (fun draw => canonicalLayerSuccess φ b a T z draw) measurable_const measurable_id
    exact (measurable_canonicalLayerSuccess hφ b hb a T).comp
      (measurable_const.prodMk measurable_id)
  have hs : MeasurableSet {p : ActivePrefix d N m (s+1) | p.1=false} :=
    measurableSet_eq_fun measurable_fst measurable_const
  rw [canonicalLayerKernel,parameterMap_apply,map_measureReal_apply hmap hs]
  have he : {draw : ReconstructionOutput N m |
      (stepActive z.1.1 draw (canonicalLayerSuccess φ b a T z draw)).1=false} =
      Prod.fst ⁻¹' {J | ¬sourceBankGood (RobustGaussianGeometry.sourceRows (canonicalBasis b z))
        (activeHidden φ z.1.1) a T J} := by
    ext draw
    simp only [Set.mem_setOf_eq,Set.mem_preimage]
    unfold stepActive canonicalLayerSuccess
    rw [halive]
    by_cases hgood : sourceBankGood (RobustGaussianGeometry.sourceRows (canonicalBasis b z))
        (activeHidden φ z.1.1) a T draw.1
    · rw [if_pos (Bool.and_eq_true_iff.mpr ⟨rfl, decide_eq_true ⟨hmessage,hgood⟩⟩)]
      simp only [Bool.true_eq_false, not_true_eq_false, hgood]
    · rw [if_neg (fun hh => hgood (of_decide_eq_true (Bool.and_eq_true_iff.mp hh).2).2)]
      simp only [hgood, not_false_eq_true]
  change (canonicalDrawKernel b hb a t T BH BG z).real
    {draw | (stepActive z.1.1 draw (canonicalLayerSuccess φ b a T z draw)).1=false} = _
  rw [he]
  have hbad : MeasurableSet {J : Fin m → Fin N |
      ¬sourceBankGood (RobustGaussianGeometry.sourceRows (canonicalBasis b z))
        (activeHidden φ z.1.1) a T J} := (Set.to_countable _).measurableSet
  rw [← map_measureReal_apply measurable_fst hbad,
    canonicalDrawKernel_source_marginal]

/-- Instantiation with the declared literal resource formulas. -/
theorem canonicalLayerKernel_abort_resource_le (p : RobustCompressionInput) [NeZero N]
    {I : Type*} [Fintype I]
    [MeasurableSpace (QueryMessage I p.activeRank)]
    [MeasurableSingletonClass (QueryMessage I p.activeRank)]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hφbound : ∀ z, |φ z| ≤ 1)
    (b : ActivePrefix p.dimension N p.bankSize s → I → EuclideanSpace ℝ (Fin N))
    (hb : Measurable b) (t : ℝ)
    (z : CanonicalLayerInput p.dimension N p.bankSize s p.activeRank I)
    (halive : z.1.1.1=true) (hmessage : z.2 ≠ none)
    (hE : 0 < p.inverseLayerError) (hη : 0 < p.inverseLayerFailure) :
    (canonicalLayerKernel hφ b hb (p.inverseKernelPrecision : ℝ)⁻¹ t
      p.sourceClip (Real.sqrt p.activeSquaredBound) (Real.sqrt p.gaussianSquaredBound) z).real
      {next | next.1=false} ≤ (p.inverseLayerFailure : ℝ)⁻¹ := by
  rw [canonicalLayerKernel_abort_eq_source_failure hφ b hb _ _ _ _ _ z halive hmessage]
  exact sourceBankGood_resource_failure p _ (activeHidden φ z.1.1)
    (fun x i => activeHidden_bounded φ hφbound z.1.1 x i) hE hη

end NeuralGeneralization.RobustCompressionCanonicalLayer
