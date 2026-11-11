import NeuralGeneralization.BatchTwoContinuousDepthNormalizedChannel

/-! A variable scalar channel represented by actual dense network weights,
with exact output semantics and an exact weighted energy identity. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthPaper
open ConcreteModel BatchTwoContinuous BatchTwoContinuousDepthLower

def variableChannelWeights {d N r : ℕ} (a : Fin (r+1) → ℝ) (b : ℝ)
    (w : Weights d N 0) : Weights d N (r+1)
  | Sum.inl z => w (Sum.inl z)
  | Sum.inr (Sum.inl (s,_,j)) => if s=0 then a s*w (Sum.inr (Sum.inr j)) else a s/(N : ℝ)
  | Sum.inr (Sum.inr _) => b/(N : ℝ)

def scalarChannelState {r : ℕ} (a : Fin (r+1) → ℝ) (x : ℝ) (t : ℕ) : ℝ :=
  ((List.finRange (r+1)).take t).foldl (fun z s => Real.tanh (a s*z)) x

def variableChannelAfter {d N r : ℕ} (a : Fin (r+1) → ℝ) (b : ℝ)
    (w : Weights d N 0) (x : RealInput d) (t : ℕ) : Fin N → ℝ :=
  ((List.finRange (r+1)).take t).foldl (hiddenStep Real.tanh (variableChannelWeights a b w))
    (BatchTwoContinuous.firstHidden Real.tanh (variableChannelWeights a b w) x)

theorem scalarChannelState_succ {r : ℕ} (a : Fin (r+1) → ℝ) (x : ℝ) (s : Fin (r+1)) :
    scalarChannelState a x (s.val+1)=Real.tanh (a s*scalarChannelState a x s.val) := by
  unfold scalarChannelState
  rw [List.take_succ_eq_append_getElem (by simpa using s.isLt),List.foldl_append]
  simp only [List.foldl_cons,List.foldl_nil,List.getElem_finRange]
  rfl

theorem variableChannelAfter_succ {d N r : ℕ} (a : Fin (r+1) → ℝ) (b : ℝ)
    (w : Weights d N 0) (x : RealInput d) (s : Fin (r+1)) :
    variableChannelAfter a b w x (s.val+1)=
      hiddenStep Real.tanh (variableChannelWeights a b w) (variableChannelAfter a b w x s.val) s := by
  unfold variableChannelAfter
  rw [List.take_succ_eq_append_getElem (by simpa using s.isLt),List.foldl_append]
  simp only [List.foldl_cons,List.foldl_nil,List.getElem_finRange]
  rfl

theorem variableChannelAfter_one {d N r : ℕ} (a : Fin (r+1) → ℝ) (b : ℝ)
    (w : Weights d N 0) (x : RealInput d) :
    variableChannelAfter a b w x 1 = fun _ => scalarChannelState a (output Real.tanh w x) 1 := by
  rw [show 1=(0 : Fin (r+1)).val+1 from rfl,variableChannelAfter_succ,scalarChannelState_succ]
  funext i
  simp only [variableChannelAfter,scalarChannelState,Fin.val_zero,List.take_zero,List.foldl_nil,
    hiddenStep,variableChannelWeights,ite_true,BatchTwoContinuous.firstHidden,output,
    BatchTwoContinuous.finalHidden,List.finRange_zero]
  congr 1
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem variableChannel_hiddenStep_later {d N r : ℕ} (hN : 0 < N)
    (a : Fin (r+1) → ℝ) (b : ℝ) (w : Weights d N 0)
    (s : Fin (r+1)) (hs : s≠0) (z : ℝ) :
    hiddenStep Real.tanh (variableChannelWeights a b w) (fun _ => z) s=
      fun _ => Real.tanh (a s*z) := by
  funext i
  have hNR : (N : ℝ)≠0 := by exact_mod_cast hN.ne'
  simp only [hiddenStep,variableChannelWeights,if_neg hs,Finset.sum_const,
    Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  congr 1
  field_simp

theorem variableChannelAfter_positive {d N r : ℕ} (hN : 0 < N)
    (a : Fin (r+1) → ℝ) (b : ℝ) (w : Weights d N 0)
    (x : RealInput d) (t : ℕ) (ht : t≤r) :
    variableChannelAfter a b w x (t+1) = fun _ => scalarChannelState a (output Real.tanh w x) (t+1) := by
  induction t with
  | zero => simpa only [zero_add] using variableChannelAfter_one a b w x
  | succ t ih =>
    rw [show t+1+1=(⟨t+1,by omega⟩ : Fin (r+1)).val+1 from rfl,
      variableChannelAfter_succ,scalarChannelState_succ]
    rw [ih (by omega),variableChannel_hiddenStep_later hN a b w _ (by simp)]

theorem variableChannel_output {d N r : ℕ} (hN : 0 < N)
    (a : Fin (r+1) → ℝ) (b : ℝ) (w : Weights d N 0) (x : RealInput d) :
    output Real.tanh (variableChannelWeights a b w) x =
      b*scalarChannelState a (output Real.tanh w x) (r+1) := by
  have hf := variableChannelAfter_positive hN a b w x r le_rfl
  have htake : (List.finRange (r+1)).take (r+1)=List.finRange (r+1) := by simp
  have hfinal : BatchTwoContinuous.finalHidden Real.tanh (variableChannelWeights a b w) x =
      fun _ => scalarChannelState a (output Real.tanh w x) (r+1) := by
    simpa only [variableChannelAfter,htake,BatchTwoContinuous.finalHidden] using hf
  have hNR : (N : ℝ)≠0 := by exact_mod_cast hN.ne'
  simp only [output,hfinal,variableChannelWeights,Finset.sum_const,
    Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  field_simp

theorem variableChannel_energy {d N r : ℕ} (hN : 0 < N)
    (a : Fin (r+1) → ℝ) (b : ℝ) (w : Weights d N 0) :
    weightedSquaredNorm (variableChannelWeights a b w) =
      (d : ℝ)/N*(∑ i,∑ j,(w (Sum.inl (i,j)))^2)+
      (a 0)^2*(N : ℝ)*(∑ i,(w (Sum.inr (Sum.inr i)))^2)+
      (∑ s : Fin r, (a s.succ)^2)+b^2 := by
  have hNR : (N : ℝ)≠0 := by exact_mod_cast hN.ne'
  unfold weightedSquaredNorm
  simp only [variableChannelWeights,Fin.sum_univ_succ,Fin.succ_ne_zero,if_false,if_true,
    Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  simp_rw [mul_pow,div_pow]
  simp only [← Finset.mul_sum]
  rw [← Finset.sum_div]
  field_simp
  <;> ring

end NeuralGeneralization.BatchTwoContinuousDepthPaper
