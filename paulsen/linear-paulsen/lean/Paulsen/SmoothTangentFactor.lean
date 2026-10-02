import Paulsen.SmoothNoiseBounds
import Paulsen.NormalResidualVariance

/-!
# Operator and row-energy bounds for the retained tangent Gaussian

The actual tangent derivative factor has squared operator norm at most `2/n`.
Each row factor has the same norm bound and energy at most `6d/n` under the
usual upper leverage bound. These are the inputs for Gaussian maximum energy.
-/

namespace Paulsen.Smooth
open Matrix
open scoped BigOperators
noncomputable section

def retainedTangentFactor {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin n) (Fin n × Fin d) ℝ :=
  tangentLiftMatrix U * normalizedTangentNoiseFactor U ρ

def tangentLiftRowMatrix {n d : ℕ} (U : Frame n d) (i : Fin n) :
    Matrix (Fin n) (Fin n × Fin d) ℝ :=
  Matrix.of fun k p => tangentLiftMatrix U (i,k) p

def retainedTangentRowFactor {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) :
    Matrix (Fin n) (Fin n × Fin d) ℝ :=
  tangentLiftRowMatrix U i * normalizedTangentNoiseFactor U ρ

theorem retainedTangentRowFactor_apply {n d : ℕ} (U : Frame n d) (ρ : ℝ)
    (i k : Fin n) (p : Fin n × Fin d) :
    retainedTangentRowFactor U ρ i k p = retainedTangentFactor U ρ (i,k) p := rfl

theorem retainedTangentFactor_norm_sq {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (ρ : ℝ) (g : EuclideanSpace ℝ (Fin n × Fin d)) :
    ‖Matrix.toEuclideanLin (retainedTangentFactor U ρ) g‖ ^ 2 =
      2 * ‖Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g‖ ^ 2 := by
  let H : Frame n d := Matrix.of fun i a =>
    Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g (i,a)
  have hH : U.transpose * H = 0 := normalizedTangentNoiseFactor_horizontal hU ρ (fun p => g p)
  have hv : Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g = normalFrobVector H := by
    ext p
    rfl
  have hprod : Matrix.toEuclideanLin (retainedTangentFactor U ρ) g =
      Matrix.toEuclideanLin (tangentLiftMatrix U)
        (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g) := by
    simp only [retainedTangentFactor, Matrix.toEuclideanLin, Matrix.toLpLin_mul_same, LinearMap.comp_apply]
  rw [hprod, hv, tangentLiftMatrix_apply]
  exact horizontal_tangent_frobenius_sq hU hH

/-- A squared pointwise norm bound gives the corresponding squared operator bound. -/
theorem euclidean_operator_norm_sq_le_of_pointwise {ι κ : Type*}
    [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
    (M : Matrix ι κ ℝ) {v : ℝ} (hv : 0 ≤ v)
    (hM : ∀ x : EuclideanSpace ℝ κ, ‖Matrix.toEuclideanLin M x‖ ^ 2 ≤ v * ‖x‖ ^ 2) :
    ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖ ^ 2 ≤ v := by
  have hb : ‖(Matrix.toEuclideanLin M).toContinuousLinearMap‖ ≤ Real.sqrt v := by
    apply ContinuousLinearMap.opNorm_le_bound _ (Real.sqrt_nonneg v)
    intro x
    have hx := hM x
    have hs := Real.sq_sqrt hv
    change ‖Matrix.toEuclideanLin M x‖ ≤ Real.sqrt v * ‖x‖
    nlinarith [norm_nonneg (Matrix.toEuclideanLin M x), norm_nonneg x,
      mul_nonneg (Real.sqrt_nonneg v) (norm_nonneg x)]
  nlinarith [norm_nonneg (Matrix.toEuclideanLin M).toContinuousLinearMap,
    Real.sqrt_nonneg v, Real.sq_sqrt hv]

theorem retainedTangentFactor_pointwise_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ)
    (g : EuclideanSpace ℝ (Fin n × Fin d)) :
    ‖Matrix.toEuclideanLin (retainedTangentFactor U ρ) g‖ ^ 2 ≤
      (2 / (n : ℝ)) * ‖g‖ ^ 2 := by
  rw [retainedTangentFactor_norm_sq hU]
  have hn := normalizedTangentNoiseFactor_operator_norm_sq_le hU hρ
  have hx := (Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ)).toContinuousLinearMap.le_opNorm g
  have hx2 := (sq_le_sq₀ (norm_nonneg _) (mul_nonneg (norm_nonneg _) (norm_nonneg g))).2 hx
  rw [mul_pow] at hx2
  have hm := mul_le_mul_of_nonneg_right hn (sq_nonneg ‖g‖)
  change ‖Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ) g‖ ^ 2 ≤ _ at hx2
  calc
    _ ≤ 2 * ((1 / (n : ℝ)) * ‖g‖ ^ 2) := mul_le_mul_of_nonneg_left (hx2.trans hm) (by norm_num)
    _ = _ := by ring

