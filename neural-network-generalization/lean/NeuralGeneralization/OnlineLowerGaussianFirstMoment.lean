import NeuralGeneralization.OnlineLowerGaussianOscillation
import Mathlib.Analysis.Calculus.ParametricIntegral

/-! The first oscillatory Gaussian moment, including its uniform-frequency decay. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped Topology
open MeasureTheory Filter
namespace NeuralGeneralization.OnlineLowerTanh

lemma gaussian_first_majorant_integrable :
    Integrable (fun x:ℝ=>|x| *Real.exp (-x^2/2)) := by
  have h:Integrable (fun x:ℝ=>x*Real.exp (-(1/2:ℝ)*x^2)) :=
    integrable_mul_exp_neg_mul_sq (by norm_num)
  convert! h.norm using 1
  funext x
  rw [Real.norm_eq_abs,abs_mul,Real.abs_exp]
  congr 2
  ring

lemma gaussian_cosine_integral_derivative (s θ:ℝ) :
    Integrable (fun x:ℝ=>Real.exp (-x^2/2)*(-Real.sin (s*x+θ)*x)) ∧
    HasDerivAt (fun t:ℝ=>∫x:ℝ,Real.exp (-x^2/2)*Real.cos (t*x+θ))
      (∫x:ℝ,Real.exp (-x^2/2)*(-Real.sin (s*x+θ)*x)) s := by
  refine hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (F:=fun t x:ℝ=>Real.exp (-x^2/2)*Real.cos (t*x+θ))
    (F':=fun t x:ℝ=>Real.exp (-x^2/2)*(-Real.sin (t*x+θ)*x))
    (x₀:=s) (μ:=volume) (s:=Set.univ) (bound:=fun x:ℝ=>|x| *Real.exp (-x^2/2)) (by simp) ?_ ?_ ?_ ?_ ?_ ?_
  · exact Eventually.of_forall (fun t=>(gaussian_cosine_integrable t θ).aestronglyMeasurable)
  · exact gaussian_cosine_integrable s θ
  · fun_prop
  · filter_upwards [] with x t ht
    rw [Real.norm_eq_abs,abs_mul,Real.abs_exp,abs_mul,abs_neg]
    calc
      _ ≤ Real.exp (-x^2/2)*(1*|x|) :=
        mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_right (Real.abs_sin_le_one _) (abs_nonneg x)) (Real.exp_pos _).le
      _ = _ := by ring
  · exact gaussian_first_majorant_integrable
  · filter_upwards [] with x t ht
    convert! (((Real.hasDerivAt_cos (t*x+θ)).comp t
      (((hasDerivAt_id t).mul_const x).add_const θ)).const_mul (Real.exp (-x^2/2))) using 1 <;> simp

lemma gaussian_first_sine_integrable (s θ:ℝ) :
    Integrable (fun x:ℝ=>x*Real.exp (-x^2/2)*Real.sin (s*x+θ)) := by
  have h:=(gaussian_cosine_integral_derivative s θ).1.neg
  convert h using 1
  funext x
  change x*Real.exp (-x^2/2)*Real.sin (s*x+θ)=
    -(Real.exp (-x^2/2)*(-Real.sin (s*x+θ)*x))
  ring

theorem gaussian_first_sine_integral (s θ:ℝ) :
    (∫x:ℝ,x*Real.exp (-x^2/2)*Real.sin (s*x+θ))=
      Real.sqrt (2*Real.pi)*s*Real.exp (-s^2/2)*Real.cos θ := by
  have hd:=(gaussian_cosine_integral_derivative s θ).2
  have he:(fun t:ℝ=>∫x:ℝ,Real.exp (-x^2/2)*Real.cos (t*x+θ))=
      (fun t:ℝ=>Real.sqrt (2*Real.pi)*Real.exp (-t^2/2)*Real.cos θ) :=
    funext (fun t=>gaussian_cosine_integral t θ)
  rw [he] at hd
  have hd' : HasDerivAt (fun t:ℝ=>Real.sqrt (2*Real.pi)*Real.exp (-t^2/2)*Real.cos θ)
      (-(Real.sqrt (2*Real.pi)*s*Real.exp (-s^2/2)*Real.cos θ)) s := by
    convert! ((((hasDerivAt_id s).pow 2).neg.div_const 2).exp.const_mul
      (Real.sqrt (2*Real.pi))).mul_const (Real.cos θ) using 1 <;> dsimp <;> ring
  have hi:=hd.unique hd'
  have hfun:(fun x:ℝ=>Real.exp (-x^2/2)*(-Real.sin (s*x+θ)*x))=
      (fun x:ℝ=>-(x*Real.exp (-x^2/2)*Real.sin (s*x+θ))) := by
    funext x
    ring
  rw [hfun,integral_neg] at hi
  linarith

lemma gaussian_first_sine_integral_bound (s θ:ℝ) :
    |∫x:ℝ,x*Real.exp (-x^2/2)*Real.sin (s*x+θ)|≤
      Real.sqrt (2*Real.pi)*|s| *Real.exp (-s^2/2) := by
  rw [gaussian_first_sine_integral,abs_mul,abs_mul,abs_mul,
    abs_of_nonneg (Real.sqrt_nonneg _),Real.abs_exp]
  exact mul_le_of_le_one_right (by positivity) (Real.abs_cos_le_one _)

end NeuralGeneralization.OnlineLowerTanh
