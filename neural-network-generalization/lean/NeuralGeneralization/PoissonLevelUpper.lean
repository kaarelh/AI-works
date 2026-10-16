import NeuralGeneralization.PoissonLevelLower
import NeuralGeneralization.BernsteinTail

/-! Upper sharp-level bounds from the complete beta mass. The infinite
clock tail is controlled by a finite interval above the binomial mode. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

/-- The entire Poisson reference integral is bounded by its complete beta
integral, uniformly when the degree stays below the clock cutoff. -/
theorem poisson_level_beta_upper {D j : ℕ} (hj : 1 ≤ j) (hjD : j < D)
    {β ρ a : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1) (hρ0 : 0 < ρ) (ha : 0 < a)
    (hρp : ρ < poissonFlipProbability a) (hjρ : (j : ℝ) ≤ D*ρ) :
    (∫ u : ℝ in Ioi 0,u^(-1-β)*(poissonFlipProbability u)^j*
      (1-poissonFlipProbability u)^(D-j)) ≤
      (Real.exp (2*a)+a^(-β)/(β*(poissonFlipProbability a-ρ)))*
        (∫ p : ℝ in Ioo 0 1,p^((j : ℝ)-β-1)*(1-p)^(D-j)) := by
  let F : ℝ → ℝ := fun u => u^(-1-β)*(poissonFlipProbability u)^j*
    (1-poissonFlipProbability u)^(D-j)
  let g : ℝ → ℝ := fun p => p^((j : ℝ)-β-1)*(1-p)^(D-j)
  let B := ∫ p : ℝ in Ioo 0 1,g p
  let b := poissonFlipProbability a
  let H := b^j*(1-b)^(D-j)
  have hb0 : 0 < b := poissonFlipProbability_pos ha
  have hb1 : b < 1 := (poissonFlipProbability_lt_half a).trans (by norm_num)
  have hjR : (1 : ℝ) ≤ j := by exact_mod_cast hj
  have hg : IntegrableOn g (Ioo 0 1) := by
    simpa only [add_sub_cancel_right,Real.rpow_natCast] using
      real_beta_integrable (by linarith : 0 < (j : ℝ)-β)
        (by positivity : 0 < ((D-j : ℕ) : ℝ)+1)
  have hF := poisson_level_integrable (D := D) hj hβ0 hβ1
  have hFtail : IntegrableOn F (Ioi a) := hF.mono_set (fun _ hu => ha.trans hu)
  have hBsmall : (∫ p : ℝ in Ioo 0 b,g p) ≤ B := by
    apply setIntegral_mono_set hg _ (Filter.Eventually.of_forall (fun _ hp => ⟨hp.1,hp.2.trans hb1⟩))
    filter_upwards [ae_restrict_mem measurableSet_Ioo] with p hp
    exact mul_nonneg (Real.rpow_nonneg hp.1.le _) (pow_nonneg (by linarith [hp.2]) _)
  have hfinite : (∫ u : ℝ in Ioo 0 a,F u) ≤ Real.exp (2*a)*B :=
    (poisson_beta_finite_bounds (D := D) hj hβ0 hβ1 ha).2.2.trans
      (mul_le_mul_of_nonneg_left hBsmall (Real.exp_pos _).le)
  have hmono := binomial_monomial_antitone hj hjD hρ0.le hjρ
  have htailpoint (u : ℝ) (hu : u ∈ Ioi a) : F u ≤ u^(-1-β)*H := by
    have hu0 : 0 ≤ u := (ha.trans hu).le
    have hp := poissonFlipProbability_nonneg hu0
    have hua : a < u := hu
    have hpb : b ≤ poissonFlipProbability u := by
      unfold b poissonFlipProbability
      have he : Real.exp (-2*u) ≤ Real.exp (-2*a) := Real.exp_le_exp.mpr (by linarith [hua])
      linarith
    have hp1 : poissonFlipProbability u ≤ 1 := (poissonFlipProbability_lt_half u).le.trans (by norm_num)
    have hh := hmono ⟨hρp.le,hb1.le⟩ ⟨hρp.le.trans hpb,hp1⟩ hpb
    dsimp [F,H]
    simpa only [mul_assoc] using mul_le_mul_of_nonneg_left hh (Real.rpow_nonneg hu0 (-1-β))
  have htail : (∫ u : ℝ in Ioi a,F u) ≤ (a^(-β)/β)*H := by
    have hint := (integrableOn_Ioi_rpow_of_lt (by linarith : -1-β < -1) ha).mul_const H
    have hh := setIntegral_mono_on hFtail hint measurableSet_Ioi htailpoint
    rw [integral_mul_const,integral_Ioi_rpow_of_lt (by linarith : -1-β < -1) ha] at hh
    have he : -1-β+1 = -β := by ring
    rw [he,neg_div_neg_eq] at hh
    exact hh
  have hH : (b-ρ)*H ≤ B :=
    binomial_monomial_le_beta hj hjD hβ0 hβ1 hρ0 hρp hb1 hjρ
  have hgap : 0 < b-ρ := sub_pos.mpr hρp
  have hH' : H ≤ B/(b-ρ) := (le_div_iff₀ hgap).mpr (by simpa only [mul_comm] using hH)
  have htail' : (∫ u : ℝ in Ioi a,F u) ≤ a^(-β)/(β*(b-ρ))*B := by
    apply htail.trans
    have hh := mul_le_mul_of_nonneg_left hH' (by positivity : 0 ≤ a^(-β)/β)
    convert hh using 1 <;> field_simp <;> ring
  have hsplit := intervalIntegral.integral_interval_add_Ioi hF hFtail
  rw [intervalIntegral.integral_of_le ha.le,integral_Ioc_eq_integral_Ioo] at hsplit
  change (∫ u in Ioi 0,F u) ≤ (Real.exp (2*a)+a^(-β)/(β*(b-ρ)))*B
  rw [← hsplit]
  linarith


