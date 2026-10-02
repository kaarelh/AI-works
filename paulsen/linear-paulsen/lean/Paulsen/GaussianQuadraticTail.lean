import Paulsen.GaussianFourthMoment
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

/-!
# Exponential moments of Gaussian squares

The square moment-generating function is evaluated directly from the Gaussian
density and the Gaussian integral.  Integrability is derived from that formula.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

/-- The square MGF, valid throughout its finite domain and including variance zero. -/
theorem integral_exp_mul_sq_gaussianReal (v : ℝ≥0) (s : ℝ)
    (hs : 0 < 1 - 2 * s * (v : ℝ)) :
    (∫ x : ℝ, Real.exp (s * x ^ 2) ∂gaussianReal 0 v) =
      (Real.sqrt (1 - 2 * s * (v : ℝ)))⁻¹ := by
  by_cases hv : v = 0
  · simp [hv]
  have hvR : (v : ℝ) ≠ 0 := by exact_mod_cast hv
  have hvpos : 0 < (v : ℝ) := lt_of_le_of_ne v.coe_nonneg (Ne.symm hvR)
  have hC : 0 < Real.sqrt (2 * Real.pi * (v : ℝ)) := by positivity
  rw [integral_gaussianReal_eq_integral_smul hv]
  simp only [gaussianPDFReal, sub_zero, smul_eq_mul]
  have hfun : (fun x : ℝ => (Real.sqrt (2 * Real.pi * (v : ℝ)))⁻¹ *
      Real.exp (-(x ^ 2) / (2 * (v : ℝ))) * Real.exp (s * x ^ 2)) =
      fun x : ℝ => (Real.sqrt (2 * Real.pi * (v : ℝ)))⁻¹ *
        Real.exp (-((1 - 2 * s * (v : ℝ)) / (2 * (v : ℝ))) * x ^ 2) := by
    ext x
    rw [mul_assoc, ← Real.exp_add]
    congr 2
    field_simp
    ring
  rw [hfun, integral_const_mul, integral_gaussian]
  have harg : Real.pi / ((1 - 2 * s * (v : ℝ)) / (2 * (v : ℝ))) =
      (2 * Real.pi * (v : ℝ)) / (1 - 2 * s * (v : ℝ)) := by
    field_simp
  rw [harg, Real.sqrt_div (by positivity)]
  field_simp

/-- Exact centered-square moment-generating function. -/
theorem mgf_centered_square_gaussianReal (v : ℝ≥0) (s : ℝ)
    (hs : 0 < 1 - 2 * s * (v : ℝ)) :
    mgf (fun x : ℝ => x ^ 2 - (v : ℝ)) (gaussianReal 0 v) s =
      Real.exp (-s * (v : ℝ)) / Real.sqrt (1 - 2 * s * (v : ℝ)) := by
  unfold mgf
  have hfun : (fun x : ℝ => Real.exp (s * (x ^ 2 - (v : ℝ)))) =
      fun x : ℝ => Real.exp (-s * (v : ℝ)) * Real.exp (s * x ^ 2) := by
    ext x
    rw [← Real.exp_add]
    congr 1
    ring
  rw [hfun, integral_const_mul, integral_exp_mul_sq_gaussianReal v s hs]
  rfl

theorem integrable_exp_centered_square_gaussianReal (v : ℝ≥0) (s : ℝ)
    (hs : 0 < 1 - 2 * s * (v : ℝ)) :
    Integrable (fun x : ℝ => Real.exp (s * (x ^ 2 - (v : ℝ)))) (gaussianReal 0 v) := by
  apply Integrable.of_integral_ne_zero
  change mgf (fun x : ℝ => x ^ 2 - (v : ℝ)) (gaussianReal 0 v) s ≠ 0
  rw [mgf_centered_square_gaussianReal v s hs]
  exact div_ne_zero (Real.exp_ne_zero _) (Real.sqrt_pos.2 hs).ne'

