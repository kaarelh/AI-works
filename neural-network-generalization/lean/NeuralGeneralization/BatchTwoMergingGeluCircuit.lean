import NeuralGeneralization.BatchTwoMergingGeluDecoder

/-! Exact same-depth two-neuron compilation of each Boolean gate into GELU. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoMerging
open ConcreteModel
open Classical

def pairedIndex (C : ℕ) : (Fin C⊕Fin C)≃Fin (2*C) :=
  finSumFinEquiv.trans (finCongr (by omega : C+C=2*C))

def positiveIndex {C : ℕ} (i : Fin C) : Fin (2*C) := pairedIndex C (Sum.inl i)
def negativeIndex {C : ℕ} (i : Fin C) : Fin (2*C) := pairedIndex C (Sum.inr i)

theorem paired_sum {C : ℕ} (f : Fin (2*C)→ℝ) :
    (∑ i,f i)=(∑ i,f (positiveIndex i))+(∑ i,f (negativeIndex i)) := by
  rw [←(pairedIndex C).sum_comp f,Fintype.sum_sum_type]
  rfl

def pairSource {C : ℕ} : Fin C⊕Fin C→Fin C
  | .inl i=>i
  | .inr i=>i
def pairSign {C : ℕ} : Fin C⊕Fin C→ℝ
  | .inl _=>1
  | .inr _=>-1
def pairDecode {C : ℕ} : Fin C⊕Fin C→ℝ
  | .inl _=>geluDecodeA
  | .inr _=>geluDecodeB

def decodedPair {C : ℕ} (h : Fin (2*C)→ℝ) (i : Fin C) : ℝ :=
  geluDecodeA*h (positiveIndex i)+geluDecodeB*h (negativeIndex i)

namespace NorGate

theorem coefficient_sum_trit {I : Type*} [Fintype I] [DecidableEq I]
    (one : I) (g : NorGate I) (h : I→Bool) (hconst : h one=true) :
    (∑j,coefficients one g j*bitReal (h j))=-1 ∨
    (∑j,coefficients one g j*bitReal (h j))=0 ∨
    (∑j,coefficients one g j*bitReal (h j))=1 := by
  rw [coefficient_sum]
  cases g with
  | copy i=>cases hi:h i <;> norm_num [hi,bitReal]
  | negate i=>cases hi:h i <;> norm_num [hi,hconst,bitReal]
  | nor i j=>cases hi:h i <;> cases hj:h j <;> norm_num [hi,hj,hconst,bitReal]

theorem firstCoefficients_sum_trit {d : ℕ} (g : NorGate (Fin (d+1))) (x : Cube d) :
    (∑j,firstCoefficients g j*inputVector x j)=-1 ∨
    (∑j,firstCoefficients g j*inputVector x j)=0 ∨
    (∑j,firstCoefficients g j*inputVector x j)=1 := by
  rw [firstCoefficients_sum]
  cases g with
  | copy i=>
    dsimp only
    rw [inputVector_eq_labelReal]
    cases hi:(Fin.cases true x i:Bool) <;> norm_num [hi,labelReal]
  | negate i=>
    dsimp only
    rw [inputVector_eq_labelReal]
    cases hi:(Fin.cases true x i:Bool) <;> norm_num [hi,labelReal]
  | nor i j=>
    dsimp only
    rw [inputVector_eq_labelReal,inputVector_eq_labelReal]
    cases hi:(Fin.cases true x i:Bool) <;> cases hj:(Fin.cases true x j:Bool) <;>
      norm_num [hi,hj,labelReal]

end NorGate

namespace LayeredNorCircuit
variable {d C r : ℕ}

def geluWeights (B : LayeredNorCircuit d C r) (a : ℝ) : Weights d (2*C) r
  | .inl (i,j)=>pairSign ((pairedIndex C).symm i)*
      B.weights a (.inl (pairSource ((pairedIndex C).symm i),j))
  | .inr (.inl (s,i,j))=>pairSign ((pairedIndex C).symm i)*
      B.weights a (.inr (.inl (s,pairSource ((pairedIndex C).symm i),
        pairSource ((pairedIndex C).symm j))))*pairDecode ((pairedIndex C).symm j)
  | .inr (.inr i)=>B.weights a (.inr (.inr (pairSource ((pairedIndex C).symm i))))*
      pairDecode ((pairedIndex C).symm i)

theorem gelu_first_positive (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d) (i : Fin C) :
    firstHidden gelu (B.geluWeights a) x (positiveIndex i)=
      gelu (∑j,(B.first i).firstCoefficients j*inputVector x j) := by
  simp [firstHidden,geluWeights,positiveIndex,pairSign,pairSource,weights]

