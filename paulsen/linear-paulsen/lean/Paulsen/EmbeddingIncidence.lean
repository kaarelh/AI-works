import Mathlib.Algebra.BigOperators.Field
import Mathlib.Tactic
import Mathlib.Data.Fin.Embedding
import Mathlib.Data.Fintype.Pi

/-!
# Incidence identities for injective row tuples

The uniform distribution on injective `d`-tuples of `n` indices has inclusion
marginal `d / n`. These elementary counting identities identify the center of the
Cauchy--Binet exponential sum.
-/

namespace Paulsen

open scoped BigOperators

/-- How often an index occurs in an injective tuple. This is zero or one;
the sum formula makes the marginal identities straightforward. -/
def embeddingIncidence {n d : ℕ} (f : Fin d ↪ Fin n) (i : Fin n) : ℝ :=
  ∑ j : Fin d, if f j = i then 1 else 0

theorem sum_embeddingIncidence {n d : ℕ} (f : Fin d ↪ Fin n) :
    (∑ i : Fin n, embeddingIncidence f i) = (d : ℝ) := by
  unfold embeddingIncidence
  rw [Finset.sum_comm]
  simp

/-- Summing coefficient times incidence recovers the sum along the tuple. -/
theorem sum_mul_embeddingIncidence {n d : ℕ}
    (c : Fin n → ℝ) (f : Fin d ↪ Fin n) :
    (∑ i : Fin n, c i * embeddingIncidence f i) = ∑ j : Fin d, c (f j) := by
  unfold embeddingIncidence
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]
  simp [mul_ite]

/-- Every index has the same number of occurrences among all injective tuples. -/
theorem sum_embeddingIncidence_eq {n d : ℕ} (i j : Fin n) :
    (∑ f : Fin d ↪ Fin n, embeddingIncidence f i) =
      ∑ f : Fin d ↪ Fin n, embeddingIncidence f j := by
  let e : (Fin d ↪ Fin n) ≃ (Fin d ↪ Fin n) :=
    Equiv.embeddingCongr (Equiv.refl (Fin d)) (Equiv.swap i j)
  calc
    (∑ f : Fin d ↪ Fin n, embeddingIncidence f i) =
        ∑ f : Fin d ↪ Fin n, embeddingIncidence (e f) j := by
      apply Finset.sum_congr rfl
      intro f _
      simp [embeddingIncidence, e, Equiv.swap_apply_eq_iff]
    _ = ∑ f : Fin d ↪ Fin n, embeddingIncidence f j :=
      e.sum_comp (fun f => embeddingIncidence f j)

/-- The average inclusion marginal of an injective tuple is `d / n`. -/
theorem embeddingIncidence_average {n d : ℕ} (hn : 0 < n) (hd : d ≤ n) (i : Fin n) :
    (∑ f : Fin d ↪ Fin n, embeddingIncidence f i) /
      (Fintype.card (Fin d ↪ Fin n) : ℝ) = (d : ℝ) / (n : ℝ) := by
  letI : Nonempty (Fin d ↪ Fin n) := ⟨Fin.castLEEmb hd⟩
  have hmass : (n : ℝ) * (∑ f : Fin d ↪ Fin n, embeddingIncidence f i) =
      (Fintype.card (Fin d ↪ Fin n) : ℝ) * (d : ℝ) := by
    calc
      (n : ℝ) * (∑ f : Fin d ↪ Fin n, embeddingIncidence f i) =
          ∑ _j : Fin n, ∑ f : Fin d ↪ Fin n, embeddingIncidence f i := by simp
      _ = ∑ j : Fin n, ∑ f : Fin d ↪ Fin n, embeddingIncidence f j := by
        apply Finset.sum_congr rfl
        intro j _
        exact sum_embeddingIncidence_eq i j
      _ = ∑ f : Fin d ↪ Fin n, ∑ j : Fin n, embeddingIncidence f j := Finset.sum_comm
      _ = (Fintype.card (Fin d ↪ Fin n) : ℝ) * (d : ℝ) := by
        simp [sum_embeddingIncidence]
  have hn0 : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hn)
  have hc0 : (Fintype.card (Fin d ↪ Fin n) : ℝ) ≠ 0 :=
    Nat.cast_ne_zero.mpr Fintype.card_ne_zero
  apply (div_eq_div_iff hc0 hn0).mpr
  simpa [mul_comm] using hmass

end Paulsen
