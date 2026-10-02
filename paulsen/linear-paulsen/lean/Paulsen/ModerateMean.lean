import Paulsen.HorizontalGaussianMean
import Paulsen.NormalResidualMean
import Paulsen.NormalizedTangentNoise

/-!
# Exact mean of the actual moderate-row Gaussian seed

The covariance decomposition is converted into the precise quadratic mean:
the original diagonal error, the explicit base term, and the controlled
residual. All expectations are with respect to the actual Gaussian factor.
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory
noncomputable section

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

theorem integral_horizontalQuadraticDiagonal_eq_covariance {n d : ℕ}
    (U : Frame n d) (C : Matrix (Fin n × Fin d) κ ℝ) (i : Fin n) :
    (∫ g, horizontalQuadraticDiagonal U (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (EuclideanSpace ℝ κ)) = normalQuadraticCovariance U i (C * C.transpose) := by
  rw [integral_horizontalQuadraticDiagonal_gaussianImage]
  have heq : C * C.transpose = ∑ s, Matrix.vecMulVec
      (fun p => (Matrix.of fun i j => C (i,j) s) p.1 p.2)
      (fun p => (Matrix.of fun i j => C (i,j) s) p.1 p.2) := by
    ext p q
    simp [Matrix.mul_apply, Matrix.sum_apply, Matrix.vecMulVec_apply]
  rw [heq, map_sum]
  simp only [normalQuadraticCovariance_outer]

theorem normalQuadraticCovariance_horizontalProjection {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) :
    normalQuadraticCovariance U i (horizontalProjectionMatrix U) =
      (d : ℝ) - n * rowNormSq U i := by
  have htrace : ∑ j, frameComplementProjection U j j = (n : ℝ) - d := by
    change (frameComplementProjection U).trace = _
    rw [frameComplementProjection, Matrix.trace_sub, Matrix.trace_one]
    have hP : (frameProjection U).trace = (d : ℝ) := by
      rw [frameProjection, Matrix.trace_mul_comm, hU]
      simp
    rw [hP, Fintype.card_fin]
  change (∑ k, horizontalProjectionMatrix U (i,k) (i,k)) -
    (∑ j, ∑ k, ∑ l, U i k * U i l * horizontalProjectionMatrix U (j,k) (j,l)) = _
  have happ (r : Fin n) (k l : Fin d) :
      horizontalProjectionMatrix U (r,k) (r,l) = if k = l then 1 - rowNormSq U r else 0 := by
    change frameComplementProjection U r r * (if k = l then 1 else 0) = _
    simp [frameComplementProjection, frameProjection_diagonal, mul_ite]
  have hfirst : (∑ k, horizontalProjectionMatrix U (i,k) (i,k)) =
      (d : ℝ) * (1 - rowNormSq U i) := by
    simp only [happ, if_true, Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  have hinner (j : Fin n) :
      (∑ k, ∑ l, U i k * U i l * horizontalProjectionMatrix U (j,k) (j,l)) =
        rowNormSq U i * (1 - rowNormSq U j) := by
    simp only [happ, mul_ite, mul_zero, Finset.sum_ite_eq, Finset.mem_univ, if_true]
    simp only [rowNormSq, Finset.sum_mul, pow_two]
  rw [hfirst]
  simp_rw [hinner]
  rw [← Finset.mul_sum]
  have hsum : (∑ j, (1 - rowNormSq U j)) = (n : ℝ) - d := by
    simpa [frameComplementProjection, frameProjection_diagonal] using htrace
  rw [hsum]
  ring

theorem normalQuadraticCovariance_highProjection {n d : ℕ} (U : Frame n d)
    (ρ : ℝ) (i : Fin n) :
    normalQuadraticCovariance U i (normalizedHighProjection U ρ) =
      ∑ j ∈ highNormalizedModes U ρ, horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i := by
  simp [normalizedHighProjection, map_sum, normalQuadraticCovariance_normalDirectionOuter]

/-- Exact quadratic mean used by the moderate-row seed construction. -/
theorem integral_horizontalQuadraticDiagonal_normalizedTangentNoise {n d : ℕ}
    (hn : 0 < n) {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    (∫ g, horizontalQuadraticDiagonal U
      (frameOfVector (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g)) i
      ∂stdGaussian (FrameVector n d)) =
        (d : ℝ) / n - rowNormSq U i -
          (1 / (n : ℝ)) *
            (projectionLaplacian (frameProjection U) *ᵥ (fun j => (rowNormSq U j)⁻¹)) i -
          normalResidualDiagonal U ρ i := by
  rw [integral_horizontalQuadraticDiagonal_eq_covariance,
    normalizedTangentNoiseFactor_covariance hU hρ, map_smul,
    retainedHorizontalProjection, map_sub,
    normalQuadraticCovariance_horizontalProjection hU,
    normalQuadraticCovariance_highProjection,
    normalResidualDiagonal_eq_removed_sub_base hU hp]
  simp only [smul_eq_mul]
  field_simp [Nat.cast_ne_zero.mpr hn.ne']
  ring

end
end Paulsen
