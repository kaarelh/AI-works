import NeuralGeneralization.BatchTwoContinuousModel
import Mathlib.MeasureTheory.Measure.Prod

/-! Measurability of the literal posterior-risk and confidence success events,
including samples on which the conditioning event has zero prior mass. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoContinuous
open ConcreteModel

theorem measurable_sample_test_mass {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : RealInput d→ℝ) (hf : Measurable f) (ρ : ℝ)
    (B : Set (RealInput d × Weights d N r)) (hB : MeasurableSet B) :
    Measurable (fun p : (Fin n→RealInput d) × RealInput d =>
      posterior φ μ f ρ p.1 {w | (p.2,w)∈B}) := by
  let S := Fin n→RealInput d
  let W := Weights d N r
  let T : Set ((S × RealInput d) × W) := {p | ∀ i,
    |output φ p.2 (p.1.1 i)-f (p.1.1 i)|<ρ}
  have hT : MeasurableSet T := by
    simp only [T,Set.setOf_forall]
    apply MeasurableSet.iInter
    intro i
    have hx : Measurable (fun p : (S × RealInput d) × W => p.1.1 i) :=
      (measurable_pi_apply i).comp (measurable_fst.comp measurable_fst)
    exact measurableSet_lt (((continuous_output_joint hφ).measurable.comp
      (measurable_snd.prodMk hx)).sub (hf.comp hx)).abs measurable_const
  let C : Set ((S × RealInput d) × W) := {p | (p.1.2,p.2)∈B}
  have hC : MeasurableSet C := hB.preimage
    ((measurable_snd.comp measurable_fst).prodMk measurable_snd)
  have hnum := measurable_measure_prodMk_left_finite (ν:=μ) (hT.inter hC)
  have hden := measurable_measure_prodMk_left_finite (ν:=μ) hT
  have heq (p : S × RealInput d) : posterior φ μ f ρ p.1 {w | (p.2,w)∈B}=
      (μ {w | (p,w)∈T})⁻¹ * μ {w | (p,w)∈T∩C} := by
    rw [posterior,cond_apply (isOpen_trainingEvent hφ f ρ p.1).measurableSet]
    rfl
  simp_rw [heq]
  exact hden.inv.mul hnum

theorem measurable_sample_risk {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (D : Measure (RealInput d)) [IsFiniteMeasure D]
    (f : RealInput d→ℝ) (hf : Measurable f) (ρ τ : ℝ) :
    Measurable (fun s : Fin n→RealInput d => risk φ D (posterior φ μ f ρ s) f τ) := by
  have hm := measurable_sample_test_mass (n:=n) hφ μ f hf ρ
    (jointErrorEvent φ f τ) (measurable_jointErrorEvent hφ hf τ)
  have hi := (hm.lintegral_prod_right' (ν:=D)).ennreal_toReal
  have heq (s : Fin n→RealInput d) : risk φ D (posterior φ μ f ρ s) f τ=
      (∫⁻ x,posterior φ μ f ρ s {w | (x,w)∈jointErrorEvent φ f τ} ∂D).toReal := by
    letI : IsZeroOrProbabilityMeasure (posterior φ μ f ρ s) := by unfold posterior; infer_instance
    unfold risk Measure.real
    rw [Measure.prod_apply (measurable_jointErrorEvent hφ hf τ)]
    rfl
  simpa only [heq] using hi

theorem measurable_sample_correct_probability {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (f : RealInput d→ℝ) (hf : Measurable f) (ρ τ : ℝ) :
    Measurable (fun p : (Fin n→RealInput d) × RealInput d =>
      correctProbability φ (posterior φ μ f ρ p.1) f τ p.2) := by
  have hm := (measurable_sample_test_mass (n:=n) hφ μ f hf ρ
    (jointErrorEvent φ f τ)ᶜ (measurable_jointErrorEvent hφ hf τ).compl).ennreal_toReal
  simpa only [correctProbability,Measure.real,jointErrorEvent,Set.mem_compl_iff,
    Set.mem_setOf_eq,not_lt] using hm

theorem measurable_sample_confidence_failure {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (D : Measure (RealInput d)) [IsFiniteMeasure D]
    (f : RealInput d→ℝ) (hf : Measurable f) (ρ τ : ℝ) :
    Measurable (fun s : Fin n→RealInput d =>
      confidenceFailure φ D (posterior φ μ f ρ s) f τ) := by
  have hm := measurableSet_le (measurable_sample_correct_probability (n:=n) hφ μ f hf ρ τ)
    (measurable_const (a:=(2/3:ℝ)))
  exact (measurable_measure_prodMk_left_finite (ν:=D) hm).ennreal_toReal

/-- The exact joint event appearing in both continuous-domain learning
statements is measurable, not merely bounded using a measurable subset. -/
theorem measurable_regression_success {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (D : Measure (RealInput d)) [IsFiniteMeasure D]
    (f : RealInput d→ℝ) (hf : Measurable f) (ρ τ a b : ℝ) :
    MeasurableSet {s : Fin n→RealInput d |
      risk φ D (posterior φ μ f ρ s) f τ≤a ∧
      confidenceFailure φ D (posterior φ μ f ρ s) f τ≤b} :=
  (measurableSet_le (measurable_sample_risk hφ μ D f hf ρ τ) measurable_const).inter
    (measurableSet_le (measurable_sample_confidence_failure hφ μ D f hf ρ τ) measurable_const)

#print axioms measurable_regression_success
end NeuralGeneralization.BatchTwoContinuous