/-- Sharp normalized reference-level upper bound. -/
theorem poisson_level_normalized_upper {D j : ℕ} (hj : 1 ≤ j) (hjD : j < D)
    {β ρ a : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1) (hρ0 : 0 < ρ) (ha : 0 < a)
    (hρp : ρ < poissonFlipProbability a) (hjρ : (j : ℝ) ≤ D*ρ) :
    (j : ℝ)^(1+β)*(D.choose j : ℝ)*((D : ℝ)^(-β)*
      (∫ u : ℝ in Ioi 0,u^(-1-β)*(poissonFlipProbability u)^j*
        (1-poissonFlipProbability u)^(D-j))) ≤
      2*(Real.exp (2*a)+a^(-β)/(β*(poissonFlipProbability a-ρ)))/(1-β) := by
  let C := Real.exp (2*a)+a^(-β)/(β*(poissonFlipProbability a-ρ))
  let B := ∫ p : ℝ in Ioo 0 1,p^((j : ℝ)-β-1)*(1-p)^(D-j)
  let I := ∫ u : ℝ in Ioi 0,u^(-1-β)*(poissonFlipProbability u)^j*
    (1-poissonFlipProbability u)^(D-j)
  let w := (j : ℝ)^(1+β)*(D.choose j : ℝ)
  have hC : 0 ≤ C := by dsimp [C]; positivity
  have hw : 0 ≤ w := by dsimp [w]; positivity
  have hD1 : (1 : ℝ) ≤ D := by exact_mod_cast (hj.trans hjD.le)
  have hD : 0 < (D : ℝ) := by linarith
  have hDpow : 0 ≤ (D : ℝ)^(-β) := Real.rpow_nonneg hD.le _
  have hi : I ≤ C*B := poisson_level_beta_upper hj hjD hβ0 hβ1 hρ0 ha hρp hjρ
  have hb : w*B ≤ ((D : ℝ)+1)^β/(1-β) := by
    simpa only [Real.rpow_natCast] using (binomial_beta_reference_bounds hj hjD.le hβ0 hβ1).2
  have hscale : (D : ℝ)^(-β)*((D : ℝ)+1)^β ≤ 2 := by
    have hh := Real.rpow_le_rpow (show 0 ≤ (D : ℝ)+1 by positivity)
      (show (D : ℝ)+1 ≤ 2*D by linarith) hβ0.le
    have hm := mul_le_mul_of_nonneg_left hh hDpow
    rw [Real.mul_rpow (by norm_num : (0 : ℝ) ≤ 2) hD.le] at hm
    have he : (D : ℝ)^(-β)*((2 : ℝ)^β*(D : ℝ)^β)=(2 : ℝ)^β := by
      rw [mul_left_comm,← Real.rpow_add hD,neg_add_cancel,Real.rpow_zero,mul_one]
    rw [he] at hm
    apply hm.trans
    simpa only [Real.rpow_one] using Real.rpow_le_rpow_of_exponent_le
      (by norm_num : (1 : ℝ) ≤ 2) hβ1.le
  change w*((D : ℝ)^(-β)*I) ≤ 2*C/(1-β)
  calc
    _ = ((D : ℝ)^(-β)*w)*I := by ring
    _ ≤ ((D : ℝ)^(-β)*w)*(C*B) := mul_le_mul_of_nonneg_left hi (mul_nonneg hDpow hw)
    _ = ((D : ℝ)^(-β)*C)*(w*B) := by ring
    _ ≤ ((D : ℝ)^(-β)*C)*(((D : ℝ)+1)^β/(1-β)) :=
      mul_le_mul_of_nonneg_left hb (mul_nonneg hDpow hC)
    _ = (C/(1-β))*((D : ℝ)^(-β)*((D : ℝ)+1)^β) := by ring
    _ ≤ (C/(1-β))*2 := mul_le_mul_of_nonneg_left hscale (div_nonneg hC (by linarith))
    _ = _ := by ring

end NeuralGeneralization
