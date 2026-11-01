import NeuralGeneralization.BatchTwoContinuousClassification

noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuous.Classification
open ConcreteModel CompressionSampling BatchTwoSurvivalStatistics

theorem learning_of_cover {d N r : ℕ} {H : Type*} [Fintype H] [Nonempty H]
    (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ]
    (φ : ℝ → ℝ) (hcφ : Continuous φ) (f : RealInput d → ℝ) (hf : Continuous f)
    (X : Set (RealInput d)) (label : RealInput d→Bool) (hl : Measurable label)
    (g : H → RealInput d → ℝ) (hg : ∀ h, Measurable (g h))
    (G : Set (Weights d N r)) (hG : MeasurableSet G)
    {a ρ u β E : ℝ} (hu : 0 ≤ u) (hgap : 2*a ≤ 1/2)
    (hm : ∀ x∈X, 1/2+ρ≤labelReal (label x)*f x)
    (hcover : ∀ w ∈ G, ∃ h, ∀ x ∈ X, |output φ w x-g h x| ≤ a)
    (hcard : (Fintype.card H : ℝ) ≤ Real.exp E)
    (hpos : 0 < μ.real (uniformTube φ f X ρ))
    (htail : μ.real Gᶜ/μ.real (uniformTube φ f X ρ) ≤ β)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D] (hDX : D Xᶜ=0)
    {δ : ℝ} (hδ : 0 < δ) (n : ℕ)
    (hsize : E+Real.log (1/δ) ≤ (n : ℝ)*u) :
    1-δ ≤ (iidSamples D n).real {s |
      risk φ D (posterior φ μ label s) label ≤ u+β ∧
      confidenceFailure φ D (posterior φ μ label s) label ≤ 3*(u+β)} := by
  classical
  let A := comparison label g a
  have hA : ∀ h, MeasurableSet (A h) := measurable_comparison hl g hg _
  have hprob := goodSamples_probability_log D A hA n hδ hcard hsize
  apply hprob.trans
  apply ENNReal.toReal_mono (measure_ne_top _ _)
  apply measure_mono_ae
  filter_upwards [iid_domain_ae D X hDX] with sample hsX
  intro hs
  have htrainSet := (isOpen_trainingEvent (N := N) (r := r) hcφ label sample).measurableSet
  have hden : 0 < μ.real (trainingEvent φ label sample) :=
    hpos.trans_le (measureReal_mono (uniformTube_subset_training φ f label X ρ hm sample hsX))
  have hden0 : μ (trainingEvent φ label sample) ≠ 0 := by
    intro he
    simp only [Measure.real,he,ENNReal.toReal_zero] at hden
    exact hden.false
  let Q := posterior φ μ label sample
  letI : IsProbabilityMeasure Q := cond_isProbabilityMeasure hden0
  have hQtail : Q.real Gᶜ ≤ β := by
    apply (RobustPosterior.cond_real_le_ratio μ _ _ htrainSet).trans
    apply le_trans _ htail
    exact div_le_div_of_nonneg_left measureReal_nonneg hpos
      (measureReal_mono (uniformTube_subset_training φ f label X ρ hm sample hsX))
  have htrain : ∀ᵐ w ∂Q, w ∈ trainingEvent φ label sample := ae_cond_mem htrainSet
  have hr := cover_posterior_risk D Q φ hcφ label hl g X hDX sample hsX
    hu hgap hs Gᶜ hG.compl hQtail (by
      filter_upwards [htrain] with w hw
      exact ⟨hw,fun hn => hcover w (by simpa using hn)⟩)
  have hc := confidence_le_three_risk hcφ D Q hl
  exact ⟨hr,by linarith⟩


theorem learning_of_tail {d N r K R : ℕ}
    (hd : 1≤d) (hN : 0<N) (hK : 1≤K) (hR : 1≤R)
    (μ : Measure (Weights d N r)) [IsProbabilityMeasure μ]
    (φ : ℝ→ℝ) (hφ : admissibleActivation φ) (hcφ : Continuous φ)
    (f : RealInput d→ℝ) (hf : Continuous f)
    (X : Set (RealInput d)) (hX : X.Nonempty) (hcompact : IsCompact X)
    (hball : ∀ x∈X, ∑ j,x j^2≤1)
    (label : RealInput d→Bool) (hl : Measurable label)
    {ρ u β : ℝ} (hu : 0≤u) (hgap : 2*(1/(3*(R:ℝ)))≤1/2)
    (hm : ∀ x∈X,1/2+ρ≤labelReal (label x)*f x)
    (hpos : 0<μ.real (uniformTube φ f X ρ))
    (htail : μ.real {w | (K:ℝ)<weightedSquaredNorm w}/μ.real (uniformTube φ f X ρ)≤β)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D] (hDX : D Xᶜ=0)
    {δ : ℝ} (hδ : 0<δ) (n : ℕ)
    (hsize : (coverEntropy d r K R:ℝ)+Real.log (1/δ)≤(n:ℝ)*u) :
    1-δ≤(iidSamples D n).real {s |
      risk φ D (posterior φ μ label s) label≤u+β ∧
      confidenceFailure φ D (posterior φ μ label s) label≤3*(u+β)} := by
  classical
  letI : Nonempty (UniformCoverCode d r K R) := ⟨fun _ => ⟨0,by simp⟩⟩
  have hE : IsClosed {w : Weights d N r | weightedSquaredNorm w≤(K:ℝ)} := by
    apply isClosed_le _ continuous_const
    unfold weightedSquaredNorm
    fun_prop
  apply learning_of_cover μ φ hcφ f hf X label hl (uniformCoverOutput d r K R φ)
    (fun h => (continuous_output_input hcφ _).measurable) _ hE.measurableSet hu hgap hm
    (fun w hw => exists_uniform_cover hd hN hK hR φ hφ w hw X hX hball)
    (uniformCoverCode_card_le_exp d r K R) hpos _ D hDX hδ n hsize
  simpa only [Set.compl_setOf,not_le] using htail

end NeuralGeneralization.BatchTwoContinuous.Classification
