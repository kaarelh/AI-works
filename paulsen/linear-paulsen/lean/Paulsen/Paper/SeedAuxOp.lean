import Paulsen.Paper.Moderate

/-!
# Helper for `Paulsen.Paper.ModerateSeed`: operator-norm, Frobenius and row-norm calculus

Generic facts about `opNorm`, `frobSq`, `rowNormSq` and the inverse square root
`invSqrt (1 + s (WᵀW))` used in the proof of `lem:retraction`.
-/

namespace Paulsen.Paper.SeedAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-! ### Basic operator-norm facts -/

theorem opNorm_nonneg {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ]
    (M : Matrix ι κ ℝ) : 0 ≤ opNorm M := norm_nonneg _

theorem opNorm_add_le {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ]
    (A B : Matrix ι κ ℝ) : opNorm (A + B) ≤ opNorm A + opNorm B := by
  unfold opNorm
  rw [map_add, map_add]
  exact norm_add_le _ _

theorem opNorm_smul {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ]
    (c : ℝ) (A : Matrix ι κ ℝ) : opNorm (c • A) = |c| * opNorm A := by
  unfold opNorm
  rw [map_smul, map_smul, norm_smul, Real.norm_eq_abs]

theorem opNorm_neg {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ]
    (A : Matrix ι κ ℝ) : opNorm (-A) = opNorm A := by
  unfold opNorm
  rw [map_neg, map_neg, norm_neg]

theorem opNorm_sub_le {ι κ : Type*} [Fintype ι] [Fintype κ] [DecidableEq κ]
    (A B : Matrix ι κ ℝ) : opNorm (A - B) ≤ opNorm A + opNorm B := by
  rw [sub_eq_add_neg]
  exact (opNorm_add_le A (-B)).trans_eq (by rw [opNorm_neg])

theorem opNorm_mul_le {ι κ υ : Type*} [Fintype ι] [Fintype κ] [Fintype υ] [DecidableEq κ]
    [DecidableEq υ] (C : Matrix ι κ ℝ) (D : Matrix κ υ ℝ) :
    opNorm (C * D) ≤ opNorm C * opNorm D :=
  euclidean_operator_norm_mul_le C D

/-- `‖Hx‖² ≤ ‖H‖² ‖x‖²`. -/
theorem frameEnergy_le_opNorm_sq {n d : ℕ} (H : Frame n d) (x : Fin d → ℝ) :
    frameEnergy H x ≤ opNorm H ^ 2 * vectorNormSq x := by
  have h := (Matrix.toEuclideanLin H).toContinuousLinearMap.le_opNorm (WithLp.toLp 2 x)
  have hs := pow_le_pow_left₀ (norm_nonneg _) h 2
  simpa only [opNorm, mul_pow, EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
    LinearMap.coe_toContinuousLinearMap', WithLp.ofLp_toLp, frameEnergy, vectorNormSq,
    Matrix.mulVec, dotProduct] using hs

/-- An energy bound gives an operator-norm bound. -/
theorem opNorm_le_of_frameEnergy {n d : ℕ} (V : Frame n d) {c : ℝ} (hc : 0 ≤ c)
    (hV : ∀ x, frameEnergy V x ≤ c ^ 2 * vectorNormSq x) : opNorm V ≤ c := by
  unfold opNorm
  apply ContinuousLinearMap.opNorm_le_bound _ hc
  intro x
  have hsq : ‖Matrix.toEuclideanLin V x‖ ^ 2 ≤ c ^ 2 * ‖x‖ ^ 2 := by
    simpa only [EuclideanSpace.real_norm_sq_eq, Matrix.toLpLin_apply,
      frameEnergy, vectorNormSq, Matrix.mulVec, dotProduct] using hV x.ofLp
  change ‖Matrix.toEuclideanLin V x‖ ≤ c * ‖x‖
  have hnonneg := mul_nonneg hc (norm_nonneg x)
  have hprod : (c * ‖x‖) ^ 2 = c ^ 2 * ‖x‖ ^ 2 := by rw [mul_pow]
  nlinarith [norm_nonneg (Matrix.toEuclideanLin V x)]

