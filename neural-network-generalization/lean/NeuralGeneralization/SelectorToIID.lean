import NeuralGeneralization.FiniteSelectorMoments
import NeuralGeneralization.FiniteBirthdayBound

/-!
# Bernoulli selector to IID sample comparison

For a finite ambient set, independent literal selectors of mean size 2n
dominate every upward-closed bad event for n IID sampled vertices, up to
a factor two and the exact birthday collision term. Both the size event
and the uniform-subset comparisons are proved, not postulated.
-/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
open Classical
attribute [local instance] Classical.propDecidable
variable {V α : Type*} [Fintype V] [Nonempty V] [DecidableEq V] [Fintype α] [Nonempty α]

theorem selector_to_iid_monotone (n : ℕ) (choose : α → Bool) (hn : 4 ≤ n)
    (hmean : (Fintype.card V:ℝ)*selectorProbability choose=2*(n:ℝ))
    (bad : Finset V → Prop) (hbad : ∀ S T : Finset V, S ⊆ T → bad S → bad T) :
    finiteEvent (fun s : Fin n → V => bad (sampleRange s)) ≤
      2*finiteEvent (fun ω : V → α => bad (selectedSet choose ω))+
        (n:ℝ)*((n:ℝ)-1)/(2*(Fintype.card V:ℝ)) := by
  have hq := mul_le_mul_of_nonneg_left (selectorProbability_le_one choose)
    (Nat.cast_nonneg (Fintype.card V) : (0:ℝ)≤Fintype.card V)
  have hnV : n ≤ Fintype.card V := by
    have hr : (n:ℝ)≤Fintype.card V := by nlinarith only [hq, hmean, (Nat.cast_nonneg n : (0:ℝ)≤n)]
    exact_mod_cast hr
  have hs := selector_count_good_probability (V := V) choose n hn hmean
  have hmain := iidRangeEvent_le_twice_selector_add_collision n choose bad hbad hnV hs
  have hcollision := iid_collision_probability (V := V) (n := n) (by omega)
  linarith only [hmain, hcollision]

/-- A literal finite uniform selector with exactly k successful labels. -/
def initialSelector (M k : ℕ) : Fin M → Bool := fun j => decide (j.val < k)

theorem initialSelector_probability {M k : ℕ} (hk : k ≤ M) :
    selectorProbability (initialSelector M k) = (k:ℝ)/(M:ℝ) := by
  unfold selectorProbability finiteMean initialSelector
  simp only [decide_eq_true_eq, Fintype.card_fin]
  congr 1
  change (∑ x : Fin M, (fun j : ℕ => if j<k then (1:ℝ) else 0) x.val) = _
  rw [Fin.sum_univ_eq_sum_range (fun j : ℕ => if j<k then (1:ℝ) else 0)]
  calc
    (∑ j ∈ Finset.range M, if j<k then (1:ℝ) else 0) =
        ∑ j ∈ Finset.range k, if j<k then (1:ℝ) else 0 := by
      symm
      apply Finset.sum_subset (Finset.range_mono hk)
      intro j _ hj
      simp only [Finset.mem_range] at hj
      simp [hj]
    _ = (k:ℝ) := by
      calc
        _ = ∑ _j ∈ Finset.range k, (1:ℝ) := by
          apply Finset.sum_congr rfl
          intro j hj
          rw [if_pos (Finset.mem_range.mp hj)]
        _ = _ := by simp

/-- The requested n-sample comparison with selectors represented explicitly by
uniform labels in `Fin (card V)`, retaining the first 2n labels. -/
theorem initial_selector_to_iid_monotone (n : ℕ) (hn : 4 ≤ n)
    (hnV : 2*n ≤ Fintype.card V)
    (bad : Finset V → Prop) (hbad : ∀ S T : Finset V, S ⊆ T → bad S → bad T) :
    finiteEvent (fun s : Fin n → V => bad (sampleRange s)) ≤
      2*finiteEvent (fun ω : V → Fin (Fintype.card V) =>
        bad (selectedSet (initialSelector (Fintype.card V) (2*n)) ω))+
        (n:ℝ)*((n:ℝ)-1)/(2*(Fintype.card V:ℝ)) := by
  letI : Nonempty (Fin (Fintype.card V)) := Fin.pos_iff_nonempty.mp Fintype.card_pos
  apply selector_to_iid_monotone n _ hn _ bad hbad
  rw [initialSelector_probability hnV]
  have hM : (Fintype.card V:ℝ) ≠ 0 := Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  push_cast
  field_simp

end NeuralGeneralization.SquaredSampling
