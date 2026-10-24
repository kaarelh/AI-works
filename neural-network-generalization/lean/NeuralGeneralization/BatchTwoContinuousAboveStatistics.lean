import NeuralGeneralization.BatchTwoContinuousLearning
import NeuralGeneralization.BatchTwoContinuousFiniteSpectralTail

/-! Continuous regression under any actual measurable uniform-cover event.
This permits the large-width spectral cover and the bounded-width energy cover
to use the same posterior generalization argument. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel CompressionSampling BatchTwoSurvivalStatistics

theorem regression_learning_of_cover {d N r : ℕ} {H : Type*} [Fintype H] [Nonempty H]
    (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ]
    (φ : ℝ → ℝ) (hcφ : Continuous φ) (f : RealInput d → ℝ) (hf : Continuous f)
    (X : Set (RealInput d))
    (g : H → RealInput d → ℝ) (hg : ∀ h, Measurable (g h))
    (G : Set (Weights d N r)) (hG : MeasurableSet G)
    {a ρ τ u β E : ℝ} (hu : 0 ≤ u) (hgap : ρ+2*a ≤ τ)
    (hcover : ∀ w ∈ G, ∃ h, ∀ x ∈ X, |output φ w x-g h x| ≤ a)
    (hcard : (Fintype.card H : ℝ) ≤ Real.exp E)
    (hpos : 0 < μ.real (uniformTube φ f X ρ))
    (htail : μ.real Gᶜ/μ.real (uniformTube φ f X ρ) ≤ β)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D] (hDX : D Xᶜ=0)
    {δ : ℝ} (hδ : 0 < δ) (n : ℕ)
    (hsize : E+Real.log (1/δ) ≤ (n : ℝ)*u) :
    1-δ ≤ (iidSamples D n).real {s |
      risk φ D (posterior φ μ f ρ s) f τ ≤ u+β ∧
      confidenceFailure φ D (posterior φ μ f ρ s) f τ ≤ 3*(u+β)} := by
  classical
  let A := regressionComparison f g ρ a
  have hA : ∀ h, MeasurableSet (A h) := measurable_regressionComparison hf.measurable g hg _ _
  have hprob := goodSamples_probability_log D A hA n hδ hcard hsize
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
  have hQtail : Q.real Gᶜ ≤ β := by
    apply (RobustPosterior.cond_real_le_ratio μ _ _ htrainSet).trans
    apply le_trans _ htail
    exact div_le_div_of_nonneg_left measureReal_nonneg hpos
      (measureReal_mono (uniformTube_subset_training φ f X ρ sample hsX))
  have htrain : ∀ᵐ w ∂Q, w ∈ trainingEvent φ f ρ sample := ae_cond_mem htrainSet
  have hr := regression_cover_posterior_risk D Q φ hcφ f hf.measurable g X hDX sample hsX
    hu hgap hs Gᶜ hG.compl hQtail (by
      filter_upwards [htrain] with w hw
      exact ⟨hw,fun hn => hcover w (by simpa using hn)⟩)
  have hc := confidenceFailure_le_three_risk hcφ D Q hf.measurable τ
  exact ⟨hr,by linarith⟩

end NeuralGeneralization.BatchTwoContinuous