theorem opNorm_parseval_le_one {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    opNorm U ≤ 1 :=
  opNorm_le_of_frameEnergy U zero_le_one (fun x => by rw [hU.frameEnergy_eq]; simp)

theorem opNorm_one_le {k : Type*} [Fintype k] [DecidableEq k] :
    opNorm (1 : Matrix k k ℝ) ≤ 1 := by
  unfold opNorm
  apply ContinuousLinearMap.opNorm_le_bound _ zero_le_one
  intro x
  simp

/-! ### Quadratic forms and symmetric matrices -/

/-- For a symmetric matrix a quadratic-form bound gives the operator-norm bound. -/
theorem opNorm_le_of_quad {k : Type*} [Fintype k] [DecidableEq k] (A : Matrix k k ℝ)
    (hA : A.transpose = A) {c : ℝ} (hc : 0 ≤ c)
    (h : ∀ x : k → ℝ, |matrixQuadratic A x| ≤ c * ∑ i, x i ^ 2) : opNorm A ≤ c := by
  have hH : A.IsHermitian := by
    unfold Matrix.IsHermitian
    rw [Matrix.conjTranspose_eq_transpose_of_trivial, hA]
  apply euclidean_operator_norm_le_of_eigenvalues A hH c hc
  intro i
  rw [ToolboxAux.eigenvalue_eq_quadratic hH i]
  have h1 := h (fun a => ToolboxAux.eigQ hH a i)
  rw [ToolboxAux.eigQ_col_norm hH i, mul_one] at h1
  exact h1

/-- `(A M Aᵀ)_{ii}` is the quadratic form of `M` at the `i`-th row of `A`. -/
theorem conj_diag_eq_quad {n d : ℕ} (A : Matrix (Fin n) (Fin d) ℝ)
    (M : Matrix (Fin d) (Fin d) ℝ) (i : Fin n) :
    (A * M * A.transpose) i i = matrixQuadratic M (A i) := by
  simp only [Matrix.mul_apply, Matrix.transpose_apply, matrixQuadratic, Finset.sum_mul]
  rw [Finset.sum_comm]

theorem abs_conj_diag_le {n d : ℕ} (A : Matrix (Fin n) (Fin d) ℝ)
    (M : Matrix (Fin d) (Fin d) ℝ) (i : Fin n) :
    |(A * M * A.transpose) i i| ≤ opNorm M * rowNormSq A i := by
  rw [conj_diag_eq_quad]
  exact ToolboxAux.abs_quad_le_opNorm M (A i)

theorem opNorm_gram_le {n d : ℕ} (W : Frame n d) {K : ℝ} (hK : opNorm W ^ 2 ≤ K) :
    opNorm (W.transpose * W) ≤ K := by
  have hK0 : 0 ≤ K := (sq_nonneg _).trans hK
  apply opNorm_le_of_quad _ (by rw [Matrix.transpose_mul, Matrix.transpose_transpose]) hK0
  intro x
  rw [← ToolboxAux.frameEnergy_eq_quad]
  have h0 : 0 ≤ frameEnergy W x := Finset.sum_nonneg fun _ _ => sq_nonneg _
  rw [abs_of_nonneg h0]
  exact (frameEnergy_le_opNorm_sq W x).trans
    (mul_le_mul_of_nonneg_right hK (Finset.sum_nonneg fun _ _ => sq_nonneg _))

/-! ### Rows and Frobenius norms -/

/-- Rows of `A Bᵀ`: `‖(A Bᵀ)_i‖² ≤ ‖B‖² ‖A_i‖²`. -/
theorem rowNormSq_mul_transpose_le_opNorm {n m d : ℕ} (A : Matrix (Fin n) (Fin d) ℝ)
    (B : Matrix (Fin m) (Fin d) ℝ) (i : Fin n) :
    rowNormSq (A * B.transpose) i ≤ opNorm B ^ 2 * rowNormSq A i := by
  have he : rowNormSq (A * B.transpose) i = frameEnergy B (A i) := by
    simp only [rowNormSq, frameEnergy, Matrix.mul_apply, Matrix.transpose_apply]
    apply Finset.sum_congr rfl; intro k _
    congr 1
    apply Finset.sum_congr rfl; intro j _
    ring
  rw [he]
  exact frameEnergy_le_opNorm_sq B (A i)

theorem rowNormSq_mul_symm_le_opNorm {n d : ℕ} (A : Matrix (Fin n) (Fin d) ℝ)
    (B : Matrix (Fin d) (Fin d) ℝ) (hB : B.transpose = B) (i : Fin n) :
    rowNormSq (A * B) i ≤ opNorm B ^ 2 * rowNormSq A i := by
  have := rowNormSq_mul_transpose_le_opNorm A B i
  rwa [hB] at this

theorem frobSq_eq_sum_rowNormSq {n d : ℕ} (A : Matrix (Fin n) (Fin d) ℝ) :
    frobSq A = ∑ i, rowNormSq A i := rfl

theorem frobSq_nonneg {n d : ℕ} (A : Matrix (Fin n) (Fin d) ℝ) : 0 ≤ frobSq A :=
  Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _

theorem frobSq_mul_symm_le_opNorm {n d : ℕ} (A : Matrix (Fin n) (Fin d) ℝ)
    (B : Matrix (Fin d) (Fin d) ℝ) (hB : B.transpose = B) :
    frobSq (A * B) ≤ opNorm B ^ 2 * frobSq A := by
  rw [frobSq_eq_sum_rowNormSq, frobSq_eq_sum_rowNormSq, Finset.mul_sum]
  exact Finset.sum_le_sum fun i _ => rowNormSq_mul_symm_le_opNorm A B hB i

theorem frobSq_le_opNorm_sq {n d : ℕ} (Z : Frame n d) :
    frobSq Z ≤ d * opNorm Z ^ 2 := by
  have h : frobSq Z = ∑ j : Fin d, frameEnergy Z (Pi.single j 1) := by
    unfold frobSq frameEnergy
    rw [Finset.sum_comm]
    apply Finset.sum_congr rfl; intro j _
    apply Finset.sum_congr rfl; intro i _
    congr 1
    simp [Pi.single_apply]
  rw [h]
  calc ∑ j : Fin d, frameEnergy Z (Pi.single j 1)
      ≤ ∑ _j : Fin d, opNorm Z ^ 2 := by
        apply Finset.sum_le_sum; intro j _
        have := frameEnergy_le_opNorm_sq Z (Pi.single j 1)
        have hv : vectorNormSq (Pi.single j (1 : ℝ) : Fin d → ℝ) = 1 := by
          simp [vectorNormSq, Pi.single_apply]
        rwa [hv, mul_one] at this
    _ = _ := by simp

theorem sqrt_frobSq_eq_norm {n d : ℕ} (A : Frame n d) :
    Real.sqrt (frobSq A) = ‖normalFrobVector A‖ := by
  rw [frobSq_eq_sum_rowNormSq, ← Linear.normalFrobVector_norm_sq_eq_sum,
    Real.sqrt_sq (norm_nonneg _)]

theorem opNorm_le_sqrt_frobSq {n d : ℕ} (A : Frame n d) :
    opNorm A ≤ Real.sqrt (frobSq A) := by
  rw [sqrt_frobSq_eq_norm]
  exact Linear.opNorm_le_frob A

theorem opNorm_sq_le_frobSq {n d : ℕ} (A : Frame n d) :
    opNorm A ^ 2 ≤ frobSq A := by
  have h := opNorm_le_sqrt_frobSq A
  have h2 := pow_le_pow_left₀ (opNorm_nonneg A) h 2
  rwa [Real.sq_sqrt (frobSq_nonneg A)] at h2

theorem sqrt_frobSq_add_le {n d : ℕ} (A B : Frame n d) :
    Real.sqrt (frobSq (A + B)) ≤ Real.sqrt (frobSq A) + Real.sqrt (frobSq B) := by
  rw [sqrt_frobSq_eq_norm, sqrt_frobSq_eq_norm, sqrt_frobSq_eq_norm]
  have : normalFrobVector (A + B) = normalFrobVector A + normalFrobVector B := rfl
  rw [this]
  exact norm_add_le _ _

theorem sqrt_frobSq_smul {n d : ℕ} (c : ℝ) (A : Frame n d) :
    Real.sqrt (frobSq (c • A)) = |c| * Real.sqrt (frobSq A) := by
  rw [sqrt_frobSq_eq_norm, sqrt_frobSq_eq_norm]
  have : normalFrobVector (c • A) = c • normalFrobVector A := rfl
  rw [this, norm_smul, Real.norm_eq_abs]

theorem sqrt_rowNormSq_eq_norm {n d : ℕ} (A : Frame n d) (i : Fin n) :
    Real.sqrt (rowNormSq A i) = ‖(WithLp.toLp 2 (A i) : EuclideanSpace ℝ (Fin d))‖ := by
  rw [EuclideanSpace.norm_eq]
  congr 1
  simp [rowNormSq, Real.norm_eq_abs, sq_abs]

theorem sqrt_rowNormSq_add_le {n d : ℕ} (A B : Frame n d) (i : Fin n) :
    Real.sqrt (rowNormSq (A + B) i) ≤
      Real.sqrt (rowNormSq A i) + Real.sqrt (rowNormSq B i) := by
  rw [sqrt_rowNormSq_eq_norm, sqrt_rowNormSq_eq_norm, sqrt_rowNormSq_eq_norm]
  have : (WithLp.toLp 2 ((A + B) i) : EuclideanSpace ℝ (Fin d)) =
      WithLp.toLp 2 (A i) + WithLp.toLp 2 (B i) := rfl
  rw [this]
  exact norm_add_le _ _

theorem sqrt_rowNormSq_smul {n d : ℕ} (c : ℝ) (A : Frame n d) (i : Fin n) :
    Real.sqrt (rowNormSq (c • A) i) = |c| * Real.sqrt (rowNormSq A i) := by
  rw [Linear.rowNormSq_smul, Real.sqrt_mul (sq_nonneg c), Real.sqrt_sq_eq_abs]

theorem rowNormSq_le_frobSq {n d : ℕ} (A : Frame n d) (i : Fin n) :
    rowNormSq A i ≤ frobSq A := by
  rw [frobSq_eq_sum_rowNormSq]
  exact Finset.single_le_sum (fun j _ => rowNormSq_nonneg A j) (Finset.mem_univ i)

/-- `|∑_k A_ik B_ik| ≤ ‖A_i‖ ‖B_i‖`. -/
theorem abs_row_inner_le {n d : ℕ} (A B : Frame n d) (i : Fin n) :
    |∑ k, A i k * B i k| ≤ Real.sqrt (rowNormSq A i) * Real.sqrt (rowNormSq B i) := by
  rw [← Real.sqrt_mul (rowNormSq_nonneg A i)]
  apply Real.abs_le_sqrt
  exact Finset.sum_mul_sq_le_sq_mul_sq _ _ _


/-! ### Quadratic forms: linearity and the complete graph -/

theorem mq_add {ι : Type*} [Fintype ι] (A B : Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (A + B) x = matrixQuadratic A x + matrixQuadratic B x := by
  simp only [matrixQuadratic, Matrix.add_apply, mul_add, add_mul, Finset.sum_add_distrib]

theorem mq_smul {ι : Type*} [Fintype ι] (c : ℝ) (A : Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (c • A) x = c * matrixQuadratic A x := by
  simp only [matrixQuadratic, Matrix.smul_apply, smul_eq_mul, Finset.mul_sum]
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _
  ring

/-- `xᵀ𝖪x ≥ (n - b)‖x‖²` for `x` supported on a set of size `b`. -/
theorem completeLaplacian_supported {n : ℕ} (B : Finset (Fin n)) (x : Fin n → ℝ)
    (hx : ∀ j, j ∉ B → x j = 0) :
    ((n : ℝ) - B.card) * vectorNormSq x ≤ matrixQuadratic (completeLaplacian n) x := by
  have hq : matrixQuadratic (completeLaplacian n) x = n * vectorNormSq x - (∑ i, x i) ^ 2 := by
    simp only [matrixQuadratic, completeLaplacian, Matrix.sub_apply, Matrix.smul_apply,
      Matrix.one_apply, Matrix.of_apply, smul_eq_mul, vectorNormSq, mul_sub, sub_mul,
      Finset.sum_sub_distrib, mul_ite, mul_one, mul_zero, ite_mul, zero_mul,
      Finset.sum_ite_eq, Finset.mem_univ, if_true, pow_two, Finset.sum_mul, Finset.mul_sum]
    congr 1
    · apply Finset.sum_congr rfl; intro i _; ring
    · rw [Finset.sum_comm]
  have hsum : ∑ i, x i = ∑ i ∈ B, x i :=
    (Finset.sum_subset (Finset.subset_univ B) (fun j _ hj => hx j hj)).symm
  have hsq : ∑ i, x i ^ 2 = ∑ i ∈ B, x i ^ 2 :=
    (Finset.sum_subset (Finset.subset_univ B) (fun j _ hj => by rw [hx j hj]; ring)).symm
  have hcs : (∑ i ∈ B, x i) ^ 2 ≤ B.card * ∑ i ∈ B, x i ^ 2 := sq_sum_le_card_mul_sum_sq
  rw [hq, hsum]
  unfold vectorNormSq
  rw [hsq]
  nlinarith


/-- For a Parseval `U`, `xᵀL_Px = ∑_i x_i (L_w x)_i` with the weights `w_ij = P_ij²`. -/
theorem mq_projectionLaplacian_eq_weighted {n d : ℕ} (U : Frame n d) (hU : IsParseval U)
    (x : Fin n → ℝ) :
    matrixQuadratic (projectionLaplacian (frameProjection U)) x =
      ∑ i, x i * weightedLaplacian (fun i j => frameProjection U i j ^ 2) x i := by
  have h1 := (lem_energy U hU).1 x
  have hq : matrixQuadratic (projectionLaplacian (frameProjection U)) x =
      ∑ i, x i * (projectionLaplacian (frameProjection U) *ᵥ x) i := by
    simp only [matrixQuadratic, Matrix.mulVec, dotProduct, Finset.mul_sum, mul_assoc]
  rw [hq]
  apply Finset.sum_congr rfl; intro i _
  rw [h1]
  congr 1
  unfold weightedLaplacian
  apply Finset.sum_congr rfl; intro j _
  by_cases hij : i = j
  · subst hij; simp
  · simp [hij]

/-! ### The matrix `G = 1 + s WᵀW` and its inverse square root -/

section Gram

variable {d : ℕ}

theorem gram_add_posDef {n : ℕ} (W : Frame n d) {s : ℝ} (hs : 0 ≤ s) :
    (1 + s • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ).PosDef := by
  have hS : (W.transpose * W).PosSemidef := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_conjTranspose_mul_self W
  exact Matrix.PosDef.add_posSemidef Matrix.PosDef.one (hS.smul hs)

/-- Orthogonal conjugates of a bounded diagonal have bounded operator norm. -/
theorem opNorm_conj_diag_le (Q : Matrix (Fin d) (Fin d) ℝ) (hQ : Q * Q.transpose = 1)
    (c : Fin d → ℝ) {C : ℝ} (hC : 0 ≤ C) (hc : ∀ i, |c i| ≤ C) :
    opNorm (Q * Matrix.diagonal c * Q.transpose) ≤ C := by
  apply opNorm_le_of_quad _ (by
    rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose,
      Matrix.diagonal_transpose, Matrix.mul_assoc]) hC
  intro x
  -- the quadratic form is `∑ c_k (Qᵀx)_k²`
  set y : Fin d → ℝ := Q.transpose *ᵥ x with hy
  have hdot : ∀ M : Matrix (Fin d) (Fin d) ℝ, matrixQuadratic M x = x ⬝ᵥ (M *ᵥ x) := by
    intro M
    simp only [matrixQuadratic, dotProduct, Matrix.mulVec, Finset.mul_sum]
    apply Finset.sum_congr rfl; intro i _
    apply Finset.sum_congr rfl; intro j _
    ring
  have hxQ : x ᵥ* Q = y := by
    rw [hy, ← Matrix.vecMul_transpose, Matrix.transpose_transpose]
  have hquad : matrixQuadratic (Q * Matrix.diagonal c * Q.transpose) x =
      ∑ k, c k * y k ^ 2 := by
    rw [hdot, ← Matrix.mulVec_mulVec, ← Matrix.mulVec_mulVec, Matrix.dotProduct_mulVec, hxQ]
    simp only [dotProduct, Matrix.mulVec_diagonal, ← hy]
    apply Finset.sum_congr rfl; intro k _
    ring
  have hnorm : ∑ k, y k ^ 2 = ∑ i, x i ^ 2 := by
    have h1 : ∑ k, y k ^ 2 = y ⬝ᵥ y := by simp [dotProduct, pow_two]
    have h2 : ∑ i, x i ^ 2 = x ⬝ᵥ x := by simp [dotProduct, pow_two]
    rw [h1, h2]
    conv_lhs => rw [hy]
    rw [Matrix.dotProduct_mulVec, Matrix.vecMul_transpose, Matrix.mulVec_mulVec, hQ,
      Matrix.one_mulVec, dotProduct_comm]
  rw [hquad, ← hnorm]
  calc |∑ k, c k * y k ^ 2| ≤ ∑ k, |c k * y k ^ 2| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ k, C * y k ^ 2 := by
        apply Finset.sum_le_sum; intro k _
        rw [abs_mul, abs_of_nonneg (sq_nonneg (y k))]
        exact mul_le_mul_of_nonneg_right (hc k) (sq_nonneg _)
    _ = C * ∑ k, y k ^ 2 := by rw [Finset.mul_sum]

/-- The spectral data of `G = 1 + s WᵀW`. -/
theorem gram_spectral {n : ℕ} (W : Frame n d) {s K : ℝ} (hs : 0 ≤ s)
    (hK : opNorm W ^ 2 ≤ K) :
    ∃ Q : Matrix (Fin d) (Fin d) ℝ, ∃ e : Fin d → ℝ,
      Q.transpose * Q = 1 ∧ Q * Q.transpose = 1 ∧
      (∀ i, 1 ≤ e i ∧ e i ≤ 1 + s * K) ∧
      (1 + s • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ) =
        Q * Matrix.diagonal e * Q.transpose ∧
      invSqrt (1 + s • (W.transpose * W)) =
        Q * Matrix.diagonal (fun i => (Real.sqrt (e i))⁻¹) * Q.transpose ∧
      (1 + s • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ =
        Q * Matrix.diagonal (fun i => (e i)⁻¹) * Q.transpose := by
  set G : Matrix (Fin d) (Fin d) ℝ := 1 + s • (W.transpose * W) with hGdef
  have hG : G.PosDef := gram_add_posDef W hs
  have hH := hG.isHermitian
  refine ⟨ToolboxAux.eigQ hH, hH.eigenvalues, ToolboxAux.eigQ_transpose_mul hH,
    ToolboxAux.eigQ_mul_transpose hH, ?_, ToolboxAux.eig_decomp hH, ?_, ?_⟩
  · intro i
    rw [ToolboxAux.eigenvalue_eq_quadratic hH i]
    set q : Fin d → ℝ := fun a => ToolboxAux.eigQ hH a i with hq
    have hq1 : ∑ a, q a ^ 2 = 1 := ToolboxAux.eigQ_col_norm hH i
    have hexp : ∑ a, ∑ b, ToolboxAux.eigQ hH a i * G a b * ToolboxAux.eigQ hH b i =
        ∑ a, q a ^ 2 + s * frameEnergy W q := by
      rw [ToolboxAux.frameEnergy_eq_quad]
      simp only [hGdef, matrixQuadratic, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul,
        Matrix.one_apply, hq, mul_add, add_mul, Finset.sum_add_distrib, Finset.mul_sum,
        mul_ite, mul_one, mul_zero, ite_mul, zero_mul, Finset.sum_ite_eq, Finset.mem_univ,
        if_true, pow_two]
      congr 1
      apply Finset.sum_congr rfl; intro a _
      apply Finset.sum_congr rfl; intro b _
      ring
    rw [hexp, hq1]
    have hE0 : 0 ≤ frameEnergy W q := Finset.sum_nonneg fun _ _ => sq_nonneg _
    have hE1 : frameEnergy W q ≤ K := by
      have := frameEnergy_le_opNorm_sq W q
      have hv : vectorNormSq q = 1 := hq1
      rw [hv, mul_one] at this
      exact this.trans hK
    constructor
    · nlinarith [mul_nonneg hs hE0]
    · nlinarith [mul_le_mul_of_nonneg_left hE1 hs]
  · unfold invSqrt
    exact ToolboxAux.cfc_decomp hH _
  · have hspec := (invSqrt_spec G hG).2.1
    rw [← hspec]
    unfold invSqrt
    rw [ToolboxAux.cfc_decomp hH, ToolboxAux.conj_diag_mul _ (ToolboxAux.eigQ_transpose_mul hH)]
    have hfun : (fun i => (Real.sqrt (hH.eigenvalues i))⁻¹ * (Real.sqrt (hH.eigenvalues i))⁻¹) =
        fun i => (hH.eigenvalues i)⁻¹ := by
      funext i
      have he : 0 < hH.eigenvalues i := hG.eigenvalues_pos i
      rw [← mul_inv, Real.mul_self_sqrt he.le]
    rw [hfun]

/-- All the operator-norm facts on `G = 1 + s WᵀW` used for `lem:retraction`. -/
theorem gram_facts {n : ℕ} (W : Frame n d) {s K : ℝ} (hs : 0 ≤ s)
    (hK : opNorm W ^ 2 ≤ K) :
    (1 + s • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ).PosDef ∧
    (invSqrt (1 + s • (W.transpose * W))).transpose = invSqrt (1 + s • (W.transpose * W)) ∧
    invSqrt (1 + s • (W.transpose * W)) * invSqrt (1 + s • (W.transpose * W)) =
      (1 + s • (W.transpose * W))⁻¹ ∧
    invSqrt (1 + s • (W.transpose * W)) * (1 + s • (W.transpose * W)) *
      invSqrt (1 + s • (W.transpose * W)) = 1 ∧
    ((1 + s • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹).transpose =
      (1 + s • (W.transpose * W))⁻¹ ∧
    opNorm ((1 + s • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1) ≤ s * K ∧
    opNorm (invSqrt (1 + s • (W.transpose * W)) - 1) ≤ s * K ∧
    opNorm ((1 + s • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹) ≤ 1 := by
  have hK0 : 0 ≤ K := (sq_nonneg _).trans hK
  obtain ⟨Q, e, hQ1, hQ2, he, hGe, hS, hGi⟩ := gram_spectral W hs hK
  have hG := gram_add_posDef W hs
  have hspec := invSqrt_spec _ hG
  have hconjT : ∀ c : Fin d → ℝ,
      (Q * Matrix.diagonal c * Q.transpose).transpose = Q * Matrix.diagonal c * Q.transpose := by
    intro c
    rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose,
      Matrix.diagonal_transpose, Matrix.mul_assoc]
  have hone : (1 : Matrix (Fin d) (Fin d) ℝ) = Q * Matrix.diagonal (fun _ => (1 : ℝ)) *
      Q.transpose := (ToolboxAux.conj_diag_one Q hQ2).symm
  have hsub : ∀ c c' : Fin d → ℝ, Q * Matrix.diagonal c * Q.transpose -
      Q * Matrix.diagonal c' * Q.transpose = Q * Matrix.diagonal (c - c') * Q.transpose := by
    intro c c'
    rw [show Matrix.diagonal (c - c') = Matrix.diagonal c - Matrix.diagonal c' from
      (Matrix.diagonal_sub c c').symm, Matrix.mul_sub, Matrix.sub_mul]
  have hsK : 0 ≤ s * K := mul_nonneg hs hK0
  refine ⟨hG, ?_, hspec.2.1, hspec.2.2, ?_, ?_, ?_, ?_⟩
  · rw [hS]; exact hconjT _
  · rw [hGi]; exact hconjT _
  · rw [hGi, hone, hsub]
    apply opNorm_conj_diag_le Q hQ2 _ hsK
    intro i
    have h1 := (he i).1
    have h2 := (he i).2
    have hpos : 0 < e i := by linarith
    simp only [Pi.sub_apply]
    rw [abs_le]
    have hinv : (e i)⁻¹ * e i = 1 := inv_mul_cancel₀ hpos.ne'
    have hinv0 : 0 < (e i)⁻¹ := inv_pos.mpr hpos
    constructor
    · -- `1/e ≥ 2 - e`
      have : 2 - e i ≤ (e i)⁻¹ := by nlinarith [sq_nonneg (e i - 1)]
      linarith
    · have : (e i)⁻¹ ≤ 1 := inv_le_one_of_one_le₀ h1
      linarith
  · rw [hS, hone, hsub]
    apply opNorm_conj_diag_le Q hQ2 _ hsK
    intro i
    have h1 := (he i).1
    have h2 := (he i).2
    simp only [Pi.sub_apply]
    have hsq1 : 1 ≤ Real.sqrt (e i) := by
      rw [show (1 : ℝ) = Real.sqrt 1 by simp]; exact Real.sqrt_le_sqrt h1
    have hinv1 : (Real.sqrt (e i))⁻¹ ≤ 1 := inv_le_one_of_one_le₀ hsq1
    have hinv0 : 0 < (Real.sqrt (e i))⁻¹ := by positivity
    rw [abs_of_nonpos (by linarith)]
    -- `1 - 1/√e ≤ √e - 1 ≤ e - 1 ≤ sK`
    have hse : Real.sqrt (e i) ≤ e i := by
      rw [Real.sqrt_le_left (by linarith)]
      nlinarith
    have hkey : 1 - (Real.sqrt (e i))⁻¹ ≤ Real.sqrt (e i) - 1 := by
      have hs0 : 0 < Real.sqrt (e i) := by linarith
      rw [sub_le_iff_le_add]
      have : (Real.sqrt (e i))⁻¹ * Real.sqrt (e i) = 1 := inv_mul_cancel₀ hs0.ne'
      nlinarith
    linarith
  · rw [hGi]
    apply opNorm_conj_diag_le Q hQ2 _ zero_le_one
    intro i
    have h1 := (he i).1
    have hpos : 0 < e i := by linarith
    rw [abs_of_pos (inv_pos.mpr hpos)]
    exact inv_le_one_of_one_le₀ h1

end Gram

end

end Paulsen.Paper.SeedAux
