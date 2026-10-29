import NeuralGeneralization.BoundedTilt
import Mathlib.InformationTheory.KullbackLeibler.Basic

noncomputable section
open MeasureTheory InformationTheory
open scoped ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BoundedTilt

variable {Ω : Type*} [MeasurableSpace Ω]

/-- Bounded exponential tilts have finite actual Mathlib KL divergence. -/
theorem boundedTilt_klDiv_ne_top (μ : Measure Ω) [IsProbabilityMeasure μ]
    (V : Ω → ℝ) (hV : Measurable V) {G : ℝ} (hbound : ∀ x, |V x|≤G) :
    klDiv (μ.tilted V) μ ≠ ∞ :=
  klDiv_ne_top (tilted_absolutelyContinuous μ V)
    (integrable_log_rnDeriv_tilted μ V hV hbound)

/-- Identifies the previously proved log-density entropy with Mathlib's
actual Kullback-Leibler divergence, including normalization and integrability. -/
theorem boundedTilt_klDiv_eq (μ : Measure Ω) [IsProbabilityMeasure μ]
    (V : Ω → ℝ) (hV : Measurable V) {G : ℝ} (hbound : ∀ x, |V x|≤G) :
    klDiv (μ.tilted V) μ = ENNReal.ofReal
      (∫ x, Real.log (density μ V x) ∂μ.tilted V) := by
  letI := tilted_probability μ V hV hbound
  rw [klDiv_of_ac_of_integrable (tilted_absolutelyContinuous μ V)
    (integrable_log_rnDeriv_tilted μ V hV hbound)]
  simp only [probReal_univ,add_sub_cancel_right]
  congr 1
  exact (entropy_eq_integral_log_rnDeriv μ V hV hbound).symm

theorem boundedTilt_toReal_klDiv_eq (μ : Measure Ω) [IsProbabilityMeasure μ]
    (V : Ω → ℝ) (hV : Measurable V) {G : ℝ} (hbound : ∀ x, |V x|≤G) :
    (klDiv (μ.tilted V) μ).toReal =
      (∫ x, V x ∂μ.tilted V)-Real.log (partition μ V) := by
  rw [boundedTilt_klDiv_eq μ V hV hbound,
    ENNReal.toReal_ofReal (tilted_entropy_nonneg μ V hV hbound)]
  exact tilted_entropy_identity μ V hV hbound

#print axioms boundedTilt_toReal_klDiv_eq
end ConditionalNonpolynomial.Analytic
