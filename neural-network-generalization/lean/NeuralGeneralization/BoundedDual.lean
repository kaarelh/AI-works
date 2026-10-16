import Mathlib.Data.Real.Basic
import Mathlib.Data.Finset.Max
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Algebra.BigOperators.Ring.Finset
import Mathlib.Algebra.BigOperators.Group.Finset.Piecewise
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-!
# The finite-dimensional support argument in the bounded-dual lift

This file proves the ℓ¹/ℓ∞ support identity, and the exact error/entropy
identity from the first-order optimality condition. The latter is expressly
conditional on that first-order condition and the analytic entropy identity.
The companion `ActualBoundedDual` module proves those hypotheses and constructs
the maximizing actual exponential tilt from bounded measurable observables.
These components alone do not certify the neural-network learning theorem.
-/

namespace NeuralGeneralization.BoundedDual

noncomputable section

open scoped BigOperators

variable {ι : Type*} [Fintype ι] [DecidableEq ι] [Nonempty ι]

/-- The entrywise ℓ¹ norm, written as a finite sum. -/
def entryL1 (v : ι → ℝ) : ℝ := ∑ i, |v i|

/-- The real bilinear pairing, without a dimension-dependent normalization. -/
def pairing (a v : ι → ℝ) : ℝ := ∑ i, a i * v i

/-- The largest absolute coordinate; nonempty finite coordinate sets are used. -/
def maxAbs (a : ι → ℝ) : ℝ :=
  Finset.univ.sup' Finset.univ_nonempty (fun i => |a i|)

omit [DecidableEq ι] in
lemma abs_le_maxAbs (a : ι → ℝ) (i : ι) : |a i| ≤ maxAbs a := by
  exact Finset.le_sup' (fun j => |a j|) (Finset.mem_univ i)

omit [DecidableEq ι] in
lemma maxAbs_nonneg (a : ι → ℝ) : 0 ≤ maxAbs a := by
  obtain ⟨i⟩ := ‹Nonempty ι›
  exact (abs_nonneg (a i)).trans (abs_le_maxAbs a i)

omit [DecidableEq ι] in
lemma exists_maxAbs (a : ι → ℝ) : ∃ i, |a i| = maxAbs a := by
  obtain ⟨i, hi, hmax⟩ := Finset.exists_max_image Finset.univ (fun i => |a i|)
    Finset.univ_nonempty
  refine ⟨i, le_antisymm (abs_le_maxAbs a i) ?_⟩
  exact Finset.sup'_le _ _ (fun j hj => hmax j hj)

omit [DecidableEq ι] [Nonempty ι] in
lemma pairing_comm (a v : ι → ℝ) : pairing a v = pairing v a := by
  unfold pairing
  apply Finset.sum_congr rfl
  intro i hi
  exact mul_comm _ _

omit [DecidableEq ι] [Nonempty ι] in
lemma pairing_sub_right (a u v : ι → ℝ) :
    pairing a (u - v) = pairing a u - pairing a v := by
  simp only [pairing, Pi.sub_apply, mul_sub, Finset.sum_sub_distrib]

omit [DecidableEq ι] [Nonempty ι] in
lemma pairing_sub_left (a b v : ι → ℝ) :
    pairing (a - b) v = pairing a v - pairing b v := by
  simp only [pairing, Pi.sub_apply, sub_mul, Finset.sum_sub_distrib]

omit [DecidableEq ι] in
lemma pairing_le_maxAbs_mul_entryL1 (a v : ι → ℝ) :
    pairing a v ≤ maxAbs a * entryL1 v := by
  calc
    pairing a v ≤ ∑ i, |a i| * |v i| := by
      apply Finset.sum_le_sum
      intro i hi
      exact (le_abs_self (a i * v i)).trans_eq (abs_mul (a i) (v i))
    _ ≤ ∑ i, maxAbs a * |v i| := by
      apply Finset.sum_le_sum
      intro i hi
      exact mul_le_mul_of_nonneg_right (abs_le_maxAbs a i) (abs_nonneg _)
    _ = maxAbs a * entryL1 v := by rw [entryL1, Finset.mul_sum]

