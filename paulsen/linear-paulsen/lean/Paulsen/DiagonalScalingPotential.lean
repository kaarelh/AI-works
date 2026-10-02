import Paulsen.ScalingExistence
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Log.Deriv
import Mathlib.Analysis.Matrix.PosDef

/-!
# The actual potential for exponential diagonal scaling

Cauchy--Binet writes the Gram determinant as a finite exponential sum of
squared minors. Differentiating this sum and using its inclusion marginals
identifies the derivative with the scaled leverage vector.
-/

namespace Paulsen

open Matrix
open scoped BigOperators

noncomputable section

def diagonalScalingWeight {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ)
    (f : Fin d ↪ Fin n) : ℝ :=
  embeddingMinorWeight U f * Real.exp (2 * ∑ j, s (f j))

def diagonalScalingPartition {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) : ℝ :=
  ∑ f : Fin d ↪ Fin n, diagonalScalingWeight U s f

def diagonalScalingPotential {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) : ℝ :=
  (1 / 2) * Real.log (diagonalScalingPartition U s)

def diagonalScalingDerivative {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) :
    (Fin n → ℝ) →L[ℝ] ℝ :=
  ∑ i, scaledLeverage U (fun j => Real.exp (2 * s j)) i • ContinuousLinearMap.proj i

@[simp] theorem diagonalScalingDerivative_apply {n d : ℕ}
    (U : Frame n d) (s h : Fin n → ℝ) :
    diagonalScalingDerivative U s h =
      ∑ i, scaledLeverage U (fun j => Real.exp (2 * s j)) i * h i := by
  simp [diagonalScalingDerivative]

theorem exp_rowScale_gram {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) :
    (rowScale U (fun i => Real.exp (s i))).transpose * rowScale U (fun i => Real.exp (s i)) =
      weightedFrameGram U (fun i => Real.exp (2 * s i)) := by
  rw [rowScale_gram]
  congr 1
  funext i
  rw [pow_two, ← Real.exp_add]
  congr 1
  ring

theorem sum_embeddingMinorWeight_eq_gram_det {n d : ℕ} (Y : Frame n d) :
    (∑ f, embeddingMinorWeight Y f) = (Y.transpose * Y).det := by
  have hf : (d.factorial : ℝ) ≠ 0 := Nat.cast_ne_zero.mpr (Nat.factorial_ne_zero d)
  have h := factorial_mul_gram_det_embeddings Y
  simp only [Fintype.card_fin] at h
  simp only [embeddingMinorWeight, ← Finset.sum_div]
  rw [← h, mul_div_cancel_left₀ _ hf]

theorem diagonalScalingWeight_eq_scaled_minor {n d : ℕ}
    (U : Frame n d) (s : Fin n → ℝ) (f : Fin d ↪ Fin n) :
    diagonalScalingWeight U s f = embeddingMinorWeight (rowScale U (fun i => Real.exp (s i))) f := by
  have h := sq_row_minor_exp_scaling U (fun i => 2 * s i) (1 : Matrix (Fin d) (Fin d) ℝ) f
  simp only [mul_div_cancel_left₀ _ (show (2 : ℝ) ≠ 0 by norm_num), Matrix.mul_one,
    Matrix.det_one, one_pow, mul_one, ← Finset.mul_sum] at h
  unfold diagonalScalingWeight embeddingMinorWeight rowScale
  rw [h]
  ring

theorem diagonalScalingPartition_eq_det {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) :
    diagonalScalingPartition U s = (weightedFrameGram U (fun i => Real.exp (2 * s i))).det := by
  simp only [diagonalScalingPartition, diagonalScalingWeight_eq_scaled_minor]
  rw [sum_embeddingMinorWeight_eq_gram_det, exp_rowScale_gram]

