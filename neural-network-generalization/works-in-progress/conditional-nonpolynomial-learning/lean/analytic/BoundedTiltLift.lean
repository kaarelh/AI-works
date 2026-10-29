import BoundedTiltKL
import NeuralGeneralization.RobustEntropyChain

noncomputable section
open MeasureTheory InformationTheory
open scoped ENNReal
namespace ConditionalAnalytic
open NeuralGeneralization.BoundedTilt
open ConditionalNonpolynomial.Analytic

variable {Ω X : Type*} [MeasurableSpace Ω] [MeasurableSpace X]

/-- Tilting by a statistic commutes exactly with pushing forward by that
statistic, even for singular or non-injective statistics. -/
theorem map_tilted_pullback (μ : Measure Ω) (F : Ω → X) (hF : Measurable F)
    (V : X → ℝ) (hV : Measurable V) :
    (μ.tilted (V ∘ F)).map F = (μ.map F).tilted V := by
  have hZ : (∫ x, Real.exp (V x) ∂μ.map F) =
      ∫ x, Real.exp (V (F x)) ∂μ :=
    integral_map hF.aemeasurable (Real.measurable_exp.comp hV).aestronglyMeasurable
  ext E hE
  rw [Measure.map_apply hF hE, tilted_apply' _ _ (hF hE),
    tilted_apply' _ _ hE, setLIntegral_map hE (by fun_prop) hF, hZ]
  rfl

/-- A bounded tilt lifted to common Gaussian coordinates has exactly the same
KL cost; this is an equality, not just the data-processing upper bound. -/
theorem klDiv_tilted_pullback (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : Ω → X) (hF : Measurable F) (V : X → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) :
    (klDiv (μ.tilted (V ∘ F)) μ).toReal =
      (klDiv ((μ.map F).tilted V) (μ.map F)).toReal := by
  letI : IsProbabilityMeasure (μ.map F) := Measure.isProbabilityMeasure_map hF.aemeasurable
  rw [boundedTilt_toReal_klDiv_eq μ (V ∘ F) (hV.comp hF) (fun x => hbound (F x)),
    boundedTilt_toReal_klDiv_eq (μ.map F) V hV hbound]
  congr 1
  · rw [← map_tilted_pullback μ F hF V hV,
      integral_map hF.aemeasurable hV.aestronglyMeasurable]
    rfl
  · unfold partition
    congr 1
    exact (integral_map hF.aemeasurable (show AEStronglyMeasurable (fun x => Real.exp (V x)) (μ.map F) from
      (Real.measurable_exp.comp hV).aestronglyMeasurable)).symm

#print axioms map_tilted_pullback
#print axioms klDiv_tilted_pullback
end ConditionalAnalytic
