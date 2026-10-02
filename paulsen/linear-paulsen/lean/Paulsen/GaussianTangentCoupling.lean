import Paulsen.GaussianRowMoments
import Paulsen.GaussianLinearImage
import Paulsen.TangentQuadraticMean

/-!
# Coupling the row-tangent and global-tangent Gaussian noises
-/

open MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory

noncomputable section

namespace Paulsen

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]

omit [Fintype κ] [DecidableEq κ] in
theorem euclideanQuadratic_one (x : EuclideanSpace ℝ ι) :
    euclideanQuadratic (1 : Matrix ι ι ℝ) x = ‖x‖ ^ 2 := by
  simp [euclideanQuadratic, Matrix.toEuclideanLin]

omit [Fintype κ] [DecidableEq κ] in
theorem memLp_euclideanQuadratic_stdGaussian (A : Matrix ι ι ℝ) (hA : A.IsHermitian) :
    MemLp (euclideanQuadratic A) 2 (stdGaussian (EuclideanSpace ℝ ι)) := by
  have h := (memLp_centered_euclideanQuadratic_stdGaussian A hA).add (memLp_const A.trace)
  change MemLp (fun x => (euclideanQuadratic A x - A.trace) + A.trace) 2 _ at h
  simpa only [sub_add_cancel] using h

omit [Fintype κ] [DecidableEq κ] in
theorem integral_euclideanQuadratic_stdGaussian (A : Matrix ι ι ℝ) (hA : A.IsHermitian) :
    (∫ g, euclideanQuadratic A g ∂stdGaussian (EuclideanSpace ℝ ι)) = A.trace := by
  have h := integral_centered_euclideanQuadratic_stdGaussian A hA
  rw [integral_sub ((memLp_euclideanQuadratic_stdGaussian A hA).integrable (by norm_num))
    (integrable_const _), integral_const] at h
  simpa only [probReal_univ, one_smul, sub_eq_zero] using h

theorem norm_sq_gaussianImage_eq_quadratic (C : Matrix ι κ ℝ) (g : EuclideanSpace ℝ κ) :
    ‖Matrix.toEuclideanLin C g‖ ^ 2 = euclideanQuadratic (C.transpose * C) g := by
  rw [← euclideanQuadratic_one, euclideanQuadratic_linear_image, Matrix.mul_one]

theorem memLp_norm_sq_gaussianImage (C : Matrix ι κ ℝ) :
    MemLp (fun g => ‖Matrix.toEuclideanLin C g‖ ^ 2) 2
      (stdGaussian (EuclideanSpace ℝ κ)) := by
  simp_rw [norm_sq_gaussianImage_eq_quadratic]
  exact memLp_euclideanQuadratic_stdGaussian _ (by
    simpa only [Matrix.mul_one] using
      isHermitian_quadratic_pullback (1 : Matrix ι ι ℝ) Matrix.isHermitian_one C)

theorem integral_norm_sq_gaussianImage (C : Matrix ι κ ℝ) :
    (∫ g, ‖Matrix.toEuclideanLin C g‖ ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ)) =
      ∑ p, ∑ q, C p q ^ 2 := by
  simp_rw [norm_sq_gaussianImage_eq_quadratic]
  rw [integral_euclideanQuadratic_stdGaussian _ (by
    simpa only [Matrix.mul_one] using
      isHermitian_quadratic_pullback (1 : Matrix ι ι ℝ) Matrix.isHermitian_one C)]
  simp only [Matrix.trace, Matrix.diag, Matrix.mul_apply, Matrix.transpose_apply, ← sq]
  exact Finset.sum_comm

omit [Fintype κ] [DecidableEq κ] in
theorem integral_norm_sq_scaled_projection (E : Submodule ℝ (EuclideanSpace ℝ ι)) (c : ℝ) :
    (∫ g, ‖c • E.starProjection g‖ ^ 2 ∂stdGaussian (EuclideanSpace ℝ ι)) =
      c ^ 2 * (Module.finrank ℝ E : ℝ) := by
  have h := integral_norm_sq_gaussianImage (c • subspaceProjectionMatrix E)
  simp only [map_smul, subspaceProjectionMatrix_toEuclideanLin,
    LinearMap.smul_apply, ContinuousLinearMap.coe_coe] at h
  rw [h]
  simp only [Matrix.smul_apply, smul_eq_mul, mul_pow, ← Finset.mul_sum]
  rw [subspaceProjectionMatrix_sq_sum]

theorem rowTangentNoiseFactor_apply {n d : ℕ} (X : Frame n d) (g : FrameVector n d) :
    Matrix.toEuclideanLin (rowTangentNoiseFactor X) g =
      (1 / Real.sqrt (n : ℝ)) • (rowTangentSpace X).starProjection g := by
  simp only [rowTangentNoiseFactor, map_smul, subspaceProjectionMatrix_toEuclideanLin,
    LinearMap.smul_apply, ContinuousLinearMap.coe_coe]

theorem tangentNoiseFactor_apply {n d : ℕ} (X : Frame n d) (g : FrameVector n d) :
    Matrix.toEuclideanLin (tangentNoiseFactor X) g =
      (1 / Real.sqrt (n : ℝ)) • (globalTangentSpace X).starProjection g := by
  exact congrArg (fun f : FrameVector n d →L[ℝ] FrameVector n d => f g)
    (tangentNoiseFactor_toContinuousLinearMap X)

