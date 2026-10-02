import Paulsen.Paper.SampleAuxNoise

/-!
# Helpers for `ModerateSample`: linear algebra for the whitened block of (S4)

For a positive definite `J`: `J^{1/2} J^{-1/2} = 1`, `J^{1/2} J^{1/2} = J`, both square roots are
symmetric, `‖J^{-1/2} v‖² = vᵀJ⁻¹v ≤ ‖v‖²/c` when `J ⪰ cI`, and quadratic forms of sums of
rank-one matrices.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

variable {m : Type*} [Fintype m] [DecidableEq m]
set_option linter.unusedSectionVars false

theorem posDef_spectrum_pos {J : Matrix m m ℝ} (hJ : J.PosDef) {x : ℝ}
    (hx : x ∈ spectrum ℝ J) : 0 < x := by
  rw [hJ.isHermitian.spectrum_real_eq_range_eigenvalues] at hx
  obtain ⟨i, rfl⟩ := hx
  exact hJ.eigenvalues_pos i

theorem posDef_isSelfAdjoint {J : Matrix m m ℝ} (hJ : J.PosDef) : IsSelfAdjoint J :=
  Matrix.isHermitian_iff_isSelfAdjoint.mp hJ.isHermitian

theorem sqrtM_mul_invSqrt {J : Matrix m m ℝ} (hJ : J.PosDef) :
    cfc Real.sqrt J * invSqrt J = 1 := by
  have hfin := Matrix.finite_spectrum J
  have hsa := posDef_isSelfAdjoint hJ
  rw [invSqrt, ← cfc_mul Real.sqrt (fun x : ℝ => (Real.sqrt x)⁻¹) J
    (hfin.continuousOn _) (hfin.continuousOn _)]
  rw [← cfc_one ℝ J]
  apply cfc_congr
  intro x hx
  have hx0 := posDef_spectrum_pos hJ hx
  simp only [Pi.one_apply]
  exact mul_inv_cancel₀ (Real.sqrt_pos.mpr hx0).ne'

