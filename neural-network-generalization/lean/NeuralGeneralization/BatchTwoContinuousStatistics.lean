import NeuralGeneralization.BatchTwoContinuousCover
import NeuralGeneralization.BatchTwoSurvivalPosterior

/-! Exact finite-cover generalization for real-output interpolation. The final
risk averages over the full posterior; no posterior-mean substitution occurs. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel BatchTwoSurvivalStatistics

def regressionComparison {d : ℕ} {H : Type*} (f : RealInput d → ℝ)
    (g : H → RealInput d → ℝ) (ρ a : ℝ) (h : H) : Set (RealInput d) :=
  {x | ρ+a ≤ |g h x-f x|}

theorem measurable_regressionComparison {d : ℕ} {H : Type*} {f : RealInput d → ℝ}
    (hf : Measurable f) (g : H → RealInput d → ℝ) (hg : ∀ h, Measurable (g h))
    (ρ a : ℝ) (h : H) : MeasurableSet (regressionComparison f g ρ a h) :=
  measurableSet_le measurable_const (((hg h).sub hf).abs)

theorem regression_cover_posterior_risk {d N r n : ℕ} {H : Type*} [Fintype H]
    (D : Measure (RealInput d)) [IsProbabilityMeasure D]
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (φ : ℝ → ℝ) (hφ : Continuous φ) (f : RealInput d → ℝ) (hf : Measurable f)
    (g : H → RealInput d → ℝ) (X : Set (RealInput d)) (hDX : D Xᶜ=0)
    (sample : Fin n → RealInput d) (hsX : ∀ i, sample i ∈ X)
    {ρ τ a u β : ℝ} (hu : 0 ≤ u) (hgap : ρ+2*a ≤ τ)
    (hs : sample ∉ badSamples D (regressionComparison f g ρ a) n u)
    (E : Set (Weights d N r)) (hE : MeasurableSet E) (htail : Q.real E ≤ β)
    (hgood : ∀ᵐ w ∂Q, w ∈ trainingEvent φ f ρ sample ∧
      (w ∉ E → ∃ h, ∀ x ∈ X, |output φ w x-g h x| ≤ a)) :
    risk φ D Q f τ ≤ u+β := by
  apply finite_cover_posterior_error D Q (jointErrorEvent φ f τ)
    (measurable_jointErrorEvent hφ hf τ) (regressionComparison f g ρ a) sample hu hs E hE htail
  have haX : ∀ᵐ x ∂D, x ∈ X := by rw [ae_iff]; exact hDX
  filter_upwards [hgood] with w hw
  intro he
  obtain ⟨h,hc⟩ := hw.2 he
  refine ⟨h,?_,?_⟩
  · intro i
    change ¬ρ+a ≤ |g h (sample i)-f (sample i)|
    have ht := abs_sub_le (g h (sample i)) (output φ w (sample i)) (f (sample i))
    rw [abs_sub_comm (g h (sample i)) (output φ w (sample i))] at ht
    have htrain := hw.1 i
    have hcover := hc (sample i) (hsX i)
    linarith
  · apply ENNReal.toReal_mono (measure_ne_top _ _)
    apply measure_mono_ae
    filter_upwards [haX] with x hx
    intro herr
    change τ < |output φ w x-f x| at herr
    change ρ+a ≤ |g h x-f x|
    have ht := abs_sub_le (output φ w x) (g h x) (f x)
    linarith [hc x hx]

theorem energy_cover_posterior_risk {d N r K R n : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K) (hR : 1 ≤ R)
    (D : Measure (RealInput d)) [IsProbabilityMeasure D]
    (Q : Measure (Weights d N r)) [IsProbabilityMeasure Q]
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (hcφ : Continuous φ)
    (f : RealInput d → ℝ) (hf : Measurable f)
    (X : Set (RealInput d)) (hX : X.Nonempty) (hball : ∀ x ∈ X, ∑ j, x j^2 ≤ 1)
    (hDX : D Xᶜ=0) (sample : Fin n → RealInput d) (hsX : ∀ i, sample i ∈ X)
    {ρ τ u β : ℝ} (hu : 0 ≤ u) (hgap : ρ+2*(1/(3*(R : ℝ))) ≤ τ)
    (hs : sample ∉ badSamples D (regressionComparison f (uniformCoverOutput d r K R φ) ρ (1/(3*(R : ℝ)))) n u)
    (htail : Q.real {w | (K : ℝ) < weightedSquaredNorm w} ≤ β)
    (htrain : ∀ᵐ w ∂Q, w ∈ trainingEvent φ f ρ sample) : risk φ D Q f τ ≤ u+β := by
  have he : MeasurableSet {w : Weights d N r | (K : ℝ) < weightedSquaredNorm w} := by
    apply measurableSet_lt measurable_const
    unfold weightedSquaredNorm
    fun_prop
  apply regression_cover_posterior_risk D Q φ hcφ f hf _ X hDX sample hsX hu hgap hs _ he htail
  filter_upwards [htrain] with w hw
  refine ⟨hw,?_⟩
  intro hnot
  exact exists_uniform_cover hd hN hK hR φ hφ w (le_of_not_gt hnot) X hX hball

end NeuralGeneralization.BatchTwoContinuous
