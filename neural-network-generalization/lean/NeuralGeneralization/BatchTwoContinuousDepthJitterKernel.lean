import NeuralGeneralization.BatchTwoContinuousDepthJitterLaw
import Mathlib.Analysis.Calculus.BumpFunction.Convolution
import Mathlib.Analysis.Calculus.ContDiff.Convolution
import Mathlib.MeasureTheory.Group.Convolution

/-! An actual smooth, compactly supported probability kernel on the paper's
jitter interval, and its smooth convolution against the singular Cantor law. -/
noncomputable section
open Set Filter MeasureTheory ContinuousLinearMap
open scoped BigOperators ENNReal Topology ContDiff Convolution
namespace NeuralGeneralization.BatchTwoContinuousDepthLower

def jitterBump (r : ℕ) : ContDiffBump (0 : ℝ) :=
  ⟨jitterRadius r / 2, jitterRadius r, half_pos (jitterRadius_pos r),
    half_lt_self (jitterRadius_pos r)⟩

def jitterKernel (r : ℕ) : ℝ → ℝ := (jitterBump r).normed volume

theorem jitterKernel_contDiff (r : ℕ) : ContDiff ℝ ∞ (jitterKernel r) :=
  (jitterBump r).contDiff_normed

theorem jitterKernel_nonneg (r : ℕ) (u : ℝ) : 0 ≤ jitterKernel r u :=
  (jitterBump r).nonneg_normed u

theorem jitterKernel_integrable (r : ℕ) : Integrable (jitterKernel r) :=
  (jitterBump r).integrable_normed

theorem jitterKernel_integral (r : ℕ) : ∫ u, jitterKernel r u = 1 :=
  (jitterBump r).integral_normed

theorem jitterKernel_compact (r : ℕ) : HasCompactSupport (jitterKernel r) :=
  (jitterBump r).hasCompactSupport_normed

theorem jitterKernel_support (r : ℕ) {u : ℝ} (hu : jitterKernel r u ≠ 0) :
    |u| < jitterRadius r := by
  have hs : u ∈ Function.support (jitterKernel r) := hu
  rw [jitterKernel, (jitterBump r).support_normed_eq] at hs
  simpa only [Metric.mem_ball, Real.dist_eq, sub_zero, jitterBump] using hs

def realJitterLaw (r : ℕ) : Measure ℝ := volume.withDensity (fun u => ENNReal.ofReal (jitterKernel r u))

instance realJitterLaw_probability (r : ℕ) : IsProbabilityMeasure (realJitterLaw r) where
  measure_univ := by
    rw [realJitterLaw, withDensity_apply _ MeasurableSet.univ, Measure.restrict_univ,
      ← ofReal_integral_eq_lintegral_ofReal (jitterKernel_integrable r)
        (Eventually.of_forall (jitterKernel_nonneg r)), jitterKernel_integral]
    norm_num

theorem realJitterLaw_bounded (r : ℕ) : ∀ᵐ u ∂realJitterLaw r, |u| ≤ jitterRadius r := by
  rw [realJitterLaw, ae_withDensity_iff (jitterKernel_contDiff r).continuous.measurable.ennreal_ofReal]
  apply Eventually.of_forall
  intro u hu
  exact (jitterKernel_support r (fun h => hu (by rw [h]; simp))).le

def smoothJitterLaw (r : ℕ) : Measure (Jitter r) :=
  (realJitterLaw r).comap Subtype.val

instance smoothJitterLaw_probability (r : ℕ) : IsProbabilityMeasure (smoothJitterLaw r) := by
  apply (MeasurableEmbedding.subtype_coe (s := {u : ℝ | |u| ≤ jitterRadius r})
    (measurableSet_le measurable_id.abs measurable_const)).isProbabilityMeasure_comap
  filter_upwards [realJitterLaw_bounded r] with u hu
  exact ⟨⟨u, hu⟩, rfl⟩

theorem smoothJitterLaw_map (r : ℕ) : (smoothJitterLaw r).map Subtype.val = realJitterLaw r := by
  exact (map_comap_subtype_coe (s := {u : ℝ | |u| ≤ jitterRadius r})
    (measurableSet_le measurable_id.abs measurable_const) (realJitterLaw r)).trans
    (Measure.restrict_eq_self_of_ae_mem (realJitterLaw_bounded r))

/-- The scalar density is convolution of the Cantor measure with the actual bump. -/
def smoothedScalarDensity (r : ℕ) (x : ℝ) : ℝ := ∫ t, jitterKernel r (x-t) ∂cantorLaw

theorem smoothedScalarDensity_contDiff (r : ℕ) : ContDiff ℝ ∞ (smoothedScalarDensity r) := by
  have h := (jitterKernel_compact r).contDiff_convolution_right (lsmul ℝ ℝ)
    (f := fun _ : ℝ => (1 : ℝ)) (μ := cantorLaw) (integrable_const 1).locallyIntegrable
    (jitterKernel_contDiff r)
  have he : ((fun _ : ℝ => (1 : ℝ)) ⋆[lsmul ℝ ℝ, cantorLaw] jitterKernel r) =
      smoothedScalarDensity r := by
    funext x
    simp only [convolution_def, lsmul_apply, smul_eq_mul, one_mul, smoothedScalarDensity]
  rw [he] at h
  exact h

theorem smoothedScalarDensity_nonneg (r : ℕ) (x : ℝ) : 0 ≤ smoothedScalarDensity r x :=
  integral_nonneg (fun _ => jitterKernel_nonneg r _)

theorem smoothedScalarDensity_integrand (r : ℕ) (x : ℝ) :
    Integrable (fun t => jitterKernel r (x-t)) cantorLaw := by
  have h := (jitterKernel_compact r).convolutionExists_right (lsmul ℝ ℝ)
    (f := fun _ : ℝ => (1 : ℝ)) (μ := cantorLaw) (integrable_const 1).locallyIntegrable
    (jitterKernel_contDiff r).continuous x
  simpa only [ConvolutionExistsAt, lsmul_apply, smul_eq_mul, one_mul] using h

theorem smoothedScalarDensity_ennreal (r : ℕ) (x : ℝ) :
    ENNReal.ofReal (smoothedScalarDensity r x) =
      ∫⁻ t, ENNReal.ofReal (jitterKernel r (x-t)) ∂cantorLaw :=
  ofReal_integral_eq_lintegral_ofReal (smoothedScalarDensity_integrand r x)
    (Eventually.of_forall (fun _ => jitterKernel_nonneg r _))

theorem smoothJitter_scalar_convolution (r : ℕ) :
    jitteredScalarLaw r (smoothJitterLaw r) = cantorLaw ∗ realJitterLaw r := by
  rw [Measure.conv, ← smoothJitterLaw_map r]
  change (signLaw.prod (smoothJitterLaw r)).map (jitteredScalar r) =
    ((signLaw.map scalarCoding).prod ((smoothJitterLaw r).map Subtype.val)).map (fun z => z.1+z.2)
  rw [Measure.map_prod_map _ _ scalarCoding_measurable measurable_subtype_coe,
    Measure.map_map (by fun_prop) (scalarCoding_measurable.prodMap measurable_subtype_coe)]
  rfl

end NeuralGeneralization.BatchTwoContinuousDepthLower
