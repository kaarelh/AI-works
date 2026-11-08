import NeuralGeneralization.OnlineLowerBernsteinBeta
import Mathlib.Probability.Distributions.Beta

noncomputable section
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.OnlineLowerBernstein

def arcsineMeasure : Measure ℝ := betaMeasure (1/2) (1/2)

instance : IsProbabilityMeasure arcsineMeasure :=
  isProbabilityMeasureBeta (by norm_num) (by norm_num)

theorem arcsine_ae_mem : ∀ᵐ u ∂arcsineMeasure, 0<u ∧ u<1 := by
  unfold arcsineMeasure betaMeasure
  apply (ae_withDensity_iff (by unfold betaPDF; fun_prop)).mpr
  filter_upwards [] with x hx
  by_contra hh
  simp [betaPDF,betaPDFReal,hh] at hx

theorem arcsine_integrable_id : Integrable (fun u:ℝ => u) arcsineMeasure := by
  apply (integrable_const (1:ℝ)).mono' measurable_id.aestronglyMeasurable
  filter_upwards [arcsine_ae_mem] with u hu
  simpa [Real.norm_eq_abs,abs_of_pos hu.1] using hu.2.le

theorem arcsine_mean : (∫ u,u ∂arcsineMeasure) = 1/2 := by
  unfold arcsineMeasure betaMeasure
  rw [integral_withDensity_eq_integral_toReal_smul
    (by unfold betaPDF; fun_prop) (by filter_upwards [] with x; exact ENNReal.ofReal_lt_top) ]
  have he : (fun x:ℝ => (betaPDF (1/2) (1/2) x).toReal • x) =
      (Ioo (0:ℝ) 1).indicator
        (fun x => (1 / beta (1/2) (1/2)) * (x^((3/2:ℝ)-1)*(1-x)^((1/2:ℝ)-1))) := by
    funext x
    by_cases hx : x∈Ioo (0:ℝ) 1
    · rw [Set.indicator_of_mem hx]
      change 0<x ∧ x<1 at hx
      simp only [betaPDF,betaPDFReal,if_pos hx]
      have hbeta : 0 < beta (1/2) (1/2) := beta_pos (by norm_num) (by norm_num)
      rw [ENNReal.toReal_ofReal (mul_nonneg
        (mul_nonneg (one_div_nonneg.mpr hbeta.le) (Real.rpow_nonneg hx.1.le _))
        (Real.rpow_nonneg (sub_nonneg.mpr hx.2.le) _))]
      simp only [smul_eq_mul]
      have hp : x^((3/2:ℝ)-1) = x*x^((1/2:ℝ)-1) := by
        rw [show (3/2:ℝ)-1=1+((1/2:ℝ)-1) by ring,Real.rpow_add hx.1,Real.rpow_one]
      rw [hp]
      ring
    · rw [Set.indicator_of_notMem hx]
      change ¬(0<x ∧ x<1) at hx
      simp [betaPDF,betaPDFReal,hx]
  rw [he,integral_indicator measurableSet_Ioo,integral_const_mul,
    integral_real_beta (by norm_num : (0:ℝ)<3/2) (by norm_num : (0:ℝ)<1/2)]
  have gh := Real.Gamma_add_one (s := (1/2:ℝ)) (by norm_num)
  have gn : Real.Gamma (1/2) ≠ 0 := (Real.Gamma_pos_of_pos (by norm_num)).ne'
  norm_num [beta] at gh ⊢
  rw [show (3/2:ℝ)=1/2+1 by ring,Real.Gamma_add_one (by norm_num)]
  field_simp

end NeuralGeneralization.OnlineLowerBernstein
