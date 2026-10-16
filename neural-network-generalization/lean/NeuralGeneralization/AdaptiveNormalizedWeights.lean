import NeuralGeneralization.ActualAdaptiveSpectrum
import NeuralGeneralization.LargeSampleBudgets

/-! The three subcritical regimes reduce to the same normalized scalar
budget.  These are inequalities for the actual neural exponent and trace. -/
noncomputable section
namespace NeuralGeneralization.AdaptiveCutoff

lemma neural_exponent_pos (k : ℕ) : 0 < 1/(2:ℝ)^(k+1) := by positivity
lemma neural_exponent_le_half (k : ℕ) : 1/(2:ℝ)^(k+1) ≤ 1/2 := by
  have hp : (1:ℝ)≤2^k := one_le_pow₀ (by norm_num)
  apply (div_le_div_iff₀ (by positivity : (0:ℝ)<2^(k+1)) (by norm_num : (0:ℝ)<2)).mpr
  rw [pow_succ]
  nlinarith only [hp]

lemma positive_weight_bounds {d r β : ℝ} (hr : 1≤r) (hrd : r≤d)
    (hβ0 : 0≤β) (hβ1 : β≤1) :
    0≤d^β ∧ d^β*r^(-β)≤d/r ∧ d^β≤d := by
  have hd : 1≤d := hr.trans hrd
  refine ⟨Real.rpow_nonneg (by linarith only [hd]) _,
    rpow_weight_ratio (by linarith only [hr]) hrd hβ1,?_⟩
  simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le hd hβ1

lemma zero_weight_bounds {d r β : ℝ} (hr : 1≤r) (hrd : r≤d)
    (hβ0 : 0≤β) (hβ1 : 2*β≤1) :
    0≤d^(2*β)*r^(-β) ∧
      (d^(2*β)*r^(-β))*r^(-β)≤d/r ∧ d^(2*β)*r^(-β)≤d := by
  have hr0 : 0<r := by linarith only [hr]
  have hd : 1≤d := hr.trans hrd
  have hp : r^(-β)≤1 := by
    simpa only [Real.rpow_zero] using Real.rpow_le_rpow_of_exponent_le hr (by linarith : -β≤0)
  refine ⟨by positivity,?_,?_⟩
  · have he : (d^(2*β)*r^(-β))*r^(-β)=d^(2*β)*r^(-(2*β)) := by
      rw [mul_assoc,←Real.rpow_add hr0]
      congr 2 <;> ring
    rw [he]
    exact rpow_weight_ratio hr0 hrd hβ1
  · have hh : d^(2*β)≤d := by
      simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le hd hβ1
    calc
      _ ≤ d^(2*β)*1 := mul_le_mul_of_nonneg_left hp (by positivity)
      _ ≤ d := by simpa only [mul_one] using hh

lemma negative_weight_bounds {d r β : ℝ} (hr : 1≤r) (hrd : r≤d)
    (hβ0 : 0≤β) (hβ1 : β≤1) :
    0≤r^β ∧ r^β*r^(-β)≤d/r ∧ r^β≤d := by
  have hr0 : 0<r := by linarith only [hr]
  refine ⟨Real.rpow_nonneg hr0.le _,?_,?_⟩
  · rw [←Real.rpow_add hr0,add_neg_cancel,Real.rpow_zero]
    exact (le_div_iff₀ hr0).mpr (by simpa only [one_mul] using hrd)
  · have hh : r^β≤r := by
      simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le hr hβ1
    exact hh.trans hrd

