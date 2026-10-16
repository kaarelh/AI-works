import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.Probability.Independence.Basic
import Mathlib.Tactic.FunProp
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Linear forms in an actual independent Gaussian product

The exact moment formula and its Chernoff bound are proved for the product
Gaussian law. Together with finite Hilbert-space nets these supply the free
matrix operator norm estimate needed by the cloning cylinder construction.
-/

noncomputable section

open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.GaussianTail

theorem mgf_gaussian_linear_form {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (s : ℝ) :
    mgf (fun x : ι → ℝ => ∑ i, c i * x i)
      (Measure.pi fun i => gaussianReal 0 (v i)) s =
      Real.exp (s ^ 2 * (∑ i, c i ^ 2 * (v i : ℝ)) / 2) := by
  have hInd := iIndepFun_pi (μ := fun i => gaussianReal 0 (v i))
    (fun i => (show AEMeasurable (fun x : ℝ => c i * x)
      (gaussianReal 0 (v i)) by fun_prop))
  have h := hInd.mgf_sum (by fun_prop) Finset.univ (t := s)
  have hfun : (fun x : ι → ℝ => ∑ i, c i * x i) =
      ∑ i, (fun x : ι → ℝ => c i * x i) := by
    ext x
    simp only [Finset.sum_apply]
  rw [hfun, h]
  have hi (i : ι) : mgf (fun x : ι → ℝ => c i * x i)
      (Measure.pi fun i => gaussianReal 0 (v i)) s =
      Real.exp (s ^ 2 * (c i ^ 2 * (v i : ℝ)) / 2) := by
    unfold mgf
    rw [integral_comp_eval (μ := fun i => gaussianReal 0 (v i)) (i := i)
      (f := fun y : ℝ => Real.exp (s * (c i * y))) (by fun_prop)]
    have hid : (fun y : ℝ => Real.exp (s * (c i * y))) =
        fun y : ℝ => Real.exp ((s * c i) * y) := by
      ext y
      congr 1
      ring
    rw [hid]
    change mgf (fun y : ℝ => y) (gaussianReal 0 (v i)) (s * c i) = _
    rw [mgf_fun_id_gaussianReal]
    congr 1
    ring
  simp_rw [hi]
  rw [← Real.exp_sum]
  congr 1
  rw [Finset.mul_sum, Finset.sum_div]

theorem integrable_exp_gaussian_linear_form {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (s : ℝ) :
    Integrable (fun x : ι → ℝ => Real.exp (s * ∑ i, c i * x i))
      (Measure.pi fun i => gaussianReal 0 (v i)) := by
  apply Integrable.of_integral_ne_zero
  change mgf (fun x : ι → ℝ => ∑ i, c i * x i)
    (Measure.pi fun i => gaussianReal 0 (v i)) s ≠ 0
  rw [mgf_gaussian_linear_form]
  exact Real.exp_ne_zero _

/-- A variance upper bound, rather than equality, also covers zero-variance
linear forms without a separate degenerate-distribution argument. -/
theorem gaussian_linear_form_upper_tail {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (V u : ℝ) (hV : 0 < V) (hu : 0 ≤ u)
    (hvar : (∑ i, c i ^ 2 * (v i : ℝ)) ≤ V) :
    (Measure.pi fun i => gaussianReal 0 (v i)).real
      {x : ι → ℝ | u ≤ ∑ i, c i * x i} ≤ Real.exp (-u ^ 2 / (2 * V)) := by
  have h := measure_ge_le_exp_mul_mgf u (div_nonneg hu hV.le)
    (integrable_exp_gaussian_linear_form v c (u / V))
  rw [mgf_gaussian_linear_form, ← Real.exp_add] at h
  refine h.trans (Real.exp_le_exp.mpr ?_)
  calc
    _ ≤ -(u / V) * u + (u / V) ^ 2 * V / 2 := by
      have hh := mul_le_mul_of_nonneg_left hvar (sq_nonneg (u / V))
      linarith
    _ = _ := by field_simp; ring

theorem gaussian_linear_form_abs_tail {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) (V u : ℝ) (hV : 0 < V) (hu : 0 ≤ u)
    (hvar : (∑ i, c i ^ 2 * (v i : ℝ)) ≤ V) :
    (Measure.pi fun i => gaussianReal 0 (v i)).real
      {x : ι → ℝ | u ≤ |∑ i, c i * x i|} ≤
      2 * Real.exp (-u ^ 2 / (2 * V)) := by
  have hplus := gaussian_linear_form_upper_tail v c V u hV hu hvar
  have hminus := gaussian_linear_form_upper_tail v (fun i => -c i) V u hV hu
    (by simpa only [neg_sq] using hvar)
  simp only [neg_mul, Finset.sum_neg_distrib] at hminus
  have hsubset :
      {x : ι → ℝ | u ≤ |∑ i, c i * x i|} ⊆
      {x : ι → ℝ | u ≤ ∑ i, c i * x i} ∪
      {x : ι → ℝ | u ≤ -(∑ i, c i * x i)} := by
    intro x hx
    rcases le_total 0 (∑ i, c i * x i) with hs | hs
    · exact Or.inl (by simpa only [Set.mem_setOf_eq, abs_of_nonneg hs] using hx)
    · exact Or.inr (by simpa only [Set.mem_setOf_eq, abs_of_nonpos hs] using hx)
  calc
    _ ≤ (Measure.pi fun i => gaussianReal 0 (v i)).real
        ({x : ι → ℝ | u ≤ ∑ i, c i * x i} ∪
        {x : ι → ℝ | u ≤ -(∑ i, c i * x i)}) := measureReal_mono hsubset
    _ ≤ (Measure.pi fun i => gaussianReal 0 (v i)).real
        {x : ι → ℝ | u ≤ ∑ i, c i * x i} +
        (Measure.pi fun i => gaussianReal 0 (v i)).real
        {x : ι → ℝ | u ≤ -(∑ i, c i * x i)} := measureReal_union_le _ _
    _ ≤ _ := by linarith

end NeuralGeneralization.GaussianTail
