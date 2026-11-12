import NeuralGeneralization.GaussianConeRadial
import NeuralGeneralization.GaussianMixtureCDF
import NeuralGeneralization.BatchTwoNeuralConverseRelays
import Mathlib.Analysis.Real.Pi.Bounds

/-! Scalar and Gaussian moment bounds for spherical score anti-concentration. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators NNReal
namespace NeuralGeneralization.BatchTwoContinuousSphere
open ConcreteModel GaussianConeRadial

theorem standard_gaussian_density_bound_le_half :
    GaussianMixtureCDF.densityBound 1 ≤ (1/2:ℝ) := by
  unfold GaussianMixtureCDF.densityBound
  norm_num only [NNReal.coe_one, mul_one]
  apply one_div_le_one_div_of_le (by norm_num : (0:ℝ)<2)
  apply (Real.le_sqrt (by norm_num) (by positivity)).mpr
  nlinarith [Real.pi_gt_three]

/-- The standard Gaussian assigns at most a to [-a,a]. -/
theorem gaussian_abs_small_ball {a : ℝ} (ha : 0 ≤ a) :
    (gaussianReal 0 1) {x : ℝ | |x| ≤ a} ≤ ENNReal.ofReal a := by
  have hs : {x : ℝ | |x| ≤ a} = Icc (-a) a := by ext x; simp only [Set.mem_setOf_eq, Set.mem_Icc, abs_le]
  rw [hs, gaussianReal_apply_eq_integral 0 (by norm_num : (1:ℝ≥0) ≠ 0)]
  apply ENNReal.ofReal_le_ofReal
  have h := setIntegral_mono_on (integrable_gaussianPDFReal 0 1).integrableOn
    (integrableOn_const (measure_Icc_lt_top.ne : volume (Icc (-a) a) ≠ ⊤))
    measurableSet_Icc (fun x _ =>
      (GaussianMixtureCDF.pdf_le_densityBound 0 1 x).trans standard_gaussian_density_bound_le_half)
  rw [setIntegral_const, smul_eq_mul, Measure.real, Real.volume_Icc,
    ENNReal.toReal_ofReal (by linarith : 0 ≤ a-(-a))] at h
  linarith

theorem tanh_ge_half {x : ℝ} (hx : x ∈ Icc (0:ℝ) 1) : x/2 ≤ Real.tanh x := by
  have hroot : Real.sqrt (1+x^2) ≤ 2 := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · norm_num
    · nlinarith [hx.1, hx.2]
  exact (div_le_div_of_nonneg_left hx.1 (Real.sqrt_pos.mpr (by positivity)) hroot).trans
    (BatchTwoNeuralConverse.tanh_lower_square_root hx.1)

theorem abs_le_twice_abs_tanh {x : ℝ} (hx : |x| ≤ 1) : |x| ≤ 2*|Real.tanh x| := by
  by_cases h : 0 ≤ x
  · have ht := tanh_ge_half ⟨h, (le_abs_self x).trans hx⟩
    rw [abs_of_nonneg h]
    linarith [le_abs_self (Real.tanh x)]
  · have ht := tanh_ge_half (x := -x) ⟨by linarith, (neg_le_abs x).trans hx⟩
    rw [Real.tanh_neg] at ht
    rw [abs_of_nonpos (by linarith)]
    linarith [neg_le_abs (Real.tanh x)]

/-- A normalized-coordinate band is contained in an independent Gaussian
small-ball event. The factor 3/2 is enough whenever s<=2/3. -/
theorem normalized_coordinate_band {x R s : ℝ} (hR : 0 ≤ R)
    (hs : 0 ≤ s) (hs1 : s ≤ 2/3)
    (h : |x| ≤ s*Real.sqrt (x^2+R^2)) : |x| ≤ (3/2)*s*R := by
  have hsq := (sq_le_sq₀ (abs_nonneg x) (by positivity)).mpr h
  rw [sq_abs, mul_pow, Real.sq_sqrt (by positivity)] at hsq
  have hs2 : s^2 ≤ 4/9 := by nlinarith
  have hprod := mul_nonneg (show 0 ≤ 4/9-s^2 by linarith) (sq_nonneg x)
  apply (sq_le_sq₀ (abs_nonneg x) (by positivity)).mp
  rw [sq_abs]
  nlinarith

end NeuralGeneralization.BatchTwoContinuousSphere
