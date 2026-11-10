import NeuralGeneralization.BatchTwoContinuousDepthJitterKernel
import Mathlib.MeasureTheory.Group.LIntegral

/-! Identification of the scalar convolution with its genuine smooth density.
The probability measure is still the independent-jitter construction. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open Set Filter MeasureTheory ContinuousLinearMap
open scoped BigOperators ENNReal Topology ContDiff Convolution
namespace NeuralGeneralization.BatchTwoContinuousDepthLower
open BatchTwoContinuous

/-- Exact equality of measures, not merely smoothness of a candidate density. -/
theorem smoothedScalarLaw_density (r : ℕ) :
    jitteredScalarLaw r (smoothJitterLaw r) =
      volume.withDensity (fun x => ENNReal.ofReal (smoothedScalarDensity r x)) := by
  rw [smoothJitter_scalar_convolution]
  apply Measure.ext_of_lintegral
  intro f hf
  rw [Measure.lintegral_conv hf,
    lintegral_withDensity_eq_lintegral_mul volume
      (smoothedScalarDensity_contDiff r).continuous.measurable.ennreal_ofReal hf]
  have hleft (t : ℝ) : ∫⁻ u, f (t+u) ∂realJitterLaw r =
      ∫⁻ x, ENNReal.ofReal (jitterKernel r (x-t))*f x := by
    rw [realJitterLaw, lintegral_withDensity_eq_lintegral_mul volume
      (jitterKernel_contDiff r).continuous.measurable.ennreal_ofReal (show Measurable (fun u : ℝ => f (t+u)) from
        hf.comp (measurable_const.add measurable_id))]
    have h := lintegral_add_left_eq_self (μ := (volume : Measure ℝ))
      (fun x => ENNReal.ofReal (jitterKernel r (x-t))*f x) t
    simpa only [add_sub_cancel_left, Pi.mul_apply] using h
  simp_rw [hleft, Pi.mul_apply, smoothedScalarDensity_ennreal]
  have hright (x : ℝ) : (∫⁻ t, ENNReal.ofReal (jitterKernel r (x-t)) ∂cantorLaw)*f x =
      ∫⁻ t, ENNReal.ofReal (jitterKernel r (x-t))*f x ∂cantorLaw := by
    exact (lintegral_mul_const (f x) (show Measurable (fun t : ℝ =>
      ENNReal.ofReal (jitterKernel r (x-t))) from
      ((jitterKernel_contDiff r).continuous.measurable.comp
        (measurable_const.sub measurable_id)).ennreal_ofReal)).symm
  simp_rw [hright]
  apply lintegral_lintegral_swap
  exact (((jitterKernel_contDiff r).continuous.measurable.comp
    (measurable_snd.sub measurable_fst)).ennreal_ofReal.mul (hf.comp measurable_snd)).aemeasurable

theorem cantorLaw_sharp_bound : ∀ᵐ t ∂cantorLaw, |t| ≤ (16/25 : ℝ) := by
  rw [cantorLaw, ae_map_iff scalarCoding_measurable.aemeasurable
    (show MeasurableSet {t : ℝ | |t| ≤ (16/25 : ℝ)} from
      measurableSet_le measurable_id.abs measurable_const)]
  exact Eventually.of_forall coding_sharp_bound

theorem smoothedScalarDensity_zero (r : ℕ) {x : ℝ} (hx : (13/20 : ℝ) < |x|) :
    smoothedScalarDensity r x = 0 := by
  apply integral_eq_zero_of_ae
  filter_upwards [cantorLaw_sharp_bound] with t ht
  by_contra hn
  have hsupport := jitterKernel_support r hn
  have htriangle := abs_sub_le x t 0
  simp only [sub_zero] at htriangle
  linarith [jitterRadius_le r]

theorem smoothedScalarDensity_compact (r : ℕ) : HasCompactSupport (smoothedScalarDensity r) := by
  apply HasCompactSupport.intro (K := Icc (-13/20 : ℝ) (13/20)) isCompact_Icc
  intro x hx
  apply smoothedScalarDensity_zero r
  by_contra hn
  apply hx
  simpa only [mem_Icc, neg_div] using (abs_le.mp (le_of_not_gt hn))

theorem smoothedScalarDensity_integrable (r : ℕ) : Integrable (smoothedScalarDensity r) :=
  (smoothedScalarDensity_contDiff r).continuous.integrable_of_hasCompactSupport
    (smoothedScalarDensity_compact r)

theorem smoothedScalarDensity_integral (r : ℕ) : ∫ x, smoothedScalarDensity r x = 1 := by
  have he := congrArg (fun μ : Measure ℝ => μ univ) (smoothedScalarLaw_density r)
  rw [measure_univ, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ,
    ← ofReal_integral_eq_lintegral_ofReal (smoothedScalarDensity_integrable r)
      (Eventually.of_forall (smoothedScalarDensity_nonneg r))] at he
  have hn : 0 ≤ ∫ x, smoothedScalarDensity r x := integral_nonneg (smoothedScalarDensity_nonneg r)
  have h := congrArg ENNReal.toReal he
  simpa only [ENNReal.toReal_one, ENNReal.toReal_ofReal hn] using h.symm

/-- The paper's depth-dependent distribution on the circle. -/
def smoothInputLaw (r : ℕ) : Measure (RealInput 2) := jitteredInputLaw r (smoothJitterLaw r)
instance smoothInputLaw_probability (r : ℕ) : IsProbabilityMeasure (smoothInputLaw r) :=
  jitteredInputLaw_probability r (smoothJitterLaw r)

theorem smoothInputLaw_density_pushforward (r : ℕ) :
    smoothInputLaw r = (volume.withDensity
      (fun x => ENNReal.ofReal (smoothedScalarDensity r x))).map sphereArc := by
  rw [← smoothedScalarLaw_density, jitteredInputLaw_arc]
  rfl

theorem smoothInputLaw_sphere (r : ℕ) : smoothInputLaw r {x | ∑ i, x i^2=1} = 1 :=
  jitteredInputLaw_sphere r (smoothJitterLaw r)

end NeuralGeneralization.BatchTwoContinuousDepthLower
