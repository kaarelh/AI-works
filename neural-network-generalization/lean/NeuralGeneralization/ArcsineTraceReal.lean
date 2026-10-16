import NeuralGeneralization.ArcsineTraceLower
import NeuralGeneralization.ArcsineExponentialCusp

/-! Convenient real-power versions of the actual all-depth trace bounds. -/
noncomputable section
namespace NeuralGeneralization

lemma reciprocal_nat_rpow {r : ℕ} (hr : 0 < r) (β : ℝ) :
    (1/(r : ℝ))^β=(r : ℝ)^(-β) := by
  rw [one_div,Real.inv_rpow (by positivity : (0 : ℝ) ≤ r),Real.rpow_neg (by positivity)]

/-- Uniform upper trace bound for the actual kernel at every depth. -/
theorem iterated_arcsine_spectral_tail_upper (d k r : ℕ) (hr : 0 < r) :
    walshSpectralTail (arcsineProfile d k) r ≤ 4*(r : ℝ)^(-(1/(2 : ℝ)^k)) := by
  let T := walshSpectralTail (arcsineProfile d k) r
  let q : ℕ := 2^k
  let β : ℝ := 1/(q : ℝ)
  have hq : 0 < q := by dsimp [q]; positivity
  have hβ : 0 ≤ β := by dsimp [β]; positivity
  have hr0 : 0 < (r : ℝ) := by exact_mod_cast hr
  have hT : 0 ≤ T := Finset.sum_nonneg (fun S hS => arcsineProfile_coefficient_nonneg d k S)
  have hp := iterated_arcsine_spectral_tail_power d k r hr
  change (2*r : ℝ)*(T/4)^q ≤ 1 at hp
  have hb : (T/4)^q ≤ 1/(r : ℝ) := by
    apply (le_div_iff₀ hr0).mpr
    have hnonneg := mul_nonneg hr0.le (pow_nonneg (by positivity : 0 ≤ T/4) q)
    nlinarith only [hp,hnonneg]
  have hh := Real.rpow_le_rpow (pow_nonneg (by positivity : 0 ≤ T/4) q) hb hβ
  rw [show ((T/4)^q)^β=T/4 from nat_power_inverse_root q hq (by positivity),
    reciprocal_nat_rpow hr β] at hh
  have he : β=1/(2 : ℝ)^k := by simp [β,q]
  rw [← he]
  change T ≤ _
  linarith

/-- Matching lower trace bound in the uniform sparse-cutoff range. -/
theorem iterated_arcsine_spectral_tail_lower (d k r : ℕ) (hk : 1 ≤ k) (hr : 0 < r)
    (hdim : 131072*r ≤ d) :
    (r : ℝ)^(-(1/(2 : ℝ)^k))/16384 ≤ walshSpectralTail (arcsineProfile d k) r := by
  let T := walshSpectralTail (arcsineProfile d k) r
  let q : ℕ := 2^k
  let β : ℝ := 1/(q : ℝ)
  have hq : 0 < q := by dsimp [q]; positivity
  have hβ : 0 ≤ β := by dsimp [β]; positivity
  have hr0 : 0 < (r : ℝ) := by exact_mod_cast hr
  have hT : 0 ≤ T := Finset.sum_nonneg (fun S hS => arcsineProfile_coefficient_nonneg d k S)
  have hp := iterated_arcsine_spectral_tail_power_lower d k r hk hr hdim
  change 1 ≤ (r : ℝ)*(16384*T)^q at hp
  have hb : 1/(r : ℝ) ≤ (16384*T)^q := by
    apply (div_le_iff₀ hr0).mpr
    simpa only [mul_comm] using hp
  have hh := Real.rpow_le_rpow (by positivity : 0 ≤ 1/(r : ℝ)) hb hβ
  rw [show ((16384*T)^q)^β=16384*T from nat_power_inverse_root q hq (by positivity),
    reciprocal_nat_rpow hr β] at hh
  have he : β=1/(2 : ℝ)^k := by simp [β,q]
  rw [← he]
  change _ ≤ T
  linarith

end NeuralGeneralization
