import NeuralGeneralization.SpectralNoiseComparison

/-!
# Matching lower spectral trace bounds at every depth

An elementary two-noise argument proves the correct power without complex
singularity transfer. The constants are explicit and uniform over depth.
-/

noncomputable section
namespace NeuralGeneralization
open scoped BigOperators

def dyadicRoot : ℕ → ℝ → ℝ
  | 0,t => t
  | k+1,t => Real.sqrt (dyadicRoot k t)

theorem dyadicRoot_nonneg {t : ℝ} (ht : 0 ≤ t) (k : ℕ) : 0 ≤ dyadicRoot k t := by
  cases k with
  | zero => exact ht
  | succ k => exact Real.sqrt_nonneg _

theorem dyadicRoot_power {t : ℝ} (ht : 0 ≤ t) (k : ℕ) :
    (dyadicRoot k t)^(2^k) = t := by
  induction k with
  | zero => simp [dyadicRoot]
  | succ k ih =>
    rw [dyadicRoot,pow_succ,show 2^k*2 = 2*2^k by omega,pow_mul,
      Real.sq_sqrt (dyadicRoot_nonneg ht k),ih]

/-- Actual high-degree trace has the matching inverse-power lower bound
whenever the cutoff is a sufficiently small fixed fraction of dimension.
For `p=2^k`, this says `T_r ≥ r^(-1/p)/16384`.
All neural profiles and their Fourier weights are instantiated. -/
theorem iterated_arcsine_spectral_tail_power_lower (d k r : ℕ)
    (hk : 1 ≤ k) (hr : 0 < r) (hdim : 131072*r ≤ d) :
    1 ≤ (r : ℝ)*(16384*walshSpectralTail (arcsineProfile d k) r)^(2^k) := by
  let p := 2^k
  let x := dyadicRoot k (1/(r : ℝ))
  let η : ℝ := 1/65536
  let ρ : ℝ := 1-η/(r : ℝ)
  let ρ₀ : ℝ := 1-1/(r : ℝ)
  have hr0 : (0 : ℝ) < r := Nat.cast_pos.mpr hr
  have hr1 : (1 : ℝ) ≤ r := by exact_mod_cast hr
  have hd1 : (1 : ℝ) ≤ d := by exact_mod_cast (show 1 ≤ d by omega)
  have hp : 2 ≤ p := by
    dsimp [p]
    simpa using Nat.pow_le_pow_right (by decide : 0 < 2) hk
  have hx : 0 ≤ x := dyadicRoot_nonneg (by positivity) k
  have hxp : x^p = 1/(r : ℝ) := dyadicRoot_power (by positivity) k
  have hη0 : 0 ≤ η := by norm_num [η]
  have hη1 : η ≤ 1 := by norm_num [η]
  have hρ0 : 0 ≤ ρ := by
    have := (div_le_one hr0).mpr (hη1.trans hr1)
    dsimp [ρ]
    linarith
  have hρ1 : ρ ≤ 1 := by
    have := div_nonneg hη0 hr0.le
    dsimp [ρ]
    linarith
  have hρ₀0 : 0 ≤ ρ₀ := by
    have := (div_le_one hr0).mpr hr1
    dsimp [ρ₀]
    linarith
  have hρ₀1 : ρ₀ ≤ 1 := by
    have := (one_div_pos.mpr hr0).le
    dsimp [ρ₀]
    linarith
  have hmean : 2 ≤ (d : ℝ)*(1-ρ) := by
    have hdR : (131072 : ℝ)*r ≤ d := by exact_mod_cast hdim
    have heq : (d : ℝ)*(1-ρ) = (d : ℝ)/(65536*r) := by dsimp [ρ,η]; ring
    rw [heq]
    apply (le_div_iff₀ (by positivity : (0 : ℝ) < 65536*r)).mpr
    linarith
  have hfraction : (1 : ℝ)/2 ≤ (d : ℝ)/(d+1) := by
    apply (le_div_iff₀ (by positivity : (0 : ℝ) < d+1)).mpr
    linarith
  have hμlower : (1 : ℝ)/(131072*r) ≤ (d : ℝ)*(1-ρ)/(d+1) := by
    have hh := mul_le_mul_of_nonneg_right hfraction (div_nonneg hη0 hr0.le)
    have heq : (d : ℝ)/(d+1)*(η/r) = (d : ℝ)*(1-ρ)/(d+1) := by dsimp [ρ]; ring
    rw [heq] at hh
    have heq' : (1 : ℝ)/(131072*r) = (1/2)*(η/r) := by dsimp [η]; ring
    rwa [heq']
  have h512 : (131072 : ℝ) ≤ (512 : ℝ)^p := by
    have hh := pow_le_pow_right₀ (by norm_num : (1 : ℝ) ≤ 512) hp
    norm_num at hh ⊢
    linarith
  have hb : (2*(x/1024))^p ≤ (d : ℝ)*(1-ρ)/(d+1) := by
    have hh := div_le_div_of_nonneg_left (show 0 ≤ 1/(r : ℝ) by positivity)
      (by norm_num : (0 : ℝ) < 131072) h512
    have heq : (2*(x/1024))^p = (1/(r : ℝ))/(512 : ℝ)^p := by
      rw [show 2*(x/1024) = x/512 by ring,div_pow,hxp]
    rw [heq]
    apply hh.trans
    simpa only [div_div,mul_comm] using hμlower
  have hlow := arcsineNoiseGap_lower_of_power d k hρ0 hρ1 hmean
    (show 0 ≤ x/1024 by positivity) hb
  have hup := arcsineNoiseGap_power_le d k hρ₀0 hρ₀1
  have hupperpower : (arcsineNoiseGap d k ρ₀/2)^p ≤ x^p := by
    rw [hxp]
    apply hup.trans
    dsimp [ρ₀]
    have := (one_div_pos.mpr hr0).le
    linarith
  have hupper : arcsineNoiseGap d k ρ₀ ≤ 2*x := by
    have hgap := arcsineNoiseGap_nonneg d k hρ₀0 hρ₀1
    have hh := (pow_le_pow_iff_left₀ (by positivity : 0 ≤ arcsineNoiseGap d k ρ₀/2)
      hx (by omega : p ≠ 0)).mp hupperpower
    linarith
  have hcompare := arcsineNoiseGap_two_scale d k hr hη0 hη1
  change arcsineNoiseGap d k ρ ≤ 2*η*arcsineNoiseGap d k ρ₀+
    walshSpectralTail (arcsineProfile d k) r at hcompare
  have htail : x ≤ 16384*walshSpectralTail (arcsineProfile d k) r := by
    dsimp [η] at hcompare
    linarith
  have hpower := pow_le_pow_left₀ hx htail p
  rw [hxp] at hpower
  have hh := mul_le_mul_of_nonneg_left hpower hr0.le
  have heq : (r : ℝ)*(1/(r : ℝ)) = 1 := by field_simp
  rwa [heq] at hh

end NeuralGeneralization
