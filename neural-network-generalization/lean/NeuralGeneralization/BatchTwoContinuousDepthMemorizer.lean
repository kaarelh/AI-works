import NeuralGeneralization.BatchTwoContinuousDepthBumpNetwork
import NeuralGeneralization.BatchTwoContinuousDepthChannelNetwork

/-! Exact bounded-label memorization at every learner width above a fixed
sample-dependent threshold. The separate first-layer and readout estimates
preserve the exponentially small inverse-channel labels. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous BatchTwoNeuralConverse

theorem exists_real_clone_separate {d C N : ℕ} (hC : 0 < C) (hCN : C ≤ N)
    (w : Weights d C 0) : ∃ v : Weights d N 0,
      (∀ x : RealInput d, output Real.tanh v x=output Real.tanh w x) ∧
      (d : ℝ)/N*(∑ i,∑ j,(v (Sum.inl (i,j)))^2) ≤
        (d : ℝ)/C*(∑ i,∑ j,(w (Sum.inl (i,j)))^2) ∧
      (N : ℝ)*(∑ i,(v (Sum.inr (Sum.inr i)))^2) ≤
        2*(C : ℝ)*(∑ i,(w (Sum.inr (Sum.inr i)))^2) := by
  classical
  let k := N/C
  have hk : 0 < k := Nat.div_pos hCN hC
  have hmod : N%C < C := Nat.mod_lt _ hC
  have hsplit : N%C+C*k=N := Nat.mod_add_div N C
  have hbelow : C*k ≤ N := by omega
  have hCk : C ≤ C*k := by simpa only [Nat.mul_one] using Nat.mul_le_mul_left C hk
  have habove : N ≤ 2*C*k := by nlinarith
  let e : ((Fin C × Fin k) ⊕ Fin (N-C*k)) ≃ Fin N := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
    omega)
  refine ⟨clonedWeights e w,output_clonedWeights hk Real.tanh e w,?_,?_⟩
  · rw [first_squaredSum_cloned]
    have hCR : (0 : ℝ)<C := by exact_mod_cast hC
    have hNR : (0 : ℝ)<N := by exact_mod_cast lt_of_lt_of_le hC hCN
    have hbelowR : (C : ℝ)*k≤N := by exact_mod_cast hbelow
    have hratio : (d : ℝ)/N*k ≤ (d : ℝ)/C := by
      apply (le_div_iff₀ hCR).2
      rw [div_mul_eq_mul_div,div_mul_eq_mul_div]
      apply (div_le_iff₀ hNR).2
      nlinarith [mul_le_mul_of_nonneg_left hbelowR (Nat.cast_nonneg d (α := ℝ))]
    have hsum : 0 ≤ ∑ i,∑ j,(w (Sum.inl (i,j)))^2 := by positivity
    simpa only [mul_assoc] using mul_le_mul_of_nonneg_right hratio hsum
  · rw [readout_squaredSum_cloned hk]
    have hkR : (0 : ℝ)<k := by exact_mod_cast hk
    have haboveR : (N : ℝ)≤2*C*k := by exact_mod_cast habove
    have hratio : (N : ℝ)/k≤2*C := (div_le_iff₀ hkR).2 haboveR
    have hsum : 0 ≤ ∑ i,(w (Sum.inr (Sum.inr i)))^2 := by positivity
    simpa only [div_mul_eq_mul_div,mul_div_assoc] using mul_le_mul_of_nonneg_right hratio hsum

theorem vector_squared_le_l1 {n : ℕ} (v : Fin n → ℝ) :
    (∑ i,(v i)^2) ≤ (vectorL1 v)^2 := by
  simpa only [vectorL1,sq_abs,Finset.mem_univ,Finset.sum_const,ite_true] using
    Finset.sum_sq_le_sq_sum_of_nonneg (s := Finset.univ) (f := fun i => |v i|) (fun i _ => abs_nonneg _)