theorem sqrtM_mul_sqrtM {J : Matrix m m ℝ} (hJ : J.PosDef) :
    cfc Real.sqrt J * cfc Real.sqrt J = J := by
  have hfin := Matrix.finite_spectrum J
  have hsa := posDef_isSelfAdjoint hJ
  rw [← cfc_mul Real.sqrt Real.sqrt J (hfin.continuousOn _) (hfin.continuousOn _)]
  conv_rhs => rw [← cfc_id' ℝ J]
  apply cfc_congr
  intro x hx
  exact Real.mul_self_sqrt (posDef_spectrum_pos hJ hx).le

theorem cfc_transpose_self (f : ℝ → ℝ) (J : Matrix m m ℝ) : (cfc f J).transpose = cfc f J := by
  have h : IsSelfAdjoint (cfc f J) := cfc_predicate f J
  have h2 := Matrix.isHermitian_iff_isSelfAdjoint.mpr h
  simpa [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial] using h2

theorem invSqrt_transpose (J : Matrix m m ℝ) : (invSqrt J).transpose = invSqrt J :=
  cfc_transpose_self _ J

theorem dotProduct_mulVec_transpose (M : Matrix m m ℝ) (v w : m → ℝ) :
    (M *ᵥ v) ⬝ᵥ w = v ⬝ᵥ (M.transpose *ᵥ w) := by
  rw [Matrix.dotProduct_mulVec, Matrix.vecMul_transpose]

/-- `(J^{1/2} x) ⋅ (J^{-1/2} v) = x ⋅ v`. -/
theorem sqrtM_invSqrt_dot {J : Matrix m m ℝ} (hJ : J.PosDef) (x v : m → ℝ) :
    (cfc Real.sqrt J *ᵥ x) ⬝ᵥ (invSqrt J *ᵥ v) = x ⬝ᵥ v := by
  rw [dotProduct_mulVec_transpose, cfc_transpose_self, Matrix.mulVec_mulVec,
    sqrtM_mul_invSqrt hJ, Matrix.one_mulVec]

/-- `‖J^{1/2} x‖² = xᵀJx`. -/
theorem sqrtM_norm_sq {J : Matrix m m ℝ} (hJ : J.PosDef) (x : m → ℝ) :
    (cfc Real.sqrt J *ᵥ x) ⬝ᵥ (cfc Real.sqrt J *ᵥ x) = matrixQuadratic J x := by
  rw [dotProduct_mulVec_transpose, cfc_transpose_self, Matrix.mulVec_mulVec, sqrtM_mul_sqrtM hJ]
  simp [matrixQuadratic, Matrix.mulVec, dotProduct, Finset.mul_sum, mul_assoc]

/-- `‖J^{-1/2} v‖² = vᵀJ⁻¹v`. -/
theorem invSqrt_norm_sq {J : Matrix m m ℝ} (hJ : J.PosDef) (v : m → ℝ) :
    (invSqrt J *ᵥ v) ⬝ᵥ (invSqrt J *ᵥ v) = v ⬝ᵥ (J⁻¹ *ᵥ v) := by
  rw [dotProduct_mulVec_transpose, invSqrt_transpose, Matrix.mulVec_mulVec,
    (invSqrt_spec J hJ).2.1]

/-- `vᵀJ⁻¹v ≤ ‖v‖²/c` when `J ⪰ cI`. -/
theorem dot_inv_le {J : Matrix m m ℝ} (hJ : J.PosDef) {c : ℝ} (hc : 0 < c)
    (hlow : ∀ y : m → ℝ, c * (y ⬝ᵥ y) ≤ y ⬝ᵥ (J *ᵥ y)) (v : m → ℝ) :
    v ⬝ᵥ (J⁻¹ *ᵥ v) ≤ (v ⬝ᵥ v) / c := by
  set y := J⁻¹ *ᵥ v
  have hdet : IsUnit J.det := hJ.isUnit.map Matrix.detMonoidHom |>.ne_zero |> isUnit_iff_ne_zero.mpr
  have hv : J *ᵥ y = v := by
    simp only [y, Matrix.mulVec_mulVec, Matrix.mul_nonsing_inv J hdet, Matrix.one_mulVec]
  have hsym : J.transpose = J := by
    have := hJ.isHermitian
    simpa [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial] using this
  have h1 : v ⬝ᵥ y = y ⬝ᵥ (J *ᵥ y) := by
    rw [← hv, dotProduct_mulVec_transpose, hsym]
  have h2 := hlow y
  have hyy : 0 ≤ y ⬝ᵥ y := by
    simp only [dotProduct]; exact Finset.sum_nonneg fun _ _ => mul_self_nonneg _
  have hvv : 0 ≤ v ⬝ᵥ v := by
    simp only [dotProduct]; exact Finset.sum_nonneg fun _ _ => mul_self_nonneg _
  -- Cauchy–Schwarz
  have hcs : (v ⬝ᵥ y) ^ 2 ≤ (v ⬝ᵥ v) * (y ⬝ᵥ y) := by
    have := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ v y
    simpa [dotProduct, pow_two] using this
  have hvy : 0 ≤ v ⬝ᵥ y := by rw [h1]; linarith [mul_nonneg hc.le hyy]
  rw [le_div_iff₀ hc]
  -- c (v⋅y)² ≤ (v⋅y)(c y⋅y) ≤ ... ⇒ c (v⋅y) ≤ v⋅v
  rcases eq_or_lt_of_le hvy with h0 | hpos
  · rw [← h0]; simp [hvv]
  · have h3 : c * (y ⬝ᵥ y) ≤ v ⬝ᵥ y := by rw [h1]; exact h2
    have h4 : (v ⬝ᵥ y) * (c * (v ⬝ᵥ y)) ≤ (v ⬝ᵥ y) * (v ⬝ᵥ v) := by
      nlinarith [hcs, h3, mul_le_mul_of_nonneg_left h3 hpos.le]
    have := le_of_mul_le_mul_left h4 hpos
    linarith

theorem matrixQuadratic_finsetSum {ι k : Type*} [Fintype ι] (s : Finset k)
    (M : k → Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (∑ i ∈ s, M i) x = ∑ i ∈ s, matrixQuadratic (M i) x := by
  simp only [matrixQuadratic, Matrix.sum_apply, Finset.mul_sum, Finset.sum_mul]
  conv_lhs => arg 2; ext a; rw [Finset.sum_comm]
  rw [Finset.sum_comm]

theorem matrixQuadratic_smul_vecMulVec {ι : Type*} [Fintype ι] (c : ℝ) (e x : ι → ℝ) :
    matrixQuadratic (c • Matrix.vecMulVec e e) x = c * (x ⬝ᵥ e) ^ 2 := by
  simp only [matrixQuadratic, Matrix.smul_apply, Matrix.vecMulVec_apply, smul_eq_mul, dotProduct,
    pow_two, Finset.mul_sum, Finset.sum_mul]
  apply Finset.sum_congr rfl; intro a _
  apply Finset.sum_congr rfl; intro b _
  ring

/-- Quadratic form of a sum of rank-one matrices. -/
theorem matrixQuadratic_sum_rankOne {ι : Type*} [Fintype ι] {k : Type*} [Fintype k]
    (c : k → k → ℝ) (e : k → k → ι → ℝ) (P : k → k → Prop) [∀ i j, Decidable (P i j)]
    (x : ι → ℝ) :
    matrixQuadratic (∑ i, ∑ j, if P i j then c i j • Matrix.vecMulVec (e i j) (e i j) else 0) x =
      ∑ i, ∑ j, if P i j then c i j * (x ⬝ᵥ e i j) ^ 2 else 0 := by
  rw [matrixQuadratic_finsetSum]
  apply Finset.sum_congr rfl; intro i _
  rw [matrixQuadratic_finsetSum]
  apply Finset.sum_congr rfl; intro j _
  split_ifs
  · exact matrixQuadratic_smul_vecMulVec _ _ _
  · simp [matrixQuadratic]

/-- Exchange of two pairs of finite sums. -/
theorem sum4_comm {α β γ δ : Type*} [Fintype α] [Fintype β] [Fintype γ] [Fintype δ]
    (f : α → β → γ → δ → ℝ) :
    ∑ a, ∑ b, ∑ c, ∑ d, f a b c d = ∑ c, ∑ d, ∑ a, ∑ b, f a b c d := by
  calc ∑ a, ∑ b, ∑ c, ∑ d, f a b c d = ∑ a, ∑ c, ∑ b, ∑ d, f a b c d :=
        Finset.sum_congr rfl (fun a _ => Finset.sum_comm)
    _ = ∑ a, ∑ c, ∑ d, ∑ b, f a b c d :=
        Finset.sum_congr rfl (fun a _ => Finset.sum_congr rfl (fun c _ => Finset.sum_comm))
    _ = ∑ c, ∑ a, ∑ d, ∑ b, f a b c d := Finset.sum_comm
    _ = ∑ c, ∑ d, ∑ a, ∑ b, f a b c d := Finset.sum_congr rfl (fun c _ => Finset.sum_comm)

/-- `if p then ∑∑ f else 0 = ∑∑ (if p then f else 0)`. -/
theorem ite_sum_sum {β γ : Type*} [Fintype β] [Fintype γ] (p : Prop) [Decidable p]
    (f : β → γ → ℝ) :
    (if p then ∑ b, ∑ c, f b c else 0) = ∑ b, ∑ c, if p then f b c else 0 := by
  split_ifs <;> simp

end

end Paulsen.Paper