/-- Direct Chernoff bound for a centered Gaussian square. -/
theorem centered_gaussian_square_chernoff (v : ℝ≥0) (s u : ℝ)
    (hs0 : 0 ≤ s) (hs : 0 < 1 - 2 * s * (v : ℝ)) :
    (gaussianReal 0 v).real {x : ℝ | u ≤ x ^ 2 - (v : ℝ)} ≤
      Real.exp (-s * u) *
        (Real.exp (-s * (v : ℝ)) / Real.sqrt (1 - 2 * s * (v : ℝ))) := by
  have h := measure_ge_le_exp_mul_mgf u hs0
    (integrable_exp_centered_square_gaussianReal v s hs)
  rwa [mgf_centered_square_gaussianReal v s hs] at h

/-- A quadratic upper bound on the centered logarithmic correction. -/
theorem centered_log_one_sub_le (u : ℝ) (hu : u ≤ 1 / 2) :
    -u / 2 - Real.log (1 - u) / 2 ≤ u ^ 2 := by
  have hden : 0 < 1 - u := by linarith
  have hlog := Real.one_sub_inv_le_log_of_pos hden
  have hid : -u - (1 - (1 - u)⁻¹) = u ^ 2 / (1 - u) := by
    field_simp
    ring
  have hbound : u ^ 2 / (1 - u) ≤ 2 * u ^ 2 := by
    apply (div_le_iff₀ hden).2
    have hnonneg := mul_nonneg (sq_nonneg u) (show 0 ≤ 1 - 2 * u by linarith)
    nlinarith
  linarith

/-- A Gaussian-square exponential estimate with a numerical constant four.
The exact MGF above is sharper; this form composes into quadratic-form tails. -/
theorem mgf_centered_square_le_exp (v : ℝ≥0) (s : ℝ)
    (hs : 2 * s * (v : ℝ) ≤ 1 / 2) :
    mgf (fun x : ℝ => x ^ 2 - (v : ℝ)) (gaussianReal 0 v) s ≤
      Real.exp (4 * s ^ 2 * (v : ℝ) ^ 2) := by
  have hden : 0 < 1 - 2 * s * (v : ℝ) := by linarith
  rw [mgf_centered_square_gaussianReal v s hden]
  apply (Real.log_le_iff_le_exp (div_pos (Real.exp_pos _) (Real.sqrt_pos.2 hden))).1
  rw [Real.log_div (Real.exp_ne_zero _) (Real.sqrt_pos.2 hden).ne',
    Real.log_exp, Real.log_sqrt hden.le]
  have h := centered_log_one_sub_le (2 * s * (v : ℝ)) hs
  nlinarith [h]

