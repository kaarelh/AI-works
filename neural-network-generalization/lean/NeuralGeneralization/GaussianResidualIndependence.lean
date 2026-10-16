import NeuralGeneralization.GaussianSignRepresenter
import Mathlib.Probability.Distributions.Gaussian.HasGaussianLaw.Independence
import Mathlib.Probability.Distributions.Gaussian.Multivariate

/-! Exact independent Gaussian residuals for sign conditioning. The Gaussian
law and its covariance are proved for the existing concrete product prior. -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace
namespace NeuralGeneralization.GaussianResidualIndependence
open GaussianOrthogonal GaussianConditionalSubspace
variable {I : Type*} [Fintype I]

theorem euclideanGaussian_eq_stdGaussian :
    euclideanGaussian (ι := I) 1 = stdGaussian (EuclideanSpace ℝ I) :=
  map_pi_eq_stdGaussian

/-- Orthogonal projections of the concrete standard Gaussian are independent. -/
theorem orthogonal_projections_independent (K : Submodule ℝ (EuclideanSpace ℝ I)) :
    IndepFun K.starProjection Kᗮ.starProjection (euclideanGaussian (ι := I) 1) := by
  rw [euclideanGaussian_eq_stdGaussian]
  have hjoint : HasGaussianLaw (fun x : EuclideanSpace ℝ I =>
      (K.starProjection x, Kᗮ.starProjection x)) (stdGaussian (EuclideanSpace ℝ I)) :=
    IsGaussian.hasGaussianLaw_id.map_fun (K.starProjection.prod Kᗮ.starProjection)
  apply hjoint.indepFun_of_covariance_inner
  intro u v
  have hu (x : EuclideanSpace ℝ I) : ⟪u, K.starProjection x⟫ = ⟪K.starProjection u, x⟫ :=
    (K.inner_starProjection_left_eq_right u x).symm
  have hv (x : EuclideanSpace ℝ I) : ⟪v, Kᗮ.starProjection x⟫ = ⟪Kᗮ.starProjection v, x⟫ :=
    (Kᗮ.inner_starProjection_left_eq_right v x).symm
  simp_rw [hu, hv]
  rw [← covarianceBilin_apply_eq_cov IsGaussian.memLp_two_id,
    covarianceBilin_stdGaussian, innerSL_apply_apply]
  exact Submodule.inner_right_of_mem_orthogonal
    (K.orthogonalProjectionOnto u).property (Kᗮ.orthogonalProjectionOnto v).property

/-- Conditioning the first coordinate of a product probability leaves the
second coordinate's law unchanged. -/
theorem cond_prod_left {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]
    (μ : Measure α) (ν : Measure β) [IsFiniteMeasure μ] [IsProbabilityMeasure ν]
    (C : Set α) :
    cond (μ.prod ν) (C ×ˢ Set.univ) = (cond μ C).prod ν := by
  unfold ProbabilityTheory.cond
  rw [Measure.prod_prod, measure_univ, mul_one, ← Measure.prod_restrict,
    Measure.restrict_univ, Measure.prod_smul_left]

