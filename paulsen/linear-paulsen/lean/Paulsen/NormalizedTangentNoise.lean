import Paulsen.NormalizedTruncation
import Paulsen.GaussianLinearImage
import Mathlib.LinearAlgebra.Matrix.Kronecker
import Mathlib.Analysis.CStarAlgebra.Matrix

/-!
# The actual horizontal Gaussian noise projection

The ambient matrix space is vectorized by row/column pairs. Left multiplication
by `Q = I-UUᵀ` is `Q ⊗ I`; subtracting the high-normal projection gives the
actual retained horizontal covariance.
-/

open Matrix
open scoped BigOperators

noncomputable section

namespace Paulsen

def horizontalProjectionMatrix {n d : ℕ} (U : Frame n d) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.kronecker (frameComplementProjection U) (1 : Matrix (Fin d) (Fin d) ℝ)

theorem horizontalProjectionMatrix_transpose {n d : ℕ} (U : Frame n d) :
    (horizontalProjectionMatrix U).transpose = horizontalProjectionMatrix U := by
  simp only [horizontalProjectionMatrix, Matrix.kronecker, ← Matrix.kroneckerMap_transpose,
    Matrix.transpose_one, frameComplementProjection_transpose]

theorem horizontalProjectionMatrix_idempotent {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    horizontalProjectionMatrix U * horizontalProjectionMatrix U = horizontalProjectionMatrix U := by
  simp only [horizontalProjectionMatrix, Matrix.kronecker, ← Matrix.mul_kronecker_mul,
    hU.frameComplementProjection_idempotent, Matrix.one_mul]

theorem horizontalProjectionMatrix_posSemidef {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    (horizontalProjectionMatrix U).PosSemidef := by
  have hQ : (frameComplementProjection U).PosSemidef := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial, frameComplementProjection_transpose,
      hU.frameComplementProjection_idempotent] using
      Matrix.posSemidef_self_mul_conjTranspose (frameComplementProjection U)
  exact hQ.kronecker Matrix.PosSemidef.one

/-- The vectorized projection is exactly left multiplication by `Q`. -/
theorem horizontalProjectionMatrix_mulVec {n d : ℕ} (U : Frame n d)
    (z : Fin n × Fin d → ℝ) (i : Fin n) (a : Fin d) :
    (horizontalProjectionMatrix U *ᵥ z) (i, a) =
      (frameComplementProjection U * Matrix.of (fun r b => z (r, b))) i a := by
  simp only [horizontalProjectionMatrix, Matrix.kronecker, Matrix.mulVec, dotProduct, Matrix.kronecker_apply,
    Fintype.sum_prod_type, Matrix.one_apply, Matrix.mul_apply, Matrix.of_apply]
  apply Finset.sum_congr rfl
  intro r _
  simp

theorem horizontalProjectionMatrix_normalMap {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    horizontalProjectionMatrix U * normalMapMatrix U = normalMapMatrix U := by
  ext p i
  rcases p with ⟨r, a⟩
  change (horizontalProjectionMatrix U *ᵥ (fun p => normalMapMatrix U p i)) (r, a) = _
  rw [horizontalProjectionMatrix_mulVec]
  simp only [Matrix.mul_apply, normalMapMatrix, Matrix.of_apply, ← mul_assoc, ← Finset.sum_mul]
  change (frameComplementProjection U * frameComplementProjection U) r i * U i a = _
  rw [hU.frameComplementProjection_idempotent]

theorem horizontalProjectionMatrix_normalizedNormalMap {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) :
    horizontalProjectionMatrix U * normalizedNormalMapMatrix U = normalizedNormalMapMatrix U := by
  rw [normalizedNormalMapMatrix, ← Matrix.mul_assoc, horizontalProjectionMatrix_normalMap hU]

theorem horizontalProjectionMatrix_normalDirection {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) :
    horizontalProjectionMatrix U *ᵥ (fun p => normalizedNormalDirection U i p) =
      fun p => normalizedNormalDirection U i p := by
  have hK := horizontalProjectionMatrix_normalizedNormalMap hU
  change horizontalProjectionMatrix U *ᵥ
    ((Real.sqrt (normalizedFisherEigenvalue U i))⁻¹ •
      (normalizedNormalMapMatrix U *ᵥ (fun j => normalizedFisherEigenvector U i j))) = _
  rw [Matrix.mulVec_smul, Matrix.mulVec_mulVec, hK]
  rfl

theorem horizontalProjectionMatrix_highProjection {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) :
    horizontalProjectionMatrix U * normalizedHighProjection U ρ = normalizedHighProjection U ρ := by
  rw [normalizedHighProjection, Matrix.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [normalDirectionOuter, Matrix.mul_vecMulVec, horizontalProjectionMatrix_normalDirection hU]

theorem highProjection_horizontalProjectionMatrix {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) :
    normalizedHighProjection U ρ * horizontalProjectionMatrix U = normalizedHighProjection U ρ := by
  have h := congrArg Matrix.transpose (horizontalProjectionMatrix_highProjection hU ρ)
  have he : (normalizedHighProjection U ρ).transpose = normalizedHighProjection U ρ := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      (normalizedHighProjection_posSemidef U ρ).isHermitian.eq
  simpa only [Matrix.transpose_mul, horizontalProjectionMatrix_transpose, he] using h

def retainedHorizontalProjection {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  horizontalProjectionMatrix U - normalizedHighProjection U ρ

theorem retainedHorizontalProjection_transpose {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (retainedHorizontalProjection U ρ).transpose = retainedHorizontalProjection U ρ := by
  have he : (normalizedHighProjection U ρ).transpose = normalizedHighProjection U ρ := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      (normalizedHighProjection_posSemidef U ρ).isHermitian.eq
  simp only [retainedHorizontalProjection, Matrix.transpose_sub, horizontalProjectionMatrix_transpose, he]

theorem retainedHorizontalProjection_idempotent {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    retainedHorizontalProjection U ρ * retainedHorizontalProjection U ρ = retainedHorizontalProjection U ρ := by
  simp only [retainedHorizontalProjection, Matrix.sub_mul, Matrix.mul_sub,
    horizontalProjectionMatrix_idempotent hU, normalizedHighProjection_idempotent U hρ,
    horizontalProjectionMatrix_highProjection hU, highProjection_horizontalProjectionMatrix hU]
  abel

theorem retainedHorizontalProjection_posSemidef {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (retainedHorizontalProjection U ρ).PosSemidef := by
  simpa only [Matrix.conjTranspose_eq_transpose_of_trivial, retainedHorizontalProjection_transpose,
    retainedHorizontalProjection_idempotent hU hρ] using
    Matrix.posSemidef_self_mul_conjTranspose (retainedHorizontalProjection U ρ)

/-- The complement projection annihilates the original frame on the left. -/
theorem IsParseval.transpose_mul_frameComplementProjection {n d : ℕ}
    {U : Frame n d} (hU : IsParseval U) :
    U.transpose * frameComplementProjection U = 0 := by
  unfold frameComplementProjection frameProjection
  rw [Matrix.mul_sub, Matrix.mul_one, ← Matrix.mul_assoc, hU, Matrix.one_mul, sub_self]

theorem horizontalProjectionMatrix_retained {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) :
    horizontalProjectionMatrix U * retainedHorizontalProjection U ρ =
      retainedHorizontalProjection U ρ := by
  rw [retainedHorizontalProjection, Matrix.mul_sub,
    horizontalProjectionMatrix_idempotent hU, horizontalProjectionMatrix_highProjection hU]

/-- Every retained ambient vector is an actual horizontal tangent matrix. -/
theorem retainedHorizontalProjection_horizontal {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) (z : Fin n × Fin d → ℝ) :
    U.transpose * Matrix.of (fun i a => (retainedHorizontalProjection U ρ *ᵥ z) (i, a)) = 0 := by
  have hK := congrArg (fun M => M *ᵥ z) (horizontalProjectionMatrix_retained hU ρ)
  rw [← Matrix.mulVec_mulVec] at hK
  have hmat : Matrix.of (fun i a => (retainedHorizontalProjection U ρ *ᵥ z) (i, a)) =
      frameComplementProjection U *
        Matrix.of (fun i a => (retainedHorizontalProjection U ρ *ᵥ z) (i, a)) := by
    ext i a
    exact (congrFun hK (i, a)).symm.trans (horizontalProjectionMatrix_mulVec U _ i a)
  conv_lhs => rw [hmat]
  rw [← Matrix.mul_assoc, hU.transpose_mul_frameComplementProjection, Matrix.zero_mul]

/-- The explicit covariance factor applied to a standard ambient Gaussian. -/
def normalizedTangentNoiseFactor {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  (Real.sqrt (n : ℝ))⁻¹ • retainedHorizontalProjection U ρ

theorem normalizedTangentNoiseFactor_covariance {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    normalizedTangentNoiseFactor U ρ * (normalizedTangentNoiseFactor U ρ).transpose =
      (1 / (n : ℝ)) • retainedHorizontalProjection U ρ := by
  simp only [normalizedTangentNoiseFactor, Matrix.transpose_smul,
    retainedHorizontalProjection_transpose, Matrix.smul_mul, Matrix.mul_smul, smul_smul,
    retainedHorizontalProjection_idempotent hU hρ]
  congr 1
  rw [← sq, inv_pow, Real.sq_sqrt (Nat.cast_nonneg n), one_div]

theorem normalizedTangentNoiseFactor_horizontal {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) (z : Fin n × Fin d → ℝ) :
    U.transpose * Matrix.of (fun i a => (normalizedTangentNoiseFactor U ρ *ᵥ z) (i, a)) = 0 := by
  have hm : Matrix.of (fun i a => (normalizedTangentNoiseFactor U ρ *ᵥ z) (i, a)) =
      (Real.sqrt (n : ℝ))⁻¹ •
        Matrix.of (fun i a => (retainedHorizontalProjection U ρ *ᵥ z) (i, a)) := by
    ext i a
    simp only [normalizedTangentNoiseFactor, Matrix.smul_mulVec, Matrix.of_apply,
      Pi.smul_apply, smul_eq_mul]
    rfl
  rw [hm, Matrix.mul_smul, retainedHorizontalProjection_horizontal hU, smul_zero]

open scoped Matrix.Norms.L2Operator in
/-- The retained projection is a contraction, including degenerate dimensions. -/
theorem retainedHorizontalProjection_operator_norm_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    ‖(Matrix.toEuclideanLin (retainedHorizontalProjection U ρ)).toContinuousLinearMap‖ ≤ 1 := by
  have hp : IsStarProjection (retainedHorizontalProjection U ρ) := by
    constructor
    · exact retainedHorizontalProjection_idempotent hU hρ
    · exact (retainedHorizontalProjection_posSemidef hU hρ).isHermitian
  change ‖retainedHorizontalProjection U ρ‖ ≤ 1
  exact IsStarProjection.norm_le _ hp

/-- The Gaussian covariance factor has squared operator norm at most `1/n`. -/
theorem normalizedTangentNoiseFactor_operator_norm_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    ‖(Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ)).toContinuousLinearMap‖ ^ 2 ≤
      1 / (n : ℝ) := by
  have hn := retainedHorizontalProjection_operator_norm_le hU hρ
  have heq : (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ)).toContinuousLinearMap =
      (Real.sqrt (n : ℝ))⁻¹ •
        (Matrix.toEuclideanLin (retainedHorizontalProjection U ρ)).toContinuousLinearMap := by
    ext x i
    simp only [normalizedTangentNoiseFactor, map_smul, LinearMap.coe_toContinuousLinearMap',
      _root_.smul_apply]
  rw [heq, norm_smul, Real.norm_eq_abs, abs_of_nonneg (inv_nonneg.mpr (Real.sqrt_nonneg _)), mul_pow]
  have hn2 : ‖(Matrix.toEuclideanLin (retainedHorizontalProjection U ρ)).toContinuousLinearMap‖ ^ 2 ≤ 1 := by
    nlinarith [norm_nonneg (Matrix.toEuclideanLin (retainedHorizontalProjection U ρ)).toContinuousLinearMap]
  calc
    _ ≤ (Real.sqrt (n : ℝ))⁻¹ ^ 2 * 1 := mul_le_mul_of_nonneg_left hn2 (sq_nonneg _)
    _ = _ := by rw [mul_one, inv_pow, Real.sq_sqrt (Nat.cast_nonneg n), one_div]

/-- The actual horizontal truncation has the same derivative covariance as the
ambient truncation, because the normal map takes values in the horizontal space. -/
theorem normal_retainedHorizontal_covariance {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (normalMapMatrix U).transpose * retainedHorizontalProjection U ρ * normalMapMatrix U =
      leverageRoot U * lowFisherCovariance U ρ * leverageRoot U := by
  rw [retainedHorizontalProjection, Matrix.mul_sub, Matrix.sub_mul]
  have hK : (normalMapMatrix U).transpose * horizontalProjectionMatrix U * normalMapMatrix U =
      (normalMapMatrix U).transpose * normalMapMatrix U := by
    rw [Matrix.mul_assoc, horizontalProjectionMatrix_normalMap hU]
  rw [hK]
  have h := normalTruncation_covariance U hp hρ
  simpa only [Matrix.mul_sub, Matrix.mul_one, Matrix.sub_mul] using h

/-- The covariance of the actual Gaussian diagonal derivative is bounded by
`ρ p_i / n` in every coordinate. -/
theorem normal_noise_covariance_diagonal_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    ((normalMapMatrix U).transpose *
      (normalizedTangentNoiseFactor U ρ * (normalizedTangentNoiseFactor U ρ).transpose) *
        normalMapMatrix U) i i ≤ ρ * rowNormSq U i / (n : ℝ) := by
  rw [normalizedTangentNoiseFactor_covariance hU hρ, Matrix.mul_smul, Matrix.smul_mul]
  have heq : (normalMapMatrix U).transpose * retainedHorizontalProjection U ρ * normalMapMatrix U =
      (normalMapMatrix U).transpose * (1 - normalizedHighProjection U ρ) * normalMapMatrix U := by
    rw [normal_retainedHorizontal_covariance hU hp hρ, normalTruncation_covariance U hp hρ]
  rw [heq]
  have hi := normalTruncation_covariance_diagonal_le U hp hρ i
  change (1 / (n : ℝ)) * _ ≤ _
  calc
    _ ≤ (1 / (n : ℝ)) * (ρ * rowNormSq U i) :=
      mul_le_mul_of_nonneg_left hi (by positivity)
    _ = _ := by ring

/-- Restrict the ambient covariance to a single matrix row. -/
def tangentNoiseRowCovariance {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) :
    Matrix (Fin d) (Fin d) ℝ :=
  (normalizedTangentNoiseFactor U ρ * (normalizedTangentNoiseFactor U ρ).transpose).submatrix
    (fun a => (i, a)) (fun a => (i, a))

theorem tangentNoiseRowCovariance_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    ((1 / (n : ℝ)) • (1 : Matrix (Fin d) (Fin d) ℝ) -
      tangentNoiseRowCovariance U ρ i).PosSemidef := by
  have he := (normalizedHighProjection_posSemidef U ρ).submatrix (fun a => (i, a))
  have hp : ((rowNormSq U i) • (1 : Matrix (Fin d) (Fin d) ℝ)).PosSemidef :=
    Matrix.PosSemidef.one.smul (rowNormSq_nonneg U i)
  have hid : (1 : Matrix (Fin d) (Fin d) ℝ) -
      (retainedHorizontalProjection U ρ).submatrix (fun a => (i, a)) (fun a => (i, a)) =
      (rowNormSq U i) • (1 : Matrix (Fin d) (Fin d) ℝ) +
        (normalizedHighProjection U ρ).submatrix (fun a => (i, a)) (fun a => (i, a)) := by
    ext a b
    simp only [retainedHorizontalProjection, Matrix.submatrix_apply, Matrix.sub_apply,
      horizontalProjectionMatrix, Matrix.kronecker, Matrix.kronecker_apply,
      frameComplementProjection, Matrix.sub_apply, Matrix.one_apply_eq,
      frameProjection_diagonal, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul]
    ring
  have heq : (1 / (n : ℝ)) • (1 : Matrix (Fin d) (Fin d) ℝ) -
      tangentNoiseRowCovariance U ρ i =
      (1 / (n : ℝ)) • ((1 : Matrix (Fin d) (Fin d) ℝ) -
        (retainedHorizontalProjection U ρ).submatrix (fun a => (i, a)) (fun a => (i, a))) := by
    unfold tangentNoiseRowCovariance
    rw [normalizedTangentNoiseFactor_covariance hU hρ]
    ext a b
    simp only [Matrix.sub_apply, Matrix.smul_apply, Matrix.submatrix_apply, smul_eq_mul]
    ring
  rw [heq, hid]
  exact (hp.add he).smul (by positivity)

theorem tangentNoiseRowCovariance_trace_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    (tangentNoiseRowCovariance U ρ i).trace ≤ (d : ℝ) / n := by
  have ht := (tangentNoiseRowCovariance_le hU hρ i).trace_nonneg
  simp only [Matrix.trace_sub, Matrix.trace_smul, Matrix.trace_one, Fintype.card_fin,
    smul_eq_mul] at ht
  calc
    _ ≤ 1 / (n : ℝ) * (d : ℝ) := sub_nonneg.mp ht
    _ = _ := by ring

end Paulsen
