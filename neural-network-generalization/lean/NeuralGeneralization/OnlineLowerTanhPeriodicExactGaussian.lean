import NeuralGeneralization.OnlineLowerTanhPeriodicSmoothing
import NeuralGeneralization.OnlineLowerGaussianOscillation
import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.MeasureTheory.Integral.DominatedConvergence

/-! The Fourier-damped response is the literal Gaussian convolution of the
periodic response, for every positive gain and every nonnegative residual energy. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.OnlineLowerTanh

lemma standardGaussian_sine_integral (s θ : ℝ) :
    (∫ x : ℝ, Real.sin (s*x+θ) ∂gaussianReal 0 1) =
      Real.exp (-s^2/2)*Real.sin θ := by
  rw [integral_gaussianReal_eq_integral_smul (by norm_num : (1:NNReal) ≠ 0)]
  simp only [gaussianPDFReal, NNReal.coe_one, mul_one, sub_zero, smul_eq_mul]
  simp_rw [mul_assoc]
  rw [integral_const_mul, gaussian_sine_integral]
  have hp : Real.sqrt (2*Real.pi) ≠ 0 := ne_of_gt (by positivity)
  field_simp

lemma standardGaussian_sine_integrable (s θ : ℝ) :
    Integrable (fun x : ℝ => Real.sin (s*x+θ)) (gaussianReal 0 1) := by
  apply (integrable_const (1:ℝ)).mono' (by fun_prop)
  exact Filter.Eventually.of_forall (fun x => by simpa only [Real.norm_eq_abs] using Real.abs_sin_le_one (s*x+θ))

lemma periodicFourierResponse_gaussian_convolution {a E : ℝ}
    (ha : 0 < a) (hE : 0 ≤ E) (b : ℝ) :
    (∫ x : ℝ, periodicFourierResponse a (b+Real.sqrt E*x)
      ∂gaussianReal 0 1) = smoothedResponse a E b := by
  let F : ℕ → ℝ → ℝ := fun j x => periodicCoefficient a j *
    Real.sin ((2*(j:ℝ)+1)*periodicFrequency a*(b+Real.sqrt E*x))
  have hi : ∀ j, Integrable (F j) (gaussianReal 0 1) := by
    intro j
    convert (standardGaussian_sine_integrable
      ((2*(j:ℝ)+1)*periodicFrequency a*Real.sqrt E)
      ((2*(j:ℝ)+1)*periodicFrequency a*b)).const_mul (periodicCoefficient a j) using 1
    funext x
    dsimp [F]
    congr 2 <;> ring
  have hbnd : ∀ j x, ‖F j x‖ ≤ periodicCoefficient a j := by
    intro j x
    dsimp [F]
    rw [abs_mul, abs_of_pos (periodicCoefficient_pos ha j)]
    exact mul_le_of_le_one_right (periodicCoefficient_pos ha j).le
      (Real.abs_sin_le_one _)
  have hs : Summable (fun j => ∫ x : ℝ, ‖F j x‖ ∂gaussianReal 0 1) := by
    apply (periodicCoefficient_summable ha).of_nonneg_of_le
      (fun j => integral_nonneg (fun x => norm_nonneg _))
    intro j
    calc
      (∫ x : ℝ, ‖F j x‖ ∂gaussianReal 0 1) ≤
          ∫ _x : ℝ, periodicCoefficient a j ∂gaussianReal 0 1 :=
        integral_mono (hi j).norm (integrable_const _) (hbnd j)
      _ = periodicCoefficient a j := by simp
  change (∫ x : ℝ, ∑' j, F j x ∂gaussianReal 0 1) = _
  rw [←integral_tsum_of_summable_integral_norm hi hs]
  unfold smoothedResponse
  apply tsum_congr
  intro j
  have heq : F j = fun x : ℝ => periodicCoefficient a j *
      Real.sin (((2*(j:ℝ)+1)*periodicFrequency a*Real.sqrt E)*x+
        (2*(j:ℝ)+1)*periodicFrequency a*b) := by
    funext x
    dsimp [F]
    congr 2 <;> ring
  rw [heq, integral_const_mul, standardGaussian_sine_integral]
  unfold smoothedCoefficient
  rw [mul_pow, Real.sq_sqrt hE]
  rw [show -(((2*(j:ℝ)+1)*periodicFrequency a)^2*E)/2 =
    -E*((2*(j:ℝ)+1)*periodicFrequency a)^2/2 by ring]
  ring

end NeuralGeneralization.OnlineLowerTanh
