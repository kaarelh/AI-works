import NeuralGeneralization.RobustCompressionInductionComplete
import NeuralGeneralization.RobustCompressionInductionTerminalResources
import NeuralGeneralization.RobustMainReduction

/-! # Unconditional constructive large-width raw-path compression

Every source of randomness, selected message, clipped reconstruction, retained
original history, and final sampled readout is instantiated. The hypotheses
are only the literal original Gaussian-relative entropy and scalar resources.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustMainProofs
open ConcreteModel RobustEntropy RobustCompressionInduction

/-- The analytic construction required by the final learning theorem. -/
theorem largeWidthRawCompression : LargeWidthRawCompression := by
  intro p hd hdepth hK hA hR N hN σ t hσ ht ht1 htdef Q hprob hKL
  have hn : 0<N := lt_trans p.widthBound_pos hN
  letI : NeZero N := ⟨hn.ne'⟩
  letI : IsProbabilityMeasure Q := hprob
  letI : MeasurableSpace (QueryMessage (Fin (Fintype.card (Cube p.dimension))) p.activeRank) := ⊤
  have hscale : (N : ℝ)*σ^2≤1 := htdef ▸ ht1
  have hKL' : klDiv Q (smallPrior p.dimension N (p.depth-2) σ) ≤
      ENNReal.ofReal ((p.energy : ℝ)/σ^2) := by
    have he : (N : ℝ)*p.energy/((N : ℝ)*σ^2)=(p.energy : ℝ)/σ^2 := by
      have hn' : (N : ℝ)≠0 := by positivity
      field_simp
    simpa only [htdef,he] using hKL
  obtain ⟨Γ,hΓ,hhistory⟩ := exists_actual_terminal_histories p hd (by omega)
    (by omega : 0<p.energy) hA (by omega : 0<p.inverseRadius) hN.le hσ hscale Q hKL'
  have hentropy := ResourceInvariant.entropy_cap p hσ hscale hN.le
    (by omega : 0<p.energy) (by omega : p.depth-2≤p.depth) Γ hΓ
  refine ⟨terminalCandidateLaw Γ.law (σ*Real.sqrt (N : ℝ)) p.readoutClip p.readoutMoment,
    inferInstance,?_⟩
  exact rawPathCompression_of_resource_terminal_histories p (by omega) hA (by omega)
    hσ hscale tanh_lipschitzWith.continuous (fun z => (Real.abs_tanh_lt_one z).le)
    Q Γ.law hentropy hΓ.2.1 hhistory hΓ.2.2

end NeuralGeneralization.RobustMainProofs
