import NeuralGeneralization.ParityError
import NeuralGeneralization.FunctionPrior

/-! The analytic ±1 parity and the Boolean target in the network statements agree exactly. -/
noncomputable section
namespace NeuralGeneralization
open scoped BigOperators
open ConcreteModel

lemma fullParity_eq_int_product {d : ℕ} (x : Cube d) :
    fullParity x = ((∏ i, if x i then (1 : ℤ) else -1) : ℝ) := by
  simp only [fullParity, Int.cast_prod]
  apply Finset.prod_congr rfl
  intro i _
  cases h : x i <;> simp [cubeCoordinateSign, h]

lemma labelReal_parity {d : ℕ} (x : Cube d) : labelReal (parity d x) = fullParity x := by
  have he : (∏ i, if x i then (1 : ℤ) else -1) = 1 ↔ fullParity x = 1 := by
    rw [fullParity_eq_int_product]
    exact_mod_cast (Iff.rfl : (∏ i, if x i then (1 : ℤ) else -1) = 1 ↔ _)
  simp only [parity, labelReal, decide_eq_true_eq, he]
  rcases fullParity_sign x with h | h <;> norm_num [h]

lemma labelReal_decide_nonneg (z : ℝ) : labelReal (decide (0 ≤ z)) = binarySign z := by
  simp [labelReal, binarySign]

lemma labelReal_injective : Function.Injective labelReal := by
  intro b c h
  cases b <;> cases c
  · rfl
  · norm_num [labelReal] at h
  · norm_num [labelReal] at h
  · rfl

lemma functionError_parity_eq {d : ℕ} (z : Cube d → ℝ) :
    functionError (uniformLaw d) (parity d) (fun x => decide (0 ≤ z x)) = uniformParityError z := by
  have he (x : Cube d) : decide (0 ≤ z x) = parity d x ↔ binarySign (z x) = fullParity x := by
    rw [← labelReal_decide_nonneg, ← labelReal_parity]
    exact labelReal_injective.eq_iff.symm
  simp only [functionError, he, uniformLaw, uniformParityError, uniformCubeMean,
    Finset.sum_div]
  apply Finset.sum_congr rfl
  intro x _
  split_ifs <;> simp

end NeuralGeneralization
