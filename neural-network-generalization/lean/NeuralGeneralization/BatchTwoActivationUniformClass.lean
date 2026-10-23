import NeuralGeneralization.BatchTwoActivationUniformBudgets
import NeuralGeneralization.BatchTwoActivationSmallWidth

/-! A fixed union class contains both the spectral and covariance branches. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def activationUniformFunctions (b d S r : ℕ) (φ : ℝ → ℝ) : Finset (BooleanFunction d) :=
  energyFunctions d r φ (activationUniformEnergy b d S r) ∪
    activationEndpointFunctions b d (activationUniformEndpointEnergy b d S r) (r+1)

theorem energyFunctions_mono {d r : ℕ} (φ : ℝ → ℝ) {J J' : ℝ} (hJJ' : J≤J') :
    energyFunctions d r φ J⊆energyFunctions d r φ J' := by
  classical
  intro f hf
  obtain ⟨_,N,hN,w,hw,hm⟩ := Finset.mem_filter.mp hf
  exact Finset.mem_filter.mpr ⟨Finset.mem_univ _,N,hN,w,hw.trans hJJ',hm⟩

theorem activationUniform_spectral_subset (b d S r : ℕ) (φ : ℝ → ℝ) :
    energyFunctions d r φ (((r:ℝ)+5)*activationUniformSpectralEnergy b d S r)⊆activationUniformFunctions b d S r φ := by
  apply Finset.Subset.trans (energyFunctions_mono φ ?_) Finset.subset_union_left
  exact_mod_cast (show (r+5)*activationUniformSpectralEnergy b d S r≤activationUniformEnergy b d S r by
    unfold activationUniformEnergy; omega)

theorem activationUniform_smallWidth_subset (b d S r : ℕ) (φ : ℝ → ℝ) :
    energyFunctions d r φ (activationUniformSmallEnergy b d S r)⊆activationUniformFunctions b d S r φ := by
  apply Finset.Subset.trans (energyFunctions_mono φ ?_) Finset.subset_union_left
  exact_mod_cast (show activationUniformSmallEnergy b d S r≤activationUniformEnergy b d S r by
    unfold activationUniformEnergy; omega)

theorem activationUniform_endpoint_subset (b d S r : ℕ) (φ : ℝ → ℝ) :
    activationEndpointFunctions b d (activationUniformEndpointEnergy b d S r) (r+1)⊆
      activationUniformFunctions b d S r φ := Finset.subset_union_right

theorem activationUniformFunctions_card_le_exp {b d S r : ℕ} (hb : 1≤b) (hd : 1≤d)
    {φ : ℝ → ℝ} {ℓ : ℝ} (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) :
    ((activationUniformFunctions b d S r φ).card:ℝ)≤Real.exp (activationUniformCapacity b d S r) := by
  classical
  have hJ : (1:ℝ)≤activationUniformEnergy b d S r := by exact_mod_cast activationUniformEnergy_one_le b d S r
  have henergy := energyFunctions_card_le_exp (r:=r) hφ hℓ0 hJ hd
  have hscale : outputNormalization r ℓ (activationUniformEnergy b d S r)≤
      (activationUniformEnergyScale b d S r:ℝ) := by
    unfold outputNormalization activationUniformEnergyScale
    push_cast
    gcongr
  have hlog : activationLogCapacity d r ℓ (activationUniformEnergy b d S r)≤
      (activationIntegerCapacity d (r+1) (activationUniformEnergyScale b d S r):ℝ) := by
    unfold activationLogCapacity capacityPolynomial activationIntegerCapacity
    push_cast
    have hscale0 : 0≤outputNormalization r ℓ (activationUniformEnergy b d S r) := by
      unfold outputNormalization; positivity
    gcongr
  have he := henergy.trans (Real.exp_le_exp.mpr hlog)
  have hm := activationEndpointFunctions_card_le_exp (b:=b) (d:=d)
    (K:=activationUniformEndpointEnergy b d S r) hb (by omega : 0<r+1)
  let E : ℝ := activationIntegerCapacity d (r+1) (activationUniformEnergyScale b d S r)
  let M : ℝ := activationEndpointCapacity b d (activationUniformEndpointEnergy b d S r) (r+1)
  have hE : 0≤E := Nat.cast_nonneg _
  have hM : 0≤M := Nat.cast_nonneg _
  have hsum : Real.exp E+Real.exp M≤Real.exp (E+M+1) := by
    have he' : Real.exp E≤Real.exp (E+M) := Real.exp_le_exp.mpr (by linarith)
    have hm' : Real.exp M≤Real.exp (E+M) := Real.exp_le_exp.mpr (by linarith)
    have htwo : (2:ℝ)≤Real.exp 1 := by linarith [Real.add_one_le_exp (1:ℝ)]
    rw [Real.exp_add]
    nlinarith [mul_le_mul_of_nonneg_left htwo (Real.exp_pos (E+M)).le]
  simp only [activationUniformCapacity,Nat.cast_add,Nat.cast_one]
  apply le_trans _ hsum
  have hcard : ((activationUniformFunctions b d S r φ).card:ℝ)≤
      (energyFunctions d r φ (activationUniformEnergy b d S r)).card+
      (activationEndpointFunctions b d (activationUniformEndpointEnergy b d S r) (r+1)).card := by
    exact_mod_cast Finset.card_union_le (energyFunctions d r φ (activationUniformEnergy b d S r))
      (activationEndpointFunctions b d (activationUniformEndpointEnergy b d S r) (r+1))
  exact hcard.trans (add_le_add he hm)

end NeuralGeneralization.BatchTwoActivation
