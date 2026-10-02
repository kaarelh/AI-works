import Paulsen.Paper.ToolboxAuxSpectral
import Paulsen.GaussianQuadraticForm
import Paulsen.ComplementReduction
import Mathlib.LinearAlgebra.UnitaryGroup
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
# Helper for `Paulsen.Paper.Toolbox`: `lem:align`, the exact minimum over `O(d)`.

For a square matrix `C` with singular values `σ_k = √(eig_k(CᵀC))` we show
`max_{R ∈ O(d)} tr(CR) = ∑ σ_k` (von Neumann's trace inequality for one orthogonal factor),
via an explicit singular value decomposition built from an orthonormal-basis extension.
-/

namespace Paulsen.Paper.ToolboxAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

variable {d : ℕ}

/-- The singular values of a square real matrix, as in `crossSingularValues`. -/
def sv (C : Matrix (Fin d) (Fin d) ℝ) : Fin d → ℝ :=
  fun k => Real.sqrt ((Matrix.posSemidef_conjTranspose_mul_self C).isHermitian.eigenvalues k)

theorem sv_eig_nonneg (C : Matrix (Fin d) (Fin d) ℝ) (k : Fin d) :
    0 ≤ (Matrix.posSemidef_conjTranspose_mul_self C).isHermitian.eigenvalues k :=
  (Matrix.posSemidef_conjTranspose_mul_self C).eigenvalues_nonneg k

theorem sv_sq (C : Matrix (Fin d) (Fin d) ℝ) (k : Fin d) :
    sv C k ^ 2 = (Matrix.posSemidef_conjTranspose_mul_self C).isHermitian.eigenvalues k :=
  Real.sq_sqrt (sv_eig_nonneg C k)

theorem sv_nonneg (C : Matrix (Fin d) (Fin d) ℝ) (k : Fin d) : 0 ≤ sv C k := Real.sqrt_nonneg _

/-- `∑ σ_k² = ‖C‖_F²`. -/
theorem sum_sv_sq (C : Matrix (Fin d) (Fin d) ℝ) :
    ∑ k, sv C k ^ 2 = (C.transpose * C).trace := by
  simp only [sv_sq]
  have h := (Matrix.posSemidef_conjTranspose_mul_self C).isHermitian.trace_eq_sum_eigenvalues
  rw [show C.transpose * C = Cᴴ * C by rw [Matrix.conjTranspose_eq_transpose_of_trivial], h]
  simp

/-- The right singular frame: `Z = C V` has orthogonal columns of lengths `σ_k`. -/
theorem svd_Z (C : Matrix (Fin d) (Fin d) ℝ) :
    ∃ V : Matrix (Fin d) (Fin d) ℝ, V.transpose * V = 1 ∧ V * V.transpose = 1 ∧
      (C * V).transpose * (C * V) = Matrix.diagonal (fun k => sv C k ^ 2) := by
  have hH := (Matrix.posSemidef_conjTranspose_mul_self C).isHermitian
  have hdec := eig_decomp hH
  refine ⟨eigQ hH, eigQ_transpose_mul hH, eigQ_mul_transpose hH, ?_⟩
  have hQ1 := eigQ_transpose_mul hH
  simp only [sv_sq]
  set Q := eigQ hH
  set e := hH.eigenvalues
  clear_value Q e
  rw [Matrix.conjTranspose_eq_transpose_of_trivial] at hdec
  rw [Matrix.transpose_mul]
  calc Q.transpose * C.transpose * (C * Q) = Q.transpose * (C.transpose * C) * Q := by
        simp only [Matrix.mul_assoc]
    _ = _ := by
      rw [hdec]
      simp only [← Matrix.mul_assoc, hQ1, Matrix.one_mul]
      rw [Matrix.mul_assoc, hQ1, Matrix.mul_one]

theorem col_sq_sum_of_gram {Z : Matrix (Fin d) (Fin d) ℝ} {c : Fin d → ℝ}
    (hZ : Z.transpose * Z = Matrix.diagonal c) (k l : Fin d) :
    ∑ j, Z j k * Z j l = if k = l then c k else 0 := by
  have h := congrArg (fun M => M k l) hZ
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.diagonal_apply] at h
  exact h

