import NeuralGeneralization.GaussianTail
import Mathlib.MeasureTheory.Integral.Pi
import Mathlib.MeasureTheory.Measure.Haar.NormedSpace

/-! The ordinary density of the actual finite independent Gaussian product. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianProductDensity
variable {I : Type*} [Fintype I]

def density (v : ℝ≥0) (x : I → ℝ) : ℝ := ∏ i, gaussianPDFReal 0 v (x i)

theorem density_nonneg (v : ℝ≥0) (x : I → ℝ) : 0 ≤ density v x :=
  Finset.prod_nonneg (fun i hi => gaussianPDFReal_nonneg _ _ _)

@[fun_prop] theorem measurable_density (v : ℝ≥0) : Measurable (density (I := I) v) := by
  unfold density
  apply Finset.measurable_prod
  intro i hi
  exact (measurable_gaussianPDFReal 0 v).comp (measurable_pi_apply i)

theorem integrable_density (v : ℝ≥0) : Integrable (density (I := I) v) volume :=
  Integrable.fintype_prod (fun _ => integrable_gaussianPDFReal 0 v)

theorem gaussianPi_eq_withDensity (v : ℝ≥0) (hv : v ≠ 0) :
    (Measure.pi fun _ : I => gaussianReal 0 v) =
      (volume : Measure (I → ℝ)).withDensity (fun x => ENNReal.ofReal (density v x)) := by
  apply Measure.pi_eq
  intro s hs
  rw [withDensity_apply _ (MeasurableSet.univ_pi hs)]
  rw [← ofReal_integral_eq_lintegral_ofReal (integrable_density v).restrict
    (ae_of_all _ (density_nonneg v))]
  change ENNReal.ofReal (∫ x, density v x ∂(Measure.pi fun _ : I => (volume : Measure ℝ)).restrict
    (Set.univ.pi s)) = _
  rw [Measure.restrict_pi_pi]
  change ENNReal.ofReal (∫ x, ∏ i, gaussianPDFReal 0 v (x i)
    ∂Measure.pi fun i => (volume : Measure ℝ).restrict (s i)) = _
  rw [integral_fintype_prod_eq_prod]
  simp_rw [gaussianReal_apply_eq_integral 0 hv]
  exact ENNReal.ofReal_prod_of_nonneg (fun i hi => integral_nonneg (gaussianPDFReal_nonneg _ _))

theorem integral_gaussianPi (v : ℝ≥0) (hv : v ≠ 0) (f : (I → ℝ) → ℝ) :
    (∫ x, f x ∂Measure.pi (fun _ : I => gaussianReal 0 v)) = ∫ x, density v x * f x := by
  rw [gaussianPi_eq_withDensity v hv,
    integral_withDensity_eq_integral_toReal_smul (measurable_density v).ennreal_ofReal
      (ae_of_all _ (fun _ => ENNReal.ofReal_lt_top))]
  simp only [ENNReal.toReal_ofReal (density_nonneg _ _), smul_eq_mul]

/-- Standard Gaussian density as a radial exponential, in every finite dimension. -/
theorem standard_density_eq (x : I → ℝ) :
    density 1 x = (Real.sqrt (2 * Real.pi))⁻¹ ^ Fintype.card I *
      Real.exp (-(∑ i, x i ^ 2) / 2) := by
  simp only [density, gaussianPDFReal, NNReal.coe_one, mul_one, sub_zero]
  rw [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ, ← Real.exp_sum]
  rw [← Finset.sum_div, ← Finset.sum_neg_distrib]

end NeuralGeneralization.GaussianProductDensity
