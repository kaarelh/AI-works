import Paulsen.NormalBaseMean
import Paulsen.GaussianTangentCoupling

/-!
# Actual Gaussian means of the horizontal quadratic diagonal

The deterministic column formulas are connected to integrals over the
standard Gaussian law, including singular covariance factors.
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory
noncomputable section

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

theorem integral_rowNormSq_gaussianImage_eq_columns {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (i : Fin n) :
    (∫ g, rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (EuclideanSpace ℝ κ)) = ∑ j, ∑ k, C (i,j) k ^ 2 := by
  let D : Matrix (Fin d) κ ℝ := Matrix.of fun j k => C (i,j) k
  have heq (g : EuclideanSpace ℝ κ) :
      rowNormSq (frameOfVector (Matrix.toEuclideanLin C g)) i =
        ‖Matrix.toEuclideanLin D g‖ ^ 2 := by
    rw [EuclideanSpace.real_norm_sq_eq]
    rfl
  simp_rw [heq]
  exact integral_norm_sq_gaussianImage D

def horizontalRightFactor {n d : ℕ} (U : Frame n d)
    (C : Matrix (Fin n × Fin d) κ ℝ) : Matrix (Fin n × Fin n) κ ℝ :=
  Matrix.of fun p s => ∑ j, U p.1 j * C (p.2,j) s

theorem horizontalRightFactor_apply {n d : ℕ} (U : Frame n d)
    (C : Matrix (Fin n × Fin d) κ ℝ) (g : EuclideanSpace ℝ κ) :
    frameOfVector (Matrix.toEuclideanLin (horizontalRightFactor U C) g) =
      U * (frameOfVector (Matrix.toEuclideanLin C g)).transpose := by
  ext i k
  simp only [frameOfVector, horizontalRightFactor, Matrix.toLpLin_apply,
    Matrix.mulVec, dotProduct, Matrix.of_apply, Matrix.mul_apply, Matrix.transpose_apply,
    Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro s _
  ring

theorem memLp_horizontalQuadraticDiagonal_gaussianImage {n d : ℕ} (U : Frame n d)
    (C : Matrix (Fin n × Fin d) κ ℝ) (i : Fin n) :
    MemLp (fun g => horizontalQuadraticDiagonal U (frameOfVector (Matrix.toEuclideanLin C g)) i)
      2 (stdGaussian (EuclideanSpace ℝ κ)) := by
  unfold horizontalQuadraticDiagonal
  simp_rw [← horizontalRightFactor_apply]
  exact (memLp_rowNormSq_gaussianImage C i).sub
    (memLp_rowNormSq_gaussianImage (horizontalRightFactor U C) i)

/-- The mean is the sum of the deterministic quadratic diagonals of the
covariance factor's columns, with no independence of output entries assumed. -/
theorem integral_horizontalQuadraticDiagonal_gaussianImage {n d : ℕ} (U : Frame n d)
    (C : Matrix (Fin n × Fin d) κ ℝ) (i : Fin n) :
    (∫ g, horizontalQuadraticDiagonal U (frameOfVector (Matrix.toEuclideanLin C g)) i
      ∂stdGaussian (EuclideanSpace ℝ κ)) =
        ∑ s, horizontalQuadraticDiagonal U (Matrix.of fun i j => C (i,j) s) i := by
  unfold horizontalQuadraticDiagonal
  simp_rw [← horizontalRightFactor_apply]
  rw [integral_sub ((memLp_rowNormSq_gaussianImage C i).integrable (by norm_num))
    ((memLp_rowNormSq_gaussianImage (horizontalRightFactor U C) i).integrable (by norm_num)),
    integral_rowNormSq_gaussianImage_eq_columns, integral_rowNormSq_gaussianImage_eq_columns,
    Finset.sum_sub_distrib, Finset.sum_comm (f := fun j s => C (i,j) s ^ 2),
    Finset.sum_comm (f := fun j s => horizontalRightFactor U C (i,j) s ^ 2)]
  rfl

/-- The base covariance mean is the exact inverse-leverage Laplacian vector. -/
theorem integral_horizontalQuadraticDiagonal_base {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (i : Fin n) :
    (∫ g, horizontalQuadraticDiagonal U
      (frameOfVector (Matrix.toEuclideanLin (normalizedNormalMapMatrix U) g)) i
      ∂stdGaussian (EuclideanSpace ℝ (Fin n))) =
        (projectionLaplacian (frameProjection U) *ᵥ (fun j => (rowNormSq U j)⁻¹)) i := by
  rw [integral_horizontalQuadraticDiagonal_gaussianImage]
  have hcol (s : Fin n) : (Matrix.of fun i j => normalizedNormalMapMatrix U (i,j) s) =
      baseNormalDirection U s := by
    ext i j
    exact (baseNormalDirection_eq_column U s i j).symm
  simp_rw [hcol]
  exact horizontalQuadraticDiagonal_base_sum_eq_laplacian hU hp i

end
end Paulsen
