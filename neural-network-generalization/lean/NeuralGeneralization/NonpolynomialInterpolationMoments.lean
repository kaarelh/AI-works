import NeuralGeneralization.NonpolynomialInterpolationPolynomial
import Mathlib.LinearAlgebra.Lagrange

/-! Distinct finite nodes have a nonzero moment against any nonzero coefficient
vector. Differentiating a smooth affine-translate relation isolates that moment. -/
noncomputable section
open scoped BigOperators ContDiff
namespace NeuralGeneralization.NonpolynomialInterpolation
variable {ι : Type*} [Fintype ι]

/-- A nonzero signed measure on distinct finite nodes has a nonzero monomial moment. -/
theorem exists_nonzero_moment {t c : ι → ℝ} (ht : Function.Injective t) (hc : c ≠ 0) :
    ∃ k : ℕ, ∑ i, c i * t i ^ k ≠ 0 := by
  classical
  by_contra! hz
  have hp (p : Polynomial ℝ) : ∑ i, c i * p.eval (t i) = 0 := by
    simp_rw [Polynomial.eval_eq_sum, Polynomial.sum, Finset.mul_sum]
    rw [Finset.sum_comm]
    apply Finset.sum_eq_zero
    intro k _
    calc
      ∑ i, c i * (p.coeff k * t i ^ k) = p.coeff k * ∑ i, c i * t i ^ k := by
        rw [Finset.mul_sum]
        apply Finset.sum_congr rfl
        intro i _
        ring
      _ = 0 := by rw [hz, mul_zero]
  apply hc
  funext i
  have hi := hp (Lagrange.basis Finset.univ t i)
  have he : ∑ j, c j * (Lagrange.basis Finset.univ t i).eval (t j) = c i := by
    rw [Finset.sum_eq_single i]
    · simp [Lagrange.eval_basis_self ht.injOn]
    · intro j _ hji
      rw [Lagrange.eval_basis_of_ne (Ne.symm hji) (Finset.mem_univ j), mul_zero]
    · simp
  simpa only [he, Pi.zero_apply] using hi

/-- The derivative in the scaling parameter of an affine translate. -/
theorem iteratedDeriv_affine_scale {f : ℝ → ℝ} (hf : ContDiff ℝ ∞ f)
    (k : ℕ) (t b : ℝ) :
    iteratedDeriv k (fun s => f (s * t + b)) 0 = t ^ k * iteratedDeriv k f b := by
  have hshift : ContDiff ℝ (k : ℕ) (fun x => f (x + b)) :=
    (contDiff_infty.mp hf k).comp (contDiff_id.add contDiff_const)
  have he := congrFun (iteratedDeriv_comp_const_mul hshift t) 0
  simpa only [mul_comm, mul_zero, zero_mul, iteratedDeriv_comp_add_const,
    zero_add] using he

/-- If every affine translate of a smooth function satisfies one nontrivial
finite relation, a derivative of the function vanishes globally. -/
theorem smooth_relation_powerSpan {f : ℝ → ℝ} (hf : ContDiff ℝ ∞ f)
    {t c : ι → ℝ} {k : ℕ} (hk : ∑ i, c i * t i ^ k ≠ 0)
    (hrel : ∀ s b, ∑ i, c i * f (s * t i + b) = 0) : f ∈ powerSpan k := by
  apply mem_powerSpan_of_iteratedDeriv_zero hf
  intro b
  have hz : (fun s : ℝ => ∑ i, c i * f (s * t i + b)) = 0 := funext (fun s => hrel s b)
  have hcd (i : ι) : ContDiffAt ℝ (k : ℕ) (fun s : ℝ => c i * f (s * t i + b)) 0 := by
    exact (contDiff_const.mul ((contDiff_infty.mp hf k).comp
      ((contDiff_id.mul contDiff_const).add contDiff_const))).contDiffAt
  have he := congrArg (fun g : ℝ → ℝ => iteratedDeriv k g 0) hz
  rw [iteratedDeriv_fun_sum (fun i _ => hcd i)] at he
  simp only [iteratedDeriv_const_mul_field, iteratedDeriv_affine_scale hf,
    Pi.zero_def, iteratedDeriv_const, ite_self] at he
  have hp : (∑ i, c i * t i ^ k) * iteratedDeriv k f b = 0 := by
    simpa only [Finset.sum_mul, mul_assoc] using he
  exact (mul_eq_zero.mp hp).resolve_left hk

end NeuralGeneralization.NonpolynomialInterpolation
