import Mathlib.Analysis.Complex.CauchyIntegral
import Mathlib.Analysis.Fourier.Inversion
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals

/-! # Vertical integrals for a holomorphic quadratic remainder -/
noncomputable section
open scoped Topology FourierTransform
open Filter Set MeasureTheory Complex
namespace NeuralGeneralization.OnlineLowerTanh

/-- Exactly the analytic remainder hypothesis in the inverse-Laplace lemma. -/
structure HalfPlaneQuadraticRemainder (E : ℂ → ℂ) (a K : ℝ) : Prop where
  holomorphic : DifferentiableOn ℂ E {z | a < z.re}
  bound : ∀ z, a < z.re → ‖E z‖ ≤ K / ‖z‖^2

lemma inv_sq_add_sq_integrable {c : ℝ} (hc : 0 < c) :
    Integrable (fun y : ℝ => (c^2+y^2)⁻¹) := by
  have hi := (integrable_comp_mul_left_iff (fun y : ℝ => (1+y^2)⁻¹)
    (inv_ne_zero hc.ne')).2 integrable_inv_one_add_sq
  convert hi.const_mul (c^2)⁻¹ using 1
  ext y
  field_simp

lemma integral_inv_sq_add_sq_univ {c : ℝ} (hc : 0 < c) :
    (∫ y : ℝ, (c^2+y^2)⁻¹) = Real.pi/c := by
  calc
    _ = ∫ y : ℝ, (c^2)⁻¹ * (1+(c⁻¹*y)^2)⁻¹ := by congr 1; funext y; field_simp
    _ = _ := by
      rw [integral_const_mul, Measure.integral_comp_inv_mul_left (fun y : ℝ => (1+y^2)⁻¹) c,
        integral_univ_inv_one_add_sq, abs_of_pos hc]
      simp only [smul_eq_mul]
      field_simp

namespace HalfPlaneQuadraticRemainder
variable {E : ℂ → ℂ} {a K : ℝ} (H : HalfPlaneQuadraticRemainder E a K)

def vertical (_ : HalfPlaneQuadraticRemainder E a K) (c t y : ℝ) : ℂ := E (c+y*I) * Complex.exp ((c+y*I)*t)
def bromwich (c t : ℝ) : ℂ := (2*(Real.pi:ℂ))⁻¹ * ∫ y : ℝ, H.vertical c t y

lemma continuous_vertical {c : ℝ} (hc : a < c) (t : ℝ) :
    Continuous (H.vertical c t) := by
  unfold vertical
  have he : Continuous (fun y : ℝ => E ((c:ℂ)+y*I)) :=
    H.holomorphic.continuousOn.comp_continuous (by fun_prop) (by intro y; simpa using hc)
  exact he.mul (by fun_prop)

lemma norm_vertical_le {c : ℝ} (hc : a < c) (t y : ℝ) :
    ‖H.vertical c t y‖ ≤ K * Real.exp (c*t) * (c^2+y^2)⁻¹ := by
  have h := H.bound ((c:ℂ)+y*I) (by simpa using hc)
  have hn : ‖(c:ℂ)+y*I‖^2 = c^2+y^2 := by
    rw [Complex.sq_norm, Complex.normSq_apply]
    simp <;> ring
  unfold vertical
  rw [norm_mul, Complex.norm_exp]
  simp only [mul_re, add_re, ofReal_re, I_re, ofReal_im, mul_zero, zero_mul, sub_zero,
    add_zero] at *
  calc
    _ ≤ (K/(c^2+y^2))*Real.exp (c*t) := mul_le_mul_of_nonneg_right (by simpa [hn] using h) (by positivity)
    _ = _ := by ring

lemma integrable_vertical {c : ℝ} (hc : a < c) (hc0 : 0 < c) (t : ℝ) :
    Integrable (H.vertical c t) := by
  apply ((inv_sq_add_sq_integrable hc0).const_mul (K*Real.exp (c*t))).mono'
    (H.continuous_vertical hc t).aestronglyMeasurable
  exact ae_of_all _ (H.norm_vertical_le hc t)

lemma norm_bromwich_le {c : ℝ} (hc : a < c) (hc0 : 0 < c) (t : ℝ) :
    ‖H.bromwich c t‖ ≤ K*Real.exp (c*t)/(2*c) := by
  have h : ‖∫ y : ℝ, H.vertical c t y‖ ≤ K*Real.exp (c*t)*(Real.pi/c) := by
    calc
      _ ≤ ∫ y : ℝ, ‖H.vertical c t y‖ := norm_integral_le_integral_norm _
      _ ≤ ∫ y : ℝ, K*Real.exp (c*t)*(c^2+y^2)⁻¹ :=
        integral_mono (H.integrable_vertical hc hc0 t).norm
          ((inv_sq_add_sq_integrable hc0).const_mul _) (H.norm_vertical_le hc t)
      _ = _ := by rw [integral_const_mul, integral_inv_sq_add_sq_univ hc0]
  unfold bromwich
  rw [norm_mul]
  calc
    _ ≤ ‖(2*(Real.pi:ℂ))⁻¹‖ * (K*Real.exp (c*t)*(Real.pi/c)) :=
      mul_le_mul_of_nonneg_left h (norm_nonneg _)
    _ = _ := by
      rw [norm_inv, norm_mul]
      simp only [norm_ofNat, norm_real, Real.norm_eq_abs, abs_of_pos Real.pi_pos]
      field_simp
end HalfPlaneQuadraticRemainder
end NeuralGeneralization.OnlineLowerTanh