/-- A literal neural interpolant. The small coefficient condition is later
verified uniformly over the exponential sample range. -/
theorem exists_channel_memorizer {n M N r : ℕ} (hn : 0 < n) (hMN : M ≤ N)
    (hM : 2*n ≤ M) {δ : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1)
    (s : Fin n → RealInput 2) (y : Fin n → ℝ)
    (hs : ∀ i, |s i 0| ≤ 1) (hy : ∀ i, |y i| ≤ 13/20)
    (hsep : ∀ i j, i≠j → δ ≤ |s i 0-s j 0|)
    (hfirst : 14*(n : ℝ)*(interpolationSlope n δ)^2 ≤ 3*M)
    (hsmall : 16*(M : ℝ)*(n : ℝ)^2*((3/4 : ℝ)^(r+1))^2 ≤ 1) :
    ∃ w : Weights 2 N (r+1), (∀ i,output Real.tanh w (s i)=y i) ∧
      weightedSquaredNorm w ≤ 4*(r : ℝ)+5 := by
  classical
  have hMpos : 0 < M := by omega
  have hNpos : 0 < N := lt_of_lt_of_le hMpos hMN
  have hMR : (0 : ℝ)<M := by exact_mod_cast hMpos
  let y' : Fin n → ℝ := fun i => inverseChannel^[r+1] (y i)
  obtain ⟨v,hv,hinterp⟩ := exact_bump_coefficients hn hδ (fun i => s i 0) y' hsep
  have hysmall (i : Fin n) : |y' i| ≤ (3/4 : ℝ)^(r+1) := by
    have h := inverseChannel_iterate_bound (r+1) (hy i)
    exact h.trans (by nlinarith [hy i,pow_nonneg (by norm_num : (0 : ℝ)≤3/4) (r+1)])
  have hvl1 : vectorL1 v ≤ 2*(n : ℝ)*(3/4 : ℝ)^(r+1) := by
    have hh := Finset.sum_le_sum (s := Finset.univ) (fun i _ => hysmall i)
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] at hh
    unfold vectorL1 at hv ⊢
    linarith
  have hvsq : (∑ i,(v i)^2) ≤ 4*(n : ℝ)^2*((3/4 : ℝ)^(r+1))^2 := by
    have hp : 0 ≤ vectorL1 v := Finset.sum_nonneg (fun i _ => abs_nonneg _)
    have hb := vector_squared_le_l1 v
    nlinarith
  let e : ((Fin n × Bool) ⊕ Fin (M-2*n)) ≃ Fin M := Fintype.equivOfCardEq (by
    simp only [Fintype.card_sum,Fintype.card_prod,Fintype.card_fin,Fintype.card_bool]
    omega)
  let b := bumpWeights e (interpolationSlope n δ) δ (fun i => s i 0) v
  obtain ⟨u,hu,hufirst,hulast⟩ := exists_real_clone_separate hMpos hMN b
  have hbfirst : (2 : ℝ)/M*(∑ i,∑ j,(b (Sum.inl (i,j)))^2) ≤ 3 := by
    have hh := bump_first_squared e (interpolationSlope n δ) δ (fun i => s i 0) v
      (by rwa [abs_of_pos hδ]) hs
    rw [div_mul_eq_mul_div]
    apply (div_le_iff₀ hMR).2
    dsimp [b]
    nlinarith
  have hblast : (M : ℝ)*2*(∑ i,(b (Sum.inr (Sum.inr i)))^2) ≤
      4*(M : ℝ)*(n : ℝ)^2*((3/4 : ℝ)^(r+1))^2 := by
    dsimp [b]
    rw [bump_readout_squared]
    nlinarith [mul_le_mul_of_nonneg_left hvsq hMR.le]
  refine ⟨channelWeights r u,?_,?_⟩
  · intro i
    rw [channel_output hNpos,hu,bump_output,hinterp]
    exact scalarChannel_iterate_inverse (r+1) (hy i)
  · rw [channel_energy hNpos]
    have hf : (2 : ℝ)/N*(∑ i,∑ j,(u (Sum.inl (i,j)))^2)≤3 := hufirst.trans hbfirst
    have hl : 4*(N : ℝ)*(∑ i,(u (Sum.inr (Sum.inr i)))^2)≤1 := by
      nlinarith
    norm_num only [Nat.cast_ofNat]
    linarith

end NeuralGeneralization.BatchTwoContinuousDepthLower
