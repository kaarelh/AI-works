import NeuralGeneralization.PrekopaLeindlerReal
import Mathlib.Probability.Distributions.Gaussian.Real

/-! The actual scalar Gaussian Prékopa--Leindler inequality. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped NNReal
namespace NeuralGeneralization.PrekopaLeindlerGaussian
open PrekopaLeindlerInterval PrekopaLeindlerReal

theorem gaussian_density_mix {t : ℝ} (ht : t ∈ Icc 0 1) (x y : ℝ) :
    gaussianPDFReal 0 1 x ^ (1-t) * gaussianPDFReal 0 1 y ^ t ≤
      gaussianPDFReal 0 1 (mix t x y) := by
  let c : ℝ := (Real.sqrt (2 * Real.pi))⁻¹
  have hc : 0 < c := inv_pos.mpr (Real.sqrt_pos.2 (by positivity))
  have hform (z : ℝ) : gaussianPDFReal 0 1 z = c * Real.exp (-z^2/2) := by
    simp only [gaussianPDFReal, NNReal.coe_one, mul_one, sub_zero, c]
  rw [hform, hform, hform, Real.mul_rpow hc.le (Real.exp_pos _).le,
    Real.mul_rpow hc.le (Real.exp_pos _).le, ← Real.exp_mul, ← Real.exp_mul]
  have hcadd : c ^ (1-t) * c ^ t = c := by
    rw [← Real.rpow_add hc, sub_add_cancel, Real.rpow_one]
  calc
    _ = c * Real.exp ((-x^2/2)*(1-t)+(-y^2/2)*t) := by
      calc
        _ = (c ^ (1-t) * c ^ t) *
          (Real.exp ((-x^2/2)*(1-t)) * Real.exp ((-y^2/2)*t)) := by ring
        _ = _ := by rw [hcadd, ← Real.exp_add]
    _ ≤ c * Real.exp (-(mix t x y)^2/2) := by
      apply mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr ?_) hc.le
      have hsq := mul_nonneg (mul_nonneg ht.1 (sub_nonneg.mpr ht.2)) (sq_nonneg (x-y))
      dsimp [mix]
      nlinarith

theorem continuous_gaussian_density : Continuous (gaussianPDFReal 0 1) := by
  unfold gaussianPDFReal
  fun_prop

theorem gaussian_weight_integrable {f : ℝ → ℝ} (hf : Continuous f)
    (B : ℝ) (hB : ∀ x, |f x| ≤ B) :
    Integrable (fun x => gaussianPDFReal 0 1 x * f x) :=
  (integrable_gaussianPDFReal 0 1).mul_bdd hf.aestronglyMeasurable
    (Filter.Eventually.of_forall fun x => by simpa only [Real.norm_eq_abs] using hB x)

theorem prekopa_leindler_gaussian {f g h : ℝ → ℝ} {t : ℝ}
    (hf : Continuous f) (hg : Continuous g) (hh : Continuous h)
    (hfpos : ∀ x, 0 < f x) (hgpos : ∀ x, 0 < g x)
    (Bf Bg Bh : ℝ) (hfB : ∀ x, |f x| ≤ Bf) (hgB : ∀ x, |g x| ≤ Bg)
    (hhB : ∀ x, |h x| ≤ Bh) (ht : t ∈ Icc 0 1)
    (hpoint : ∀ x y, f x ^ (1-t) * g y ^ t ≤ h (mix t x y)) :
    (∫ x, f x ∂gaussianReal 0 1) ^ (1-t) *
      (∫ x, g x ∂gaussianReal 0 1) ^ t ≤ ∫ x, h x ∂gaussianReal 0 1 := by
  rw [integral_gaussianReal_eq_integral_smul (by norm_num : (1 : ℝ≥0) ≠ 0),
    integral_gaussianReal_eq_integral_smul (by norm_num : (1 : ℝ≥0) ≠ 0),
    integral_gaussianReal_eq_integral_smul (by norm_num : (1 : ℝ≥0) ≠ 0)]
  simp only [smul_eq_mul]
  apply prekopa_leindler_real (continuous_gaussian_density.mul hf)
    (continuous_gaussian_density.mul hg) (continuous_gaussian_density.mul hh)
    (fun x => mul_pos (gaussianPDFReal_pos 0 1 x (by norm_num)) (hfpos x))
    (fun x => mul_pos (gaussianPDFReal_pos 0 1 x (by norm_num)) (hgpos x))
    (gaussian_weight_integrable hf Bf hfB) (gaussian_weight_integrable hg Bg hgB)
    (gaussian_weight_integrable hh Bh hhB) ht
  intro x y
  simp only [Pi.mul_apply]
  rw [Real.mul_rpow (gaussianPDFReal_nonneg _ _ _) (hfpos x).le,
    Real.mul_rpow (gaussianPDFReal_nonneg _ _ _) (hgpos y).le]
  calc
    _ = (gaussianPDFReal 0 1 x ^ (1-t) * gaussianPDFReal 0 1 y ^ t) *
        (f x ^ (1-t) * g y ^ t) := by ring
    _ ≤ gaussianPDFReal 0 1 (mix t x y) * h (mix t x y) :=
      mul_le_mul (gaussian_density_mix ht x y) (hpoint x y)
        (mul_pos (Real.rpow_pos_of_pos (hfpos x) _) (Real.rpow_pos_of_pos (hgpos y) _)).le
        (gaussianPDFReal_nonneg _ _ _)

end NeuralGeneralization.PrekopaLeindlerGaussian
end
