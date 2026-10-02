import Paulsen.Paper.SeedAuxOp

/-!
# Helper for `Paulsen.Paper.ModerateSeed`: algebra and deterministic bounds of the retraction

`U_t = (U + tW)(I + t²WᵀW)^{-1/2}` (ambient horizontal `W`), written unfolded.
The constants are those of the proof of `lem:retraction` (`17`, `2√a`, `17√(3a/2)`, `289t²`,
`18`, `4√a`).
-/

namespace Paulsen.Paper.SeedAux

open Matrix Paulsen
open scoped BigOperators

noncomputable section

variable {n d : ℕ}

/-- `UᵀV = 0` gives `(U+tVW)ᵀ(U+tVW) = G`, `U_t` is Parseval, and `P_t = (U+tW)G⁻¹(U+tW)ᵀ`. -/
theorem retr_basic (U W : Frame n d) (hU : IsParseval U) (hUW : U.transpose * W = 0) (t : ℝ) :
    (U + t • W).transpose * (U + t • W) = 1 + t ^ 2 • (W.transpose * W) ∧
    IsParseval ((U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W))) ∧
    frameProjection ((U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W))) =
      (U + t • W) * (1 + t ^ 2 • (W.transpose * W))⁻¹ * (U + t • W).transpose := by
  have hgram := gram_horizontal_perturbation U W t hU hUW
  obtain ⟨-, hST, hSS, hSGS, -⟩ := gram_facts W (sq_nonneg t) (le_refl (opNorm W ^ 2))
  refine ⟨hgram, ?_, ?_⟩
  · unfold IsParseval
    rw [Matrix.transpose_mul, hST, Matrix.mul_assoc, ← Matrix.mul_assoc (U + t • W).transpose,
      hgram, ← Matrix.mul_assoc, hSGS]
  · unfold frameProjection
    rw [Matrix.transpose_mul, hST, Matrix.mul_assoc, ← Matrix.mul_assoc
      (invSqrt (1 + t ^ 2 • (W.transpose * W))), hSS, ← Matrix.mul_assoc]

/-- `G⁻¹ = I - t²WᵀW + t⁴(WᵀW)²G⁻¹`. -/
theorem gram_inv_expand (W : Frame n d) (t : ℝ) :
    (1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ =
      1 - t ^ 2 • (W.transpose * W) +
        t ^ 4 • ((W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W))⁻¹) := by
  set M := W.transpose * W with hM
  set X := (1 + t ^ 2 • M : Matrix (Fin d) (Fin d) ℝ)⁻¹ with hX
  have hG := gram_add_posDef W (sq_nonneg t)
  have hunit : IsUnit (1 + t ^ 2 • M : Matrix (Fin d) (Fin d) ℝ).det :=
    (Matrix.isUnit_iff_isUnit_det _).mp hG.isUnit
  have hGX : (1 + t ^ 2 • M) * X = 1 := Matrix.mul_nonsing_inv _ hunit
  rw [Matrix.add_mul, Matrix.one_mul, Matrix.smul_mul] at hGX
  have h1 : X = 1 - t ^ 2 • (M * X) := eq_sub_of_add_eq hGX
  have h2 : M * X = M - t ^ 2 • (M * M * X) := by
    conv_lhs => rw [h1]
    rw [Matrix.mul_sub, Matrix.mul_one, Matrix.mul_smul, ← Matrix.mul_assoc]
  calc X = 1 - t ^ 2 • (M * X) := h1
    _ = 1 - t ^ 2 • (M - t ^ 2 • (M * M * X)) := by rw [h2]
    _ = 1 - t ^ 2 • M + t ^ 4 • (M ^ 2 * X) := by
      rw [smul_sub, smul_smul, pow_two M, show t ^ 2 * t ^ 2 = t ^ 4 by ring]
      abel