theorem diagonalScalingPartition_pos {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (s : Fin n → ℝ) : 0 < diagonalScalingPartition U s := by
  rw [diagonalScalingPartition_eq_det]
  exact (weightedFrameGram_posDef U _ hU (fun i => Real.exp_pos _)).det_pos

theorem diagonalScalingPotential_eq_logdet {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) :
    diagonalScalingPotential U s =
      (1 / 2) * Real.log (weightedFrameGram U (fun i => Real.exp (2 * s i))).det := by
  rw [diagonalScalingPotential, diagonalScalingPartition_eq_det]

theorem embeddingMinorWeight_right_mul {n d : ℕ} (Y : Frame n d)
    (M : Matrix (Fin d) (Fin d) ℝ) (f : Fin d ↪ Fin n) :
    embeddingMinorWeight (Y * M) f = embeddingMinorWeight Y f * M.det ^ 2 := by
  have hsub : (Y * M).submatrix f id = Y.submatrix f id * M := by
    ext i j
    simp [Matrix.mul_apply, Matrix.submatrix_apply]
  simp only [embeddingMinorWeight, hsub, Matrix.det_mul, mul_pow]
  ring

/-- Inclusion marginals of normalized squared minors equal the actual
Gram-inverse leverage, for every frame with positive-definite Gram matrix. -/
theorem normalized_minor_marginal {n d : ℕ} (Y : Frame n d)
    (hG : (Y.transpose * Y).PosDef) (i : Fin n) :
    (∑ f, embeddingIncidence f i *
      (embeddingMinorWeight Y f / (Y.transpose * Y).det)) = columnSpaceProjection Y i i := by
  obtain ⟨M, _hM, hW⟩ := exists_posDef_right_whitening Y hG
  have hsum : (∑ f, embeddingMinorWeight Y f / (Y.transpose * Y).det) = 1 := by
    rw [← Finset.sum_div, sum_embeddingMinorWeight_eq_gram_det, div_self hG.det_pos.ne']
  have hweights : ∀ f, embeddingMinorWeight Y f / (Y.transpose * Y).det =
      embeddingMinorWeight (Y * M) f := by
    apply normalized_common_factor_unique (embeddingMinorWeight Y)
      (fun f => embeddingMinorWeight Y f / (Y.transpose * Y).det)
      (embeddingMinorWeight (Y * M)) ((Y.transpose * Y).det)⁻¹ (M.det ^ 2)
    · intro f
      simp only [div_eq_mul_inv, mul_comm]
    · intro f
      rw [embeddingMinorWeight_right_mul]
      ring
    · exact hsum
    · exact sum_embeddingMinorWeight (Y * M) hW
  simp only [hweights]
  rw [embeddingMinorWeight_marginal (Y * M) hW,
    columnSpaceProjection_eq_of_parseval_right_mul Y M hW, frameProjection_diagonal]

/-- The exponential-minor distribution has precisely the scaled leverage
as its vector of inclusion probabilities. -/
theorem diagonalScalingWeight_marginal {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (s : Fin n → ℝ) (i : Fin n) :
    (∑ f, embeddingIncidence f i *
      (diagonalScalingWeight U s f / diagonalScalingPartition U s)) =
      scaledLeverage U (fun j => Real.exp (2 * s j)) i := by
  have hG := rowScale_gram_posDef U (fun j => Real.exp (s j)) hU
    (fun j => Real.exp_ne_zero _)
  rw [diagonalScalingPartition_eq_det, ← exp_rowScale_gram]
  simp only [diagonalScalingWeight_eq_scaled_minor]
  rw [normalized_minor_marginal _ hG, rowScale_projection_diagonal]
  congr 1
  funext j
  rw [pow_two, ← Real.exp_add]
  congr 1
  ring

def embeddingSumCLM {n d : ℕ} (f : Fin d ↪ Fin n) : (Fin n → ℝ) →L[ℝ] ℝ :=
  ∑ j, ContinuousLinearMap.proj (f j)

@[simp] theorem embeddingSumCLM_apply {n d : ℕ} (f : Fin d ↪ Fin n) (s : Fin n → ℝ) :
    embeddingSumCLM f s = ∑ j, s (f j) := by
  simp [embeddingSumCLM]

theorem hasFDerivAt_diagonalScalingWeight {n d : ℕ} (U : Frame n d)
    (f : Fin d ↪ Fin n) (s : Fin n → ℝ) :
    HasFDerivAt (fun x => diagonalScalingWeight U x f)
      ((2 * diagonalScalingWeight U s f) • embeddingSumCLM f) s := by
  have h := ((((embeddingSumCLM f).hasFDerivAt (x := s)).const_mul (2 : ℝ)).exp.const_mul
    (embeddingMinorWeight U f))
  simpa only [embeddingSumCLM_apply, diagonalScalingWeight, smul_smul,
    mul_comm, mul_left_comm, mul_assoc] using h

theorem hasFDerivAt_diagonalScalingPartition {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ) :
    HasFDerivAt (diagonalScalingPartition U)
      (∑ f, (2 * diagonalScalingWeight U s f) • embeddingSumCLM f) s :=
  HasFDerivAt.fun_sum fun f _ => hasFDerivAt_diagonalScalingWeight U f s

theorem diagonalScalingWeight_pairing {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (s h : Fin n → ℝ) :
    (∑ f, (diagonalScalingWeight U s f / diagonalScalingPartition U s) *
      (∑ j, h (f j))) = ∑ i, scaledLeverage U (fun j => Real.exp (2 * s j)) i * h i := by
  simp_rw [← sum_mul_embeddingIncidence h]
  calc
    _ = ∑ i, (∑ f, embeddingIncidence f i *
        (diagonalScalingWeight U s f / diagonalScalingPartition U s)) * h i := by
      simp only [Finset.mul_sum, Finset.sum_mul]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro i _
      apply Finset.sum_congr rfl
      intro f _
      ring
    _ = _ := by simp only [diagonalScalingWeight_marginal hU]

/-- The derivative of the actual log-determinant potential is the scaled
leverage vector, paired with the direction of motion. -/
theorem hasFDerivAt_diagonalScalingPotential {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (s : Fin n → ℝ) :
    HasFDerivAt (diagonalScalingPotential U) (diagonalScalingDerivative U s) s := by
  have hZ := hasFDerivAt_diagonalScalingPartition U s
  have h := (hZ.log (diagonalScalingPartition_pos hU s).ne').const_mul (1 / 2 : ℝ)
  have heq : diagonalScalingDerivative U s = (1 / 2 : ℝ) •
      ((diagonalScalingPartition U s)⁻¹ •
        ∑ f, (2 * diagonalScalingWeight U s f) • embeddingSumCLM f) := by
    ext v
    simp only [diagonalScalingDerivative_apply, FunLike.coe_smul,
      Pi.smul_apply, smul_eq_mul, _root_.sum_apply, embeddingSumCLM_apply]
    rw [← diagonalScalingWeight_pairing hU s v]
    simp only [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro f _
    simp only [div_eq_mul_inv]
    ring_nf
  rw [heq]
  exact h

theorem diagonalScalingPotential_differentiable {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) : Differentiable ℝ (diagonalScalingPotential U) :=
  fun s => (hasFDerivAt_diagonalScalingPotential hU s).differentiableAt

theorem fderiv_diagonalScalingPotential_apply {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (s h : Fin n → ℝ) :
    fderiv ℝ (diagonalScalingPotential U) s h =
      ∑ i, scaledLeverage U (fun j => Real.exp (2 * s j)) i * h i := by
  rw [(hasFDerivAt_diagonalScalingPotential hU s).fderiv, diagonalScalingDerivative_apply]

theorem diagonalScalingPotential_contDiff {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (k : WithTop ℕ∞) : ContDiff ℝ k (diagonalScalingPotential U) := by
  unfold diagonalScalingPotential
  apply contDiff_const.mul
  apply ContDiff.log
  · unfold diagonalScalingPartition diagonalScalingWeight
    apply ContDiff.sum
    intro f _
    apply contDiff_const.mul
    apply ContDiff.exp
    apply contDiff_const.mul
    exact ContDiff.sum fun j _ => contDiff_apply ℝ ℝ (f j)
  · intro s
    exact (diagonalScalingPartition_pos hU s).ne'

@[simp] theorem diagonalScalingPartition_zero {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) : diagonalScalingPartition U 0 = 1 := by
  change U.transpose * U = 1 at hU
  rw [diagonalScalingPartition_eq_det]
  simp only [Pi.zero_apply, mul_zero, Real.exp_zero, weightedFrameGram,
    Matrix.diagonal_one, Matrix.mul_one, hU, Matrix.det_one]

@[simp] theorem diagonalScalingPotential_zero {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) : diagonalScalingPotential U 0 = 0 := by
  rw [diagonalScalingPotential, diagonalScalingPartition_zero hU, Real.log_one, mul_zero]

theorem fderiv_diagonalScalingPotential_zero {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (h : Fin n → ℝ) :
    fderiv ℝ (diagonalScalingPotential U) 0 h = ∑ i, rowNormSq U i * h i := by
  rw [fderiv_diagonalScalingPotential_apply hU]
  change U.transpose * U = 1 at hU
  apply Finset.sum_congr rfl
  intro i _
  congr 1
  simp only [Pi.zero_apply, mul_zero, Real.exp_zero, scaledLeverage, weightedFrameGram,
    Matrix.diagonal_one, Matrix.mul_one, hU, inv_one, one_mul]
  exact frameProjection_diagonal U i

end
end Paulsen
