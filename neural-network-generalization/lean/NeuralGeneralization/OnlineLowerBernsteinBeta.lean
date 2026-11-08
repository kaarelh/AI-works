import NeuralGeneralization.OnlineLowerExpSubstitution
import Mathlib.Analysis.SpecialFunctions.Gamma.Beta

noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerBernstein

private theorem beta_integrand_ofReal (a b x : ℝ) (hx : x ∈ Ioo (0:ℝ) 1) :
    ((x^(a-1)*(1-x)^(b-1):ℝ):ℂ) =
      (x:ℂ)^((a:ℂ)-1)*(1-(x:ℂ))^((b:ℂ)-1) := by
  rw [Complex.ofReal_mul,Complex.ofReal_cpow hx.1.le,
    Complex.ofReal_cpow (sub_nonneg.mpr hx.2.le)]
  push_cast
  rfl

theorem integrable_real_beta {a b : ℝ} (ha : 0<a) (hb : 0<b) :
    IntegrableOn (fun x:ℝ => x^(a-1)*(1-x)^(b-1)) (Ioo 0 1) := by
  have hc := Complex.betaIntegral_convergent (u := (a:ℂ)) (v := (b:ℂ))
    (by simpa using ha) (by simpa using hb)
  rw [intervalIntegrable_iff_integrableOn_Ioo_of_le (by norm_num)] at hc
  apply hc.re.congr
  filter_upwards [ae_restrict_mem measurableSet_Ioo] with x hx
  exact (congrArg Complex.re (beta_integrand_ofReal a b x hx)).symm

theorem integral_real_beta {a b : ℝ} (ha : 0<a) (hb : 0<b) :
    (∫ x in Ioo (0:ℝ) 1,x^(a-1)*(1-x)^(b-1)) =
      Real.Gamma a*Real.Gamma b/Real.Gamma (a+b) := by
  apply Complex.ofReal_injective
  rw [←integral_complex_ofReal]
  calc
    _ = Complex.betaIntegral a b := by
      rw [Complex.betaIntegral,intervalIntegral.integral_of_le (by norm_num),
        integral_Ioc_eq_integral_Ioo]
      exact setIntegral_congr_fun measurableSet_Ioo (fun x hx => beta_integrand_ofReal a b x hx)
    _ = _ := by
      rw [Complex.betaIntegral_eq_Gamma_mul_div _ _ (by simpa using ha) (by simpa using hb),
        ←Complex.ofReal_add,Complex.Gamma_ofReal,Complex.Gamma_ofReal,Complex.Gamma_ofReal]
      push_cast
      rfl

/-- The kernel in the convolution representation of the ReLU Bernstein density. -/
def betaLaplaceKernel (t : ℝ) : ℝ := (1-Real.exp (-t))^(-(1/2:ℝ))

private theorem beta_substitution_integrand (z t : ℝ) :
    Real.exp (-t)*((Real.exp (-t))^(z-1)*(1-Real.exp (-t))^((1/2:ℝ)-1)) =
      Real.exp (-z*t)*betaLaplaceKernel t := by
  rw [Real.rpow_def_of_pos (Real.exp_pos _),Real.log_exp]
  rw [←mul_assoc,←Real.exp_add]
  simp only [betaLaplaceKernel]
  congr 2 <;> ring

theorem integrable_betaLaplace {z : ℝ} (hz : 0<z) :
    IntegrableOn (fun t => Real.exp (-z*t)*betaLaplaceKernel t) (Ioi 0) := by
  have h := (integrable_expNeg_substitution
    (fun x:ℝ => x^(z-1)*(1-x)^((1/2:ℝ)-1))).mp
      (integrable_real_beta hz (by norm_num))
  simpa only [beta_substitution_integrand] using h

theorem laplace_beta_kernel {z : ℝ} (hz : 0<z) :
    (∫ t in Ioi (0:ℝ),Real.exp (-z*t)*betaLaplaceKernel t) =
      Real.Gamma z*Real.Gamma (1/2)/Real.Gamma (z+1/2) := by
  rw [←integral_real_beta hz (by norm_num : (0:ℝ)<1/2),
    integral_expNeg_substitution]
  simp only [beta_substitution_integrand]

end NeuralGeneralization.OnlineLowerBernstein
