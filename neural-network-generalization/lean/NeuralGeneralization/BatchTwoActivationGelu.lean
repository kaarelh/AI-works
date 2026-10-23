import NeuralGeneralization.BatchTwoActivationStrongPrior
import NeuralGeneralization.BatchTwoMergingGeluCircuitNorm

/-! Exact GELU belongs to the unbounded activation class. Its same-depth
Boolean compiler has two neurons per wire and every weight at most four.
The analytic CDF and compiler proofs are shared with the merging manuscript. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel BatchTwoMerging

theorem gelu_zeroLipschitz : zeroLipschitzActivation 2 gelu := by
  refine ⟨gelu_zero,?_⟩
  intro x y
  simpa only [Real.dist_eq,NNReal.coe_ofNat] using gelu_lipschitz.dist_le_mul x y

theorem boolean_gate_coefficient_abs_le_two {I : Type*} [DecidableEq I]
    (one : I) (g : NorGate I) (i : I) : |NorGate.coefficients one g i|≤2 := by
  cases g <;> simp only [NorGate.coefficients] <;> split_ifs <;> norm_num

theorem boolean_first_coefficient_abs_le_one {d : ℕ} (g : NorGate (Fin (d+1)))
    (i : Fin (d+1)) : |NorGate.firstCoefficients g i|≤1 := by
  cases g <;> simp only [NorGate.firstCoefficients] <;> split_ifs <;> norm_num

theorem boolean_compiler_weight_abs_le_two {d C r : ℕ} (B : LayeredNorCircuit d C r)
    (i : WeightIndex d C r) : |B.weights 1 i|≤2 := by
  rcases i with ⟨i,j⟩|i
  · exact (boolean_first_coefficient_abs_le_one (B.first i) j).trans (by norm_num)
  · rcases i with ⟨s,i,j⟩|i
    · exact boolean_gate_coefficient_abs_le_two B.constant (B.internal s i) j
    · simp only [LayeredNorCircuit.weights,one_mul]
      split_ifs <;> norm_num

theorem pairSign_abs_one {C : ℕ} (i : Fin C ⊕ Fin C) : |pairSign i|=1 := by
  cases i <;> norm_num [pairSign]

theorem pairDecode_abs_le_two {C : ℕ} (i : Fin C ⊕ Fin C) : |pairDecode i|≤2 := by
  obtain ⟨ha,ha2,hb,hb1⟩ := geluDecode_bounds
  cases i with
  | inl i => simpa only [pairDecode,abs_of_nonneg ha] using ha2
  | inr i => simpa only [pairDecode,abs_of_nonneg hb] using hb1.trans (by norm_num : (1:ℝ)≤2)

theorem gelu_compiler_weight_abs_le_four {d C r : ℕ} (B : LayeredNorCircuit d C r)
    (i : WeightIndex d (2*C) r) : |B.geluWeights 1 i|≤4 := by
  rcases i with ⟨i,j⟩|i
  · simp only [LayeredNorCircuit.geluWeights,abs_mul,pairSign_abs_one,one_mul]
    exact (boolean_compiler_weight_abs_le_two B _).trans (by norm_num)
  · rcases i with ⟨s,i,j⟩|i
    · simp only [LayeredNorCircuit.geluWeights,abs_mul,pairSign_abs_one,one_mul]
      calc
        _ ≤ 2*2 := mul_le_mul (boolean_compiler_weight_abs_le_two B _) (pairDecode_abs_le_two _)
          (abs_nonneg _) (by norm_num)
        _ = 4 := by norm_num
    · simp only [LayeredNorCircuit.geluWeights,abs_mul]
      calc
        _ ≤ 2*2 := mul_le_mul (boolean_compiler_weight_abs_le_two B _) (pairDecode_abs_le_two _)
          (abs_nonneg _) (by norm_num)
        _ = 4 := by norm_num

/-- Exact same-depth GELU compilation, including the paper's weight constant. -/
theorem exact_same_depth_gelu_compilation {d C r : ℕ} (B : LayeredNorCircuit d C r) :
    ∃w : Weights d (2*C) r, (∀i,|w i|≤4) ∧
      ∀x,networkOutput gelu w x=labelReal (B.computes x) := by
  refine ⟨B.geluWeights 1,gelu_compiler_weight_abs_le_four B,?_⟩
  intro x
  simpa only [one_mul] using B.gelu_networkOutput 1 x

end NeuralGeneralization.BatchTwoActivation
