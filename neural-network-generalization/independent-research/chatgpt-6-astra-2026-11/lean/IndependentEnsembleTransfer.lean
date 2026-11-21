import Mathlib

/-! Selected deterministic steps of the ensemble-transfer argument.
This file does not formalize the random convex-balancing probability,
posterior energy bound, or downstream statistical generalization.
-/

namespace IndependentResearch

open scoped BigOperators

theorem capped_weights_sum_sq_le {ι : Type*} [Fintype ι]
    (β : ι → ℝ) (cap : ℝ)
    (hβ : ∀ i, 0 ≤ β i) (hcap : ∀ i, β i ≤ cap)
    (hsum : ∑ i, β i = 1) : ∑ i, (β i) ^ 2 ≤ cap := by
  calc
    ∑ i, (β i) ^ 2 ≤ ∑ i, cap * β i := by
      apply Finset.sum_le_sum
      intro i hi
      nlinarith [hβ i, hcap i]
    _ = cap := by rw [← Finset.mul_sum, hsum, mul_one]

theorem capped_weighted_cost_le {ι : Type*} [Fintype ι]
    (β cost : ι → ℝ) (cap B : ℝ)
    (hβ : ∀ i, 0 ≤ β i) (hcap : ∀ i, β i ≤ cap)
    (hsum : ∑ i, β i = 1) (hcost : ∀ i, cost i ≤ B ^ 2) :
    ∑ i, (β i) ^ 2 * cost i ≤ cap * B ^ 2 := by
  calc
    ∑ i, (β i) ^ 2 * cost i ≤ ∑ i, (β i) ^ 2 * B ^ 2 := by
      exact Finset.sum_le_sum (fun i _ => mul_le_mul_of_nonneg_left (hcost i) (sq_nonneg _))
    _ = (∑ i, (β i) ^ 2) * B ^ 2 := by rw [Finset.sum_mul]
    _ ≤ cap * B ^ 2 := mul_le_mul_of_nonneg_right
      (capped_weights_sum_sq_le β cap hβ hcap hsum) (sq_nonneg B)

theorem ensemble_cost_factor_four {ι : Type*} [Fintype ι]
    (β cost : ι → ℝ) (L B : ℝ) (hL : 0 < L)
    (hβ : ∀ i, 0 ≤ β i) (hcap : ∀ i, β i ≤ 4 / L)
    (hsum : ∑ i, β i = 1) (hcost : ∀ i, cost i ≤ B ^ 2) :
    L * (∑ i, (β i) ^ 2 * cost i) ≤ 4 * B ^ 2 := by
  have h := mul_le_mul_of_nonneg_left
    (capped_weighted_cost_le β cost (4 / L) B hβ hcap hsum hcost) hL.le
  have heq : L * ((4 / L) * B ^ 2) = 4 * B ^ 2 := by
    field_simp
  simpa only [heq] using h

theorem convex_combination_error_bound {ι V : Type*} [Fintype ι]
    [NormedAddCommGroup V] [NormedSpace ℝ V]
    (β : ι → ℝ) (e : ι → V) (Δ : ℝ)
    (hβ : ∀ i, 0 ≤ β i) (hsum : ∑ i, β i = 1)
    (he : ∀ i, ‖e i‖ ≤ Δ) : ‖∑ i, β i • e i‖ ≤ Δ := by
  calc
    ‖∑ i, β i • e i‖ ≤ ∑ i, ‖β i • e i‖ := norm_sum_le _ _
    _ = ∑ i, β i * ‖e i‖ := by
      apply Finset.sum_congr rfl
      intro i hi
      rw [norm_smul, Real.norm_eq_abs, abs_of_nonneg (hβ i)]
    _ ≤ ∑ i, β i * Δ := Finset.sum_le_sum
      (fun i _ => mul_le_mul_of_nonneg_left (he i) (hβ i))
    _ = Δ := by rw [← Finset.sum_mul, hsum, one_mul]

theorem balanced_comparators_cancel {ι V : Type*} [Fintype ι]
    [AddCommGroup V] [Module ℝ V]
    (β : ι → ℝ) (q ell e : ι → V) (f : V)
    (hq : ∀ i, q i = f + ell i + e i)
    (hsum : ∑ i, β i = 1) (hbalance : ∑ i, β i • ell i = 0) :
    (∑ i, β i • q i) - f = ∑ i, β i • e i := by
  simp_rw [hq, smul_add]
  rw [Finset.sum_add_distrib, Finset.sum_add_distrib,
    ← Finset.sum_smul, hsum, one_smul, hbalance, add_zero]
  abel


/-- Averaging an even target plus odd contamination with its reflected copy
cancels that contamination pointwise. -/
theorem antithetic_comparator_identity {X : Type*}
    (J : X → X) (q f ell e : X → ℝ)
    (hq : ∀ x, q x = f x + ell x + e x)
    (hf : ∀ x, f (J x) = f x)
    (hell : ∀ x, ell (J x) = -ell x) (x : X) :
    (q x + q (J x)) / 2 - f x = (e x + e (J x)) / 2 := by
  rw [hq x, hq (J x), hf x, hell x]
  ring

/-- The scalar square is contracted by two-point averaging. -/
theorem antithetic_square_bound (a b : ℝ) :
    ((a+b)/2)^2 ≤ (a^2+b^2)/2 := by
  nlinarith [sq_nonneg (a-b)]

/-- Averaging with any permutation contracts the finite squared-error sum.
Involution and target symmetry enter only the preceding cancellation identity. -/
theorem antithetic_finite_error_contraction {ι : Type*} [Fintype ι]
    (J : Equiv.Perm ι) (e : ι → ℝ) :
    ∑ x, ((e x + e (J x))/2)^2 ≤ ∑ x, (e x)^2 := by
  calc
    ∑ x, ((e x + e (J x))/2)^2 ≤ ∑ x, ((e x)^2 + (e (J x))^2)/2 :=
      Finset.sum_le_sum (fun x _ => antithetic_square_bound _ _)
    _ = ((∑ x, (e x)^2) + ∑ x, (e (J x))^2)/2 := by
      rw [← Finset.sum_div, Finset.sum_add_distrib]
    _ = ∑ x, (e x)^2 := by
      have hsum : (∑ x, (e (J x))^2) = ∑ x, (e x)^2 :=
        Equiv.sum_comp J (fun x => (e x)^2)
      rw [hsum]
      ring

/-- The averaged direct-sum kernel incurs no squared-norm increase when
both component comparators obey the same bound. -/
theorem antithetic_direct_sum_cost (c1 c2 B : ℝ)
    (h1 : c1 ≤ B^2) (h2 : c2 ≤ B^2) :
    2 * ((1/2 : ℝ)^2*c1 + (1/2 : ℝ)^2*c2) ≤ B^2 := by
  nlinarith

end IndependentResearch
