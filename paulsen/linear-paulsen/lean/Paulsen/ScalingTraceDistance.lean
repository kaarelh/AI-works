import Paulsen.ScalingDistance

/-! # Trace control of projection distance under diagonal scaling -/

namespace Paulsen

open Matrix

theorem scaling_trace_identity {n : ℕ} (P Q D : Matrix (Fin n) (Fin n) ℝ)
    (hP : P * P = P) (hQ : Q * Q = Q)
    (hQDP : Q * D * P = D * P) (hPDQ : P * D * Q = P * D) :
    (D * ((Q - P) * (Q - P))).trace = (D * (Q - P)).trace := by
  have h₁ : (D * Q * P).trace = (D * P).trace := by
    calc
      _ = (P * D * Q).trace := by rw [Matrix.trace_mul_cycle]
      _ = (P * D).trace := by rw [hPDQ]
      _ = _ := Matrix.trace_mul_comm P D
  have h₂ : (D * P * Q).trace = (D * P).trace := by
    calc
      _ = (Q * D * P).trace := by rw [Matrix.trace_mul_cycle]
      _ = _ := by rw [hQDP]
  have hexp : D * ((Q - P) * (Q - P)) =
      D * (Q * Q) - D * Q * P - D * P * Q + D * (P * P) := by
    noncomm_ring
  rw [hexp, hP, hQ, Matrix.trace_add, Matrix.trace_sub, Matrix.trace_sub,
    h₁, h₂, Matrix.mul_sub, Matrix.trace_sub]
  ring


open scoped BigOperators
open Paulsen

theorem scaling_distance_trace_bound {n : ℕ}
    (P Q : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) (m M : ℝ)
    (hPs : P.transpose = P) (hQs : Q.transpose = Q)
    (hP : P * P = P) (hQ : Q * Q = Q)
    (htr : P.trace = Q.trace)
    (hQDP : Q * Matrix.diagonal w * P = Matrix.diagonal w * P)
    (hlo : ∀ i, m ≤ w i) (hhi : ∀ i, w i ≤ M) :
    m * sqDistance P Q ≤ (M - m) / 2 * ∑ i, |Q i i - P i i| := by
  have hPDQ : P * Matrix.diagonal w * Q = P * Matrix.diagonal w := by
    have ht := congrArg Matrix.transpose hQDP
    simpa only [Matrix.transpose_mul, Matrix.diagonal_transpose, hPs, hQs,
      Matrix.mul_assoc] using ht
  have hs : ∀ i j, (Q - P) j i = (Q - P) i j := by
    intro i j
    have hp := congrFun (congrFun hPs i) j
    have hq := congrFun (congrFun hQs i) j
    simpa only [Matrix.transpose_apply, Matrix.sub_apply] using congrArg₂ (· - ·) hq hp
  have hid := scaling_trace_identity P Q (Matrix.diagonal w) hP hQ hQDP hPDQ
  have he : (∑ i, w i * ∑ j, (Q i j - P i j)^2) =
      ∑ i, w i * (Q i i - P i i) := by
    have hdiag (A : Matrix (Fin n) (Fin n) ℝ) :
        (Matrix.diagonal w * A).trace = ∑ i, w i * A i i := by
      simp only [Matrix.trace, Matrix.diag, Matrix.diagonal_mul]
    rw [hdiag, hdiag] at hid
    simp only [Matrix.mul_apply] at hid
    convert hid using 1
    apply Finset.sum_congr rfl
    intro i _
    congr 1
    apply Finset.sum_congr rfl
    intro j _
    rw [hs i j]
    simp only [Matrix.sub_apply, pow_two]
    all_goals rfl
  have hsum : (∑ i, (Q i i - P i i)) = 0 := by
    simp only [Finset.sum_sub_distrib]
    change Q.trace - P.trace = 0
    rw [htr, sub_self]
  have hlower : m * sqDistance P Q ≤ ∑ i, w i * ∑ j, (Q i j - P i j)^2 := by
    rw [sqDistance_symm P Q]
    unfold sqDistance
    rw [Finset.mul_sum]
    exact Finset.sum_le_sum fun i _ => mul_le_mul_of_nonneg_right (hlo i)
      (Finset.sum_nonneg fun j _ => sq_nonneg _)
  have hcenter : (∑ i, w i * (Q i i - P i i)) =
      ∑ i, (w i - (M + m)/2) * (Q i i - P i i) := by
    simp only [sub_mul, Finset.sum_sub_distrib, ← Finset.mul_sum, hsum, mul_zero, sub_zero]
  calc
    _ ≤ ∑ i, w i * ∑ j, (Q i j - P i j)^2 := hlower
    _ = ∑ i, (w i - (M + m)/2) * (Q i i - P i i) := he.trans hcenter
    _ ≤ ∑ i, ((M - m)/2) * |Q i i - P i i| := by
      apply Finset.sum_le_sum
      intro i _
      have habs : |w i - (M + m)/2| ≤ (M-m)/2 := by
        apply abs_le.mpr
        constructor <;> linarith [hlo i, hhi i]
      calc
        _ ≤ |(w i - (M+m)/2) * (Q i i-P i i)| := le_abs_self _
        _ = |w i - (M+m)/2| * |Q i i-P i i| := abs_mul _ _
        _ ≤ _ := mul_le_mul_of_nonneg_right habs (abs_nonneg _)
    _ = _ := (Finset.mul_sum _ _ _).symm


