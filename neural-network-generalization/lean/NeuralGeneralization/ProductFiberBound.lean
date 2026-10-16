import Mathlib.MeasureTheory.Integral.Prod

noncomputable section
open MeasureTheory
namespace NeuralGeneralization.ProductFiberBound
variable {Ω Ξ : Type*} [MeasurableSpace Ω] [MeasurableSpace Ξ]

theorem real_prod_le (μ : Measure Ω) (ν : Measure Ξ)
    [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (E : Set (Ω × Ξ)) (hE : MeasurableSet E) {C : ℝ} (hC : 0 ≤ C)
    (h : ∀ x, ν.real (Prod.mk x ⁻¹' E) ≤ C) : (μ.prod ν).real E ≤ C := by
  have hbound : (μ.prod ν) E ≤ ENNReal.ofReal C := by
    rw [Measure.prod_apply hE]
    calc
      _ ≤ ∫⁻ _x, ENNReal.ofReal C ∂μ := lintegral_mono (fun x => by
        exact (ENNReal.le_ofReal_iff_toReal_le (measure_ne_top ν _) hC).mpr (h x))
      _ = _ := by simp
  exact (ENNReal.toReal_mono ENNReal.ofReal_ne_top hbound).trans_eq (ENNReal.toReal_ofReal hC)

end NeuralGeneralization.ProductFiberBound
end
