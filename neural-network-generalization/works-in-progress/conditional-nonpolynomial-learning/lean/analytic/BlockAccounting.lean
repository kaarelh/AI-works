import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

open scoped BigOperators

namespace ConditionalNonpolynomial.Analytic

/-- A finite Markov-count estimate, with no independence assumption. -/
theorem bad_block_card_bound {ι : Type*} [DecidableEq ι]
    (S : Finset ι) (cost : ι → ℝ) (θ : ℝ)
    (hcost : ∀ i ∈ S, 0 ≤ cost i) :
    θ * ((S.filter fun i => θ < cost i).card : ℝ) ≤ ∑ i ∈ S, cost i := by
  classical
  let B := S.filter fun i => θ < cost i
  calc
    θ * (B.card : ℝ) = ∑ _i ∈ B, θ := by simp [mul_comm]
    _ ≤ ∑ i ∈ B, cost i := Finset.sum_le_sum fun i hi =>
      le_of_lt (Finset.mem_filter.mp hi).2
    _ ≤ ∑ i ∈ S, cost i := Finset.sum_le_sum_of_subset_of_nonneg
      (Finset.filter_subset _ _) (fun i hi _ => hcost i hi)

/-- If each of two kinds of bad block consumes at most a quarter of the
available threshold budget, at least half the blocks are good in both senses. -/
theorem at_least_half_good_blocks {ι : Type*} [DecidableEq ι]
    (S : Finset ι) (cost₁ cost₂ : ι → ℝ) (θ₁ θ₂ : ℝ)
    (hθ₁ : 0 < θ₁) (hθ₂ : 0 < θ₂)
    (hc₁ : ∀ i ∈ S, 0 ≤ cost₁ i) (hc₂ : ∀ i ∈ S, 0 ≤ cost₂ i)
    (hb₁ : ∑ i ∈ S, cost₁ i ≤ θ₁ * (S.card : ℝ) / 4)
    (hb₂ : ∑ i ∈ S, cost₂ i ≤ θ₂ * (S.card : ℝ) / 4) :
    (S.card : ℝ) / 2 ≤
      ((S.filter fun i => cost₁ i ≤ θ₁ ∧ cost₂ i ≤ θ₂).card : ℝ) := by
  classical
  let B₁ := S.filter fun i => θ₁ < cost₁ i
  let B₂ := S.filter fun i => θ₂ < cost₂ i
  let G := S.filter fun i => cost₁ i ≤ θ₁ ∧ cost₂ i ≤ θ₂
  have hn₁ : (B₁.card : ℝ) ≤ (S.card : ℝ) / 4 := by
    apply (mul_le_mul_iff_right₀ hθ₁).mp
    have hh := (bad_block_card_bound S cost₁ θ₁ hc₁).trans hb₁
    simpa only [mul_div_assoc] using hh
  have hn₂ : (B₂.card : ℝ) ≤ (S.card : ℝ) / 4 := by
    apply (mul_le_mul_iff_right₀ hθ₂).mp
    have hh := (bad_block_card_bound S cost₂ θ₂ hc₂).trans hb₂
    simpa only [mul_div_assoc] using hh
  have hcover : S ⊆ G ∪ B₁ ∪ B₂ := by
    intro i hi
    by_cases h₁ : cost₁ i ≤ θ₁
    · by_cases h₂ : cost₂ i ≤ θ₂
      · exact Finset.mem_union_left _ (Finset.mem_union_left _
          (Finset.mem_filter.mpr ⟨hi, h₁, h₂⟩))
      · exact Finset.mem_union_right _ (Finset.mem_filter.mpr ⟨hi, lt_of_not_ge h₂⟩)
    · exact Finset.mem_union_left _ (Finset.mem_union_right _
        (Finset.mem_filter.mpr ⟨hi, lt_of_not_ge h₁⟩))
  have hc : S.card ≤ G.card + B₁.card + B₂.card :=
    (Finset.card_le_card hcover).trans ((Finset.card_union_le _ _).trans
      (Nat.add_le_add_right (Finset.card_union_le _ _) _))
  have hcr : (S.card : ℝ) ≤ G.card + B₁.card + B₂.card := by exact_mod_cast hc
  change (S.card : ℝ) / 2 ≤ (G.card : ℝ)
  linarith

