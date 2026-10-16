import NeuralGeneralization.BetaReference

/-! Integrability, exact first moment, and a uniform lower bound for a
truncated beta integral. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

/-- The real beta integrand is integrable at both singular endpoints. -/
theorem real_beta_integrable {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    IntegrableOn (fun p : ℝ => p^(a-1)*(1-p)^(b-1)) (Ioo 0 1) := by
  have h := (intervalIntegrable_iff_integrableOn_Ioo_of_le
    (by norm_num : (0 : ℝ) ≤ 1)).mp
    (Complex.betaIntegral_convergent (u := (a : ℂ)) (v := (b : ℂ))
      (by simpa) (by simpa))
  have hr : IntegrableOn (fun p : ℝ => Complex.re ((p : ℂ)^((a : ℂ)-1)*
      (1-(p : ℂ))^((b : ℂ)-1))) (Ioo 0 1) := h.re
  apply hr.congr_fun _ measurableSet_Ioo
  intro p hp
  have he : (p : ℂ)^((a : ℂ)-1)*(1-(p : ℂ))^((b : ℂ)-1) =
      ((p^(a-1)*(1-p)^(b-1) : ℝ) : ℂ) := by
    rw [show (a : ℂ)-1=((a-1 : ℝ) : ℂ) by push_cast; rfl,
      show (b : ℂ)-1=((b-1 : ℝ) : ℂ) by push_cast; rfl,
      show (1 : ℂ)-(p : ℂ)=((1-p : ℝ) : ℂ) by push_cast; rfl,
      Complex.ofReal_mul,Complex.ofReal_cpow hp.1.le,Complex.ofReal_cpow (show 0 ≤ 1-p by linarith [hp.2])]
  change Complex.re _ = _
  rw [he,Complex.ofReal_re]

/-- Multiplication by the coordinate shifts the first beta parameter. -/
theorem real_beta_firstMoment {a b : ℝ} (ha : 0 < a) (hb : 0 < b) :
    (∫ p : ℝ in Ioo 0 1,p*(p^(a-1)*(1-p)^(b-1))) =
      (a/(a+b))*(∫ p : ℝ in Ioo 0 1,p^(a-1)*(1-p)^(b-1)) := by
  have he : ∀ p ∈ Ioo (0 : ℝ) 1,
      p*(p^(a-1)*(1-p)^(b-1))=p^((a+1)-1)*(1-p)^(b-1) := by
    intro p hp
    rw [add_sub_cancel_right]
    calc
      _ = (p^(1 : ℝ)*p^(a-1))*(1-p)^(b-1) := by rw [Real.rpow_one]; ring
      _ = _ := by rw [← Real.rpow_add hp.1]; congr 2; ring
  rw [setIntegral_congr_fun measurableSet_Ioo he,
    real_beta_integral (by linarith : 0 < a+1) hb,real_beta_integral ha hb]
  rw [Real.Gamma_add_one (ne_of_gt ha),show a+1+b=(a+b)+1 by ring,
    Real.Gamma_add_one (ne_of_gt (add_pos ha hb))]
  simp only [mul_div_mul_comm,div_mul_eq_mul_div]
  ring

/-- Markov's first-moment estimate leaves a definite fraction of the beta
mass below any cutoff above its mean. -/
theorem real_beta_truncated_lower {a b c : ℝ} (ha : 0 < a) (hb : 0 < b)
    (hc0 : 0 < c) (hc1 : c < 1) :
    (1-a/((a+b)*c))*(∫ p : ℝ in Ioo 0 1,p^(a-1)*(1-p)^(b-1)) ≤
      ∫ p : ℝ in Ioo 0 c,p^(a-1)*(1-p)^(b-1) := by
  let f : ℝ → ℝ := fun p => p^(a-1)*(1-p)^(b-1)
  have hf : IntegrableOn f (Ioo 0 1) := real_beta_integrable ha hb
  have hpg : IntegrableOn (fun p => p*f p) (Ioo 0 1) := by
    apply (real_beta_integrable (by linarith : 0 < a+1) hb).congr_fun _ measurableSet_Ioo
    intro p hp
    dsimp [f]
    rw [add_sub_cancel_right]
    calc
      _ = (p^(1 : ℝ)*p^(a-1))*(1-p)^(b-1) := by rw [← Real.rpow_add hp.1]; congr 2; ring
      _ = _ := by rw [Real.rpow_one]; ring
  have hfind : IntegrableOn ((Ioo 0 c).indicator f) (Ioo 0 1) :=
    hf.indicator measurableSet_Ioo
  have hpoint : ∀ p ∈ Ioo (0 : ℝ) 1,
      c*f p ≤ p*f p+c*(Ioo 0 c).indicator f p := by
    intro p hp
    have hf0 : 0 ≤ f p := mul_nonneg (Real.rpow_nonneg hp.1.le _) (Real.rpow_nonneg (by linarith [hp.2]) _)
    by_cases hpc : p < c
    · rw [indicator_of_mem (show p ∈ Ioo 0 c from ⟨hp.1,hpc⟩)]
      nlinarith [mul_nonneg hp.1.le hf0]
    · rw [indicator_of_notMem (show p ∉ Ioo 0 c by intro h; exact hpc h.2)]
      nlinarith [mul_nonneg (sub_nonneg.mpr (le_of_not_gt hpc)) hf0]
  have hi := setIntegral_mono_on (hf.const_mul c) (hpg.add (hfind.const_mul c))
    measurableSet_Ioo hpoint
  change (∫ p in Ioo 0 1,c*f p) ≤ (∫ p in Ioo 0 1,p*f p+c*(Ioo 0 c).indicator f p) at hi
  rw [integral_const_mul,integral_add hpg (hfind.const_mul c),integral_const_mul,
    setIntegral_indicator measurableSet_Ioo] at hi
  have hinter : Ioo (0 : ℝ) 1 ∩ Ioo 0 c = Ioo 0 c := by
    ext p
    simp only [mem_inter_iff,mem_Ioo]
    constructor
    · tauto
    · intro hp
      exact ⟨⟨hp.1,hp.2.trans hc1⟩,hp⟩
  rw [hinter] at hi
  change c*(∫ p in Ioo 0 1,f p) ≤ (∫ p in Ioo 0 1,p*f p)+c*(∫ p in Ioo 0 c,f p) at hi
  rw [show (∫ p in Ioo 0 1,p*f p)=(a/(a+b))*(∫ p in Ioo 0 1,f p) from
    real_beta_firstMoment ha hb] at hi
  change (1-a/((a+b)*c))*(∫ p in Ioo 0 1,f p) ≤ (∫ p in Ioo 0 c,f p)
  apply (mul_le_mul_iff_right₀ hc0).mp
  have he : c*(1-a/((a+b)*c))=c-a/(a+b) := by field_simp
  rw [← mul_assoc,he]
  linarith

end NeuralGeneralization
