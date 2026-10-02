import Paulsen.Paper.SampleAuxLinear

/-!
# Helpers for `ModerateSample`: second moments of the filtered noise

`Z = (C_ρ/n)^{1/2} g` and `Y = Y_Z` are linear images of the standard Gaussian `g`; since
`C_ρ ⪯ I_𝒵` every linear functional of `Z` is dominated by the unfiltered one.
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

/-- Shorthand for the noise factor `(C_ρ/n)^{1/2}`. -/
abbrev noiseF {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Smooth.normalizedTangentNoiseFactor U ρ

/-- Shorthand for the tangent factor `g ↦ vec Y`. -/
abbrev tangentF {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Matrix (Fin n × Fin n) (Fin n × Fin d) ℝ :=
  Smooth.retainedTangentFactor U ρ

theorem moderateNoise_apply {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d)
    (i : Fin n) (c : Fin d) :
    moderateNoise U ρ g i c = Matrix.toEuclideanLin (noiseF U ρ) g (i, c) := rfl

theorem tangentY_moderateNoise_apply {n d : ℕ} (U : Frame n d) (ρ : ℝ) (g : FrameVector n d)
    (i j : Fin n) :
    tangentY U (moderateNoise U ρ g) i j = Matrix.toEuclideanLin (tangentF U ρ) g (i, j) := by
  have h := congrFun (congrFun (Smooth.moderateNoiseFrame_tangent U ρ g) i) j
  exact h.symm

theorem opNorm_noiseF_sq {n d : ℕ} {U : Frame n d} (hU : IsParseval U) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    opNorm (noiseF U ρ) ^ 2 ≤ 1 / (n : ℝ) :=
  Smooth.normalizedTangentNoiseFactor_operator_norm_sq_le hU hρ

theorem opNorm_tangentF_sq {n d : ℕ} {U : Frame n d} (hU : IsParseval U) {ρ : ℝ}
    (hρ : 0 ≤ ρ) : opNorm (tangentF U ρ) ^ 2 ≤ 2 / (n : ℝ) :=
  Smooth.retainedTangentFactor_operator_norm_sq_le hU hρ

theorem matrixQuadratic_single {ι : Type*} [Fintype ι] [DecidableEq ι] (M : Matrix ι ι ℝ)
    (p : ι) : matrixQuadratic M (Pi.single p 1) = M p p := by
  simp [matrixQuadratic, Pi.single_apply]

theorem matrixQuadratic_smul {ι : Type*} [Fintype ι] (c : ℝ) (M : Matrix ι ι ℝ) (x : ι → ℝ) :
    matrixQuadratic (c • M) x = c * matrixQuadratic M x := by
  simp only [matrixQuadratic, Matrix.smul_apply, smul_eq_mul, Finset.mul_sum]
  apply Finset.sum_congr rfl; intro i _
  apply Finset.sum_congr rfl; intro j _
  ring

/-- Domination by the unfiltered covariance: `E⟨w,Z⟩² = wᵀ(C_ρ/n)w ≤ wᵀ(I_𝒵/n)w`. -/
theorem integral_sq_noise_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (w : Fin n × Fin d → ℝ) :
    ∫ g, (∑ q, w q * Matrix.toEuclideanLin (noiseF U ρ) g q) ^ 2 ∂gaussAmb n d ≤
      (1 / (n : ℝ)) * matrixQuadratic (horizontalProjectionMatrix U) w := by
  rw [integral_sq_linDual, (moderateNoise_spec U hU hp hρ).1, matrixQuadratic_smul]
  exact mul_le_mul_of_nonneg_left ((lem_filter_a U hU hp hρ).1 w).2 (by positivity)

/-- The same for one coordinate. -/
theorem integral_sq_noise_coord_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (p : Fin n × Fin d) :
    ∫ g, (Matrix.toEuclideanLin (noiseF U ρ) g p) ^ 2 ∂gaussAmb n d ≤
      (1 / (n : ℝ)) * horizontalProjectionMatrix U p p := by
  have h := integral_sq_noise_le hU hp hρ (Pi.single p 1)
  rw [matrixQuadratic_single] at h
  simpa [Pi.single_apply] using h

theorem horizontalProjectionMatrix_apply {n d : ℕ} (U : Frame n d) (a a' : Fin n)
    (b b' : Fin d) :
    horizontalProjectionMatrix U (a, b) (a', b') =
      frameComplementProjection U a a' * (if b = b' then 1 else 0) := by
  simp [horizontalProjectionMatrix, Matrix.kronecker, Matrix.one_apply]

/-- `E ‖Zᵀv_i‖² ≤ a(1-p_i)`. -/
theorem integral_rowNormSq_noise_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (i : Fin n) :
    ∫ g, rowNormSq (moderateNoise U ρ g) i ∂gaussAmb n d ≤
      (d : ℝ) / n * (1 - rowNormSq U i) := by
  have hint : ∀ c : Fin d, Integrable
      (fun g => (Matrix.toEuclideanLin (noiseF U ρ) g (i, c)) ^ 2) (gaussAmb n d) :=
    fun c => (memLp_sq_gaussianCoordinate (noiseF U ρ) (i, c)).integrable (by norm_num)
  change ∫ g, ∑ c, (Matrix.toEuclideanLin (noiseF U ρ) g (i, c)) ^ 2 ∂gaussAmb n d ≤ _
  rw [integral_finsetSum _ (fun c _ => hint c)]
  calc
    _ ≤ ∑ _c : Fin d, (1 / (n : ℝ)) * (1 - rowNormSq U i) := by
      apply Finset.sum_le_sum
      intro c _
      have h := integral_sq_noise_coord_le hU hp hρ (i, c)
      rw [horizontalProjectionMatrix_apply] at h
      simpa [frameComplementProjection, frameProjection_diagonal] using h
    _ = _ := by simp; ring

/-- `E ‖Z u_i‖² ≤ (1-a)p_i`. -/
theorem integral_rowNormSq_noise_transpose_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (i : Fin n) (hn : 0 < n) :
    ∫ g, rowNormSq (U * (moderateNoise U ρ g).transpose) i ∂gaussAmb n d ≤
      (1 - (d : ℝ) / n) * rowNormSq U i := by
  have hnR : (0 : ℝ) < n := Nat.cast_pos.mpr hn
  let w : Fin n → Fin n × Fin d → ℝ := fun r q => if q.1 = r then U i q.2 else 0
  have hw : ∀ (g : FrameVector n d) (r : Fin n),
      (U * (moderateNoise U ρ g).transpose) i r =
        ∑ q, w r q * Matrix.toEuclideanLin (noiseF U ρ) g q := by
    intro g r
    simp only [Matrix.mul_apply, Matrix.transpose_apply, moderateNoise_apply, w,
      Fintype.sum_prod_type, ite_mul, zero_mul]
    rw [Finset.sum_eq_single r]
    · simp
    · intro b _ hb; simp [hb]
    · simp
  have hq : ∀ r, matrixQuadratic (horizontalProjectionMatrix U) (w r) =
      (1 - rowNormSq U r) * rowNormSq U i := by
    intro r
    have hmv : ∀ a b, ∑ a', ∑ b', horizontalProjectionMatrix U (a, b) (a', b') * w r (a', b') =
        frameComplementProjection U a r * U i b := by
      intro a b
      rw [Finset.sum_eq_single r]
      · rw [Finset.sum_eq_single b]
        · simp [horizontalProjectionMatrix_apply, w]
        · intro b' _ hb'; simp [horizontalProjectionMatrix_apply, w, Ne.symm hb']
        · simp
      · intro a' _ ha'; simp [w, ha']
      · simp
    have hm : matrixQuadratic (horizontalProjectionMatrix U) (w r) =
        ∑ a, ∑ b, w r (a, b) *
          ∑ a', ∑ b', horizontalProjectionMatrix U (a, b) (a', b') * w r (a', b') := by
      simp only [matrixQuadratic, Fintype.sum_prod_type, Finset.mul_sum, mul_assoc]
    rw [hm]
    simp_rw [hmv]
    rw [Finset.sum_eq_single r]
    · simp only [w, if_true, frameComplementProjection, Matrix.sub_apply, Matrix.one_apply_eq,
        frameProjection_diagonal]
      simp only [rowNormSq, Finset.mul_sum]
      apply Finset.sum_congr rfl; intro c _; ring
    · intro a _ ha; simp [w, ha]
    · simp
  change ∫ g, ∑ r, ((U * (moderateNoise U ρ g).transpose) i r) ^ 2 ∂gaussAmb n d ≤ _
  simp_rw [hw]
  rw [integral_finsetSum _ (fun r _ => integrable_sq_linDual _ (w r))]
  calc
    _ ≤ ∑ r, (1 / (n : ℝ)) * ((1 - rowNormSq U r) * rowNormSq U i) := by
      apply Finset.sum_le_sum
      intro r _
      rw [← hq r]
      exact integral_sq_noise_le hU hp hρ (w r)
    _ = (1 / (n : ℝ)) * ((n - ∑ r, rowNormSq U r) * rowNormSq U i) := by
      rw [← Finset.mul_sum, ← Finset.sum_mul, Finset.sum_sub_distrib]
      simp
    _ = _ := by
      rw [hU.total_rowNormSq]
      field_simp

/-- `E‖Y_i‖² ≤ a(1-p_i) + (1-a)p_i`. -/
theorem integral_rowNormSq_tangentY_le {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (i : Fin n) (hn : 0 < n) :
    ∫ g, rowNormSq (tangentY U (moderateNoise U ρ g)) i ∂gaussAmb n d ≤
      (d : ℝ) / n * (1 - rowNormSq U i) + (1 - (d : ℝ) / n) * rowNormSq U i := by
  have hsplit : ∀ g, rowNormSq (tangentY U (moderateNoise U ρ g)) i =
      rowNormSq (moderateNoise U ρ g) i + rowNormSq (U * (moderateNoise U ρ g).transpose) i :=
    fun g => (tangentY_facts U _ hU ((moderateNoise_spec U hU hp hρ).2.2 g)).1 i
  simp_rw [hsplit]
  have hi1 : Integrable (fun g => rowNormSq (moderateNoise U ρ g) i) (gaussAmb n d) :=
    (memLp_rowNormSq_gaussianImage (noiseF U ρ) i).integrable (by norm_num)
  have hi2 : Integrable (fun g => rowNormSq (U * (moderateNoise U ρ g).transpose) i)
      (gaussAmb n d) := by
    let w : Fin n → Fin n × Fin d → ℝ := fun r q => if q.1 = r then U i q.2 else 0
    have hw : ∀ (g : FrameVector n d) (r : Fin n),
        (U * (moderateNoise U ρ g).transpose) i r =
          ∑ q, w r q * Matrix.toEuclideanLin (noiseF U ρ) g q := by
      intro g r
      simp only [Matrix.mul_apply, Matrix.transpose_apply, moderateNoise_apply, w,
        Fintype.sum_prod_type, ite_mul, zero_mul]
      rw [Finset.sum_eq_single r]
      · simp
      · intro b _ hb; simp [hb]
      · simp
    change Integrable (fun g => ∑ r, ((U * (moderateNoise U ρ g).transpose) i r) ^ 2) _
    simp_rw [hw]
    exact integrable_finsetSum _ (fun r _ => integrable_sq_linDual _ (w r))
  rw [integral_add hi1 hi2]
  exact add_le_add (integral_rowNormSq_noise_le hU hp hρ i)
    (integral_rowNormSq_noise_transpose_le hU hp hρ i hn)

end

end Paulsen.Paper
