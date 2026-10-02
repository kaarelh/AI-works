import Paulsen.NormalizedNormalMap

/-!
# Exact base-covariance mean of a horizontal seed

The quadratic diagonal term is the difference of two row energies. Summing it
over the columns of the normalized normal map gives exactly L(p⁻¹), without
an estimate that loses a power of the density d/n.
-/

namespace Paulsen
open Matrix
open scoped BigOperators
noncomputable section

def horizontalQuadraticDiagonal {n d : ℕ} (U H : Frame n d) (i : Fin n) : ℝ :=
  rowNormSq H i - rowNormSq (U * H.transpose) i

/-- A column of the normalized normal map, reshaped as a frame. -/
def baseNormalDirection {n d : ℕ} (U : Frame n d) (j : Fin n) : Frame n d :=
  Matrix.of fun i k => frameComplementProjection U i j * U j k /
    Real.sqrt (rowNormSq U j)

theorem baseNormalDirection_eq_column {n d : ℕ} (U : Frame n d)
    (j i : Fin n) (k : Fin d) :
    baseNormalDirection U j i k = normalizedNormalMapMatrix U (i,k) j := by
  simp [baseNormalDirection, normalizedNormalMapMatrix, leverageNormalizer,
    Matrix.mul_diagonal, normalMapMatrix, div_eq_mul_inv]

theorem baseNormalDirection_rowNormSq {n d : ℕ} (U : Frame n d)
    (hp : ∀ i, 0 < rowNormSq U i) (i j : Fin n) :
    rowNormSq (baseNormalDirection U j) i = (frameComplementProjection U i j) ^ 2 := by
  change (∑ k, (baseNormalDirection U j i k) ^ 2) = _
  simp only [baseNormalDirection, Matrix.of_apply, div_pow, mul_pow,
    Real.sq_sqrt (hp j).le, ← Finset.sum_div, ← Finset.mul_sum]
  change (frameComplementProjection U i j) ^ 2 * rowNormSq U j / rowNormSq U j = _
  exact mul_div_cancel_right₀ _ (hp j).ne'

theorem mul_baseNormalDirection_transpose {n d : ℕ} (U : Frame n d)
    (i j k : Fin n) :
    (U * (baseNormalDirection U j).transpose) i k =
      frameProjection U i j * frameComplementProjection U k j / Real.sqrt (rowNormSq U j) := by
  simp only [Matrix.mul_apply, Matrix.transpose_apply, baseNormalDirection, Matrix.of_apply,
    frameProjection, Finset.sum_mul, Finset.sum_div]
  apply Finset.sum_congr rfl
  intro a _
  ring

theorem frameComplementProjection_row_squares {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) :
    (∑ j, (frameComplementProjection U i j) ^ 2) = 1 - rowNormSq U i := by
  have hs : ∀ i j, frameComplementProjection U i j = frameComplementProjection U j i := by
    intro i j
    exact congrArg (fun M : Matrix (Fin n) (Fin n) ℝ => M j i)
      (frameComplementProjection_transpose U)
  have he := projection_row_squares _ hs hU.frameComplementProjection_idempotent i
  simpa [frameComplementProjection, frameProjection_diagonal] using he

