import Mathlib.Analysis.SpecialFunctions.Gaussian.FourierTransform
import Mathlib.Tactic

noncomputable section
open MeasureTheory Complex
namespace NeuralGeneralization.OnlineLowerTanh

lemma gaussian_complex_integral (s θ:ℝ) :
    (∫x:ℝ,Complex.exp ((-(1/2):ℂ)*(x:ℂ)^2+I*(s:ℂ)*(x:ℂ)+I*(θ:ℂ)))=
      (Real.sqrt (2*Real.pi):ℂ)*Complex.exp ((-(s^2)/2:ℝ)+I*(θ:ℂ)) := by
  have hh:=integral_cexp_quadratic (b:=(-(1/2):ℂ)) (by norm_num) (I*(s:ℂ)) (I*(θ:ℂ))
  rw [hh]
  have hsqrt : ((Real.pi:ℂ)/ -(-(1/2):ℂ))^(1/2:ℂ)=(Real.sqrt (2*Real.pi):ℂ) := by
    have hbase : (Real.pi:ℂ)/ -(-(1/2):ℂ)=((2*Real.pi:ℝ):ℂ) := by push_cast; ring
    rw [hbase,Real.sqrt_eq_rpow]
    convert (Complex.ofReal_cpow (by positivity : 0≤2*Real.pi) (1/2:ℝ)).symm using 1 <;> push_cast <;> rfl
  rw [hsqrt]
  congr 2
  push_cast
  rw [mul_pow,I_sq]
  ring

lemma gaussian_sine_integrable (s θ:ℝ) :
    Integrable (fun x:ℝ=>Real.exp (-x^2/2)*Real.sin (s*x+θ)) := by
  have hh:=integrable_cexp_quadratic' (b:=(-(1/2):ℂ)) (by norm_num) (I*(s:ℂ)) (I*(θ:ℂ))
  have hi:=hh.im
  simp only [RCLike.im_to_complex] at hi
  convert hi using 1
  funext x
  simp only [Complex.exp_im,Complex.add_re,Complex.add_im,Complex.mul_re,Complex.mul_im,
    Complex.ofReal_re,Complex.ofReal_im,Complex.I_re,Complex.I_im,
    Complex.neg_re,Complex.neg_im,Complex.div_re,Complex.div_im,Complex.normSq_apply,
    ←Complex.ofReal_pow]
  norm_num
  congr 2 <;> ring_nf <;> simp

lemma gaussian_cosine_integrable (s θ:ℝ) :
    Integrable (fun x:ℝ=>Real.exp (-x^2/2)*Real.cos (s*x+θ)) := by
  have hh:=integrable_cexp_quadratic' (b:=(-(1/2):ℂ)) (by norm_num) (I*(s:ℂ)) (I*(θ:ℂ))
  have hi:=hh.re
  simp only [RCLike.re_to_complex] at hi
  convert hi using 1
  funext x
  simp only [Complex.exp_re,Complex.add_re,Complex.add_im,Complex.mul_re,Complex.mul_im,
    Complex.ofReal_re,Complex.ofReal_im,Complex.I_re,Complex.I_im,
    Complex.neg_re,Complex.neg_im,Complex.div_re,Complex.div_im,Complex.normSq_apply,
    ←Complex.ofReal_pow]
  norm_num
  congr 2 <;> ring_nf <;> simp

theorem gaussian_sine_integral (s θ:ℝ) :
    (∫x:ℝ,Real.exp (-x^2/2)*Real.sin (s*x+θ))=
      Real.sqrt (2*Real.pi)*Real.exp (-s^2/2)*Real.sin θ := by
  have hh:=congrArg Complex.im (gaussian_complex_integral s θ)
  have hi:=integral_im (integrable_cexp_quadratic' (b:=(-(1/2):ℂ)) (by norm_num) (I*(s:ℂ)) (I*(θ:ℂ)))
  simp only [RCLike.im_to_complex] at hi
  rw [←hi] at hh
  convert hh using 1
  · apply integral_congr_ae
    filter_upwards [] with x
    simp only [Complex.exp_im,Complex.add_re,Complex.add_im,Complex.mul_re,Complex.mul_im,
      Complex.ofReal_re,Complex.ofReal_im,Complex.I_re,Complex.I_im,
      Complex.neg_re,Complex.neg_im,Complex.div_re,Complex.div_im,Complex.normSq_apply,
      ←Complex.ofReal_pow]
    norm_num
    congr 2 <;> ring_nf <;> simp
  · simp only [Complex.mul_im,Complex.exp_im,Complex.exp_re,←Complex.ofReal_pow,
      Complex.ofReal_re,Complex.ofReal_im,Complex.add_re,Complex.add_im,
      Complex.I_re,Complex.I_im,Complex.mul_re,zero_mul,mul_zero,zero_add,add_zero,
      sub_zero,one_mul,mul_assoc]

theorem gaussian_cosine_integral (s θ:ℝ) :
    (∫x:ℝ,Real.exp (-x^2/2)*Real.cos (s*x+θ))=
      Real.sqrt (2*Real.pi)*Real.exp (-s^2/2)*Real.cos θ := by
  have hh:=congrArg Complex.re (gaussian_complex_integral s θ)
  have hi:=integral_re (integrable_cexp_quadratic' (b:=(-(1/2):ℂ)) (by norm_num) (I*(s:ℂ)) (I*(θ:ℂ)))
  simp only [RCLike.re_to_complex] at hi
  rw [←hi] at hh
  convert hh using 1
  · apply integral_congr_ae
    filter_upwards [] with x
    simp only [Complex.exp_re,Complex.add_re,Complex.add_im,Complex.mul_re,Complex.mul_im,
      Complex.ofReal_re,Complex.ofReal_im,Complex.I_re,Complex.I_im,
      Complex.neg_re,Complex.neg_im,Complex.div_re,Complex.div_im,Complex.normSq_apply,
      ←Complex.ofReal_pow]
    norm_num
    congr 2 <;> ring_nf <;> simp
  · simp only [Complex.mul_re,Complex.exp_im,Complex.exp_re,←Complex.ofReal_pow,
      Complex.ofReal_re,Complex.ofReal_im,Complex.add_re,Complex.add_im,
      Complex.I_re,Complex.I_im,Complex.mul_im,zero_mul,mul_zero,zero_add,add_zero,
      sub_zero,one_mul,mul_assoc]

end NeuralGeneralization.OnlineLowerTanh
