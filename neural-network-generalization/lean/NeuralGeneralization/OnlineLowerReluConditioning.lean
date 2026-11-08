import NeuralGeneralization.OnlineLowerReluMonotone

/-!+# Explicit monotone scores arising from parity-conditioned ReLU rails

The free opposite-rail bits leave a single parity-dependent term in each
block. Its magnitude is at most the dominant rail amplitude, which makes
the resulting score monotone in every selected coordinate.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

/-- The ordinary selected bits of one conditioned rail pair. -/
def conditionedRailProfile (a c : ℝ) (k : ℕ) : ℝ :=
  2 * a * k + c * (-1 : ℝ) ^ k

theorem conditionedRailProfile_monotone (a c : ℝ) (hc : |c| ≤ a) :
    Monotone (conditionedRailProfile a c) := by
  apply monotone_nat_of_le_succ
  intro k
  have hp : c * (-1 : ℝ) ^ k ≤ a := by
    calc
      c * (-1 : ℝ) ^ k ≤ |c * (-1 : ℝ) ^ k| := le_abs_self _
      _ = |c| := by simp [abs_mul, abs_pow]
      _ ≤ a := hc
  unfold conditionedRailProfile
  rw [pow_succ, Nat.cast_add, Nat.cast_one]
  nlinarith

/-- A sum of conditioned rail profiles; blocks need not be disjoint for
the monotonicity assertion. -/
def conditionedBlockScore {ι α : Type*} [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (a c : ι → ℝ) (bias : ℝ) (S : Finset α) : ℝ :=
  bias + ∑ i, conditionedRailProfile (a i) (c i) (S ∩ blocks i).card

theorem conditionedBlockScore_monotone {ι α : Type*}
    [Fintype ι] [DecidableEq α]
    (blocks : ι → Finset α) (a c : ι → ℝ) (bias : ℝ)
    (hc : ∀ i, |c i| ≤ a i) :
    Monotone (conditionedBlockScore blocks a c bias) := by
  intro S T hST
  have hsum : (∑ i, conditionedRailProfile (a i) (c i) (S ∩ blocks i).card) ≤
      ∑ i, conditionedRailProfile (a i) (c i) (T ∩ blocks i).card := by
    apply Finset.sum_le_sum
    intro i _
    apply conditionedRailProfile_monotone _ _ (hc i)
    exact Finset.card_le_card (Finset.inter_subset_inter_right hST)
  unfold conditionedBlockScore
  linarith

/-- A sharp top-coefficient estimate for an explicitly parity-conditioned
block score after taking the distinguished selected-bit derivative. -/
theorem conditioned_block_difference_parity_bound {ι : Type*} [Fintype ι]
    (n : ℕ) (blocks : ι → Finset (Fin (n + 1))) (a c : ι → ℝ)
    (bias d : ℝ) (hc : ∀ i, |c i| ≤ a i) (hd : 0 ≤ d) :
    |(∑ S : Finset (Fin (n + 1)), (-1 : ℝ) ^ S.card *
        reluDifference d (conditionedBlockScore blocks a c bias S)) /
        (2 : ℝ) ^ (n + 2)| ≤
      d * (n.choose (n / 2) : ℝ) / (2 : ℝ) ^ (n + 1) := by
  exact monotone_score_difference_parity_bound n d _ hd
    (conditionedBlockScore_monotone blocks a c bias hc)

end NeuralGeneralization.OnlineLowerRelu
