import Mathlib

/-!
Deterministic square-root inequalities behind the softplus count-rate
optimization. No marked large-deviation principle, conditional posterior,
or asymptotic evidence formula is formalized here.
-/

namespace IndependentResearch
open scoped BigOperators

theorem sqrt_pair_lower_bound (a b δ : ℝ) (hδ : 0 ≤ δ)
    (ha : δ ≤ a) (hb : δ ≤ b) :
    Real.sqrt δ + Real.sqrt (a + b - δ) ≤ Real.sqrt a + Real.sqrt b := by
  have ha0 : 0 ≤ a := le_trans hδ ha
  have hb0 : 0 ≤ b := le_trans hδ hb
  have hc0 : 0 ≤ a + b - δ := by linarith
  have hprod : δ * (a + b - δ) ≤ a * b := by
    nlinarith [mul_nonneg (sub_nonneg.mpr ha) (sub_nonneg.mpr hb)]
  have hroot := Real.sqrt_le_sqrt hprod
  rw [Real.sqrt_mul hδ, Real.sqrt_mul ha0] at hroot
  have hs : (Real.sqrt δ + Real.sqrt (a + b - δ)) ^ 2 ≤
      (Real.sqrt a + Real.sqrt b) ^ 2 := by
    nlinarith [Real.sq_sqrt hδ, Real.sq_sqrt ha0, Real.sq_sqrt hb0,
      Real.sq_sqrt hc0]
  nlinarith [Real.sqrt_nonneg δ, Real.sqrt_nonneg (a + b - δ),
    Real.sqrt_nonneg a, Real.sqrt_nonneg b]

theorem shifted_sqrt_subadditive (δ x y : ℝ) (hδ : 0 ≤ δ)
    (hx : 0 ≤ x) (hy : 0 ≤ y) :
    Real.sqrt (δ + (x + y)) - Real.sqrt δ ≤
      (Real.sqrt (δ + x) - Real.sqrt δ) +
      (Real.sqrt (δ + y) - Real.sqrt δ) := by
  have h := sqrt_pair_lower_bound (δ + x) (δ + y) δ hδ (by linarith) (by linarith)
  have he : δ + x + (δ + y) - δ = δ + (x + y) := by ring
  rw [he] at h
  linarith

theorem shifted_sqrt_sum_bound {ι : Type*} (s : Finset ι) (x : ι → ℝ)
    (δ : ℝ) (hδ : 0 ≤ δ) (hx : ∀ i ∈ s, 0 ≤ x i) :
    Real.sqrt (δ + ∑ i ∈ s, x i) - Real.sqrt δ ≤
      ∑ i ∈ s, (Real.sqrt (δ + x i) - Real.sqrt δ) := by
  classical
  induction s using Finset.induction_on with
  | empty => simp
  | @insert a s ha ih =>
      have hxa : 0 ≤ x a := hx a (Finset.mem_insert_self _ _)
      have hxs : ∀ i ∈ s, 0 ≤ x i := by
        intro i hi
        exact hx i (Finset.mem_insert_of_mem hi)
      have hsum : 0 ≤ ∑ i ∈ s, x i := Finset.sum_nonneg hxs
      have hp := shifted_sqrt_subadditive δ (x a) (∑ i ∈ s, x i) hδ hxa hsum
      have hi := ih hxs
      simp only [Finset.sum_insert ha]
      linarith

theorem sqrt_split_concavity (A x y : ℝ) (hx : 0 ≤ x) (hy : 0 ≤ y)
    (hA : x + y ≤ A) :
    Real.sqrt A + Real.sqrt (A - x - y) ≤
      Real.sqrt (A - x) + Real.sqrt (A - y) := by
  have hδ : 0 ≤ A - x - y := by linarith
  have h := sqrt_pair_lower_bound (A - x) (A - y) (A - x - y)
    hδ (by linarith) (by linarith)
  have he : A - x + (A - y) - (A - x - y) = A := by ring
  rw [he] at h
  linarith

end IndependentResearch
