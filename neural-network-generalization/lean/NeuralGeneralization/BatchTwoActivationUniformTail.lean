import NeuralGeneralization.BatchTwoActivationUniformBudgetBounds
import NeuralGeneralization.BatchTwoActivationUniformClass
import NeuralGeneralization.BatchTwoActivationEndpointTail
import NeuralGeneralization.ExponentialTailRatio

/-! The three actual Gaussian regimes yield one relative-mass estimate for
all widths and all scales simultaneously. -/
noncomputable section
set_option maxHeartbeats 1800000
set_option maxRecDepth 10000
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem functionMass_complement_mono {d N r : ℕ} (φ : ℝ → ℝ)
    (μ : Measure (Weights d N r)) {A B : Finset (BooleanFunction d)} (hAB : A⊆B) :
    (∑g∈Finset.univ\B,functionMass φ (1/2) μ g)≤
      ∑g∈Finset.univ\A,functionMass φ (1/2) μ g := by
  classical
  apply Finset.sum_le_sum_of_subset_of_nonneg
  · intro g hg
    apply Finset.mem_sdiff.mpr
    exact ⟨Finset.mem_univ _,fun hh => (Finset.mem_sdiff.mp hg).2 (hAB hh)⟩
  · intro g _ _
    exact functionMass_nonneg φ (1/2) μ g

theorem activationBand_target_mass {b d C S N r : ℕ} (hd : 1≤d) (hCN : C≤N) (hCS : C≤S)
    {φ : ℝ → ℝ} {ℓ t : ℝ} (hφ : zeroLipschitzActivation ℓ φ) (hℓ0 : 0≤ℓ) (hℓ : ℓ≤b)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C)
    (ht : 0<t) (ht1 : t≤1) :
    Real.exp (-(N:ℝ)*(activationNatTarget b d S r:ℝ)/t^2)≤
      functionMass φ (1/2) (activationBandPrior d N r t) f := by
  obtain ⟨hC,w,hmargin,hw⟩ := hf
  have hN : 0<N := (by omega : 0<C).trans_le hCN
  have hn : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have hsqrt := Real.sqrt_pos.mpr hn
  have hσ : 0<t/Real.sqrt (N:ℝ) := by positivity
  have hscale : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2≤1 := by
    rw [div_pow,Real.sq_sqrt hn.le]
    have he : (N:ℝ)*(t^2/(N:ℝ))=t^2 := by field_simp
    rw [he]
    nlinarith
  have hmass := activation_target_polynomial_mass (by omega) (by omega) hCN hφ hℓ0 w hw f hmargin hσ hscale
  have hA := (activationTargetPolynomial_le_natTarget (b:=b) hℓ0 hℓ).trans
    (show (activationNatTarget b d C r:ℝ)≤activationNatTarget b d S r by
      exact_mod_cast activationNatTarget_mono_complexity b d r hCS)
  apply le_trans _ hmass
  apply Real.exp_le_exp.mpr
  rw [div_pow,Real.sq_sqrt hn.le]
  have he : -activationTargetPolynomial d C r ℓ/(t^2/(N:ℝ))=
      -(N:ℝ)*activationTargetPolynomial d C r ℓ/t^2 := by field_simp
  rw [he]
  apply div_le_div_of_nonneg_right _ (sq_nonneg t)
  nlinarith [mul_le_mul_of_nonneg_left hA hn.le]

