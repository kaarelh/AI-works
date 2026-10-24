import NeuralGeneralization.BatchTwoOnlinePermutation

/-!
# The finite relevant-class total-mistakes expectation theorem

All averages below are over the actual uniform random permutation law.
The displayed harmonic constant is the one in the manuscript.
-/
noncomputable section
open scoped BigOperators
open Classical
attribute [local instance] Classical.propDecidable

namespace NeuralGeneralization.BatchTwoOnline
open SquaredSampling

variable {H : Type*} [Fintype H] [DecidableEq H]

def harmonicSum (n : ℕ) : ℝ := ∑ i : Fin n, 1 / ((i.val : ℝ) + 1)

def permutationTotal {m : ℕ} (w : H → ℝ) (good : H → Fin m → Prop)
    (π : Equiv.Perm (Fin m)) : ℝ := ∑ i, permutationRound w good π i

lemma permutationRound_le_one {m : ℕ}
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (π : Equiv.Perm (Fin m)) (i : Fin m) : permutationRound w good π i ≤ 1 := by
  have hk : prefixKeep good π i.val target := fun j _ => htarget (π j)
  rw [← posterior_sum w _ hw target hk hwt]
  apply Finset.sum_le_sum
  intro g _
  exact mul_le_of_le_one_right (posterior_nonneg w _ hw target hk hwt g)
    (pointLoss_le_one good g (π i))

lemma reverse_harmonic (m : ℕ) :
    (∑ i : Fin m, 1 / ((m-i.val : ℕ) : ℝ)) = harmonicSum m := by
  have he := Equiv.sum_comp (Fin.revPerm : Equiv.Perm (Fin m))
    (fun i : Fin m => 1 / ((i.val : ℝ) + 1))
  unfold harmonicSum
  rw [← he]
  apply Finset.sum_congr rfl
  intro i _
  have hnat : (Fin.revPerm i).val + 1 = m-i.val := by
    change m - (i.val + 1) + 1 = m-i.val
    omega
  have hreal : (((Fin.revPerm i).val : ℕ) : ℝ) + 1 = (m-i.val : ℕ) := by
    exact_mod_cast hnat
  rw [hreal]

lemma harmonic_decomposition (m : ℕ) (b : ℝ) :
    (∑ i : Fin m,
      ((m+1 : ℕ) : ℝ) / (m+1-i.succ.val : ℕ) * (b/(i.succ.val : ℝ))) =
      2 * b * harmonicSum m := by
  have hterm (i : Fin m) :
      ((m+1 : ℕ) : ℝ) / (m+1-i.succ.val : ℕ) * (b/(i.succ.val : ℝ)) =
      b * (1/((i.val : ℝ)+1) + 1/(m-i.val : ℕ)) := by
    have he : m+1-i.succ.val = m-i.val := by simp only [Fin.val_succ]; omega
    have hmi : i.val ≤ m := i.isLt.le
    have hi0 : (i.val : ℝ)+1 ≠ 0 := by positivity
    have hm0 : (0 : ℝ) < (m-i.val : ℕ) := by exact_mod_cast Nat.sub_pos_of_lt i.isLt
    rw [he, Fin.val_succ, Nat.cast_add, Nat.cast_one, Nat.cast_add, Nat.cast_one]
    rw [Nat.cast_sub hmi]
    have hm0' : (m : ℝ)-(i.val : ℝ) ≠ 0 := by
      rw [Nat.cast_sub hmi] at hm0
      exact ne_of_gt hm0
    field_simp
    ring
  simp_rw [hterm, mul_add]
  rw [Finset.sum_add_distrib, ← Finset.mul_sum, ← Finset.mul_sum, reverse_harmonic]
  change b * harmonicSum m + b * harmonicSum m = _
  ring

/-- Main finite relevant-class expectation bound, with its exact harmonic
constant. The prior weights need not sum to one: the tail is measured relative
to the target weight, exactly as in the posterior formula. -/
theorem expected_permutationTotal_le (m : ℕ)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin (m+1) → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (h β : ℝ) (hh : 0 ≤ h)
    (hcard : (A.card : ℝ) ≤ Real.exp h)
    (htail : (∑ g ∈ Finset.univ \ A, w g) / w target ≤ β) :
    finiteMean (permutationTotal w good) ≤
      1 + 2*(h+1)*harmonicSum m + (m+1 : ℕ)*β := by
  have hβ : 0 ≤ β := (div_nonneg (Finset.sum_nonneg (fun g _ => hw g)) hwt.le).trans htail
  have hfirst : finiteMean (fun π : Equiv.Perm (Fin (m+1)) =>
      permutationRound w good π 0) ≤ 1 := by
    calc
      _ ≤ finiteMean (fun _π : Equiv.Perm (Fin (m+1)) => (1 : ℝ)) :=
        finiteMean_mono fun π => permutationRound_le_one w hw good target htarget hwt π 0
      _ = _ := finiteMean_const _
  have hrest : (∑ i : Fin m, finiteMean (fun π : Equiv.Perm (Fin (m+1)) =>
      permutationRound w good π i.succ)) ≤
      2*(h+1)*harmonicSum m + m*β := by
    calc
      _ ≤ ∑ i : Fin m,
          (((m+1 : ℕ) : ℝ)/(m+1-i.succ.val : ℕ) * ((h+1)/i.succ.val) + β) := by
        apply Finset.sum_le_sum
        intro i _
        exact expected_permutationRound_le w hw good target htarget hwt A h β hh hcard htail
          i.succ (by simp)
      _ = _ := by
        rw [Finset.sum_add_distrib, harmonic_decomposition]
        simp
  unfold permutationTotal
  rw [finiteMean_sum, Fin.sum_univ_succ]
  have hsum := add_le_add hfirst hrest
  push_cast
  nlinarith

/-- The same theorem with the domain size itself as parameter. -/
theorem expected_permutationTotal_le_general (m : ℕ) (hm : 0 < m)
    (w : H → ℝ) (hw : ∀ g, 0 ≤ w g) (good : H → Fin m → Prop)
    (target : H) (htarget : ∀ x, good target x) (hwt : 0 < w target)
    (A : Finset H) (h β : ℝ) (hh : 0 ≤ h)
    (hcard : (A.card : ℝ) ≤ Real.exp h)
    (htail : (∑ g ∈ Finset.univ \ A, w g) / w target ≤ β) :
    finiteMean (permutationTotal w good) ≤
      1 + 2*(h+1)*harmonicSum (m-1) + m*β := by
  obtain ⟨k, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (Nat.ne_of_gt hm)
  simpa only [Nat.succ_eq_add_one, Nat.add_sub_cancel] using
    expected_permutationTotal_le k w hw good target htarget hwt A h β hh hcard htail

end NeuralGeneralization.BatchTwoOnline