/-- Both noises use the same Gaussian realization; their difference is exactly
the scaled projection onto the removed tangent directions. -/
theorem tangentNoise_coupling_eq {n d : ℕ} (X : Frame n d) (g : FrameVector n d) :
    Matrix.toEuclideanLin (rowTangentNoiseFactor X) g -
      Matrix.toEuclideanLin (tangentNoiseFactor X) g =
        (1 / Real.sqrt (n : ℝ)) • (removedTangentSpace X).starProjection g := by
  rw [rowTangentNoiseFactor_apply, tangentNoiseFactor_apply, ← smul_sub,
    removedTangentProjection_eq_sub, sub_apply]

theorem integral_tangentNoise_coupling_sq {n d : ℕ} (X : Frame n d) :
    (∫ g : FrameVector n d,
      ‖Matrix.toEuclideanLin (rowTangentNoiseFactor X) g -
        Matrix.toEuclideanLin (tangentNoiseFactor X) g‖ ^ 2
      ∂stdGaussian (FrameVector n d)) =
      (Module.finrank ℝ (removedTangentSpace X) : ℝ) / n := by
  simp_rw [tangentNoise_coupling_eq]
  rw [integral_norm_sq_scaled_projection, div_pow, one_pow,
    Real.sq_sqrt (Nat.cast_nonneg n)]
  ring

theorem integral_tangentNoise_coupling_sq_le {n d : ℕ} (X : Frame n d) :
    (∫ g : FrameVector n d,
      ‖Matrix.toEuclideanLin (rowTangentNoiseFactor X) g -
        Matrix.toEuclideanLin (tangentNoiseFactor X) g‖ ^ 2
      ∂stdGaussian (FrameVector n d)) ≤ (d : ℝ) ^ 2 / n := by
  rw [integral_tangentNoise_coupling_sq]
  apply div_le_div_of_nonneg_right _ (Nat.cast_nonneg n)
  exact_mod_cast removedTangentSpace_finrank_le X

theorem integral_tangentNoise_norm_sq {n d : ℕ} (X : Frame n d) :
    (∫ g : FrameVector n d, ‖Matrix.toEuclideanLin (tangentNoiseFactor X) g‖ ^ 2
      ∂stdGaussian (FrameVector n d)) =
      (Module.finrank ℝ (globalTangentSpace X) : ℝ) / n := by
  simp_rw [tangentNoiseFactor_apply]
  rw [integral_norm_sq_scaled_projection, div_pow, one_pow,
    Real.sq_sqrt (Nat.cast_nonneg n)]
  ring

theorem integral_tangentNoise_norm_sq_le {n d : ℕ} (X : Frame n d) (hn : 0 < n) :
    (∫ g : FrameVector n d, ‖Matrix.toEuclideanLin (tangentNoiseFactor X) g‖ ^ 2
      ∂stdGaussian (FrameVector n d)) ≤ (d : ℝ) := by
  rw [integral_tangentNoise_norm_sq]
  apply (div_le_iff₀ (Nat.cast_pos.mpr hn)).2
  have h := Submodule.finrank_le (globalTangentSpace X)
  simp only [FrameVector, finrank_euclideanSpace, Fintype.card_prod,
    Fintype.card_fin] at h
  exact_mod_cast h.trans_eq (Nat.mul_comm n d)

theorem sqDistance_frameOfVector {n d : ℕ} (z w : FrameVector n d) :
    sqDistance (frameOfVector z) (frameOfVector w) = ‖z - w‖ ^ 2 := by
  simp only [sqDistance, frameOfVector, EuclideanSpace.real_norm_sq_eq,
    PiLp.sub_apply, Fintype.sum_prod_type]

theorem totalEnergy_frameOfVector {n d : ℕ} (z : FrameVector n d) :
    (∑ i, rowNormSq (frameOfVector z) i) = ‖z‖ ^ 2 := by
  simp only [rowNormSq, frameOfVector, EuclideanSpace.real_norm_sq_eq,
    Fintype.sum_prod_type]

theorem memLp_tangentNoise_coupling_sq {n d : ℕ} (X : Frame n d) :
    MemLp (fun g : FrameVector n d =>
      ‖Matrix.toEuclideanLin (rowTangentNoiseFactor X) g -
        Matrix.toEuclideanLin (tangentNoiseFactor X) g‖ ^ 2) 2
      (stdGaussian (FrameVector n d)) := by
  simpa only [map_sub, LinearMap.sub_apply] using
    memLp_norm_sq_gaussianImage (rowTangentNoiseFactor X - tangentNoiseFactor X)

/-- The coupling estimate in the frame-distance convention used by the Paulsen bound. -/
theorem integral_sqDistance_tangentNoise_coupling_le {n d : ℕ} (X : Frame n d) :
    (∫ g : FrameVector n d,
      sqDistance (frameOfVector (Matrix.toEuclideanLin (rowTangentNoiseFactor X) g))
        (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g))
      ∂stdGaussian (FrameVector n d)) ≤ (d : ℝ) ^ 2 / n := by
  simp_rw [sqDistance_frameOfVector]
  exact integral_tangentNoise_coupling_sq_le X

theorem integral_totalEnergy_tangentNoise_le {n d : ℕ} (X : Frame n d) (hn : 0 < n) :
    (∫ g : FrameVector n d,
      ∑ i, rowNormSq (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)) i
      ∂stdGaussian (FrameVector n d)) ≤ (d : ℝ) := by
  simp_rw [totalEnergy_frameOfVector]
  exact integral_tangentNoise_norm_sq_le X hn

end Paulsen
