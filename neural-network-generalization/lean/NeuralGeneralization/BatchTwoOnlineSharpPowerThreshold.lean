import NeuralGeneralization.BatchTwoOnlineSharpSpectralTail

/-! The exact all-width cutoff T from the online above-mean-field corollary
implies both required Gaussian spectral conditions. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel

def powerWidthThreshold (d C r : ℕ) (K γ : ℝ) : ℕ :=
  ⌈max (C:ℝ) (max ((8*((d:ℝ)+1))^(1/(γ-1))) ((8/spectralRadius r K)^(2/(γ-1))))⌉₊

theorem width_scale_identity {N : ℕ} (hN : 0<N) (γ : ℝ) :
    (N:ℝ)*(powerStandardDeviation N γ)^2*((N:ℝ)^(γ-1))=1 := by
  have hn:0<(N:ℝ):=by exact_mod_cast hN
  rw [powerStandardDeviation_sq hN]
  calc
    _ = (N:ℝ)^((1+(-γ))+(γ-1)) := by rw [Real.rpow_add hn,Real.rpow_add hn,Real.rpow_one]
    _ = 1 := by rw [show 1+(-γ)+(γ-1)=0 by ring,Real.rpow_zero]

theorem power_spectral_conditions {d N r : ℕ} {K γ : ℝ} (hN : 0<N) (hK : 1≤K)
    (hfirst : 8*((d:ℝ)+1)≤(N:ℝ)^(γ-1))
    (hmat : 64/(spectralRadius r K)^2≤(N:ℝ)^(γ-1)) :
    8*((N*(d+1):ℕ):ℝ)*(powerStandardDeviation N γ)^2≤K ∧
      8*(powerStandardDeviation N γ)*Real.sqrt (N:ℝ)≤spectralRadius r K := by
  have hs:=powerStandardDeviation_pos hN γ
  have hprod:=width_scale_identity hN γ
  have hn:0<(N:ℝ):=by exact_mod_cast hN
  have hm0:0≤(N:ℝ)*(powerStandardDeviation N γ)^2:=by positivity
  have hf:=mul_le_mul_of_nonneg_left hfirst hm0
  have hb1:8*((N*(d+1):ℕ):ℝ)*(powerStandardDeviation N γ)^2≤1:=by
    push_cast
    nlinarith only [hf,hprod]
  refine ⟨hb1.trans hK,?_⟩
  have ha:spectralRadius r K>0:=spectralRadius_pos _ _
  have hm:64≤(N:ℝ)^(γ-1)*(spectralRadius r K)^2:=
    (div_le_iff₀ (sq_pos_of_pos ha)).mp hmat
  have hm':=mul_le_mul_of_nonneg_left hm hm0
  have hsq:(8*powerStandardDeviation N γ*Real.sqrt (N:ℝ))^2≤(spectralRadius r K)^2:=by
    rw [mul_pow,mul_pow,Real.sq_sqrt hn.le]
    have he:(N:ℝ)*(powerStandardDeviation N γ)^2*((N:ℝ)^(γ-1)*(spectralRadius r K)^2)=
        (spectralRadius r K)^2:=by nlinarith only [congrArg (fun z:ℝ=>z*(spectralRadius r K)^2) hprod]
    rw [he] at hm'
    nlinarith only [hm']
  exact (sq_le_sq₀ (by positivity) ha.le).mp hsq

theorem powerWidthThreshold_conditions {d C N r : ℕ} {K γ : ℝ}
    (hγ : 1<γ) (hTN : powerWidthThreshold d C r K γ≤N) :
    C≤N ∧ 8*((d:ℝ)+1)≤(N:ℝ)^(γ-1) ∧
      64/(spectralRadius r K)^2≤(N:ℝ)^(γ-1) := by
  have hmax:max (C:ℝ) (max ((8*((d:ℝ)+1))^(1/(γ-1))) ((8/spectralRadius r K)^(2/(γ-1))))≤N:=
    (Nat.le_ceil _).trans (show (powerWidthThreshold d C r K γ:ℝ)≤N by exact_mod_cast hTN)
  have hC:(C:ℝ)≤N:=(le_max_left _ _).trans hmax
  have hbase:(8*((d:ℝ)+1))^(1/(γ-1))≤N:=
    (le_trans (le_max_left _ _) (le_max_right _ _)).trans hmax
  have hmatrix:(8/spectralRadius r K)^(2/(γ-1))≤N:=
    (le_trans (le_max_right _ _) (le_max_right _ _)).trans hmax
  have hq:0<γ-1:=by linarith
  have ha:0<spectralRadius r K:=spectralRadius_pos _ _
  have hf:=Real.rpow_le_rpow (Real.rpow_nonneg (by positivity) _) hbase hq.le
  have hm:=Real.rpow_le_rpow (Real.rpow_nonneg (by positivity) _) hmatrix hq.le
  rw [←Real.rpow_mul (by positivity : 0≤8*((d:ℝ)+1)),div_mul_cancel₀ _ hq.ne',Real.rpow_one] at hf
  rw [←Real.rpow_mul (by positivity : 0≤8/spectralRadius r K),div_mul_cancel₀ _ hq.ne',Real.rpow_two] at hm
  refine ⟨by exact_mod_cast hC,hf,?_⟩
  norm_num only [div_pow,show (8:ℝ)^2=64 by norm_num] at hm
  exact hm

/-- The literal raw exceptional-mass estimate, with no asymptotic width
threshold hidden in the hypotheses. -/
theorem powerPrior_normFunctions_tail {d N r : ℕ} {K γ : ℝ} (hd : 1≤d) (hN : 0<N)
    (hK : 1≤K) (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    (hfirst : 8*((d:ℝ)+1)≤(N:ℝ)^(γ-1))
    (hmat : 64/(spectralRadius r K)^2≤(N:ℝ)^(γ-1)) :
    (∑f∈Finset.univ\normFunctions d r φ (((r:ℝ)+5)*K),
      functionMass φ (1/2) (powerPrior d N r γ) f)≤
      ((r:ℝ)+2)*Real.exp (-K*(N:ℝ)^γ/8) := by
  obtain ⟨hf,hm⟩:=power_spectral_conditions hN hK hfirst hmat
  have ht:=smallPrior_normFunctions_tail hd hN hK (powerStandardDeviation_pos hN γ) hφ hf hm
  rw [←powerPrior_eq_smallPrior_standardDeviation hN γ] at ht
  have he:-K/(8*(powerStandardDeviation N γ)^2)=-K*(N:ℝ)^γ/8:=by
    rw [powerStandardDeviation_sq hN,Real.rpow_neg (Nat.cast_nonneg N)]
    field_simp
  simpa only [he] using ht

end NeuralGeneralization.BatchTwoOnlineSharp