theorem gelu_first_negative (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d) (i : Fin C) :
    firstHidden gelu (B.geluWeights a) x (negativeIndex i)=
      gelu (-(∑j,(B.first i).firstCoefficients j*inputVector x j)) := by
  simp [firstHidden,geluWeights,negativeIndex,pairSign,pairSource,weights,
    ←Finset.sum_neg_distrib]

theorem gelu_first_decode (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d) (i : Fin C) :
    decodedPair (firstHidden gelu (B.geluWeights a) x) i=bitReal (B.firstBits x i) := by
  rw [decodedPair,B.gelu_first_positive,B.gelu_first_negative,
    geluDecode_identity (NorGate.firstCoefficients_sum_trit (B.first i) x)]
  exact NorGate.relu_firstCoefficients (B.first i) x

theorem gelu_internal_sum (B : LayeredNorCircuit d C r) (a : ℝ)
    (h : Fin (2*C)→ℝ) (s : Fin r) (i : Fin (2*C)) :
    (∑j,B.geluWeights a (.inr (.inl (s,i,j)))*h j)=
      pairSign ((pairedIndex C).symm i)*
      ∑j,(B.internal s (pairSource ((pairedIndex C).symm i))).coefficients B.constant j*
        decodedPair h j := by
  rw [paired_sum]
  simp only [geluWeights,positiveIndex,negativeIndex,Equiv.symm_apply_apply,
    pairSource,pairDecode,weights,decodedPair,Finset.mul_sum,Finset.sum_add_distrib,mul_add]
  congr 1 <;> apply Finset.sum_congr rfl <;> intro j _ <;> ring

theorem gelu_step_decode (B : LayeredNorCircuit d C r) (a : ℝ)
    (h : Fin (2*C)→ℝ) (bits : Fin C→Bool) (hconst : bits B.constant=true)
    (hdecode : ∀i,decodedPair h i=bitReal (bits i)) (s : Fin r) (i : Fin C) :
    decodedPair (hiddenStep gelu (B.geluWeights a) h s) i=bitReal (B.stepBits bits s i) := by
  unfold decodedPair hiddenStep
  rw [B.gelu_internal_sum,B.gelu_internal_sum]
  simp only [positiveIndex,negativeIndex,Equiv.symm_apply_apply,pairSource,pairSign,one_mul,neg_one_mul]
  simp_rw [hdecode]
  rw [geluDecode_identity (NorGate.coefficient_sum_trit B.constant (B.internal s i) bits hconst)]
  exact NorGate.relu_coefficients B.constant (B.internal s i) bits hconst

theorem gelu_fold_decode (B : LayeredNorCircuit d C r) (a : ℝ)
    (ss : List (Fin r)) (h : Fin (2*C)→ℝ) (bits : Fin C→Bool)
    (hconst : bits B.constant=true) (hdecode : ∀i,decodedPair h i=bitReal (bits i)) :
    ∀i,decodedPair (ss.foldl (hiddenStep gelu (B.geluWeights a)) h) i=
      bitReal (ss.foldl B.stepBits bits i) := by
  induction ss generalizing h bits with
  | nil=>exact hdecode
  | cons s ss ih=>
    simp only [List.foldl_cons]
    exact ih _ _ (B.stepBits_constant bits hconst s) (B.gelu_step_decode a h bits hconst hdecode s)

theorem gelu_final_decode (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d) :
    ∀i,decodedPair (finalHidden gelu (B.geluWeights a) x) i=bitReal (B.finalBits x i) :=
  B.gelu_fold_decode a _ _ _ (B.firstBits_constant x) (B.gelu_first_decode a x)

theorem gelu_networkOutput (B : LayeredNorCircuit d C r) (a : ℝ) (x : Cube d) :
    networkOutput gelu (B.geluWeights a) x=a*labelReal (B.computes x) := by
  unfold networkOutput
  rw [paired_sum]
  have he : (∑i,B.geluWeights a (.inr (.inr (positiveIndex i)))*
      finalHidden gelu (B.geluWeights a) x (positiveIndex i))+
      (∑i,B.geluWeights a (.inr (.inr (negativeIndex i)))*
      finalHidden gelu (B.geluWeights a) x (negativeIndex i))=
      ∑i,B.weights a (.inr (.inr i))*decodedPair (finalHidden gelu (B.geluWeights a) x) i := by
    simp only [geluWeights,positiveIndex,negativeIndex,Equiv.symm_apply_apply,pairSource,pairDecode,
      decodedPair,mul_add,Finset.sum_add_distrib]
    congr 1 <;> apply Finset.sum_congr rfl <;> intro j _ <;> ring
  rw [he]
  simp_rw [B.gelu_final_decode]
  simpa only [networkOutput,B.finalHidden_weights] using B.networkOutput_weights a x

end LayeredNorCircuit
end NeuralGeneralization.BatchTwoMerging
