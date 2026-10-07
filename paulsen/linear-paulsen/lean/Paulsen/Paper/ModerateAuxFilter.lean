import Paulsen.Paper.ModerateAuxLin
import Paulsen.ResolventRationalCovariance
import Paulsen.ResolventDrift

/-!
# Helpers for `Paulsen.Paper.Moderate`: rational calculus of the filter

With `N = N̄` the normalized normal map, `S = NᵀN` and `Ω = NNᵀ`:
* push-through: `(ρI+S)⁻¹ Nᵀ = Nᵀ (ρI+Ω)⁻¹`;
* `Nᵀ C_ρ N = ρ S (ρI+S)⁻¹` for `C_ρ = ρI_𝒵(ρI+Ω)⁻¹`;
* `ρ S(ρI+S)⁻¹ ⪯ ρ I`;
* the spectral identity `∑_y ((1-μ)/(ρ+μ)) y yᵀ = (I-S)(ρI+S)⁻¹`.
-/

namespace Paulsen.Paper.ModerateAux

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

variable {n d : ℕ}

theorem normalizedNormalCovariance_posSemidef' (U : Frame n d) :
    (normalizedNormalCovariance U).PosSemidef := by
  simpa only [normalizedNormalCovariance, Matrix.conjTranspose_eq_transpose_of_trivial] using
    Matrix.posSemidef_self_mul_conjTranspose (normalizedNormalMapMatrix U)