/-- von Neumann upper bound: `tr(CR) ≤ ∑ σ_k` for orthogonal `R`. -/
theorem trace_mul_orth_le (C R : Matrix (Fin d) (Fin d) ℝ) (hR : R * R.transpose = 1) :
    (C * R).trace ≤ ∑ k, sv C k := by
  obtain ⟨V, hV1, hV2, hZ⟩ := svd_Z C
  set Z := C * V with hZdef
  set S := V.transpose * R with hSdef
  have hSS : S * S.transpose = 1 := by
    rw [hSdef, Matrix.transpose_mul, Matrix.transpose_transpose]
    calc V.transpose * R * (R.transpose * V) = V.transpose * (R * R.transpose) * V := by
          simp only [Matrix.mul_assoc]
      _ = 1 := by rw [hR, Matrix.mul_one, hV1]
  have htr : (C * R).trace = ∑ k, ∑ j, S k j * Z j k := by
    have : C * R = Z * S := by
      rw [hZdef, hSdef]
      calc C * R = C * (V * V.transpose) * R := by rw [hV2, Matrix.mul_one]
        _ = _ := by simp only [Matrix.mul_assoc]
    rw [this, Matrix.trace, Finset.sum_comm]
    simp only [Matrix.diag_apply, Matrix.mul_apply]
    apply Finset.sum_congr rfl; intro k _
    apply Finset.sum_congr rfl; intro j _; ring
  rw [htr]
  apply Finset.sum_le_sum; intro k _
  refine (Real.sum_mul_le_sqrt_mul_sqrt _ _ _).trans_eq ?_
  have h1 : ∑ j, S k j ^ 2 = 1 := by
    have h := congrArg (fun M => M k k) hSS
    simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.one_apply_eq] at h
    simpa [pow_two] using h
  have h2 : ∑ j, Z j k ^ 2 = sv C k ^ 2 := by
    have h := col_sq_sum_of_gram hZ k k
    simp only [if_true] at h
    simpa [pow_two] using h
  rw [h1, h2, Real.sqrt_one, one_mul, Real.sqrt_sq (sv_nonneg C k)]

