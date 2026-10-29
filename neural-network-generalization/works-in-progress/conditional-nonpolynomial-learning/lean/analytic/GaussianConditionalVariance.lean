import TanhStrictSecant
import NeuralGeneralization.BatchTwoContinuousDepthCriticalPopulation

/-! Actual conditional Gaussian variances of tanh.  Purification follows from
the least-squares property of the mean and a fixed Gaussian interval; no
Gaussian Poincaré inequality is assumed. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory Set
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.BatchTwoContinuousDepthCritical
open NeuralGeneralization.BatchTwoNonGaussian

def shiftedVariance (r a : ℝ) : ℝ := shiftedSecond r a - (shiftedMean r a)^2

theorem shifted_tanh_integrable (r a : ℝ) :
    Integrable (fun z : ℝ => Real.tanh (a + Real.sqrt r*z)) (gaussianReal 0 1) := by
  apply Integrable.of_bound (by fun_prop) 1
  filter_upwards [] with z
  exact (Real.abs_tanh_lt_one _).le

theorem shifted_tanh_square_integrable (r a : ℝ) :
    Integrable (fun z : ℝ => (Real.tanh (a + Real.sqrt r*z))^2) (gaussianReal 0 1) := by
  apply Integrable.of_bound (by fun_prop) 1
  filter_upwards [] with z
  rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
  exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le

theorem shifted_tanh_centered_integrable (r a c : ℝ) :
    Integrable (fun z : ℝ => (Real.tanh (a + Real.sqrt r*z)-c)^2) (gaussianReal 0 1) := by
  apply Integrable.of_bound (by fun_prop) ((1+|c|)^2)
  filter_upwards [] with z
  rw [Real.norm_eq_abs, abs_of_nonneg (sq_nonneg _)]
  have hh : |Real.tanh (a+Real.sqrt r*z)-c| ≤ 1+|c| :=
    (abs_sub _ _).trans (add_le_add (Real.abs_tanh_lt_one _).le le_rfl)
  have hs := pow_le_pow_left₀ (abs_nonneg _) hh 2
  simpa only [sq_abs] using hs

theorem shifted_tanh_centered_integral (r a c : ℝ) :
    (∫ z, (Real.tanh (a+Real.sqrt r*z)-c)^2 ∂gaussianReal 0 1) =
      shiftedVariance r a + (shiftedMean r a-c)^2 := by
  have hp (z : ℝ) : (Real.tanh (a+Real.sqrt r*z)-c)^2 =
      (Real.tanh (a+Real.sqrt r*z))^2 - (2*c)*Real.tanh (a+Real.sqrt r*z)+c^2 := by ring
  simp_rw [hp]
  have hi : Integrable (fun z : ℝ => (Real.tanh (a+Real.sqrt r*z))^2-(2*c)*Real.tanh (a+Real.sqrt r*z)) (gaussianReal 0 1) :=
    (shifted_tanh_square_integrable r a).sub ((shifted_tanh_integrable r a).const_mul (2*c))
  rw [integral_add hi (integrable_const _),
    integral_sub (shifted_tanh_square_integrable r a)
      ((shifted_tanh_integrable r a).const_mul (2*c)), integral_const_mul]
  simp only [integral_const, probReal_univ, smul_eq_mul, one_mul]
  change shiftedSecond r a - 2*c*shiftedMean r a+c^2 = _
  unfold shiftedVariance
  ring

theorem shiftedVariance_nonneg (r a : ℝ) : 0 ≤ shiftedVariance r a := by
  have hh : 0 ≤ ∫ z : ℝ, (Real.tanh (a+Real.sqrt r*z)-shiftedMean r a)^2 ∂gaussianReal 0 1 :=
    integral_nonneg (fun z => sq_nonneg _)
  rw [shifted_tanh_centered_integral] at hh
  simpa using hh

theorem shiftedVariance_le_centered (r a c : ℝ) :
    shiftedVariance r a ≤ ∫ z, (Real.tanh (a+Real.sqrt r*z)-c)^2 ∂gaussianReal 0 1 := by
  rw [shifted_tanh_centered_integral]
  exact le_add_of_nonneg_right (sq_nonneg _)

theorem shifted_tanh_centered_square_le {r : ℝ} (hr : 0 ≤ r) (a z : ℝ) :
    (Real.tanh (a+Real.sqrt r*z)-Real.tanh a)^2 ≤ r*z^2 := by
  have hh := ConcreteModel.tanh_admissible.2 (a+Real.sqrt r*z) a
  have hs := pow_le_pow_left₀ (abs_nonneg _) hh 2
  simpa only [sq_abs, add_sub_cancel_left, mul_pow, Real.sq_sqrt hr] using hs

