import NeuralGeneralization.BatchTwoActivationEndpointEnergyReadout

noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem actual_good_network_energy_witness {b d K N r : ℕ}
    (hb : 1≤b) (hd : 1≤d) (hK : 1≤K) (hN : 0<N)
    {ℓ B σ : ℝ} (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) (hB0 : 0≤B) (hB : B≤b)
    (hσ : 0<σ) (hscale : (N:ℝ)*σ^2≤1)
    {φ : ℝ → ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hb' : ∀u,|deriv scalarCutoff u|≤B) (hbb : ∀u,|deriv (deriv scalarCutoff) u|≤B)
    (w : Weights d N r) (f : BooleanFunction d)
    (hmargin : w∈marginEvent φ (1/2) f)
    (hgood : ActivationGoodHidden b d K (r+1) N φ σ r w)
    (hreadout : (N:ℝ)*(∑i,w (.inr (.inr i))^2)≤8*(K:ℝ)) :
    ∃R:RawAuxiliaryNetwork d (r+1) ℓ (activationRawBudget b d K (r+1)),
      (∀s,R.width s=activationFiniteWidth b d K (r+1)) ∧
      (∀x,(7/8:ℝ)≤labelReal (f x)*rawAuxiliaryOutput R x) ∧
      rawAuxiliaryWeightedEnergy R≤(activationEndpointEnergyBudget b d K (r+1):ℝ) := by
  obtain ⟨W,v,hv,hs,hcov⟩ := actual_hidden_tower_reconstruction hb hd hK hN
    hℓ0 hℓ hB0 hB hσ hscale hφ hb' hbb r (le_refl _) w hgood
  have hKR : (0:ℝ)<K := by exact_mod_cast (show 0<K by omega)
  obtain ⟨β,hβ,hpred⟩ := actual_readout_reconstructed_margin hN φ w f (by positivity : 0<8*(K:ℝ)) hmargin hreadout
  apply fixed_tower_readout_energy_witness (by omega : 0<r+1) hℓ0 W v hv hs β (by nlinarith) f
  apply hpred
  intro x y
  have hc := hcov x y
  simp only [Nat.sub_self,activationPrecisionGrow] at hc
  apply hc.trans
  have hA : 256*(K:ℝ)≤activationBaseBudget b d K (r+1) := by
    exact_mod_cast (show 256*K≤activationBaseBudget b d K (r+1) by unfold activationBaseBudget; omega)
  have hh := one_div_le_one_div_of_le (by positivity : 0<256*(K:ℝ)) hA
  convert hh using 1 <;> ring

end NeuralGeneralization.BatchTwoActivation
