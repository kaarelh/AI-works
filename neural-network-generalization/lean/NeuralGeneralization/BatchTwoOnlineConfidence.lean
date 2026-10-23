import NeuralGeneralization.BatchTwoOnlineBounds

/-! # Strict confidence and majority-error consequences -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling
variable {H : Type*} [Fintype H] [DecidableEq H] {m : ℕ}

def permutationConfidenceCount (w : H → ℝ) (good : H → Fin m → Prop)
    (θ : ℝ) (π : Equiv.Perm (Fin m)) : ℝ :=
  ∑ i, if 1-permutationRound w good π i ≤ θ then 1 else 0

/-- Correct-label posterior probability is `1-q`; the weak inequality in
this definition is exactly failure of the manuscript's strict convention. -/
theorem permutationConfidenceCount_le_total
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (θ : ℝ) (hθ : θ < 1) (π) :
    permutationConfidenceCount w good θ π ≤ permutationTotal w good π/(1-θ) := by
  apply (le_div_iff₀ (sub_pos.mpr hθ)).mpr
  rw [permutationConfidenceCount, Finset.sum_mul]
  apply Finset.sum_le_sum
  intro i _
  split_ifs with hi
  · simp only [one_mul]
    linarith
  · simp only [zero_mul]
    exact permutationRound_nonneg w hw good target htarget hwt π i

theorem confidence_bounds_of_randomOrderBounds
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (h β : ℝ) (hb : RandomOrderBounds w good h β) (θ : ℝ) (hθ : θ < 1) :
    finiteMean (permutationConfidenceCount w good θ) ≤ expectationBudget m h β/(1-θ) ∧
    ∀ δ : ℝ, 0 < δ → δ < 1 →
      finiteEvent (fun π => highProbabilityBudget m h β δ/(1-θ) < permutationConfidenceCount w good θ π) ≤ δ := by
  constructor
  · calc
      _ ≤ finiteMean (fun π => permutationTotal w good π/(1-θ)) :=
        finiteMean_mono (permutationConfidenceCount_le_total w hw good target htarget hwt θ hθ)
      _ = finiteMean (permutationTotal w good)/(1-θ) := finiteMean_div _ _
      _ ≤ _ := div_le_div_of_nonneg_right hb.1 (sub_pos.mpr hθ).le
  · intro δ hδ hδ1
    apply (finiteEvent_mono (fun π hp => ?_)).trans (hb.2.2 δ hδ hδ1).1
    have hlt := hp.trans_le (permutationConfidenceCount_le_total w hw good target htarget hwt θ hθ π)
    exact (div_lt_div_iff_of_pos_right (sub_pos.mpr hθ)).mp hlt

/-- Any majority decision, with any convention at ties, makes an error only
where posterior error probability is at least one half. This pointwise
condition gives the exact deterministic factor-two count bound. -/
theorem majority_count_le_twice_total
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (π : Equiv.Perm (Fin m)) (wrong : Fin m → Prop)
    (hmajority : ∀ i, wrong i → (1/2 : ℝ) ≤ permutationRound w good π i) :
    (∑ i : Fin m, if wrong i then (1 : ℝ) else 0) ≤ 2*permutationTotal w good π := by
  unfold permutationTotal
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro i _
  by_cases hi : wrong i
  · simp only [if_pos hi]
    linarith [hmajority i hi]
  · simp only [if_neg hi]
    exact mul_nonneg (by norm_num) (permutationRound_nonneg w hw good target htarget hwt π i)

end NeuralGeneralization.BatchTwoOnline
