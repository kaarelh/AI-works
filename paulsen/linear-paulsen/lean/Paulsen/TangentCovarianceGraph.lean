import Paulsen.NormalTangentGraph
import Paulsen.RetainedTangentFactor

/-! Exact entry covariance and graph energy of the retained tangent Gaussian. -/

open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section
namespace Paulsen

theorem tangentLift_horizontal_mul_apply {n d : ℕ} (U : Frame n d)
    (i j r : Fin n) (b : Fin d) :
    (tangentLiftMatrix U * horizontalProjectionMatrix U) (i,j) (r,b) =
      frameComplementProjection U i r * U j b + frameComplementProjection U j r * U i b := by
  simp only [Matrix.mul_apply, tangentLiftMatrix, Matrix.of_apply,
    horizontalProjectionMatrix, Matrix.kronecker, Matrix.kronecker_apply, Fintype.sum_prod_type,
    Matrix.one_apply, add_mul, Finset.sum_add_distrib, ite_mul, zero_mul,
    mul_ite, mul_zero]
  simp only [Finset.sum_ite_irrel, Finset.sum_const_zero, Finset.sum_ite_eq, Finset.sum_ite_eq',
    Finset.mem_univ, if_true]
  ring

theorem tangentLift_horizontal_covariance_apply {n d : ℕ} (U : Frame n d)
    (i j k l : Fin n) :
    (tangentLiftMatrix U * horizontalProjectionMatrix U * (tangentLiftMatrix U).transpose)
        (i,j) (k,l) =
      frameComplementProjection U i k * frameProjection U j l +
      frameComplementProjection U i l * frameProjection U j k +
      frameComplementProjection U j k * frameProjection U i l +
      frameComplementProjection U j l * frameProjection U i k := by
  change (∑ p : Fin n × Fin d, (tangentLiftMatrix U * horizontalProjectionMatrix U) (i,j) p *
    tangentLiftMatrix U (k,l) p) = _
  rw [Fintype.sum_prod_type]
  simp_rw [tangentLift_horizontal_mul_apply]
  simp only [tangentLiftMatrix, Matrix.of_apply, mul_add, add_mul, Finset.sum_add_distrib,
    mul_ite, mul_zero]
  simp only [Finset.sum_ite_irrel, Finset.sum_const_zero, Finset.sum_ite_eq,
    Finset.mem_univ, if_true]
  simp only [frameProjection, Matrix.mul_apply, Matrix.transpose_apply, Finset.mul_sum,
    mul_assoc]
  simp only [Finset.sum_add_distrib, mul_comm, mul_assoc]
  ring

theorem unconditionedTangent_entry_variance_offDiagonal {n d : ℕ} (U : Frame n d)
    (i j : Fin n) (hij : i≠j) :
    (1/(n:ℝ)) * (tangentLiftMatrix U * horizontalProjectionMatrix U *
      (tangentLiftMatrix U).transpose) (i,j) (i,j) =
    (rowNormSq U i + rowNormSq U j - 2*rowNormSq U i*rowNormSq U j -
      2*(frameProjection U i j)^2)/(n:ℝ) := by
  rw [tangentLift_horizontal_covariance_apply]
  simp only [frameComplementProjection, Matrix.sub_apply, Matrix.one_apply,
    if_true, if_neg hij, if_neg hij.symm, frameProjection_diagonal,
    frameProjection_symm U j i]
  ring

def tangentCovarianceEntry {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ →ₗ[ℝ] ℝ where
  toFun C := (tangentLiftMatrix U * C * (tangentLiftMatrix U).transpose) (i,j) (i,j)
  map_add' C D := by simp only [Matrix.mul_add, Matrix.add_mul, Matrix.add_apply]
  map_smul' c C := by simp only [Matrix.mul_smul, Matrix.smul_mul, Matrix.smul_apply, smul_eq_mul,
    RingHom.id_apply]

