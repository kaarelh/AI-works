import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.Probability.Moments.MGFAnalytic
import Mathlib.Probability.Moments.Variance
import Mathlib.Probability.HasLaw
import Mathlib.MeasureTheory.Function.L2Space
import Mathlib.Tactic.Ring

/-!
# Fourth moments of centered real Gaussians

The fourth moment is obtained by differentiating the Gaussian moment-generating
function.  No fourth-moment or Gaussian quadratic-form identity is assumed.
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

/-- Four derivatives of the centered Gaussian moment-generating function. -/
theorem iteratedDeriv_four_gaussian_mgf (v : ℝ) :
    iteratedDeriv 4 (fun t : ℝ => Real.exp (v * t ^ 2 / 2)) 0 = 3 * v ^ 2 := by
  have h0 (t : ℝ) : HasDerivAt (fun s : ℝ => Real.exp (v * s ^ 2 / 2))
      (v * t * Real.exp (v * t ^ 2 / 2)) t := by
    convert! ((((hasDerivAt_id' t).pow 2).const_mul v).div_const 2).exp using 1
    simp only [Pi.pow_apply]
    ring
  have h1 (t : ℝ) : HasDerivAt (fun s : ℝ => v * s * Real.exp (v * s ^ 2 / 2))
      ((v + v ^ 2 * t ^ 2) * Real.exp (v * t ^ 2 / 2)) t := by
    convert! ((hasDerivAt_id' t).const_mul v).mul (h0 t) using 1
    ring
  have h2 (t : ℝ) : HasDerivAt
      (fun s : ℝ => (v + v ^ 2 * s ^ 2) * Real.exp (v * s ^ 2 / 2))
      ((3 * v ^ 2 * t + v ^ 3 * t ^ 3) * Real.exp (v * t ^ 2 / 2)) t := by
    have hp := (hasDerivAt_const t v).add (((hasDerivAt_id' t).pow 2).const_mul (v ^ 2))
    convert! hp.mul (h0 t) using 1
    simp only [Pi.pow_apply, Pi.add_apply]
    ring
  have h3 : HasDerivAt
      (fun s : ℝ => (3 * v ^ 2 * s + v ^ 3 * s ^ 3) * Real.exp (v * s ^ 2 / 2))
      (3 * v ^ 2) 0 := by
    have hp := ((hasDerivAt_id' (0 : ℝ)).const_mul (3 * v ^ 2)).add
      (((hasDerivAt_id' (0 : ℝ)).pow 3).const_mul (v ^ 3))
    convert! hp.mul (h0 0) using 1
    simp [Pi.pow_apply, Pi.add_apply]
  have hd0 := funext fun t => (h0 t).deriv
  have hd1 := funext fun t => (h1 t).deriv
  have hd2 := funext fun t => (h2 t).deriv
  simp only [iteratedDeriv_succ, iteratedDeriv_zero, hd0, hd1, hd2]
  exact h3.deriv

/-- The centered fourth moment includes the degenerate zero-variance Gaussian. -/
theorem integral_pow_four_gaussianReal (v : ℝ≥0) :
    (∫ x : ℝ, x ^ 4 ∂gaussianReal 0 v) = 3 * (v : ℝ) ^ 2 := by
  have h := iteratedDeriv_mgf_zero
    (X := id) (μ := gaussianReal 0 v) (by simp) 4
  rw [mgf_id_gaussianReal] at h
  simp only [zero_mul, zero_add, Pi.pow_apply, id_eq] at h
  rw [← h]
  exact iteratedDeriv_four_gaussian_mgf v

theorem integral_pow_two_gaussianReal (v : ℝ≥0) :
    (∫ x : ℝ, x ^ 2 ∂gaussianReal 0 v) = (v : ℝ) := by
  have h := variance_of_integral_eq_zero (X := fun x : ℝ => x)
    (μ := gaussianReal 0 v) aemeasurable_id (by simp)
  simpa using h.symm.trans variance_fun_id_gaussianReal

theorem memLp_square_gaussianReal (v : ℝ≥0) :
    MemLp (fun x : ℝ => x ^ 2) 2 (gaussianReal 0 v) := by
  apply (memLp_two_iff_integrable_sq (by fun_prop)).2
  have h := integrable_pow_of_mem_interior_integrableExpSet
    (X := id) (μ := gaussianReal 0 v) (by simp) 4
  simpa only [id_eq, ← pow_mul] using h

/-- The variance of a Gaussian square is twice the square of its variance. -/
theorem variance_square_gaussianReal (v : ℝ≥0) :
    variance (fun x : ℝ => x ^ 2) (gaussianReal 0 v) = 2 * (v : ℝ) ^ 2 := by
  rw [variance_eq_sub (memLp_square_gaussianReal v)]
  simp only [Pi.pow_apply, ← pow_mul]
  rw [integral_pow_four_gaussianReal, integral_pow_two_gaussianReal]
  ring

theorem integral_pow_four_of_hasLaw {Ω : Type*} [MeasurableSpace Ω]
    {P : Measure Ω} {X : Ω → ℝ} {v : ℝ≥0}
    (hX : HasLaw X (gaussianReal 0 v) P) :
    (∫ ω, (X ω) ^ 4 ∂P) = 3 * (v : ℝ) ^ 2 := by
  calc
    (∫ ω, (X ω) ^ 4 ∂P) = ∫ x : ℝ, x ^ 4 ∂gaussianReal 0 v := by
      exact hX.integral_comp (f := fun x : ℝ => x ^ 4) (by fun_prop)
    _ = _ := integral_pow_four_gaussianReal v

theorem memLp_square_of_hasLaw {Ω : Type*} [MeasurableSpace Ω]
    {P : Measure Ω} {X : Ω → ℝ} {v : ℝ≥0}
    (hX : HasLaw X (gaussianReal 0 v) P) :
    MemLp (fun ω => (X ω) ^ 2) 2 P := by
  have hm : MemLp (fun x : ℝ => x ^ 2) 2 (P.map X) := by
    rw [hX.map_eq]
    exact memLp_square_gaussianReal v
  exact hm.comp_of_map hX.aemeasurable

theorem variance_square_of_hasLaw {Ω : Type*} [MeasurableSpace Ω]
    {P : Measure Ω} {X : Ω → ℝ} {v : ℝ≥0}
    (hX : HasLaw X (gaussianReal 0 v) P) :
    variance (fun ω => (X ω) ^ 2) P = 2 * (v : ℝ) ^ 2 := by
  have h := variance_map (X := fun x : ℝ => x ^ 2) (Y := X)
    (by fun_prop) hX.aemeasurable
  rw [hX.map_eq] at h
  exact h.symm.trans (variance_square_gaussianReal v)

/-- Independent Gaussian squares: the diagonal quadratic-form variance. -/
theorem variance_sum_centered_gaussian_squares {ι : Type*} [Fintype ι]
    (v : ι → ℝ≥0) (c : ι → ℝ) :
    variance (fun x : ι → ℝ => ∑ i, c i * ((x i) ^ 2 - (v i : ℝ)))
      (Measure.pi fun i => gaussianReal 0 (v i)) =
      2 * ∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2 := by
  have hm (i : ι) : MemLp (fun x : ℝ => c i * (x ^ 2 - (v i : ℝ))) 2
      (gaussianReal 0 (v i)) :=
    ((memLp_square_gaussianReal (v i)).sub (memLp_const (v i : ℝ))).const_mul (c i)
  have h := variance_sum_pi (μ := fun i => gaussianReal 0 (v i)) hm
  have hfun : (fun x : ι → ℝ => ∑ i, c i * ((x i) ^ 2 - (v i : ℝ))) =
      ∑ i, (fun x : ι → ℝ => c i * ((x i) ^ 2 - (v i : ℝ))) := by
    ext x
    simp only [Finset.sum_apply]
  rw [hfun, h, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  rw [variance_const_mul, variance_sub_const (by fun_prop), variance_square_gaussianReal]
  ring

/-- The same diagonal quadratic-form identity on any probability space carrying
independent centered Gaussian variables. -/
theorem variance_sum_centered_gaussian_squares_of_indep
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    {P : Measure Ω} [IsProbabilityMeasure P]
    (X : ι → Ω → ℝ) (v : ι → ℝ≥0) (c : ι → ℝ)
    (hLaw : ∀ i, HasLaw (X i) (gaussianReal 0 (v i)) P)
    (hIndep : iIndepFun X P) :
    variance (fun ω => ∑ i, c i * ((X i ω) ^ 2 - (v i : ℝ))) P =
      2 * ∑ i, (c i) ^ 2 * (v i : ℝ) ^ 2 := by
  have hm (i : ι) : MemLp (fun ω => c i * ((X i ω) ^ 2 - (v i : ℝ))) 2 P :=
    ((memLp_square_of_hasLaw (hLaw i)).sub (memLp_const (v i : ℝ))).const_mul (c i)
  have hpair : Set.Pairwise (↑(Finset.univ : Finset ι))
      (fun i j => IndepFun (fun ω => c i * ((X i ω) ^ 2 - (v i : ℝ)))
        (fun ω => c j * ((X j ω) ^ 2 - (v j : ℝ))) P) := by
    intro i hi j hj hij
    exact (hIndep.indepFun hij).comp
      (show Measurable (fun x : ℝ => c i * (x ^ 2 - (v i : ℝ))) by fun_prop)
      (show Measurable (fun x : ℝ => c j * (x ^ 2 - (v j : ℝ))) by fun_prop)
  have h := IndepFun.variance_sum (fun i (_ : i ∈ (Finset.univ : Finset ι)) => hm i) hpair
  have hfun : (fun ω => ∑ i, c i * ((X i ω) ^ 2 - (v i : ℝ))) =
      ∑ i, (fun ω => c i * ((X i ω) ^ 2 - (v i : ℝ))) := by
    ext ω
    simp only [Finset.sum_apply]
  rw [hfun, h, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i hi
  rw [variance_const_mul,
    variance_sub_const (memLp_square_of_hasLaw (hLaw i)).aestronglyMeasurable,
    variance_square_of_hasLaw (hLaw i)]
  ring

end Paulsen
