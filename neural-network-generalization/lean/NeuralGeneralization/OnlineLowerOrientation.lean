import Mathlib.Data.Real.Basic
import Mathlib.Algebra.Order.BigOperators.GroupWithZero.Finset
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# Summing competing rail orientations without an exponential factor

This file proves the elementary product bound used to improve the tanh
construction's rail baseline. It is an analytic ingredient, not a standalone
proof of the neural online lower bound.
-/

open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

variable {ι : Type*} [DecidableEq ι]

/-- For each rail pair, `a` is the dominant orientation's nonnegative factor
and `b` is the opposite orientation's factor. Their sum is at most one.
The sum of products from all orientations except the dominant one is bounded
by the sum of the individual opposite factors. -/
theorem competing_orientation_product_bound (s : Finset ι) (a b : ι → ℝ)
    (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 ≤ b i)
    (hab : ∀ i ∈ s, a i + b i ≤ 1) :
    (∏ i ∈ s, (a i + b i)) - (∏ i ∈ s, a i) ≤ ∑ i ∈ s, b i := by
  induction s using Finset.induction_on with
  | empty => simp
  | @insert i s hi ih =>
    have hai : 0 ≤ a i := ha i (Finset.mem_insert_self i s)
    have hbi : 0 ≤ b i := hb i (Finset.mem_insert_self i s)
    have hai' : a i ≤ 1 := by
      have := hab i (Finset.mem_insert_self i s)
      linarith
    have has : ∀ j ∈ s, 0 ≤ a j := fun j hj => ha j (Finset.mem_insert_of_mem hj)
    have hbs : ∀ j ∈ s, 0 ≤ b j := fun j hj => hb j (Finset.mem_insert_of_mem hj)
    have habs : ∀ j ∈ s, a j + b j ≤ 1 :=
      fun j hj => hab j (Finset.mem_insert_of_mem hj)
    have hp : (∏ j ∈ s, (a j + b j)) ≤ 1 :=
      Finset.prod_le_one (fun j hj => add_nonneg (has j hj) (hbs j hj)) habs
    have hs : 0 ≤ ∑ j ∈ s, b j := Finset.sum_nonneg hbs
    have hd := ih has hbs habs
    rw [Finset.prod_insert hi, Finset.prod_insert hi, Finset.sum_insert hi]
    calc
      (a i + b i) * (∏ j ∈ s, (a j + b j)) - a i * (∏ j ∈ s, a j)
          = a i * ((∏ j ∈ s, (a j + b j)) - (∏ j ∈ s, a j))
            + b i * (∏ j ∈ s, (a j + b j)) := by ring
      _ ≤ a i * (∑ j ∈ s, b j) + b i * 1 :=
        add_le_add (mul_le_mul_of_nonneg_left hd hai)
          (mul_le_mul_of_nonneg_left hp hbi)
      _ ≤ b i + ∑ j ∈ s, b j := by
        have := mul_le_mul_of_nonneg_right hai' hs
        linarith

/-- If each competing rail factor is at most `ε`, only the number of pairs
appears in the bound; the number of complete orientations does not. -/
theorem competing_orientation_uniform_bound (s : Finset ι) (a b : ι → ℝ)
    (ε : ℝ) (ha : ∀ i ∈ s, 0 ≤ a i) (hb : ∀ i ∈ s, 0 ≤ b i)
    (hab : ∀ i ∈ s, a i + b i ≤ 1) (hε : ∀ i ∈ s, b i ≤ ε) :
    (∏ i ∈ s, (a i + b i)) - (∏ i ∈ s, a i) ≤ (s.card : ℝ) * ε := by
  calc
    _ ≤ ∑ i ∈ s, b i := competing_orientation_product_bound s a b ha hb hab
    _ ≤ ∑ _i ∈ s, ε := Finset.sum_le_sum hε
    _ = (s.card : ℝ) * ε := by simp

end NeuralGeneralization.OnlineLower

namespace NeuralGeneralization.OnlineLower

/-- An elementary reciprocal Bernoulli bound, avoiding any estimate of
individual binomial coefficients. -/
theorem reciprocal_bernoulli (x : ℝ) (hx : 0 ≤ x) (n : ℕ) :
    (1 + x) ^ n * (1 - (n : ℝ) * x) ≤ 1 := by
  induction n with
  | zero => simp
  | succ n ih =>
    have hp : 0 ≤ (1 + x) ^ n := pow_nonneg (by linarith) n
    have hs : (1 + x) * (1 - ((n : ℝ) + 1) * x) ≤ 1 - (n : ℝ) * x := by
      have hn : 0 ≤ (n : ℝ) + 1 := add_nonneg (Nat.cast_nonneg n) zero_le_one
      nlinarith [mul_nonneg hn (sq_nonneg x)]
    calc
      (1 + x) ^ (n + 1) * (1 - ((n + 1 : ℕ) : ℝ) * x)
          = (1 + x) ^ n * ((1 + x) * (1 - ((n : ℝ) + 1) * x)) := by
            rw [pow_succ, Nat.cast_add, Nat.cast_one]
            ring
      _ ≤ (1 + x) ^ n * (1 - (n : ℝ) * x) := mul_le_mul_of_nonneg_left hs hp
      _ ≤ 1 := ih

/-- Summing all switch counts costs at most a factor linear in the number
of pairs when the single-pair weight is at most `1/(2n)`. -/
theorem all_switch_counts_bound (x : ℝ) (hx : 0 ≤ x) (n : ℕ)
    (hsmall : (n : ℝ) * x ≤ 1 / 2) :
    (1 + x) ^ n - 1 ≤ 2 * (n : ℝ) * x := by
  have hp : 0 ≤ (1 + x) ^ n := pow_nonneg (by linarith) n
  have hb := reciprocal_bernoulli x hx n
  have hnon : 0 ≤ (n : ℝ) * x := mul_nonneg (Nat.cast_nonneg n) hx
  have htwo : (1 + x) ^ n ≤ 2 := by
    nlinarith [mul_nonneg hp (sub_nonneg.mpr hsmall)]
  nlinarith [mul_nonneg (sub_nonneg.mpr htwo) hnon]

end NeuralGeneralization.OnlineLower