/-- Exact MGF of a diagonal Gaussian quadratic form with arbitrary signed
coefficients and arbitrary nonnegative coordinate variances. -/
theorem mgf_sum_centered_gaussian_squares {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (s : ℝ)
    (hs : ∀ i, 0 < 1 - 2 * s * c i * (v i : ℝ)) :
    mgf (fun x : ι → ℝ => ∑ i, c i * ((x i) ^ 2 - (v i : ℝ)))
      (Measure.pi fun i => gaussianReal 0 (v i)) s =
      ∏ i, Real.exp (-s * c i * (v i : ℝ)) /
        Real.sqrt (1 - 2 * s * c i * (v i : ℝ)) := by
  have hInd := iIndepFun_pi (μ := fun i => gaussianReal 0 (v i))
    (fun i => (show AEMeasurable (fun x : ℝ => c i * (x ^ 2 - (v i : ℝ)))
      (gaussianReal 0 (v i)) by fun_prop))
  have h := hInd.mgf_sum (by fun_prop) Finset.univ (t := s)
  have hfun : (fun x : ι → ℝ => ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))) =
      ∑ i, (fun x : ι → ℝ => c i * ((x i) ^ 2 - (v i : ℝ))) := by
    ext x
    simp only [Finset.sum_apply]
  rw [hfun, h]
  apply Finset.prod_congr rfl
  intro i hi
  unfold mgf
  change (∫ x : ι → ℝ, Real.exp (s * (c i * ((x i) ^ 2 - (v i : ℝ))))
    ∂(Measure.pi fun i => gaussianReal 0 (v i))) = _
  rw [integral_comp_eval (μ := fun i => gaussianReal 0 (v i)) (i := i)
    (f := fun y : ℝ => Real.exp (s * (c i * (y ^ 2 - (v i : ℝ)))))
    (by fun_prop)]
  have hfun' : (fun y : ℝ => Real.exp (s * (c i * (y ^ 2 - (v i : ℝ))))) =
      fun y : ℝ => Real.exp ((s * c i) * (y ^ 2 - (v i : ℝ))) := by
    ext y
    congr 1
    ring
  rw [hfun']
  change mgf (fun y : ℝ => y ^ 2 - (v i : ℝ)) (gaussianReal 0 (v i)) (s * c i) = _
  rw [mgf_centered_square_gaussianReal (v i) (s * c i) (by simpa [mul_assoc] using hs i)]
  congr 2 <;> ring

theorem integrable_exp_sum_centered_gaussian_squares {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (s : ℝ)
    (hs : ∀ i, 0 < 1 - 2 * s * c i * (v i : ℝ)) :
    Integrable (fun x : ι → ℝ => Real.exp (s * ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))))
      (Measure.pi fun i => gaussianReal 0 (v i)) := by
  apply Integrable.of_integral_ne_zero
  change mgf (fun x : ι → ℝ => ∑ i, c i * ((x i) ^ 2 - (v i : ℝ)))
    (Measure.pi fun i => gaussianReal 0 (v i)) s ≠ 0
  rw [mgf_sum_centered_gaussian_squares v c s hs]
  apply Finset.prod_ne_zero_iff.2
  intro i hi
  exact div_ne_zero (Real.exp_ne_zero _) (Real.sqrt_pos.2 (hs i)).ne'

/-- Chernoff's bound with the exact product MGF, before any loss in constants. -/
theorem gaussian_quadratic_chernoff_exact {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (s u : ℝ) (hs0 : 0 ≤ s)
    (hs : ∀ i, 0 < 1 - 2 * s * c i * (v i : ℝ)) :
    (Measure.pi fun i => gaussianReal 0 (v i)).real
      {x : ι → ℝ | u ≤ ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))} ≤
      Real.exp (-s * u) * ∏ i, Real.exp (-s * c i * (v i : ℝ)) /
        Real.sqrt (1 - 2 * s * c i * (v i : ℝ)) := by
  have h := measure_ge_le_exp_mul_mgf u hs0
    (integrable_exp_sum_centered_gaussian_squares v c s hs)
  rwa [mgf_sum_centered_gaussian_squares v c s hs] at h

