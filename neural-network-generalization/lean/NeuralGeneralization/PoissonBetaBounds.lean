import NeuralGeneralization.PoissonBetaChange

/-! Uniform comparisons between a Poissonized coordinate-walk integral
and an explicitly normalized beta integral. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

/-- A pointwise clock comparison on a bounded time interval. -/
theorem poisson_beta_integrand_bounds {j D : ℕ} {β a u : ℝ}
    (hβ0 : 0 ≤ β) (hu : 0 < u) (hua : u ≤ a) :
    Real.exp (-2*a*(1+β))*
      ((poissonFlipProbability u)^((j : ℝ)-β-1)*
        (1-poissonFlipProbability u)^(D-j)*Real.exp (-2*u)) ≤
      u^(-1-β)*(poissonFlipProbability u)^j*(1-poissonFlipProbability u)^(D-j) ∧
    u^(-1-β)*(poissonFlipProbability u)^j*(1-poissonFlipProbability u)^(D-j) ≤
      Real.exp (2*a)*
      ((poissonFlipProbability u)^((j : ℝ)-β-1)*
        (1-poissonFlipProbability u)^(D-j)*Real.exp (-2*u)) := by
  let p := poissonFlipProbability u
  have hp : 0 < p := poissonFlipProbability_pos hu
  have hq : 0 ≤ 1-p := by
    have hh := poissonFlipProbability_lt_half u
    dsimp [p]
    linarith
  have hpow : 0 ≤ p^j*(1-p)^(D-j) := by positivity
  have hz : -1-β ≤ 0 := by linarith
  have hlow : Real.exp (-2*a*(1+β))*p^(-1-β) ≤ u^(-1-β) := by
    have hb := poissonFlipProbability_lower hu.le hua
    have hupp : u ≤ Real.exp (2*a)*p := by
      have hh := mul_le_mul_of_nonneg_right hb (Real.exp_pos (2*a)).le
      have hcancel : Real.exp (-2*a)*Real.exp (2*a)=1 := by
        rw [← Real.exp_add,show -2*a+2*a=0 by ring,Real.exp_zero]
      calc
        u = (u*Real.exp (-2*a))*Real.exp (2*a) := by rw [mul_assoc,hcancel,mul_one]
        _ ≤ p*Real.exp (2*a) := hh
        _ = Real.exp (2*a)*p := mul_comm _ _
    have hh := Real.rpow_le_rpow_of_nonpos hu hupp hz
    rw [Real.mul_rpow (Real.exp_pos _).le hp.le,← Real.exp_mul] at hh
    have he : 2*a*(-1-β)= -2*a*(1+β) := by ring
    rwa [he] at hh
  have hupp : u^(-1-β) ≤ p^(-1-β) :=
    Real.rpow_le_rpow_of_nonpos hp (poissonFlipProbability_le_self hu.le) hz
  have hid : p^((j : ℝ)-β-1)*(1-p)^(D-j)=p^(-1-β)*(p^j*(1-p)^(D-j)) := by
    rw [← mul_assoc,← Real.rpow_natCast p j,← Real.rpow_add hp]
    congr 2
    ring
  have helo : Real.exp (-2*u) ≤ 1 := by rw [Real.exp_le_one_iff]; linarith
  have heup : 1 ≤ Real.exp (2*a)*Real.exp (-2*u) := by
    rw [← Real.exp_add,Real.one_le_exp_iff]
    linarith
  change Real.exp (-2*a*(1+β))*(p^((j : ℝ)-β-1)*(1-p)^(D-j)*Real.exp (-2*u)) ≤
    u^(-1-β)*p^j*(1-p)^(D-j) ∧ _
  rw [hid]
  constructor
  · calc
      _ ≤ Real.exp (-2*a*(1+β))*(p^(-1-β)*(p^j*(1-p)^(D-j))*1) := by
        gcongr
      _ ≤ u^(-1-β)*(p^j*(1-p)^(D-j)) := by
        simpa only [mul_one,mul_assoc] using mul_le_mul_of_nonneg_right hlow hpow
      _ = _ := by ring
  · change u^(-1-β)*p^j*(1-p)^(D-j) ≤
      Real.exp (2*a)*(p^(-1-β)*(p^j*(1-p)^(D-j))*Real.exp (-2*u))
    calc
      _ ≤ p^(-1-β)*(p^j*(1-p)^(D-j)) := by
        simpa only [mul_assoc] using mul_le_mul_of_nonneg_right hupp hpow
      _ ≤ (p^(-1-β)*(p^j*(1-p)^(D-j)))*(Real.exp (2*a)*Real.exp (-2*u)) := by
        simpa only [mul_one] using mul_le_mul_of_nonneg_left heup
          (mul_nonneg (Real.rpow_nonneg hp.le _) hpow)
      _ = _ := by ring


