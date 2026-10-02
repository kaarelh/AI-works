import Paulsen.Paper.ToolboxAuxSpectral
import Paulsen.GaussianQuadraticForm

/-!
# Helper for `Paulsen.Paper.Toolbox`: the operator-norm bridge, `invSqrt`, and the polar
factor (`lem:align`, polar part).

All statements are phrased with the definitions of `Toolbox.lean` unfolded
(`invSqrt G = cfc (fun x => (√x)⁻¹) G`, `opNorm M = ‖toEuclideanLin M‖`).
-/

namespace Paulsen.Paper.ToolboxAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

/-- `|xᵀAx| ≤ ‖A‖ ‖x‖²`. -/
theorem abs_quad_le_opNorm {k : Type*} [Fintype k] [DecidableEq k] (A : Matrix k k ℝ)
    (x : k → ℝ) :
    |matrixQuadratic A x| ≤ ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ * ∑ i, x i ^ 2 := by
  let y : EuclideanSpace ℝ k := WithLp.toLp 2 x
  have he : matrixQuadratic A x = inner ℝ y (Matrix.toEuclideanLin A y) :=
    (euclideanQuadratic_eq_matrixQuadratic A y).symm
  rw [he]
  calc
    _ ≤ ‖y‖ * ‖Matrix.toEuclideanLin A y‖ := abs_real_inner_le_norm _ _
    _ ≤ ‖y‖ * (‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ * ‖y‖) :=
      mul_le_mul_of_nonneg_left
        ((Matrix.toEuclideanLin A).toContinuousLinearMap.le_opNorm y) (norm_nonneg _)
    _ = _ := by
      rw [show ‖y‖ * (‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ * ‖y‖) =
        ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ * ‖y‖ ^ 2 by ring]
      rw [EuclideanSpace.real_norm_sq_eq]

