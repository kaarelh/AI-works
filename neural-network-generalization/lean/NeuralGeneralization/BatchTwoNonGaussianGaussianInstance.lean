import NeuralGeneralization.BatchTwoNonGaussianModel

/-! The standard Gaussian is an actual instance of the stated coordinate-law
model; its second moment and density are identified with mathlib's Gaussian. -/

noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoNonGaussian

private theorem quadratic_deriv (x : ℝ) :
    HasDerivAt (fun y : ℝ => y ^ 2 / 2) x x := by
  convert! ((hasDerivAt_id x).pow 2).div_const 2 using 1 <;> simp <;> ring

private theorem standard_gaussian_square_integral :
    (∫ x : ℝ, x ^ 2 ∂gaussianReal 0 1) = 1 := by
  have h := variance_fun_id_gaussianReal (μ := 0) (v := 1)
  rw [variance_eq_integral (X := fun x : ℝ => x) measurable_id'.aemeasurable] at h
  simpa using h

def standardGaussian : CoordinateLaw where
  law := gaussianReal 0 1
  probability := inferInstance
  potential := fun x => x ^ 2 / 2
  smooth := by fun_prop
  even := by intro x; simp
  normalizer := Real.sqrt (2 * Real.pi)
  normalizer_pos := by positivity
  density_eq := by
    rw [gaussianReal_of_var_ne_zero 0 (by norm_num : (1 : NNReal) ≠ 0)]
    congr 1
    funext x
    unfold gaussianPDF gaussianPDFReal
    congr 1
    norm_num
    ring
  lowerCurvature := 1
  upperCurvature := 1
  lowerCurvature_pos := by norm_num
  curvature_lower := by
    have heq : deriv (fun y : ℝ => y ^ 2 / 2) = id := funext fun x => (quadratic_deriv x).deriv
    rw [heq]
    intro x
    simp
  curvature_upper := by
    have heq : deriv (fun y : ℝ => y ^ 2 / 2) = id := funext fun x => (quadratic_deriv x).deriv
    rw [heq]
    intro x
    simp
  square_integrable := Integrable.of_integral_ne_zero (by rw [standard_gaussian_square_integral]; norm_num)
  square_integral := standard_gaussian_square_integral

@[simp] theorem standardGaussian_law : standardGaussian.law = gaussianReal 0 1 := rfl

end NeuralGeneralization.BatchTwoNonGaussian
