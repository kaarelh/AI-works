import Paulsen.ScalingDistance
import Paulsen.CompactCorrection
import Paulsen.FullSparkDensity

/-!
# Static orthogonal alignment of Parseval frames

Polar alignment replaces a horizontal lift. Singular cross-Gram matrices
are handled by density and compactness of the orthogonal group.
-/

namespace Paulsen

open Matrix Filter
open scoped BigOperators MatrixOrder Topology

/-- The right polar factor for an invertible real square matrix. -/
theorem exists_polar_alignment_of_isUnit {d : ℕ}
    (A : Matrix (Fin d) (Fin d) ℝ) (hA : IsUnit A) :
    ∃ R : Matrix (Fin d) (Fin d) ℝ,
      R * R.transpose = 1 ∧ R.transpose * R = 1 ∧ (A * R).PosSemidef := by
  let B := A * A.transpose
  have hB : B.PosSemidef := by
    simpa only [B, Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_self_mul_conjTranspose A
  let H := CFC.sqrt B
  have hH : H.PosSemidef := Matrix.nonneg_iff_posSemidef.mp (CFC.sqrt_nonneg B)
  have hHsym : H.transpose = H := by
    simpa only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
      using hH.isHermitian
  have hHsq : H * H = B := by
    simpa only [pow_two] using CFC.sq_sqrt B hB.nonneg
  have hl : A⁻¹ * A = 1 := Matrix.nonsing_inv_mul A
    ((Matrix.isUnit_iff_isUnit_det A).mp hA)
  have hr : A * A⁻¹ = 1 := Matrix.mul_nonsing_inv A
    ((Matrix.isUnit_iff_isUnit_det A).mp hA)
  have hlt : A.transpose * A⁻¹.transpose = 1 := by
    simpa only [Matrix.transpose_mul, Matrix.transpose_one] using congrArg Matrix.transpose hl
  let R := A⁻¹ * H
  have hRR : R * R.transpose = 1 := by
    dsimp only [R]
    rw [Matrix.transpose_mul, hHsym]
    calc
      A⁻¹ * H * (H * A⁻¹.transpose) = A⁻¹ * (H * H) * A⁻¹.transpose := by
        simp only [Matrix.mul_assoc]
      _ = A⁻¹ * (A * A.transpose) * A⁻¹.transpose := by rw [hHsq]
      _ = 1 := by
        rw [← Matrix.mul_assoc A⁻¹ A, hl, Matrix.one_mul, hlt]
  refine ⟨R, hRR, mul_eq_one_comm.mp hRR, ?_⟩
  have hAR : A * R = H := by
    dsimp only [R]
    rw [← Matrix.mul_assoc, hr, Matrix.one_mul]
  rwa [hAR]

theorem isClosed_posSemidef_matrix (d : ℕ) :
    IsClosed {A : Matrix (Fin d) (Fin d) ℝ | A.PosSemidef} := by
  have hh : IsClosed {A : Matrix (Fin d) (Fin d) ℝ | A.IsHermitian} := by
    simp only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
    exact isClosed_eq (by fun_prop) continuous_id
  have hq : IsClosed {A : Matrix (Fin d) (Fin d) ℝ |
      ∀ x : Fin d → ℝ, 0 ≤ star x ⬝ᵥ (A *ᵥ x)} := by
    simp only [Set.setOf_forall]
    apply isClosed_iInter
    intro x
    apply isClosed_le continuous_const
    simp only [dotProduct, Matrix.mulVec]
    fun_prop
  simpa only [Matrix.posSemidef_iff_dotProduct_mulVec, Set.setOf_and] using hh.inter hq

theorem isCompact_parseval_square (d : ℕ) :
    IsCompact {R : Matrix (Fin d) (Fin d) ℝ | IsParseval R} := by
  have hc : IsClosed {R : Matrix (Fin d) (Fin d) ℝ | IsParseval R} :=
    isClosed_eq (by fun_prop) continuous_const
  apply (isCompact_Icc : IsCompact (Set.Icc (fun _ _ => (-1 : ℝ))
    (fun _ _ => (1 : ℝ)))).of_isClosed_subset hc
  intro R hR
  constructor
  · intro i j
    exact (abs_le.mp (hR.entry_abs_le_one i j)).1
  · intro i j
    exact (abs_le.mp (hR.entry_abs_le_one i j)).2

set_option maxHeartbeats 1000000 in
theorem isClosed_polar_alignable (d : ℕ) :
    IsClosed {A : Matrix (Fin d) (Fin d) ℝ |
      ∃ R : Matrix (Fin d) (Fin d) ℝ, IsParseval R ∧ (A * R).PosSemidef} := by
  let K := {R : Matrix (Fin d) (Fin d) ℝ | IsParseval R}
  letI : CompactSpace K := isCompact_iff_compactSpace.mp (isCompact_parseval_square d)
  let S : Set (Matrix (Fin d) (Fin d) ℝ × K) := {p | (p.1 * p.2.val).PosSemidef}
  have hS : IsClosed S := by
    exact (isClosed_posSemidef_matrix d).preimage (by fun_prop)
  have hc := isClosedMap_fst_of_compactSpace S hS
  have heq : Prod.fst '' S = {A : Matrix (Fin d) (Fin d) ℝ |
      ∃ R : Matrix (Fin d) (Fin d) ℝ, IsParseval R ∧ (A * R).PosSemidef} := by
    ext A
    constructor
    · rintro ⟨⟨A', R⟩, hR, hAA⟩
      change A' = A at hAA
      subst A'
      exact ⟨R.val, R.property, hR⟩
    · rintro ⟨R, hR, hAR⟩
      exact ⟨(A, ⟨R, hR⟩), hAR, rfl⟩
  rwa [heq] at hc

/-- Every real square matrix admits a right orthogonal alignment with a
positive-semidefinite result, including singular matrices. -/
theorem exists_polar_alignment {d : ℕ} (A : Matrix (Fin d) (Fin d) ℝ) :
    ∃ R : Matrix (Fin d) (Fin d) ℝ,
      R * R.transpose = 1 ∧ R.transpose * R = 1 ∧ (A * R).PosSemidef := by
  have h : ∃ R : Matrix (Fin d) (Fin d) ℝ, IsParseval R ∧ (A * R).PosSemidef := by
    refine (dense_fullSpark d d).induction
      (P := fun B => ∃ R : Matrix (Fin d) (Fin d) ℝ, IsParseval R ∧ (B * R).PosSemidef)
      ?_ (isClosed_polar_alignable d) A
    intro B hB
    have hdet : B.det ≠ 0 := by
      have hb := hB (Function.Embedding.refl (Fin d))
      change (B.submatrix id id).det ≠ 0 at hb
      simpa only [Matrix.submatrix_id_id] using hb
    obtain ⟨R, _hRR, hRtR, hBR⟩ := exists_polar_alignment_of_isUnit B
      ((Matrix.isUnit_iff_isUnit_det B).mpr (isUnit_iff_ne_zero.mpr hdet))
    exact ⟨R, hRtR, hBR⟩
  obtain ⟨R, hR, hAR⟩ := h
  exact ⟨R, mul_eq_one_comm.mp hR, hR, hAR⟩

/-- A Parseval synthesis matrix is a Euclidean contraction (indeed an isometry). -/
theorem IsParseval.euclidean_operator_norm_le_one {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) :
    ‖(Matrix.toEuclideanLin U).toContinuousLinearMap‖ ≤ 1 := by
  apply ContinuousLinearMap.opNorm_le_bound _ zero_le_one
  intro x
  have h := hU.frameEnergy_eq x.ofLp
  have hn : ‖Matrix.toEuclideanLin U x‖ ^ 2 = ‖x‖ ^ 2 := by
    simpa only [EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
      frameEnergy, vectorNormSq, Matrix.mulVec, dotProduct] using h
  change ‖Matrix.toEuclideanLin U x‖ ≤ 1 * ‖x‖
  rw [one_mul]
  nlinarith [norm_nonneg (Matrix.toEuclideanLin U x), norm_nonneg x]

/-- For a positive-semidefinite contraction, trace dominates squared
Frobenius norm. -/
theorem trace_square_le_trace_of_posSemidef_contraction {d : ℕ}
    (H : Matrix (Fin d) (Fin d) ℝ) (hH : H.PosSemidef)
    (hnorm : ‖(Matrix.toEuclideanLin H).toContinuousLinearMap‖ ≤ 1) :
    (H * H).trace ≤ H.trace := by
  have hsym : H.transpose = H := by
    simpa only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
      using hH.isHermitian
  have hsquares : (H * H).trace = ∑ i, (hH.isHermitian.eigenvalues i) ^ 2 := by
    rw [eigenvalues_sq_sum_eq_entry_sq_sum H hH.isHermitian,
      entry_sq_sum_eq_trace, hsym]
  rw [hsquares, hH.isHermitian.trace_eq_sum_eigenvalues]
  apply Finset.sum_le_sum
  intro i _
  have hi0 := hH.eigenvalues_nonneg i
  have hi1 : hH.isHermitian.eigenvalues i ≤ 1 :=
    (le_abs_self _).trans ((abs_eigenvalue_le_euclidean_operator_norm H
      hH.isHermitian i).trans hnorm)
  change hH.isHermitian.eigenvalues i ^ 2 ≤ hH.isHermitian.eigenvalues i
  nlinarith

theorem sqDistance_eq_energies_sub_trace {n d : ℕ} (U V : Frame n d) :
    sqDistance U V = (U.transpose * U).trace + (V.transpose * V).trace -
      2 * (U.transpose * V).trace := by
  rw [sqDistance_eq_trace_sub, Matrix.transpose_sub, Matrix.sub_mul,
    Matrix.mul_sub, Matrix.mul_sub, Matrix.trace_sub, Matrix.trace_sub, Matrix.trace_sub]
  have hcross : (V.transpose * U).trace = (U.transpose * V).trace := by
    rw [← Matrix.trace_transpose (V.transpose * U), Matrix.transpose_mul,
      Matrix.transpose_transpose]
  rw [hcross]
  ring

theorem parseval_projection_distance_crossGram {n d : ℕ}
    (U V : Frame n d) (hU : IsParseval U) (hV : IsParseval V) :
    sqDistance (frameProjection U) (frameProjection V) =
      2 * (d : ℝ) - 2 * ((U.transpose * V) * (U.transpose * V).transpose).trace := by
  rw [projection_sqDistance_eq_twice_residual U V hU hV,
    projection_residual_sq_sum U V hU, hV]
  have hcross : (V.transpose * frameProjection U * V).trace =
      ((U.transpose * V) * (U.transpose * V).transpose).trace := by
    rw [Matrix.transpose_mul, Matrix.transpose_transpose]
    calc
      (V.transpose * frameProjection U * V).trace =
          ((V.transpose * U) * (U.transpose * V)).trace := by
        simp only [frameProjection, Matrix.mul_assoc]
      _ = _ := Matrix.trace_mul_comm _ _
  rw [hcross]
  simp only [Matrix.trace_one, Fintype.card_fin]
  ring

/-- Static Procrustes alignment: equally sized Parseval frames can be rotated
so their squared distance is at most the squared distance of their projections.
No invertibility hypothesis on the cross-Gram matrix is required. -/
theorem exists_parseval_frame_alignment {n d : ℕ}
    (U V : Frame n d) (hU : IsParseval U) (hV : IsParseval V) :
    ∃ R : Matrix (Fin d) (Fin d) ℝ,
      R * R.transpose = 1 ∧ R.transpose * R = 1 ∧
      sqDistance U (V * R) ≤ sqDistance (frameProjection U) (frameProjection V) := by
  let A := U.transpose * V
  obtain ⟨R, hRR, hRtR, hH⟩ := exists_polar_alignment A
  have hAnorm : ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ ≤ 1 := by
    have hb := euclidean_operator_norm_mul_le U.transpose V
    rw [euclidean_operator_norm_transpose] at hb
    calc
      _ ≤ ‖(Matrix.toEuclideanLin U).toContinuousLinearMap‖ *
          ‖(Matrix.toEuclideanLin V).toContinuousLinearMap‖ := hb
      _ ≤ 1 * 1 := mul_le_mul hU.euclidean_operator_norm_le_one
        hV.euclidean_operator_norm_le_one (norm_nonneg _) zero_le_one
      _ = 1 := one_mul 1
  have hHnorm : ‖(Matrix.toEuclideanLin (A * R)).toContinuousLinearMap‖ ≤ 1 := by
    calc
      _ ≤ ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ *
          ‖(Matrix.toEuclideanLin R).toContinuousLinearMap‖ :=
        euclidean_operator_norm_mul_le A R
      _ ≤ 1 * 1 := mul_le_mul hAnorm
        (IsParseval.euclidean_operator_norm_le_one hRtR) (norm_nonneg _) zero_le_one
      _ = 1 := one_mul 1
  have hHsym : (A * R).transpose = A * R := by
    simpa only [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial]
      using hH.isHermitian
  have hHH : (A * R) * (A * R) = A * A.transpose := by
    nth_rw 2 [← hHsym]
    rw [Matrix.transpose_mul]
    calc
      A * R * (R.transpose * A.transpose) = A * (R * R.transpose) * A.transpose := by
        simp only [Matrix.mul_assoc]
      _ = A * A.transpose := by rw [hRR, Matrix.mul_one]
  have htrace := trace_square_le_trace_of_posSemidef_contraction (A * R) hH hHnorm
  rw [hHH] at htrace
  refine ⟨R, hRR, hRtR, ?_⟩
  rw [sqDistance_eq_energies_sub_trace, hU,
    hV.mul_orthogonal R hRtR, parseval_projection_distance_crossGram U V hU hV]
  simp only [Matrix.trace_one, Fintype.card_fin]
  change (d : ℝ) + d - 2 * (U.transpose * (V * R)).trace ≤
    2 * d - 2 * (A * A.transpose).trace
  rw [← Matrix.mul_assoc]
  change (d : ℝ) + d - 2 * (A * R).trace ≤ 2 * d - 2 * (A * A.transpose).trace
  linarith

end Paulsen
