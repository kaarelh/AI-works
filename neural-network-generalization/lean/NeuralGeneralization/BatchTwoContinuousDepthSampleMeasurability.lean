import NeuralGeneralization.BatchTwoContinuousDepthStrongConcentration
import Mathlib.MeasureTheory.Integral.Lebesgue.Add

/-! Sample measurability and passage from almost-everywhere eventual posterior
failure to the literal lower limit of sample probabilities. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators Topology ENNReal
open MeasureTheory ProbabilityTheory Filter
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

theorem measurable_sample_correctProbability {d N r n : ℕ}
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : RealInput d → ℝ) (hf : Continuous f) (ρ τ : ℝ) :
    Measurable (fun p : (Fin n → RealInput d) × RealInput d =>
      correctProbability Real.tanh (BatchTwoContinuous.posterior Real.tanh μ f ρ p.1) f τ p.2) := by
  let S := Fin n → RealInput d
  let W := Weights d N r
  let T : Set ((S × RealInput d) × W) := {p | ∀ i,
      |output Real.tanh p.2 (p.1.1 i)-f (p.1.1 i)|<ρ}
  have hT : MeasurableSet T := by
    simp only [T,Set.setOf_forall]
    apply MeasurableSet.iInter
    intro i
    have hx : Continuous (fun p : (S × RealInput d) × W => p.1.1 i) :=
      (continuous_apply i).comp (continuous_fst.comp continuous_fst)
    exact (isOpen_lt (((continuous_output_joint tanh_lipschitzWith.continuous).comp
      (continuous_snd.prodMk hx)).sub (hf.comp hx)).abs continuous_const).measurableSet
  let C : Set ((S × RealInput d) × W) := {p | |output Real.tanh p.2 p.1.2-f p.1.2|≤τ}
  have hC : MeasurableSet C := by
    have hx : Continuous (fun p : (S × RealInput d) × W => p.1.2) :=
      continuous_snd.comp continuous_fst
    exact measurableSet_le ((((continuous_output_joint tanh_lipschitzWith.continuous).comp
      (continuous_snd.prodMk hx)).sub (hf.comp hx)).abs.measurable) measurable_const
  have hnum := (measurable_measure_prodMk_left_finite (ν := μ) (hT.inter hC)).ennreal_toReal
  have hden := (measurable_measure_prodMk_left_finite (ν := μ) hT).ennreal_toReal
  have heq (p : S × RealInput d) :
      correctProbability Real.tanh (BatchTwoContinuous.posterior Real.tanh μ f ρ p.1) f τ p.2 =
      (μ {w | (p,w)∈T∩C}).toReal/(μ {w | (p,w)∈T}).toReal := by
    unfold correctProbability BatchTwoContinuous.posterior
    rw [RobustPosterior.cond_real_eq_ratio μ _ _
      (isOpen_trainingEvent tanh_lipschitzWith.continuous f ρ p.1).measurableSet]
    rfl
  simp_rw [heq]
  exact hnum.div hden

theorem measurable_sample_confidenceFailure {d N r n : ℕ}
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (D : Measure (RealInput d)) [IsFiniteMeasure D]
    (f : RealInput d → ℝ) (hf : Continuous f) (ρ τ : ℝ) :
    Measurable (fun s : Fin n → RealInput d =>
      BatchTwoContinuous.confidenceFailure Real.tanh D
        (BatchTwoContinuous.posterior Real.tanh μ f ρ s) f τ) := by
  have hm : MeasurableSet {p : (Fin n → RealInput d) × RealInput d |
      correctProbability Real.tanh (BatchTwoContinuous.posterior Real.tanh μ f ρ p.1) f τ p.2 ≤ (2/3 : ℝ)} :=
    measurableSet_le (measurable_sample_correctProbability μ f hf ρ τ) measurable_const
  exact (measurable_measure_prodMk_left_finite (ν := D) hm).ennreal_toReal

/-- Fatou for moving measurable events, at an arbitrary countably generated
nontrivial filter. This allows the small-prior threshold to depend on the sample. -/
theorem measure_event_le_liminf {X I : Type*} [MeasurableSpace X]
    (μ : Measure X) {l : Filter I} [NeBot l] [IsCountablyGenerated l]
    (E : Set X) (hE : MeasurableSet E) (A : I → Set X) (hA : ∀ i, MeasurableSet (A i))
    (hgood : ∀ᵐ x ∂μ, x∈E → ∀ᶠ i in l, x∈A i) :
    μ E ≤ liminf (fun i => μ (A i)) l := by
  classical
  let F : I → X → ℝ≥0∞ := fun i => (A i).indicator (fun _ => 1)
  have hF (i : I) : Measurable (F i) := measurable_const.indicator (hA i)
  have hpoint : ∀ᵐ x ∂μ, E.indicator (fun _ => (1 : ℝ≥0∞)) x ≤ liminf (fun i => F i x) l := by
    filter_upwards [hgood] with x hx
    by_cases he : x∈E
    · have heq : (fun i => F i x)=ᶠ[l] (fun _ => (1 : ℝ≥0∞)) := by
        filter_upwards [hx he] with i hi
        simp [F,hi]
      rw [liminf_congr heq]
      simp [he]
    · simp only [Set.indicator_of_notMem he]
      exact bot_le
  calc
    μ E = ∫⁻ x,E.indicator (fun _ => (1 : ℝ≥0∞)) x ∂μ := by simp [hE]
    _ ≤ ∫⁻ x,liminf (fun i => F i x) l ∂μ := lintegral_mono_ae hpoint
    _ ≤ liminf (fun i => ∫⁻ x,F i x ∂μ) l := lintegral_liminf_le hF
    _ = liminf (fun i => μ (A i)) l := by simp [F,hA]

end NeuralGeneralization.BatchTwoContinuousDepthLower
