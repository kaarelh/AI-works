import Paulsen.Paper.SampleAuxS4a

/-!
# Helpers for `ModerateSample`: second moments for (S4)

* the coefficients `(Y_ij)_{i<j}` have covariance `⪯ (2/n) I`;
* the whitened block `J_𝔅 = L_𝔅𝔅 + at²I` is positive definite with `J_𝔅 ⪰ at² I`;
* restriction of sums and quadratic forms to vectors supported on `𝔅`;
* `tr(J⁻¹ L_𝔅𝔅) ≤ |𝔅|`.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- The functional `g ↦ ∑_{i<j} c_ij Y_ij(g)` in coefficient form. -/
theorem upper_sum_eq_linDual {n d : ℕ} (U : Frame n d) (ρ : ℝ) (c : Fin n → Fin n → ℝ)
    (g : FrameVector n d) :
    (∑ i, ∑ j, if i < j then c i j * tangentY U (moderateNoise U ρ g) i j else 0) =
      ∑ p, (fun p : Fin n × Fin n => if p.1 < p.2 then c p.1 p.2 else 0) p *
        Matrix.toEuclideanLin (tangentF U ρ) g p := by
  rw [Fintype.sum_prod_type]
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _
  rw [tangentY_moderateNoise_apply]
  by_cases h : i < j <;> simp [h]

/-- `(Y_ij)_{i<j}` has covariance `⪯ (2/n)I` (proof of `lem:sample`, (S4)). -/
theorem integral_upper_sum_sq_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U) {ρ : ℝ}
    (hρ : 0 ≤ ρ) (c : Fin n → Fin n → ℝ) :
    ∫ g, (∑ i, ∑ j, if i < j then c i j * tangentY U (moderateNoise U ρ g) i j else 0) ^ 2
        ∂gaussAmb n d ≤ 2 / n * ∑ i, ∑ j, if i < j then c i j ^ 2 else 0 := by
  simp_rw [upper_sum_eq_linDual U ρ c]
  rw [integral_sq_linDual]
  refine (matrixQuadratic_mul_transpose_le _ _).trans ?_
  have hw : ∑ p : Fin n × Fin n, (if p.1 < p.2 then c p.1 p.2 else 0) ^ 2 =
      ∑ i, ∑ j, if i < j then c i j ^ 2 else 0 := by
    rw [Fintype.sum_prod_type]
    apply Finset.sum_congr rfl; intro i _
    apply Finset.sum_congr rfl; intro j _
    by_cases h : i < j <;> simp [h]
  rw [hw]
  exact mul_le_mul_of_nonneg_right (opNorm_tangentF_sq hU hρ)
    (Finset.sum_nonneg fun i _ => Finset.sum_nonneg fun j _ => by split_ifs <;> positivity)

theorem integrable_upper_sum_sq {n d : ℕ} (U : Frame n d) (ρ : ℝ) (c : Fin n → Fin n → ℝ) :
    Integrable (fun g => (∑ i, ∑ j, if i < j then c i j * tangentY U (moderateNoise U ρ g) i j
      else 0) ^ 2) (gaussAmb n d) := by
  simp_rw [upper_sum_eq_linDual U ρ c]
  exact integrable_sq_linDual _ _

/-- Sums over `𝔅` of functions vanishing off `𝔅`. -/
theorem sum_subtype_eq {n : ℕ} (B : Finset (Fin n)) (f : Fin n → ℝ)
    (hf : ∀ k, k ∉ B → f k = 0) : ∑ b : B, f b = ∑ k, f k := by
  rw [Finset.sum_coe_sort B f]
  exact Finset.sum_subset (Finset.subset_univ _) (fun k _ hk => hf k hk)

/-- Quadratic forms of principal blocks on vectors supported on `𝔅`. -/
theorem matrixQuadratic_submatrix_eq {n : ℕ} (B : Finset (Fin n)) (M : Matrix (Fin n) (Fin n) ℝ)
    (x : Fin n → ℝ) (hx : ∀ k, k ∉ B → x k = 0) :
    matrixQuadratic (M.submatrix (↑) (↑) : Matrix B B ℝ) (fun b => x b) = matrixQuadratic M x := by
  unfold matrixQuadratic
  simp only [Matrix.submatrix_apply]
  rw [sum_subtype_eq B (fun a => ∑ b : B, x a * M a b * x b) (fun k hk => by simp [hx k hk])]
  apply Finset.sum_congr rfl; intro a _
  exact sum_subtype_eq B (fun b => x a * M a b * x b) (fun k hk => by simp [hx k hk])

theorem dotProduct_subtype_eq {n : ℕ} (B : Finset (Fin n)) (x v : Fin n → ℝ)
    (hx : ∀ k, k ∉ B → x k = 0) :
    (fun b : B => x b) ⬝ᵥ (fun b : B => v b) = x ⬝ᵥ v := by
  simp only [dotProduct]
  exact sum_subtype_eq B (fun k => x k * v k) (fun k hk => by simp [hx k hk])

