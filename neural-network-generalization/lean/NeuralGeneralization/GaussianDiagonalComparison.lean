import NeuralGeneralization.GaussianProductDensity
import Mathlib.MeasureTheory.Measure.WithDensity

/-!
# Density comparison for damping selected Gaussian coordinates

Independent Gaussian variances in `(0,1]` can be decreased at a cost equal to
the product of their standard deviations. This is an inequality of actual
measures, so it remains valid for every measurable event after every linear map.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal ENNReal
namespace NeuralGeneralization.GaussianDiagonalComparison
variable {I : Type*} [Fintype I]

def density (v : I → ℝ≥0) (x : I → ℝ) : ℝ := ∏ i, gaussianPDFReal 0 (v i) (x i)

lemma density_nonneg (v : I → ℝ≥0) (x : I → ℝ) : 0 ≤ density v x :=
  Finset.prod_nonneg fun _ _ => gaussianPDFReal_nonneg _ _ _

@[fun_prop] lemma measurable_density (v : I → ℝ≥0) : Measurable (density v) := by
  unfold density
  exact Finset.measurable_prod _ fun i _ =>
    (measurable_gaussianPDFReal 0 (v i)).comp (measurable_pi_apply i)

lemma integrable_density (v : I → ℝ≥0) : Integrable (density v) volume :=
  Integrable.fintype_prod fun i => integrable_gaussianPDFReal 0 (v i)

theorem gaussianPi_eq_withDensity (v : I → ℝ≥0) (hv : ∀ i, v i ≠ 0) :
    (Measure.pi fun i => gaussianReal 0 (v i)) =
      (volume : Measure (I → ℝ)).withDensity (fun x => ENNReal.ofReal (density v x)) := by
  apply Measure.pi_eq
  intro s hs
  rw [withDensity_apply _ (MeasurableSet.univ_pi hs)]
  rw [← ofReal_integral_eq_lintegral_ofReal (integrable_density v).restrict
    (ae_of_all _ (density_nonneg v))]
  change ENNReal.ofReal (∫ x, density v x ∂(Measure.pi fun _ : I => (volume : Measure ℝ)).restrict
    (Set.univ.pi s)) = _
  rw [Measure.restrict_pi_pi]
  change ENNReal.ofReal (∫ x, ∏ i, gaussianPDFReal 0 (v i) (x i)
    ∂Measure.pi fun i => (volume : Measure ℝ).restrict (s i)) = _
  rw [integral_fintype_prod_eq_prod]
  simp_rw [gaussianReal_apply_eq_integral 0 (hv _)]
  exact ENNReal.ofReal_prod_of_nonneg fun _ _ => integral_nonneg (gaussianPDFReal_nonneg _ _)

lemma scalar_density_compare (v : ℝ≥0) (hv : 0 < v) (hv1 : v ≤ 1) (x : ℝ) :
    Real.sqrt (v : ℝ)*gaussianPDFReal 0 v x ≤ gaussianPDFReal 0 1 x := by
  have hvr : 0 < (v : ℝ) := hv
  have hvr1 : (v : ℝ) ≤ 1 := hv1
  have hden : Real.sqrt (2*Real.pi*(v : ℝ)) =
      Real.sqrt (2*Real.pi)*Real.sqrt (v : ℝ) := Real.sqrt_mul (by positivity) _
  have hcoeff : Real.sqrt (v : ℝ)*(Real.sqrt (2*Real.pi*(v : ℝ)))⁻¹ =
      (Real.sqrt (2*Real.pi))⁻¹ := by
    rw [hden]
    field_simp [(Real.sqrt_pos.mpr hvr).ne']
  have hexp : Real.exp (-(x^2)/(2*(v:ℝ))) ≤ Real.exp (-(x^2)/2) := by
    apply Real.exp_le_exp.mpr
    apply (div_le_iff₀ (by positivity : 0 < 2*(v:ℝ))).2
    nlinarith [sq_nonneg x]
  simp only [gaussianPDFReal, sub_zero, NNReal.coe_one, mul_one]
  rw [← mul_assoc, hcoeff]
  exact mul_le_mul_of_nonneg_left hexp (by positivity)

theorem density_compare (v : I → ℝ≥0) (hv : ∀ i, 0 < v i) (hv1 : ∀ i, v i ≤ 1)
    (x : I → ℝ) :
    (∏ i, Real.sqrt (v i : ℝ))*density v x ≤ density (fun _ => 1) x := by
  unfold density
  rw [← Finset.prod_mul_distrib]
  exact Finset.prod_le_prod (fun i _ => mul_nonneg (Real.sqrt_nonneg _) (gaussianPDFReal_nonneg _ _ _))
    (fun i _ => scalar_density_compare (v i) (hv i) (hv1 i) (x i))

/-- The covariance-damping comparison is a literal measure inequality. -/
theorem damped_gaussian_measure_le (v : I → ℝ≥0)
    (hv : ∀ i, 0 < v i) (hv1 : ∀ i, v i ≤ 1) :
    ENNReal.ofReal (∏ i, Real.sqrt (v i : ℝ)) • (Measure.pi fun i => gaussianReal 0 (v i)) ≤
      Measure.pi (fun _i : I => gaussianReal 0 1) := by
  rw [gaussianPi_eq_withDensity v (fun i => (hv i).ne'),
    gaussianPi_eq_withDensity (fun _i : I => 1) (by intro i; norm_num)]
  rw [← withDensity_smul _ (measurable_density v).ennreal_ofReal]
  apply withDensity_mono
  exact ae_of_all _ fun x => by
    simp only [Pi.smul_apply, smul_eq_mul]
    rw [← ENNReal.ofReal_mul (Finset.prod_nonneg fun i _ => Real.sqrt_nonneg _)]
    exact ENNReal.ofReal_le_ofReal (density_compare v hv hv1 x)

end NeuralGeneralization.GaussianDiagonalComparison
