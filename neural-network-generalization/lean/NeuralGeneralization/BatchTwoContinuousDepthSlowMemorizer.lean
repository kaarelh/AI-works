import NeuralGeneralization.BatchTwoContinuousDepthMemorizer
import NeuralGeneralization.BatchTwoContinuousDepthSlowNetwork

/-! An actual interpolator whose leading energy is strictly below 2L.
The readout contributes exactly one unit of weighted energy. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open ConcreteModel BatchTwoContinuous BatchTwoNeuralConverse

/-- A literal neural interpolant. The small coefficient condition is later
verified uniformly over the exponential sample range. -/
theorem exists_slow_channel_memorizer {n M N r : ℕ} (hn : 0 < n) (hMN : M ≤ N)
    (hM : 2*n ≤ M) {δ : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1)
    (s : Fin n → RealInput 2) (y : Fin n → ℝ)
    (hs : ∀ i, |s i 0| ≤ 1) (hy : ∀ i, |y i| ≤ 13/20)
    (hsep : ∀ i j, i≠j → δ ≤ |s i 0-s j 0|)
    (hfirst : 14*(n : ℝ)*(interpolationSlope n δ)^2 ≤ 3*M)
    (hsmall : 16*(M : ℝ)*(n : ℝ)^2*((6/7 : ℝ)^(r+1))^2 ≤ 1) :
    ∃ w : Weights 2 N (r+1), (∀ i,output Real.tanh w (s i)=y i) ∧
      weightedSquaredNorm w ≤ (49/25)*(r : ℝ)+5 ∧
      (N:ℝ)*(∑i,(w (Sum.inr (Sum.inr i)))^2)=1 := by
  classical
  have hMpos : 0 < M := by omega
  have hNpos : 0 < N := lt_of_lt_of_le hMpos hMN
  have hMR : (0 : ℝ)<M := by exact_mod_cast hMpos
  let y' : Fin n → ℝ := fun i => inverseSlowChannel^[r+1] (y i)
  obtain ⟨v,hv,hinterp⟩ := exact_bump_coefficients hn hδ (fun i => s i 0) y' hsep
  have hysmall (i : Fin n) : |y' i| ≤ (6/7 : ℝ)^(r+1) := by
    have h := inverseSlowChannel_iterate_bound (r+1) (hy i)
    exact h.trans (by nlinarith [hy i,pow_nonneg (by norm_num : (0 : ℝ)≤6/7) (r+1)])
  have hvl1 : vectorL1 v ≤ 2*(n : ℝ)*(6/7 : ℝ)^(r+1) := by
    have hh := Finset.sum_le_sum (s := Finset.univ) (fun i _ => hysmall i)
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_fin,nsmul_eq_mul] at hh
    unfold vectorL1 at hv ⊢
    linarith
  have hvsq : (∑ i,(v i)^2) ≤ 4*(n : ℝ)^2*((6/7 : ℝ)^(r+1))^2 := by
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
      4*(M : ℝ)*(n : ℝ)^2*((6/7 : ℝ)^(r+1))^2 := by
    dsimp [b]
    rw [bump_readout_squared]
    nlinarith [mul_le_mul_of_nonneg_left hvsq hMR.le]
  refine ⟨slowChannelWeights r u,?_,?_,slowChannel_readout_energy hNpos u⟩
  · intro i
    rw [slowChannel_output hNpos,hu,bump_output,hinterp]
    exact slowChannel_iterate_inverse (r+1) (hy i)
  · rw [slowChannel_energy hNpos]
    have hf : (2 : ℝ)/N*(∑ i,∑ j,(u (Sum.inl (i,j)))^2)≤3 := hufirst.trans hbfirst
    have hl : (49/25)*(N : ℝ)*(∑ i,(u (Sum.inr (Sum.inr i)))^2)≤1 := by
      nlinarith
    norm_num only [Nat.cast_ofNat]
    linarith

end NeuralGeneralization.BatchTwoContinuousDepthLower
