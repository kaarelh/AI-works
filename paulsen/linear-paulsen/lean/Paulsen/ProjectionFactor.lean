import Paulsen.FrameComplement
import Mathlib.LinearAlgebra.Matrix.Rank

/-! Every real symmetric idempotent matrix is the projection of a Parseval frame. -/
namespace Paulsen
open Matrix
open scoped BigOperators
noncomputable section

theorem IsParseval.frameProjection_rank {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) : (frameProjection U).rank = d := by
  rw [frameProjection, Matrix.rank_self_mul_transpose, ← Matrix.rank_transpose_mul_self U,
    hU, Matrix.rank_one, Fintype.card_fin]

/-- Factor an orthogonal projection through an orthonormal basis of its range. -/
theorem exists_parseval_of_symmetric_idempotent {n : ℕ} (P : Frame n n)
    (hsymm : P.transpose = P) (hidem : P * P = P) :
    ∃ U : Frame n P.rank, IsParseval U ∧ frameProjection U = P := by
  classical
  let E := EuclideanSpace ℝ (Fin n)
  let T := Matrix.toEuclideanLin P
  let K : Submodule ℝ E := LinearMap.range T
  let k := Module.finrank ℝ K
  let b := stdOrthonormalBasis ℝ K
  let U : Frame n k := Matrix.of fun i j => (b j : E) i
  have hU : IsParseval U := by
    ext i j
    change (∑ l, U l i * U l j) = if i = j then 1 else 0
    have hij := b.inner_eq_ite i j
    change (∑ l, U l j * U l i) = if i = j then 1 else 0 at hij
    exact (Finset.sum_congr rfl (fun l _ => mul_comm (U l i) (U l j))).trans hij
  have hfix (j : Fin k) : T (b j : E) = (b j : E) := by
    obtain ⟨x, hx⟩ := (b j).property
    rw [← hx]
    change WithLp.toLp 2 (P *ᵥ (P *ᵥ x.ofLp)) = WithLp.toLp 2 (P *ᵥ x.ofLp)
    rw [Matrix.mulVec_mulVec, hidem]
  have hsum (i : Fin n) (j : Fin k) : ∑ l, P i l * U l j = U i j := by
    have hh := congrArg (fun v : E => v i) (hfix j)
    exact hh
  have hsymm' (i j : Fin n) : P i j = P j i := by
    exact congrArg (fun M : Frame n n => M j i) hsymm
  have hfactor : frameProjection U = P := by
    ext i j
    let v : K := ⟨WithLp.toLp 2 (fun l => P l j), by
      refine ⟨WithLp.toLp 2 (Pi.single j 1), ?_⟩
      ext l
      change (P *ᵥ Pi.single j 1) l = P l j
      simp [Matrix.mulVec, dotProduct, Pi.single_apply]⟩
    have hcoef (a : Fin k) : inner ℝ (b a) v = U j a := by
      change (∑ l, P l j * U l a) = U j a
      simpa only [hsymm' j] using hsum j a
    have hh := congrArg (fun w : K => (w : E) i) (b.sum_repr' v)
    simp only [Submodule.coe_sum, Submodule.coe_smul, hcoef] at hh
    change (∑ a : Fin k, U j a • (b a : EuclideanSpace ℝ (Fin n))).ofLp i = P i j at hh
    rw [WithLp.ofLp_sum] at hh
    simp only [Finset.sum_apply] at hh
    change ∑ a, U j a * U i a = P i j at hh
    change (∑ a, U i a * U j a) = P i j
    exact (Finset.sum_congr rfl (fun a _ => mul_comm (U i a) (U j a))).trans hh
  have hk : k = P.rank := by rw [← hfactor, hU.frameProjection_rank]
  rw [← hk]
  exact ⟨U, hU, hfactor⟩

end
end Paulsen
