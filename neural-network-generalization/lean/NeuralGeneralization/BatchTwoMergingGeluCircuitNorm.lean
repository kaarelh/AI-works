import NeuralGeneralization.BatchTwoMergingGeluCircuit

/-! Actual coefficient norms and bounded digital states of the GELU compiler. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel

theorem geluDecodeA_ge_one : 1≤geluDecodeA := by
  have ht := normalCDF_one_gt_two_thirds
  have hu := (normalCDF_bounds 1).2
  unfold geluDecodeA
  apply (le_div_iff₀ (show 0<2*normalCDF 1-1 by linarith)).mpr
  linarith

theorem geluDecodeNorm_bounds : 1≤geluDecodeA^2+geluDecodeB^2 ∧
    geluDecodeA^2+geluDecodeB^2≤5 := by
  obtain ⟨ha,ha2,hb,hb1⟩ := geluDecode_bounds
  have ha1 := geluDecodeA_ge_one
  constructor <;> nlinarith [sq_nonneg geluDecodeB]

theorem abs_trit_le_one {u : ℝ} (hu : u=-1 ∨ u=0 ∨ u=1) : |u|≤1 := by
  rcases hu with rfl|rfl|rfl <;> norm_num

namespace LayeredNorCircuit
variable {d C r : ℕ}

theorem gelu_first_bound (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d)
    (i : Fin (2*C)) : |firstHidden gelu (B.geluWeights a) x i|≤1 := by
  obtain ⟨j,rfl⟩ := (pairedIndex C).surjective i
  cases j with
  | inl j=>
    change |firstHidden gelu (B.geluWeights a) x (positiveIndex j)|≤1
    rw [B.gelu_first_positive]
    exact (gelu_abs_le _).trans (abs_trit_le_one (NorGate.firstCoefficients_sum_trit (B.first j) x))
  | inr j=>
    change |firstHidden gelu (B.geluWeights a) x (negativeIndex j)|≤1
    rw [B.gelu_first_negative]
    exact (gelu_abs_le _).trans (by rw [abs_neg]; exact abs_trit_le_one (NorGate.firstCoefficients_sum_trit (B.first j) x))

theorem gelu_step_bound (B : LayeredNorCircuit d C r) (a : ℝ)
    (h : Fin (2*C)→ℝ) (bits : Fin C→Bool) (hconst : bits B.constant=true)
    (hdecode : ∀j,decodedPair h j=bitReal (bits j)) (s : Fin r) (i : Fin (2*C)) :
    |hiddenStep gelu (B.geluWeights a) h s i|≤1 := by
  unfold hiddenStep
  rw [B.gelu_internal_sum]
  simp_rw [hdecode]
  apply (gelu_abs_le _).trans
  rw [abs_mul]
  have hs : |pairSign ((pairedIndex C).symm i)|=1 := by
    cases (pairedIndex C).symm i <;> simp [pairSign]
  rw [hs,one_mul]
  exact abs_trit_le_one (NorGate.coefficient_sum_trit B.constant
    (B.internal s (pairSource ((pairedIndex C).symm i))) bits hconst)

theorem gelu_fold_bound (B : LayeredNorCircuit d C r) (a : ℝ)
    (ss : List (Fin r)) (h : Fin (2*C)→ℝ) (bits : Fin C→Bool)
    (hconst : bits B.constant=true) (hdecode : ∀j,decodedPair h j=bitReal (bits j))
    (hbound : ∀j,|h j|≤1) :
    ∀i,|ss.foldl (hiddenStep gelu (B.geluWeights a)) h i|≤1 := by
  induction ss generalizing h bits with
  | nil=>exact hbound
  | cons s ss ih=>
    simp only [List.foldl_cons]
    exact ih _ _ (B.stepBits_constant bits hconst s)
      (B.gelu_step_decode a h bits hconst hdecode s) (B.gelu_step_bound a h bits hconst hdecode s)