/-- The joint conditional distribution is an actual product, rather than an
assumption about Gaussian conditional expectations. -/
theorem conditional_pair_product {Ω α β : Type*}
    [MeasurableSpace Ω] [MeasurableSpace α] [MeasurableSpace β]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (f : Ω → α) (g : Ω → β) (hf : Measurable f) (hg : Measurable g)
    (hind : IndepFun f g μ) (C : Set α) (hC : MeasurableSet C) :
    (cond μ (f ⁻¹' C)).map (fun x => (f x, g x)) =
      (cond (μ.map f) C).prod (μ.map g) := by
  letI : IsProbabilityMeasure (μ.map f) := Measure.isProbabilityMeasure_map hf.aemeasurable
  letI : IsProbabilityMeasure (μ.map g) := Measure.isProbabilityMeasure_map hg.aemeasurable
  have hp : (fun x => (f x, g x)) ⁻¹' (C ×ˢ Set.univ) = f ⁻¹' C := by
    ext x
    simp
  rw [← hp, map_cond_preimage _ _ (hf.prodMk hg) _ (hC.prod MeasurableSet.univ),
    hind.map_prod_eq_prod_map_map hf.aemeasurable hg.aemeasurable, cond_prod_left]

/-- Exact posterior factorization into the conditioned observed projection
and an independent, unchanged Gaussian residual projection. -/
theorem conditional_projection_pair (K : Submodule ℝ (EuclideanSpace ℝ I))
    (C : Set (EuclideanSpace ℝ I)) (hC : MeasurableSet C) :
    (cond (euclideanGaussian (ι := I) 1) (K.starProjection ⁻¹' C)).map
      (fun x => (K.starProjection x, Kᗮ.starProjection x)) =
      (cond ((euclideanGaussian (ι := I) 1).map K.starProjection) C).prod
        ((euclideanGaussian (ι := I) 1).map Kᗮ.starProjection) :=
  conditional_pair_product _ _ _ K.starProjection.continuous.measurable
    Kᗮ.starProjection.continuous.measurable (orthogonal_projections_independent K) C hC

/-- Exact scalar Gaussian law of an arbitrary linear form of the concrete
standard Gaussian. -/
theorem map_inner_eq_gaussian (b : EuclideanSpace ℝ I) :
    (euclideanGaussian (ι := I) 1).map (fun x => ⟪b, x⟫) =
      gaussianReal 0 (‖b‖ ^ 2).toNNReal := by
  rw [euclideanGaussian_eq_stdGaussian]
  have h : HasGaussianLaw (fun x : EuclideanSpace ℝ I => ⟪b, x⟫)
      (stdGaussian (EuclideanSpace ℝ I)) :=
    IsGaussian.hasGaussianLaw_id.map_fun (innerSL ℝ b)
  rw [h.map_eq_gaussianReal]
  congr 1
  · exact integral_strongDual_stdGaussian (innerSL ℝ b)
  · congr 1
    change Var[innerSL ℝ b; stdGaussian (EuclideanSpace ℝ I)] = _
    rw [variance_dual_stdGaussian, innerSL_apply_norm]

/-- The residual linear form has variance equal to squared distance of its
feature vector from the observation span. -/
def residualVariance (K : Submodule ℝ (EuclideanSpace ℝ I)) (b : EuclideanSpace ℝ I) : ℝ :=
  ‖Kᗮ.starProjection b‖ ^ 2

theorem conditional_scalar_pair (K : Submodule ℝ (EuclideanSpace ℝ I))
    (b : EuclideanSpace ℝ I) (C : Set (EuclideanSpace ℝ I)) (hC : MeasurableSet C) :
    (cond (euclideanGaussian (ι := I) 1) (K.starProjection ⁻¹' C)).map
      (fun x => (K.starProjection x, ⟪b, Kᗮ.starProjection x⟫)) =
      (cond ((euclideanGaussian (ι := I) 1).map K.starProjection) C).prod
        (gaussianReal 0 (residualVariance K b).toNNReal) := by
  have hind : IndepFun K.starProjection (fun x : EuclideanSpace ℝ I => ⟪b, Kᗮ.starProjection x⟫)
      (euclideanGaussian (ι := I) 1) := by
    exact (orthogonal_projections_independent K).comp measurable_id
      (innerSL ℝ b).continuous.measurable
  rw [conditional_pair_product _ _ _ K.starProjection.continuous.measurable
    (by fun_prop) hind C hC]
  have heq : (fun x : EuclideanSpace ℝ I => ⟪b, Kᗮ.starProjection x⟫) =
      fun x => ⟪Kᗮ.starProjection b, x⟫ := by
    funext x
    exact (Kᗮ.inner_starProjection_left_eq_right b x).symm
  rw [heq, map_inner_eq_gaussian]
  rfl

/-- The actual conditional prediction law is a mixture of Gaussians with a
single, common residual variance. -/
theorem conditional_prediction_mixture (K : Submodule ℝ (EuclideanSpace ℝ I))
    (b : EuclideanSpace ℝ I) (C : Set (EuclideanSpace ℝ I)) (hC : MeasurableSet C) :
    (cond (euclideanGaussian (ι := I) 1) (K.starProjection ⁻¹' C)).map (fun x => ⟪b, x⟫) =
      ((cond ((euclideanGaussian (ι := I) 1).map K.starProjection) C).prod
        (gaussianReal 0 (residualVariance K b).toNNReal)).map
          (fun p : EuclideanSpace ℝ I × ℝ => ⟪b, p.1⟫ + p.2) := by
  rw [← conditional_scalar_pair K b C hC,
    Measure.map_map (by fun_prop) (by fun_prop)]
  congr 1
  funext x
  simp only [Function.comp_apply]
  rw [← inner_add_right, K.starProjection_add_starProjection_orthogonal]

end NeuralGeneralization.GaussianResidualIndependence