def tangentCovarianceGraph {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ →ₗ[ℝ] ℝ :=
  (1/2:ℝ) • ∑ i, ∑ j, (x i-x j)^2 • tangentCovarianceEntry U i j

theorem tangentCovarianceGraph_eq {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ)
    (C : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) :
    tangentCovarianceGraph U x C = graphEnergy (Matrix.of fun i j => tangentCovarianceEntry U i j C) x := by
  simp only [tangentCovarianceGraph, LinearMap.smul_apply, LinearMap.sum_apply, smul_eq_mul,
    graphEnergy, Matrix.of_apply]
  congr 1
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem tangentCovarianceGraph_nonneg {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ)
    (C : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) (hC : C.PosSemidef) :
    0≤tangentCovarianceGraph U x C := by
  rw [tangentCovarianceGraph_eq]
  apply mul_nonneg (by norm_num : (0:ℝ)≤1/2)
  apply Finset.sum_nonneg
  intro i _
  apply Finset.sum_nonneg
  intro j _
  apply mul_nonneg _ (sq_nonneg _)
  change 0≤(tangentLiftMatrix U * C * (tangentLiftMatrix U).transpose) (i,j) (i,j)
  have h := hC.mul_mul_conjTranspose_same (tangentLiftMatrix U)
  simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using h.diag_nonneg (i := (i,j))

theorem tangentCovarianceEntry_outer {n d : ℕ} (U H : Frame n d) (i j : Fin n) :
    tangentCovarianceEntry U i j (Matrix.vecMulVec (fun p => H p.1 p.2) (fun p => H p.1 p.2)) =
      ((H*U.transpose+U*H.transpose) i j)^2 := by
  change (tangentLiftMatrix U * Matrix.vecMulVec (fun p : Fin n × Fin d => H p.1 p.2)
    (fun p : Fin n × Fin d => H p.1 p.2) * (tangentLiftMatrix U).transpose) (i,j) (i,j) = _
  rw [matrix_outer_conjugation, Matrix.vecMulVec_apply, tangentLiftMatrix_mulVec]
  ring

theorem tangentCovarianceGraph_base {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ) :
    (1/(n:ℝ))*tangentCovarianceGraph U x (normalizedNormalCovariance U) =
      graphEnergy (baseNormalTangentVariance U) x := by
  rw [tangentCovarianceGraph_eq, ← graphEnergy_smul_eq]
  congr 1
  ext i j
  simp only [Matrix.smul_apply, Matrix.of_apply, smul_eq_mul, baseNormalTangentVariance,
    normalizedNormalCovariance_base_decomposition, map_sum, tangentCovarianceEntry_outer,
    baseNormalTangent]

theorem tangentCovarianceGraph_positive {n d : ℕ} (U : Frame n d) (ρ : ℝ) (x : Fin n → ℝ) :
    (1/(n:ℝ))*tangentCovarianceGraph U x (normalizedPositiveResidual U ρ) =
      graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x := by
  rw [tangentCovarianceGraph_eq, ← graphEnergy_smul_eq]
  rfl


variable {κ : Type*} [Fintype κ] [DecidableEq κ]

theorem integral_sq_gaussianCoordinate_eq_covariance {n d : ℕ}
    (C : Matrix (Fin n × Fin d) κ ℝ) (p : Fin n × Fin d) :
    (∫ g, (Matrix.toEuclideanLin C g p)^2 ∂stdGaussian (EuclideanSpace ℝ κ)) =
      (C*C.transpose) p p := by
  have hc : gaussianCoordinate C p = innerSL ℝ (WithLp.toLp 2 (fun s => C p s)) := by
    ext g
    simp only [gaussianCoordinate_apply, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct,
      innerSL_apply_apply, PiLp.inner_apply, Real.inner_apply]
  change (∫ g, (gaussianCoordinate C p g)^2 ∂_) = _
  rw [integral_sq_dual_stdGaussian, hc, innerSL_apply_norm, EuclideanSpace.real_norm_sq_eq]
  simp only [Matrix.mul_apply, Matrix.transpose_apply, pow_two]

theorem integral_gaussianImage_graphEnergy_eq_covariance {n : ℕ}
    (C : Matrix (Fin n × Fin n) κ ℝ) (x : Fin n → ℝ) :
    (∫ g, graphEnergy (Matrix.of fun i j => (Matrix.toEuclideanLin C g (i,j))^2) x
      ∂stdGaussian (EuclideanSpace ℝ κ)) =
      graphEnergy (Matrix.of fun i j => (C*C.transpose) (i,j) (i,j)) x := by
  simp only [graphEnergy, Matrix.of_apply]
  rw [integral_const_mul, integral_finsetSum]
  · congr 1
    apply Finset.sum_congr rfl
    intro i _
    rw [integral_finsetSum]
    · apply Finset.sum_congr rfl
      intro j _
      rw [integral_mul_const, integral_sq_gaussianCoordinate_eq_covariance]
    · intro j _
      exact ((memLp_sq_gaussianCoordinate C (i,j)).integrable (by norm_num)).mul_const _
  · intro i _
    exact integrable_finsetSum _ (fun j _ =>
      ((memLp_sq_gaussianCoordinate C (i,j)).integrable (by norm_num)).mul_const _)


def unconditionedTangentFactor {n d : ℕ} (U : Frame n d) :
    Matrix (Fin n × Fin n) (Fin n × Fin d) ℝ :=
  (Real.sqrt (n:ℝ))⁻¹ • (tangentLiftMatrix U * horizontalProjectionMatrix U)

theorem unconditionedTangentFactor_covariance {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) :
    unconditionedTangentFactor U * (unconditionedTangentFactor U).transpose =
      (1/(n:ℝ)) • (tangentLiftMatrix U * horizontalProjectionMatrix U * (tangentLiftMatrix U).transpose) := by
  simp only [unconditionedTangentFactor, Matrix.transpose_smul, Matrix.transpose_mul,
    horizontalProjectionMatrix_transpose, Matrix.smul_mul, Matrix.mul_smul, smul_smul]
  have he : (tangentLiftMatrix U * horizontalProjectionMatrix U) *
      (horizontalProjectionMatrix U * (tangentLiftMatrix U).transpose) =
      tangentLiftMatrix U * horizontalProjectionMatrix U * (tangentLiftMatrix U).transpose := by
    calc
      _ = tangentLiftMatrix U * (horizontalProjectionMatrix U * horizontalProjectionMatrix U) *
        (tangentLiftMatrix U).transpose := by simp only [Matrix.mul_assoc]
      _ = _ := by rw [horizontalProjectionMatrix_idempotent hU]
  rw [he]
  congr 1
  rw [← pow_two, inv_pow, Real.sq_sqrt (Nat.cast_nonneg n), one_div]

theorem integral_sq_unconditionedTangent_offDiagonal {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i j : Fin n) (hij : i≠j) :
    (∫ g, (Matrix.toEuclideanLin (unconditionedTangentFactor U) g (i,j))^2
      ∂stdGaussian (FrameVector n d)) =
      (rowNormSq U i+rowNormSq U j-2*rowNormSq U i*rowNormSq U j-
        2*(frameProjection U i j)^2)/(n:ℝ) := by
  rw [integral_sq_gaussianCoordinate_eq_covariance, unconditionedTangentFactor_covariance hU]
  exact unconditionedTangent_entry_variance_offDiagonal U i j hij

theorem retainedTangentFactor_covariance {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) :
    retainedTangentFactor U ρ * (retainedTangentFactor U ρ).transpose =
      (1/(n:ℝ)) • (tangentLiftMatrix U * retainedHorizontalProjection U ρ * (tangentLiftMatrix U).transpose) := by
  unfold retainedTangentFactor
  rw [Matrix.transpose_mul]
  calc
    _ = tangentLiftMatrix U *
        (normalizedTangentNoiseFactor U ρ * (normalizedTangentNoiseFactor U ρ).transpose) *
          (tangentLiftMatrix U).transpose := by simp only [Matrix.mul_assoc]
    _ = _ := by rw [normalizedTangentNoiseFactor_covariance hU hρ, Matrix.mul_smul, Matrix.smul_mul]

theorem integral_retainedTangent_graphEnergy_eq {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) (x : Fin n → ℝ) :
    (∫ g, graphEnergy (Matrix.of fun i j =>
      (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j))^2) x
      ∂stdGaussian (FrameVector n d)) =
      (1/(n:ℝ))*tangentCovarianceGraph U x (retainedHorizontalProjection U ρ) := by
  rw [integral_gaussianImage_graphEnergy_eq_covariance, retainedTangentFactor_covariance hU hρ,
    tangentCovarianceGraph_eq, ← graphEnergy_smul_eq]
  rfl

/-- The negative residual contributes a nonnegative graph, so only the base
and positive residual need to be paid for in the expansion bound. -/
theorem integral_retainedTangent_graphEnergy_lower {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0≤ρ) (x : Fin n → ℝ) :
    (1/(n:ℝ))*tangentCovarianceGraph U x (horizontalProjectionMatrix U) -
      graphEnergy (baseNormalTangentVariance U) x -
      graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x ≤
    (∫ g, graphEnergy (Matrix.of fun i j =>
      (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,j))^2) x
      ∂stdGaussian (FrameVector n d)) := by
  rw [integral_retainedTangent_graphEnergy_eq hU hρ, retainedHorizontalProjection,
    normalizedHighProjection_decomposition, map_sub, map_sub, map_add,
    ← tangentCovarianceGraph_base, ← tangentCovarianceGraph_positive]
  have hn := tangentCovarianceGraph_nonneg U x (normalizedNegativeResidual U ρ)
    (normalizedNegativeResidual_posSemidef U ρ)
  have hh := mul_nonneg (show (0:ℝ)≤1/(n:ℝ) by positivity) hn
  nlinarith only [hh]

end Paulsen