theorem frameEnergy_sub_eq_quad {n d : ℕ} (X : Frame n d) (x : Fin d → ℝ) :
    frameEnergy X x - vectorNormSq x = matrixQuadratic (X.transpose * X - 1) x := by
  rw [frameEnergy_eq_sum_gram]
  unfold matrixQuadratic vectorNormSq
  simp only [Matrix.sub_apply, Matrix.mul_apply, Matrix.transpose_apply, Matrix.one_apply]
  rw [← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl; intro j _
  have : ∑ k, x j * (if j = k then (1 : ℝ) else 0) * x k = x j ^ 2 := by
    simp [pow_two]
  rw [← this, ← Finset.sum_sub_distrib]
  apply Finset.sum_congr rfl; intro k _
  ring

/-- `isNearlyParseval_iff_opNorm`, unfolded. -/
theorem isNearlyParseval_iff_opNorm' {n d : ℕ} (X : Frame n d) {δ : ℝ} (hδ : 0 ≤ δ) :
    IsNearlyParseval δ X ↔
      ‖(Matrix.toEuclideanLin (X.transpose * X - 1)).toContinuousLinearMap‖ ≤ δ := by
  have hA : (X.transpose * X - 1 : Matrix (Fin d) (Fin d) ℝ).IsHermitian := by
    have h0 : (X.transpose * X).IsHermitian := by
      unfold Matrix.IsHermitian
      rw [Matrix.conjTranspose_eq_transpose_of_trivial, Matrix.transpose_mul,
        Matrix.transpose_transpose]
    exact h0.sub Matrix.isHermitian_one
  constructor
  · intro h
    apply euclidean_operator_norm_le_of_eigenvalues _ hA δ hδ
    intro i
    rw [eigenvalue_eq_quadratic hA i]
    have hq := frameEnergy_sub_eq_quad X (fun a => eigQ hA a i)
    have hn : vectorNormSq (fun a => eigQ hA a i) = 1 := eigQ_col_norm hA i
    have h1 := h (fun a => eigQ hA a i)
    rw [hn] at h1 hq
    have : matrixQuadratic (X.transpose * X - 1) (fun a => eigQ hA a i) =
        ∑ a, ∑ b, eigQ hA a i * (X.transpose * X - 1 : Matrix (Fin d) (Fin d) ℝ) a b *
          eigQ hA b i := rfl
    rw [← this, ← hq, abs_le]
    constructor <;> linarith [h1.1, h1.2]
  · intro h x
    have hq := frameEnergy_sub_eq_quad X x
    have hb := abs_quad_le_opNorm (X.transpose * X - 1) x
    have hb' : |matrixQuadratic (X.transpose * X - 1) x| ≤ δ * vectorNormSq x :=
      hb.trans (mul_le_mul_of_nonneg_right h (Finset.sum_nonneg fun i _ => sq_nonneg _))
    rw [← hq, abs_le] at hb'
    constructor <;> linarith [hb'.1, hb'.2]

/-! ### Explicit diagonalised calculus -/

variable {k : Type*} [Fintype k] [DecidableEq k]

theorem conj_diag_mul (Q : Matrix k k ℝ) (hQ : Q.transpose * Q = 1) (a b : k → ℝ) :
    (Q * Matrix.diagonal a * Q.transpose) * (Q * Matrix.diagonal b * Q.transpose) =
      Q * Matrix.diagonal (fun i => a i * b i) * Q.transpose := by
  calc (Q * Matrix.diagonal a * Q.transpose) * (Q * Matrix.diagonal b * Q.transpose)
      = Q * Matrix.diagonal a * (Q.transpose * Q) * Matrix.diagonal b * Q.transpose := by
        simp only [Matrix.mul_assoc]
    _ = _ := by rw [hQ, Matrix.mul_one, Matrix.mul_assoc Q, Matrix.diagonal_mul_diagonal]

theorem conj_diag_one (Q : Matrix k k ℝ) (hQ : Q * Q.transpose = 1) :
    Q * Matrix.diagonal (fun _ => (1 : ℝ)) * Q.transpose = 1 := by
  rw [show (Matrix.diagonal (fun _ : k => (1 : ℝ))) = 1 from rfl, Matrix.mul_one, hQ]

/-- `invSqrt_spec`, unfolded. -/
theorem invSqrt_spec' (G : Matrix k k ℝ) (hG : G.PosDef) :
    (cfc (fun x : ℝ => (Real.sqrt x)⁻¹) G).PosDef ∧
    cfc (fun x : ℝ => (Real.sqrt x)⁻¹) G * cfc (fun x : ℝ => (Real.sqrt x)⁻¹) G = G⁻¹ ∧
    cfc (fun x : ℝ => (Real.sqrt x)⁻¹) G * G * cfc (fun x : ℝ => (Real.sqrt x)⁻¹) G = 1 := by
  have hH := hG.isHermitian
  have he : ∀ i, 0 < hH.eigenvalues i := hG.eigenvalues_pos
  rw [cfc_decomp hH]
  have hQ1 := eigQ_transpose_mul hH
  have hQ2 := eigQ_mul_transpose hH
  have hdec := eig_decomp hH
  set Q := eigQ hH
  set e := hH.eigenvalues
  clear_value Q e
  subst hdec
  have hsq : ∀ i, (Real.sqrt (e i))⁻¹ * (Real.sqrt (e i))⁻¹ = (e i)⁻¹ := by
    intro i
    rw [← mul_inv, Real.mul_self_sqrt (he i).le]
  refine ⟨?_, ?_, ?_⟩
  · have hD : (Matrix.diagonal (fun i => (Real.sqrt (e i))⁻¹)).PosDef :=
      Matrix.posDef_diagonal_iff.mpr (fun i => inv_pos.mpr (Real.sqrt_pos.mpr (he i)))
    have hinj : Function.Injective Q.vecMul := by
      intro x y hxy
      have := congrArg (fun v => v ᵥ* Q.transpose) hxy
      simpa [Matrix.vecMul_vecMul, hQ2] using this
    have := hD.mul_mul_conjTranspose_same hinj
    rwa [Matrix.conjTranspose_eq_transpose_of_trivial] at this
  · rw [conj_diag_mul Q hQ1]
    symm
    apply Matrix.inv_eq_right_inv
    rw [conj_diag_mul Q hQ1]
    have : (fun i => e i * (e i)⁻¹) = fun _ => (1 : ℝ) := by
      funext i; exact mul_inv_cancel₀ (he i).ne'
    simp only [hsq]
    rw [this, conj_diag_one Q hQ2]
  · rw [conj_diag_mul Q hQ1, conj_diag_mul Q hQ1]
    have : (fun i => (Real.sqrt (e i))⁻¹ * e i * (Real.sqrt (e i))⁻¹) = fun _ => (1 : ℝ) := by
      funext i
      rw [mul_assoc, mul_comm (e i), ← mul_assoc, hsq, inv_mul_cancel₀ (he i).ne']
    rw [this, conj_diag_one Q hQ2]

/-! ### The polar factor in eigen-coordinates -/

theorem frameEnergy_eq_quad {n d : ℕ} (X : Frame n d) (x : Fin d → ℝ) :
    frameEnergy X x = matrixQuadratic (X.transpose * X) x := by
  rw [frameEnergy_eq_sum_gram]
  unfold matrixQuadratic
  simp only [Matrix.mul_apply, Matrix.transpose_apply]
  apply Finset.sum_congr rfl; intro j _
  apply Finset.sum_congr rfl; intro l _
  ring

theorem transpose_mul_self_isHermitian {n d : ℕ} (X : Frame n d) :
    (X.transpose * X).IsHermitian := by
  unfold Matrix.IsHermitian
  rw [Matrix.conjTranspose_eq_transpose_of_trivial, Matrix.transpose_mul,
    Matrix.transpose_transpose]

/-- Diagonalisation of the Gram matrix of a nearly Parseval frame. -/
theorem gram_diag {n d : ℕ} (X : Frame n d) {δ : ℝ} (hX : IsNearlyParseval δ X) :
    ∃ Q : Matrix (Fin d) (Fin d) ℝ, ∃ e : Fin d → ℝ,
      Q.transpose * Q = 1 ∧ Q * Q.transpose = 1 ∧
      X.transpose * X = Q * Matrix.diagonal e * Q.transpose ∧
      (∀ i, 1 - δ ≤ e i ∧ e i ≤ 1 + δ) ∧
      ∀ f : ℝ → ℝ, cfc f (X.transpose * X) =
        Q * Matrix.diagonal (fun i => f (e i)) * Q.transpose := by
  have hG := transpose_mul_self_isHermitian X
  refine ⟨eigQ hG, hG.eigenvalues, eigQ_transpose_mul hG, eigQ_mul_transpose hG,
    eig_decomp hG, ?_, cfc_decomp hG⟩
  intro i
  rw [eigenvalue_eq_quadratic hG i]
  have h1 := hX (fun a => eigQ hG a i)
  have hn : vectorNormSq (fun a => eigQ hG a i) = 1 := eigQ_col_norm hG i
  rw [hn, frameEnergy_eq_quad] at h1
  have hq : matrixQuadratic (X.transpose * X) (fun a => eigQ hG a i) =
      ∑ a, ∑ b, eigQ hG a i * (X.transpose * X) a b * eigQ hG b i := rfl
  rw [hq] at h1
  constructor
  · linarith [h1.1]
  · linarith [h1.2]

section PolarCoords

variable {n d : ℕ}

theorem diag3 (a b c : Fin d → ℝ) :
    Matrix.diagonal a * Matrix.diagonal b * Matrix.diagonal c =
      Matrix.diagonal (fun i => a i * b i * c i) := by
  rw [Matrix.diagonal_mul_diagonal, Matrix.diagonal_mul_diagonal]

theorem pc_Y_gram (X : Frame n d) (Q : Matrix (Fin d) (Fin d) ℝ) (e : Fin d → ℝ)
    (hQ1 : Q.transpose * Q = 1)
    (hG : X.transpose * X = Q * Matrix.diagonal e * Q.transpose) :
    (X * Q).transpose * (X * Q) = Matrix.diagonal e := by
  rw [Matrix.transpose_mul]
  calc Q.transpose * X.transpose * (X * Q) = Q.transpose * (X.transpose * X) * Q := by
        simp only [Matrix.mul_assoc]
    _ = _ := by
      rw [hG]
      simp only [← Matrix.mul_assoc, hQ1, Matrix.one_mul]
      rw [Matrix.mul_assoc, hQ1, Matrix.mul_one]

theorem pc_Y_col (Y : Matrix (Fin n) (Fin d) ℝ) (e : Fin d → ℝ)
    (hYY : Y.transpose * Y = Matrix.diagonal e) (k : Fin d) :
    ∑ i, Y i k ^ 2 = e k := by
  have h := congrArg (fun M => M k k) hYY
  simp only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.diagonal_apply_eq] at h
  rw [← h]; simp only [pow_two]

/-- Diagonal entries of `Y C Yᵀ` with `YᵀY = diag e`. -/
theorem pc_rowNormSq_YCYt (Y : Matrix (Fin n) (Fin d) ℝ) (e : Fin d → ℝ)
    (hYY : Y.transpose * Y = Matrix.diagonal e) (c : Fin d → ℝ) (i : Fin n) :
    rowNormSq (Y * Matrix.diagonal c * Y.transpose) i =
      ∑ k, Y i k ^ 2 * (c k ^ 2 * e k) := by
  rw [← frameProjection_diagonal]
  unfold frameProjection
  have : Y * Matrix.diagonal c * Y.transpose * (Y * Matrix.diagonal c * Y.transpose).transpose =
      Y * Matrix.diagonal (fun k => c k ^ 2 * e k) * Y.transpose := by
    rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose,
      Matrix.diagonal_transpose]
    calc Y * Matrix.diagonal c * Y.transpose * (Y * (Matrix.diagonal c * Y.transpose))
        = Y * (Matrix.diagonal c * (Y.transpose * Y) * Matrix.diagonal c) * Y.transpose := by
          simp only [Matrix.mul_assoc]
      _ = _ := by
          rw [hYY, diag3]
          have : (fun i => c i * e i * c i) = fun k => c k ^ 2 * e k := by
            funext k; ring
          rw [this]
  rw [this]
  simp only [Matrix.mul_apply, Matrix.diagonal_apply, Matrix.transpose_apply, mul_ite, mul_zero,
    Finset.sum_ite_eq', Finset.mem_univ, if_true]
  apply Finset.sum_congr rfl; intro k _; ring

theorem pc_rowNormSq_YDQt (Y : Matrix (Fin n) (Fin d) ℝ) (Q : Matrix (Fin d) (Fin d) ℝ)
    (hQ1 : Q.transpose * Q = 1) (c : Fin d → ℝ) (i : Fin n) :
    rowNormSq (Y * Matrix.diagonal c * Q.transpose) i = ∑ k, Y i k ^ 2 * c k ^ 2 := by
  rw [rowNormSq_mul_orthogonal _ _ (by rw [Matrix.transpose_transpose]; exact hQ1)]
  unfold rowNormSq
  simp only [Matrix.mul_diagonal]
  apply Finset.sum_congr rfl; intro k _; ring

theorem pc_rowNormSq_YQt (Y : Matrix (Fin n) (Fin d) ℝ) (Q : Matrix (Fin d) (Fin d) ℝ)
    (hQ1 : Q.transpose * Q = 1) (i : Fin n) :
    rowNormSq (Y * Q.transpose) i = ∑ k, Y i k ^ 2 := by
  rw [rowNormSq_mul_orthogonal _ _ (by rw [Matrix.transpose_transpose]; exact hQ1)]
  rfl

end PolarCoords

/-- The polar factor statements of `lem:align`, unfolded. -/
theorem polar_facts {n d : ℕ} (X : Frame n d) {δ : ℝ} (hδ0 : 0 ≤ δ) (hδ1 : δ < 1)
    (hX : IsNearlyParseval δ X) :
    IsParseval (X * cfc (fun x : ℝ => (Real.sqrt x)⁻¹) (X.transpose * X)) ∧
    sqDistance X (X * cfc (fun x : ℝ => (Real.sqrt x)⁻¹) (X.transpose * X)) ≤ (d : ℝ) * δ ^ 2 ∧
    (∀ i, rowNormSq X i / (1 + δ) ≤
        rowNormSq (X * cfc (fun x : ℝ => (Real.sqrt x)⁻¹) (X.transpose * X)) i ∧
      rowNormSq (X * cfc (fun x : ℝ => (Real.sqrt x)⁻¹) (X.transpose * X)) i ≤
        rowNormSq X i / (1 - δ)) ∧
    (δ ≤ 1 / 2 → ∀ i,
      |rowNormSq (X * cfc (fun x : ℝ => (Real.sqrt x)⁻¹) (X.transpose * X)) i - rowNormSq X i| ≤
        2 * δ * rowNormSq X i ∧
      rowNormSq (frameProjection (X * cfc (fun x : ℝ => (Real.sqrt x)⁻¹) (X.transpose * X)) -
        frameProjection X) i ≤ 6 * δ ^ 2 * rowNormSq X i) := by
  obtain ⟨Q, e, hQ1, hQ2, hG, he, hcfc⟩ := gram_diag X hX
  generalize hMdef : cfc (fun x : ℝ => (Real.sqrt x)⁻¹) (X.transpose * X) = M
  have hepos : ∀ k, 0 < e k := fun k => by linarith [(he k).1]
  have hM : M = Q * Matrix.diagonal (fun k => (Real.sqrt (e k))⁻¹) * Q.transpose := by
    rw [← hMdef]; exact hcfc _
  obtain ⟨f, hf⟩ : ∃ f : Fin d → ℝ, f = fun k => (Real.sqrt (e k))⁻¹ := ⟨_, rfl⟩
  rw [← hf] at hM
  have hfsq : ∀ k, f k ^ 2 = (e k)⁻¹ := by
    intro k; rw [hf]; simp only [inv_pow, Real.sq_sqrt (hepos k).le]
  have hYY := pc_Y_gram X Q e hQ1 hG
  have hXY : X = X * Q * Q.transpose := by rw [Matrix.mul_assoc, hQ2, Matrix.mul_one]
  have hXM : X * M = (X * Q) * Matrix.diagonal f * Q.transpose := by
    rw [hM]; simp only [Matrix.mul_assoc]
  generalize hYdef : X * Q = Y at hYY hXY hXM
  have hYcol := pc_Y_col Y e hYY
  have hrowX : ∀ i, rowNormSq X i = ∑ k, Y i k ^ 2 := by
    intro i; rw [hXY]; exact pc_rowNormSq_YQt Y Q hQ1 i
  have hrowXM : ∀ i, rowNormSq (X * M) i = ∑ k, Y i k ^ 2 * (e k)⁻¹ := by
    intro i; rw [hXM, pc_rowNormSq_YDQt Y Q hQ1]; simp only [hfsq]
  have hinv_lo : ∀ k, 1 / (1 + δ) ≤ (e k)⁻¹ := fun k => by
    rw [one_div]; exact inv_anti₀ (hepos k) (he k).2
  have hinv_hi : ∀ k, (e k)⁻¹ ≤ 1 / (1 - δ) := fun k => by
    rw [one_div]; exact inv_anti₀ (by linarith) (he k).1
  refine ⟨?_, ?_, ?_, ?_⟩
  · -- Parseval
    unfold IsParseval
    rw [hXM, Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_transpose,
      Matrix.diagonal_transpose]
    calc Q * (Matrix.diagonal f * Y.transpose) * (Y * Matrix.diagonal f * Q.transpose)
        = Q * (Matrix.diagonal f * (Y.transpose * Y) * Matrix.diagonal f) * Q.transpose := by
          simp only [Matrix.mul_assoc]
      _ = 1 := by
          rw [hYY, diag3]
          have : (fun k => f k * e k * f k) = fun _ => (1 : ℝ) := by
            funext k
            rw [mul_comm (f k), mul_assoc, ← pow_two, hfsq, mul_inv_cancel₀ (hepos k).ne']
          rw [this]; exact conj_diag_one Q hQ2
  · -- distance
    have hdist : sqDistance X (X * M) = ∑ k, (Real.sqrt (e k) - 1) ^ 2 := by
      rw [hXM]
      conv_lhs => rw [hXY]
      rw [sqDistance_mul_orthogonal _ _ _ (by rw [Matrix.transpose_transpose]; exact hQ1)]
      unfold sqDistance
      simp only [Matrix.mul_diagonal]
      rw [Finset.sum_comm]
      apply Finset.sum_congr rfl; intro k _
      have : ∀ i, (Y i k - Y i k * f k) ^ 2 = (1 - f k) ^ 2 * Y i k ^ 2 := fun i => by ring
      simp only [this]
      rw [← Finset.mul_sum, hYcol k]
      have hs := Real.sq_sqrt (hepos k).le
      have hs0 : 0 < Real.sqrt (e k) := Real.sqrt_pos.mpr (hepos k)
      rw [hf]
      field_simp
      rw [hs]; ring_nf
    rw [hdist]
    calc ∑ k, (Real.sqrt (e k) - 1) ^ 2 ≤ ∑ _k : Fin d, δ ^ 2 := by
          apply Finset.sum_le_sum; intro k _
          have hs := Real.sq_sqrt (hepos k).le
          have hs0 := Real.sqrt_nonneg (e k)
          have h1 : (e k - 1) ^ 2 ≤ δ ^ 2 :=
            sq_le_sq' (by linarith [(he k).1]) (by linarith [(he k).2])
          have h2 : (Real.sqrt (e k) - 1) ^ 2 ≤ (e k - 1) ^ 2 := by
            have : e k - 1 = (Real.sqrt (e k) - 1) * (Real.sqrt (e k) + 1) := by
              ring_nf; rw [hs]
            rw [this, mul_pow]
            have : 1 ≤ (Real.sqrt (e k) + 1) ^ 2 := by nlinarith
            nlinarith [sq_nonneg (Real.sqrt (e k) - 1)]
          linarith
      _ = (d : ℝ) * δ ^ 2 := by simp
  · intro i
    rw [hrowXM i, hrowX i]
    constructor
    · rw [div_eq_mul_one_div, Finset.sum_mul]
      apply Finset.sum_le_sum; intro k _
      exact mul_le_mul_of_nonneg_left (hinv_lo k) (sq_nonneg _)
    · rw [div_eq_mul_one_div, Finset.sum_mul]
      apply Finset.sum_le_sum; intro k _
      exact mul_le_mul_of_nonneg_left (hinv_hi k) (sq_nonneg _)
  · intro hδ i
    have hcl : ∀ k, |(e k)⁻¹ - 1| ≤ 2 * δ := by
      intro k
      have hek := hepos k
      have : (e k)⁻¹ - 1 = (1 - e k) / e k := by field_simp
      rw [this, abs_div, abs_of_pos hek, div_le_iff₀ hek]
      have := abs_le.mpr (show -δ ≤ 1 - e k ∧ 1 - e k ≤ δ by
        constructor <;> linarith [(he k).1, (he k).2])
      nlinarith [(he k).1]
    constructor
    · rw [hrowXM i, hrowX i, ← Finset.sum_sub_distrib, Finset.mul_sum]
      refine (Finset.abs_sum_le_sum_abs _ _).trans ?_
      apply Finset.sum_le_sum; intro k _
      rw [show Y i k ^ 2 * (e k)⁻¹ - Y i k ^ 2 = Y i k ^ 2 * ((e k)⁻¹ - 1) by ring, abs_mul,
        abs_of_nonneg (sq_nonneg _)]
      nlinarith [hcl k, sq_nonneg (Y i k)]
    · have hdiff : frameProjection (X * M) - frameProjection X =
          Y * Matrix.diagonal (fun k => (e k)⁻¹ - 1) * Y.transpose := by
        unfold frameProjection
        rw [hXM]
        conv_lhs => rw [hXY]
        rw [Matrix.transpose_mul, Matrix.transpose_mul, Matrix.transpose_mul,
          Matrix.transpose_transpose, Matrix.diagonal_transpose]
        have e1 : Y * Matrix.diagonal f * Q.transpose * (Q * (Matrix.diagonal f * Y.transpose)) =
            Y * Matrix.diagonal (fun k => (e k)⁻¹) * Y.transpose := by
          calc _ = Y * Matrix.diagonal f * (Q.transpose * Q) * Matrix.diagonal f * Y.transpose := by
                simp only [Matrix.mul_assoc]
            _ = _ := by
                rw [hQ1, Matrix.mul_one, Matrix.mul_assoc Y, Matrix.diagonal_mul_diagonal]
                have : (fun i => f i * f i) = fun k => (e k)⁻¹ := by
                  funext k; rw [← pow_two, hfsq]
                rw [this]
        have e2 : Y * Q.transpose * (Q * Y.transpose) = Y * Matrix.diagonal (fun _ : Fin d => (1 : ℝ)) *
            Y.transpose := by
          calc _ = Y * (Q.transpose * Q) * Y.transpose := by simp only [Matrix.mul_assoc]
            _ = _ := by rw [hQ1]; rfl
        rw [e1, e2, ← Matrix.sub_mul, ← Matrix.mul_sub, Matrix.diagonal_sub]
      rw [hdiff, pc_rowNormSq_YCYt Y e hYY, hrowX i, Finset.mul_sum]
      apply Finset.sum_le_sum; intro k _
      have hek := hepos k
      have hb : ((e k)⁻¹ - 1) ^ 2 * e k ≤ 6 * δ ^ 2 := by
        have : ((e k)⁻¹ - 1) ^ 2 * e k = (1 - e k) ^ 2 / e k := by field_simp
        rw [this, div_le_iff₀ hek]
        have h1 : (1 - e k) ^ 2 ≤ δ ^ 2 :=
          sq_le_sq' (by linarith [(he k).2]) (by linarith [(he k).1])
        nlinarith [(he k).1, sq_nonneg δ]
      nlinarith [sq_nonneg (Y i k)]

end

end Paulsen.Paper.ToolboxAux
