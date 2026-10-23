import NeuralGeneralization.BatchTwoContinuousDepthSlowChannel
import NeuralGeneralization.BatchTwoContinuousCloning

/-! Scalar inverse channels as actual dense, finite-width neural networks. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous

def slowChannelWeights {d N : ℕ} (r : ℕ) (w : Weights d N 0) : Weights d N (r+1)
  | Sum.inl a => w (Sum.inl a)
  | Sum.inr (Sum.inl (s,_,j)) => if s=0 then (7/5)*w (Sum.inr (Sum.inr j)) else (7/5)/(N : ℝ)
  | Sum.inr (Sum.inr _) => 1/(N : ℝ)

def slowChannelAfter {d N r : ℕ} (w : Weights d N 0) (x : RealInput d) (t : ℕ) : Fin N → ℝ :=
  ((List.finRange (r+1)).take t).foldl (hiddenStep Real.tanh (slowChannelWeights r w))
    (BatchTwoContinuous.firstHidden Real.tanh (slowChannelWeights r w) x)

theorem slowChannelAfter_succ {d N r : ℕ} (w : Weights d N 0) (x : RealInput d)
    (s : Fin (r+1)) : slowChannelAfter (r := r) w x (s.val+1)=
      hiddenStep Real.tanh (slowChannelWeights r w) (slowChannelAfter (r := r) w x s.val) s := by
  unfold slowChannelAfter
  rw [List.take_succ_eq_append_getElem (by simpa using s.isLt),List.foldl_append]
  simp only [List.foldl_cons,List.foldl_nil,List.getElem_finRange]
  rfl

theorem slowChannelAfter_one {d N r : ℕ} (w : Weights d N 0) (x : RealInput d) :
    slowChannelAfter (r := r) w x 1=fun _ => slowChannel (output Real.tanh w x) := by
  rw [show 1=(0 : Fin (r+1)).val+1 by rfl,slowChannelAfter_succ]
  funext i
  simp only [slowChannelAfter,Fin.val_zero,List.take_zero,List.foldl_nil,hiddenStep,slowChannelWeights,ite_true,
    BatchTwoContinuous.firstHidden,slowChannel,output,BatchTwoContinuous.finalHidden,
    List.finRange_zero,List.foldl_nil]
  congr 1
  rw [Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem slowChannel_hiddenStep_later {d N r : ℕ} (hN : 0 < N) (w : Weights d N 0)
    (s : Fin (r+1)) (hs : s≠0) (z : ℝ) :
    hiddenStep Real.tanh (slowChannelWeights r w) (fun _ => z) s=fun _ => slowChannel z := by
  funext i
  have hNR : (N : ℝ)≠0 := by exact_mod_cast hN.ne'
  simp only [hiddenStep,slowChannelWeights,if_neg hs,Finset.sum_const,
    Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,slowChannel]
  congr 1
  field_simp

theorem slowChannelAfter_positive {d N r : ℕ} (hN : 0 < N) (w : Weights d N 0)
    (x : RealInput d) (t : ℕ) (ht : t≤r) :
    slowChannelAfter (r := r) w x (t+1)=fun _ => slowChannel^[t+1] (output Real.tanh w x) := by
  induction t with
  | zero => simpa only [zero_add,Function.iterate_one] using slowChannelAfter_one w x
  | succ t ih =>
    rw [show t+1+1=(⟨t+1,by omega⟩ : Fin (r+1)).val+1 by rfl,slowChannelAfter_succ]
    rw [ih (by omega),slowChannel_hiddenStep_later hN w _ (by simp)]
    simp only [Function.iterate_succ_apply']

theorem slowChannel_output {d N r : ℕ} (hN : 0 < N) (w : Weights d N 0) (x : RealInput d) :
    output Real.tanh (slowChannelWeights r w) x=slowChannel^[r+1] (output Real.tanh w x) := by
  have hf := slowChannelAfter_positive hN w x r le_rfl
  have htake : (List.finRange (r+1)).take (r+1)=List.finRange (r+1) := by simp
  have hfinal : BatchTwoContinuous.finalHidden Real.tanh (slowChannelWeights r w) x=
      fun _ => slowChannel^[r+1] (output Real.tanh w x) := by
    simpa only [slowChannelAfter,htake,BatchTwoContinuous.finalHidden] using hf
  have hNR : (N : ℝ)≠0 := by exact_mod_cast hN.ne'
  simp [output,hfinal,slowChannelWeights,hNR]

theorem slowChannel_energy {d N r : ℕ} (hN : 0 < N) (w : Weights d N 0) :
    weightedSquaredNorm (slowChannelWeights r w) =
      (d : ℝ)/N*(∑ i,∑ j,(w (Sum.inl (i,j)))^2)+
      (49/25)*(N : ℝ)*(∑ i,(w (Sum.inr (Sum.inr i)))^2)+(49/25)*(r : ℝ)+1 := by
  classical
  have hNR : (N : ℝ)≠0 := by exact_mod_cast hN.ne'
  unfold weightedSquaredNorm
  simp only [slowChannelWeights,Fin.sum_univ_succ,Fin.succ_ne_zero,if_false,if_true,
    Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul]
  simp_rw [mul_pow,← Finset.mul_sum]
  field_simp
  <;> ring


theorem slowChannel_readout_energy {d N r : ℕ} (hN : 0<N) (w : Weights d N 0) :
    (N:ℝ)*(∑i,(slowChannelWeights r w (Sum.inr (Sum.inr i)))^2)=1 := by
  have hNR:(N:ℝ)≠0:=by exact_mod_cast hN.ne'
  simp [slowChannelWeights,hNR]
  field_simp

end NeuralGeneralization.BatchTwoContinuousDepthLower