/-- A dimension-free quadratic bound on the diagonal quadratic-form MGF. -/
theorem mgf_sum_centered_gaussian_squares_le {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (s : ℝ)
    (hs : ∀ i, 2 * s * c i * (v i : ℝ) ≤ 1 / 2) :
    mgf (fun x : ι → ℝ => ∑ i, c i * ((x i) ^ 2 - (v i : ℝ)))
      (Measure.pi fun i => gaussianReal 0 (v i)) s ≤
      Real.exp (4 * s ^ 2 * ∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2) := by
  have hdomain (i : ι) : 0 < 1 - 2 * s * c i * (v i : ℝ) := by
    have hi := hs i
    linarith
  have hterm (i : ι) : Real.exp (-s * c i * (v i : ℝ)) /
      Real.sqrt (1 - 2 * s * c i * (v i : ℝ)) ≤
      Real.exp (4 * s ^ 2 * (c i) ^ 2 * (v i : ℝ) ^ 2) := by
    have hi := mgf_centered_square_le_exp (v i) (s * c i)
      (by simpa [mul_assoc] using hs i)
    rw [mgf_centered_square_gaussianReal (v i) (s * c i)
      (by simpa [mul_assoc] using hdomain i)] at hi
    simpa only [neg_mul, mul_assoc, mul_pow] using hi
  rw [mgf_sum_centered_gaussian_squares v c s hdomain]
  calc
    (∏ i, Real.exp (-s * c i * (v i : ℝ)) /
        Real.sqrt (1 - 2 * s * c i * (v i : ℝ))) ≤
        ∏ i, Real.exp (4 * s ^ 2 * (c i) ^ 2 * (v i : ℝ) ^ 2) := by
      apply Finset.prod_le_prod
      · intro i hi
        exact div_nonneg (Real.exp_pos _).le (Real.sqrt_nonneg _)
      · intro i hi
        exact hterm i
    _ = Real.exp (4 * s ^ 2 * ∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2) := by
      rw [← Real.exp_sum]
      congr 1
      simp only [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i hi
      ring

/-- A Chernoff estimate suitable for selecting a subgaussian or exponential
tail parameter.  No sign condition on the quadratic-form coefficients is needed. -/
theorem gaussian_quadratic_chernoff {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (s u : ℝ) (hs0 : 0 ≤ s)
    (hs : ∀ i, 2 * s * c i * (v i : ℝ) ≤ 1 / 2) :
    (Measure.pi fun i => gaussianReal 0 (v i)).real
      {x : ι → ℝ | u ≤ ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))} ≤
      Real.exp (4 * s ^ 2 * (∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2) - s * u) := by
  have hdomain (i : ι) : 0 < 1 - 2 * s * c i * (v i : ℝ) := by
    have hi := hs i
    linarith
  calc
    _ ≤ Real.exp (-s * u) * mgf
        (fun x : ι → ℝ => ∑ i, c i * ((x i) ^ 2 - (v i : ℝ)))
        (Measure.pi fun i => gaussianReal 0 (v i)) s :=
      measure_ge_le_exp_mul_mgf u hs0
        (integrable_exp_sum_centered_gaussian_squares v c s hdomain)
    _ ≤ Real.exp (-s * u) *
        Real.exp (4 * s ^ 2 * ∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2) :=
      mul_le_mul_of_nonneg_left (mgf_sum_centered_gaussian_squares_le v c s hs)
        (Real.exp_pos _).le
    _ = _ := by rw [← Real.exp_add]; congr 1; ring

/-- Elementary optimization of the capped quadratic Chernoff exponent. -/
theorem quadratic_chernoff_parameter_bound (B V u : ℝ)
    (hB : 0 < B) (hV : 0 < V) :
    4 * (min (u / (8 * V)) (1 / (8 * B))) ^ 2 * V -
        (min (u / (8 * V)) (1 / (8 * B))) * u ≤
      -min (u ^ 2 / (16 * V)) (u / (16 * B)) := by
  rcases le_total (u / (8 * V)) (1 / (8 * B)) with hsmall | hlarge
  · rw [min_eq_left hsmall]
    have heq : 4 * (u / (8 * V)) ^ 2 * V - (u / (8 * V)) * u =
        -(u ^ 2 / (16 * V)) := by
      field_simp
      ring
    rw [heq]
    exact neg_le_neg (min_le_left _ _)
  · rw [min_eq_right hlarge]
    have hcross : V ≤ u * B := by
      have hmul := (div_le_div_iff₀ (by positivity : 0 < 8 * B)
        (by positivity : 0 < 8 * V)).1 hlarge
      nlinarith
    have heq : 4 * (1 / (8 * B)) ^ 2 * V - (1 / (8 * B)) * u =
        (V - 2 * u * B) / (16 * B ^ 2) := by
      field_simp
      ring
    have hcancel : -(u / (16 * B)) * (16 * B ^ 2) = -u * B := by
      field_simp
    calc
      _ = (V - 2 * u * B) / (16 * B ^ 2) := heq
      _ ≤ -(u / (16 * B)) := by
        apply (div_le_iff₀ (by positivity : 0 < 16 * B ^ 2)).2
        rw [hcancel]
        linarith
      _ ≤ -min (u ^ 2 / (16 * V)) (u / (16 * B)) := neg_le_neg (min_le_right _ _)

/-- A Bernstein-form upper tail for any signed diagonal Gaussian quadratic form.
`V` bounds the sum of squared weighted variances and `B` bounds each one. -/
theorem gaussian_quadratic_upper_tail {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (B V u : ℝ)
    (hB : 0 < B) (hV : 0 < V) (hu : 0 ≤ u)
    (hcoeff : ∀ i, |c i * (v i : ℝ)| ≤ B)
    (henergy : (∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2) ≤ V) :
    (Measure.pi fun i => gaussianReal 0 (v i)).real
      {x : ι → ℝ | u ≤ ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))} ≤
      Real.exp (-min (u ^ 2 / (16 * V)) (u / (16 * B))) := by
  let s := min (u / (8 * V)) (1 / (8 * B))
  have hs0 : 0 ≤ s := le_min (div_nonneg hu (by positivity)) (by positivity)
  have hsB : s * (8 * B) ≤ 1 :=
    (le_div_iff₀ (by positivity : 0 < 8 * B)).1 (min_le_right _ _)
  have hparam (i : ι) : 2 * s * c i * (v i : ℝ) ≤ 1 / 2 := by
    have hc : c i * (v i : ℝ) ≤ B := (abs_le.mp (hcoeff i)).2
    have hmul := mul_le_mul_of_nonneg_left hc (show 0 ≤ 2 * s by positivity)
    nlinarith
  calc
    _ ≤ Real.exp (4 * s ^ 2 * (∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2) - s * u) :=
      gaussian_quadratic_chernoff v c s u hs0 hparam
    _ ≤ Real.exp (4 * s ^ 2 * V - s * u) := by
      apply Real.exp_le_exp.2
      exact sub_le_sub_right (mul_le_mul_of_nonneg_left henergy (by positivity)) _
    _ ≤ _ := Real.exp_le_exp.2 (quadratic_chernoff_parameter_bound B V u hB hV)

