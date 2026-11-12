import NeuralGeneralization.BatchTwoContinuousSphereLaw

/-! Orthogonal invariance of the uniform spherical input law. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuousSphere

/-- All orthogonal transformations preserve the constructed spherical law. -/
theorem uniformSphere_orthogonal_invariant (d : ℕ)
    (U : EuclideanSpace ℝ (Fin d) ≃ₗᵢ[ℝ] EuclideanSpace ℝ (Fin d)) :
    ((uniformSphere d).map (WithLp.toLp 2)).map U =
      (uniformSphere d).map (WithLp.toLp 2) := by
  let normalize : EuclideanSpace ℝ (Fin d) → EuclideanSpace ℝ (Fin d) :=
    fun x => ‖x‖⁻¹ • x
  have hn : Measurable normalize := by fun_prop
  have hU : Measurable U := U.continuous.measurable
  have he : U ∘ normalize = normalize ∘ U := by
    funext x
    simp [normalize]
  rw [uniformSphere_euclidean]
  change ((stdGaussian (EuclideanSpace ℝ (Fin d))).map normalize).map U =
    (stdGaussian (EuclideanSpace ℝ (Fin d))).map normalize
  rw [Measure.map_map hU hn, he, ← Measure.map_map hn hU, stdGaussian_map]

end NeuralGeneralization.BatchTwoContinuousSphere