/-- The exact diagonal expansion of `(P_t)_{ii} = ξ_iᵀG⁻¹ξ_i`. -/
theorem retr_expansion (U W : Frame n d) (hU : IsParseval U) (hUW : U.transpose * W = 0)
    (t : ℝ) (i : Fin n) :
    frameProjection ((U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W))) i i =
      rowNormSq U i + 2 * t * diagMap U W i + t ^ 2 * horizontalQuadraticDiagonal U W i -
      2 * t ^ 3 * ∑ k, (U * W.transpose) i k * (W * W.transpose) i k -
      t ^ 4 * rowNormSq (W * W.transpose) i +
      t ^ 4 * ((U + t • W) * (W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W))⁻¹ *
        (U + t • W).transpose : Matrix (Fin n) (Fin n) ℝ) i i := by
  rw [(retr_basic U W hU hUW t).2.2]
  set Ξ := U + t • W with hΞ
  set X := (1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ with hXdef
  have hX := gram_inv_expand W t
  rw [← hXdef] at hX
  have hsplit : Ξ * X * Ξ.transpose = Ξ * Ξ.transpose -
      t ^ 2 • ((Ξ * W.transpose) * (Ξ * W.transpose).transpose) +
      t ^ 4 • (Ξ * (W.transpose * W) ^ 2 * X * Ξ.transpose) := by
    conv_lhs => rw [hX]
    rw [Matrix.transpose_mul, Matrix.transpose_transpose]
    simp only [Matrix.mul_add, Matrix.mul_sub, Matrix.add_mul, Matrix.sub_mul, Matrix.mul_one,
      Matrix.mul_smul, Matrix.smul_mul, Matrix.mul_assoc]
  rw [hsplit]
  have hΞW : Ξ * W.transpose = U * W.transpose + t • (W * W.transpose) := by
    rw [hΞ, Matrix.add_mul, Matrix.smul_mul]
  simp only [Matrix.add_apply, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul]
  rw [← Linear.rowNormSq_eq_mul_transpose, ← Linear.rowNormSq_eq_mul_transpose, hΞW]
  have e1 : rowNormSq Ξ i = rowNormSq U i + 2 * t * diagMap U W i + t ^ 2 * rowNormSq W i := by
    simp only [hΞ, rowNormSq, diagMap, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul,
      Matrix.mul_apply, Matrix.transpose_apply, add_sq, Finset.sum_add_distrib, Finset.mul_sum]
    congr 1
    · congr 1
      apply Finset.sum_congr rfl; intro k _; ring
    · apply Finset.sum_congr rfl; intro k _; ring
  have e2 : rowNormSq (U * W.transpose + t • (W * W.transpose)) i =
      rowNormSq (U * W.transpose) i +
        2 * t * ∑ k, (U * W.transpose) i k * (W * W.transpose) i k +
        t ^ 2 * rowNormSq (W * W.transpose) i := by
    simp only [rowNormSq, Matrix.add_apply, Matrix.smul_apply, smul_eq_mul, add_sq,
      Finset.sum_add_distrib, Finset.mul_sum]
    congr 1
    · congr 1
      apply Finset.sum_congr rfl; intro k _; ring
    · apply Finset.sum_congr rfl; intro k _; ring
  rw [e1, e2]
  unfold horizontalQuadraticDiagonal
  ring

/-- `P_t - P - tY_W = (U+tW)(G⁻¹-I)(U+tW)ᵀ + t²WWᵀ`. -/
theorem retr_error_split (U W : Frame n d) (hU : IsParseval U) (hUW : U.transpose * W = 0)
    (t : ℝ) :
    frameProjection ((U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W))) -
        frameProjection U - t • tangentY U W =
      (U + t • W) * ((1 + t ^ 2 • (W.transpose * W))⁻¹ - 1) * (U + t • W).transpose +
        t ^ 2 • (W * W.transpose) := by
  rw [(retr_basic U W hU hUW t).2.2]
  unfold frameProjection tangentY
  simp only [Matrix.mul_sub, Matrix.sub_mul, Matrix.mul_one, Matrix.transpose_add,
    Matrix.transpose_smul, Matrix.add_mul, Matrix.mul_add, Matrix.smul_mul, Matrix.mul_smul,
    smul_add, smul_smul]
  rw [show t * t = t ^ 2 by ring]
  module

/-! ### Deterministic bounds (the proof of `lem:retraction` (a)–(c)) -/