theorem edgeVec_sq_sum_le {n : ℕ} (B : Finset (Fin n)) (i j : Fin n) :
    ∑ b : B, edgeVec i j b ^ 2 ≤ 2 := by
  have h1 : ∑ b : B, edgeVec i j b ^ 2 ≤ ∑ k, edgeVec i j k ^ 2 := by
    rw [Finset.sum_coe_sort B (fun k => edgeVec i j k ^ 2)]
    exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
      (fun _ _ _ => sq_nonneg _)
  refine h1.trans ?_
  by_cases hij : i = j
  · subst hij; simp [edgeVec]
  · have hpt : ∀ k, edgeVec i j k ^ 2 = (if k = i then (1 : ℝ) else 0) +
        (if k = j then (1 : ℝ) else 0) := by
      intro k
      simp only [edgeVec, Pi.sub_apply, Pi.single_apply]
      by_cases hki : k = i <;> by_cases hkj : k = j
      · exact absurd (hki.symm.trans hkj) hij
      · subst hki; simp [hkj]
      · subst hkj; simp [hki]
      · simp [hki, hkj]
    have : ∑ k, edgeVec i j k ^ 2 = 2 := by
      simp_rw [hpt]
      rw [Finset.sum_add_distrib]
      simp
      norm_num
    rw [this]

/-- The whitened block is positive definite with `J ⪰ c I`. -/
theorem block_posDef {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (B : Finset (Fin n))
    {c : ℝ} (hc : 0 < c) :
    ((projectionLaplacian (frameProjection U)).submatrix (fun b : B => (b : Fin n))
        (fun b : B => (b : Fin n)) + c • (1 : Matrix B B ℝ)).PosDef
      ∧ ∀ y : B → ℝ, c * (y ⬝ᵥ y) ≤ y ⬝ᵥ
        (((projectionLaplacian (frameProjection U)).submatrix (fun b : B => (b : Fin n))
          (fun b : B => (b : Fin n)) + c • (1 : Matrix B B ℝ)) *ᵥ y) := by
  have hL := projectionLaplacian_posSemidef (frameProjection U) (frameProjection_symm U)
    hU.frameProjection_idempotent
  have hLB := Matrix.PosSemidef.submatrix hL (fun b : B => (b : Fin n))
  refine ⟨Matrix.PosDef.posSemidef_add hLB (Matrix.PosDef.smul Matrix.PosDef.one hc),
    fun y => ?_⟩
  rw [Matrix.add_mulVec, dotProduct_add, Matrix.smul_mulVec, Matrix.one_mulVec, dotProduct_smul,
    smul_eq_mul]
  have := Matrix.PosSemidef.dotProduct_mulVec_nonneg hLB y
  simp only [star_trivial] at this
  linarith

/-- Entries of `L_𝔅𝔅` as edge sums. -/
theorem block_laplacian_apply {n d : ℕ} {U : Frame n d} (hU : IsParseval U) (B : Finset (Fin n))
    (b c : B) :
    ((projectionLaplacian (frameProjection U)).submatrix (↑) (↑) : Matrix B B ℝ) b c =
      ∑ i, ∑ j, if i < j then frameProjection U i j ^ 2 * (edgeVec i j b * edgeVec i j c)
        else 0 := by
  rw [Matrix.submatrix_apply, ← (lap_facts U hU).1]
  simp only [sqLaplacian, Matrix.sum_apply]
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _
  split_ifs <;> simp [Matrix.vecMulVec_apply]

/-- `∑_{b,c} (J⁻¹)_{bc} (J - cI)_{bc} ≤ |𝔅|`. -/
theorem trace_inv_mul_le {m : Type*} [Fintype m] [DecidableEq m] {J : Matrix m m ℝ}
    (hJ : J.PosDef) {c : ℝ} (hc : 0 ≤ c) :
    ∑ b, ∑ e, J⁻¹ b e * (J - c • (1 : Matrix m m ℝ)) b e ≤ Fintype.card m := by
  have hsym : J.transpose = J := by
    have := hJ.isHermitian
    simpa [Matrix.IsHermitian, Matrix.conjTranspose_eq_transpose_of_trivial] using this
  have hdet : IsUnit J.det :=
    isUnit_iff_ne_zero.mpr (hJ.isUnit.map Matrix.detMonoidHom).ne_zero
  have hinv : J⁻¹ * J = 1 := Matrix.nonsing_inv_mul J hdet
  have h1 : ∀ b, ∑ e, J⁻¹ b e * J b e = 1 := by
    intro b
    have := congrFun (congrFun hinv b) b
    simp only [Matrix.mul_apply, Matrix.one_apply_eq] at this
    rw [← this]
    apply Finset.sum_congr rfl; intro e _
    have hs := congrFun (congrFun hsym b) e
    simp only [Matrix.transpose_apply] at hs
    rw [hs]
  have hdiag : ∀ b, 0 < J⁻¹ b b := fun b => hJ.inv.diag_pos
  have h2 : ∀ b, ∑ e, J⁻¹ b e * (c • (1 : Matrix m m ℝ)) b e = c * J⁻¹ b b := by
    intro b
    rw [Finset.sum_eq_single b]
    · simp; ring
    · intro e _ he; simp [Matrix.one_apply_ne (Ne.symm he)]
    · simp
  calc ∑ b, ∑ e, J⁻¹ b e * (J - c • (1 : Matrix m m ℝ)) b e
      = ∑ b, (1 - c * J⁻¹ b b) := by
        apply Finset.sum_congr rfl; intro b _
        simp only [Matrix.sub_apply, mul_sub, Finset.sum_sub_distrib, h1 b]
        rw [← h2 b]
    _ ≤ ∑ _b : m, (1 : ℝ) := Finset.sum_le_sum fun b _ => by
        have := mul_nonneg hc (hdiag b).le; linarith
    _ = Fintype.card m := by simp

end

end Paulsen.Paper