/-- Integrability and two-sided beta comparison on any finite time window. -/
theorem poisson_beta_finite_bounds {D j : ℕ} (hj : 1 ≤ j)
    {β a : ℝ} (hβ0 : 0 < β) (hβ1 : β < 1) (ha : 0 < a) :
    IntegrableOn (fun u : ℝ => u^(-1-β)*(poissonFlipProbability u)^j*
      (1-poissonFlipProbability u)^(D-j)) (Ioo 0 a) ∧
    Real.exp (-2*a*(1+β))*(∫ p : ℝ in Ioo 0 (poissonFlipProbability a),
      p^((j : ℝ)-β-1)*(1-p)^(D-j)) ≤
      (∫ u : ℝ in Ioo 0 a,u^(-1-β)*(poissonFlipProbability u)^j*
        (1-poissonFlipProbability u)^(D-j)) ∧
    (∫ u : ℝ in Ioo 0 a,u^(-1-β)*(poissonFlipProbability u)^j*
      (1-poissonFlipProbability u)^(D-j)) ≤
      Real.exp (2*a)*(∫ p : ℝ in Ioo 0 (poissonFlipProbability a),
        p^((j : ℝ)-β-1)*(1-p)^(D-j)) := by
  let g : ℝ → ℝ := fun p => p^((j : ℝ)-β-1)*(1-p)^(D-j)
  let H : ℝ → ℝ := fun u => g (poissonFlipProbability u)*Real.exp (-2*u)
  let F : ℝ → ℝ := fun u => u^(-1-β)*(poissonFlipProbability u)^j*
    (1-poissonFlipProbability u)^(D-j)
  have hjR : (1 : ℝ) ≤ j := by exact_mod_cast hj
  have hgfull : IntegrableOn g (Ioo 0 1) := by
    have h := real_beta_integrable (by linarith : 0 < (j : ℝ)-β)
      (by positivity : 0 < ((D-j : ℕ) : ℝ)+1)
    simpa only [add_sub_cancel_right,Real.rpow_natCast] using h
  have hg : IntegrableOn g (Ioo 0 (poissonFlipProbability a)) := hgfull.mono_set (by
    intro p hp
    exact ⟨hp.1,hp.2.trans ((poissonFlipProbability_lt_half a).trans (by norm_num))⟩)
  have hH : IntegrableOn H (Ioo 0 a) := (poisson_beta_integrable_iff a ha.le g).mpr hg
  have hFmeas : AEStronglyMeasurable F (volume.restrict (Ioo 0 a)) := by
    apply Measurable.aestronglyMeasurable
    dsimp [F,poissonFlipProbability]
    fun_prop
  have hF : IntegrableOn F (Ioo 0 a) := by
    apply (hH.const_mul (Real.exp (2*a))).mono' hFmeas
    filter_upwards [ae_restrict_mem measurableSet_Ioo] with u hu
    have hp := (poissonFlipProbability_pos hu.1).le
    have hq : 0 ≤ 1-poissonFlipProbability u := by
      linarith [poissonFlipProbability_lt_half u]
    have hu0 : 0 ≤ u := hu.1.le
    have hF0 : 0 ≤ F u := by dsimp [F]; positivity
    rw [Real.norm_eq_abs,abs_of_nonneg hF0]
    exact (poisson_beta_integrand_bounds (D := D) (j := j) hβ0.le hu.1 hu.2.le).2
  refine ⟨hF,?_,?_⟩
  · have h := setIntegral_mono_on (hH.const_mul (Real.exp (-2*a*(1+β)))) hF
      measurableSet_Ioo (fun u hu =>
        (poisson_beta_integrand_bounds (D := D) (j := j) hβ0.le hu.1 hu.2.le).1)
    rw [integral_const_mul,show (∫ u in Ioo 0 a,H u)=(∫ p in Ioo 0 (poissonFlipProbability a),g p)
      from poisson_beta_change a ha.le g] at h
    exact h
  · have h := setIntegral_mono_on hF (hH.const_mul (Real.exp (2*a)))
      measurableSet_Ioo (fun u hu =>
        (poisson_beta_integrand_bounds (D := D) (j := j) hβ0.le hu.1 hu.2.le).2)
    rw [integral_const_mul,show (∫ u in Ioo 0 a,H u)=(∫ p in Ioo 0 (poissonFlipProbability a),g p)
      from poisson_beta_change a ha.le g] at h
    exact h

end NeuralGeneralization