theorem shiftedVariance_le {r : ℝ} (hr : 0 ≤ r) (a : ℝ) :
    shiftedVariance r a ≤ r := by
  apply (shiftedVariance_le_centered r a (Real.tanh a)).trans
  have hh := integral_mono (shifted_tanh_centered_integrable r a (Real.tanh a))
    (standardGaussian.square_integrable.const_mul r) (shifted_tanh_centered_square_le hr a)
  have hg : (∫ z : ℝ, z^2 ∂gaussianReal 0 1) = 1 := standardGaussian.square_integral
  rw [integral_const_mul, hg, mul_one] at hh
  exact hh

def purificationNoiseInterval : Set ℝ := Icc (1/4) (1/2)
def purificationNoiseMass : ℝ := (gaussianReal 0 1).real purificationNoiseInterval
def purificationSignalInterval : Set ℝ := Icc 2 3
def purificationSignalMass : ℝ := (gaussianReal 0 1).real purificationSignalInterval
def purificationRate : ℝ := purificationNoiseMass*purificationSignalMass/32

theorem gaussian_Icc_mass_pos {a b : ℝ} (hab : a < b) :
    0 < (gaussianReal 0 1).real (Icc a b) := by
  apply ENNReal.toReal_pos
  · intro hz
    have hv := (gaussianReal_absolutelyContinuous' 0 (by norm_num : (1:NNReal) ≠ 0)) hz
    rw [Real.volume_Icc] at hv
    exact (ENNReal.ofReal_pos.mpr (sub_pos.mpr hab)).ne' hv
  · exact measure_ne_top _ _

theorem purificationNoiseMass_pos : 0 < purificationNoiseMass :=
  gaussian_Icc_mass_pos (by norm_num)

theorem purificationSignalMass_pos : 0 < purificationSignalMass :=
  gaussian_Icc_mass_pos (by norm_num)

theorem purificationRate_pos : 0 < purificationRate :=
  div_pos (mul_pos purificationNoiseMass_pos purificationSignalMass_pos) (by norm_num)

theorem shiftedVariance_strict {v r a : ℝ} (hr : 0 ≤ r) (hrv : r ≤ v)
    (hvsmall : v ≤ 1/2) (ha : 2*Real.sqrt v ≤ a) :
    shiftedVariance r a ≤ r-purificationNoiseMass*v*r/32 := by
  have hv := hr.trans hrv
  have hdef (z : ℝ) : purificationNoiseInterval.indicator (fun _ : ℝ => v*r/32) z ≤
      r*z^2-(Real.tanh (a+Real.sqrt r*z)-Real.tanh a)^2 := by
    by_cases hz : z ∈ purificationNoiseInterval
    · rw [Set.indicator_of_mem hz]
      have hz' : 1/4 ≤ z ∧ z ≤ 1/2 := hz
      have har : Real.sqrt v ≤ a := by nlinarith [Real.sqrt_nonneg v]
      have hshift : Real.sqrt v ≤ a+Real.sqrt r*z := by
        have hp := mul_nonneg (Real.sqrt_nonneg r) (show 0 ≤ z by linarith)
        linarith
      have hh := tanh_strict_secant_deficit hv hvsmall hshift har
      have he : (a+Real.sqrt r*z-a)^2 = r*z^2 := by
        rw [add_sub_cancel_left,mul_pow,Real.sq_sqrt hr]
      rw [he] at hh
      have hzsq : (1/16:ℝ) ≤ z^2 := by nlinarith
      have hp := mul_le_mul_of_nonneg_left hzsq (mul_nonneg hv hr)
      nlinarith
    · rw [Set.indicator_of_notMem hz]
      exact sub_nonneg.mpr (shifted_tanh_centered_square_le hr a z)
  have hi := (integrable_const (μ := gaussianReal 0 1) (v*r/32 : ℝ)).indicator
    (show MeasurableSet purificationNoiseInterval from measurableSet_Icc)
  have hir : Integrable (fun z : ℝ => r*z^2) (gaussianReal 0 1) := standardGaussian.square_integrable.const_mul r
  have hd : Integrable (fun z : ℝ => r*z^2-(Real.tanh (a+Real.sqrt r*z)-Real.tanh a)^2) (gaussianReal 0 1) :=
    hir.sub (shifted_tanh_centered_integrable r a (Real.tanh a))
  have hg : (∫ z : ℝ, z^2 ∂gaussianReal 0 1) = 1 := standardGaussian.square_integral
  have hh := integral_mono hi hd hdef
  rw [integral_indicator (show MeasurableSet purificationNoiseInterval from measurableSet_Icc),
    setIntegral_const,smul_eq_mul, integral_sub hir
      (shifted_tanh_centered_integrable r a (Real.tanh a)), integral_const_mul,
    hg,mul_one] at hh
  change purificationNoiseMass*(v*r/32) ≤ r-_ at hh
  have hm := shiftedVariance_le_centered r a (Real.tanh a)
  nlinarith

def steeringResidual (a r : ℝ) : ℝ :=
  ∫ z, shiftedVariance r (Real.sqrt a*z) ∂gaussianReal 0 1

theorem shiftedVariance_continuous : Continuous (fun p : ℝ×ℝ => shiftedVariance p.1 p.2) := by
  exact shiftedSecond_continuous.sub (shiftedMean_continuous.pow 2)

theorem shiftedVariance_le_one (r a : ℝ) : shiftedVariance r a ≤ 1 := by
  unfold shiftedVariance
  linarith [(shiftedSecond_bounds r a).2,sq_nonneg (shiftedMean r a)]

theorem steeringResidual_integrable (a r : ℝ) :
    Integrable (fun z : ℝ => shiftedVariance r (Real.sqrt a*z)) (gaussianReal 0 1) := by
  apply Integrable.of_bound
    ((shiftedVariance_continuous.comp (continuous_const.prodMk (by fun_prop))).aestronglyMeasurable) 1
  filter_upwards [] with z
  change ‖shiftedVariance r (Real.sqrt a*z)‖ ≤ 1
  rw [Real.norm_eq_abs,abs_of_nonneg (shiftedVariance_nonneg _ _)]
  exact shiftedVariance_le_one _ _

theorem steeringResidual_nonneg (a r : ℝ) : 0 ≤ steeringResidual a r :=
  integral_nonneg (fun _ => shiftedVariance_nonneg _ _)

theorem steeringResidual_le {r : ℝ} (hr : 0 ≤ r) (a : ℝ) : steeringResidual a r ≤ r := by
  have hh := integral_mono (steeringResidual_integrable a r) (integrable_const r)
    (fun z => shiftedVariance_le hr (Real.sqrt a*z))
  simpa [steeringResidual] using hh

theorem steeringResidual_strict {v a r : ℝ} (hr : 0 ≤ r) (hrv : r ≤ v)
    (hva : v ≤ a) (hvsmall : v ≤ 1/2) :
    steeringResidual a r ≤ (1-purificationRate*v)*r := by
  have hv := hr.trans hrv
  have hp (z : ℝ) : shiftedVariance r (Real.sqrt a*z) ≤
      r-purificationSignalInterval.indicator (fun _ : ℝ => purificationNoiseMass*v*r/32) z := by
    by_cases hz : z ∈ purificationSignalInterval
    · rw [Set.indicator_of_mem hz]
      apply shiftedVariance_strict hr hrv hvsmall
      have hz' : 2 ≤ z ∧ z ≤ 3 := hz
      have hs := Real.sqrt_le_sqrt hva
      have hm := mul_le_mul_of_nonneg_left hz'.1 (Real.sqrt_nonneg a)
      nlinarith [Real.sqrt_nonneg v]
    · rw [Set.indicator_of_notMem hz,sub_zero]
      exact shiftedVariance_le hr _
  have hi := (integrable_const (μ := gaussianReal 0 1) (purificationNoiseMass*v*r/32)).indicator
    (show MeasurableSet purificationSignalInterval from measurableSet_Icc)
  have hib : Integrable (fun z : ℝ => r-
      purificationSignalInterval.indicator (fun _ : ℝ => purificationNoiseMass*v*r/32) z)
      (gaussianReal 0 1) := (integrable_const r).sub hi
  have hh := integral_mono (steeringResidual_integrable a r) hib hp
  rw [integral_sub (integrable_const r) hi,
    integral_indicator (show MeasurableSet purificationSignalInterval from measurableSet_Icc),
    setIntegral_const,smul_eq_mul] at hh
  simp only [integral_const,probReal_univ,smul_eq_mul,one_mul] at hh
  change steeringResidual a r ≤ r-purificationSignalMass*(purificationNoiseMass*v*r/32) at hh
  unfold purificationRate
  nlinarith

#print axioms steeringResidual_strict
end ConditionalNonpolynomial.Analytic
