import NeuralGeneralization.BatchTwoContinuousStatistics
import NeuralGeneralization.BatchTwoContinuousPriorGeometry

/-! The finite-sample posterior theorem from the proved uniform cover and an
explicit raw prior tail/target ratio. The strong-prior endpoint supplies that
ratio from the actual product prior, rather than assuming concentration. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling BatchTwoSurvivalStatistics

theorem iid_domain_ae {d n : ℕ} (D : Measure (RealInput d)) [IsProbabilityMeasure D]
    (X : Set (RealInput d)) (hDX : D Xᶜ=0) : ∀ᵐ s ∂iidSamples D n, ∀ i, s i ∈ X := by
  have hX : ∀ᵐ x ∂D, x ∈ X := by rw [ae_iff]; exact hDX
  apply eventually_all.mpr
  intro i
  exact Measure.tendsto_eval_ae_ae.eventually hX

theorem regression_learning_of_tail {d N r K R : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K) (hR : 1 ≤ R)
    (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ]
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (hcφ : Continuous φ)
    (f : RealInput d → ℝ) (hf : Continuous f)
    (X : Set (RealInput d)) (hX : X.Nonempty) (hcompact : IsCompact X)
    (hball : ∀ x ∈ X, ∑ j, x j^2 ≤ 1)
    {ρ τ u β : ℝ} (hu : 0 ≤ u) (hgap : ρ+2*(1/(3*(R : ℝ))) ≤ τ)
    (hpos : 0 < μ.real (uniformTube φ f X ρ))
    (htail : μ.real {w | (K : ℝ) < weightedSquaredNorm w}/μ.real (uniformTube φ f X ρ) ≤ β)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D] (hDX : D Xᶜ=0)
    {δ : ℝ} (hδ : 0 < δ) (n : ℕ)
    (hsize : (coverEntropy d r K R : ℝ)+Real.log (1/δ) ≤ (n : ℝ)*u) :
    1-δ ≤ (iidSamples D n).real {s |
      risk φ D (posterior φ μ f ρ s) f τ ≤ u+β ∧
      confidenceFailure φ D (posterior φ μ f ρ s) f τ ≤ 3*(u+β)} := by
  classical
  let H := UniformCoverCode d r K R
  letI : Nonempty H := ⟨fun _ => ⟨0,by simp⟩⟩
  let g := uniformCoverOutput d r K R φ
  let A := regressionComparison f g ρ (1/(3*(R : ℝ)))
  have hA : ∀ h, MeasurableSet (A h) := measurable_regressionComparison hf.measurable g
    (fun h => (continuous_output_input hcφ _).measurable) _ _
  have hprob := goodSamples_probability_log D A hA n hδ (uniformCoverCode_card_le_exp d r K R) hsize
  apply hprob.trans
  apply ENNReal.toReal_mono (measure_ne_top _ _)
  apply measure_mono_ae
  filter_upwards [iid_domain_ae D X hDX] with sample hsX
  intro hs
  have htrainSet := (isOpen_trainingEvent (N := N) (r := r) hcφ f ρ sample).measurableSet
  have hden : 0 < μ.real (trainingEvent φ f ρ sample) :=
    hpos.trans_le (measureReal_mono (uniformTube_subset_training φ f X ρ sample hsX))
  have hden0 : μ (trainingEvent φ f ρ sample) ≠ 0 := by
    intro he
    simp only [Measure.real,he,ENNReal.toReal_zero] at hden
    exact hden.false
  let Q := posterior φ μ f ρ sample
  letI : IsProbabilityMeasure Q := cond_isProbabilityMeasure hden0
  have hQtail : Q.real {w | (K : ℝ) < weightedSquaredNorm w} ≤ β := by
    apply (RobustPosterior.cond_real_le_ratio μ _ _ htrainSet).trans
    apply le_trans _ htail
    exact div_le_div_of_nonneg_left measureReal_nonneg hpos
      (measureReal_mono (uniformTube_subset_training φ f X ρ sample hsX))
  have htrain : ∀ᵐ w ∂Q, w ∈ trainingEvent φ f ρ sample := ae_cond_mem htrainSet
  have hr := energy_cover_posterior_risk hd hN hK hR D Q φ hφ hcφ f hf.measurable
    X hX hball hDX sample hsX hu hgap hs hQtail htrain
  have hc := confidenceFailure_le_three_risk hcφ D Q hf.measurable τ
  exact ⟨hr,by linarith⟩

end NeuralGeneralization.BatchTwoContinuous