omit [DecidableEq ι] in
lemma pairing_le_ball_support (a v : ι → ℝ) {G : ℝ}
    (hv : entryL1 v ≤ G) : pairing a v ≤ G * maxAbs a := by
  calc
    pairing a v ≤ maxAbs a * entryL1 v := pairing_le_maxAbs_mul_entryL1 a v
    _ ≤ maxAbs a * G := mul_le_mul_of_nonneg_left hv (maxAbs_nonneg a)
    _ = G * maxAbs a := mul_comm _ _

/-- A single signed coordinate attains the support function of the ℓ¹ ball. -/
theorem exists_ball_support (a : ι → ℝ) {G : ℝ} (hG : 0 ≤ G) :
    ∃ v : ι → ℝ, entryL1 v ≤ G ∧ pairing a v = G * maxAbs a := by
  obtain ⟨i, hi⟩ := exists_maxAbs a
  by_cases hai : 0 ≤ a i
  · let v : ι → ℝ := fun j => if j = i then G else 0
    refine ⟨v, ?_, ?_⟩
    · simp [v, entryL1, abs_ite, abs_of_nonneg hG]
    · simp only [pairing, v, mul_ite, mul_zero]
      rw [Finset.sum_ite_eq']
      simp only [Finset.mem_univ, if_true]
      rw [← hi, abs_of_nonneg hai, mul_comm]
  · let v : ι → ℝ := fun j => if j = i then -G else 0
    refine ⟨v, ?_, ?_⟩
    · simp [v, entryL1, abs_ite, abs_of_nonneg hG]
    · simp only [pairing, v, mul_ite, mul_zero]
      rw [Finset.sum_ite_eq']
      simp only [Finset.mem_univ, if_true]
      rw [← hi, abs_of_neg (lt_of_not_ge hai)]
      ring

/-- First-order optimality on the entire ℓ¹ ball forces exact support equality. -/
theorem support_eq_of_first_order (a star : ι → ℝ) {G : ℝ}
    (hG : 0 ≤ G) (hstar : entryL1 star ≤ G)
    (hfirst : ∀ v : ι → ℝ, entryL1 v ≤ G → pairing a (v - star) ≤ 0) :
    pairing a star = G * maxAbs a := by
  apply le_antisymm (pairing_le_ball_support a star hstar)
  obtain ⟨v, hv, heq⟩ := exists_ball_support a hG
  have h := hfirst v hv
  rw [pairing_sub_right, heq] at h
  linarith

/-- The algebraic core of the exponential-tilt entropy identity.

For a log-MGF Λ, analytic work supplies `m = ∇Λ(star)` and
`entropy = pairing star m - Λ(star)`, and proves the displayed first-order
condition. Those facts are explicit hypotheses here, not new axioms.
-/
theorem exact_entropy_error_decomposition
    (q m star : ι → ℝ) {G logPartition entropy : ℝ}
    (hG : 0 ≤ G) (hstar : entryL1 star ≤ G)
    (hfirst : ∀ v : ι → ℝ, entryL1 v ≤ G →
      pairing (q - m) (v - star) ≤ 0)
    (hentropy : entropy = pairing star m - logPartition) :
    pairing star q - logPartition = entropy + G * maxAbs (q - m) := by
  have hs := support_eq_of_first_order (q - m) star hG hstar hfirst
  rw [pairing_sub_left, pairing_comm q star, pairing_comm m star] at hs
  linarith

/-- Nonnegative entropy converts the exact identity into simultaneous bounds. -/
theorem entropy_and_error_le
    (q m star : ι → ℝ) {G logPartition entropy K : ℝ}
    (hG : 0 < G) (hstar : entryL1 star ≤ G)
    (hfirst : ∀ v : ι → ℝ, entryL1 v ≤ G →
      pairing (q - m) (v - star) ≤ 0)
    (hentropy : entropy = pairing star m - logPartition)
    (hnonneg : 0 ≤ entropy)
    (hbound : pairing star q - logPartition ≤ K) :
    entropy ≤ K ∧ maxAbs (q - m) ≤ K / G := by
  have hid := exact_entropy_error_decomposition q m star hG.le hstar hfirst hentropy
  have herror_nonneg : 0 ≤ G * maxAbs (q - m) :=
    mul_nonneg hG.le (maxAbs_nonneg _)
  constructor
  · linarith
  · apply (le_div_iff₀ hG).2
    nlinarith

end

end NeuralGeneralization.BoundedDual
