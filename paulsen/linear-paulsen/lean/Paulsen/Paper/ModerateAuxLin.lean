import Paulsen.Paper.ModerateAuxLap

/-!
# Helpers for `Paulsen.Paper.Moderate`: linear algebra of the normal map

Row bounds for horizontal frames, the contraction `0 ⪯ Ω ⪯ I`, the second moment of a
linear Gaussian functional, and the push-through identities behind `lem:filter`(b).
-/

namespace Paulsen.Paper.ModerateAux

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- `‖A v‖² ≤ ‖A‖² ‖v‖²` written with coordinates. -/
theorem sum_sq_mulVec_le_opNorm {m k : Type*} [Fintype m] [Fintype k] [DecidableEq k]
    (A : Matrix m k ℝ) (v : k → ℝ) :
    ∑ j, (∑ l, A j l * v l) ^ 2 ≤
      ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ ^ 2 * ∑ l, v l ^ 2 := by
  have h := (Matrix.toEuclideanLin A).toContinuousLinearMap.le_opNorm (WithLp.toLp 2 v)
  have h2 := pow_le_pow_left₀ (norm_nonneg _) h 2
  rw [mul_pow, EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq] at h2
  simpa [Matrix.toLpLin_apply, Matrix.mulVec, dotProduct] using h2

theorem complement_mul_horizontal {n d : ℕ} {U H : Frame n d} (hUH : U.transpose * H = 0) :
    frameComplementProjection U * H = H := by
  simp [frameComplementProjection, Matrix.sub_mul, frameProjection, Matrix.mul_assoc, hUH]

/-- `‖Zᵀ v_i‖² ≤ ‖Z‖² (1 - p_i)`. -/
theorem rowNormSq_horizontal_le {n d : ℕ} {U H : Frame n d} (hU : IsParseval U)
    (hUH : U.transpose * H = 0) (i : Fin n) :
    rowNormSq H i ≤
      ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 * (1 - rowNormSq U i) := by
  have hQH := complement_mul_horizontal hUH
  have hrow : ∀ k, H i k = ∑ r, H.transpose k r * frameComplementProjection U i r := by
    intro k
    have := congrArg (fun M : Frame n d => M i k) hQH
    simp only [Matrix.mul_apply] at this
    rw [← this]
    apply Finset.sum_congr rfl; intro r _; simp [mul_comm]
  calc rowNormSq H i = ∑ k, (∑ r, H.transpose k r * frameComplementProjection U i r) ^ 2 := by
        simp only [rowNormSq]; exact Finset.sum_congr rfl (fun k _ => by rw [← hrow k])
    _ ≤ _ := sum_sq_mulVec_le_opNorm _ _
    _ = _ := by rw [euclidean_operator_norm_transpose, frameComplementProjection_row_squares hU]

/-- `‖Z u_i‖² ≤ ‖Z‖² p_i`. -/
theorem rowNormSq_mul_transpose_le_opNorm {n d : ℕ} (U H : Frame n d) (i : Fin n) :
    rowNormSq (U * H.transpose) i ≤
      ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ^ 2 * rowNormSq U i := by
  calc rowNormSq (U * H.transpose) i = ∑ j, (∑ k, H j k * U i k) ^ 2 := by
        simp only [rowNormSq, Matrix.mul_apply, Matrix.transpose_apply]
        apply Finset.sum_congr rfl; intro j _; congr 1
        apply Finset.sum_congr rfl; intro k _; ring
    _ ≤ _ := sum_sq_mulVec_le_opNorm _ _
    _ = _ := rfl

theorem mq_one {ι : Type*} [Fintype ι] [DecidableEq ι] (x : ι → ℝ) :
    matrixQuadratic (1 : Matrix ι ι ℝ) x = ∑ i, x i ^ 2 := by
  rw [← Matrix.diagonal_one, matrixQuadratic_diagonal]; simp

theorem mq_nonneg_of_posSemidef {ι : Type*} [Fintype ι] (A : Matrix ι ι ℝ)
    (hA : A.PosSemidef) (x : ι → ℝ) : 0 ≤ matrixQuadratic A x := by
  simpa only [matrixQuadratic, Matrix.mulVec, dotProduct, Finset.mul_sum, mul_assoc,
    star_trivial] using hA.dotProduct_mulVec_nonneg x

