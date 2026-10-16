import NeuralGeneralization.AdaptiveNormalizedWeights
import NeuralGeneralization.GaussianNegativeDeterministic

/-! Explicit scalar conversion for the actual sign-conditioned Gaussian
posterior in the adaptive large-sample argument. -/
noncomputable section
namespace NeuralGeneralization.SubcriticalNegativeLargeSample
open AdaptiveCutoff GaussianSignConfidence

def marginFactor : ℝ := Real.pi*(Real.exp (-1)-7/20)^2/262144

def tailTolerance : ℝ := min (marginFactor/32) (1/4194304)

lemma marginFactor_pos : 0<marginFactor := by
  unfold marginFactor
  have hc := buffered_confidence_constant_pos
  positivity

lemma tailTolerance_pos : 0<tailTolerance :=
  lt_min (div_pos marginFactor_pos (by norm_num)) (by norm_num)

lemma negative_margin_scalar_budgets {d n r : ℕ} {A ε ell : ℝ}
    (k : ℕ) (hcut : LargeCutoff d n A ε r)
    (hell : 0≤ell)
    (hsmall : (n:ℝ)*ell*((d:ℝ)+1)^10≤tailTolerance) :
    let β : ℝ := 1/(2:ℝ)^(k+1)
    let T : ℝ := (r:ℝ)^(-β)
    let W : ℝ := (r:ℝ)^β
    let τ := walshSpectralTail (arcsineProfile d (k+1)) (r+additionalBand d+1)
    let b := Real.sqrt (Real.pi*τ)*(Real.exp (-1)-7/20)/2
    0<τ ∧ 0<b ∧ marginFactor*T≤b^2 ∧
      (n:ℝ)/b^2≤(1/marginFactor)*(n:ℝ)*W ∧
      2*(n:ℝ)*ell/τ≤1/32 ∧ (n:ℝ)*ell≤b^2/32 := by
  dsimp only
  let β : ℝ := 1/(2:ℝ)^(k+1)
  let T : ℝ := (r:ℝ)^(-β)
  let W : ℝ := (r:ℝ)^β
  let τ := walshSpectralTail (arcsineProfile d (k+1)) (r+additionalBand d+1)
  let b := Real.sqrt (Real.pi*τ)*(Real.exp (-1)-7/20)/2
  have hr : (1:ℝ)≤r := by exact_mod_cast hcut.positive
  have hr0 : (0:ℝ)<r := by linarith
  have hrd : (r:ℝ)≤d := by
    exact_mod_cast (show r≤d by have := hcut.degree_le; omega)
  have hW := negative_weight_bounds hr hrd (neural_exponent_pos k).le
    ((neural_exponent_le_half k).trans (by norm_num))
  change 0≤W ∧ W*T≤(d:ℝ)/(r:ℝ) ∧ W≤d at hW
  have hTW : T*W=1 := by
    dsimp [T,W]
    rw [←Real.rpow_add hr0,neg_add_cancel,Real.rpow_zero]
  have hT : 0<T := Real.rpow_pos_of_pos hr0 _
  have hτ : T/65536≤τ := upper_trace_lower_of_largeCutoff k hcut
  have hτpos : 0<τ := (div_pos hT (by norm_num)).trans_le hτ
  have hc := buffered_confidence_constant_pos
  have hb : 0<b := by dsimp [b]; positivity
  have hb2 : b^2=Real.pi*τ*(Real.exp (-1)-7/20)^2/4 := by
    dsimp [b]
    rw [div_pow,mul_pow,Real.sq_sqrt (mul_pos Real.pi_pos hτpos).le]
    ring
  have hbound : marginFactor*T≤b^2 := by
    rw [hb2]
    unfold marginFactor
    have hh := mul_le_mul_of_nonneg_left hτ
      (show 0≤Real.pi*(Real.exp (-1)-7/20)^2 by positivity)
    nlinarith only [hh]
  have hB : (n:ℝ)/b^2≤(1/marginFactor)*(n:ℝ)*W := by
    have hh := div_le_div_of_nonneg_left (Nat.cast_nonneg n : (0:ℝ)≤n)
      (mul_pos marginFactor_pos hT) hbound
    apply hh.trans_eq
    apply (div_eq_iff (mul_pos marginFactor_pos hT).ne').mpr
    have hk := marginFactor_pos.ne'
    field_simp
    nlinarith only [hTW]
  have hD : 1≤(d:ℝ)+1 := by linarith [Nat.cast_nonneg (α:=ℝ) d]
  have hdpow : (d:ℝ)≤((d:ℝ)+1)^10 := by
    have hh := pow_le_pow_right₀ hD (by norm_num : (1:ℕ)≤10)
    norm_num only [pow_one] at hh
    linarith
  have hNW : (n:ℝ)*ell*W≤tailTolerance := by
    have hh := mul_le_mul_of_nonneg_left (hW.2.2.trans hdpow)
      (mul_nonneg (Nat.cast_nonneg n) hell)
    exact hh.trans hsmall
  have hnT : (n:ℝ)*ell≤tailTolerance*T := by
    have hh := mul_le_mul_of_nonneg_right hNW hT.le
    rw [mul_assoc ((n:ℝ)*ell),mul_comm W T,hTW,mul_one] at hh
    exact hh
  have hv : 2*(n:ℝ)*ell/τ≤1/32 := by
    apply (div_le_iff₀ hτpos).mpr
    have ht := min_le_right (marginFactor/32) (1/4194304:ℝ)
    have hh := mul_le_mul_of_nonneg_right ht hT.le
    change tailTolerance*T≤(1/4194304)*T at hh
    linarith only [hnT,hτ,hh]
  have he : (n:ℝ)*ell≤b^2/32 := by
    have ht := min_le_left (marginFactor/32) (1/4194304:ℝ)
    have hh := mul_le_mul_of_nonneg_right ht hT.le
    change tailTolerance*T≤(marginFactor/32)*T at hh
    linarith only [hnT,hh,hbound]
  exact ⟨hτpos,hb,hbound,hB,hv,he⟩

end NeuralGeneralization.SubcriticalNegativeLargeSample
