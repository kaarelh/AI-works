import Paulsen.Paper.SampleAuxQuad

/-!
# Helpers for `ModerateSample`: the event (S1)

* the net bound on `‖Z‖_op`, using the coordinates `Z = VᵀH ∈ ℝ^{(n-d)×d}` (flag 8 of the
  blueprint: this gives `5^{(n-d)+d} = 5ⁿ`);
* the tail of `‖Zᵀv_i‖² = rowNormSq H i` from `lem:gauss`(a);
* `‖Zu_i‖² ≤ ‖Z‖²‖u_i‖²`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

section Generic

variable {ι κ : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
set_option linter.unusedSectionVars false

omit [DecidableEq ι] in
theorem norm_sq_toEuclideanLin_eq (M : Matrix ι κ ℝ) (x : EuclideanSpace ℝ κ) :
    ‖Matrix.toEuclideanLin M x‖ ^ 2 = matrixQuadratic (M.transpose * M) (fun q => x q) := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, matrixQuadratic, Matrix.mul_apply,
    Matrix.transpose_apply, pow_two, Finset.sum_mul, Finset.mul_sum]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl; intro q _
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl; intro q' _
  apply Finset.sum_congr rfl; intro p _
  ring

theorem opNorm_le_of_norm_sq_le (M : Matrix ι κ ℝ) {c : ℝ} (hc : 0 ≤ c)
    (h : ∀ x : EuclideanSpace ℝ κ, ‖Matrix.toEuclideanLin M x‖ ^ 2 ≤ c ^ 2 * ‖x‖ ^ 2) :
    opNorm M ≤ c := by
  apply ContinuousLinearMap.opNorm_le_bound _ hc
  intro x
  have hx := h x
  rw [← mul_pow] at hx
  exact (pow_le_pow_iff_left₀ (norm_nonneg _) (by positivity) (by norm_num)).mp hx

theorem matrixQuadratic_mul_transpose_nonneg (M : Matrix ι κ ℝ) (x : ι → ℝ) :
    0 ≤ matrixQuadratic (M * M.transpose) x := by
  rw [← linDual_norm_sq]
  positivity

omit [DecidableEq κ] in
theorem frobSq_diagonal (v : ι → ℝ) : frobSq (Matrix.diagonal v) = ∑ p, v p ^ 2 := by
  unfold frobSq
  apply Finset.sum_congr rfl; intro p _
  rw [Finset.sum_eq_single p]
  · simp
  · intro q _ hq; simp [Matrix.diagonal_apply_ne _ (Ne.symm hq)]
  · simp

end Generic

/-- An isometry has operator norm at most `1`. -/
theorem opNorm_isometry_le {n m : ℕ} (V : Matrix (Fin n) (Fin m) ℝ)
    (hV : V.transpose * V = 1) : opNorm V ≤ 1 := by
  apply opNorm_le_of_norm_sq_le V zero_le_one
  intro x
  rw [norm_sq_toEuclideanLin_eq, hV, one_pow, one_mul, EuclideanSpace.real_norm_sq_eq]
  simp [matrixQuadratic, Matrix.one_apply, pow_two]

