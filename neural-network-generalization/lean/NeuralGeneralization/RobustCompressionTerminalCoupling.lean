import NeuralGeneralization.RobustCompressionTerminalSampling

/-! # The exact final-network coupling and its all-input readout failure -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel CompressionSampling
variable {d N m s : ℕ}

def terminalOutputFailure (φ : ℝ → ℝ) (t B K η : ℝ) :
    Set (TerminalState d N m s × Weights d m s) :=
  {z | terminalEnergy t z.1.2 ≤ K ∧ ∃ x : Cube d,
    K/B+η ≤ |networkOutput φ z.2 x - terminalOriginalOutput φ t z.1 x|}

theorem measurableSet_terminalOutputFailure {φ : ℝ → ℝ} (hφ : Continuous φ)
    (t B K η : ℝ) :
    MeasurableSet (terminalOutputFailure (d := d) (N := N) (m := m) (s := s) φ t B K η) := by
  have hs (x : Cube d) : MeasurableSet
      {z : TerminalState d N m s × Weights d m s |
        K/B+η ≤ |networkOutput φ z.2 x - terminalOriginalOutput φ t z.1 x|} :=
    measurableSet_le measurable_const
      (((continuous_networkOutput hφ x).measurable.comp measurable_snd).sub
        ((measurable_terminalOriginalOutput hφ t x).comp measurable_fst)).abs
  unfold terminalOutputFailure
  have he : {z : TerminalState d N m s × Weights d m s |
      terminalEnergy t z.1.2 ≤ K ∧ ∃ x : Cube d,
      K/B+η ≤ |networkOutput φ z.2 x - terminalOriginalOutput φ t z.1 x|} =
      {z | terminalEnergy t z.1.2 ≤ K} ∩ ⋃ x : Cube d,
        {z | K/B+η ≤ |networkOutput φ z.2 x - terminalOriginalOutput φ t z.1 x|} := by
    ext z; simp
  rw [he]
  exact (measurableSet_le ((measurable_terminalEnergy t).comp (by fun_prop))
    measurable_const).inter (MeasurableSet.iUnion hs)

theorem terminalCoupling_sampling_tail [NeZero N] (hm : 0 < m)
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hb : ∀ z, |φ z| ≤ 1)
    {t B K η : ℝ} (hB : 0 < B) (hη : 0 ≤ η) :
    (terminalCoupling Q t B K).joint.real (terminalOutputFailure φ t B K η) ≤
      (2 : ℝ)^d * (2*Real.exp (-(m : ℝ)*η^2/(2*B^2))) := by
  change ((Q.prod (iidSamples (uniformIndexLaw N) m)).map
    (fun z => (z.1,terminalDraw t B K z.1 z.2))).real _ ≤ _
  rw [measureReal_def, Measure.map_apply
    (measurable_fst.prodMk (measurable_terminalDraw t B K))
    (measurableSet_terminalOutputFailure hφ t B K η)]
  exact terminal_sampling_joint_tail hm Q hφ hb hB hη

theorem terminalCoupling_resource_tail (p : RobustCompressionInput) [NeZero N]
    (Q : Measure (TerminalState p.dimension N p.bankSize s)) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hb : ∀ z, |φ z| ≤ 1) (t : ℝ)
    (hη : 0 < p.inverseLayerFailure) (hR : 0 < p.inverseRadius) :
    (terminalCoupling Q t p.readoutClip p.readoutMoment).joint.real
      (terminalOutputFailure φ t p.readoutClip p.readoutMoment
        (1/(16*(p.inverseRadius : ℝ)))) ≤ (p.inverseLayerFailure : ℝ)⁻¹ := by
  have hB : (0 : ℝ) < p.readoutClip := by exact_mod_cast p.readoutClip_pos hη hR
  exact (terminalCoupling_sampling_tail p.bankSize_pos Q hφ hb hB
    (by positivity : 0 ≤ 1/(16*(p.inverseRadius : ℝ)))).trans
      (by simpa only [neg_div, neg_mul] using p.readout_sampling_failure hη hR)

/-- Bounded live prefixes produce an actually bounded common final-network law.
No independence between the prefix and remaining readout is required. -/
theorem terminalCandidateLaw_bounded [NeZero N]
    (Q : Measure (TerminalState d N m s)) [IsProbabilityMeasure Q]
    {t B K W : ℝ} (hB : 0 ≤ B) (hW : 0 ≤ W) (hBW : B ≤ W) (hm : 0 < m)
    (hQ : ∀ᵐ p ∂Q, activePrefixBounded W p.1) :
    ∀ᵐ w ∂terminalCandidateLaw Q t B K, boundedWeights W w := by
  have hset : MeasurableSet {w : Weights d m s | boundedWeights W w} := by
    change MeasurableSet {w : Weights d m s | ∀ i, |w i| ≤ W}
    rw [Set.setOf_forall]
    exact MeasurableSet.iInter (fun i => measurableSet_le
      (measurable_pi_apply i).abs measurable_const)
  rw [terminalCandidateLaw, ae_map_iff (measurable_terminalDraw t B K).aemeasurable hset]
  have hQ' : ∀ᵐ p ∂(Q.prod (iidSamples (uniformIndexLaw N) m)).map Prod.fst,
      activePrefixBounded W p.1 := by
    rw [(measurePreserving_fst (μ := Q)
      (ν := iidSamples (uniformIndexLaw N) m)).map_eq]
    exact hQ
  filter_upwards [ae_of_ae_map measurable_fst.aemeasurable hQ'] with z hz
  exact terminalDraw_bounded hB hW hBW hm z.1 hz z.2

end NeuralGeneralization.RobustCompressionInduction
