import NeuralGeneralization.OnlineLowerTanhMixtureBounds

/-! # A fixed bias window of negative curvature near a periodic maximum -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma periodicCoefficient_zero_lower {a lo hi : ℝ} (hlo : 0 < lo)
    (haLo : lo ≤ a) (haHi : a ≤ hi) :
    (Real.pi/hi)/Real.sinh (periodicDecay lo) ≤ periodicCoefficient a 0 := by
  have ha := hlo.trans_le haLo
  have hhi := ha.trans_le haHi
  have hdec : periodicDecay a ≤ periodicDecay lo := by
    unfold periodicDecay
    exact div_le_div_of_nonneg_left (sq_nonneg _) (by positivity) (by linarith)
  have hnum := div_le_div_of_nonneg_left Real.pi_pos.le ha haHi
  have hden := Real.sinh_le_sinh.mpr hdec
  simp only [periodicCoefficient,Nat.cast_zero,mul_zero,zero_add,one_mul]
  exact (div_le_div_of_nonneg_right hnum (Real.sinh_pos_iff.mpr (periodicDecay_pos hlo)).le).trans
    (div_le_div_of_nonneg_left (div_nonneg Real.pi_pos.le ha.le)
      (Real.sinh_pos_iff.mpr (periodicDecay_pos ha)) hden)

lemma firstMomentMajorant_nonneg {lo hi : ℝ} (hlo : 0 < lo) (hhi : 0 < hi) (l : ℕ) :
    0 ≤ firstMomentMajorant lo hi l := by
  unfold firstMomentMajorant
  apply add_nonneg _ (secondMomentMajorant_nonneg hlo hhi l)
  have hs := Real.sinh_pos_iff.mpr (periodicDecay_pos hhi)
  positivity [(periodicRatio_mem hhi).1]

