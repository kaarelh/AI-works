import NeuralGeneralization.BatchTwoOnlineReluCount

/-! Literal product-norm capacity for all-width ReLU energy sublevels. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def reluEnergyCapacity (d r : ℕ) (K : ℝ) : ℕ :=
  ⌈(4*((d:ℝ)+1)/d)*(K/(r+2:ℝ))^(r+2)*(reluDepthFactor (r+1))^2⌉₊

theorem relu_energy_product_capacity {d r : ℕ} (hd : 0<d) {K : ℝ} (hK : 0<K) :
    reluProductCapacity d (r+1) (sharpProductScale d r 1 K)=reluEnergyCapacity d r K := by
  have hdR : 0<(d:ℝ) := Nat.cast_pos.mpr hd
  have hb : 0≤K/(r+2:ℝ) := by positivity
  have he : ((K/(r+2:ℝ))^((r+2:ℝ)/2))^2=(K/(r+2:ℝ))^(r+2) := by
    rw [←Real.rpow_mul_natCast hb ((r+2:ℝ)/2) 2]
    norm_num only [Nat.cast_ofNat]
    rw [show ((r+2:ℝ)/2)*2=(r+2:ℝ) by ring]
    simpa only [Nat.cast_add,Nat.cast_ofNat] using Real.rpow_natCast (K/(r+2:ℝ)) (r+2)
  unfold reluProductCapacity reluEnergyCapacity sharpProductScale
  simp only [one_pow,one_div,mul_pow,inv_pow,Real.sq_sqrt hdR.le,he]
  congr 1
  ring

theorem energy_network_mem_relu_functions {d N r : ℕ} (hd : 0<d) (hN : 0<N)
    (w : Weights d N r) {K : ℝ} (hK : 0<K) (hw : weightedSquaredNorm w≤K)
    (f : BooleanFunction d) (hf : ∀x,(1/2:ℝ)≤labelReal (f x)*networkOutput relu w x) :
    f∈reluFunctions d (r+1) (sharpProductScale d r 1 K) := by
  apply physical_relu_mem_functions hN w (sharpProductScale_pos hd (by norm_num) hK) _ f hf
  simpa only [one_pow,one_mul] using
    physicalProduct_scaled_le hd hN relu_zeroLipschitz (by norm_num) w hK hw

theorem energyFunctions_subset_relu {d r : ℕ} (hd : 0<d) {K : ℝ} (hK : 0<K) :
    energyFunctions d r relu K⊆reluFunctions d (r+1) (sharpProductScale d r 1 K) := by
  classical
  intro f hf
  obtain ⟨_,N,hN,w,hw,hm⟩ := Finset.mem_filter.mp hf
  exact energy_network_mem_relu_functions hd hN w hK hw f hm

/-- Exactly the v_R count in the online ReLU extension, at any positive
energy cutoff K, with the actual union over every learner width. -/
theorem relu_energyFunctions_card_le {d r : ℕ} (hd : 0<d) {K : ℝ} (hK : 0<K) :
    (energyFunctions d r relu K).card≤(2^d+1)^(reluEnergyCapacity d r K) := by
  have h := (Finset.card_le_card (energyFunctions_subset_relu (r := r) hd hK)).trans
    (reluFunctions_card_le (by omega) (sharpProductScale_pos hd (by norm_num) hK))
  rwa [relu_energy_product_capacity hd hK] at h

theorem relu_energyFunctions_card_le_exp {d r : ℕ} (hd : 0<d) {K : ℝ} (hK : 0<K) :
    ((energyFunctions d r relu K).card:ℝ)≤
      Real.exp ((reluEnergyCapacity d r K:ℝ)*Real.log ((2:ℝ)^d+1)) := by
  rw [Real.exp_nat_mul,Real.exp_log (by positivity)]
  exact_mod_cast relu_energyFunctions_card_le hd hK

end NeuralGeneralization.BatchTwoActivation
