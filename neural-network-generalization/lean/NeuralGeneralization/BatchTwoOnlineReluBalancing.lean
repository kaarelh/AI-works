import NeuralGeneralization.BatchTwoOnlineReluLayerScaling
import NeuralGeneralization.BatchTwoOnlineReluBalanceScalars
import NeuralGeneralization.RobustCompressionGridPadding

/-! Actual exact ReLU balancing and enlargement at the literal product cost. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def reluBalancedEnergy (d r : ℕ) (P : ℝ) : ℝ :=
  (r+2:ℝ)*((d:ℝ)*P^2)^((r+2:ℝ)⁻¹)

theorem physical_relu_product_pos {d N r : ℕ} (hN : 0<N) (w : Weights d N r)
    (hne : ∃x,networkOutput relu w x≠0) : 0<physicalProduct hN relu_zeroLipschitz w := by
  have hp := physicalProduct_nonneg hN relu_zeroLipschitz w
  by_contra h
  have hz : physicalProduct hN relu_zeroLipschitz w=0 := le_antisymm (le_of_not_gt h) hp
  obtain ⟨W,_,hW⟩ := physical_relu_normalization hN w
  obtain ⟨x,hx⟩ := hne
  apply hx
  rw [hW x,hz,auxiliaryOutput,zero_mul]

theorem weightedLayerEnergy_pos_of_relu_output {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) (hne : ∃x,networkOutput relu w x≠0) (i : Fin r⊕Bool) :
    0<weightedLayerEnergy w i := by
  have hp := physical_relu_product_pos hN w hne
  have hprod : 0<∏j,weightedLayerEnergy w j := by
    rw [weightedLayerEnergy_product hN relu_zeroLipschitz]
    exact mul_pos (Nat.cast_pos.mpr hd) (sq_pos_of_pos hp)
  by_contra h
  have hz : weightedLayerEnergy w i=0 := le_antisymm (le_of_not_gt h) (weightedLayerEnergy_nonneg w i)
  have hzero := Finset.prod_eq_zero (Finset.mem_univ i) hz
  linarith

/-- The rescaled physical weights have the same real output everywhere and
exactly L(d P^2)^(1/L) weighted energy. -/
theorem exists_balanced_relu_weights {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) (hne : ∃x,networkOutput relu w x≠0) :
    ∃v : Weights d N r,(∀x,networkOutput relu v x=networkOutput relu w x) ∧
      weightedSquaredNorm v=reluBalancedEnergy d r (physicalProduct hN relu_zeroLipschitz w) := by
  obtain ⟨b,hb,hprod,henergy⟩ := exists_balancing_factors (weightedLayerEnergy w)
    (weightedLayerEnergy_pos_of_relu_output hd hN w hne)
  refine ⟨rescaleReluLayers b w,?_,?_⟩
  · intro x
    rw [rescaleReluLayers_output b (fun i=>(hb i).le) w x,hprod,one_mul]
  · rw [←weightedLayerEnergy_sum]
    simp_rw [rescaleReluLayers_energy,henergy]
    rw [weightedLayerEnergy_product hN relu_zeroLipschitz]
    simp only [Finset.sum_const,Finset.card_univ,Fintype.card_sum,Fintype.card_fin,
      Fintype.card_bool,nsmul_eq_mul,Nat.cast_add,Nat.cast_ofNat]
    rfl

theorem physicalProduct_widthPadded {d C N r : ℕ} (hC : 0<C) (hCN : C≤N)
    (w : Weights d C r) :
    physicalProduct (hC.trans_le hCN) relu_zeroLipschitz (widthPaddedWeights hCN w)=
      physicalProduct hC relu_zeroLipschitz w := by
  have he : (physicalProduct (hC.trans_le hCN) relu_zeroLipschitz (widthPaddedWeights hCN w))^2=
      (physicalProduct hC relu_zeroLipschitz w)^2 := by
    rw [physicalProduct_sq,physicalProduct_sq]
    unfold widthPaddedWeights
    simp only [first_squaredSum_cloned,internal_squaredSum_cloned (by norm_num : 0<1),
      readout_squaredSum_cloned (by norm_num : 0<1),Nat.cast_one,one_mul,div_one]
  exact (sq_eq_sq₀ (physicalProduct_nonneg _ _ _) (physicalProduct_nonneg _ _ _)).mp he

/-- Every width N>=C admits the same function at the same optimal balanced
energy, with no integrality or neuron-replication loss. -/
theorem exists_enlarged_balanced_relu_weights {d C N r : ℕ} (hd : 0<d) (hC : 0<C)
    (hCN : C≤N) (w : Weights d C r) (hne : ∃x,networkOutput relu w x≠0) :
    ∃v : Weights d N r,(∀x,networkOutput relu v x=networkOutput relu w x) ∧
      weightedSquaredNorm v=reluBalancedEnergy d r (physicalProduct hC relu_zeroLipschitz w) := by
  have hp : ∃x,networkOutput relu (widthPaddedWeights hCN w) x≠0 := by
    simpa only [networkOutput_widthPaddedWeights] using hne
  obtain ⟨v,hv,he⟩ := exists_balanced_relu_weights hd (hC.trans_le hCN) (widthPaddedWeights hCN w) hp
  rw [physicalProduct_widthPadded hC hCN w] at he
  exact ⟨v,fun x=>(hv x).trans (networkOutput_widthPaddedWeights hCN relu w x),he⟩

end NeuralGeneralization.BatchTwoActivation