/-- A finite periodic phase mixture near the maximum retains restoring
curvature on an explicit neighborhood of zero; both signs are allowed. -/
theorem smoothed_restoring_window {m : ℕ} (p phase : Fin m → ℝ)
    {a E lo hi σ c₀ : ℝ} (hlo : 0 < lo) (haLo : lo ≤ a) (haHi : a ≤ hi)
    (hhi2 : hi ≤ 2) (hE : 0 ≤ E) (hσ : |σ| ≤ 1)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i,p i=1)
    (hc₀ : 0 < c₀) (hcLower : c₀ ≤ periodicCoefficient a 0)
    (hnear : (999/1000)*periodicFourierMaximum a ≤ ∑ i,p i*(σ*smoothedResponse a E (phase i)))
    (b : ℝ) (hb : |b| ≤ c₀/(1000*((∑' l : ℕ, firstMomentMajorant lo hi l)+1))) :
    (∑ i,p i*(σ*(-smoothedSecondMoment a E (phase i+b)))) ≤
      -(1/1000)*periodicFrequency a^2*periodicCoefficient a 0 := by
  have ha := hlo.trans_le haLo
  have hhi := ha.trans_le haHi
  let M := ∑' l : ℕ, firstMomentMajorant lo hi l
  have hM : 0 ≤ M := tsum_nonneg (firstMomentMajorant_nonneg hlo hhi)
  have hD : 0 < 1000*(M+1) := by positivity
  have hsmall : M*|b| ≤ c₀/1000 := by
    have hh := mul_le_mul_of_nonneg_left hb hM
    have hr : M*(c₀/(1000*(M+1))) ≤ c₀/1000 := by
      apply (le_div_iff₀ (by norm_num : (0:ℝ)<1000)).mpr
      have hden : M+1 ≠ 0 := by positivity
      have he : M*(c₀/(1000*(M+1)))*1000 = c₀*M/(M+1) := by field_simp
      rw [he]
      exact (div_le_iff₀ (by positivity : 0<M+1)).mpr (by nlinarith)
    exact hh.trans hr
  have herror (i : Fin m) :
      |σ*smoothedResponse a E (phase i+b)-σ*smoothedResponse a E (phase i)| ≤ M*|b| := by
    rw [← mul_sub,abs_mul]
    have h1 := mul_le_of_le_one_left (abs_nonneg (smoothedResponse a E (phase i+b)-smoothedResponse a E (phase i))) hσ
    have h2 := smoothedResponse_lipschitz_compact hlo haLo haHi hE (phase i+b) (phase i)
    simpa only [add_sub_cancel_left] using h1.trans h2
  have havg := weighted_uniform_error p
    (fun i => σ*smoothedResponse a E (phase i+b))
    (fun i => σ*smoothedResponse a E (phase i)) hp hsum herror
  have hF := periodicFourierMaximum_lower ha (haHi.trans hhi2)
  have hnew : (99/100)*periodicFourierMaximum a ≤
      ∑ i,p i*(σ*smoothedResponse a E (phase i+b)) := by
    have hlow := (abs_le.mp havg).1
    nlinarith
  exact smoothed_restoring_average_signed ha (haHi.trans hhi2) hE hσ p
    (fun i => phase i+b) hp hsum.le hnew

theorem smoothed_restoring_window_signs {m : ℕ} (p phase : Fin m → ℝ)
    {a E lo hi c₀ : ℝ} (σ : Fin m → ℝ) (hlo : 0 < lo) (haLo : lo ≤ a) (haHi : a ≤ hi)
    (hhi2 : hi ≤ 2) (hE : 0 ≤ E) (hσ : ∀ i, |σ i| ≤ 1)
    (hp : ∀ i, 0 ≤ p i) (hsum : ∑ i,p i=1)
    (hc₀ : 0 < c₀) (hcLower : c₀ ≤ periodicCoefficient a 0)
    (hnear : (999/1000)*periodicFourierMaximum a ≤ ∑ i,p i*(σ i*smoothedResponse a E (phase i)))
    (b : ℝ) (hb : |b| ≤ c₀/(1000*((∑' l : ℕ, firstMomentMajorant lo hi l)+1))) :
    (∑ i,p i*(σ i*(-smoothedSecondMoment a E (phase i+b)))) ≤
      -(1/1000)*periodicFrequency a^2*periodicCoefficient a 0 := by
  have ha := hlo.trans_le haLo
  have hhi := ha.trans_le haHi
  let M := ∑' l : ℕ, firstMomentMajorant lo hi l
  have hM : 0 ≤ M := tsum_nonneg (firstMomentMajorant_nonneg hlo hhi)
  have hD : 0 < 1000*(M+1) := by positivity
  have hsmall : M*|b| ≤ c₀/1000 := by
    have hh := mul_le_mul_of_nonneg_left hb hM
    have hr : M*(c₀/(1000*(M+1))) ≤ c₀/1000 := by
      apply (le_div_iff₀ (by norm_num : (0:ℝ)<1000)).mpr
      have hden : M+1 ≠ 0 := by positivity
      have he : M*(c₀/(1000*(M+1)))*1000 = c₀*M/(M+1) := by field_simp
      rw [he]
      exact (div_le_iff₀ (by positivity : 0<M+1)).mpr (by nlinarith)
    exact hh.trans hr
  have herror (i : Fin m) :
      |σ i*smoothedResponse a E (phase i+b)-σ i*smoothedResponse a E (phase i)| ≤ M*|b| := by
    rw [← mul_sub,abs_mul]
    have h1 := mul_le_of_le_one_left (abs_nonneg (smoothedResponse a E (phase i+b)-smoothedResponse a E (phase i))) (hσ i)
    have h2 := smoothedResponse_lipschitz_compact hlo haLo haHi hE (phase i+b) (phase i)
    simpa only [add_sub_cancel_left] using h1.trans h2
  have havg := weighted_uniform_error p
    (fun i => σ i*smoothedResponse a E (phase i+b))
    (fun i => σ i*smoothedResponse a E (phase i)) hp hsum herror
  have hF := periodicFourierMaximum_lower ha (haHi.trans hhi2)
  have hnew : (99/100)*periodicFourierMaximum a ≤
      ∑ i,p i*(σ i*smoothedResponse a E (phase i+b)) := by
    have hlow := (abs_le.mp havg).1
    nlinarith
  exact smoothed_restoring_average_signs σ ha (haHi.trans hhi2) hE hσ p
    (fun i => phase i+b) hp hsum.le hnew

end NeuralGeneralization.OnlineLowerTanh
