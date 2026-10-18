import NeuralGeneralization.RobustEntropyQueryObservation
import NeuralGeneralization.RobustGaussianGeometryActive

/-! # Exact zero-safe projection coordinates and residual variance -/
noncomputable section
open MeasureTheory ProbabilityTheory InnerProductSpace
open scoped BigOperators RealInnerProductSpace
namespace NeuralGeneralization.RobustEntropy
open RobustGaussianGeometry
variable {N q : ℕ}
local notation "E" => EuclideanSpace ℝ (Fin N)

def activeCoordinateVector (b : Fin q → E) (x : E) : EuclideanSpace ℝ (Fin q) :=
  WithLp.toLp 2 (evaluations (gramSchmidtNormed ℝ b) x)

theorem activeCoordinateVector_norm_sq (b : Fin q → E) (x : E) :
    ‖activeCoordinateVector b x‖^2 = ‖activeProjection b x‖^2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  exact active_energy_eq_projection b x

theorem queryResidual_norm_le (b : Fin q → E) (x : E) :
    ‖queryResidual b x‖ ≤ ‖x‖ := by
  unfold queryResidual
  rw [activeProjection_eq_starProjection,← Submodule.starProjection_orthogonal_val]
  exact (Submodule.span ℝ (Set.range b))ᗮ.norm_starProjection_apply_le x

theorem queryResidual_norm_sq (b : Fin q → E) (x : E) :
    ‖queryResidual b x‖^2 = ‖x‖^2-‖activeCoordinateVector b x‖^2 := by
  rw [activeCoordinateVector_norm_sq]
  have h := Submodule.norm_sq_eq_add_norm_sq_starProjection x (Submodule.span ℝ (Set.range b))
  rw [Submodule.starProjection_orthogonal_val] at h
  simp only [← activeProjection_eq_starProjection] at h
  change ‖x‖^2 = ‖activeProjection b x‖^2+‖queryResidual b x‖^2 at h
  linarith

theorem activeCoordinateVector_inner (b : Fin q → E) (x g : E) :
    ⟪activeCoordinateVector b g,activeCoordinateVector b x⟫ = ⟪x,activeProjection b g⟫ := by
  calc
    _ = ∑ j, ⟪gramSchmidtNormed ℝ b j,g⟫*⟪gramSchmidtNormed ℝ b j,x⟫ := by
      simp [activeCoordinateVector,EuclideanSpace.inner_eq_star_dotProduct,
        dotProduct,evaluations,mul_comm]
    _ = _ := by
      simp only [activeProjection,inner_sum,inner_smul_right]
      apply Finset.sum_congr rfl
      intro j hj
      rw [real_inner_comm x (gramSchmidtNormed ℝ b j)]

/-- Exactly the active mean plus a zero-safe normalized residual. -/
theorem scaled_query_decomposition (b : Fin q → E) (x g : E) (t : ℝ) :
    t*⟪x,g⟫ = ⟪t • activeCoordinateVector b g,activeCoordinateVector b x⟫+
      t*‖queryResidual b x‖*⟪normalizedQueryResidual b x,g⟫ := by
  rw [real_inner_smul_left,activeCoordinateVector_inner,query_inner_decomposition b x g]
  ring

theorem sqrt_query_variance (b : Fin q → E) (x : E) {t : ℝ} (ht : 0 ≤ t) :
    Real.sqrt (t^2*(‖x‖^2-‖activeCoordinateVector b x‖^2)) = t*‖queryResidual b x‖ := by
  rw [← queryResidual_norm_sq,← mul_pow,Real.sqrt_sq (mul_nonneg ht (norm_nonneg _))]

end NeuralGeneralization.RobustEntropy
