import NeuralGeneralization.BatchTwoImprovedTerminalVariance
import NeuralGeneralization.BatchTwoImprovedPointwiseTerminal

/-! The fixed-input variance estimate under the actual common terminal coupling. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal BigOperators
namespace NeuralGeneralization.BatchTwoImprovedTerminal
open Classical ConcreteModel CompressionSampling RobustCompressionSampling
  RobustCompressionReadout RobustCompressionInduction BatchTwoImprovedInduction

variable {d N m r : ℕ}

theorem pointwise_terminal_sampling_joint_tail [NeZero N] (hm : 0 < m)
    (Q : Measure (TerminalState d N m r)) [IsProbabilityMeasure Q]
    {φ : ℝ → ℝ} (hφ : Continuous φ) (hb : ∀ z, |φ z| ≤ 1)
    {t B K η : ℝ} (hB : 0 < B) (hK : 0 ≤ K) (hη : 0 < η) (x : Cube d) :
    (terminalCoupling Q t B K).joint.real
      (pointwiseTerminalOutputFailure φ t B K η x) ≤ K/((m : ℝ)*η^2) := by
  let E : Set (TerminalState d N m r × (Fin m → Fin N)) :=
    (fun z => (z.1, terminalDraw t B K z.1 z.2)) ⁻¹'
      pointwiseTerminalOutputFailure φ t B K η x
  have hE : MeasurableSet E :=
    (measurableSet_pointwiseTerminalOutputFailure hφ t B K η x).preimage
      (measurable_fst.prodMk (measurable_terminalDraw t B K))
  change ((Q.prod (iidSamples (uniformIndexLaw N) m)).map
    (fun z => (z.1,terminalDraw t B K z.1 z.2))).real _ ≤ _
  rw [map_measureReal_apply
    (measurable_fst.prodMk (measurable_terminalDraw t B K))
    (measurableSet_pointwiseTerminalOutputFailure hφ t B K η x)]
  apply independent_row_mixture_le Q (iidSamples (uniformIndexLaw N) m) E hE
    (by positivity)
  intro p
  by_cases he : terminalEnergy t p.2 ≤ K
  · have ht := readout_sampling_variance_tail hm (terminalCoefficients t p.2)
      (activeHidden φ p.1) (activeHidden_bounded φ hb p.1) hB hη he x
    have hset : Prod.mk p ⁻¹' E =
        {I | K/B+η ≤ |sampledReadout (terminalCoefficients t p.2)
          (activeHidden φ p.1) B I x-readoutValue (terminalCoefficients t p.2)
            (activeHidden φ p.1) x|} := by
      ext I
      simp only [E, Set.mem_preimage, pointwiseTerminalOutputFailure, Set.mem_setOf_eq,
        he, true_and, terminalOriginalOutput, terminalDraw_output φ t B K p I x he]
    rwa [hset]
  · have hset : Prod.mk p ⁻¹' E = ∅ := by
      ext I
      simp [E, pointwiseTerminalOutputFailure, he]
    rw [hset, measureReal_empty]
    positivity

end NeuralGeneralization.BatchTwoImprovedTerminal
