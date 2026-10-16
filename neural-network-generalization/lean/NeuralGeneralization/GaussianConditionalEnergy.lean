import NeuralGeneralization.GaussianTail
import Mathlib.Probability.ConditionalProbability
import Mathlib.Probability.Moments.IntegrableExpMul

/-!
# Gaussian quadratic energy under actual event conditioning

The logarithmic event-probability cost follows directly from the exponential
tangent inequality and the exact conditional measure. Gaussian square MGFs
then give the energy bound, without assuming an entropy inequality.
-/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

namespace NeuralGeneralization

theorem exp_integral_le_of_integrable {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (f : Ω → ℝ)
    (hf : Integrable f μ) (he : Integrable (fun x => Real.exp (f x)) μ) :
    Real.exp (∫ x, f x ∂μ) ≤ ∫ x, Real.exp (f x) ∂μ := by
  let m := ∫ x, f x ∂μ
  have hpoint (x : Ω) : Real.exp m * (1 + f x - m) ≤ Real.exp (f x) := by
    have ht := mul_le_mul_of_nonneg_left (Real.add_one_le_exp (f x - m))
      (Real.exp_pos m).le
    have hid : Real.exp m * Real.exp (f x - m) = Real.exp (f x) := by
      rw [← Real.exp_add]
      congr 1
      ring
    rw [hid] at ht
    linarith
  have hint : Integrable (fun x => Real.exp m * (1 + f x - m)) μ :=
    (((integrable_const 1).add hf).sub (integrable_const m)).const_mul _
  have hh := integral_mono hint he hpoint
  have hlin : (∫ x, 1 + f x - m ∂μ) = 1 + (∫ x, f x ∂μ) - m := by
    calc
      _ = ∫ x, f x + (1 - m) ∂μ := by
        apply integral_congr_ae
        exact Filter.Eventually.of_forall fun x => by ring
      _ = _ := by
        rw [integral_add hf (integrable_const (1 - m))]
        simp
        ring
  have hid : (∫ x, Real.exp m * (1 + f x - m) ∂μ) = Real.exp m := by
    rw [integral_const_mul, hlin]
    simp [m]
  rwa [hid] at hh

theorem conditional_expectation_le_of_exponential_moment
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (Q : Ω → ℝ) (s B : ℝ) (hs : 0 < s)
    (hQ : Integrable Q μ) (he : Integrable (fun x => Real.exp (s * Q x)) μ)
    (hmgf : (∫ x, Real.exp (s * Q x) ∂μ) ≤ Real.exp B)
    (E : Set Ω) (hE : μ E ≠ 0) :
    (∫ x, Q x ∂cond μ E) ≤ (B + Real.log (1 / μ.real E)) / s := by
  letI : IsProbabilityMeasure (cond μ E) := cond_isProbabilityMeasure hE
  have hp : 0 < μ.real E := ENNReal.toReal_pos hE (measure_ne_top μ E)
  have hQE : Integrable Q (cond μ E) :=
    hQ.restrict.smul_measure (ENNReal.inv_ne_top.mpr hE)
  have heE : Integrable (fun x => Real.exp (s * Q x)) (cond μ E) :=
    he.restrict.smul_measure (ENNReal.inv_ne_top.mpr hE)
  have hJ := exp_integral_le_of_integrable (cond μ E) (fun x => s * Q x)
    (hQE.const_mul s) heE
  rw [integral_const_mul] at hJ
  have hcond : (∫ x, Real.exp (s * Q x) ∂cond μ E) ≤
      (μ.real E)⁻¹ * Real.exp B := by
    unfold ProbabilityTheory.cond
    rw [integral_smul_measure, ENNReal.toReal_inv]
    change (μ.real E)⁻¹ * (∫ x in E, Real.exp (s * Q x) ∂μ) ≤ _
    apply mul_le_mul_of_nonneg_left _ (inv_nonneg.mpr hp.le)
    exact (setIntegral_le_integral he (Filter.Eventually.of_forall fun x => (Real.exp_pos _).le)).trans hmgf
  have hid : (μ.real E)⁻¹ * Real.exp B = Real.exp (B + Real.log (1 / μ.real E)) := by
    rw [Real.exp_add, Real.exp_log (one_div_pos.mpr hp)]
    ring
  have hbound := hJ.trans hcond
  rw [hid, Real.exp_le_exp] at hbound
  exact (le_div_iff₀ hs).mpr (by linarith)

/-- Actual conditional Gaussian quadratic energy. The coefficient-domain
condition ensures finite moments at both signs of the exponential parameter. -/
theorem conditional_gaussian_quadratic_energy {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (s : ℝ) (hs : 0 < s)
    (hcoeff : ∀ i, |2 * s * c i * (v i : ℝ)| ≤ 1 / 2)
    (E : Set (ι → ℝ))
    (hE : (Measure.pi fun i => gaussianReal 0 (v i)) E ≠ 0) :
    (∫ x, (∑ i, c i * (x i ^ 2 - (v i : ℝ)))
        ∂cond (Measure.pi fun i => gaussianReal 0 (v i)) E) ≤
      4 * s * (∑ i, c i ^ 2 * (v i : ℝ) ^ 2) +
        Real.log (1 / (Measure.pi fun i => gaussianReal 0 (v i)).real E) / s := by
  have hplus (i : ι) : 2 * s * c i * (v i : ℝ) ≤ 1 / 2 := (abs_le.mp (hcoeff i)).2
  have hminus (i : ι) : 2 * (-s) * c i * (v i : ℝ) ≤ 1 / 2 := by
    have hh := (abs_le.mp (hcoeff i)).1
    linarith
  have he := GaussianTail.integrable_exp_sum_centered_gaussian_squares v c s
    (fun i => by have hh := hplus i; linarith)
  have he' := GaussianTail.integrable_exp_sum_centered_gaussian_squares v c (-s)
    (fun i => by have hh := hminus i; linarith)
  have hQ : Integrable (fun x : ι → ℝ => ∑ i, c i * (x i ^ 2 - (v i : ℝ)))
      (Measure.pi fun i => gaussianReal 0 (v i)) := by
    simpa only [pow_one] using integrable_pow_of_integrable_exp_mul hs.ne' he he' 1
  have hm := GaussianTail.mgf_sum_centered_gaussian_squares_le v c s hplus
  have hh := conditional_expectation_le_of_exponential_moment
    (Measure.pi fun i => gaussianReal 0 (v i))
    (fun x : ι → ℝ => ∑ i, c i * (x i ^ 2 - (v i : ℝ))) s
    (4 * s ^ 2 * ∑ i, c i ^ 2 * (v i : ℝ) ^ 2) hs hQ he hm E hE
  have hid : (4 * s ^ 2 * (∑ i, c i ^ 2 * (v i : ℝ) ^ 2) +
      Real.log (1 / (Measure.pi fun i => gaussianReal 0 (v i)).real E)) / s =
      4 * s * (∑ i, c i ^ 2 * (v i : ℝ) ^ 2) +
      Real.log (1 / (Measure.pi fun i => gaussianReal 0 (v i)).real E) / s := by
    field_simp
  rwa [hid] at hh

/-- The trace/operator-scale form used for the globally conditioned Gaussian
endpoint: conditioning on any positive-probability event costs at most a
constant times its logarithmic inverse probability. -/
theorem conditional_gaussian_diagonal_energy {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (hc : ∀ i, 0 ≤ c i)
    (B : ℝ) (hB : 0 < B) (hscale : ∀ i, c i * (v i : ℝ) ≤ B)
    (E : Set (ι → ℝ))
    (hE : (Measure.pi fun i => gaussianReal 0 (v i)) E ≠ 0) :
    (∫ x, (∑ i, c i * x i ^ 2) ∂cond (Measure.pi fun i => gaussianReal 0 (v i)) E) ≤
      2 * (∑ i, c i * (v i : ℝ)) +
        4 * B * Real.log (1 / (Measure.pi fun i => gaussianReal 0 (v i)).real E) := by
  let μ : Measure (ι → ℝ) := Measure.pi fun i => gaussianReal 0 (v i)
  letI : IsProbabilityMeasure (cond μ E) := cond_isProbabilityMeasure hE
  let s := 1 / (4 * B)
  have hs : 0 < s := by dsimp [s]; positivity
  have hcoeff (i : ι) : |2 * s * c i * (v i : ℝ)| ≤ 1 / 2 := by
    have hci := hc i
    rw [abs_of_nonneg (by positivity)]
    have heq : 2 * s * c i * (v i : ℝ) = (c i * (v i : ℝ)) / (2 * B) := by
      dsimp [s]
      ring
    rw [heq]
    apply (div_le_iff₀ (by positivity : 0 < 2 * B)).mpr
    linarith [hscale i]
  have hV : (∑ i, c i ^ 2 * (v i : ℝ) ^ 2) ≤ B * (∑ i, c i * (v i : ℝ)) := by
    rw [Finset.mul_sum]
    apply Finset.sum_le_sum
    intro i hi
    have hci := mul_nonneg (hc i) (v i).coe_nonneg
    nlinarith [mul_le_mul_of_nonneg_right (hscale i) hci]
  have hcenter := conditional_gaussian_quadratic_energy v c s hs hcoeff E hE
  have he := GaussianTail.integrable_exp_sum_centered_gaussian_squares v c s
    (fun i => by have hh := (abs_le.mp (hcoeff i)).2; linarith)
  have he' := GaussianTail.integrable_exp_sum_centered_gaussian_squares v c (-s)
    (fun i => by have hh := (abs_le.mp (hcoeff i)).1; linarith)
  have hQ : Integrable (fun x : ι → ℝ => ∑ i, c i * (x i ^ 2 - (v i : ℝ))) μ := by
    simpa only [pow_one] using integrable_pow_of_integrable_exp_mul hs.ne' he he' 1
  have hQE : Integrable (fun x : ι → ℝ => ∑ i, c i * (x i ^ 2 - (v i : ℝ)))
      (cond μ E) := hQ.restrict.smul_measure (ENNReal.inv_ne_top.mpr hE)
  have hfun : (fun x : ι → ℝ => ∑ i, c i * x i ^ 2) =
      fun x => (∑ i, c i * (x i ^ 2 - (v i : ℝ))) + (∑ i, c i * (v i : ℝ)) := by
    funext x
    simp only [mul_sub, Finset.sum_sub_distrib]
    ring
  rw [hfun, integral_add hQE (integrable_const _)]
  simp only [integral_const, probReal_univ, one_smul]
  have hscaled : 4 * s * (∑ i, c i ^ 2 * (v i : ℝ) ^ 2) ≤ ∑ i, c i * (v i : ℝ) := by
    have hh := mul_le_mul_of_nonneg_left hV (show 0 ≤ 4 * s by positivity)
    have heq : 4 * s * (B * (∑ i, c i * (v i : ℝ))) = ∑ i, c i * (v i : ℝ) := by
      dsimp [s]
      field_simp
    rwa [heq] at hh
  have hlog : Real.log (1 / μ.real E) / s = 4 * B * Real.log (1 / μ.real E) := by
    simp [s, div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc]
  change _ ≤ _ + Real.log (1 / μ.real E) / s at hcenter
  rw [hlog] at hcenter
  linarith

end NeuralGeneralization
