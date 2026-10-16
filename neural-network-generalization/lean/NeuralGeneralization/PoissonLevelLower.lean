import NeuralGeneralization.PoissonBetaBounds

/-! Lower bounds for Poissonized spectral levels, uniform below any
fixed fraction of the middle degree. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

lemma poisson_level_integrable {D j : ℕ} (hj : 1 ≤ j) {β : ℝ}
    (hβ0 : 0 < β) (hβ1 : β < 1) :
    IntegrableOn (fun u : ℝ => u^(-1-β)*(poissonFlipProbability u)^j*
      (1-poissonFlipProbability u)^(D-j)) (Ioi 0) := by
  let F : ℝ → ℝ := fun u => u^(-1-β)*(poissonFlipProbability u)^j*
    (1-poissonFlipProbability u)^(D-j)
  have hfinite : IntegrableOn F (Ioc 0 1) :=
    (integrableOn_Ioc_iff_integrableOn_Ioo (by finiteness)).mpr
      (poisson_beta_finite_bounds (D := D) hj hβ0 hβ1 (by norm_num : (0 : ℝ) < 1)).1
  have htail : IntegrableOn F (Ioi 1) := by
    apply (integrableOn_Ioi_rpow_of_lt (by linarith : -1-β < -1)
      (by norm_num : (0 : ℝ) < 1)).mono'
    · apply Measurable.aestronglyMeasurable
      dsimp [F,poissonFlipProbability]
      fun_prop
    · filter_upwards [ae_restrict_mem measurableSet_Ioi] with u hu
      have hu0 : 0 ≤ u := le_trans (by norm_num : (0 : ℝ) ≤ 1) hu.le
      have hp0 := poissonFlipProbability_nonneg hu0
      have hp1 : poissonFlipProbability u ≤ 1 := (poissonFlipProbability_lt_half u).le.trans (by norm_num)
      have hq0 : 0 ≤ 1-poissonFlipProbability u := by linarith
      have hq1 : 1-poissonFlipProbability u ≤ 1 := by linarith
      have hF0 : 0 ≤ F u := by dsimp [F]; positivity
      rw [Real.norm_eq_abs,abs_of_nonneg hF0]
      calc
        F u ≤ u^(-1-β)*1*1 := by
          dsimp [F]
          gcongr
          · exact pow_le_one₀ hp0 hp1
          · exact pow_le_one₀ hq0 hq1
        _ = _ := by ring
  simpa only [Ioc_union_Ioi_eq_Ioi (by norm_num : (0 : ℝ) ≤ 1)] using
    hfinite.union htail

/-- Exact mean control for the reference beta law. -/
lemma beta_reference_mean_le {D j : ℕ} (hjD : j ≤ D) {β ρ : ℝ}
    (hβ0 : 0 ≤ β) (hβ1 : β < 1) (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1)
    (hjρ : (j : ℝ) ≤ ρ*D) :
    ((j : ℝ)-β)/((D : ℝ)+1-β) ≤ ρ := by
  have hden : 0 < (D : ℝ)+1-β := by
    have hd0 : (0 : ℝ) ≤ D := by positivity
    linarith
  apply (div_le_iff₀ hden).mpr
  have hh : 0 ≤ ρ*(1-β) := mul_nonneg hρ0 (by linarith)
  nlinarith

