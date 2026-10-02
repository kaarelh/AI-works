import Paulsen.Definitions
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

/-! Finite frame energy bounds, including the zero-error endpoint. -/

namespace Paulsen

theorem frameEnergy_nonneg {n d : ℕ} (U : Frame n d) (x : Fin d → ℝ) :
    0 ≤ frameEnergy U x := Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem frameEnergy_le_total_energy {n d : ℕ} (U : Frame n d) (x : Fin d → ℝ) :
    frameEnergy U x ≤ (∑ i, rowNormSq U i) * vectorNormSq x := by
  unfold frameEnergy rowNormSq vectorNormSq
  rw [Finset.sum_mul]
  exact Finset.sum_le_sum fun i _ => Finset.sum_mul_sq_le_sq_mul_sq _ (U i) x

theorem IsEqualNorm.total_rowNormSq {n d : ℕ} {U : Frame n d}
    (hU : IsEqualNorm U) (hn : 0 < n) :
    (∑ i, rowNormSq U i) = (d : ℝ) := by
  have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hn)
  have heq : ∀ i, rowNormSq U i = (d : ℝ) / (n : ℝ) := hU
  simp_rw [heq]
  simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  field_simp

theorem IsNearlyEqualNorm.total_rowNormSq_le {n d : ℕ} {ε : ℝ} {U : Frame n d}
    (hU : IsNearlyEqualNorm ε U) (hn : 0 < n) :
    (∑ i, rowNormSq U i) ≤ (1 + ε) * (d : ℝ) := by
  have hnR : (n : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.ne_of_gt hn)
  calc
    (∑ i, rowNormSq U i) ≤ ∑ _i : Fin n, (1 + ε) * ((d : ℝ) / (n : ℝ)) :=
      Finset.sum_le_sum fun i _ => (hU i).2
    _ = _ := by
      simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
      field_simp

/-- An equal-row frame always has a finite (possibly very poor) spectral error. -/
theorem IsEqualNorm.isNearlyParseval_rank {n d : ℕ} {U : Frame n d}
    (hU : IsEqualNorm U) (hd : 0 < d) (hn : 0 < n) :
    IsNearlyParseval (d : ℝ) U := by
  intro x
  have hdR : (1 : ℝ) ≤ (d : ℝ) := by exact_mod_cast hd
  have hx := vectorNormSq_nonneg x
  have he := frameEnergy_nonneg U x
  have hb := frameEnergy_le_total_energy U x
  rw [hU.total_rowNormSq hn] at hb
  constructor
  · nlinarith [mul_nonpos_of_nonpos_of_nonneg (show 1 - (d : ℝ) ≤ 0 by linarith) hx]
  · nlinarith

theorem frameEnergy_basis {n d : ℕ} (U : Frame n d) (j : Fin d) :
    frameEnergy U (Pi.single j 1) = ∑ i, U i j ^ 2 := by
  simp [frameEnergy, Pi.single_apply, mul_ite]

theorem frameEnergy_basis_add {n d : ℕ} (U : Frame n d) (j k : Fin d) :
    frameEnergy U (Pi.single j 1 + Pi.single k 1) =
      (∑ i, U i j ^ 2) + 2 * (∑ i, U i j * U i k) + (∑ i, U i k ^ 2) := by
  simp only [frameEnergy, Pi.add_apply, mul_add, Finset.sum_add_distrib]
  simp only [Pi.single_apply, mul_ite, mul_one, mul_zero, Finset.sum_ite_eq',
    Finset.mem_univ, if_true]
  simp only [add_sq, Finset.sum_add_distrib, Finset.mul_sum, mul_assoc]

/-- Equality of all quadratic forms recovers the Parseval matrix identity. -/
theorem isParseval_of_frameEnergy_eq {n d : ℕ} (U : Frame n d)
    (hU : ∀ x, frameEnergy U x = vectorNormSq x) : IsParseval U := by
  have hdiag (j : Fin d) : (∑ i, U i j ^ 2) = 1 := by
    have h := hU (Pi.single j 1)
    rw [frameEnergy_basis] at h
    simpa [vectorNormSq, Pi.single_apply] using h
  apply (isParseval_iff_gram U).mpr
  intro j k
  by_cases hjk : j = k
  · subst k
    simpa [pow_two] using hdiag j
  · have h := hU (Pi.single j 1 + Pi.single k 1)
    rw [frameEnergy_basis_add, hdiag j, hdiag k] at h
    have hv : vectorNormSq (Pi.single j 1 + Pi.single k 1) = 2 := by
      simp only [vectorNormSq, Pi.add_apply, add_sq, Finset.sum_add_distrib]
      norm_num [Pi.single_apply, Ne.symm hjk]
    rw [hv] at h
    simp only [hjk, if_false]
    linarith

theorem isNearlyParseval_zero_iff {n d : ℕ} (U : Frame n d) :
    IsNearlyParseval 0 U ↔ IsParseval U := by
  constructor
  · intro h
    apply isParseval_of_frameEnergy_eq U
    intro x
    have hx := h x
    simp only [sub_zero, add_zero, one_mul] at hx
    exact le_antisymm hx.2 hx.1
  · intro h
    exact h.isNearlyParseval le_rfl

end Paulsen
