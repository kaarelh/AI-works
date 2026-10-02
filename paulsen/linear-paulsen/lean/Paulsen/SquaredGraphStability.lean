import Paulsen.HorizontalRetraction

/-! Squared-entry graph energies under a small rowwise matrix perturbation. -/

namespace Paulsen

open Matrix
open scoped BigOperators

theorem squared_graphEnergy_triangle {n : ℕ} (A B : Frame n n) (x : Fin n → ℝ) :
    graphEnergy (fun i j => A i j ^ 2) x ≤
      2 * graphEnergy (fun i j => B i j ^ 2) x +
        2 * graphEnergy (fun i j => (A i j - B i j) ^ 2) x := by
  have hsum : (∑ i, ∑ j, A i j ^ 2 * (x i - x j) ^ 2) ≤
      ∑ i, ∑ j, (2 * B i j ^ 2 + 2 * (A i j - B i j) ^ 2) * (x i - x j) ^ 2 := by
    apply Finset.sum_le_sum
    intro i _
    apply Finset.sum_le_sum
    intro j _
    apply mul_le_mul_of_nonneg_right _ (sq_nonneg _)
    nlinarith [sq_nonneg (A i j - 2 * B i j)]
  simp only [add_mul, Finset.sum_add_distrib, mul_assoc, ← Finset.mul_sum] at hsum
  dsimp only [graphEnergy]
  linarith

theorem squared_graphEnergy_le_of_row_bounds {n : ℕ} (E : Frame n n) (β : ℝ)
    (hsym : ∀ i j, E i j = E j i) (hrow : ∀ i, rowNormSq E i ≤ β) (x : Fin n → ℝ) :
    graphEnergy (fun i j => E i j ^ 2) x ≤ 2 * β * vectorNormSq x := by
  have hs : (∑ i, ∑ j, E i j ^ 2 * (x i - x j) ^ 2) ≤
      ∑ i, ∑ j, E i j ^ 2 * (2 * x i ^ 2 + 2 * x j ^ 2) := by
    apply Finset.sum_le_sum
    intro i _
    apply Finset.sum_le_sum
    intro j _
    apply mul_le_mul_of_nonneg_left _ (sq_nonneg _)
    nlinarith [sq_nonneg (x i + x j)]
  have hswap : (∑ i, ∑ j, E i j ^ 2 * x j ^ 2) =
      ∑ i, ∑ j, E i j ^ 2 * x i ^ 2 := by
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    rw [hsym j i]
  have hbound : (∑ i, ∑ j, E i j ^ 2 * x i ^ 2) ≤ β * vectorNormSq x := by
    simp only [← Finset.sum_mul, vectorNormSq, Finset.mul_sum]
    exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right (hrow i) (sq_nonneg _)
  have hexpand : (∑ i, ∑ j, E i j ^ 2 * (2 * x i ^ 2 + 2 * x j ^ 2)) =
      2 * (∑ i, ∑ j, E i j ^ 2 * x i ^ 2) +
        2 * (∑ i, ∑ j, E i j ^ 2 * x j ^ 2) := by
    simp only [Finset.mul_sum, ← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  rw [hexpand, hswap] at hs
  dsimp only [graphEnergy]
  linarith

/-- Upper and lower graph comparisons preserve the original graph metric;
only the small remainder is bounded in the ambient Euclidean metric. -/
theorem squared_graphEnergy_stability {n : ℕ} (A B : Frame n n) (β : ℝ)
    (hsymA : ∀ i j, A i j = A j i) (hsymB : ∀ i j, B i j = B j i)
    (hrow : ∀ i, rowNormSq (A - B) i ≤ β) (x : Fin n → ℝ) :
    (1 / 2 : ℝ) * graphEnergy (fun i j => A i j ^ 2) x -
        2 * β * vectorNormSq x ≤ graphEnergy (fun i j => B i j ^ 2) x ∧
      graphEnergy (fun i j => B i j ^ 2) x ≤
        2 * graphEnergy (fun i j => A i j ^ 2) x + 4 * β * vectorNormSq x := by
  have hE := squared_graphEnergy_le_of_row_bounds (A - B) β
    (fun i j => by simp only [Matrix.sub_apply, hsymA i j, hsymB i j]) hrow x
  have hE' : graphEnergy (fun i j => (B i j - A i j) ^ 2) x =
      graphEnergy (fun i j => (A i j - B i j) ^ 2) x := by
    congr 1
    funext i j
    ring
  have hAB := squared_graphEnergy_triangle A B x
  have hBA := squared_graphEnergy_triangle B A x
  rw [hE'] at hBA
  change graphEnergy (fun i j => (A i j - B i j) ^ 2) x ≤ _ at hE
  constructor <;> linarith

/-- A relative graph lower bound survives a rowwise fourth-order remainder. -/
theorem squared_graphEnergy_gap_stability {n : ℕ}
    (A B : Frame n n) (J : (Fin n → ℝ) → ℝ) (c s β : ℝ)
    (hsymA : ∀ i j, A i j = A j i) (hsymB : ∀ i j, B i j = B j i)
    (hrow : ∀ i, rowNormSq (A - B) i ≤ β)
    (hsmall : 8 * β ≤ c * s) (x : Fin n → ℝ) (hJ : 0 ≤ J x)
    (hlower : c * (J x + s * vectorNormSq x) ≤ graphEnergy (fun i j => A i j ^ 2) x)
    (hc : 0 ≤ c) :
    (c / 4) * (J x + s * vectorNormSq x) ≤ graphEnergy (fun i j => B i j ^ 2) x := by
  have h := (squared_graphEnergy_stability A B β hsymA hsymB hrow x).1
  have hsmall' := mul_le_mul_of_nonneg_right hsmall (vectorNormSq_nonneg x)
  nlinarith [mul_nonneg hc hJ]

end Paulsen
