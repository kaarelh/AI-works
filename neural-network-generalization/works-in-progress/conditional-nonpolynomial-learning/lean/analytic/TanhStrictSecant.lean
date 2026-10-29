import ScalarGaussianGrowth
import NeuralGeneralization.TanhScalarJet
import NeuralGeneralization.BatchTwoNonGaussianSmallBallKernel
import Mathlib.Analysis.Calculus.MeanValue

/-! A strict contraction on a fixed positive part of the Gaussian sample
space. This permits purification via the elementary pairwise variance identity. -/
noncomputable section
open Set
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.TanhDifferential
open NeuralGeneralization.BatchTwoNonGaussian

theorem tanhFirst_le_on_positive_ray {v x : ℝ} (hv : 0 ≤ v) (hvsmall : v ≤ 1/2)
    (hx : Real.sqrt v ≤ x) : tanhFirst x ≤ 1-v/2 := by
  have hroot := Real.sq_sqrt hv
  have hbase := tanh_square_lower_quartic (Real.sqrt v)
  have hfour : (Real.sqrt v)^4=v^2 := by nlinarith [sq_nonneg (Real.sqrt v)]
  rw [hroot,hfour] at hbase
  have hmono := tanh_monotone hx
  have hnon : 0 ≤ Real.tanh (Real.sqrt v) := by
    simpa only [Real.tanh_zero] using tanh_monotone (Real.sqrt_nonneg v)
  unfold tanhFirst
  nlinarith [mul_nonneg hv (sub_nonneg.mpr hvsmall)]

theorem tanh_strict_secant {v x y : ℝ} (hv : 0 ≤ v) (hvsmall : v ≤ 1/2)
    (hx : Real.sqrt v ≤ x) (hy : Real.sqrt v ≤ y) :
    |Real.tanh x-Real.tanh y| ≤ (1-v/2)*|x-y| := by
  have hh := Convex.norm_image_sub_le_of_norm_hasDerivWithin_le
    (fun z (_hz : z ∈ Ici (Real.sqrt v)) => (hasDerivAt_tanh_first z).hasDerivWithinAt)
    (fun z (hz : z ∈ Ici (Real.sqrt v)) => show ‖tanhFirst z‖ ≤ 1-v/2 from by
      rw [Real.norm_eq_abs,abs_of_nonneg (tanhFirst_nonneg z)]
      exact tanhFirst_le_on_positive_ray hv hvsmall hz)
    (convex_Ici (Real.sqrt v)) hy hx
  simpa only [Real.norm_eq_abs] using hh

theorem tanh_strict_secant_square {v x y : ℝ} (hv : 0 ≤ v) (hvsmall : v ≤ 1/2)
    (hx : Real.sqrt v ≤ x) (hy : Real.sqrt v ≤ y) :
    (Real.tanh x-Real.tanh y)^2 ≤ (1-v/2)*(x-y)^2 := by
  have hs := tanh_strict_secant hv hvsmall hx hy
  have hfac : 0 ≤ 1-v/2 := by linarith
  have hsq := pow_le_pow_left₀ (abs_nonneg _) hs 2
  rw [sq_abs,mul_pow,sq_abs] at hsq
  have hf : (1-v/2)^2 ≤ 1-v/2 := by nlinarith
  exact hsq.trans (mul_le_mul_of_nonneg_right hf (sq_nonneg _))

theorem tanh_strict_secant_deficit {v x y : ℝ} (hv : 0 ≤ v) (hvsmall : v ≤ 1/2)
    (hx : Real.sqrt v ≤ x) (hy : Real.sqrt v ≤ y) :
    (v/2)*(x-y)^2 ≤ (x-y)^2-(Real.tanh x-Real.tanh y)^2 := by
  have hh := tanh_strict_secant_square hv hvsmall hx hy
  nlinarith

theorem shifted_positive_ray {v r A z : ℝ} (hr : 0 ≤ r) (hrv : r ≤ v)
    (hA : 2*Real.sqrt v ≤ A) (hz : -(1/2:ℝ) ≤ z) :
    Real.sqrt v ≤ A+Real.sqrt r*z := by
  have hrroot := Real.sqrt_le_sqrt hrv
  have hmul := mul_le_mul_of_nonneg_left hz (Real.sqrt_nonneg r)
  nlinarith [Real.sqrt_nonneg v]

/-- A quantitative deficit on two separated noise intervals. -/
theorem tanh_shifted_noise_deficit {v r A z z' : ℝ}
    (hr : 0 ≤ r) (hrv : r ≤ v) (hvsmall : v ≤ 1/2)
    (hA : 2*Real.sqrt v ≤ A)
    (hz : z ∈ Icc (-(1/2:ℝ)) (-(1/4:ℝ)))
    (hz' : z' ∈ Icc (1/4:ℝ) (1/2:ℝ)) :
    v*r/8 ≤ r*(z-z')^2-
      (Real.tanh (A+Real.sqrt r*z)-Real.tanh (A+Real.sqrt r*z'))^2 := by
  have hv := hr.trans hrv
  have hx := shifted_positive_ray hr hrv hA hz.1
  have hy := shifted_positive_ray (z := z') hr hrv hA (by linarith [hz'.1])
  have hh := tanh_strict_secant_deficit hv hvsmall hx hy
  have heq : ((A+Real.sqrt r*z)-(A+Real.sqrt r*z'))^2=r*(z-z')^2 := by
    calc
      _ = (Real.sqrt r)^2*(z-z')^2 := by ring
      _ = _ := by rw [Real.sq_sqrt hr]
  rw [heq] at hh
  have hdiff : (1/4:ℝ) ≤ (z-z')^2 := by nlinarith [hz.2,hz'.1]
  have hprod := mul_le_mul_of_nonneg_left hdiff (mul_nonneg hv hr)
  nlinarith

#print axioms tanh_shifted_noise_deficit
end ConditionalNonpolynomial.Analytic
