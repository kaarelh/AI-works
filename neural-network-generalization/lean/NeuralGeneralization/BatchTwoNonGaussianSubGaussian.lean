import NeuralGeneralization.BatchTwoNonGaussianComparison
import NeuralGeneralization.BatchTwoNonGaussianMoments
import Mathlib.Probability.Moments.SubGaussian

/-! A genuine scalar sub-Gaussian MGF derived from the density hypotheses.
The law-dependent constant is sufficient for polynomial finite-scale bounds. -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal
namespace NeuralGeneralization.BatchTwoNonGaussian
namespace CoordinateLaw

theorem law_gaussian_upper (ν : CoordinateLaw) :
    ν.law ≤ ENNReal.ofReal (ν.comparisonFactor ν.lowerCurvature) •
      gaussianReal 0 (1 / ν.lowerCurvature).toNNReal := by
  have hv : (1 / ν.lowerCurvature).toNNReal ≠ 0 := by
    exact ne_of_gt (Real.toNNReal_pos.mpr (div_pos zero_lt_one ν.lowerCurvature_pos))
  rw [ν.law_eq_withDensity, gaussianReal_of_var_ne_zero _ hv, gaussianPDF_def,
    ← withDensity_smul _ (measurable_gaussianPDFReal _ _).ennreal_ofReal]
  apply withDensity_mono
  filter_upwards [] with x
  rw [Pi.smul_apply, smul_eq_mul, ← ENNReal.ofReal_mul
    (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le]
  exact ENNReal.ofReal_le_ofReal (ν.density_gaussian_upper x)

theorem one_le_comparisonFactor (ν : CoordinateLaw) :
    1 ≤ ν.comparisonFactor ν.lowerCurvature := by
  have h := ν.law_gaussian_upper Set.univ
  simp only [measure_univ, Measure.smul_apply, smul_eq_mul, mul_one] at h
  exact (ENNReal.ofReal_le_ofReal_iff (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le).mp
    (by simpa using h)

theorem exp_mul_integrable (ν : CoordinateLaw) (t : ℝ) :
    Integrable (fun x : ℝ => Real.exp (t * x)) ν.law :=
  ((integrable_exp_mul_gaussianReal t).smul_measure ENNReal.ofReal_ne_top).mono_measure ν.law_gaussian_upper

private theorem exp_one_add_mul_sub_le {B z : ℝ} (hB : 1 ≤ B) :
    1 + B * (Real.exp z - 1) ≤ Real.exp (B * z) := by
  have hBp : 0 < B := by linarith
  have hi : 0 ≤ 1 - B⁻¹ := by
    have h := (inv_le_one₀ hBp).mpr hB
    linarith
  have h := convexOn_exp.2 (Set.mem_univ (0 : ℝ)) (Set.mem_univ (B * z))
    hi (inv_nonneg.mpr hBp.le) (by ring : 1 - B⁻¹ + B⁻¹ = 1)
  have he : (1 - B⁻¹) * 0 + B⁻¹ * (B * z) = z := by field_simp; ring
  simp only [smul_eq_mul, he, Real.exp_zero, mul_one] at h
  have hm := mul_le_mul_of_nonneg_left h hBp.le
  have hc : B * (1 - B⁻¹ + B⁻¹ * Real.exp (B * z)) = B - 1 + Real.exp (B * z) := by
    field_simp
  rw [hc] at hm
  linarith

/-- Centering by reflection removes the fixed density-comparison prefactor
from the MGF, which is essential before taking independent products. -/
theorem mgf_le (ν : CoordinateLaw) (t : ℝ) :
    mgf (fun x : ℝ => x) ν.law t ≤
      Real.exp ((ν.comparisonFactor ν.lowerCurvature / ν.lowerCurvature) * t ^ 2 / 2) := by
  let B := ν.comparisonFactor ν.lowerCurvature
  let v : ℝ≥0 := (1 / ν.lowerCurvature).toNNReal
  let F : ℝ → ℝ := fun x => (Real.exp (t * x) + Real.exp (-(t * x))) / 2 - 1
  have hv : (v : ℝ) = 1 / ν.lowerCurvature :=
    Real.coe_toNNReal _ (div_nonneg zero_le_one ν.lowerCurvature_pos.le)
  have hFnonneg (x : ℝ) : 0 ≤ F x := by
    have h := Real.add_one_le_exp (t * x)
    have h' := Real.add_one_le_exp (-(t * x))
    dsimp [F]
    linarith
  have hneg (μ : Measure ℝ) (h : Integrable (fun x : ℝ => Real.exp ((-t) * x)) μ) :
      Integrable (fun x : ℝ => Real.exp (-(t * x))) μ := by simpa only [neg_mul] using h
  have hFint : Integrable F (gaussianReal 0 v) :=
    (((integrable_exp_mul_gaussianReal t).add
      (hneg _ (integrable_exp_mul_gaussianReal (-t)))).div_const 2).sub (integrable_const 1)
  have hFNint : Integrable F ν.law :=
    (((ν.exp_mul_integrable t).add (hneg _ (ν.exp_mul_integrable (-t)))).div_const 2).sub
      (integrable_const 1)
  have hNsym : (∫ x, Real.exp (-(t * x)) ∂ν.law) = ∫ x, Real.exp (t * x) ∂ν.law := by
    simpa only [mul_neg] using ν.integral_reflection (fun x => Real.exp (t * x))
  have hN : (∫ x, F x ∂ν.law) = mgf (fun x : ℝ => x) ν.law t - 1 := by
    dsimp [F]
    rw [integral_sub (f := fun x => (Real.exp (t * x) + Real.exp (-(t * x))) / 2)
      (g := fun _ => 1) (((ν.exp_mul_integrable t).add (hneg _ (ν.exp_mul_integrable (-t)))).div_const 2)
      (integrable_const 1), integral_div,
      integral_add (ν.exp_mul_integrable t) (hneg _ (ν.exp_mul_integrable (-t))), hNsym]
    simp only [integral_const, probReal_univ, smul_eq_mul, one_mul, mgf]
    ring
  have hGF : (∫ x, F x ∂gaussianReal 0 v) = Real.exp ((v : ℝ) * t ^ 2 / 2) - 1 := by
    dsimp [F]
    rw [integral_sub (f := fun x => (Real.exp (t * x) + Real.exp (-(t * x))) / 2)
      (g := fun _ => 1) (((integrable_exp_mul_gaussianReal t).add
      (hneg _ (integrable_exp_mul_gaussianReal (-t)))).div_const 2) (integrable_const 1), integral_div,
      integral_add (integrable_exp_mul_gaussianReal t) (hneg _ (integrable_exp_mul_gaussianReal (-t)))]
    have hp := congrFun (mgf_fun_id_gaussianReal (μ := 0) (v := v)) t
    have hn := congrFun (mgf_fun_id_gaussianReal (μ := 0) (v := v)) (-t)
    simp only [mgf, id_eq, zero_mul, zero_add, neg_sq] at hp hn
    simp only [neg_mul] at hn
    rw [hp, hn]
    simp only [integral_const, probReal_univ, smul_eq_mul, one_mul]
    ring
  have hm := integral_mono_measure ν.law_gaussian_upper
    (ae_of_all _ hFnonneg) (hFint.smul_measure ENNReal.ofReal_ne_top)
  rw [integral_smul_measure, ENNReal.toReal_ofReal
    (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le, hN, hGF] at hm
  simp only [smul_eq_mul] at hm
  have hu : mgf (fun x : ℝ => x) ν.law t ≤ 1 + B * (Real.exp ((v : ℝ) * t ^ 2 / 2) - 1) := by
    dsimp [B]
    linarith
  apply hu.trans
  have hh := exp_one_add_mul_sub_le (z := (v : ℝ) * t ^ 2 / 2) ν.one_le_comparisonFactor
  convert! hh using 1
  congr 1
  rw [hv]
  ring

theorem hasSubgaussianMGF (ν : CoordinateLaw) :
    HasSubgaussianMGF (fun x : ℝ => x)
      (ν.comparisonFactor ν.lowerCurvature / ν.lowerCurvature).toNNReal ν.law where
  integrable_exp_mul := ν.exp_mul_integrable
  mgf_le t := by
    rw [Real.coe_toNNReal _ (div_nonneg
      (ν.comparisonFactor_pos _ ν.lowerCurvature_pos).le ν.lowerCurvature_pos.le)]
    exact ν.mgf_le t

end CoordinateLaw
end NeuralGeneralization.BatchTwoNonGaussian
