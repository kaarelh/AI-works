import NeuralGeneralization.BatchTwoNonGaussianDensity
import NeuralGeneralization.GaussianProductDensity

/-! Two-sided comparison with actual Gaussian measures, proved directly from
the quadratic density envelopes.  Multiplicative constants may depend on the
fixed finite dimension but not on the shrinking prior scale. -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
namespace CoordinateLaw

def comparisonFactor (ν : CoordinateLaw) (c : ℝ) : ℝ :=
  Real.exp (-ν.potential 0) / ν.normalizer * Real.sqrt (2 * Real.pi / c)

theorem comparisonFactor_pos (ν : CoordinateLaw) (c : ℝ) (hc : 0 < c) :
    0 < ν.comparisonFactor c := by
  unfold comparisonFactor
  exact mul_pos (div_pos (Real.exp_pos _) ν.normalizer_pos)
    (Real.sqrt_pos.mpr (by positivity))

theorem comparisonFactor_gaussianPDF (ν : CoordinateLaw) (c : ℝ) (hc : 0 < c) (x : ℝ) :
    ν.comparisonFactor c * gaussianPDFReal 0 (1 / c).toNNReal x =
      Real.exp (-ν.potential 0) / ν.normalizer * Real.exp (-(c / 2) * x ^ 2) := by
  have hcs : Real.sqrt (2 * Real.pi / c) ≠ 0 := (Real.sqrt_pos.mpr (by positivity)).ne'
  have he : -x ^ 2 / (2 * (1 / c)) = -(c / 2) * x ^ 2 := by field_simp
  unfold comparisonFactor gaussianPDFReal
  rw [Real.coe_toNNReal _ (div_nonneg zero_le_one hc.le)]
  simp only [sub_zero]
  rw [he, show 2 * Real.pi * (1 / c) = 2 * Real.pi / c by ring]
  field_simp

theorem density_gaussian_lower (ν : CoordinateLaw) (x : ℝ) :
    ν.comparisonFactor ν.upperCurvature *
        gaussianPDFReal 0 (1 / ν.upperCurvature).toNNReal x ≤ ν.density x := by
  rw [ν.comparisonFactor_gaussianPDF _ ν.upperCurvature_pos]
  unfold density
  have he : Real.exp (-ν.potential 0) * Real.exp (-(ν.upperCurvature / 2) * x ^ 2) ≤
      Real.exp (-ν.potential x) := by
    rw [← Real.exp_add]
    apply Real.exp_le_exp.mpr
    have h := (ν.quadratic_envelopes x).2
    nlinarith
  convert! div_le_div_of_nonneg_right he ν.normalizer_pos.le using 1 <;> ring

theorem density_gaussian_upper (ν : CoordinateLaw) (x : ℝ) :
    ν.density x ≤ ν.comparisonFactor ν.lowerCurvature *
      gaussianPDFReal 0 (1 / ν.lowerCurvature).toNNReal x := by
  rw [ν.comparisonFactor_gaussianPDF _ ν.lowerCurvature_pos]
  unfold density
  convert! div_le_div_of_nonneg_right (ν.exp_potential_upper x) ν.normalizer_pos.le using 1 <;> ring

variable {I : Type*} [Fintype I]

theorem productDensity_gaussian_lower (ν : CoordinateLaw) (x : I → ℝ) :
    ν.comparisonFactor ν.upperCurvature ^ Fintype.card I *
        GaussianProductDensity.density (1 / ν.upperCurvature).toNNReal x ≤ ν.productDensity x := by
  have h := Finset.prod_le_prod (s := Finset.univ)
    (f := fun i : I => ν.comparisonFactor ν.upperCurvature *
      gaussianPDFReal 0 (1 / ν.upperCurvature).toNNReal (x i))
    (g := fun i : I => ν.density (x i))
    (fun i _ => mul_nonneg (ν.comparisonFactor_pos _ ν.upperCurvature_pos).le
      (gaussianPDFReal_nonneg _ _ _)) (fun i _ => ν.density_gaussian_lower (x i))
  simpa only [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ,
    GaussianProductDensity.density, productDensity] using h

theorem productDensity_gaussian_upper (ν : CoordinateLaw) (x : I → ℝ) :
    ν.productDensity x ≤ ν.comparisonFactor ν.lowerCurvature ^ Fintype.card I *
      GaussianProductDensity.density (1 / ν.lowerCurvature).toNNReal x := by
  have h := Finset.prod_le_prod (s := Finset.univ)
    (f := fun i : I => ν.density (x i))
    (g := fun i : I => ν.comparisonFactor ν.lowerCurvature *
      gaussianPDFReal 0 (1 / ν.lowerCurvature).toNNReal (x i))
    (fun i _ => ν.density_nonneg _) (fun i _ => ν.density_gaussian_upper (x i))
  simpa only [Finset.prod_mul_distrib, Finset.prod_const, Finset.card_univ,
    GaussianProductDensity.density, productDensity] using h

/-- Lower measure comparison for every event, with no smoothness or openness assumption. -/
theorem product_measure_gaussian_lower (ν : CoordinateLaw) :
    ENNReal.ofReal (ν.comparisonFactor ν.upperCurvature ^ Fintype.card I) •
        (Measure.pi fun _ : I => gaussianReal 0 (1 / ν.upperCurvature).toNNReal) ≤
      Measure.pi (fun _ : I => ν.law) := by
  have hv : (1 / ν.upperCurvature).toNNReal ≠ 0 := by
    exact ne_of_gt (Real.toNNReal_pos.mpr (div_pos zero_lt_one ν.upperCurvature_pos))
  rw [ν.product_eq_withDensity, GaussianProductDensity.gaussianPi_eq_withDensity _ hv,
    ← withDensity_smul _ (GaussianProductDensity.measurable_density _).ennreal_ofReal]
  apply withDensity_mono
  filter_upwards [] with x
  rw [Pi.smul_apply, smul_eq_mul, ← ENNReal.ofReal_mul
    (pow_nonneg (ν.comparisonFactor_pos _ ν.upperCurvature_pos).le _)]
  exact ENNReal.ofReal_le_ofReal (ν.productDensity_gaussian_lower x)

/-- Upper measure comparison for every event. -/
theorem product_measure_gaussian_upper (ν : CoordinateLaw) :
    (Measure.pi fun _ : I => ν.law) ≤
      ENNReal.ofReal (ν.comparisonFactor ν.lowerCurvature ^ Fintype.card I) •
        (Measure.pi fun _ : I => gaussianReal 0 (1 / ν.lowerCurvature).toNNReal) := by
  have hv : (1 / ν.lowerCurvature).toNNReal ≠ 0 := by
    exact ne_of_gt (Real.toNNReal_pos.mpr (div_pos zero_lt_one ν.lowerCurvature_pos))
  rw [ν.product_eq_withDensity, GaussianProductDensity.gaussianPi_eq_withDensity _ hv,
    ← withDensity_smul _ (GaussianProductDensity.measurable_density _).ennreal_ofReal]
  apply withDensity_mono
  filter_upwards [] with x
  rw [Pi.smul_apply, smul_eq_mul, ← ENNReal.ofReal_mul
    (pow_nonneg (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le _)]
  exact ENNReal.ofReal_le_ofReal (ν.productDensity_gaussian_upper x)

end CoordinateLaw
end NeuralGeneralization.BatchTwoNonGaussian
