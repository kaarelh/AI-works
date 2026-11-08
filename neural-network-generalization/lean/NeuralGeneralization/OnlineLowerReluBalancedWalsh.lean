import NeuralGeneralization.OnlineLowerReluKappa
import NeuralGeneralization.OnlineLowerOrbitSynthesis
import Mathlib.Data.Fintype.BigOperators

/-! # The balanced ReLU coefficient in the literal neural-network model -/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLowerRelu

def negativeSetEquiv (d : ℕ) : ClippingCube d ≃ Finset (Fin d) where
  toFun x := Finset.univ.filter (fun i => x i = false)
  invFun S i := decide (i ∉ S)
  left_inv x := by
    funext i
    cases h : x i <;> simp [h]
  right_inv S := by
    ext i
    simp

theorem negativeSet_sign (d : ℕ) (S : Finset (Fin d)) (i : Fin d) :
    cubeCoordinateSign ((negativeSetEquiv d).symm S i) = if i ∈ S then -1 else 1 := by
  simp [negativeSetEquiv, cubeCoordinateSign]

theorem negativeSet_full_parity (d : ℕ) (S : Finset (Fin d)) :
    walshCharacter Finset.univ ((negativeSetEquiv d).symm S) = (-1 : ℝ) ^ S.card := by
  unfold walshCharacter
  simp_rw [negativeSet_sign]
  simp

theorem negativeSet_sum_signs (d : ℕ) (S : Finset (Fin d)) :
    (∑ i, cubeCoordinateSign ((negativeSetEquiv d).symm S i)) =
      (d : ℝ) - 2 * S.card := by
  simp_rw [negativeSet_sign]
  have hterm (i : Fin d) : (if i ∈ S then (-1 : ℝ) else 1) =
      1 - 2 * (if i ∈ S then (1 : ℝ) else 0) := by
    split_ifs <;> norm_num
  simp_rw [hterm, Finset.sum_sub_distrib, ← Finset.mul_sum]
  simp

def balancedIncoming (d : ℕ) : Fin (d + 1) → ℝ := Fin.cases 0 (fun _ => 1)

theorem balancedIncoming_score (d : ℕ) (x : ClippingCube d) :
    OnlineLower.atomOutput (fun t => max t 0) (balancedIncoming d) x =
      max (∑ i, cubeCoordinateSign (x i)) 0 := by
  unfold OnlineLower.atomOutput
  rw [Fin.sum_univ_succ]
  simp [balancedIncoming, ConcreteModel.inputVector, ConcreteModel.labelReal, cubeCoordinateSign]

theorem balancedIncoming_cost (d : ℕ) :
    OnlineLower.incomingAtomCost (balancedIncoming d) = (d : ℝ) ^ 2 := by
  unfold OnlineLower.incomingAtomCost
  rw [Fin.sum_univ_succ]
  simp [balancedIncoming, pow_two]

theorem balanced_relu_walsh_subset_formula (d : ℕ) :
    walshCoefficients (OnlineLower.atomOutput (fun t => max t 0) (balancedIncoming d)) Finset.univ =
      (∑ S : Finset (Fin d), (-1 : ℝ) ^ S.card *
        max ((d : ℝ) - 2 * S.card) 0) / (2 : ℝ) ^ d := by
  unfold walshCoefficients uniformCubeMean
  rw [← Equiv.sum_comp (negativeSetEquiv d).symm]
  simp_rw [balancedIncoming_score, negativeSet_sum_signs, negativeSet_full_parity]
  simp only [ClippingCube, Fintype.card_fun, Fintype.card_bool, Fintype.card_fin,
    Nat.cast_pow, Nat.cast_ofNat]
  congr 1
  apply Finset.sum_congr rfl
  intro S _
  ring

/-- The exact normalized full-parity coefficient used by the orbit
synthesis theorem, in the existing augmented-input network convention. -/
theorem balanced_relu_walsh_exact (r : ℕ) :
    walshCoefficients
      (OnlineLower.atomOutput (fun t => max t 0) (balancedIncoming (2 * r + 2))) Finset.univ =
      (-1 : ℝ) ^ r * evenReluKappa r := by
  rw [balanced_relu_walsh_subset_formula]
  have hscore (S : Finset (Fin (2 * r + 2))) :
      ((2 * r + 2 : ℕ) : ℝ) - 2 * S.card = (2 : ℝ) * (r + 1) - 2 * S.card := by
    push_cast
    ring
  simp_rw [hscore]
  rw [balanced_relu_subset_parity]
  unfold evenReluKappa Nat.centralBinom
  ring

theorem balanced_relu_walsh_abs (r : ℕ) :
    |walshCoefficients
      (OnlineLower.atomOutput (fun t => max t 0) (balancedIncoming (2 * r + 2))) Finset.univ| =
      evenReluKappa r := by
  rw [balanced_relu_walsh_exact, abs_mul, abs_pow]
  simp [abs_of_pos (evenReluKappa_pos r)]

end NeuralGeneralization.OnlineLowerRelu