/-- A factor-two bound on the actual row scales gives cost at most half the
L1 change of the projection diagonal. -/
theorem scaling_distance_half_l1 {n : ℕ}
    (P Q : Matrix (Fin n) (Fin n) ℝ) (w : Fin n → ℝ) (m : ℝ)
    (hPs : P.transpose = P) (hQs : Q.transpose = Q)
    (hP : P * P = P) (hQ : Q * Q = Q)
    (htr : P.trace = Q.trace)
    (hQDP : Q * Matrix.diagonal w * P = Matrix.diagonal w * P)
    (hm : 0 < m) (hlo : ∀ i, m ≤ w i) (hhi : ∀ i, w i ≤ 2 * m) :
    sqDistance P Q ≤ (1 / 2 : ℝ) * ∑ i, |Q i i - P i i| := by
  apply (mul_le_mul_iff_right₀ hm).mp
  calc
    m * sqDistance P Q ≤ (2*m-m)/2 * ∑ i, |Q i i-P i i| :=
      scaling_distance_trace_bound P Q w m (2*m) hPs hQs hP hQ htr hQDP hlo hhi
    _ = m * ((1/2 : ℝ) * ∑ i, |Q i i-P i i|) := by ring


/-- The column projection of a positive row scaling fixes the scaled frame. -/
theorem rowScale_projection_mul {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (w : Fin n → ℝ) (hw : ∀ i, 0 < w i) :
    columnSpaceProjection (rowScale U w) * rowScale U w = rowScale U w := by
  let Y := rowScale U w
  have hG := rowScale_gram_posDef U w hU (fun i => (hw i).ne')
  have hi := Matrix.nonsing_inv_mul (Y.transpose * Y)
    ((Matrix.isUnit_iff_isUnit_det _).mp hG.isUnit)
  change (Y * (Y.transpose * Y)⁻¹ * Y.transpose) * Y = Y
  calc
    _ = Y * ((Y.transpose * Y)⁻¹ * (Y.transpose * Y)) := by
      simp only [Matrix.mul_assoc]
    _ = Y := by rw [hi, Matrix.mul_one]

/-- Trace distance bound for the projection onto a positive row scaling. -/
theorem rowScale_projection_trace_bound {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (w : Fin n → ℝ) (hw : ∀ i, 0 < w i) (m M : ℝ)
    (hlo : ∀ i, m ≤ w i) (hhi : ∀ i, w i ≤ M) :
    m * sqDistance (columnSpaceProjection (rowScale U w)) (frameProjection U) ≤
      (M-m)/2 * ∑ i, |columnSpaceProjection (rowScale U w) i i - rowNormSq U i| := by
  obtain ⟨A, _, hA⟩ := exists_posDef_right_whitening (rowScale U w)
    (rowScale_gram_posDef U w hU (fun i => (hw i).ne'))
  have hQ := columnSpaceProjection_eq_of_parseval_right_mul _ _ hA
  have hfix : columnSpaceProjection (rowScale U w) * Matrix.diagonal w * frameProjection U =
      Matrix.diagonal w * frameProjection U := by
    have hf := rowScale_projection_mul U hU w hw
    change columnSpaceProjection (rowScale U w) * (Matrix.diagonal w) * (U*U.transpose) =
      Matrix.diagonal w * (U*U.transpose)
    simpa only [rowScale, Matrix.mul_assoc] using congrArg (· * U.transpose) hf
  have ht : (frameProjection U).trace = (columnSpaceProjection (rowScale U w)).trace := by
    rw [hQ, hU.frameProjection_trace, hA.frameProjection_trace]
  have hs := scaling_distance_trace_bound (frameProjection U)
    (columnSpaceProjection (rowScale U w)) w m M
    (frameProjection_transpose U) (by rw [hQ]; exact frameProjection_transpose _)
    hU.frameProjection_idempotent (by rw [hQ]; exact hA.frameProjection_idempotent)
    ht hfix hlo hhi
  simpa only [sqDistance_symm (frameProjection U), frameProjection_diagonal] using hs

end Paulsen
