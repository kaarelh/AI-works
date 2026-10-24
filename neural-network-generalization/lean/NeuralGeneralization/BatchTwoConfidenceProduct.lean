import Mathlib.MeasureTheory.Measure.Prod
import Mathlib.MeasureTheory.Measure.Real
import Mathlib.MeasureTheory.Integral.Lebesgue.Markov
import Mathlib.Probability.ConditionalProbability
import Mathlib.Tactic.Linarith

/-! Posterior confidence from average risk, including arbitrary mixtures and
continuous input distributions. The error event is an actual measurable subset
of the product of inputs and parameters. -/

noncomputable section
open MeasureTheory ProbabilityTheory

namespace NeuralGeneralization.BatchTwoConfidenceProduct

variable {X W : Type*} [MeasurableSpace X] [MeasurableSpace W]

theorem confidence_bound (D : Measure X) (Q : Measure W)
    [IsProbabilityMeasure D] [IsProbabilityMeasure Q]
    (E : Set (X × W)) (hE : MeasurableSet E) {θ : ℝ} (hθ : θ < 1) :
    (1 - θ) * D.real {x | Q.real (Prod.mk x ⁻¹' E)ᶜ ≤ θ} ≤
      (D.prod Q).real E := by
  have hm := measurable_measure_prodMk_left (ν := Q) hE
  have hevent : {x | Q.real (Prod.mk x ⁻¹' E)ᶜ ≤ θ} =
      {x | ENNReal.ofReal (1 - θ) ≤ Q (Prod.mk x ⁻¹' E)} := by
    ext x
    rw [Set.mem_setOf_eq, Set.mem_setOf_eq,
      ENNReal.ofReal_le_iff_le_toReal (measure_ne_top Q _)]
    rw [probReal_compl_eq_one_sub (measurable_prodMk_left hE)]
    change 1 - Q.real (Prod.mk x ⁻¹' E) ≤ θ ↔ 1 - θ ≤ Q.real (Prod.mk x ⁻¹' E)
    constructor <;> intro h <;> linarith
  have hmarkov := mul_meas_ge_le_lintegral (μ := D) hm (ENNReal.ofReal (1 - θ))
  rw [← Measure.prod_apply hE] at hmarkov
  have hreal := ENNReal.toReal_mono (measure_ne_top (D.prod Q) E) hmarkov
  rw [ENNReal.toReal_mul,
    ENNReal.toReal_ofReal (by linarith : 0 ≤ 1 - θ)] at hreal
  rw [hevent]
  exact hreal

theorem two_thirds_confidence_bound (D : Measure X) (Q : Measure W)
    [IsProbabilityMeasure D] [IsProbabilityMeasure Q]
    (E : Set (X × W)) (hE : MeasurableSet E) :
    D.real {x | Q.real (Prod.mk x ⁻¹' E)ᶜ ≤ (2 : ℝ) / 3} ≤
      3 * (D.prod Q).real E := by
  have h := confidence_bound D Q E hE (θ := (2 : ℝ) / 3) (by norm_num)
  linarith

end NeuralGeneralization.BatchTwoConfidenceProduct
