import Paulsen.GaussianPolynomial
import Mathlib.Algebra.MvPolynomial.PDeriv
import Mathlib.MeasureTheory.Integral.Pi

/-!
# Polynomial integration by parts for independent standard Gaussians
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

variable {τ : Type*} [Fintype τ] [DecidableEq τ]

omit [DecidableEq τ] in
theorem eval_monomial_fintype (s : τ →₀ ℕ) (a : ℝ) (x : τ → ℝ) :
    MvPolynomial.eval x (MvPolynomial.monomial s a) = a * ∏ i, x i ^ s i := by
  rw [MvPolynomial.eval_monomial, Finsupp.prod_fintype _ _ (fun _ => pow_zero _)]

omit [DecidableEq τ] in
theorem integrable_mvPolynomial_stdGaussian_real (p : MvPolynomial τ ℝ) :
    Integrable (fun x : τ → ℝ => MvPolynomial.eval x p)
      (Measure.pi fun _ : τ => gaussianReal 0 1) := by
  induction p using MvPolynomial.induction_on' with
  | add p q hp hq => simpa only [map_add, Pi.add_apply] using! hp.add hq
  | monomial s a =>
    have hint (i : τ) := integrable_pow_of_mem_interior_integrableExpSet
      (X := id) (μ := gaussianReal 0 1) (by simp) (s i)
    simpa only [eval_monomial_fintype, id_eq] using (Integrable.fintype_prod hint).const_mul a

omit [DecidableEq τ] in
theorem integral_monomial_stdGaussian_real (s : τ →₀ ℕ) (a : ℝ) :
    (∫ x : τ → ℝ, MvPolynomial.eval x (MvPolynomial.monomial s a)
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) =
      a * ∏ i, ∫ y : ℝ, y ^ s i ∂gaussianReal 0 1 := by
  simp_rw [eval_monomial_fintype]
  rw [integral_const_mul, integral_fintype_prod_eq_prod
    (μ := fun _ : τ => gaussianReal 0 1) (fun i (y : ℝ) => y ^ s i)]

/-- Independent-coordinate Gaussian integration by parts for every multivariate
polynomial. The coordinate independence comes from the product measure. -/
theorem integral_mul_mvPolynomial_stdGaussian_real (p : MvPolynomial τ ℝ) (j : τ) :
    (∫ x : τ → ℝ, x j * MvPolynomial.eval x p
      ∂(Measure.pi fun _ : τ => gaussianReal 0 1)) =
      ∫ x : τ → ℝ, MvPolynomial.eval x (MvPolynomial.pderiv j p)
        ∂(Measure.pi fun _ : τ => gaussianReal 0 1) := by
  induction p using MvPolynomial.induction_on' with
  | add p q hp hq =>
    have hip : Integrable (fun x : τ → ℝ => x j * MvPolynomial.eval x p)
        (Measure.pi fun _ : τ => gaussianReal 0 1) := by
      convert! integrable_mvPolynomial_stdGaussian_real (MvPolynomial.X j * p) using 1
      ext x
      simp
    have hiq : Integrable (fun x : τ → ℝ => x j * MvPolynomial.eval x q)
        (Measure.pi fun _ : τ => gaussianReal 0 1) := by
      convert! integrable_mvPolynomial_stdGaussian_real (MvPolynomial.X j * q) using 1
      ext x
      simp
    simp only [map_add, mul_add]
    rw [integral_add hip hiq, integral_add
      (integrable_mvPolynomial_stdGaussian_real (MvPolynomial.pderiv j p))
      (integrable_mvPolynomial_stdGaussian_real (MvPolynomial.pderiv j q)), hp, hq]
  | monomial s a =>
    have hfun : (fun x : τ → ℝ => x j * MvPolynomial.eval x (MvPolynomial.monomial s a)) =
        fun x => MvPolynomial.eval x (MvPolynomial.monomial (s + Finsupp.single j 1) a) := by
      ext x
      rw [← MvPolynomial.eval_X (f := x) j, ← map_mul,
        MvPolynomial.X, MvPolynomial.monomial_mul]
      simp only [one_mul, add_comm]
    rw [hfun, MvPolynomial.pderiv_monomial, integral_monomial_stdGaussian_real,
      integral_monomial_stdGaussian_real]
    rw [← Finset.prod_erase_mul (s := Finset.univ) (a := j) _ (Finset.mem_univ j),
      ← Finset.prod_erase_mul (s := Finset.univ) (a := j)
        (fun i : τ => ∫ y : ℝ, y ^ (s - Finsupp.single j 1 : τ →₀ ℕ) i ∂gaussianReal 0 1)
        (Finset.mem_univ j)]
    have hother : (∏ i ∈ Finset.univ.erase j,
        ∫ y : ℝ, y ^ (s + Finsupp.single j 1 : τ →₀ ℕ) i ∂gaussianReal 0 1) =
        ∏ i ∈ Finset.univ.erase j,
          ∫ y : ℝ, y ^ (s - Finsupp.single j 1 : τ →₀ ℕ) i ∂gaussianReal 0 1 := by
      apply Finset.prod_congr rfl
      intro i hi
      have hij : i ≠ j := (Finset.mem_erase.mp hi).1
      simp [hij]
    rw [hother]
    simp only [Finsupp.add_apply, Finsupp.coe_tsub, Pi.sub_apply,
      Finsupp.single_eq_same, integral_pow_succ_stdGaussian_real]
    ring

end Paulsen
