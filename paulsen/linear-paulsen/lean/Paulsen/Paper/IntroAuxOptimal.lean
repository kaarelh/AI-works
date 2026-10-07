import Paulsen.Paper.Toolbox

/-! # The trace proof of the block lower bound

For orthogonal projections `E ≤ P` and `E ≤ J`, the deficit
`tr E - tr (J Q)` is at most `tr (P (I-Q))`, hence at most half the
squared distance between equal-rank projections `P` and `Q`.
-/

namespace Paulsen.Paper.IntroAux

open Matrix
open scoped BigOperators

noncomputable section

/-- The trace of a product of two orthogonal projections is nonnegative. -/
theorem projection_trace_mul_nonneg {n : ℕ} (E Q : Matrix (Fin n) (Fin n) ℝ)
    (hEs : E.transpose = E) (hE : E * E = E)
    (hQs : Q.transpose = Q) (hQ : Q * Q = Q) : 0 ≤ (E * Q).trace := by
  have h := Finset.sum_nonneg (s := Finset.univ) fun i (_ : i ∈ Finset.univ) =>
    Finset.sum_nonneg (s := Finset.univ) fun j (_ : j ∈ Finset.univ) => sq_nonneg ((E*Q) i j)
  rw [entry_sq_sum_eq_trace, Matrix.transpose_mul, hEs, hQs] at h
  have he : (Q * E * (E * Q)).trace = (E * Q).trace := by
    calc
      _ = (Q * (E*E) * Q).trace := by simp only [Matrix.mul_assoc]
      _ = (Q * E * Q).trace := by rw [hE]
      _ = (Q * Q * E).trace := Matrix.trace_mul_cycle _ _ _
      _ = (E*Q).trace := by rw [hQ, Matrix.trace_mul_comm]
  rwa [he] at h

/-- The difference of nested orthogonal projections is an orthogonal projection. -/
theorem projection_sub_projection {n : ℕ} (P E : Matrix (Fin n) (Fin n) ℝ)
    (hPs : P.transpose = P) (hEs : E.transpose = E)
    (hP : P*P=P) (hE : E*E=E) (hPE : P*E=E) :
    (P-E).transpose = P-E ∧ (P-E)*(P-E)=P-E := by
  have hEP : E*P=E := by
    have h := congrArg Matrix.transpose hPE
    simpa only [Matrix.transpose_mul, hPs, hEs] using h
  constructor
  · rw [Matrix.transpose_sub, hPs, hEs]
  · noncomm_ring [hP, hE, hPE, hEP]

/-- The projection trace deficit on a coordinate block is bounded by half the
squared distance. `P*E=E` and `J*E=E` encode `E ≤ P` and `E ≤ J`. -/
theorem optimal_core {n : ℕ} (P Q E J : Matrix (Fin n) (Fin n) ℝ)
    (hPs : P.transpose=P) (hQs : Q.transpose=Q)
    (hEs : E.transpose=E) (hJs : J.transpose=J)
    (hP : P*P=P) (hQ : Q*Q=Q) (hE : E*E=E) (hJ : J*J=J)
    (htr : P.trace=Q.trace) (hPE : P*E=E) (hJE : J*E=E) :
    2 * (E.trace - (J*Q).trace) ≤ sqDistance P Q := by
  have hR := projection_sub_projection P E hPs hEs hP hE hPE
  have hS := projection_sub_projection J E hJs hEs hJ hE hJE
  have hQc : (1-Q).transpose=1-Q := by rw [Matrix.transpose_sub, Matrix.transpose_one, hQs]
  have hQcc : (1-Q)*(1-Q)=1-Q := by noncomm_ring [hQ]
  have hnonneg := projection_trace_mul_nonneg (P-E) (1-Q) hR.1 hR.2 hQc hQcc
  have hnonneg' := projection_trace_mul_nonneg (J-E) Q hS.1 hS.2 hQs hQ
  simp only [Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_one, Matrix.trace_sub] at hnonneg hnonneg'
  have hdist : sqDistance P Q = 2 * (P.trace - (P*Q).trace) := by
    rw [sqDistance_eq_trace_sub, Matrix.transpose_sub, hPs, hQs,
      Matrix.sub_mul, Matrix.mul_sub, Matrix.mul_sub, hP, hQ,
      Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_sub,
      Matrix.trace_mul_comm Q P, ← htr]
    ring
  rw [hdist]
  linarith

end
end Paulsen.Paper.IntroAux