theorem baseNormalDirection_second_rowNormSq {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (i j : Fin n) :
    rowNormSq (U * (baseNormalDirection U j).transpose) i =
      (frameProjection U i j) ^ 2 * (1 - rowNormSq U j) / rowNormSq U j := by
  unfold rowNormSq
  simp_rw [mul_baseNormalDirection_transpose, div_pow, mul_pow, Real.sq_sqrt (hp j).le]
  rw [← Finset.sum_div, ← Finset.mul_sum]
  have hs : ∀ k, frameComplementProjection U k j = frameComplementProjection U j k := by
    intro k
    exact congrArg (fun M : Matrix (Fin n) (Fin n) ℝ => M j k)
      (frameComplementProjection_transpose U)
  simp_rw [hs]
  rw [frameComplementProjection_row_squares hU]
  rfl

/-- Exact base mean, before multiplication by the Gaussian scale 1/n. -/
theorem horizontalQuadraticDiagonal_base_sum {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (i : Fin n) :
    (∑ j, horizontalQuadraticDiagonal U (baseNormalDirection U j) i) =
      1 - ∑ j, (frameProjection U i j) ^ 2 / rowNormSq U j := by
  simp only [horizontalQuadraticDiagonal, baseNormalDirection_rowNormSq U hp,
    baseNormalDirection_second_rowNormSq hU hp, Finset.sum_sub_distrib]
  rw [frameComplementProjection_row_squares hU]
  have hterm (j : Fin n) :
      (frameProjection U i j) ^ 2 * (1 - rowNormSq U j) / rowNormSq U j =
        (frameProjection U i j) ^ 2 / rowNormSq U j - (frameProjection U i j) ^ 2 := by
    field_simp [(hp j).ne']
  simp_rw [hterm]
  rw [Finset.sum_sub_distrib, hU.projection_row_squares]
  ring

theorem projectionLaplacian_inv_leverage {n d : ℕ} (U : Frame n d)
    (hp : ∀ i, 0 < rowNormSq U i) (i : Fin n) :
    (projectionLaplacian (frameProjection U) *ᵥ (fun j => (rowNormSq U j)⁻¹)) i =
      1 - ∑ j, (frameProjection U i j) ^ 2 / rowNormSq U j := by
  rw [projectionLaplacian, Matrix.sub_mulVec]
  simp only [Pi.sub_apply, frameProjection_diagonal,
    Matrix.mulVec, dotProduct, Matrix.of_apply, div_eq_mul_inv]
  simp [Matrix.diagonal_apply, (hp i).ne']

/-- The concrete base covariance has mean L(p⁻¹), exactly. -/
theorem horizontalQuadraticDiagonal_base_sum_eq_laplacian {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (i : Fin n) :
    (∑ j, horizontalQuadraticDiagonal U (baseNormalDirection U j) i) =
      (projectionLaplacian (frameProjection U) *ᵥ (fun j => (rowNormSq U j)⁻¹)) i := by
  rw [horizontalQuadraticDiagonal_base_sum hU hp, projectionLaplacian_inv_leverage U hp]

/-- Near-flat leverage makes the exact base mean uniformly small, independently
of the density. Division by n gives the Gaussian mean bound 4ε/n. -/
theorem horizontalQuadraticDiagonal_base_sum_abs_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {a ε : ℝ} (ha : 0 < a) (hε0 : 0 ≤ ε) (hεhalf : ε ≤ 1 / 2)
    (hrows : ∀ i, (1 - ε) * a ≤ rowNormSq U i ∧ rowNormSq U i ≤ (1 + ε) * a)
    (i : Fin n) :
    |∑ j, horizontalQuadraticDiagonal U (baseNormalDirection U j) i| ≤ 4 * ε := by
  have hlow : 0 < (1 - ε) * a := mul_pos (by linarith) ha
  have hupp : 0 < (1 + ε) * a := mul_pos (by linarith) ha
  have hp (j : Fin n) : 0 < rowNormSq U j := hlow.trans_le (hrows j).1
  rw [horizontalQuadraticDiagonal_base_sum hU hp]
  have hlower : (1 - ε) / (1 + ε) ≤ ∑ j, (frameProjection U i j) ^ 2 / rowNormSq U j := by
    calc
      _ = ((1 - ε) * a) / ((1 + ε) * a) := by field_simp
      _ ≤ rowNormSq U i / ((1 + ε) * a) :=
        div_le_div_of_nonneg_right (hrows i).1 hupp.le
      _ = (∑ j, (frameProjection U i j) ^ 2) / ((1 + ε) * a) := by rw [hU.projection_row_squares]
      _ ≤ _ := by
        rw [Finset.sum_div]
        exact Finset.sum_le_sum fun j _ =>
          div_le_div_of_nonneg_left (sq_nonneg _) (hp j) (hrows j).2
  have hupper : (∑ j, (frameProjection U i j) ^ 2 / rowNormSq U j) ≤ (1 + ε) / (1 - ε) := by
    calc
      _ ≤ (∑ j, (frameProjection U i j) ^ 2) / ((1 - ε) * a) := by
        rw [Finset.sum_div]
        exact Finset.sum_le_sum fun j _ =>
          div_le_div_of_nonneg_left (sq_nonneg _) hlow (hrows j).1
      _ = rowNormSq U i / ((1 - ε) * a) := by rw [hU.projection_row_squares]
      _ ≤ ((1 + ε) * a) / ((1 - ε) * a) :=
        div_le_div_of_nonneg_right (hrows i).2 hlow.le
      _ = _ := by field_simp
  have hlo : 1 - 4 * ε ≤ (1 - ε) / (1 + ε) := by
    apply (le_div_iff₀ (by linarith : 0 < 1 + ε)).2
    nlinarith [sq_nonneg ε]
  have hhi : (1 + ε) / (1 - ε) ≤ 1 + 4 * ε := by
    apply (div_le_iff₀ (by linarith : 0 < 1 - ε)).2
    nlinarith
  exact abs_le.mpr ⟨by linarith, by linarith⟩

theorem horizontalQuadraticDiagonal_base_mean_abs_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {a ε : ℝ} (ha : 0 < a) (hε0 : 0 ≤ ε) (hεhalf : ε ≤ 1 / 2)
    (hrows : ∀ i, (1 - ε) * a ≤ rowNormSq U i ∧ rowNormSq U i ≤ (1 + ε) * a)
    (i : Fin n) :
    |(1 / (n : ℝ)) * ∑ j, horizontalQuadraticDiagonal U (baseNormalDirection U j) i| ≤
      4 * ε / n := by
  rw [abs_mul, abs_of_nonneg (by positivity : 0 ≤ 1 / (n : ℝ))]
  calc
    _ ≤ (1 / (n : ℝ)) * (4 * ε) := mul_le_mul_of_nonneg_left
      (horizontalQuadraticDiagonal_base_sum_abs_le hU ha hε0 hεhalf hrows i)
      (by positivity : 0 ≤ 1 / (n : ℝ))
    _ = _ := by ring

end
end Paulsen
