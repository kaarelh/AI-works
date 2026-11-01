import NeuralGeneralization.BatchTwoContinuousClassification
import Mathlib.MeasureTheory.Measure.Prod

/-! Measurability of the literal posterior-risk and confidence success events,
including samples on which the conditioning event has zero prior mass. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoContinuous.Classification
open ConcreteModel

theorem measurable_sample_test_mass {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (label : RealInput d→Bool) (hl : Measurable label)
    (B : Set (RealInput d × Weights d N r)) (hB : MeasurableSet B) :
    Measurable (fun p : (Fin n→RealInput d) × RealInput d =>
      posterior φ μ label p.1 {w | (p.2,w)∈B}) := by
  let S := Fin n→RealInput d
  let W := Weights d N r
  let T : Set ((S × RealInput d) × W) := {p | ∀ i,
    (1/2:ℝ)<labelReal (label (p.1.1 i))*output φ p.2 (p.1.1 i)}
  have hT : MeasurableSet T := by
    simp only [T,Set.setOf_forall]
    apply MeasurableSet.iInter
    intro i
    have hx : Measurable (fun p : (S × RealInput d) × W => p.1.1 i) :=
      (measurable_pi_apply i).comp (measurable_fst.comp measurable_fst)
    exact measurableSet_lt measurable_const
      (((measurable_of_finite labelReal).comp (hl.comp hx)).mul
        ((continuous_output_joint hφ).measurable.comp (measurable_snd.prodMk hx)))
  let C : Set ((S × RealInput d) × W) := {p | (p.1.2,p.2)∈B}
  have hC : MeasurableSet C := hB.preimage
    ((measurable_snd.comp measurable_fst).prodMk measurable_snd)
  have hnum := measurable_measure_prodMk_left_finite (ν:=μ) (hT.inter hC)
  have hden := measurable_measure_prodMk_left_finite (ν:=μ) hT
  have heq (p : S × RealInput d) : posterior φ μ label p.1 {w | (p.2,w)∈B}=
      (μ {w | (p,w)∈T})⁻¹ * μ {w | (p,w)∈T∩C} := by
    rw [posterior,cond_apply (isOpen_trainingEvent hφ label p.1).measurableSet]
    rfl
  simp_rw [heq]
  exact hden.inv.mul hnum

theorem measurable_sample_risk {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (D : Measure (RealInput d)) [IsFiniteMeasure D]
    (label : RealInput d→Bool) (hl : Measurable label) :
    Measurable (fun s : Fin n→RealInput d => risk φ D (posterior φ μ label s) label) := by
  have hm := measurable_sample_test_mass (n:=n) hφ μ label hl
    (errorEvent φ label) (measurable_errorEvent hφ hl)
  have hi := (hm.lintegral_prod_right' (ν:=D)).ennreal_toReal
  have heq (s : Fin n→RealInput d) : risk φ D (posterior φ μ label s) label=
      (∫⁻ x,posterior φ μ label s {w | (x,w)∈errorEvent φ label} ∂D).toReal := by
    letI : IsZeroOrProbabilityMeasure (posterior φ μ label s) := by unfold posterior; infer_instance
    unfold risk Measure.real
    rw [Measure.prod_apply (measurable_errorEvent hφ hl)]
    rfl
  simpa only [heq] using hi

theorem measurable_sample_correct_probability {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (label : RealInput d→Bool) (hl : Measurable label) :
    Measurable (fun p : (Fin n→RealInput d) × RealInput d =>
      (posterior φ μ label p.1).real {w | 0<labelReal (label p.2)*output φ w p.2}) := by
  have hm := (measurable_sample_test_mass (n:=n) hφ μ label hl
    (errorEvent φ label)ᶜ (measurable_errorEvent hφ hl).compl).ennreal_toReal
  simpa only [Measure.real,errorEvent,Set.mem_compl_iff,
    Set.mem_setOf_eq,not_le] using hm

theorem measurable_sample_confidence_failure {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (D : Measure (RealInput d)) [IsFiniteMeasure D]
    (label : RealInput d→Bool) (hl : Measurable label) :
    Measurable (fun s : Fin n→RealInput d =>
      confidenceFailure φ D (posterior φ μ label s) label) := by
  have hm := measurableSet_le (measurable_sample_correct_probability (n:=n) hφ μ label hl)
    (measurable_const (a:=(2/3:ℝ)))
  exact (measurable_measure_prodMk_left_finite (ν:=D) hm).ennreal_toReal

/-- The exact joint event appearing in both continuous-domain learning
statements is measurable, not merely bounded using a measurable subset. -/
theorem measurable_classification_success {d N r n : ℕ}
    {φ : ℝ→ℝ} (hφ : Continuous φ)
    (μ : Measure (Weights d N r)) [IsFiniteMeasure μ]
    (D : Measure (RealInput d)) [IsFiniteMeasure D]
    (label : RealInput d→Bool) (hl : Measurable label) (a b : ℝ) :
    MeasurableSet {s : Fin n→RealInput d |
      risk φ D (posterior φ μ label s) label≤a ∧
      confidenceFailure φ D (posterior φ μ label s) label≤b} :=
  (measurableSet_le (measurable_sample_risk hφ μ D label hl) measurable_const).inter
    (measurableSet_le (measurable_sample_confidence_failure hφ μ D label hl) measurable_const)

#print axioms measurable_classification_success
end NeuralGeneralization.BatchTwoContinuous.Classification
