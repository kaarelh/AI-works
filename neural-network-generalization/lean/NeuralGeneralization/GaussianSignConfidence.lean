import NeuralGeneralization.GaussianResidualIndependence
import NeuralGeneralization.GaussianMixtureCDF
import NeuralGeneralization.GaussianConditionalLogCDF

/-! Buffered confidence forces a positive mean at the residual Gaussian
scale, for the actual finite Gaussian sign posterior. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.GaussianSignConfidence
open GaussianOrthogonal GaussianConeRadial GaussianSignCone GaussianConditionalSubspace
open GaussianSignRegression GaussianResidualIndependence GaussianConditionalLogCDF
variable {I J : Type*} [Fintype I] [Fintype J]

def euclideanEvent (A : J → I → ℝ) : Set (EuclideanSpace ℝ I) :=
  (fun x => ofLp x) ⁻¹' signCone A

theorem measurableSet_euclideanEvent (A : J → I → ℝ) : MeasurableSet (euclideanEvent A) :=
  (WithLp.measurable_ofLp 2 (I → ℝ)) (measurableSet_signCone A)

theorem projection_event_eq (A : J → I → ℝ) :
    (observationSpan A).starProjection ⁻¹' euclideanEvent A = euclideanEvent A := by
  ext x
  have heq (j : J) :
      (∑ i, A j i * ((observationSpan A).starProjection x) i) = ∑ i, A j i * x i := by
    have h := Submodule.inner_orthogonalProjectionOnto_eq_of_mem_left
      (⟨toLp 2 (A j), observation_mem A j⟩ : observationSpan A) x
    change ⟪toLp 2 (A j), (observationSpan A).starProjection x⟫ = ⟪toLp 2 (A j), x⟫ at h
    simpa [EuclideanSpace.inner_eq_star_dotProduct, dotProduct, mul_comm] using h
  change (∀ j, 0 < ∑ i, A j i * ((observationSpan A).starProjection x) i) ↔
    (∀ j, 0 < ∑ i, A j i * x i)
  simp only [heq]

theorem event_probability_ne_zero (A : J → I → ℝ)
    (hprob : (GaussianCoordinateIntegration.law I) (signCone A) ≠ 0) :
    (euclideanGaussian (ι := I) 1) (euclideanEvent A) ≠ 0 := by
  unfold euclideanGaussian
  rw [Measure.map_apply (WithLp.measurable_toLp 2 (I → ℝ)) (measurableSet_euclideanEvent A)]
  exact hprob

def locationLaw (A : J → I → ℝ) (u : I → ℝ) : Measure ℝ :=
  (cond ((euclideanGaussian (ι := I) 1).map (observationSpan A).starProjection)
    (euclideanEvent A)).map (fun x => ⟪toLp 2 u, x⟫)

def variance (A : J → I → ℝ) (u : I → ℝ) : ℝ :=
  residualVariance (observationSpan A) (toLp 2 u)

theorem variance_nonneg (A : J → I → ℝ) (u : I → ℝ) : 0 ≤ variance A u := sq_nonneg _

theorem locationLaw_isProbability (A : J → I → ℝ) (u : I → ℝ)
    (hprob : (GaussianCoordinateIntegration.law I) (signCone A) ≠ 0) :
    IsProbabilityMeasure (locationLaw A u) := by
  have hm := (observationSpan A).starProjection.continuous.measurable
  letI : IsProbabilityMeasure ((euclideanGaussian (ι := I) 1).map (observationSpan A).starProjection) :=
    Measure.isProbabilityMeasure_map hm.aemeasurable
  have hp : ((euclideanGaussian (ι := I) 1).map (observationSpan A).starProjection) (euclideanEvent A) ≠ 0 := by
    rw [Measure.map_apply hm (measurableSet_euclideanEvent A), projection_event_eq]
    exact event_probability_ne_zero A hprob
  letI := cond_isProbabilityMeasure hp
  unfold locationLaw
  exact Measure.isProbabilityMeasure_map (by fun_prop)

theorem conditionedOutput_eq_euclidean (A : J → I → ℝ) (u : I → ℝ) :
    conditionedOutput A u =
      (cond (euclideanGaussian (ι := I) 1) (euclideanEvent A)).map (fun x => ⟪toLp 2 u, x⟫) := by
  have hpre : (toLp 2 : (I → ℝ) → EuclideanSpace ℝ I) ⁻¹' euclideanEvent A = signCone A := rfl
  have hmap : (cond (GaussianCoordinateIntegration.law I) (signCone A)).map (toLp 2) =
      cond (euclideanGaussian (ι := I) 1) (euclideanEvent A) := by
    rw [← hpre, map_cond_preimage _ _ (WithLp.measurable_toLp 2 (I → ℝ)) _
      (measurableSet_euclideanEvent A)]
    rfl
  rw [← hmap, Measure.map_map (by fun_prop) (WithLp.measurable_toLp 2 (I → ℝ))]
  unfold conditionedOutput
  congr 1
  funext x
  simp [GaussianSignCDF.linear, EuclideanSpace.inner_eq_star_dotProduct, dotProduct, mul_comm]

