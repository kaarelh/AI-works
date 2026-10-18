import NeuralGeneralization.RobustCompressionTerminalMoments

/-! # Integrated terminal sampling with the original prefix/readout joint retained -/
noncomputable section
set_option maxHeartbeats 800000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped ENNReal BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustCompressionReadout RobustCompressionSampling CompressionSampling

variable {d N m s : ℕ}

def terminalOriginalOutput (φ : ℝ → ℝ) (t : ℝ)
    (p : TerminalState d N m s) (x : Cube d) : ℝ :=
  readoutValue (terminalCoefficients t p.2) (activeHidden φ p.1) x

theorem measurable_terminalOriginalOutput {φ : ℝ → ℝ} (hφ : Continuous φ)
    (t : ℝ) (x : Cube d) :
    Measurable (fun p : TerminalState d N m s => terminalOriginalOutput φ t p x) := by
  have hh := (measurable_activeHidden (N := N) (m := m) (s := s) hφ x).comp
    (measurable_fst : Measurable (Prod.fst : TerminalState d N m s → ActivePrefix d N m s))
  unfold terminalOriginalOutput readoutValue populationMean terminalCoefficients
  fun_prop

def terminalSamplingFailure (φ : ℝ → ℝ) (t B K η : ℝ) :
    Set (TerminalState d N m s × (Fin m → Fin N)) :=
  {z | terminalEnergy t z.1.2 ≤ K ∧ ∃ x : Cube d,
    K/B+η ≤ |networkOutput φ (terminalDraw t B K z.1 z.2) x -
      terminalOriginalOutput φ t z.1 x|}

theorem measurableSet_terminalSamplingFailure {φ : ℝ → ℝ} (hφ : Continuous φ)
    (t B K η : ℝ) :
    MeasurableSet (terminalSamplingFailure (d := d) (N := N) (m := m) (s := s) φ t B K η) := by
  have hs (x : Cube d) : MeasurableSet
      {z : TerminalState d N m s × (Fin m → Fin N) |
        K/B+η ≤ |networkOutput φ (terminalDraw t B K z.1 z.2) x -
          terminalOriginalOutput φ t z.1 x|} :=
    measurableSet_le measurable_const
      (((continuous_networkOutput hφ x).measurable.comp (measurable_terminalDraw t B K)).sub
        ((measurable_terminalOriginalOutput hφ t x).comp measurable_fst)).abs
  unfold terminalSamplingFailure
  have he : {z : TerminalState d N m s × (Fin m → Fin N) |
      terminalEnergy t z.1.2 ≤ K ∧ ∃ x : Cube d,
      K/B+η ≤ |networkOutput φ (terminalDraw t B K z.1 z.2) x -
        terminalOriginalOutput φ t z.1 x|} =
      {z | terminalEnergy t z.1.2 ≤ K} ∩ ⋃ x : Cube d,
        {z | K/B+η ≤ |networkOutput φ (terminalDraw t B K z.1 z.2) x -
          terminalOriginalOutput φ t z.1 x|} := by ext z; simp
  rw [he]
  exact (measurableSet_le ((measurable_terminalEnergy t).comp (by fun_prop))
    measurable_const).inter (MeasurableSet.iUnion hs)

/-- A single common candidate law, with no queried input in its definition. -/
def terminalCandidateLaw [NeZero N] (Q : Measure (TerminalState d N m s))
    (t B K : ℝ) : Measure (Weights d m s) :=
  (Q.prod (iidSamples (uniformIndexLaw N) m)).map (fun z => terminalDraw t B K z.1 z.2)

instance terminalCandidateLaw_probability [NeZero N]
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q] (t B K : ℝ) :
    IsProbabilityMeasure (terminalCandidateLaw Q t B K) :=
  Measure.isProbabilityMeasure_map (measurable_terminalDraw t B K).aemeasurable