/-- The maximum in von Neumann's inequality is attained. -/
theorem exists_orth_trace_eq (C : Matrix (Fin d) (Fin d) ℝ) :
    ∃ R : Matrix (Fin d) (Fin d) ℝ, R * R.transpose = 1 ∧ R.transpose * R = 1 ∧
      (C * R).trace = ∑ k, sv C k := by
  obtain ⟨V, hV1, hV2, hZ⟩ := svd_Z C
  set Z := C * V with hZdef
  have hcol := col_sq_sum_of_gram hZ
  let v : Fin d → EuclideanSpace ℝ (Fin d) :=
    fun k => WithLp.toLp 2 (fun j => Z j k / sv C k)
  let s : Set (Fin d) := {k | sv C k ≠ 0}
  have hv : Orthonormal ℝ (s.restrict v) := by
    rw [orthonormal_iff_ite]
    intro a b
    have hinner : inner ℝ (v a) (v b) = ∑ j, Z j a * Z j b / (sv C a * sv C b) := by
      simp only [v, PiLp.inner_apply, RCLike.inner_apply, conj_trivial]
      apply Finset.sum_congr rfl; intro j _
      field_simp
    simp only [Set.restrict_apply]
    rw [hinner, ← Finset.sum_div, hcol]
    have ha : sv C a ≠ 0 := a.2
    by_cases hab : a = b
    · subst hab
      simp only [if_true]
      rw [← pow_two]; exact div_self (pow_ne_zero 2 ha)
    · have hab' : (a : Fin d) ≠ b := fun h => hab (Subtype.ext h)
      simp [hab', hab]
  obtain ⟨b, hb⟩ := hv.exists_orthonormalBasis_extension_of_card_eq
    (by simp : Module.finrank ℝ (EuclideanSpace ℝ (Fin d)) = Fintype.card (Fin d))
  let S : Matrix (Fin d) (Fin d) ℝ := Matrix.of fun k j => b k j
  have hSS : S * S.transpose = 1 := by
    ext k l
    simp only [S, Matrix.mul_apply, Matrix.transpose_apply, Matrix.of_apply]
    have := b.orthonormal
    rw [orthonormal_iff_ite] at this
    have h := this k l
    simp only [PiLp.inner_apply, RCLike.inner_apply, conj_trivial] at h
    rw [Matrix.one_apply]
    rw [← h]
    apply Finset.sum_congr rfl; intro j _; ring
  have hStS : S.transpose * S = 1 := mul_eq_one_comm.mp hSS
  refine ⟨V * S, ?_, ?_, ?_⟩
  · rw [Matrix.transpose_mul]
    calc V * S * (S.transpose * V.transpose) = V * (S * S.transpose) * V.transpose := by
          simp only [Matrix.mul_assoc]
      _ = 1 := by rw [hSS, Matrix.mul_one, hV2]
  · rw [Matrix.transpose_mul]
    calc S.transpose * V.transpose * (V * S) = S.transpose * (V.transpose * V) * S := by
          simp only [Matrix.mul_assoc]
      _ = 1 := by rw [hV1, Matrix.mul_one, hStS]
  · rw [← Matrix.mul_assoc, ← hZdef, Matrix.trace]
    simp only [Matrix.diag_apply, Matrix.mul_apply]
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl; intro k _
    by_cases hk : sv C k = 0
    · have hz : ∀ j, Z j k = 0 := by
        have h := hcol k k
        simp only [if_true] at h
        rw [hk, show (0 : ℝ) ^ 2 = 0 by ring] at h
        have h' : ∑ j, Z j k ^ 2 = 0 := by simpa [pow_two] using h
        intro j
        have := (Finset.sum_eq_zero_iff_of_nonneg (fun j _ => sq_nonneg (Z j k))).mp h' j
          (Finset.mem_univ j)
        exact pow_eq_zero_iff (n := 2) (by norm_num) |>.mp this
      simp [hz, hk]
    · have hbk : b k = v k := hb k hk
      have hSk : ∀ j, S k j = Z j k / sv C k := by
        intro j
        simp only [S, Matrix.of_apply, hbk, v]
      simp only [hSk]
      have h := hcol k k
      simp only [if_true] at h
      calc ∑ j, Z j k * (Z j k / sv C k) = (∑ j, Z j k * Z j k) / sv C k := by
            rw [Finset.sum_div]; apply Finset.sum_congr rfl; intro j _; ring
        _ = sv C k := by rw [h]; field_simp

/-- For Parseval `U, W`, the singular values of `UᵀW` lie in `[0,1]`. -/
theorem sv_le_one {n : ℕ} (U W : Frame n d) (hU : IsParseval U) (hW : IsParseval W)
    (k : Fin d) : sv (U.transpose * W) k ≤ 1 := by
  set C := U.transpose * W
  have hH := (Matrix.posSemidef_conjTranspose_mul_self C).isHermitian
  have h1 := abs_eigenvalue_le_euclidean_operator_norm _ hH k
  have hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖ ≤ 1 := by
    refine (euclidean_operator_norm_mul_le _ _).trans ?_
    rw [euclidean_operator_norm_transpose]
    have h1 := hU.euclidean_operator_norm_le_one
    have h2 := hW.euclidean_operator_norm_le_one
    nlinarith [norm_nonneg (Matrix.toEuclideanLin U).toContinuousLinearMap,
      norm_nonneg (Matrix.toEuclideanLin W).toContinuousLinearMap]
  have h2 : ‖(Matrix.toEuclideanLin (Cᴴ * C)).toContinuousLinearMap‖ ≤ 1 := by
    rw [Matrix.conjTranspose_eq_transpose_of_trivial]
    refine (euclidean_operator_norm_mul_le _ _).trans ?_
    rw [euclidean_operator_norm_transpose]
    nlinarith [norm_nonneg (Matrix.toEuclideanLin C).toContinuousLinearMap]
  have h3 : (Matrix.posSemidef_conjTranspose_mul_self C).isHermitian.eigenvalues k ≤ 1 :=
    (le_abs_self _).trans (h1.trans h2)
  unfold sv
  rw [Real.sqrt_le_one]
  exact h3

theorem sqDistance_mul_orth_eq {n : ℕ} (U W : Frame n d) (hU : IsParseval U)
    (hW : IsParseval W) (R : Matrix (Fin d) (Fin d) ℝ) (hR : R.transpose * R = 1) :
    sqDistance U (W * R) = 2 * (d : ℝ) - 2 * ((U.transpose * W) * R).trace := by
  rw [sqDistance_eq_energies_sub_trace]
  have h1 : U.transpose * U = 1 := hU
  have h2 : (W * R).transpose * (W * R) = 1 := by
    rw [Matrix.transpose_mul]
    calc R.transpose * W.transpose * (W * R) = R.transpose * (W.transpose * W) * R := by
          simp only [Matrix.mul_assoc]
      _ = 1 := by rw [show W.transpose * W = 1 from hW, Matrix.mul_one, hR]
  rw [h1, h2, Matrix.trace_one, Fintype.card_fin, Matrix.mul_assoc]
  ring

/-- `lem:align`, the main display, with `σ = sv (UᵀW)` and `frobSq` unfolded. -/
theorem lem_align_display {n : ℕ} (U W : Frame n d) (hU : IsParseval U) (hW : IsParseval W) :
    (∀ k, 0 ≤ sv (U.transpose * W) k ∧ sv (U.transpose * W) k ≤ 1) ∧
    IsLeast {c | ∃ R ∈ Matrix.orthogonalGroup (Fin d) ℝ, c = sqDistance U (W * R)}
      (2 * ∑ k, (1 - sv (U.transpose * W) k)) ∧
    2 * ∑ k, (1 - sv (U.transpose * W) k) ≤
      sqDistance (frameProjection U) (frameProjection W) ∧
    sqDistance (frameProjection U) (frameProjection W) =
      2 * ∑ k, (1 - sv (U.transpose * W) k ^ 2) ∧
    sqDistance (frameProjection U) (frameProjection W) =
      2 * ∑ i, ∑ j, (((1 : Matrix (Fin n) (Fin n) ℝ) - frameProjection U) * W) i j ^ 2 ∧
    sqDistance (frameProjection U) (frameProjection W) ≤ 2 * sqDistance U W := by
  set C := U.transpose * W with hCdef
  have hbnd : ∀ k, 0 ≤ sv C k ∧ sv C k ≤ 1 := fun k => ⟨sv_nonneg C k, sv_le_one U W hU hW k⟩
  have hsum1 : ∑ k, (1 - sv C k) = (d : ℝ) - ∑ k, sv C k := by
    rw [Finset.sum_sub_distrib]; simp
  have hsum2 : ∑ k, (1 - sv C k ^ 2) = (d : ℝ) - ∑ k, sv C k ^ 2 := by
    rw [Finset.sum_sub_distrib]; simp
  have hPQ : sqDistance (frameProjection U) (frameProjection W) =
      2 * ∑ k, (1 - sv C k ^ 2) := by
    rw [parseval_projection_distance_crossGram U W hU hW, hsum2, sum_sv_sq,
      Matrix.trace_mul_comm C.transpose C]
    ring
  refine ⟨hbnd, ⟨?_, ?_⟩, ?_, hPQ, projection_sqDistance_eq_twice_residual U W hU hW,
    projection_sqDistance_le_twice U W hU hW⟩
  · obtain ⟨R, hR1, hR2, htr⟩ := exists_orth_trace_eq C
    refine ⟨R, (Matrix.mem_orthogonalGroup_iff (Fin d) ℝ).mpr hR1, ?_⟩
    rw [sqDistance_mul_orth_eq U W hU hW R hR2, ← hCdef, htr, hsum1]
    ring
  · rintro c ⟨R, hR, rfl⟩
    have hR1 : R * R.transpose = 1 := (Matrix.mem_orthogonalGroup_iff (Fin d) ℝ).mp hR
    have hR2 : R.transpose * R = 1 := (Matrix.mem_orthogonalGroup_iff' (Fin d) ℝ).mp hR
    rw [sqDistance_mul_orth_eq U W hU hW R hR2, ← hCdef, hsum1]
    have := trace_mul_orth_le C R hR1
    linarith
  · rw [hPQ]
    apply mul_le_mul_of_nonneg_left _ (by norm_num)
    apply Finset.sum_le_sum; intro k _
    have := hbnd k
    nlinarith

end

end Paulsen.Paper.ToolboxAux
