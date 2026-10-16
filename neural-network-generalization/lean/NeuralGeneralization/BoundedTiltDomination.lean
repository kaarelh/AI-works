import NeuralGeneralization.BoundedTilt

/-! # Quantitative domination by the reference law for bounded tilts
The exponential density loss is exp(2G); a Gaussian tail threshold therefore
needs squared size only proportional to G, as in the finite-realization proof.
-/
noncomputable section
open MeasureTheory Real
open scoped ENNReal
namespace NeuralGeneralization.BoundedTilt
variable {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]

theorem density_le_exp_two_mul (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) (x : Ω) :
    density μ V x ≤ Real.exp (2 * G) := by
  apply (div_le_iff₀ (partition_pos μ V hV hbound)).2
  calc
    Real.exp (V x) ≤ Real.exp G :=
      Real.exp_le_exp.mpr ((le_abs_self _).trans (hbound x))
    _ = Real.exp (2 * G) * Real.exp (-G) := by rw [← Real.exp_add]; congr 1; ring
    _ ≤ Real.exp (2 * G) * partition μ V :=
      mul_le_mul_of_nonneg_left (exp_neg_le_partition μ V hV hbound) (Real.exp_pos _).le

/-- The comparison holds even for a nonmeasurable set, using outer measures. -/
theorem tilted_measure_le (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) (s : Set Ω) :
    (μ.tilted V) s ≤ ENNReal.ofReal (Real.exp (2 * G)) * μ s := by
  rw [tilted_apply]
  calc
    (∫⁻ x in s, ENNReal.ofReal (Real.exp (V x) / ∫ y, Real.exp (V y) ∂μ) ∂μ) ≤
        ∫⁻ _x in s, ENNReal.ofReal (Real.exp (2 * G)) ∂μ := by
      apply lintegral_mono
      intro x
      exact ENNReal.ofReal_le_ofReal (density_le_exp_two_mul μ V hV hbound x)
    _ = ENNReal.ofReal (Real.exp (2 * G)) * μ s := by simp

theorem tilted_measureReal_le (V : Ω → ℝ) (hV : Measurable V)
    {G : ℝ} (hbound : ∀ x, |V x| ≤ G) (s : Set Ω) :
    (μ.tilted V).real s ≤ Real.exp (2 * G) * μ.real s := by
  have htop : ENNReal.ofReal (Real.exp (2 * G)) * μ s ≠ ⊤ :=
    ENNReal.mul_ne_top ENNReal.ofReal_ne_top (measure_ne_top _ _)
  have h := ENNReal.toReal_mono htop (tilted_measure_le μ V hV hbound s)
  simpa only [ENNReal.toReal_mul, ENNReal.toReal_ofReal (Real.exp_pos _).le, Measure.real] using h

end NeuralGeneralization.BoundedTilt
end