/-- The actual upper-cutoff trace is comparable with the lower-cutoff power.
The logarithmic gap therefore costs only a fixed numerical factor. -/
theorem upper_trace_lower_of_largeCutoff {d n r : ℕ} {A ε : ℝ}
    (k : ℕ) (hcut : LargeCutoff d n A ε r) :
    (r:ℝ)^(-(1/(2:ℝ)^(k+1)))/65536 ≤
      walshSpectralTail (arcsineProfile d (k+1)) (r+additionalBand d+1) := by
  let β : ℝ := 1/(2:ℝ)^(k+1)
  let u : ℕ := r+additionalBand d+1
  have hr : 1≤r := hcut.positive
  have hr0 : (0:ℝ)<r := Nat.cast_pos.mpr (by omega)
  have hu : 0<u := by dsimp [u]; omega
  have hu4 : (u:ℝ)≤4*(r:ℝ) := by
    have hh : r+additionalBand d≤2*r := hcut.band_le
    exact_mod_cast (show u≤4*r by dsimp [u]; omega)
  have hβ0 : 0≤β := (neural_exponent_pos k).le
  have hβ1 : β≤1 := (neural_exponent_le_half k).trans (by norm_num)
  have hpow : (4*(r:ℝ))^(-β)≤(u:ℝ)^(-β) :=
    Real.rpow_le_rpow_of_nonpos (Nat.cast_pos.mpr hu) hu4 (by linarith only [hβ0])
  have h4 : (1:ℝ)/4≤4^(-β) := by
    have hh := Real.rpow_le_rpow_of_exponent_le (by norm_num : (1:ℝ)≤4)
      (show (-1:ℝ)≤ -β by linarith only [hβ1])
    norm_num only [Real.rpow_neg_one] at hh
    exact hh
  have hlow : (r:ℝ)^(-β)/4≤(u:ℝ)^(-β) := by
    have hh := mul_le_mul_of_nonneg_right h4 (Real.rpow_nonneg hr0.le (-β))
    rw [Real.mul_rpow (by norm_num : (0:ℝ)≤4) hr0.le] at hpow
    nlinarith only [hh,hpow]
  have ht := iterated_arcsine_spectral_tail_lower d (k+1) u (by omega) hu hcut.degree_le
  change (u:ℝ)^(-β)/16384≤_ at ht
  change (r:ℝ)^(-β)/65536≤_
  linarith only [hlow,ht]

lemma normalized_gram_bound {d r n L A U τ ell s₂ G Cg C T : ℝ}
    (hd : 0≤d) (hr : 0<r) (hn : 0≤n) (hL : 0≤L)
    (hA : 0≤A) (hU : 0≤U) (hCg : 0≤Cg) (hT : 0≤T)
    (htrace : τ≤U*T)
    (heigen : n*ell≤2*A*U*L*T/r)
    (hsecond : Real.sqrt (n*d*s₂)≤Real.sqrt (2*A*U)*T*Real.sqrt (d*L)/r)
    (hgram : G≤Cg*(τ+Real.sqrt (n*d*s₂)+n*ell))
    (hC0 : Cg*U≤C) (hC1 : Cg*Real.sqrt (2*A*U)≤C) (hC2 : Cg*(2*A*U)≤C) :
    G≤C*T*(1+Real.sqrt (d*L)/r+L/r) := by
  have h0 := mul_le_mul_of_nonneg_left htrace hCg
  have h1 := mul_le_mul_of_nonneg_left hsecond hCg
  have h2 := mul_le_mul_of_nonneg_left heigen hCg
  have h0' := mul_le_mul_of_nonneg_right hC0 hT
  have h1' := mul_le_mul_of_nonneg_right hC1 (show 0≤T*Real.sqrt (d*L)/r by positivity)
  have h2' := mul_le_mul_of_nonneg_right hC2 (show 0≤L*T/r by positivity)
  have he : C*T+C*(T*Real.sqrt (d*L)/r)+C*(L*T/r)=
      C*T*(1+Real.sqrt (d*L)/r+L/r) := by ring
  ring_nf at hgram h0 h1 h2 h0' h1' h2' he ⊢
  linarith only [hgram,h0,h1,h2,h0',h1',h2',he]

end NeuralGeneralization.AdaptiveCutoff