/-- Two-sided Gaussian quadratic-form tail, with explicit numerical constants. -/
theorem gaussian_quadratic_abs_tail {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (B V u : ℝ)
    (hB : 0 < B) (hV : 0 < V) (hu : 0 ≤ u)
    (hcoeff : ∀ i, |c i * (v i : ℝ)| ≤ B)
    (henergy : (∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2) ≤ V) :
    (Measure.pi fun i => gaussianReal 0 (v i)).real
      {x : ι → ℝ | u ≤ |∑ i, c i * ((x i) ^ 2 - (v i : ℝ))|} ≤
      2 * Real.exp (-min (u ^ 2 / (16 * V)) (u / (16 * B))) := by
  have hplus := gaussian_quadratic_upper_tail v c B V u hB hV hu hcoeff henergy
  have hminus := gaussian_quadratic_upper_tail v (fun i => -c i) B V u hB hV hu
    (by intro i; simpa only [neg_mul, abs_neg] using hcoeff i)
    (by simpa only [neg_sq] using henergy)
  simp only [neg_mul, Finset.sum_neg_distrib] at hminus
  have hsubset :
      {x : ι → ℝ | u ≤ |∑ i, c i * ((x i) ^ 2 - (v i : ℝ))|} ⊆
      {x : ι → ℝ | u ≤ ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))} ∪
      {x : ι → ℝ | u ≤ -(∑ i, c i * ((x i) ^ 2 - (v i : ℝ)))} := by
    intro x hx
    by_cases hsign : 0 ≤ ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))
    · left
      simpa only [Set.mem_setOf_eq, abs_of_nonneg hsign] using hx
    · right
      simpa only [Set.mem_setOf_eq, abs_of_nonpos (le_of_lt (lt_of_not_ge hsign))] using hx
  calc
    _ ≤ (Measure.pi fun i => gaussianReal 0 (v i)).real
        ({x : ι → ℝ | u ≤ ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))} ∪
        {x : ι → ℝ | u ≤ -(∑ i, c i * ((x i) ^ 2 - (v i : ℝ)))}) :=
      measureReal_mono hsubset
    _ ≤ (Measure.pi fun i => gaussianReal 0 (v i)).real
        {x : ι → ℝ | u ≤ ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))} +
        (Measure.pi fun i => gaussianReal 0 (v i)).real
        {x : ι → ℝ | u ≤ -(∑ i, c i * ((x i) ^ 2 - (v i : ℝ)))} :=
      measureReal_union_le _ _
    _ ≤ _ := by linarith

end Paulsen