/-- The full terminal state and final ordinary network have their exact
prescribed marginals under the actual sampling construction. -/
def terminalCoupling [NeZero N]
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q] (t B K : ℝ) :
    RobustStatistics.ProbabilityCoupling Q (terminalCandidateLaw Q t B K) where
  joint := (Q.prod (iidSamples (uniformIndexLaw N) m)).map
    (fun z => (z.1,terminalDraw t B K z.1 z.2))
  probability := Measure.isProbabilityMeasure_map
    (measurable_fst.prodMk (measurable_terminalDraw t B K)).aemeasurable
  left := by
    rw [Measure.map_map measurable_fst (measurable_fst.prodMk (measurable_terminalDraw t B K))]
    change (Q.prod (iidSamples (uniformIndexLaw N) m)).map Prod.fst = Q
    exact (measurePreserving_fst (μ := Q) (ν := iidSamples (uniformIndexLaw N) m)).map_eq
  right := by
    rw [Measure.map_map measurable_snd (measurable_fst.prodMk (measurable_terminalDraw t B K))]
    rfl

/-- Integrating the literal independent index sample preserves the pointwise
all-input tail, even though prefix and readout may be arbitrarily dependent. -/
theorem terminal_sampling_joint_tail [NeZero N] (hm : 0 < m)
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hb : ∀ z, |φ z| ≤ 1)
    {t B K η : ℝ} (hB : 0 < B) (hη : 0 ≤ η) :
    (Q.prod (iidSamples (uniformIndexLaw N) m)).real
      (terminalSamplingFailure φ t B K η) ≤
        (2 : ℝ)^d * (2*Real.exp (-(m : ℝ)*η^2/(2*B^2))) := by
  let ν := iidSamples (uniformIndexLaw N) m
  let δ : ℝ := (2 : ℝ)^d * (2*Real.exp (-(m : ℝ)*η^2/(2*B^2)))
  have hslice (p : TerminalState d N m s) :
      ν (Prod.mk p ⁻¹' terminalSamplingFailure φ t B K η) ≤ ENNReal.ofReal δ := by
    by_cases he : terminalEnergy t p.2 ≤ K
    · have ht := terminalDraw_sampling_tail hm φ hb hB hη p he
      have hc := ENNReal.ofReal_le_ofReal ht
      rw [measureReal_def, ENNReal.ofReal_toReal (measure_ne_top _ _)] at hc
      simpa only [terminalSamplingFailure, Set.preimage_setOf_eq, he, true_and,
        terminalOriginalOutput, ν, δ] using hc
    · have hz : Prod.mk p ⁻¹' terminalSamplingFailure φ t B K η = ∅ := by
        ext I
        simp [terminalSamplingFailure, he]
      rw [hz, measure_empty]
      exact zero_le
  have hg : Q.prod ν (terminalSamplingFailure φ t B K η) ≤ ENNReal.ofReal δ := by
    rw [Measure.prod_apply (measurableSet_terminalSamplingFailure hφ t B K η)]
    exact (lintegral_mono hslice).trans_eq (by simp)
  have hr := ENNReal.toReal_mono ENNReal.ofReal_ne_top hg
  rw [ENNReal.toReal_ofReal (by positivity : 0 ≤ δ)] at hr
  exact hr

/-- Literal declared resources make the terminal all-input sampling error at
most the reciprocal layer-failure budget. -/
theorem terminal_sampling_resource_tail (p : RobustCompressionInput) [NeZero N]
    (Q : Measure (TerminalState p.dimension N p.bankSize s)) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hb : ∀ z, |φ z| ≤ 1) (t : ℝ)
    (hη : 0 < p.inverseLayerFailure) (hR : 0 < p.inverseRadius) :
    (Q.prod (iidSamples (uniformIndexLaw N) p.bankSize)).real
      (terminalSamplingFailure φ t p.readoutClip p.readoutMoment
        (1/(16*(p.inverseRadius : ℝ)))) ≤ (p.inverseLayerFailure : ℝ)⁻¹ := by
  have hB : (0 : ℝ) < p.readoutClip := by exact_mod_cast p.readoutClip_pos hη hR
  exact (terminal_sampling_joint_tail p.bankSize_pos Q hφ hb hB
    (by positivity : 0 ≤ 1/(16*(p.inverseRadius : ℝ)))).trans
      (by simpa only [neg_div, neg_mul] using p.readout_sampling_failure hη hR)

end NeuralGeneralization.RobustCompressionInduction
