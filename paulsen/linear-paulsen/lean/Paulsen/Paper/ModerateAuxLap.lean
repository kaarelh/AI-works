import Paulsen.Paper.Gaussian
import Paulsen.Linear.ModerateDrift
import Paulsen.SmoothRationalCovariance
import Paulsen.SmoothExpectedExpansion

/-!
# Helpers for `Paulsen.Paper.Moderate`: quadratic forms and edge Laplacians

Generic facts (no paper definitions) about `matrixQuadratic`, sums over pairs `i < j`, and
the edge Laplacian `∑_{i<j} c_{ij} (e_i - e_j)(e_i - e_j)ᵀ`.
-/

namespace Paulsen.Paper.ModerateAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

variable {ι : Type*} [Fintype ι]

theorem mq_eq_dot (A : Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic A x = x ⬝ᵥ (A *ᵥ x) := by
  simp only [matrixQuadratic, dotProduct, Matrix.mulVec, Finset.mul_sum, mul_assoc]

theorem mq_add (A B : Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (A + B) x = matrixQuadratic A x + matrixQuadratic B x := by
  simp only [matrixQuadratic, Matrix.add_apply, mul_add, add_mul, Finset.sum_add_distrib]

theorem mq_smul (c : ℝ) (A : Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (c • A) x = c * matrixQuadratic A x := by
  simp only [matrixQuadratic, Matrix.smul_apply, smul_eq_mul, Finset.mul_sum]
  apply Finset.sum_congr rfl; intro i _; apply Finset.sum_congr rfl; intro j _; ring

theorem mq_zero (x : ι → ℝ) : matrixQuadratic (0 : Matrix ι ι ℝ) x = 0 := by
  simp [matrixQuadratic]

theorem mq_sum {κ : Type*} (s : Finset κ) (A : κ → Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (∑ t ∈ s, A t) x = ∑ t ∈ s, matrixQuadratic (A t) x := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [mq_zero]
  | insert a s ha ih => rw [Finset.sum_insert ha, Finset.sum_insert ha, mq_add, ih]

theorem mq_ite (c : Prop) [Decidable c] (A : Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (if c then A else 0) x = if c then matrixQuadratic A x else 0 := by
  split_ifs <;> simp [mq_zero]

theorem mq_vecMulVec (u v x : ι → ℝ) :
    matrixQuadratic (Matrix.vecMulVec u v) x = (∑ i, x i * u i) * ∑ j, v j * x j := by
  rw [Finset.sum_mul_sum]
  simp only [matrixQuadratic, Matrix.vecMulVec_apply]
  apply Finset.sum_congr rfl; intro i _; apply Finset.sum_congr rfl; intro j _; ring

theorem sum_mul_edge {n : ℕ} (x : Fin n → ℝ) (i j : Fin n) :
    ∑ k, x k * (Pi.single i (1 : ℝ) - Pi.single j 1 : Fin n → ℝ) k = x i - x j := by
  simp [Pi.single_apply, mul_sub, Finset.sum_sub_distrib]

theorem sum_edge_mul {n : ℕ} (x : Fin n → ℝ) (i j : Fin n) :
    ∑ k, (Pi.single i (1 : ℝ) - Pi.single j 1 : Fin n → ℝ) k * x k = x i - x j := by
  simp [Pi.single_apply, sub_mul, Finset.sum_sub_distrib]

/-- The quadratic form of an edge Laplacian. -/
theorem mq_edgeLap {n : ℕ} (c : Fin n → Fin n → ℝ) (x : Fin n → ℝ) :
    matrixQuadratic (∑ i, ∑ j, if i < j then (c i j) • Matrix.vecMulVec
      (Pi.single i (1 : ℝ) - Pi.single j 1 : Fin n → ℝ)
      (Pi.single i (1 : ℝ) - Pi.single j 1 : Fin n → ℝ) else 0) x =
      ∑ i, ∑ j, if i < j then c i j * (x i - x j) ^ 2 else 0 := by
  rw [mq_sum]
  apply Finset.sum_congr rfl; intro i _
  rw [mq_sum]
  apply Finset.sum_congr rfl; intro j _
  rw [mq_ite, mq_smul, mq_vecMulVec, sum_mul_edge, sum_edge_mul, sq]

/-- Half of a symmetric double sum with vanishing diagonal is the sum over `i < j`. -/
theorem sum_lt_eq_half {n : ℕ} (f : Fin n → Fin n → ℝ) (hsym : ∀ i j, f i j = f j i)
    (hdiag : ∀ i, f i i = 0) :
    (∑ i, ∑ j, if i < j then f i j else 0) = (1 / 2) * ∑ i, ∑ j, f i j := by
  have hsplit : ∀ i j, f i j = (if i < j then f i j else 0) + (if j < i then f j i else 0) := by
    intro i j
    rcases lt_trichotomy i j with h | h | h
    · simp [h, not_lt.mpr h.le]
    · subst h; simp [hdiag]
    · simp [h, not_lt.mpr h.le, hsym i j]
  have hswap : (∑ i, ∑ j, if j < i then f j i else 0) =
      ∑ i, ∑ j, if i < j then f i j else 0 := Finset.sum_comm
  have : (∑ i, ∑ j, f i j) = 2 * ∑ i, ∑ j, if i < j then f i j else 0 := by
    calc (∑ i, ∑ j, f i j) = ∑ i, ∑ j, ((if i < j then f i j else 0) +
          (if j < i then f j i else 0)) := by
          apply Finset.sum_congr rfl; intro i _; apply Finset.sum_congr rfl; intro j _
          exact hsplit i j
      _ = _ := by simp only [Finset.sum_add_distrib, hswap]; ring
  rw [this]; ring

/-- The edge Laplacian with symmetric weights is the graph energy. -/
theorem mq_edgeLap_eq_graphEnergy {n : ℕ} (c : Fin n → Fin n → ℝ)
    (hc : ∀ i j, c i j = c j i) (x : Fin n → ℝ) :
    matrixQuadratic (∑ i, ∑ j, if i < j then (c i j) • Matrix.vecMulVec
      (Pi.single i (1 : ℝ) - Pi.single j 1 : Fin n → ℝ)
      (Pi.single i (1 : ℝ) - Pi.single j 1 : Fin n → ℝ) else 0) x =
      graphEnergy (Matrix.of c) x := by
  rw [mq_edgeLap, sum_lt_eq_half (fun i j => c i j * (x i - x j) ^ 2)
    (fun i j => by rw [hc i j]; ring) (fun i => by simp)]
  simp [graphEnergy]

end

end Paulsen.Paper.ModerateAux
