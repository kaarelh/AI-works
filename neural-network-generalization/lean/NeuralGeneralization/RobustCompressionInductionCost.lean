import NeuralGeneralization.RobustCompressionGluing
import Mathlib.MeasureTheory.Integral.Lebesgue.Map

/-! # Exact accumulation of error along canonical-history couplings

A layer comparison is coupled to its own canonical state law. Gluing carries
that comparison into the complete previous history. The expected local error
is unchanged, and the total error is the sum of local errors rather than a
product of matrix norms.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustCompressionInduction
open RobustCompression

variable {U V W : Type*} [MeasurableSpace U] [MeasurableSpace V]
  [MeasurableSpace W] [StandardBorelSpace W] [Nonempty W]

theorem lintegral_glue_old (P : Measure (U × V)) (R : Measure (V × W))
    [IsProbabilityMeasure P] [IsProbabilityMeasure R]
    (F : U × V → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ z, F z.1 ∂glue P R) = ∫⁻ z, F z ∂P := by
  have h := lintegral_map hF measurable_fst (μ := glue P R)
  have he : (glue P R).map Prod.fst = P := glue_old P R
  rw [he] at h
  exact h.symm

theorem lintegral_glue_new (P : Measure (U × V)) (R : Measure (V × W))
    [IsProbabilityMeasure P] [IsProbabilityMeasure R]
    (hshared : P.snd = R.fst) (G : V × W → ℝ≥0∞) (hG : Measurable G) :
    (∫⁻ z, G (z.1.2,z.2) ∂glue P R) = ∫⁻ z, G z ∂R := by
  have hm : Measurable (fun z : (U × V) × W => (z.1.2,z.2)) := by fun_prop
  have h := lintegral_map hG hm (μ := glue P R)
  rw [glue_new P R hshared] at h
  exact h.symm

/-- Exact preservation of every local expected cost under gluing. In
particular, local squared RMS errors may be added without independence. -/
theorem lintegral_glue_cost (P : Measure (U × V)) (R : Measure (V × W))
    [IsProbabilityMeasure P] [IsProbabilityMeasure R]
    (hshared : P.snd = R.fst)
    (F : U × V → ℝ≥0∞) (G : V × W → ℝ≥0∞)
    (hF : Measurable F) (hG : Measurable G) :
    (∫⁻ z, F z.1 + G (z.1.2,z.2) ∂glue P R) =
      (∫⁻ z, F z ∂P) + ∫⁻ z, G z ∂R := by
  have hFm : Measurable (fun z : (U × V) × W => F z.1) := hF.comp measurable_fst
  rw [lintegral_add_left hFm,
    lintegral_glue_old P R F hF, lintegral_glue_new P R hshared G hG]

theorem lintegral_glue_cost_le (P : Measure (U × V)) (R : Measure (V × W))
    [IsProbabilityMeasure P] [IsProbabilityMeasure R]
    (hshared : P.snd = R.fst)
    (F : U × V → ℝ≥0∞) (G : V × W → ℝ≥0∞)
    (hF : Measurable F) (hG : Measurable G) {a b : ℝ≥0∞}
    (hOld : (∫⁻ z, F z ∂P) ≤ a) (hNew : (∫⁻ z, G z ∂R) ≤ b) :
    (∫⁻ z, F z.1 + G (z.1.2,z.2) ∂glue P R) ≤ a+b := by
  rw [lintegral_glue_cost P R hshared F G hF hG]
  exact add_le_add hOld hNew

end NeuralGeneralization.RobustCompressionInduction