/-- The sign-conditioned scalar field has an exact Gaussian location-mixture
representation with the regression residual variance. -/
theorem conditionedOutput_eq_mixture (A : J → I → ℝ) (u : I → ℝ)
    (hprob : (GaussianCoordinateIntegration.law I) (signCone A) ≠ 0) :
    conditionedOutput A u = GaussianMixtureCDF.law (locationLaw A u) (variance A u).toNNReal := by
  let ν := cond ((euclideanGaussian (ι := I) 1).map (observationSpan A).starProjection) (euclideanEvent A)
  have hm := (observationSpan A).starProjection.continuous.measurable
  letI : IsProbabilityMeasure ((euclideanGaussian (ι := I) 1).map (observationSpan A).starProjection) :=
    Measure.isProbabilityMeasure_map hm.aemeasurable
  have hp : ((euclideanGaussian (ι := I) 1).map (observationSpan A).starProjection) (euclideanEvent A) ≠ 0 := by
    rw [Measure.map_apply hm (measurableSet_euclideanEvent A), projection_event_eq]
    exact event_probability_ne_zero A hprob
  letI : IsProbabilityMeasure ν := cond_isProbabilityMeasure hp
  rw [conditionedOutput_eq_euclidean, ← projection_event_eq,
    conditional_prediction_mixture _ _ _ (measurableSet_euclideanEvent A)]
  change (ν.prod (gaussianReal 0 (variance A u).toNNReal)).map
      (fun p : EuclideanSpace ℝ I × ℝ => ⟪toLp 2 u, p.1⟫ + p.2) = _
  unfold GaussianMixtureCDF.law locationLaw
  change _ = ((ν.map (fun x => ⟪toLp 2 u, x⟫)).prod (gaussianReal 0 (variance A u).toNNReal)).map _
  nth_rw 2 [← Measure.map_id (μ := gaussianReal 0 (variance A u).toNNReal)]
  rw [Measure.map_prod_map _ _ (by fun_prop) measurable_id,
    Measure.map_map (by fun_prop) (by fun_prop)]
  rfl

theorem integrable_conditionedOutput (A : J → I → ℝ) (u : I → ℝ)
    (hprob : (GaussianCoordinateIntegration.law I) (signCone A) ≠ 0) :
    Integrable (fun x : ℝ => x) (conditionedOutput A u) := by
  unfold conditionedOutput
  apply (integrable_map_measure (by fun_prop) (measurable_linear u).aemeasurable).2
  exact integrable_finsetSum _ (fun i _ =>
    (((memLp_eval i).integrable (by norm_num)).restrict.smul_measure
      (ENNReal.inv_ne_top.mpr hprob)).const_mul (u i))

/-- Complete actual-posterior confidence lemma, with the paper's buffered
threshold and explicit positive Gaussian-scale constant. -/
theorem buffered_confidence_mean_margin (A : J → I → ℝ) (u : I → ℝ)
    (hprob : (GaussianCoordinateIntegration.law I) (signCone A) ≠ 0)
    (hv : 0 < variance A u)
    (hq : (13 : ℝ) / 20 < (conditionedOutput A u).real (Set.Ioi 0)) :
    Real.sqrt (2 * Real.pi * variance A u) * (Real.exp (-1) - 7 / 20) <
      ∫ z, GaussianSignCDF.linear u z
        ∂cond (GaussianCoordinateIntegration.law I) (signCone A) := by
  letI := locationLaw_isProbability A u hprob
  have hv' : (variance A u).toNNReal ≠ 0 := by
    exact (Real.toNNReal_pos.mpr hv).ne'
  have heq := conditionedOutput_eq_mixture A u hprob
  have hmono : StrictMono (cdf (conditionedOutput A u)) := by
    rw [heq]
    exact GaussianMixtureCDF.strictMono_cdf _ _ hv'
  have hlog := concaveOn_log_cdf A u hprob hmono
  have hi := integrable_conditionedOutput A u hprob
  rw [heq] at hlog hi hq
  have hh := GaussianMixtureCDF.mean_margin (locationLaw A u) (variance A u).toNNReal hv' hlog hi hq
  rw [← heq, conditionedOutput, integral_map (measurable_linear u).aemeasurable (by fun_prop)] at hh
  simpa only [Real.coe_toNNReal _ (variance_nonneg A u)] using hh

end NeuralGeneralization.GaussianSignConfidence
