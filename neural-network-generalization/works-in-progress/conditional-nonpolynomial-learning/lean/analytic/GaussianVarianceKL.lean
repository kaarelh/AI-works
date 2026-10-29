import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Positivity

open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal

namespace ConditionalNonpolynomial.Analytic

lemma gaussian_variance_ac (v : ℝ≥0) (hv : v ≠ 0) :
    gaussianReal 0 v ≪ gaussianReal 0 1 :=
  (gaussianReal_absolutelyContinuous 0 hv).trans
    (gaussianReal_absolutelyContinuous' 0 (by norm_num))

lemma log_gaussianPDFReal_zero (v : ℝ≥0) (hv : v ≠ 0) (x : ℝ) :
    Real.log (gaussianPDFReal 0 v x) =
      -(Real.log (2 * Real.pi) + Real.log (v : ℝ)) / 2 - x^2 / (2*v) := by
  have hvp : 0 < (v : ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  rw [gaussianPDFReal, Real.log_mul (by positivity) (Real.exp_ne_zero _),
    Real.log_inv, Real.log_sqrt (by positivity),
    Real.log_mul (by positivity) (ne_of_gt hvp), Real.log_exp]
  simp only [sub_zero]
  ring

lemma gaussian_variance_llr (v : ℝ≥0) (hv : v ≠ 0) :
    llr (gaussianReal 0 v) (gaussianReal 0 1) =ᵐ[gaussianReal 0 v]
      fun x : ℝ => -(Real.log (v : ℝ))/2 + (1-(v:ℝ)⁻¹)/2*x^2 := by
  have ha := gaussian_variance_ac v hv
  have hvv := gaussianReal_absolutelyContinuous 0 hv
  have hratio := Measure.rnDeriv_eq_div hvv
    (gaussianReal_absolutelyContinuous 0 (v := 1) (by norm_num))
  filter_upwards [ha hratio, hvv (rnDeriv_gaussianReal 0 v),
    hvv (rnDeriv_gaussianReal 0 1)] with x hx hvx h1x
  rw [llr, hx, hvx, h1x, ENNReal.toReal_div, toReal_gaussianPDF,
    toReal_gaussianPDF, Real.log_div (ne_of_gt (gaussianPDFReal_pos 0 v x hv))
      (ne_of_gt (gaussianPDFReal_pos 0 1 x (by norm_num))),
    log_gaussianPDFReal_zero v hv, log_gaussianPDFReal_zero 1 (by norm_num)]
  simp only [NNReal.coe_one, Real.log_one]
  ring

lemma gaussian_variance_llr_integrable (v : ℝ≥0) (hv : v ≠ 0) :
    Integrable (llr (gaussianReal 0 v) (gaussianReal 0 1)) (gaussianReal 0 v) := by
  apply Integrable.congr _ (gaussian_variance_llr v hv).symm
  exact (integrable_const _).add
    ((memLp_id_gaussianReal (μ := 0) (v := v) 2).integrable_sq.const_mul _)

lemma gaussian_centered_second_moment (v : ℝ≥0) :
    ∫ x : ℝ, x^2 ∂gaussianReal 0 v = (v:ℝ) := by
  have h := variance_fun_id_gaussianReal (μ := 0) (v := v)
  rw [variance_eq_integral (X := fun x : ℝ => x) measurable_id.aemeasurable] at h
  simpa only [integral_id_gaussianReal, sub_zero] using h

lemma gaussian_variance_kl_ne_top (v : ℝ≥0) (hv : v ≠ 0) :
    klDiv (gaussianReal 0 v) (gaussianReal 0 1) ≠ ∞ :=
  klDiv_ne_top (gaussian_variance_ac v hv) (gaussian_variance_llr_integrable v hv)

lemma gaussian_variance_kl_toReal (v : ℝ≥0) (hv : v ≠ 0) :
    (klDiv (gaussianReal 0 v) (gaussianReal 0 1)).toReal =
      ((v:ℝ)-1-Real.log (v:ℝ))/2 := by
  rw [toReal_klDiv (gaussian_variance_ac v hv) (gaussian_variance_llr_integrable v hv)]
  have hsq : Integrable (fun x : ℝ => x^2) (gaussianReal 0 v) :=
    (memLp_id_gaussianReal (μ := 0) (v := v) 2).integrable_sq
  rw [integral_congr_ae (gaussian_variance_llr v hv), integral_add
    (integrable_const _) (hsq.const_mul _),
    integral_const, integral_const_mul, gaussian_centered_second_moment]
  simp only [probReal_univ, smul_eq_mul, one_mul]
  have hvreal : (v:ℝ) ≠ 0 := by exact_mod_cast hv
  field_simp
  ring

/-- Equality in the extended-nonnegative codomain of Mathlib's relative entropy. -/
lemma gaussian_variance_kl_eq (v : ℝ≥0) (hv : v ≠ 0) :
    klDiv (gaussianReal 0 v) (gaussianReal 0 1) =
      ENNReal.ofReal (((v:ℝ)-1-Real.log (v:ℝ))/2) := by
  rw [← gaussian_variance_kl_toReal v hv,
    ENNReal.ofReal_toReal (gaussian_variance_kl_ne_top v hv)]

/-- A second-order bound valid on the entire variance-inflation half-line. -/
lemma variance_entropy_quadratic (v : ℝ) (hv : 1 ≤ v) :
    (v-1-Real.log v)/2 ≤ (v-1)^2/4 := by
  have ht : 0 ≤ v-1 := by linarith
  have hlog := Real.le_log_one_add_of_nonneg ht
  have hden : 0 < v-1+2 := by linarith
  have hc : 0 ≤ (v-1)^3 := pow_nonneg ht 3
  have haux : (v-1) - (v-1)^2/2 ≤ 2*(v-1)/(v-1+2) := by
    apply (le_div_iff₀ hden).mpr
    nlinarith
  have h := haux.trans hlog
  simp only [add_sub_cancel] at h
  nlinarith

lemma gaussian_variance_kl_quadratic (v : ℝ≥0) (hv : 1 ≤ v) :
    (klDiv (gaussianReal 0 v) (gaussianReal 0 1)).toReal ≤ ((v:ℝ)-1)^2/4 := by
  rw [gaussian_variance_kl_toReal v (ne_of_gt (lt_of_lt_of_le (by norm_num) hv))]
  exact variance_entropy_quadratic v (by exact_mod_cast hv)

lemma gaussian_inflation_kl_ne_top (q : ℝ) (hq : 0 ≤ q) :
    klDiv (gaussianReal 0 (Real.toNNReal (1+256*q))) (gaussianReal 0 1) ≠ ∞ := by
  apply gaussian_variance_kl_ne_top
  exact ne_of_gt (Real.toNNReal_pos.mpr (by positivity))

lemma gaussian_inflation_kl_quadratic (q : ℝ) (hq : 0 ≤ q) :
    (klDiv (gaussianReal 0 (Real.toNNReal (1+256*q))) (gaussianReal 0 1)).toReal
      ≤ 16384*q^2 := by
  have hv : (1 : ℝ≥0) ≤ Real.toNNReal (1+256*q) := by
    exact_mod_cast (show (1:ℝ) ≤ (Real.toNNReal (1+256*q):ℝ) by
      rw [Real.coe_toNNReal _ (by positivity)]; linarith)
  have h := gaussian_variance_kl_quadratic _ hv
  rw [Real.coe_toNNReal _ (by positivity)] at h
  nlinarith

end ConditionalNonpolynomial.Analytic
