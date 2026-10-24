import NeuralGeneralization.BatchTwoImprovedProjection
import Mathlib.Probability.Kernel.Composition.MapComap

/-! # A measurable Gaussian residual sampler with exact scalar marginals -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InnerProductSpace Submodule
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoImprovedProjection
open RobustGaussianGeometry GaussianOrthogonal GaussianResidualIndependence
variable {m q : ℕ}

def projectionResidualKernel :
    Kernel (Fin q → EuclideanSpace ℝ (Fin m)) (EuclideanSpace ℝ (Fin m)) where
  toFun := fun f => (euclideanGaussian (ι := Fin m) 1).map (queryResidual f)
  measurable' := by
    apply Measure.measurable_of_measurable_coe
    intro B hB
    have hf (f : Fin q → EuclideanSpace ℝ (Fin m)) : Measurable (queryResidual f) :=
      measurable_queryResidual.comp (measurable_const.prodMk measurable_id)
    simp_rw [Measure.map_apply (hf _) hB]
    exact measurable_measure_prodMk_left (measurable_queryResidual hB)

instance projectionResidualKernel_markov : IsMarkovKernel (projectionResidualKernel (m:=m) (q:=q)) where
  isProbabilityMeasure _ := Measure.isProbabilityMeasure_map
    (measurable_queryResidual.comp (measurable_const.prodMk measurable_id)).aemeasurable

theorem inner_queryResidual (f : Fin q → EuclideanSpace ℝ (Fin m))
    (r z : EuclideanSpace ℝ (Fin m)) : ⟪r,queryResidual f z⟫=⟪queryResidual f r,z⟫ := by
  simp only [queryResidual,inner_sub_right,inner_sub_left,activeProjection_eq_starProjection]
  rw [(Submodule.span ℝ (Set.range f)).inner_starProjection_left_eq_right]

/-- This is the literal Gaussian pushforward, not merely a moment match. -/
theorem projectionResidualKernel_scalar_law (f : Fin q → EuclideanSpace ℝ (Fin m))
    (r : EuclideanSpace ℝ (Fin m)) :
    (projectionResidualKernel f).map (fun z => ⟪r,z⟫) =
      gaussianReal 0 (‖queryResidual f r‖^2).toNNReal := by
  change ((euclideanGaussian (ι := Fin m) 1).map (queryResidual f)).map _ = _
  have hm : Measurable (queryResidual f) :=
    measurable_queryResidual.comp (measurable_const.prodMk measurable_id)
  rw [Measure.map_map (by fun_prop) hm]
  have he : (fun z => ⟪r,z⟫) ∘ queryResidual f = fun z => ⟪queryResidual f r,z⟫ := by
    funext z
    exact inner_queryResidual f r z
  rw [he,map_inner_eq_gaussian]

/-- Subtracting a vector in the active span does not change residual noise. -/
theorem queryResidual_sub_span (f : Fin q → EuclideanSpace ℝ (Fin m))
    (r v : EuclideanSpace ℝ (Fin m)) (hv : v ∈ Submodule.span ℝ (Set.range f)) :
    queryResidual f (r-v) = queryResidual f r := by
  simp only [queryResidual,activeProjection_eq_starProjection,map_sub,
    (Submodule.span ℝ (Set.range f)).starProjection_eq_self_iff.mpr hv]
  abel

end NeuralGeneralization.BatchTwoImprovedProjection