theorem gelu_hiddenFold_abs_le_one (B : LayeredNorCircuit d C r) (a : ℝ)
    (ss : List (Fin r)) (x : Cube d) :
    ∀i,|ss.foldl (hiddenStep gelu (B.geluWeights a))
      (firstHidden gelu (B.geluWeights a) x) i|≤1 :=
  B.gelu_fold_bound a ss _ _ (B.firstBits_constant x) (B.gelu_first_decode a x) (B.gelu_first_bound a x)

theorem gelu_first_squaredSum (B : LayeredNorCircuit d C r) (a : ℝ) :
    (∑i,∑j,B.geluWeights a (.inl (i,j))^2)=2*∑i,∑j,B.weights a (.inl (i,j))^2 := by
  rw [paired_sum]
  simp only [geluWeights,positiveIndex,negativeIndex,Equiv.symm_apply_apply,
    pairSource,pairSign,one_mul,neg_one_mul,neg_sq]
  ring

theorem gelu_internal_squaredSum (B : LayeredNorCircuit d C r) (a : ℝ) (s : Fin r) :
    (∑i,∑j,B.geluWeights a (.inr (.inl (s,i,j)))^2)=
      2*(geluDecodeA^2+geluDecodeB^2)*∑i,∑j,B.weights a (.inr (.inl (s,i,j)))^2 := by
  rw [paired_sum]
  simp_rw [paired_sum]
  simp only [geluWeights,positiveIndex,negativeIndex,Equiv.symm_apply_apply,
    pairSource,pairSign,pairDecode,one_mul,neg_one_mul,mul_pow,neg_sq,
    ←Finset.sum_mul]
  simp only [Finset.sum_add_distrib,←Finset.sum_mul,←Finset.mul_sum]
  ring

theorem gelu_readout_squaredSum (B : LayeredNorCircuit d C r) (a : ℝ) :
    (∑i,B.geluWeights a (.inr (.inr i))^2)=
      (geluDecodeA^2+geluDecodeB^2)*∑i,B.weights a (.inr (.inr i))^2 := by
  rw [paired_sum]
  simp only [geluWeights,positiveIndex,negativeIndex,Equiv.symm_apply_apply,
    pairSource,pairDecode,mul_pow,←Finset.sum_mul]
  ring

theorem gelu_first_squaredSum_le (B : LayeredNorCircuit d C r) (a : ℝ) :
    (∑i,∑j,B.geluWeights a (.inl (i,j))^2)≤2*C := by
  rw [B.gelu_first_squaredSum]
  linarith [B.first_squaredSum_le a]

theorem gelu_internal_squaredSum_le (B : LayeredNorCircuit d C r) (a : ℝ) (s : Fin r) :
    (∑i,∑j,B.geluWeights a (.inr (.inl (s,i,j)))^2)≤25*(2*C) := by
  rw [B.gelu_internal_squaredSum]
  have hn : 0≤∑i,∑j,B.weights a (.inr (.inl (s,i,j)))^2 := by positivity
  have hm := mul_le_mul geluDecodeNorm_bounds.2 (B.internal_squaredSum_le a s) hn (by norm_num : (0:ℝ)≤5)
  nlinarith

theorem gelu_readout_squaredSum_bounds (B : LayeredNorCircuit d C r) (a : ℝ) :
    a^2≤(∑i,B.geluWeights a (.inr (.inr i))^2) ∧
      (∑i,B.geluWeights a (.inr (.inr i))^2)≤25*a^2 := by
  rw [B.gelu_readout_squaredSum]
  have hn : 0≤∑i,B.weights a (.inr (.inr i))^2 := by positivity
  have hlo := mul_le_mul_of_nonneg_right geluDecodeNorm_bounds.1 hn
  have hhi := mul_le_mul geluDecodeNorm_bounds.2 (B.readout_squaredSum_bounds a).2 hn (by norm_num : (0:ℝ)≤5)
  constructor <;> nlinarith [(B.readout_squaredSum_bounds a).1]

end LayeredNorCircuit
end NeuralGeneralization.BatchTwoMerging
