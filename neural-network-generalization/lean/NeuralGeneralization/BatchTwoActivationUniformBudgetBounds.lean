import NeuralGeneralization.BatchTwoActivationUniformBudgets

/-! Elementary inequalities discharging the three-regime polynomial budgets. -/
noncomputable section
set_option maxHeartbeats 1200000
set_option maxRecDepth 10000
namespace NeuralGeneralization.BatchTwoActivation

theorem activationUniformInverseScale_radius {b d S r : ℕ} {ℓ : ℝ}
    (hℓ0 : 0≤ℓ) (hℓ : ℓ≤b) :
    16/(activationUniformInverseScale b d S r:ℝ)≤
      activationSpectralRadius d r ℓ (activationUniformSpectralEnergy b d S r) := by
  let K := activationUniformSpectralEnergy b d S r
  let I := activationUniformInverseScale b d S r
  let U := (K:ℝ)*(b:ℝ)^2*((d:ℝ)+1)*(K:ℝ)*(2*(b:ℝ)^2*((K:ℝ)+1)+1)^r+1
  let V := (K:ℝ)*spectralInputFactor d ℓ K*(spectralAmplification ℓ K)^r+1
  have hV : 0<V := by dsimp [V,spectralInputFactor,spectralAmplification]; positivity
  have hVU : V≤U := by
    dsimp [V,U,spectralInputFactor,spectralAmplification]
    rw [show (K:ℝ)*(ℓ^2*((d:ℝ)+1)*K)=(K:ℝ)*ℓ^2*((d:ℝ)+1)*K by ring]
    gcongr
  have hUI : 192*U≤(I:ℝ) := by
    have he : (I:ℝ)=384*U+16*((d:ℝ)+1)+1 := by
      simp only [I,activationUniformInverseScale,U,K,Nat.cast_add,Nat.cast_mul,Nat.cast_pow,Nat.cast_ofNat,Nat.cast_one]
    rw [he]
    have hU0 : 0≤U := by dsimp [U]; positivity
    nlinarith [Nat.cast_nonneg d (α:=ℝ)]
  have hI : (0:ℝ)<I := by exact_mod_cast (show 0<I from lt_of_lt_of_le (by norm_num) (activationUniformInverseScale_one_le b d S r))
  change 16/(I:ℝ)≤(12*V)⁻¹
  rw [inv_eq_one_div]
  apply (div_le_div_iff₀ hI (by positivity : 0<12*V)).mpr
  nlinarith

theorem activationUniform_smallScale_first {b d S r : ℕ} {t : ℝ}
    (ht : 0<t) (hsmall : t≤1/(activationUniformInverseScale b d S r:ℝ)) :
    8*((d:ℝ)+1)*t^2≤(activationUniformSpectralEnergy b d S r:ℝ) := by
  let I := activationUniformInverseScale b d S r
  have hI1 : (1:ℝ)≤I := by exact_mod_cast activationUniformInverseScale_one_le b d S r
  have hI0 : (0:ℝ)<I := by linarith
  have hId : 8*((d:ℝ)+1)≤I := by
    have hn : 8*(d+1)≤I := by dsimp [I,activationUniformInverseScale]; omega
    exact_mod_cast hn
  have htI : t*(I:ℝ)≤1 := (le_div_iff₀ hI0).mp hsmall
  have ht1 : t≤1 := by nlinarith
  have hfirst : 8*((d:ℝ)+1)*t≤1 := by nlinarith
  have hK1 : (1:ℝ)≤activationUniformSpectralEnergy b d S r := by exact_mod_cast activationUniformSpectralEnergy_one_le b d S r
  nlinarith [mul_nonneg (show 0≤8*((d:ℝ)+1) by positivity) (show 0≤t-t^2 by nlinarith)]

theorem log_prefactor_le {ε p : ℝ} (hε : 0<ε) (hp : 0<p) :
    Real.log (p/ε)≤p+Real.log (1/ε) := by
  rw [show p/ε=p*(1/ε) by ring,Real.log_mul hp.ne' (by positivity)]
  linarith [Real.log_le_sub_one_of_pos hp]

theorem activationUniform_spectral_gap {b d S r : ℕ} {A ε : ℝ}
    (hA : A≤activationNatTarget b d S r) (hε : 0<ε)
    (hlog : Real.log (1/ε)≤S) :
    A+Real.log (4*((r:ℝ)+1)/ε)≤(activationUniformSpectralEnergy b d S r:ℝ)/4 := by
  have hh := log_prefactor_le hε (by positivity : 0<4*((r:ℝ)+1))
  unfold activationUniformSpectralEnergy
  push_cast
  have hAn : (0:ℝ)≤activationNatTarget b d S r := Nat.cast_nonneg _
  have hSn : (0:ℝ)≤S := Nat.cast_nonneg _
  have hrn : (0:ℝ)≤r := Nat.cast_nonneg _
  linarith

theorem activationUniform_endpoint_gap {b d S r : ℕ} {A ε : ℝ}
    (hA : 0≤A) (hAb : A≤activationNatTarget b d S r) (hε : 0<ε)
    (hlog : Real.log (1/ε)≤S) :
    A*(activationUniformInverseScale b d S r:ℝ)^2+
      Real.log (2*(2*((r:ℝ)+1)+1)/ε)≤activationUniformEndpointEnergy b d S r := by
  have hh := log_prefactor_le hε (by positivity : 0<2*(2*((r:ℝ)+1)+1))
  have hmul := mul_le_mul_of_nonneg_right hAb (sq_nonneg (activationUniformInverseScale b d S r:ℝ))
  unfold activationUniformEndpointEnergy
  push_cast
  have hAn : (0:ℝ)≤(activationNatTarget b d S r:ℝ)*(activationUniformInverseScale b d S r:ℝ)^2 := by positivity
  have hSn : (0:ℝ)≤S := Nat.cast_nonneg _
  have hrn : (0:ℝ)≤r := Nat.cast_nonneg _
  linarith

theorem activationUniform_smallWidth_gap {b d S r : ℕ} {A ε : ℝ}
    (hA : A≤activationNatTarget b d S r) (hε : 0<ε)
    (hlog : Real.log (1/ε)≤S) :
    8*((d:ℝ)+2+(r:ℝ)*(activationUniformWidth b d S r:ℝ))≤activationUniformSmallEnergy b d S r ∧
    4*A+4*Real.log (2/ε)≤activationUniformSmallEnergy b d S r := by
  have hh := log_prefactor_le hε (by norm_num : (0:ℝ)<2)
  unfold activationUniformSmallEnergy
  push_cast
  have hAn : (0:ℝ)≤activationNatTarget b d S r := Nat.cast_nonneg _
  have hSn : (0:ℝ)≤S := Nat.cast_nonneg _
  have hd : (0:ℝ)≤d := Nat.cast_nonneg _
  have hr : (0:ℝ)≤(r:ℝ)*activationUniformWidth b d S r := by positivity
  constructor <;> linarith

end NeuralGeneralization.BatchTwoActivation