/-- A complete lower estimate before the final Gamma-ratio normalization. -/
theorem poisson_level_beta_lower {D j : ℕ} (hj : 1 ≤ j) (hjD : j ≤ D)
    {β ρ a : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (ha : 0 < a)
    (hρp : ρ < poissonFlipProbability a) (hjρ : (j : ℝ) ≤ ρ*D) :
    Real.exp (-2*a*(1+β))*(1-ρ/poissonFlipProbability a)*
      (∫ p : ℝ in Ioo 0 1,p^((j : ℝ)-β-1)*(1-p)^(D-j)) ≤
      ∫ u : ℝ in Ioi 0,u^(-1-β)*(poissonFlipProbability u)^j*
        (1-poissonFlipProbability u)^(D-j) := by
  let B : ℝ := ∫ p : ℝ in Ioo 0 1,p^((j : ℝ)-β-1)*(1-p)^(D-j)
  let Bt : ℝ := ∫ p : ℝ in Ioo 0 (poissonFlipProbability a),
    p^((j : ℝ)-β-1)*(1-p)^(D-j)
  have hjR : (1 : ℝ) ≤ j := by exact_mod_cast hj
  have hpa : 0 < poissonFlipProbability a := poissonFlipProbability_pos ha
  have hp1 : poissonFlipProbability a < 1 := (poissonFlipProbability_lt_half a).trans (by norm_num)
  have hb := real_beta_truncated_lower (by linarith : 0 < (j : ℝ)-β)
    (by positivity : 0 < ((D-j : ℕ) : ℝ)+1) hpa hp1
  rw [Nat.cast_sub hjD] at hb
  have he : (j : ℝ)-β+(D-j+1)=D+1-β := by ring
  rw [he,div_mul_eq_div_mul_one_div] at hb
  have hbe : (fun p : ℝ => p^((j : ℝ)-β-1)*(1-p)^((D : ℝ)-j+1-1)) =
      fun p : ℝ => p^((j : ℝ)-β-1)*(1-p)^((D : ℝ)-j) := by
    funext p
    rw [add_sub_cancel_right]
  rw [hbe] at hb
  have hconvert : (fun p : ℝ => p^((j : ℝ)-β-1)*(1-p)^((D : ℝ)-j)) =
      fun p : ℝ => p^((j : ℝ)-β-1)*(1-p)^(D-j) := by
    funext p
    rw [← Nat.cast_sub hjD,Real.rpow_natCast]
  rw [hconvert] at hb
  have hmean := beta_reference_mean_le hjD hβ0.le hβ1 hρ0 hρ1 hjρ
  have hB0 : 0 ≤ B := by
    apply setIntegral_nonneg measurableSet_Ioo
    intro p hp
    exact mul_nonneg (Real.rpow_nonneg hp.1.le _) (pow_nonneg (by linarith [hp.2]) _)
  have hbt : (1-ρ/poissonFlipProbability a)*B ≤ Bt := by
    apply le_trans _ hb
    apply mul_le_mul_of_nonneg_right _ hB0
    rw [div_eq_mul_one_div ρ]
    exact sub_le_sub_left (mul_le_mul_of_nonneg_right hmean (by positivity)) 1
  have hf := poisson_beta_finite_bounds (D := D) hj hβ0 hβ1 ha
  have hfull := poisson_level_integrable (D := D) hj hβ0 hβ1
  have hset : (∫ u : ℝ in Ioo 0 a,u^(-1-β)*(poissonFlipProbability u)^j*
      (1-poissonFlipProbability u)^(D-j)) ≤
      ∫ u : ℝ in Ioi 0,u^(-1-β)*(poissonFlipProbability u)^j*
        (1-poissonFlipProbability u)^(D-j) := by
    apply setIntegral_mono_set hfull _ (Filter.Eventually.of_forall (fun _ hu => hu.1))
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with u hu
    have hu0 : 0 ≤ u := hu.le
    have hp0 := poissonFlipProbability_nonneg hu0
    have hq0 : 0 ≤ 1-poissonFlipProbability u := by linarith [poissonFlipProbability_lt_half u]
    positivity
  calc
    _ ≤ Real.exp (-2*a*(1+β))*Bt := by
      simpa only [mul_assoc] using
        mul_le_mul_of_nonneg_left hbt (Real.exp_pos (-2*a*(1+β))).le
    _ ≤ _ := hf.2.1.trans hset


/-- The normalized Gamma-walk reference has the sharp power-law level
lower bound, with constants independent of dimension and degree. -/
theorem poisson_level_normalized_lower {D j : ℕ} (hj : 1 ≤ j) (hjD : j ≤ D)
    {β ρ a : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1)
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ ≤ 1) (ha : 0 < a)
    (hρp : ρ < poissonFlipProbability a) (hjρ : (j : ℝ) ≤ ρ*D) :
    (1-β)*Real.exp (-2*a*(1+β))*(1-ρ/poissonFlipProbability a) ≤
      (j : ℝ)^(1+β)*(D.choose j : ℝ)*((D : ℝ)^(-β)*
        (∫ u : ℝ in Ioi 0,u^(-1-β)*(poissonFlipProbability u)^j*
          (1-poissonFlipProbability u)^(D-j))) := by
  let c := Real.exp (-2*a*(1+β))*(1-ρ/poissonFlipProbability a)
  let B := ∫ p : ℝ in Ioo 0 1,p^((j : ℝ)-β-1)*(1-p)^(D-j)
  let I := ∫ u : ℝ in Ioi 0,u^(-1-β)*(poissonFlipProbability u)^j*
    (1-poissonFlipProbability u)^(D-j)
  let w := (j : ℝ)^(1+β)*(D.choose j : ℝ)
  have hc : 0 ≤ c := by
    dsimp [c]
    apply mul_nonneg (Real.exp_pos _).le
    exact sub_nonneg.mpr (div_le_one_of_le₀ hρp.le (poissonFlipProbability_pos ha).le)
  have hw : 0 ≤ w := by dsimp [w]; positivity
  have hD : 0 < (D : ℝ) := by exact_mod_cast (lt_of_lt_of_le (show 0 < j by omega) hjD)
  have hDpow : 0 ≤ (D : ℝ)^(-β) := Real.rpow_nonneg hD.le _
  have hi : c*B ≤ I := poisson_level_beta_lower hj hjD hβ0 hβ1 hρ0 hρ1 ha hρp hjρ
  have hb : (1-β)*((D : ℝ)+1)^β ≤ w*B := by
    simpa only [Real.rpow_natCast] using (binomial_beta_reference_bounds hj hjD hβ0 hβ1).1
  have hscale : 1 ≤ (D : ℝ)^(-β)*((D : ℝ)+1)^β := by
    have hh := Real.rpow_le_rpow hD.le (by linarith : (D : ℝ) ≤ D+1) hβ0.le
    have hm := mul_le_mul_of_nonneg_left hh hDpow
    rw [← Real.rpow_add hD,neg_add_cancel,Real.rpow_zero] at hm
    exact hm
  change (1-β)*Real.exp (-2*a*(1+β))*(1-ρ/poissonFlipProbability a) ≤ w*((D : ℝ)^(-β)*I)
  rw [mul_assoc]
  change (1-β)*c ≤ w*((D : ℝ)^(-β)*I)
  calc
    (1-β)*c ≤ ((1-β)*c)*((D : ℝ)^(-β)*((D : ℝ)+1)^β) := by
      simpa only [mul_one] using mul_le_mul_of_nonneg_left hscale
        (mul_nonneg (by linarith) hc)
    _ = ((D : ℝ)^(-β)*c)*((1-β)*((D : ℝ)+1)^β) := by ring
    _ ≤ ((D : ℝ)^(-β)*c)*(w*B) :=
      mul_le_mul_of_nonneg_left hb (mul_nonneg hDpow hc)
    _ = ((D : ℝ)^(-β)*w)*(c*B) := by ring
    _ ≤ ((D : ℝ)^(-β)*w)*I := mul_le_mul_of_nonneg_left hi (mul_nonneg hDpow hw)
    _ = _ := by ring

end NeuralGeneralization
