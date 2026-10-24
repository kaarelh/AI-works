import NeuralGeneralization.BatchTwoMergingCircuit
import NeuralGeneralization.Cloning

/-! # The Boolean compiler's exact row and readout energy bounds -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

namespace NorGate

theorem coefficients_sq_sum_le {I : Type*} [Fintype I] [DecidableEq I]
    (one : I) (g : NorGate I) : (∑ j, coefficients one g j ^ 2) ≤ 5 := by
  classical
  cases g with
  | copy i => simp [coefficients]
  | negate i =>
      by_cases hi : one = i
      · subst i; simp [coefficients]
      · simp [coefficients, sub_sq, mul_ite, ite_mul, Finset.sum_sub_distrib,
          Finset.sum_add_distrib, hi, Ne.symm hi] <;> norm_num
  | nor i j =>
      by_cases hi : one = i <;> by_cases hj : one = j <;> by_cases hij : i = j <;>
        simp_all [coefficients, sub_sq, mul_ite, ite_mul, Finset.sum_sub_distrib,
          Finset.sum_add_distrib, Finset.mul_sum, Finset.sum_mul] <;> norm_num

theorem firstCoefficients_sq_sum_le {d : ℕ} (g : NorGate (Fin (d + 1))) :
    (∑ j, firstCoefficients g j ^ 2) ≤ 1 := by
  classical
  cases g with
  | copy i =>
      by_cases hi : (0 : Fin (d + 1)) = i <;>
        simp_all [firstCoefficients, add_sq, mul_pow, mul_ite, ite_mul,
          Finset.sum_add_distrib, Finset.mul_sum, Finset.sum_mul] <;> norm_num
  | negate i =>
      by_cases hi : (0 : Fin (d + 1)) = i <;>
        simp_all [firstCoefficients, sub_sq, mul_pow, mul_ite, ite_mul,
          Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.mul_sum, Finset.sum_mul] <;> norm_num
  | nor i j =>
      by_cases hij : i = j <;>
        simp_all [firstCoefficients, sub_sq, mul_pow, mul_ite, ite_mul,
          Finset.sum_sub_distrib, Finset.sum_add_distrib, Finset.mul_sum, Finset.sum_mul] <;> norm_num

end NorGate

namespace LayeredNorCircuit

variable {d C r : ℕ}

theorem first_squaredSum_le (B : LayeredNorCircuit d C r) (a : ℝ) :
    (∑ i, ∑ j, B.weights a (Sum.inl (i, j)) ^ 2) ≤ C := by
  calc
    _ ≤ ∑ _i : Fin C, (1 : ℝ) := Finset.sum_le_sum fun i _ =>
      NorGate.firstCoefficients_sq_sum_le (B.first i)
    _ = _ := by simp

theorem internal_squaredSum_le (B : LayeredNorCircuit d C r) (a : ℝ) (s : Fin r) :
    (∑ i, ∑ j, B.weights a (Sum.inr (Sum.inl (s, i, j))) ^ 2) ≤ 5 * C := by
  calc
    _ ≤ ∑ _i : Fin C, (5 : ℝ) := Finset.sum_le_sum fun i _ =>
      NorGate.coefficients_sq_sum_le B.constant (B.internal s i)
    _ = _ := by simp [mul_comm]

theorem readout_squaredSum (B : LayeredNorCircuit d C r) (a : ℝ) :
    (∑ i, B.weights a (Sum.inr (Sum.inr i)) ^ 2) =
      if B.output = B.constant then a ^ 2 else 5 * a ^ 2 := by
  classical
  by_cases h : B.output = B.constant
  · have heq : ∀ i, B.weights a (Sum.inr (Sum.inr i)) ^ 2 =
        if B.constant = i then a ^ 2 else 0 := by
      intro i
      by_cases hi : B.constant = i <;> simp [weights, h, hi] <;> ring
    simp_rw [heq]
    simp [h]
  · have heq : ∀ i, B.weights a (Sum.inr (Sum.inr i)) ^ 2 =
        (if B.output = i then 4 * a ^ 2 else 0) +
          (if B.constant = i then a ^ 2 else 0) := by
      intro i
      by_cases ho : B.output = i <;> by_cases hc : B.constant = i
      · exact (h (ho.trans hc.symm)).elim
      · simp [weights, ho, hc]; ring
      · simp [weights, ho, hc]
      · simp [weights, ho, hc]
    simp_rw [heq]
    simp [h, Finset.sum_add_distrib]
    ring

theorem readout_squaredSum_bounds (B : LayeredNorCircuit d C r) (a : ℝ) :
    a ^ 2 ≤ (∑ i, B.weights a (Sum.inr (Sum.inr i)) ^ 2) ∧
      (∑ i, B.weights a (Sum.inr (Sum.inr i)) ^ 2) ≤ 5 * a ^ 2 := by
  rw [readout_squaredSum]
  split_ifs <;> constructor <;> nlinarith [sq_nonneg a]

theorem hiddenFold_weights_abs_le_one (B : LayeredNorCircuit d C r) (a : ℝ)
    (ss : List (Fin r)) (x : Cube d) (i : Fin C) :
    |ss.foldl (hiddenStep relu (B.weights a)) (firstHidden relu (B.weights a) x) i| ≤ 1 := by
  rw [B.firstHidden_weights, B.hiddenFold_weights a _ _ (B.firstBits_constant x)]
  exact (abs_of_nonneg (bitReal_nonneg _)).trans_le (bitReal_le_one _)

end LayeredNorCircuit

end NeuralGeneralization.BatchTwoMerging