/-- The bookkeeping of `lem:retraction` (a)–(c) from the auxiliary bounds. -/
theorem retr_bounds (U W : Frame n d) (hU : IsParseval U) {a t : ℝ} (ha : 0 < a)
    (ht : 0 < t) (ht1 : t ≤ 1)
    (hWop : opNorm W ≤ 17) (hWF : Real.sqrt (frobSq W) ≤ 17 * Real.sqrt d)
    (hWrow : ∀ i, Real.sqrt (rowNormSq W i) ≤ 2 * Real.sqrt a)
    (hUWrow : ∀ i, Real.sqrt (rowNormSq (U * W.transpose) i) ≤ 17 * Real.sqrt (3 * a / 2))
    (hGi : opNorm ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1) ≤
      289 * t ^ 2)
    (hS : opNorm (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1) ≤ 289 * t ^ 2)
    (hΞop : opNorm (U + t • W) ≤ 18)
    (hΞrow : ∀ i, Real.sqrt (rowNormSq (U + t • W) i) ≤ 4 * Real.sqrt a) :
    sqDistance ((U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W))) U ≤
        5219 ^ 2 * t ^ 2 * d ∧
    (∀ i, rowNormSq ((U + t • W) * ((1 + t ^ 2 • (W.transpose * W))⁻¹ - 1) *
        (U + t • W).transpose + t ^ 2 • (W * W.transpose)) i ≤
      865948040 * t ^ 4 * a) ∧
    ∀ i, |-(2 * t ^ 3 * ∑ k, (U * W.transpose) i k * (W * W.transpose) i k) -
        t ^ 4 * rowNormSq (W * W.transpose) i +
        t ^ 4 * ((U + t • W) * (W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W))⁻¹ *
          (U + t • W).transpose : Matrix (Fin n) (Fin n) ℝ) i i| ≤ 1338908 * a * t ^ 3 := by
  have hK : opNorm W ^ 2 ≤ 289 := by
    have := pow_le_pow_left₀ (opNorm_nonneg W) hWop 2; norm_num at this; linarith
  obtain ⟨-, hST, -, -, hGiT, -, -, hGi1⟩ := gram_facts W (sq_nonneg t) hK
  have ht2 : t ^ 2 ≤ t := by nlinarith
  have ht3 : t ^ 3 ≤ t ^ 2 := by nlinarith [pow_pos ht 2]
  have ht4 : t ^ 4 ≤ t ^ 3 := by nlinarith [pow_pos ht 3]
  have hsa : 0 ≤ Real.sqrt a := Real.sqrt_nonneg a
  have hsqa : Real.sqrt a ^ 2 = a := Real.sq_sqrt ha.le
  have hrowsq : ∀ {m : ℕ} (A : Matrix (Fin n) (Fin m) ℝ) i (c : ℝ), 0 ≤ c →
      Real.sqrt (rowNormSq A i) ≤ c →
      rowNormSq A i ≤ c ^ 2 := by
    intro m A i c hc h
    have := pow_le_pow_left₀ (Real.sqrt_nonneg _) h 2
    rwa [Real.sq_sqrt (rowNormSq_nonneg A i)] at this
  have hWrow2 : ∀ i, rowNormSq W i ≤ 4 * a := by
    intro i
    have := hrowsq W i (2 * Real.sqrt a) (by positivity) (hWrow i)
    nlinarith
  have hXirow2 : ∀ i, rowNormSq (U + t • W) i ≤ 16 * a := by
    intro i
    have := hrowsq (U + t • W) i (4 * Real.sqrt a) (by positivity) (hΞrow i)
    nlinarith
  have hWW : ∀ i, rowNormSq (W * W.transpose) i ≤ 1156 * a := by
    intro i
    have h1 := rowNormSq_mul_transpose_le_opNorm W W i
    have h2 := mul_le_mul hK (hWrow2 i) (rowNormSq_nonneg _ _) (by norm_num)
    linarith
  refine ⟨?_, ?_, ?_⟩
  · -- (a)
    have hdiff : (U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W)) - U = (U + t • W) * (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1) + t • W := by
      rw [Matrix.mul_sub, Matrix.mul_one]; abel
    have hsq : sqDistance ((U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W))) U = frobSq ((U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W)) - U) := by
      simp [sqDistance, frobSq, Matrix.sub_apply]
    have hSsym : (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1).transpose = invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1 := by
      rw [Matrix.transpose_sub, hST, Matrix.transpose_one]
    have hUF : Real.sqrt (frobSq U) = Real.sqrt d := by
      rw [frobSq_eq_sum_rowNormSq, hU.total_rowNormSq]
    have hXiF : Real.sqrt (frobSq (U + t • W)) ≤ 18 * Real.sqrt d := by
      calc Real.sqrt (frobSq (U + t • W)) ≤ Real.sqrt (frobSq U) + Real.sqrt (frobSq (t • W)) :=
            sqrt_frobSq_add_le _ _
        _ = Real.sqrt d + t * Real.sqrt (frobSq W) := by
            rw [hUF, sqrt_frobSq_smul, abs_of_pos ht]
        _ ≤ Real.sqrt d + 1 * (17 * Real.sqrt d) := by
            gcongr
        _ = 18 * Real.sqrt d := by ring
    have h1 : Real.sqrt (frobSq ((U + t • W) * (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1))) ≤ 289 * t ^ 2 * (18 * Real.sqrt d) := by
      have h := frobSq_mul_symm_le_opNorm (U + t • W) (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1) hSsym
      calc Real.sqrt (frobSq ((U + t • W) * (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1))) ≤ Real.sqrt (opNorm (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1) ^ 2 * frobSq (U + t • W)) :=
            Real.sqrt_le_sqrt h
        _ = opNorm (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1) * Real.sqrt (frobSq (U + t • W)) := by
            rw [Real.sqrt_mul (sq_nonneg _), Real.sqrt_sq (opNorm_nonneg _)]
        _ ≤ 289 * t ^ 2 * (18 * Real.sqrt d) :=
            mul_le_mul hS hXiF (Real.sqrt_nonneg _) (by positivity)
    have h2 : Real.sqrt (frobSq ((U + t • W) * invSqrt (1 + t ^ 2 • (W.transpose * W)) - U)) ≤ 5219 * t * Real.sqrt d := by
      rw [hdiff]
      calc Real.sqrt (frobSq ((U + t • W) * (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1) + t • W))
          ≤ Real.sqrt (frobSq ((U + t • W) * (invSqrt (1 + t ^ 2 • (W.transpose * W)) - 1))) + Real.sqrt (frobSq (t • W)) :=
            sqrt_frobSq_add_le _ _
        _ ≤ 289 * t ^ 2 * (18 * Real.sqrt d) + t * (17 * Real.sqrt d) := by
            rw [sqrt_frobSq_smul, abs_of_pos ht]
            gcongr
        _ ≤ 5219 * t * Real.sqrt d := by
            have hsd := Real.sqrt_nonneg (d : ℝ)
            nlinarith [mul_le_mul_of_nonneg_right ht2 hsd]
    rw [hsq]
    have h3 := pow_le_pow_left₀ (Real.sqrt_nonneg _) h2 2
    rw [Real.sq_sqrt (frobSq_nonneg _), mul_pow, mul_pow,
      Real.sq_sqrt (Nat.cast_nonneg d)] at h3
    linarith
  · -- (b): rows of `𝖤'`
    intro i
    refine (Linear.rowNormSq_add_le _ _ i).trans ?_
    have hX1sym : ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1).transpose = (1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1 := by
      rw [Matrix.transpose_sub, hGiT, Matrix.transpose_one]
    have hA : rowNormSq ((U + t • W) * ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1) * (U + t • W).transpose) i ≤ 18 ^ 2 * (289 * t ^ 2) ^ 2 * (16 * a) := by
      have h1 := rowNormSq_mul_transpose_le_opNorm ((U + t • W) * ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1)) (U + t • W) i
      have h2 := rowNormSq_mul_symm_le_opNorm (U + t • W) ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1) hX1sym i
      have h3 : opNorm (U + t • W) ^ 2 ≤ 18 ^ 2 := pow_le_pow_left₀ (opNorm_nonneg _) hΞop 2
      have h4 : opNorm ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1) ^ 2 ≤ (289 * t ^ 2) ^ 2 :=
        pow_le_pow_left₀ (opNorm_nonneg _) hGi 2
      have h5 := hXirow2 i
      calc rowNormSq ((U + t • W) * ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1) * (U + t • W).transpose) i
          ≤ opNorm (U + t • W) ^ 2 * rowNormSq ((U + t • W) * ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1)) i := h1
        _ ≤ 18 ^ 2 * (opNorm ((1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹ - 1) ^ 2 * rowNormSq (U + t • W) i) :=
            mul_le_mul h3 h2 (rowNormSq_nonneg _ _) (by norm_num)
        _ ≤ 18 ^ 2 * ((289 * t ^ 2) ^ 2 * (16 * a)) := by
            apply mul_le_mul_of_nonneg_left _ (by norm_num)
            exact mul_le_mul h4 h5 (rowNormSq_nonneg _ _) (by positivity)
        _ = _ := by ring
    have hB : rowNormSq (t ^ 2 • (W * W.transpose)) i ≤ t ^ 4 * (1156 * a) := by
      rw [Linear.rowNormSq_smul, show (t ^ 2) ^ 2 = t ^ 4 by ring]
      exact mul_le_mul_of_nonneg_left (hWW i) (by positivity)
    nlinarith
  · -- (c): the remainder
    intro i
    have hX1 : |∑ k, (U * W.transpose) i k * (W * W.transpose) i k| ≤ 708 * a := by
      have h := abs_row_inner_le (U * W.transpose) (W * W.transpose) i
      have hUW2 := hrowsq (U * W.transpose) i (17 * Real.sqrt (3 * a / 2)) (by positivity)
        (hUWrow i)
      have hp : 0 ≤ Real.sqrt (rowNormSq (U * W.transpose) i) *
          Real.sqrt (rowNormSq (W * W.transpose) i) := by positivity
      have hsq : (Real.sqrt (rowNormSq (U * W.transpose) i) *
          Real.sqrt (rowNormSq (W * W.transpose) i)) ^ 2 ≤ (708 * a) ^ 2 := by
        rw [mul_pow, Real.sq_sqrt (rowNormSq_nonneg _ _), Real.sq_sqrt (rowNormSq_nonneg _ _)]
        have e : (17 * Real.sqrt (3 * a / 2)) ^ 2 = 289 * (3 * a / 2) := by
          rw [mul_pow, Real.sq_sqrt (by positivity)]; norm_num
        rw [e] at hUW2
        have := mul_le_mul hUW2 (hWW i) (rowNormSq_nonneg _ _) (by positivity)
        nlinarith
      exact h.trans ((sq_le_sq₀ hp (by positivity)).mp hsq)
    have hX3 : |((U + t • W) * (W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W))⁻¹ *
        (U + t • W).transpose : Matrix (Fin n) (Fin n) ℝ) i i| ≤ 1336336 * a := by
      have hM := opNorm_gram_le W hK
      have hmul : opNorm ((W.transpose * W) ^ 2 *
          (1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹) ≤ 289 * 289 * 1 := by
        rw [pow_two]
        refine (opNorm_mul_le _ _).trans ?_
        refine (mul_le_mul_of_nonneg_right (opNorm_mul_le _ _) (opNorm_nonneg _)).trans ?_
        exact mul_le_mul (mul_le_mul hM hM (opNorm_nonneg _) (by norm_num)) hGi1
          (opNorm_nonneg _) (by norm_num)
      have h := abs_conj_diag_le (U + t • W) ((W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹) i
      rw [Matrix.mul_assoc (U + t • W) ((W.transpose * W) ^ 2)]
      calc _ ≤ opNorm ((W.transpose * W) ^ 2 * (1 + t ^ 2 • (W.transpose * W) : Matrix (Fin d) (Fin d) ℝ)⁻¹) * rowNormSq (U + t • W) i := h
        _ ≤ (289 * 289 * 1) * (16 * a) :=
            mul_le_mul hmul (hXirow2 i) (rowNormSq_nonneg _ _) (by norm_num)
        _ = 1336336 * a := by ring
    have hWWi := hWW i
    have hWW0 := rowNormSq_nonneg (W * W.transpose) i
    have hneg := abs_le.mp hX1
    have hneg3 := abs_le.mp hX3
    rw [abs_le]
    have ht3p : 0 < t ^ 3 := by positivity
    have ht4p : 0 < t ^ 4 := by positivity
    constructor <;> nlinarith [mul_le_mul_of_nonneg_left hneg.1 ht3p.le,
      mul_le_mul_of_nonneg_left hneg.2 ht3p.le, mul_le_mul_of_nonneg_left hneg3.1 ht4p.le,
      mul_le_mul_of_nonneg_left hneg3.2 ht4p.le, mul_le_mul_of_nonneg_left hWWi ht4p.le,
      mul_nonneg ht4p.le hWW0, mul_le_mul_of_nonneg_right ht4 ha.le]

end

end Paulsen.Paper.SeedAux