/-- Iterating the block gains gives the stated exponential penalty for every
good block. The individual inequalities, rather than a final cover bound, are
its hypotheses. -/
theorem iterated_block_gain (radius E : ℕ → ℝ) (good : ℕ → Prop)
    [DecidablePred good] (n : ℕ)
    (hstep : ∀ i < n, radius (i + 1) ≤ radius i * Real.exp (E i - if good i then 1 else 0)) :
    radius n ≤ radius 0 * Real.exp
      ((∑ i ∈ Finset.range n, E i) - ((Finset.range n).filter good).card) := by
  induction n with
  | zero => simp
  | succ n ih =>
    have hprev := ih (fun i hi => hstep i (by omega))
    have hh := (hstep n (by omega)).trans
      (mul_le_mul_of_nonneg_right hprev (Real.exp_pos _).le)
    have hid : ((∑ i ∈ Finset.range n, E i) -
        (((Finset.range n).filter good).card : ℝ)) +
        (E n - if good n then 1 else 0) =
      (∑ i ∈ Finset.range (n + 1), E i) -
        (((Finset.range (n + 1)).filter good).card : ℝ) := by
      rw [Finset.sum_range_succ, Finset.range_add_one, Finset.filter_insert]
      by_cases hn : good n
      · simp [hn]
        ring
      · simp [hn]
        ring
    calc
      radius (n + 1) ≤ (radius 0 * Real.exp
          ((∑ i ∈ Finset.range n, E i) - ((Finset.range n).filter good).card)) *
          Real.exp (E n - if good n then 1 else 0) := hh
      _ = radius 0 * Real.exp
          ((∑ i ∈ Finset.range (n + 1), E i) -
            ((Finset.range (n + 1)).filter good).card) := by
        rw [mul_assoc, ← Real.exp_add, hid]

/-- Exact gain cancellation after division by the prefix's accumulated linear
gain. This is the algebra behind `exp(sum h/a - numberGood)`. -/
theorem normalized_block_gain (radius D c g : ℕ → ℝ) (good : ℕ → Prop)
    [DecidablePred good] (n : ℕ) (a : ℝ) (ha : a ≠ 0)
    (hstep : ∀ i < n, radius (i + 1) ≤ radius i *
      Real.exp ((D i - c i) / a - if good i then 1 else 0)) :
    radius n / Real.exp (∑ i ∈ Finset.range n, g i) ≤
      radius 0 * Real.exp
        ((∑ i ∈ Finset.range n, (D i - c i - a * g i)) / a -
          ((Finset.range n).filter good).card) := by
  have hh := iterated_block_gain radius (fun i => (D i - c i) / a) good n hstep
  apply (div_le_iff₀ (Real.exp_pos _)).mpr
  have he : (∑ i ∈ Finset.range n, (D i - c i) / a) -
      (((Finset.range n).filter good).card : ℝ) =
      ((∑ i ∈ Finset.range n, (D i - c i - a * g i)) / a -
        (((Finset.range n).filter good).card : ℝ)) + ∑ i ∈ Finset.range n, g i := by
    rw [← Finset.sum_div]
    simp_rw [Finset.sum_sub_distrib, ← Finset.mul_sum]
    field_simp
    ring
  rw [mul_assoc, ← Real.exp_add, ← he]
  exact hh

#print axioms bad_block_card_bound
#print axioms at_least_half_good_blocks
#print axioms iterated_block_gain
#print axioms normalized_block_gain

end ConditionalNonpolynomial.Analytic