/-- The coordinate map `vec H ↦ vec (VᵀH)` has norm at most `1`. -/
theorem opNorm_kronecker_complement_le {n d m : ℕ} (U : Frame n d) (V : Matrix (Fin n) (Fin m) ℝ)
    (hcomp : U * U.transpose + V * V.transpose = 1) :
    opNorm (Matrix.kronecker V.transpose (1 : Matrix (Fin d) (Fin d) ℝ)) ≤ 1 := by
  apply opNorm_le_of_norm_sq_le _ zero_le_one
  intro x
  rw [one_pow, one_mul, EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq]
  have hVV : V * V.transpose = 1 - U * U.transpose := by rw [← hcomp]; abel
  have hcol : ∀ b : Fin d, ∑ r, (∑ i, V i r * x (i, b)) ^ 2 ≤ ∑ i, x (i, b) ^ 2 := by
    intro b
    have he : ∑ r, (∑ i, V i r * x (i, b)) ^ 2 =
        matrixQuadratic (V * V.transpose) (fun i => x (i, b)) := by
      simp only [matrixQuadratic, Matrix.mul_apply, Matrix.transpose_apply, pow_two,
        Finset.sum_mul, Finset.mul_sum]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl; intro i _
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl; intro i' _
      apply Finset.sum_congr rfl; intro r _
      ring
    rw [he, hVV, matrixQuadratic_sub]
    have h1 : matrixQuadratic (1 : Matrix (Fin n) (Fin n) ℝ) (fun i => x (i, b)) =
        ∑ i, x (i, b) ^ 2 := by simp [matrixQuadratic, Matrix.one_apply, pow_two]
    rw [h1]
    linarith [matrixQuadratic_mul_transpose_nonneg U (fun i => x (i, b))]
  have hK : ∀ (r : Fin m) (b : Fin d),
      (Matrix.toEuclideanLin (Matrix.kronecker V.transpose (1 : Matrix (Fin d) (Fin d) ℝ)) x)
        (r, b) = ∑ i, V i r * x (i, b) := by
    intro r b
    simp only [Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, Matrix.kronecker,
      Matrix.kroneckerMap_apply, Matrix.transpose_apply, Matrix.one_apply, Fintype.sum_prod_type,
      mul_ite, mul_one, mul_zero, ite_mul, zero_mul, Finset.sum_ite_eq, Finset.mem_univ, if_true,
      WithLp.ofLp_toLp]
  rw [Fintype.sum_prod_type, Fintype.sum_prod_type, Finset.sum_comm,
    Finset.sum_comm (f := fun i b => x (i, b) ^ 2)]
  apply Finset.sum_le_sum
  intro b _
  simp_rw [hK]
  exact hcol b