theorem activation_uniform_relative_tail {b d C S N r : ℕ}
    (hb : 1≤b) (hd : 1≤d) (hCN : C≤N) (hCS : C≤S)
    {ℓ B ε t : ℝ} (hℓ0 : 0<ℓ) (hℓ : ℓ≤b) (hB0 : 0≤B) (hB : B≤b)
    {φ : ℝ → ℝ} (hφ : zeroLipschitzActivation ℓ φ)
    (hb' : ∀u,|deriv scalarCutoff u|≤B) (hbb : ∀u,|deriv (deriv scalarCutoff) u|≤B)
    (f : BooleanFunction d) (hf : realizesAtComplexity (r:=r) φ f C)
    (hε : 0<ε) (hε1 : ε<1) (hlog : Real.log (1/ε)≤S) (ht : 0<t) (ht1 : t≤1) :
    (∑g∈Finset.univ\activationUniformFunctions b d S r φ,
      functionMass φ (1/2) (activationBandPrior d N r t) g)/
      functionMass φ (1/2) (activationBandPrior d N r t) f≤ε/2 := by
  classical
  let μ := activationBandPrior d N r t
  let A : ℝ := activationNatTarget b d S r
  let I := activationUniformInverseScale b d S r
  let Ks := activationUniformSpectralEnergy b d S r
  let Km := activationUniformEndpointEnergy b d S r
  have hA : 0≤A := Nat.cast_nonneg _
  have hN : 0<N := (by have := hf.1; omega : 0<C).trans_le hCN
  have hN1 : (1:ℝ)≤N := by exact_mod_cast hN
  have hn : (0:ℝ)<N := Nat.cast_pos.mpr hN
  have ht2 : 0<t^2 := sq_pos_of_pos ht
  have ht21 : t^2≤1 := by nlinarith
  have hfactor : 1≤(N:ℝ)/t^2 := (le_div_iff₀ ht2).mpr (by linarith)
  have hmass := activationBand_target_mass (b:=b) hd hCN hCS hφ hℓ0.le hℓ f hf ht ht1
  have hpos : 0<functionMass φ (1/2) μ f := (Real.exp_pos _).trans_le hmass
  have hI1 : (1:ℝ)≤I := by exact_mod_cast activationUniformInverseScale_one_le b d S r
  have hI0 : (0:ℝ)<I := by linarith
  have hmono {F : Finset (BooleanFunction d)} (hF : F⊆activationUniformFunctions b d S r φ) :
      (∑g∈Finset.univ\activationUniformFunctions b d S r φ,functionMass φ (1/2) μ g)/functionMass φ (1/2) μ f≤
      (∑g∈Finset.univ\F,functionMass φ (1/2) μ g)/functionMass φ (1/2) μ f :=
    div_le_div_of_nonneg_right (functionMass_complement_mono φ μ hF) hpos.le
  by_cases hsmall : t≤1/(I:ℝ)
  · apply (hmono (activationUniform_spectral_subset b d S r φ)).trans
    have hfirst := activationUniform_smallScale_first (b:=b) (d:=d) (S:=S) (r:=r) ht hsmall
    have hscale : 16*t≤activationSpectralRadius d r ℓ Ks :=
      (mul_le_mul_of_nonneg_left hsmall (by norm_num : (0:ℝ)≤16)).trans
        (by simpa only [I,Ks,div_eq_mul_inv,mul_one,one_mul] using activationUniformInverseScale_radius (d:=d) (S:=S) (r:=r) hℓ0.le hℓ)
    have htail := bandPrior_energyFunctions_spectral_tail hd hN hφ hℓ0.le ht hfirst hscale
    apply exponential_tail_ratio_prefactor_le _ _ (2*((r:ℝ)+1)) A ((Ks:ℝ)/4) ((N:ℝ)/t^2) (ε/2) _ _
      (by have := Nat.cast_nonneg r (α:=ℝ); linarith) hfactor (by positivity) (by linarith) _
    · change _≤2*((r:ℝ)+1)*Real.exp (-(N:ℝ)*(Ks:ℝ)/(4*t^2)) at htail
      rw [show -(N:ℝ)*(Ks:ℝ)/(4*t^2)= -((Ks:ℝ)/4)*((N:ℝ)/t^2) by ring] at htail
      exact htail
    · change Real.exp (-(N:ℝ)*A/t^2)≤_ at hmass
      rw [show -(N:ℝ)*A/t^2= -A*((N:ℝ)/t^2) by ring] at hmass
      exact hmass
    · have hh := activationUniform_spectral_gap (b:=b) (d:=d) (S:=S) (r:=r) (le_refl A) hε hlog
      change A+Real.log (4*((r:ℝ)+1)/ε)≤(Ks:ℝ)/4 at hh
      rw [show 2*((r:ℝ)+1)/(ε/2)=4*((r:ℝ)+1)/ε by field_simp <;> ring]
      exact hh
  · by_cases hlarge : activationUniformWidth b d S r≤N
    · apply (hmono (activationUniform_endpoint_subset b d S r φ)).trans
      have hsqrt := Real.sqrt_pos.mpr hn
      have hσ : 0<t/Real.sqrt (N:ℝ) := by positivity
      have he : (N:ℝ)*(t/Real.sqrt (N:ℝ))^2=t^2 := by rw [div_pow,Real.sq_sqrt hn.le];field_simp
      have htail := activation_endpoint_complement_mass_le hb hd (activationUniformEndpointEnergy_one_le b d S r) hN
        hℓ0 hℓ hB0 hB hσ (by rw [he];exact ht21) hφ hb' hbb hlarge
      have hinv : 1/t^2≤(I:ℝ)^2 := by
        have hti : 1≤t*(I:ℝ) := (div_le_iff₀ hI0).mp (le_of_lt (lt_of_not_ge hsmall))
        apply (div_le_iff₀ ht2).mpr
        nlinarith [sq_nonneg (t*(I:ℝ)-1)]
      have hgap : A/t^2+Real.log ((2*((r:ℝ)+1)+1)/(ε/2))≤Km := by
        have hh := activationUniform_endpoint_gap (b:=b) (d:=d) (S:=S) (r:=r) hA (le_refl A) hε hlog
        have hmul := mul_le_mul_of_nonneg_left hinv hA
        have hid : (2*((r:ℝ)+1)+1)/(ε/2)=2*(2*((r:ℝ)+1)+1)/ε := by field_simp
        rw [hid]
        change A*(I:ℝ)^2+Real.log (2*(2*((r:ℝ)+1)+1)/ε)≤(Km:ℝ) at hh
        rw [show A*(1/t^2)=A/t^2 by ring] at hmul
        linarith
      apply exponential_tail_ratio_prefactor_le _ _ (2*((r:ℝ)+1)+1) (A/t^2) (Km:ℝ) (N:ℝ) (ε/2) _ _
        (by have := Nat.cast_nonneg r (α:=ℝ); linarith) hN1 (by positivity) (by linarith) hgap
      · change _≤(2*((r:ℝ)+1)+1)*Real.exp (-(N:ℝ)*(Km:ℝ)) at htail
        rw [show -(N:ℝ)*(Km:ℝ)= -(Km:ℝ)*(N:ℝ) by ring] at htail
        exact htail
      · change Real.exp (-(N:ℝ)*A/t^2)≤_ at hmass
        rw [show -(N:ℝ)*A/t^2= -(A/t^2)*(N:ℝ) by ring] at hmass
        exact hmass
    · apply (hmono (activationUniform_smallWidth_subset b d S r φ)).trans
      have hNwidth : N≤activationUniformWidth b d S r := (lt_of_not_ge hlarge).le
      have hp : (Fintype.card (WeightIndex d N r):ℝ)≤(N:ℝ)*
          ((d:ℝ)+2+(r:ℝ)*(activationUniformWidth b d S r:ℝ)) := by
        simp only [WeightIndex,Fintype.card_sum,Fintype.card_prod,Fintype.card_fin]
        push_cast
        have hh : (N:ℝ)≤activationUniformWidth b d S r := by exact_mod_cast hNwidth
        nlinarith [mul_nonneg (Nat.cast_nonneg N) (mul_nonneg (Nat.cast_nonneg r) (sub_nonneg.mpr hh))]
      obtain ⟨hJD,hJA⟩ := activationUniform_smallWidth_gap (b:=b) (d:=d) (S:=S) (r:=r) (le_refl A) hε hlog
      have hh := bandPrior_smallWidth_relative_tail (by omega) hN hφ hℓ0.le ht ht1 hA hε
        (by linarith : ε≤2) hp hJD hJA f hmass
      exact (div_le_iff₀ hpos).mpr hh

end NeuralGeneralization.BatchTwoActivation
