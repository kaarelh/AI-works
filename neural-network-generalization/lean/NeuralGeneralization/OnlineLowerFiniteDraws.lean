import NeuralGeneralization.FinitePosterior

/-!
# Finite product laws for fresh posterior draws

The probability weights, normalization, expectation, and all-error event
are explicit finite sums. The neural specialization is in
`OnlineLowerMistakes`; independence is encoded by the product joint law.
-/

noncomputable section
open scoped BigOperators
open Classical

namespace NeuralGeneralization.OnlineLower

variable {I H : Type*} [Fintype I] [DecidableEq I] [Fintype H]

/-- The joint probability weight of independent, nonidentical finite draws. -/
def freshJointWeight (p : I → H → ℝ) (draw : I → H) : ℝ :=
  ∏ i, p i (draw i)

omit [Fintype H] [DecidableEq I] in
theorem freshJointWeight_nonneg (p : I → H → ℝ) (hp : ∀ i g, 0 ≤ p i g)
    (draw : I → H) : 0 ≤ freshJointWeight p draw :=
  Finset.prod_nonneg (fun i _ => hp i (draw i))

theorem freshJointWeight_sum (p : I → H → ℝ) (hp : ∀ i, ∑ g, p i g = 1) :
    ∑ draw, freshJointWeight p draw = 1 := by
  classical
  unfold freshJointWeight
  rw [← Fintype.prod_sum]
  simp_rw [hp]
  simp

theorem fresh_expected_coordinate (p : I → H → ℝ)
    (hp : ∀ i, ∑ g, p i g = 1) (L : H → ℝ) (i : I) :
    (∑ draw : I → H, freshJointWeight p draw * L (draw i)) =
      ∑ g, p i g * L g := by
  classical
  have hterm (draw : I → H) : freshJointWeight p draw * L (draw i) =
      ∏ j, p j (draw j) * (if j = i then L (draw j) else 1) := by
    rw [Finset.prod_mul_distrib]
    simp [freshJointWeight]
  simp_rw [hterm]
  rw [← Fintype.prod_sum (fun j g => p j g * (if j = i then L g else 1))]
  have hs (j : I) : (∑ g, p j g * (if j = i then L g else 1)) =
      if j = i then ∑ g, p i g * L g else 1 := by
    by_cases hji : j = i
    · subst j; simp
    · simp [hji, hp]
  simp_rw [hs]
  simp

theorem fresh_expected_sum (p : I → H → ℝ)
    (hp : ∀ i, ∑ g, p i g = 1) (L : I → H → ℝ) :
    (∑ draw : I → H, freshJointWeight p draw * ∑ i, L i (draw i)) =
      ∑ i, ∑ g, p i g * L i g := by
  simp_rw [Finset.mul_sum]
  rw [Finset.sum_comm]
  exact Finset.sum_congr rfl (fun i _ => fresh_expected_coordinate p hp (L i) i)

/-- Exact probability of simultaneous coordinate events under the joint law. -/
theorem fresh_all_events_probability (p : I → H → ℝ) (event : I → H → Prop) [∀ i, DecidablePred (event i)] :
    (∑ draw : I → H, if ∀ i, event i (draw i) then freshJointWeight p draw else 0) =
      ∏ i, ∑ g, if event i g then p i g else 0 := by
  classical
  rw [Fintype.prod_sum]
  apply Finset.sum_congr rfl
  intro draw hdraw
  exact (Fintype.prod_ite_zero (p := fun i => event i (draw i))
    (f := fun i => p i (draw i))).symm

/-- A coordinate's error probability is one minus its correct probability. -/
theorem finite_error_complement (p : H → ℝ) (hp : ∑ g, p g = 1)
    (good : H → Prop) [DecidablePred good] :
    (∑ g, if ¬ good g then p g else 0) =
      1 - ∑ g, if good g then p g else 0 := by
  classical
  have hs : (∑ g, if ¬ good g then p g else 0) +
      (∑ g, if good g then p g else 0) = 1 := by
    rw [← Finset.sum_add_distrib]
    calc
      _ = ∑ g, p g := by
        apply Finset.sum_congr rfl
        intro g hg
        by_cases h : good g <;> simp [h]
      _ = 1 := hp
  linarith

end NeuralGeneralization.OnlineLower
