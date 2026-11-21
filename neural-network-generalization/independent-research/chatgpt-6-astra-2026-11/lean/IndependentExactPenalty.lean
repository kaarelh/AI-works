import Mathlib

/-!
The finite exact-penalty argument used in the control-rail manuscript.
The coefficients below already include any empirical averaging factors.
The neural dual inequality and its equality characterization remain
analytic hypotheses, not conclusions of this file.
-/

namespace IndependentResearch
open scoped BigOperators

/-- Hinge slack bounds a signed margin deficit. -/
theorem hinge_slack_dominates (margin score : ℝ) :
    margin - score ≤ max (margin - score) 0 ∧
    0 ≤ max (margin - score) 0 := by
  exact ⟨le_max_left _ _, le_max_right _ _⟩

/-- An objective at or below the calibrated dual value must interpolate
when every hinge penalty strictly exceeds its dual coefficient. -/
theorem exact_hinge_penalty_feasible {X : Type*} [Fintype X]
    (margin score coefficient : X → ℝ) (energy penalty : ℝ)
    (hc : ∀ x, 0 ≤ coefficient x)
    (hp : ∀ x, coefficient x < penalty)
    (hdual : ∑ x, coefficient x * score x ≤ energy)
    (hobjective : energy + penalty * ∑ x, max (margin x - score x) 0 ≤
      ∑ x, coefficient x * margin x) :
    (∀ x, margin x ≤ score x) ∧
      energy = ∑ x, coefficient x * margin x := by
  classical
  let slack : X → ℝ := fun x => max (margin x - score x) 0
  have hs (x : X) : 0 ≤ slack x := le_max_right _ _
  have hd (x : X) : margin x - score x ≤ slack x := le_max_left _ _
  have hterm (x : X) :
      coefficient x * margin x ≤ coefficient x * score x + coefficient x * slack x := by
    have hh := mul_le_mul_of_nonneg_left (hd x) (hc x)
    nlinarith
  have hsum : (∑ x, coefficient x * margin x) ≤
      energy + ∑ x, coefficient x * slack x := by
    calc
      (∑ x, coefficient x * margin x) ≤
          ∑ x, (coefficient x * score x + coefficient x * slack x) :=
        Finset.sum_le_sum fun x _ => hterm x
      _ = (∑ x, coefficient x * score x) + ∑ x, coefficient x * slack x := by
        rw [Finset.sum_add_distrib]
      _ ≤ energy + ∑ x, coefficient x * slack x := add_le_add hdual le_rfl
  have hzsum : (∑ x, (penalty - coefficient x) * slack x) ≤ 0 := by
    have heq : (∑ x, (penalty - coefficient x) * slack x) =
        penalty * (∑ x, slack x) - ∑ x, coefficient x * slack x := by
      simp_rw [sub_mul]
      rw [Finset.sum_sub_distrib, Finset.mul_sum]
    rw [heq]
    change energy + penalty * ∑ x, slack x ≤ _ at hobjective
    linarith
  have hnonneg (x : X) : 0 ≤ (penalty - coefficient x) * slack x :=
    mul_nonneg (sub_nonneg.mpr (le_of_lt (hp x))) (hs x)
  have hz (x : X) : slack x = 0 := by
    have ht : (penalty - coefficient x) * slack x ≤ 0 := by
      calc
        (penalty - coefficient x) * slack x ≤
            ∑ y, (penalty - coefficient y) * slack y :=
          Finset.single_le_sum (fun y _ => hnonneg y) (Finset.mem_univ x)
        _ ≤ 0 := hzsum
    have hpos : 0 < penalty - coefficient x := sub_pos.mpr (hp x)
    nlinarith [hs x]
  have hfeasible (x : X) : margin x ≤ score x := by
    have hh := hd x
    rw [hz x] at hh
    linarith
  refine ⟨hfeasible, le_antisymm ?_ ?_⟩
  · change energy + penalty * ∑ x, slack x ≤ _ at hobjective
    simpa only [hz, Finset.sum_const_zero, mul_zero, add_zero] using hobjective
  · calc
      (∑ x, coefficient x * margin x) ≤ ∑ x, coefficient x * score x :=
        Finset.sum_le_sum fun x _ => mul_le_mul_of_nonneg_left (hfeasible x) (hc x)
      _ ≤ energy := hdual

/-- The exact finite penalty preserves a hard-margin unique output,
assuming the neural dual and the hard-margin uniqueness theorem. -/
theorem exact_hinge_penalty_preserves_unique_output
    {X Θ Y : Type*} [Fintype X]
    (margin coefficient : X → ℝ) (score : Θ → X → ℝ)
    (energy : Θ → ℝ) (output : Θ → Y) (star : Y) (penalty : ℝ)
    (hc : ∀ x, 0 ≤ coefficient x)
    (hp : ∀ x, coefficient x < penalty)
    (hdual : ∀ θ, ∑ x, coefficient x * score θ x ≤ energy θ)
    (hunique : ∀ θ, (∀ x, margin x ≤ score θ x) →
      energy θ ≤ (∑ x, coefficient x * margin x) → output θ = star)
    (θ : Θ)
    (hobjective : energy θ + penalty * ∑ x, max (margin x - score θ x) 0 ≤
      ∑ x, coefficient x * margin x) : output θ = star := by
  obtain ⟨hf, he⟩ := exact_hinge_penalty_feasible
    margin (score θ) coefficient (energy θ) penalty hc hp (hdual θ) hobjective
  exact hunique θ hf (le_of_eq he)

end IndependentResearch