theorem resolventZ_posDef (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    (ρ • (1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) + normalizedNormalCovariance U).PosDef :=
  (Matrix.PosDef.one.smul hρ).add_posSemidef (normalizedNormalCovariance_posSemidef' U)

theorem resolventS_posDef (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    (ρ • (1 : Matrix (Fin n) (Fin n) ℝ) + normalizedFisher U).PosDef :=
  (Matrix.PosDef.one.smul hρ).add_posSemidef (normalizedFisher_posSemidef U)

theorem resolventZ_isUnit (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    IsUnit (ρ • (1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) +
      normalizedNormalCovariance U).det :=
  isUnit_iff_ne_zero.mpr (resolventZ_posDef U hρ).det_pos.ne'

theorem resolventS_isUnit (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    IsUnit (ρ • (1 : Matrix (Fin n) (Fin n) ℝ) + normalizedFisher U).det :=
  isUnit_iff_ne_zero.mpr (resolventS_posDef U hρ).det_pos.ne'

theorem normalMap_transpose_resolvent (U : Frame n d) (ρ : ℝ) :
    (normalizedNormalMapMatrix U).transpose * (ρ • 1 + normalizedNormalCovariance U) =
      (ρ • 1 + normalizedFisher U) * (normalizedNormalMapMatrix U).transpose := by
  simp only [normalizedNormalCovariance, normalizedFisher, Matrix.mul_add, Matrix.add_mul,
    Matrix.mul_smul, Matrix.smul_mul, Matrix.mul_one, Matrix.one_mul, Matrix.mul_assoc]

/-- Push-through identity `(ρI+S)⁻¹ Nᵀ = Nᵀ (ρI+Ω)⁻¹`. -/
theorem resolvent_pushthrough (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    (ρ • 1 + normalizedFisher U)⁻¹ * (normalizedNormalMapMatrix U).transpose =
      (normalizedNormalMapMatrix U).transpose * (ρ • 1 + normalizedNormalCovariance U)⁻¹ := by
  set N := normalizedNormalMapMatrix U
  set A := ρ • (1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) + normalizedNormalCovariance U
  set B := ρ • (1 : Matrix (Fin n) (Fin n) ℝ) + normalizedFisher U
  have hA : A * A⁻¹ = 1 := Matrix.mul_nonsing_inv _ (resolventZ_isUnit U hρ)
  have hB : B⁻¹ * B = 1 := Matrix.nonsing_inv_mul _ (resolventS_isUnit U hρ)
  calc B⁻¹ * N.transpose = B⁻¹ * N.transpose * (A * A⁻¹) := by rw [hA, Matrix.mul_one]
    _ = B⁻¹ * (N.transpose * A) * A⁻¹ := by simp only [Matrix.mul_assoc]
    _ = B⁻¹ * (B * N.transpose) * A⁻¹ := by rw [normalMap_transpose_resolvent]
    _ = N.transpose * A⁻¹ := by rw [← Matrix.mul_assoc B⁻¹, hB, Matrix.one_mul]

theorem resolventS_inv_comm (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    (ρ • 1 + normalizedFisher U)⁻¹ * normalizedFisher U =
      normalizedFisher U * (ρ • 1 + normalizedFisher U)⁻¹ := by
  set B := ρ • (1 : Matrix (Fin n) (Fin n) ℝ) + normalizedFisher U
  have hB : B⁻¹ * B = 1 := Matrix.nonsing_inv_mul _ (resolventS_isUnit U hρ)
  have hB' : B * B⁻¹ = 1 := Matrix.mul_nonsing_inv _ (resolventS_isUnit U hρ)
  have hS : normalizedFisher U = B - ρ • 1 := by simp [B]
  rw [hS, Matrix.mul_sub, Matrix.sub_mul, hB, hB', Matrix.mul_smul, Matrix.smul_mul,
    Matrix.mul_one, Matrix.one_mul]

/-- `Nᵀ C_ρ N = ρ S (ρI+S)⁻¹`. -/
theorem filtered_compress {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 < ρ) :
    (normalizedNormalMapMatrix U).transpose *
        (ρ • (horizontalProjectionMatrix U *
          (ρ • 1 + normalizedNormalCovariance U)⁻¹)) * normalizedNormalMapMatrix U =
      ρ • (normalizedFisher U * (ρ • 1 + normalizedFisher U)⁻¹) := by
  have hNI : (normalizedNormalMapMatrix U).transpose * horizontalProjectionMatrix U =
      (normalizedNormalMapMatrix U).transpose := by
    have h := congrArg Matrix.transpose (horizontalProjectionMatrix_normalizedNormalMap hU)
    rwa [Matrix.transpose_mul, horizontalProjectionMatrix_transpose] at h
  simp only [Matrix.mul_smul, Matrix.smul_mul]
  congr 1
  rw [← Matrix.mul_assoc (normalizedNormalMapMatrix U).transpose, hNI,
    ← resolvent_pushthrough U hρ, Matrix.mul_assoc]
  change (ρ • 1 + normalizedFisher U)⁻¹ * normalizedFisher U = _
  exact resolventS_inv_comm U hρ

theorem normalizedFisher_transpose (U : Frame n d) :
    (normalizedFisher U).transpose = normalizedFisher U := by
  simp [normalizedFisher, Matrix.transpose_mul]

/-- `ρ S(ρI+S)⁻¹ ⪯ ρ I`. -/
theorem rational_quadratic_le (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) (y : Fin n → ℝ) :
    matrixQuadratic (ρ • (normalizedFisher U * (ρ • 1 + normalizedFisher U)⁻¹)) y ≤
      ρ * ∑ i, y i ^ 2 := by
  set S := normalizedFisher U
  set B := ρ • (1 : Matrix (Fin n) (Fin n) ℝ) + S
  have hB' : B * B⁻¹ = 1 := Matrix.mul_nonsing_inv _ (resolventS_isUnit U hρ)
  set a := B⁻¹ *ᵥ y
  set b := S *ᵥ a
  have hy : y = ρ • a + b := by
    have : y = B *ᵥ a := by simp only [a, Matrix.mulVec_mulVec, hB', Matrix.one_mulVec]
    rw [this]
    simp only [B, Matrix.add_mulVec, Matrix.smul_mulVec, Matrix.one_mulVec, b]
  have hab : 0 ≤ a ⬝ᵥ b := by
    simpa only [star_trivial] using (normalizedFisher_posSemidef U).dotProduct_mulVec_nonneg a
  have haa : 0 ≤ a ⬝ᵥ a := by rw [dot_self_eq]; positivity
  have hval : matrixQuadratic (ρ • (S * B⁻¹)) y = ρ * (y ⬝ᵥ b) := by
    rw [mq_eq_dot, Matrix.smul_mulVec, dotProduct_smul, smul_eq_mul]
    congr 1
    rw [← Matrix.mulVec_mulVec]
  rw [hval, ← dot_self_eq y, hy]
  simp only [add_dotProduct, dotProduct_add, smul_dotProduct, dotProduct_smul, smul_eq_mul]
  rw [dotProduct_comm b a]
  have h1 : 0 ≤ ρ * (ρ * (ρ * (a ⬝ᵥ a))) := by positivity
  have h2 : 0 ≤ ρ * (ρ * (a ⬝ᵥ b)) := by positivity
  nlinarith

/-- Two matrices agreeing on an orthonormal basis are equal. -/
theorem matrix_eq_of_mulVec_onb {ι : Type*} [Fintype ι] [DecidableEq ι] (X Y : Matrix ι ι ℝ)
    (b : OrthonormalBasis ι ℝ (EuclideanSpace ℝ ι))
    (h : ∀ j, X *ᵥ (b j).ofLp = Y *ᵥ (b j).ofLp) : X = Y := by
  apply (Matrix.toEuclideanLin (𝕜 := ℝ) (m := ι) (n := ι)).injective
  apply b.toBasis.ext
  intro j
  rw [OrthonormalBasis.coe_toBasis]
  simp only [Matrix.toLpLin_apply, h j]

theorem eigvec_dot (U : Frame n d) (k j : Fin n) :
    (normalizedFisherEigenvector U k).ofLp ⬝ᵥ (normalizedFisherEigenvector U j).ofLp =
      if k = j then 1 else 0 := by
  have h := (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis.inner_eq_ite j k
  rw [EuclideanSpace.inner_eq_star_dotProduct] at h
  simp only [star_trivial] at h
  change (normalizedFisherEigenvector U k).ofLp ⬝ᵥ (normalizedFisherEigenvector U j).ofLp =
    if j = k then 1 else 0 at h
  rw [h]
  by_cases hjk : j = k
  · simp [hjk]
  · simp [hjk, Ne.symm hjk]

theorem fisher_mulVec_eigvec (U : Frame n d) (j : Fin n) :
    normalizedFisher U *ᵥ (normalizedFisherEigenvector U j).ofLp =
      normalizedFisherEigenvalue U j • (normalizedFisherEigenvector U j).ofLp :=
  (normalizedFisher_posSemidef U).isHermitian.mulVec_eigenvectorBasis j

/-- The spectral identity `∑_y ((1-μ)/(ρ+μ)) y yᵀ = (I-S)(ρI+S)⁻¹`. -/
theorem spectral_rational (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    ∑ k, ((1 - normalizedFisherEigenvalue U k) / (ρ + normalizedFisherEigenvalue U k)) •
        Matrix.vecMulVec (normalizedFisherEigenvector U k).ofLp
          (normalizedFisherEigenvector U k).ofLp =
      (1 - normalizedFisher U) * (ρ • 1 + normalizedFisher U)⁻¹ := by
  set S := normalizedFisher U
  set B := ρ • (1 : Matrix (Fin n) (Fin n) ℝ) + S
  have hB : B⁻¹ * B = 1 := Matrix.nonsing_inv_mul _ (resolventS_isUnit U hρ)
  apply matrix_eq_of_mulVec_onb _ _ (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis
  intro j
  change _ *ᵥ (normalizedFisherEigenvector U j).ofLp = _ *ᵥ (normalizedFisherEigenvector U j).ofLp
  have hpos : 0 < ρ + normalizedFisherEigenvalue U j := by
    have := normalizedFisherEigenvalue_nonneg U j; linarith
  have hBy : B *ᵥ (normalizedFisherEigenvector U j).ofLp =
      (ρ + normalizedFisherEigenvalue U j) • (normalizedFisherEigenvector U j).ofLp := by
    simp only [B, Matrix.add_mulVec, Matrix.smul_mulVec, Matrix.one_mulVec, S,
      fisher_mulVec_eigvec, add_smul]
  have hBinv : B⁻¹ *ᵥ (normalizedFisherEigenvector U j).ofLp =
      (ρ + normalizedFisherEigenvalue U j)⁻¹ • (normalizedFisherEigenvector U j).ofLp := by
    have h1 : B⁻¹ *ᵥ (B *ᵥ (normalizedFisherEigenvector U j).ofLp) =
        (normalizedFisherEigenvector U j).ofLp := by
      rw [Matrix.mulVec_mulVec, hB, Matrix.one_mulVec]
    rw [hBy, Matrix.mulVec_smul] at h1
    calc B⁻¹ *ᵥ (normalizedFisherEigenvector U j).ofLp
        = (ρ + normalizedFisherEigenvalue U j)⁻¹ • ((ρ + normalizedFisherEigenvalue U j) •
            B⁻¹ *ᵥ (normalizedFisherEigenvector U j).ofLp) := by
          rw [smul_smul, inv_mul_cancel₀ hpos.ne', one_smul]
      _ = _ := by rw [h1]
  rw [Matrix.sum_mulVec, Finset.sum_eq_single j]
  · rw [Matrix.smul_mulVec, Matrix.vecMulVec_mulVec, eigvec_dot, if_pos rfl, op_smul_eq_smul,
      one_smul, ← Matrix.mulVec_mulVec, hBinv, Matrix.mulVec_smul, Matrix.sub_mulVec,
      Matrix.one_mulVec, fisher_mulVec_eigvec, smul_sub, smul_smul, ← sub_smul]
    congr 1
    field_simp
  · intro k _ hk
    rw [Matrix.smul_mulVec, Matrix.vecMulVec_mulVec, eigvec_dot, if_neg hk]
    simp
  · simp

end

end Paulsen.Paper.ModerateAux
