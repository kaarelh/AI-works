import NeuralGeneralization.GaussianReadout
import Mathlib.Analysis.SpecialFunctions.Gaussian.GaussianIntegral
import Mathlib.MeasureTheory.Measure.WithDensity

/-! # Polar integration for the actual pair of independent standard Gaussians -/

noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped NNReal

namespace NeuralGeneralization.GaussianPolar

def standardPair : Measure (ℝ × ℝ) := (gaussianReal 0 1).prod (gaussianReal 0 1)

instance standardPair_probability : IsProbabilityMeasure standardPair := by
  unfold standardPair
  infer_instance

theorem pair_density (x y : ℝ) :
    gaussianPDFReal 0 1 x * gaussianPDFReal 0 1 y =
      (2 * Real.pi)⁻¹ * Real.exp (-(x ^ 2 + y ^ 2) / 2) := by
  simp only [gaussianPDFReal, NNReal.coe_one, mul_one, sub_zero]
  rw [mul_mul_mul_comm, ← Real.exp_add]
  have hsq : Real.sqrt (2 * Real.pi) ^ 2 = 2 * Real.pi :=
    Real.sq_sqrt (by positivity)
  rw [← mul_inv, ← pow_two, hsq]
  congr 1
  ring

theorem integral_standardPair (F : ℝ × ℝ → ℝ) :
    ∫ p, F p ∂standardPair =
      ∫ p : ℝ × ℝ, (2 * Real.pi)⁻¹ *
        Real.exp (-(p.1 ^ 2 + p.2 ^ 2) / 2) * F p := by
  have hm : Measurable (fun p : ℝ × ℝ => gaussianPDF 0 1 p.1 * gaussianPDF 0 1 p.2) :=
    ((measurable_gaussianPDF 0 1).comp measurable_fst).mul
      ((measurable_gaussianPDF 0 1).comp measurable_snd)
  have hfin : ∀ᵐ p : ℝ × ℝ ∂(volume : Measure (ℝ × ℝ)),
      gaussianPDF 0 1 p.1 * gaussianPDF 0 1 p.2 < ⊤ :=
    ae_of_all _ (fun p => ENNReal.mul_lt_top gaussianPDF_lt_top gaussianPDF_lt_top)
  unfold standardPair
  rw [gaussianReal_of_var_ne_zero 0 one_ne_zero,
    prod_withDensity (measurable_gaussianPDF 0 1) (measurable_gaussianPDF 0 1)]
  change (∫ p, F p ∂(volume : Measure (ℝ × ℝ)).withDensity
    (fun p => gaussianPDF 0 1 p.1 * gaussianPDF 0 1 p.2)) = _
  rw [integral_withDensity_eq_integral_toReal_smul hm hfin]
  apply integral_congr_ae
  filter_upwards [] with p
  rw [ENNReal.toReal_mul, toReal_gaussianPDF, toReal_gaussianPDF, pair_density]
  rfl

theorem radial_integral :
    ∫ r : ℝ in Ioi 0, r * Real.exp (-(r ^ 2) / 2) = 1 := by
  apply Complex.ofReal_injective
  rw [← integral_complex_ofReal]
  have h := integral_mul_cexp_neg_mul_sq (b := (1 / 2 : ℂ)) (by norm_num)
  convert h using 1
  · apply integral_congr_ae
    filter_upwards [] with r
    simp only [Complex.ofReal_mul, Complex.ofReal_exp, Complex.ofReal_div,
      Complex.ofReal_neg, Complex.ofReal_pow, Complex.ofReal_ofNat]
    congr 2
    ring
  · norm_num

/-- A degree-zero homogeneous observable is integrated by uniform angle.
The statement refers to the actual Gaussian product law. -/
theorem homogeneous_integral (F : ℝ × ℝ → ℝ) (f : ℝ → ℝ)
    (hF : ∀ r : ℝ, 0 < r → ∀ θ ∈ Ioo (-Real.pi) Real.pi,
      F (r * Real.cos θ, r * Real.sin θ) = f θ) :
    ∫ p, F p ∂standardPair =
      (2 * Real.pi)⁻¹ * ∫ θ in Ioo (-Real.pi) Real.pi, f θ := by
  rw [integral_standardPair, ← integral_comp_polarCoord_symm]
  have heq : (∫ p in polarCoord.target,
      p.1 • ((2 * Real.pi)⁻¹ *
        Real.exp (-((polarCoord.symm p).1 ^ 2 + (polarCoord.symm p).2 ^ 2) / 2) *
        F (polarCoord.symm p))) =
      (∫ p in Ioi (0 : ℝ) ×ˢ Ioo (-Real.pi) Real.pi,
        (2 * Real.pi)⁻¹ * (p.1 * Real.exp (-(p.1 ^ 2) / 2) * f p.2)) := by
    apply setIntegral_congr_fun (measurableSet_Ioi.prod measurableSet_Ioo)
    rintro ⟨r, θ⟩ ⟨hr, hθ⟩
    simp only [polarCoord_symm_apply, smul_eq_mul]
    rw [hF r hr θ hθ]
    have hrad : (r * Real.cos θ) ^ 2 + (r * Real.sin θ) ^ 2 = r ^ 2 := by
      nlinarith [Real.sin_sq_add_cos_sq θ]
    rw [hrad]
    ring
  rw [heq, integral_const_mul]
  change (2 * Real.pi)⁻¹ *
    (∫ p in Ioi (0 : ℝ) ×ˢ Ioo (-Real.pi) Real.pi,
      p.1 * Real.exp (-(p.1 ^ 2) / 2) * f p.2 ∂((volume : Measure ℝ).prod volume)) = _
  rw [setIntegral_prod_mul (μ := (volume : Measure ℝ)) (ν := (volume : Measure ℝ))
    (fun r : ℝ => r * Real.exp (-(r ^ 2) / 2)) f (Ioi 0) (Ioo (-Real.pi) Real.pi),
    radial_integral, one_mul]

end NeuralGeneralization.GaussianPolar
