import Paulsen.RadialExistence
import Paulsen.RadialTransport
import Paulsen.Orthogonal

/-!
# Quadratic correction for full-spark frames

The Cauchy--Binet minimization supplies an exact radial correction. Diagonalizing
its positive-definite right multiplier puts that correction in the ordered
coordinate form required by the transport estimate.
-/

namespace Paulsen

open scoped BigOperators

/-- A positive-definite real matrix has an orthogonal eigenvector matrix
with its eigenvalues listed in increasing order. -/
theorem exists_ordered_posDef_diagonalization {d : ℕ}
    (M : Matrix (Fin d) (Fin d) ℝ) (hM : M.PosDef) :
    ∃ R : Matrix (Fin d) (Fin d) ℝ,
      R * R.transpose = 1 ∧ R.transpose * R = 1 ∧
      ∃ v : Fin d → ℝ, Monotone v ∧ (∀ j, 0 < v j) ∧
        M * R = R * Matrix.diagonal v := by
  classical
  let e : Fin (Fintype.card (Fin d)) ≃ Fin d :=
    Fintype.equivOfCardEq (Fintype.card_fin _)
  let q : Fin d ≃ Fin d :=
    Fin.revPerm.trans ((finCongr (Fintype.card_fin d).symm).trans e)
  let Q : Matrix (Fin d) (Fin d) ℝ := hM.isHermitian.eigenvectorUnitary
  let R := Q.submatrix id q
  let v : Fin d → ℝ := fun j => hM.isHermitian.eigenvalues (q j)
  have hQ₁ : Q * Q.transpose = 1 := by
    simpa only [Q, Unitary.coe_star, Matrix.star_eq_conjTranspose,
      Matrix.conjTranspose_eq_transpose_of_trivial] using
      Unitary.coe_mul_star_self hM.isHermitian.eigenvectorUnitary
  have hQ₂ : Q.transpose * Q = 1 := by
    simpa only [Q, Matrix.star_eq_conjTranspose,
      Matrix.conjTranspose_eq_transpose_of_trivial] using
      Unitary.coe_star_mul_self hM.isHermitian.eigenvectorUnitary
  have hR₁ : R * R.transpose = 1 := by
    dsimp only [R]
    rw [Matrix.transpose_submatrix, Matrix.submatrix_mul_equiv, hQ₁]
    rfl
  have hR₂ : R.transpose * R = 1 := by
    dsimp only [R]
    rw [Matrix.transpose_submatrix]
    change Q.transpose.submatrix q (Equiv.refl _) *
      Q.submatrix (Equiv.refl _) q = 1
    rw [Matrix.submatrix_mul_equiv, hQ₂, Matrix.submatrix_one_equiv]
  refine ⟨R, hR₁, hR₂, v, ?_, fun j => hM.eigenvalues_pos (q j), ?_⟩
  · intro i j hij
    dsimp only [v, Matrix.IsHermitian.eigenvalues, q, Equiv.trans_apply,
      Fin.revPerm_apply]
    change hM.isHermitian.eigenvalues₀ (e.symm (e _)) ≤
      hM.isHermitian.eigenvalues₀ (e.symm (e _))
    simp only [Equiv.symm_apply_apply]
    apply hM.isHermitian.eigenvalues₀_antitone
    exact (Fin.cast_le_cast (Fintype.card_fin d).symm).mpr
      (Fin.rev_le_rev.mpr hij)
  · ext i j
    have h := congrFun (hM.isHermitian.mulVec_eigenvectorBasis (q j)) i
    rw [Matrix.mul_diagonal]
    simpa only [Matrix.mul_apply, R, Q,
      Matrix.submatrix_apply, id_eq, Matrix.IsHermitian.eigenvectorUnitary_apply,
      Matrix.mulVec, dotProduct, Pi.smul_apply, smul_eq_mul, v, mul_comm] using h

/-- The full-spark quadratic bound, with an actual exact correction supplied
by exponential-sum minimization and whitening. -/
theorem fullSpark_quadratic_correction {n d : ℕ}
    (hn : 0 < n) (hd : d ≤ n) (X : Frame n d) (η : ℝ)
    (hX_spark : IsFullSpark X) (hX_norm : IsEqualNorm X)
    (hX_parseval : IsNearlyParseval η X) :
    ∃ W : Frame n d, IsEqualNormParseval W ∧
      sqDistance X W ≤ η * (d : ℝ) * ((d : ℝ) - 1) := by
  obtain ⟨r, hr, M, hM, hW⟩ := exists_fullSpark_radial_scaling hn hd X hX_spark
  obtain ⟨R, hR₁, hR₂, v, hv_mono, hv_pos, hMR⟩ :=
    exists_ordered_posDef_diagonalization M hM
  let W := Matrix.diagonal r * X * M
  refine ⟨W, hW, ?_⟩
  rw [← sqDistance_mul_orthogonal X W R hR₁]
  apply radial_correction_quadratic_bound (X * R) (W * R) v r η
    (hX_norm.mul_orthogonal R hR₁) (hX_parseval.mul_orthogonal R hR₂)
    ⟨hW.1.mul_orthogonal R hR₂, hW.2.mul_orthogonal R hR₁⟩
    hv_mono (fun j => le_of_lt (hv_pos j)) (fun i => le_of_lt (hr i))
  intro i j
  have hWR : W * R = Matrix.diagonal r * (X * R) * Matrix.diagonal v := by
    dsimp only [W]
    rw [Matrix.mul_assoc, hMR]
    simp only [Matrix.mul_assoc]
  rw [hWR, Matrix.mul_diagonal, Matrix.diagonal_mul]
  ring

end Paulsen