/-- Net bound for the filtered noise (paper (S1), first claim), via `lem:gauss`(c) applied to
`Z = VᵀH ∈ ℝ^{(n-d)×d}`. -/
theorem noise_opNorm_tail {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (hn : 0 < n)
    (hdn : d ≤ n) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) :
    (gaussAmb n d).real {g | 16 < opNorm (moderateNoise U ρ g)} ≤
      2 * 5 ^ n * Real.exp (-8 * n) := by
  obtain ⟨V, hV, hcomp, _⟩ := IsParseval.exists_complement U hU hdn
  let K := Matrix.kronecker V.transpose (1 : Matrix (Fin d) (Fin d) ℝ)
  let C := K * noiseF U ρ
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hZ : ∀ g : FrameVector n d,
      frameOfVector (Matrix.toEuclideanLin C g) = V.transpose * moderateNoise U ρ g := by
    intro g
    ext r b
    have h1 : Matrix.toEuclideanLin C g =
        Matrix.toEuclideanLin K (Matrix.toEuclideanLin (noiseF U ρ) g) := by
      simp only [C, Matrix.toEuclideanLin, Matrix.toLpLin_mul_same, LinearMap.comp_apply]
    simp only [frameOfVector, h1, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, K,
      Matrix.kronecker, Matrix.kroneckerMap_apply, Matrix.transpose_apply, Matrix.one_apply,
      Fintype.sum_prod_type, mul_ite, mul_one, mul_zero, ite_mul, zero_mul, Finset.sum_ite_eq,
      Finset.mem_univ, if_true, WithLp.ofLp_toLp, Matrix.mul_apply]
    apply Finset.sum_congr rfl; intro x _
    rw [moderateNoise_apply]
    simp only [Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, Fintype.sum_prod_type]
  have hH : ∀ g : FrameVector n d,
      moderateNoise U ρ g = V * (V.transpose * moderateNoise U ρ g) := by
    intro g
    have hh := (moderateNoise_spec U hU hp hρ).2.2 g
    have hVV : V * V.transpose = 1 - U * U.transpose := by rw [← hcomp]; abel
    rw [← Matrix.mul_assoc, hVV, Matrix.sub_mul, Matrix.one_mul, Matrix.mul_assoc, hh,
      Matrix.mul_zero, sub_zero]
  have hVop := opNorm_isometry_le V hV
  have hsub : {g : FrameVector n d | 16 < opNorm (moderateNoise U ρ g)} ⊆
      {g | 16 < opNorm (frameOfVector (Matrix.toEuclideanLin C g))} := by
    intro g hg
    simp only [Set.mem_setOf_eq] at hg ⊢
    rw [hZ g]
    have hle : opNorm (moderateNoise U ρ g) ≤ opNorm (V.transpose * moderateNoise U ρ g) := by
      conv_lhs => rw [hH g]
      calc opNorm (V * (V.transpose * moderateNoise U ρ g)) ≤
            opNorm V * opNorm (V.transpose * moderateNoise U ρ g) :=
          euclidean_operator_norm_mul_le _ _
        _ ≤ 1 * opNorm (V.transpose * moderateNoise U ρ g) :=
          mul_le_mul_of_nonneg_right hVop (opNorm_nonneg' _)
        _ = _ := one_mul _
    linarith
  have hCop : opNorm C ^ 2 ≤ ((Real.sqrt n)⁻¹) ^ 2 := by
    have hKop := opNorm_kronecker_complement_le U V hcomp
    have hF := opNorm_noiseF_sq hU hρ.le
    have hc : opNorm C ≤ opNorm (noiseF U ρ) := by
      calc opNorm C ≤ opNorm K * opNorm (noiseF U ρ) := euclidean_operator_norm_mul_le _ _
        _ ≤ 1 * opNorm (noiseF U ρ) := mul_le_mul_of_nonneg_right hKop (opNorm_nonneg' _)
        _ = _ := one_mul _
    rw [inv_pow, Real.sq_sqrt hnR.le]
    calc opNorm C ^ 2 ≤ opNorm (noiseF U ρ) ^ 2 := pow_le_pow_left₀ (opNorm_nonneg' _) hc 2
      _ ≤ 1 / (n : ℝ) := hF
      _ = (n : ℝ)⁻¹ := one_div _
  have ht := lem_gauss_c (r := n - d) (s := d) C (by norm_num : (0 : ℝ) ≤ 16) hCop
  have hpow : n - d + d = n := Nat.sub_add_cancel hdn
  rw [hpow] at ht
  have hexp : -(16 : ℝ) ^ 2 / (32 * ((Real.sqrt n)⁻¹) ^ 2) = -8 * n := by
    rw [inv_pow, Real.sq_sqrt hnR.le]
    field_simp
    norm_num
  rw [hexp] at ht
  exact (measureReal_mono hsub).trans ht

/-- The row-selection quadratic form `vec H ↦ ‖row_i H‖²`. -/
def rowSelector (n d : ℕ) (i : Fin n) : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.diagonal fun p => if p.1 = i then 1 else 0

theorem rowSelector_isHermitian (n d : ℕ) (i : Fin n) : (rowSelector n d i).IsHermitian :=
  Matrix.isHermitian_diagonal _

theorem euclideanQuadratic_rowSelector {n d : ℕ} (i : Fin n) (z : FrameVector n d) :
    euclideanQuadratic (rowSelector n d i) z = rowNormSq (frameOfVector z) i := by
  rw [euclideanQuadratic_eq_matrixQuadratic, rowSelector, matrixQuadratic_diagonal,
    Fintype.sum_prod_type, Finset.sum_eq_single i]
  · simp [rowNormSq, frameOfVector]
  · intro b _ hb; simp [hb]
  · simp

theorem frobSq_rowSelector (n d : ℕ) (i : Fin n) : frobSq (rowSelector n d i) = d := by
  rw [rowSelector, frobSq_diagonal, Fintype.sum_prod_type, Finset.sum_eq_single i]
  · simp
  · intro b _ hb; simp [hb]
  · simp

theorem opNorm_rowSelector_le (n d : ℕ) (i : Fin n) : opNorm (rowSelector n d i) ≤ 1 := by
  apply opNorm_le_of_norm_sq_le _ zero_le_one
  intro x
  rw [one_pow, one_mul, EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq]
  apply Finset.sum_le_sum
  intro p _
  simp only [rowSelector, Matrix.toLpLin_apply, Matrix.mulVec_diagonal, WithLp.ofLp_toLp]
  split_ifs <;> simp [sq_nonneg]

/-- Tail of `‖Zᵀv_i‖²` (paper (S1), second claim, for one `i`), from `lem:gauss`(a) with
`u = 2a`. -/
theorem noise_row_tail {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (hn : 0 < n) (hd : 0 < d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    (gaussAmb n d).real {g | 3 * ((d : ℝ) / n) < rowNormSq (moderateNoise U ρ g) i} ≤
      2 * Real.exp (-(d : ℝ) / 4) := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  have hdR : (0 : ℝ) < d := Nat.cast_pos.mpr hd
  have ha : 0 < (d : ℝ) / n := div_pos hdR hnR
  set A := rowSelector n d i
  set F := noiseF U ρ
  have hF := opNorm_noiseF_sq hU hρ
  have hcov : opNorm (F * F.transpose) ≤ 1 / (n : ℝ) := by
    have := euclidean_operator_norm_covariance F
    unfold opNorm
    rw [this]
    exact hF
  have hq : ∀ g : FrameVector n d,
      euclideanQuadratic A (Matrix.toEuclideanLin F g) = rowNormSq (moderateNoise U ρ g) i :=
    fun g => euclideanQuadratic_rowSelector i _
  have htr : (F.transpose * A * F).trace ≤ (d : ℝ) / n := by
    have h1 := integral_euclideanQuadratic_stdGaussian (F.transpose * A * F)
      (isHermitian_quadratic_pullback A (rowSelector_isHermitian n d i) F)
    have h2 : ∀ g : FrameVector n d, euclideanQuadratic (F.transpose * A * F) g =
        rowNormSq (moderateNoise U ρ g) i := fun g => by
      rw [← euclideanQuadratic_linear_image, hq]
    simp_rw [h2] at h1
    rw [← h1]
    exact integral_rowNormSq_gaussianImage_le F hF i
  have ht := quad_tail_of_bounds A (rowSelector_isHermitian n d i) F (s := 1 / (n : ℝ))
    (V := d) (B := 1) (u := 2 * ((d : ℝ) / n)) (by positivity) (by positivity) hcov
    (frobSq_rowSelector n d i).le (opNorm_rowSelector_le n d i)
  have hsub : {g : FrameVector n d | 3 * ((d : ℝ) / n) < rowNormSq (moderateNoise U ρ g) i} ⊆
      {g | 2 * ((d : ℝ) / n) < |euclideanQuadratic A (Matrix.toEuclideanLin F g) -
        (F.transpose * A * F).trace|} := by
    intro g hg
    simp only [Set.mem_setOf_eq] at hg ⊢
    rw [hq g]
    exact lt_of_lt_of_le (by linarith) (le_abs_self _)
  have hmin : min ((2 * ((d : ℝ) / n)) ^ 2 / ((1 / (n : ℝ)) ^ 2 * d))
      (2 * ((d : ℝ) / n) / (1 / (n : ℝ) * 1)) = 2 * d := by
    have e1 : (2 * ((d : ℝ) / n)) ^ 2 / ((1 / (n : ℝ)) ^ 2 * d) = 4 * d := by
      field_simp; ring
    have e2 : 2 * ((d : ℝ) / n) / (1 / (n : ℝ) * 1) = 2 * d := by field_simp
    rw [e1, e2]
    exact min_eq_right (by linarith)
  rw [hmin] at ht
  have he : -(1 / 8 : ℝ) * (2 * d) = -(d : ℝ) / 4 := by ring
  rw [he] at ht
  exact (measureReal_mono hsub).trans ht

/-- `‖Zu_i‖² ≤ ‖Z‖² ‖u_i‖²`. -/
theorem rowNormSq_mul_transpose_le {n d : ℕ} (U H : Frame n d) (i : Fin n) :
    rowNormSq (U * H.transpose) i ≤ opNorm H ^ 2 * rowNormSq U i := by
  have h := (Matrix.toEuclideanLin H).toContinuousLinearMap.le_opNorm (WithLp.toLp 2 (U i))
  have h2 := pow_le_pow_left₀ (norm_nonneg _) h 2
  rw [mul_pow, EuclideanSpace.real_norm_sq_eq, EuclideanSpace.real_norm_sq_eq] at h2
  have e1 : rowNormSq (U * H.transpose) i =
      ∑ r, ((Matrix.toEuclideanLin H).toContinuousLinearMap (WithLp.toLp 2 (U i)) r) ^ 2 := by
    simp only [rowNormSq, Matrix.mul_apply, Matrix.transpose_apply,
      LinearMap.coe_toContinuousLinearMap', Matrix.toLpLin_apply, Matrix.mulVec, dotProduct,
      WithLp.ofLp_toLp]
    apply Finset.sum_congr rfl; intro r _
    congr 1
    apply Finset.sum_congr rfl; intro c _
    ring
  rw [e1]
  exact h2

end

end Paulsen.Paper
