import NeuralGeneralization.BoundedDual
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Data.Fintype.BigOperators

/-!
# Symmetrizing a finite quadratic tilt

The covariance observables are indexed by ordered pairs. A dual parameter
may therefore initially be an arbitrary matrix. Taking its symmetric part
preserves the quadratic potential and cannot increase its entrywise ℓ¹ norm.
-/

noncomputable section

open scoped BigOperators

namespace NeuralGeneralization.SymmetricTilt

variable {ι : Type*} [Fintype ι]

def symmPart (A : ι → ι → ℝ) (i j : ι) : ℝ := (A i j + A j i) / 2

def entryL1 (A : ι → ι → ℝ) : ℝ := ∑ i, ∑ j, |A i j|

def quadratic (A : ι → ι → ℝ) (z : ι → ℝ) : ℝ :=
  ∑ i, ∑ j, A i j * z i * z j

omit [Fintype ι] in
theorem symmPart_symmetric (A : ι → ι → ℝ) (i j : ι) :
    symmPart A i j = symmPart A j i := by
  simp only [symmPart, add_comm]

theorem entryL1_symmPart_le (A : ι → ι → ℝ) :
    entryL1 (symmPart A) ≤ entryL1 A := by
  have hswap : (∑ i, ∑ j, |A j i|) = entryL1 A := by
    exact Finset.sum_comm
  calc
    entryL1 (symmPart A) ≤ ∑ i, ∑ j, (|A i j| + |A j i|) / 2 := by
      apply Finset.sum_le_sum
      intro i hi
      apply Finset.sum_le_sum
      intro j hj
      rw [symmPart, abs_div, abs_of_pos (by norm_num : (0 : ℝ) < 2)]
      exact div_le_div_of_nonneg_right (abs_add_le _ _) (by norm_num)
    _ = (entryL1 A + entryL1 A) / 2 := by
      simp only [← Finset.sum_div, Finset.sum_add_distrib]
      rw [hswap]
      rfl
    _ = entryL1 A := by ring

theorem quadratic_transpose (A : ι → ι → ℝ) (z : ι → ℝ) :
    quadratic (fun i j => A j i) z = quadratic A z := by
  unfold quadratic
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro i hi
  apply Finset.sum_congr rfl
  intro j hj
  ring

theorem quadratic_symmPart (A : ι → ι → ℝ) (z : ι → ℝ) :
    quadratic (symmPart A) z = quadratic A z := by
  have heq : quadratic (symmPart A) z =
      (quadratic A z + quadratic (fun i j => A j i) z) / 2 := by
    unfold quadratic symmPart
    simp only [add_div, add_mul, Finset.sum_add_distrib]
    simp only [div_mul_eq_mul_div, ← Finset.sum_div]
  rw [heq, quadratic_transpose]
  ring

theorem flatten_entryL1 (A : ι → ι → ℝ) :
    BoundedDual.entryL1 (fun p : ι × ι => A p.1 p.2) = entryL1 A := by
  simp only [BoundedDual.entryL1, entryL1, Fintype.sum_prod_type]

end NeuralGeneralization.SymmetricTilt

end