theorem one_sub_normalizedFisher {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) : 1 - normalizedFisher U = normalizedOverlap U := by
  rw [← normalizedFisher_add_overlap hU hp]; abel

theorem normalizedFisher_quadratic_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) (x : Fin n → ℝ) :
    matrixQuadratic (normalizedFisher U) x ≤ ∑ i, x i ^ 2 := by
  have h1 := mq_nonneg_of_posSemidef _ (normalizedOverlap_posSemidef U) x
  rw [← one_sub_normalizedFisher hU hp, matrixQuadratic_sub, mq_one] at h1
  linarith

theorem dot_self_eq {ι : Type*} [Fintype ι] (v : ι → ℝ) : v ⬝ᵥ v = ∑ i, v i ^ 2 := by
  simp [dotProduct, sq]

/-- `Ω ⪯ I`. -/
theorem normalizedNormalCovariance_quadratic_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) (v : Fin n × Fin d → ℝ) :
    matrixQuadratic (normalizedNormalCovariance U) v ≤ ∑ q, v q ^ 2 := by
  set N := normalizedNormalMapMatrix U
  set y := N.transpose *ᵥ v
  have hs : matrixQuadratic (normalizedNormalCovariance U) v = y ⬝ᵥ y := by
    rw [mq_eq_dot, normalizedNormalCovariance, ← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec,
      ← Matrix.mulVec_transpose]
  have hNy : (N *ᵥ y) ⬝ᵥ (N *ᵥ y) ≤ y ⬝ᵥ y := by
    have h := normalizedFisher_quadratic_le hU hp y
    rw [mq_eq_dot, normalizedFisher, ← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec,
      ← Matrix.mulVec_transpose, Matrix.transpose_transpose] at h
    rwa [dot_self_eq y]
  have hyy : y ⬝ᵥ y = v ⬝ᵥ (N *ᵥ y) := by
    rw [Matrix.dotProduct_mulVec, ← Matrix.mulVec_transpose, Matrix.transpose_transpose,
      dotProduct_comm]
  have hcs : (v ⬝ᵥ (N *ᵥ y)) ^ 2 ≤ (v ⬝ᵥ v) * ((N *ᵥ y) ⬝ᵥ (N *ᵥ y)) := by
    simpa [dotProduct, sq] using Finset.sum_mul_sq_le_sq_mul_sq Finset.univ v (N *ᵥ y)
  have hvv : 0 ≤ v ⬝ᵥ v := by rw [dot_self_eq]; positivity
  have hy0 : 0 ≤ y ⬝ᵥ y := by rw [dot_self_eq]; positivity
  rw [hs, ← dot_self_eq v]
  rw [← hyy] at hcs
  have : (y ⬝ᵥ y) ^ 2 ≤ (v ⬝ᵥ v) * (y ⬝ᵥ y) :=
    hcs.trans (mul_le_mul_of_nonneg_left hNy hvv)
  nlinarith

/-- Second moment of a linear functional of a Gaussian image. -/
theorem integral_sq_linear_stdGaussian {κ : Type*} [Fintype κ] [DecidableEq κ]
    (F : Matrix κ κ ℝ) (w : κ → ℝ) :
    ∫ g, (∑ p, (Matrix.toEuclideanLin F g) p * w p) ^ 2 ∂stdGaussian (EuclideanSpace ℝ κ) =
      w ⬝ᵥ ((F * F.transpose) *ᵥ w) := by
  set v : EuclideanSpace ℝ κ := WithLp.toLp 2 (F.transpose *ᵥ w)
  have hL : ∀ g : EuclideanSpace ℝ κ,
      (∑ p, (Matrix.toEuclideanLin F g) p * w p) = innerSL ℝ v g := by
    intro g
    rw [innerSL_apply_apply, EuclideanSpace.inner_eq_star_dotProduct]
    simp only [v, Matrix.toLpLin_apply, star_trivial]
    rw [Matrix.mulVec_transpose, dotProduct_comm, ← Matrix.dotProduct_mulVec]
    simp [dotProduct, mul_comm]
  simp_rw [hL]
  rw [integral_sq_dual_stdGaussian, innerSL_apply_norm, EuclideanSpace.real_norm_sq_eq]
  simp only [v, ← Matrix.mulVec_mulVec]
  rw [← dot_self_eq, Matrix.dotProduct_mulVec w F, ← Matrix.mulVec_transpose]

end

end Paulsen.Paper.ModerateAux