theorem retainedTangentFactor_operator_norm_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    ‖(Matrix.toEuclideanLin (retainedTangentFactor U ρ)).toContinuousLinearMap‖ ^ 2 ≤
      2 / (n : ℝ) :=
  euclidean_operator_norm_sq_le_of_pointwise _ (by positivity)
    (retainedTangentFactor_pointwise_sq_le hU hρ)

theorem retainedTangentRowFactor_operator_norm_sq_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    ‖(Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i)).toContinuousLinearMap‖ ^ 2 ≤
      2 / (n : ℝ) := by
  apply euclidean_operator_norm_sq_le_of_pointwise _ (by positivity)
  intro g
  have hs : ‖Matrix.toEuclideanLin (retainedTangentRowFactor U ρ i) g‖ ^ 2 ≤
      ‖Matrix.toEuclideanLin (retainedTangentFactor U ρ) g‖ ^ 2 := by
    simp only [EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type]
    change (∑ k : Fin n, (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (i,k)) ^ 2) ≤ _
    exact Finset.single_le_sum
      (fun (j : Fin n) _ => Finset.sum_nonneg fun (k : Fin n) _ =>
        sq_nonneg (Matrix.toEuclideanLin (retainedTangentFactor U ρ) g (j,k))) (Finset.mem_univ i)
  exact hs.trans (retainedTangentFactor_pointwise_sq_le hU hρ g)

/-- Squared energy of the deterministic map taking an ambient matrix to one tangent row. -/
theorem tangentLiftRowMatrix_sq_sum_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (i : Fin n) :
    (∑ k, ∑ p, (tangentLiftRowMatrix U i k p) ^ 2) ≤
      2 * (d : ℝ) + 2 * n * rowNormSq U i := by
  have hfirst : (∑ k : Fin n, ∑ p : Fin n × Fin d,
      (if i = p.1 then U k p.2 else 0) ^ 2) = (d : ℝ) := by
    simp only [Fintype.sum_prod_type, ite_pow, zero_pow (by decide : 2 ≠ 0),
      Finset.sum_ite_irrel, Finset.sum_const_zero, Finset.sum_ite_eq,
      Finset.mem_univ, if_true]
    exact hU.total_rowNormSq
  have hsecond : (∑ k : Fin n, ∑ p : Fin n × Fin d,
      (if k = p.1 then U i p.2 else 0) ^ 2) = (n : ℝ) * rowNormSq U i := by
    simp only [Fintype.sum_prod_type, ite_pow, zero_pow (by decide : 2 ≠ 0),
      Finset.sum_ite_irrel, Finset.sum_const_zero, Finset.sum_ite_eq,
      Finset.mem_univ, if_true]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
    rfl
  calc
    _ ≤ ∑ k : Fin n, ∑ p : Fin n × Fin d,
        (2 * (if i = p.1 then U k p.2 else 0) ^ 2 +
          2 * (if k = p.1 then U i p.2 else 0) ^ 2) := by
      apply Finset.sum_le_sum
      intro k _
      apply Finset.sum_le_sum
      intro p _
      change ((if i = p.1 then U k p.2 else 0) + (if k = p.1 then U i p.2 else 0)) ^ 2 ≤ _
      nlinarith [sq_nonneg ((if i = p.1 then U k p.2 else 0) - (if k = p.1 then U i p.2 else 0))]
    _ = _ := by simp only [Finset.sum_add_distrib, ← Finset.mul_sum, hfirst, hsecond]; ring

/-- Expected squared norm of each retained tangent row is at most `6d/n`. -/
theorem retainedTangentRowFactor_sq_sum_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n)
    (hnear : rowNormSq U i ≤ 2 * (d : ℝ) / n) :
    (∑ k, ∑ p, (retainedTangentRowFactor U ρ i k p) ^ 2) ≤ 6 * (d : ℝ) / n := by
  have hn : (0 : ℝ) < n := Nat.cast_pos.mpr (lt_of_le_of_lt (Nat.zero_le i.val) i.isLt)
  have hC := normalizedTangentNoiseFactor_operator_norm_sq_le hU hρ
  have hD := tangentLiftRowMatrix_sq_sum_le hU i
  calc
    _ ≤ ‖(Matrix.toEuclideanLin (normalizedTangentNoiseFactor U ρ)).toContinuousLinearMap‖ ^ 2 *
        ∑ k, ∑ p, (tangentLiftRowMatrix U i k p) ^ 2 :=
      entry_sq_sum_mul_le_right _ _
    _ ≤ (1 / (n : ℝ)) * (2 * d + 2 * n * rowNormSq U i) :=
      mul_le_mul hC hD (by positivity) (by positivity)
    _ = 2 * (d : ℝ) / n + 2 * rowNormSq U i := by field_simp
    _ ≤ 2 * (d : ℝ) / n + 2 * (2 * (d : ℝ) / n) :=
      add_le_add le_rfl (mul_le_mul_of_nonneg_left hnear (by norm_num))
    _ = _ := by ring

end
end Paulsen.Smooth
