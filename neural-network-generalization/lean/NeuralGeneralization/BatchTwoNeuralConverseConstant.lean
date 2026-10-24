import NeuralGeneralization.BatchTwoNeuralConverseSingleton

/-! A low-energy, strictly gain-admissible constant network at every depth. -/
namespace NeuralGeneralization.BatchTwoNeuralConverse
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
open Classical
open ConcreteModel

def constantWeights (d r : ℕ) (y : ℝ) : Weights d 1 r
  | Sum.inl (_,j) => Fin.cases (1/8) (fun _ => 0) j
  | Sum.inr (Sum.inl _) => relayFactor (r+1)
  | Sum.inr (Sum.inr _) => y/relayAmplitude (r+1) r

theorem constant_firstHidden (d r : ℕ) (y : ℝ) (x : Cube d) :
    firstHidden Real.tanh (constantWeights d r y) x = fun _ => relayAmplitude (r+1) 0 := by
  funext i
  simp [firstHidden,constantWeights,Fin.sum_univ_succ,inputVector,relayAmplitude]

theorem constant_hiddenStep (d r : ℕ) (y z : ℝ) (s : Fin r) :
    hiddenStep Real.tanh (constantWeights d r y) (fun _ => z) s =
      fun _ => Real.tanh (relayFactor (r+1)*z) := by
  funext i
  simp [hiddenStep,constantWeights]

theorem constant_cleanAfter (d r : ℕ) (y : ℝ) (x : Cube d) (n : ℕ) (hn : n≤r) :
    cleanAfter (constantWeights d r y) x n = fun _ => relayAmplitude (r+1) n := by
  induction n with
  | zero => simpa [cleanAfter] using constant_firstHidden d r y x
  | succ n ih =>
    funext i
    rw [show n+1=(⟨n,by omega⟩ : Fin r).val+1 by rfl,cleanAfter_succ]
    rw [ih (by omega),constant_hiddenStep]
    rfl

theorem constant_output (d r : ℕ) (y : ℝ) (x : Cube d) :
    networkOutput Real.tanh (constantWeights d r y) x=y := by
  have htake : (List.finRange r).take r=List.finRange r := by
    simpa only [List.length_finRange] using (List.take_length (l := List.finRange r))
  have hs := constant_cleanAfter d r y x r le_rfl
  have hf : finalHidden Real.tanh (constantWeights d r y) x=fun _ => relayAmplitude (r+1) r := by
    simpa only [cleanAfter,htake,finalHidden] using hs
  have ha : relayAmplitude (r+1) r≠0 := (relayAmplitude_pos (Nat.succ_pos _) _).ne'
  simp [networkOutput,hf,constantWeights,ha]

theorem constant_frobenius (d r : ℕ) (y : ℝ) (s : Fin r) :
    (∑ i, ∑ j, (constantWeights d r y (Sum.inr (Sum.inl (s,i,j))))^2) ≤ 1 := by
  simp only [constantWeights,Finset.univ_unique,Fin.default_eq_zero,Finset.sum_singleton]
  have h := relayFactor_bounds (Nat.succ_pos r)
  nlinarith

theorem constant_energy_bound (d r : ℕ) (y : ℝ) (hy : y^2=1) :
    weightedSquaredNorm (constantWeights d r y) ≤
      singletonBaseBudget d (r+1)+singletonReadoutBudget (r+1) := by
  have hi := Finset.sum_le_sum (s := Finset.univ) (fun s _ => constant_frobenius d r y s)
  simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul,mul_one] at hi
  have ha := relayAmplitude_inverse_bound (Nat.succ_pos r) (show r≤r+1 by omega)
  have hfirst : (∑ i : Fin 1, ∑ j, (constantWeights d r y (Sum.inl (i,j)))^2) = 1/64 := by
    simp [constantWeights,Fin.sum_univ_succ]
    norm_num
  have hlast : (∑ i : Fin 1, (constantWeights d r y (Sum.inr (Sum.inr i)))^2)=
      1/(relayAmplitude (r+1) r)^2 := by simp [constantWeights,div_pow,hy]
  unfold weightedSquaredNorm
  rw [hfirst,hlast]
  norm_num only [Nat.cast_one,div_one,one_mul]
  have hF : (1 : ℝ)≤firstFeatureBudget d := by
    unfold firstFeatureBudget
    have hp : 0≤(singletonSlope d)^2*d*(d+1 : ℝ) := by positivity
    linarith
  have hd := Nat.cast_nonneg d (α := ℝ)
  unfold singletonBaseBudget singletonReadoutBudget
  push_cast at ha ⊢
  nlinarith

theorem constant_mem_functionSupport (d r : ℕ) (y : Bool) {Λ U : ℝ}
    (hΛ : 1<Λ) (hU : 1<U) :
    constantWeights d r (labelReal y) ∈ functionSupport Λ U (fun _ => y) := by
  have hy : labelReal y≠0 := by cases y <;> norm_num [labelReal]
  have hv := readoutEnergy_pos_of_output_ne_zero (constantWeights d r (labelReal y))
    (fun _ => false) (by simpa only [constant_output] using hy)
  constructor
  · apply mem_gainSupport_of_frobenius _ hΛ hv
    · intro x
      rw [constant_output]
      cases y <;> norm_num [labelReal] <;> exact hU
    · exact constant_frobenius d r (labelReal y)
  · intro x
    rw [constant_output]
    cases y <;> norm_num [labelReal]

end
end NeuralGeneralization.BatchTwoNeuralConverse
