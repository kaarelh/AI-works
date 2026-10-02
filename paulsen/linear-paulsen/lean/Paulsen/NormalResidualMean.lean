import Paulsen.NormalBaseMean

/-!
# The commutator estimate for the residual normal mean

The normal directions are kept in ambient matrix coordinates.  The proof uses
commutativity of diagonal matrices and the Frobenius Cauchy--Schwarz inequality.
-/

open Matrix
open scoped BigOperators

noncomputable section

namespace Paulsen

def ambientNormal {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ) : Frame n d :=
  frameComplementProjection U * Matrix.diagonal x * U

def columnDiagonalBlock {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ) :
    Matrix (Fin d) (Fin d) ℝ := U.transpose * Matrix.diagonal x * U

def complementDiagonalBlock {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ) :
    Matrix (Fin n) (Fin n) ℝ :=
  frameComplementProjection U * Matrix.diagonal x * frameComplementProjection U

theorem ambientNormal_horizontal {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (x : Fin n → ℝ) : frameComplementProjection U * ambientNormal U x = ambientNormal U x := by
  simp only [ambientNormal, ← Matrix.mul_assoc, hU.frameComplementProjection_idempotent]

/-- The two off-diagonal blocks of the commutator of two diagonal operators agree. -/
theorem ambientNormal_commutator {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (x f : Fin n → ℝ) :
    complementDiagonalBlock U x * ambientNormal U f -
        ambientNormal U f * columnDiagonalBlock U x =
      complementDiagonalBlock U f * ambientNormal U x -
        ambientNormal U x * columnDiagonalBlock U f := by
  have hdiag : Matrix.diagonal x * Matrix.diagonal f =
      Matrix.diagonal f * Matrix.diagonal x := by
    simp only [Matrix.diagonal_mul_diagonal, mul_comm]
  have hc (x f : Fin n → ℝ) :
      complementDiagonalBlock U x * ambientNormal U f =
        frameComplementProjection U * (Matrix.diagonal x * Matrix.diagonal f) * U -
        ambientNormal U x * columnDiagonalBlock U f := by
    unfold complementDiagonalBlock ambientNormal columnDiagonalBlock
    rw [show frameComplementProjection U * Matrix.diagonal x * frameComplementProjection U *
        (frameComplementProjection U * Matrix.diagonal f * U) =
        frameComplementProjection U * Matrix.diagonal x *
          (frameComplementProjection U * frameComplementProjection U) * Matrix.diagonal f * U by
      simp only [Matrix.mul_assoc]]
    rw [hU.frameComplementProjection_idempotent]
    conv_lhs => arg 1; arg 1; arg 2; rw [frameComplementProjection]
    simp only [Matrix.mul_sub, Matrix.mul_one, Matrix.sub_mul, frameProjection, Matrix.mul_assoc]
  rw [hc, hc, hdiag]
  abel

def normalFrobVector {n d : ℕ} (H : Frame n d) : EuclideanSpace ℝ (Fin n × Fin d) :=
  WithLp.toLp 2 (fun p => H p.1 p.2)

theorem normalFrobVector_inner {n d : ℕ} (H K : Frame n d) :
    inner ℝ (normalFrobVector H) (normalFrobVector K) =
      (H.transpose * K).trace := by
  simp only [normalFrobVector, PiLp.inner_apply, Real.inner_apply,
    Fintype.sum_prod_type, Matrix.trace, Matrix.diag_apply, Matrix.mul_apply,
    Matrix.transpose_apply]
  rw [Finset.sum_comm]

theorem normalFrobVector_norm_sq {n d : ℕ} (H : Frame n d) :
    ‖normalFrobVector H‖ ^ 2 = (H.transpose * H).trace := by
  rw [← real_inner_self_eq_norm_sq, normalFrobVector_inner]

theorem normalFrobVector_mul_parseval_transpose_norm {n m d : ℕ}
    {U : Frame n d} (hU : IsParseval U) (H : Frame m d) :
    ‖normalFrobVector (H * U.transpose)‖ = ‖normalFrobVector H‖ := by
  have hs : ‖normalFrobVector (H * U.transpose)‖ ^ 2 = ‖normalFrobVector H‖ ^ 2 := by
    rw [normalFrobVector_norm_sq, normalFrobVector_norm_sq, Matrix.transpose_mul,
      Matrix.transpose_transpose]
    calc
      _ = (H.transpose * H * (U.transpose * U)).trace := by
        simp only [Matrix.mul_assoc]
        rw [Matrix.trace_mul_comm U]
        simp only [Matrix.mul_assoc]
      _ = _ := by rw [hU, Matrix.mul_one]
  nlinarith [norm_nonneg (normalFrobVector (H * U.transpose)), norm_nonneg (normalFrobVector H)]

theorem normalFrobVector_diagonal_mul_norm_le {n d : ℕ} (H : Frame n d)
    (f : Fin n → ℝ) {M : ℝ} (hM : 0 ≤ M) (hf : ∀ i, |f i| ≤ M) :
    ‖normalFrobVector (Matrix.diagonal f * H)‖ ≤ M * ‖normalFrobVector H‖ := by
  have hs : ‖normalFrobVector (Matrix.diagonal f * H)‖ ^ 2 ≤
      (M * ‖normalFrobVector H‖) ^ 2 := by
    simp only [normalFrobVector, EuclideanSpace.real_norm_sq_eq,
      Matrix.diagonal_mul, mul_pow, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro p _
    exact mul_le_mul_of_nonneg_right (sq_le_sq.mpr (by simpa only [abs_of_nonneg hM] using hf p.1)) (sq_nonneg _)
  exact (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hM (norm_nonneg _))).mp hs


theorem normalFrobVector_mul_diagonal_norm_le {n d : ℕ} (H : Frame n d)
    (f : Fin d → ℝ) {M : ℝ} (hM : 0 ≤ M) (hf : ∀ i, |f i| ≤ M) :
    ‖normalFrobVector (H * Matrix.diagonal f)‖ ≤ M * ‖normalFrobVector H‖ := by
  have hs : ‖normalFrobVector (H * Matrix.diagonal f)‖ ^ 2 ≤
      (M * ‖normalFrobVector H‖) ^ 2 := by
    simp only [normalFrobVector, EuclideanSpace.real_norm_sq_eq,
      Matrix.mul_diagonal, mul_pow, Finset.mul_sum]
    apply Finset.sum_le_sum
    intro p _
    calc
      _ ≤ H p.1 p.2 ^ 2 * M ^ 2 := mul_le_mul_of_nonneg_left
        (sq_le_sq.mpr (by simpa only [abs_of_nonneg hM] using hf p.2)) (sq_nonneg _)
      _ = _ := mul_comm _ _
  exact (sq_le_sq₀ (norm_nonneg _) (mul_nonneg hM (norm_nonneg _))).mp hs

theorem normalFrobVector_inner_mul_left {n m d : ℕ}
    (H : Frame n d) (B : Frame n m) (K : Frame m d) :
    inner ℝ (normalFrobVector H) (normalFrobVector (B * K)) =
      inner ℝ (normalFrobVector (B.transpose * H)) (normalFrobVector K) := by
  simp only [normalFrobVector_inner, Matrix.transpose_mul, Matrix.transpose_transpose,
    Matrix.mul_assoc]

theorem normalFrobVector_inner_mul_right {n m d : ℕ}
    (H : Frame n d) (K : Frame n m) (B : Frame m d) :
    inner ℝ (normalFrobVector H) (normalFrobVector (K * B)) =
      inner ℝ (normalFrobVector (H * B.transpose)) (normalFrobVector K) := by
  simp only [normalFrobVector_inner, Matrix.transpose_mul, Matrix.transpose_transpose]
  rw [Matrix.mul_assoc B, Matrix.trace_mul_comm B]
  simp only [Matrix.mul_assoc]

theorem weighted_rowNormSq_eq_inner {n d : ℕ} (H : Frame n d) (x : Fin n → ℝ) :
    (∑ i, x i * rowNormSq H i) =
      inner ℝ (normalFrobVector H) (normalFrobVector (Matrix.diagonal x * H)) := by
  simp only [normalFrobVector, PiLp.inner_apply, Real.inner_apply,
    Fintype.sum_prod_type, Matrix.diagonal_mul, rowNormSq, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem horizontalQuadraticDiagonal_pairing {n d : ℕ} (U H : Frame n d)
    (x : Fin n → ℝ) :
    (∑ i, x i * horizontalQuadraticDiagonal U H i) =
      inner ℝ (normalFrobVector H) (normalFrobVector (Matrix.diagonal x * H)) -
        inner ℝ (normalFrobVector H) (normalFrobVector (H * columnDiagonalBlock U x)) := by
  simp only [horizontalQuadraticDiagonal, mul_sub, Finset.sum_sub_distrib,
    weighted_rowNormSq_eq_inner]
  congr 1
  simp only [normalFrobVector_inner, Matrix.transpose_mul, Matrix.transpose_transpose,
    columnDiagonalBlock, Matrix.mul_assoc]
  rw [Matrix.trace_mul_comm (H.transpose)]
  simp only [Matrix.mul_assoc]

/-- The quadratic pairing of a horizontal direction is a block commutator pairing. -/
theorem horizontalQuadraticDiagonal_commutator_pairing {n d : ℕ} (U H : Frame n d)
    (x : Fin n → ℝ) (hH : frameComplementProjection U * H = H) :
    (∑ i, x i * horizontalQuadraticDiagonal U H i) =
      inner ℝ (normalFrobVector H)
        (normalFrobVector (complementDiagonalBlock U x * H - H * columnDiagonalBlock U x)) := by
  have hsub (A B : Frame n d) : normalFrobVector (A-B) = normalFrobVector A - normalFrobVector B := rfl
  rw [hsub, inner_sub_right, horizontalQuadraticDiagonal_pairing]
  congr 1
  unfold complementDiagonalBlock
  rw [Matrix.mul_assoc, Matrix.mul_assoc, hH]
  rw [normalFrobVector_inner_mul_left H (frameComplementProjection U),
    frameComplementProjection_transpose, hH]

/-- A normal direction's quadratic diagonal has small dual Laplacian energy. -/
theorem ambientNormal_quadratic_pairing_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (x f : Fin n → ℝ) {M : ℝ} (hM : 0 ≤ M)
    (hf : ∀ i, |f i| ≤ M) :
    |∑ i, x i * horizontalQuadraticDiagonal U (ambientNormal U f) i| ≤
      2 * M * ‖normalFrobVector (ambientNormal U f)‖ * ‖normalFrobVector (ambientNormal U x)‖ := by
  let H := ambientNormal U f
  let K := ambientNormal U x
  have hH : frameComplementProjection U * H = H := ambientNormal_horizontal hU f
  have hK : frameComplementProjection U * K = K := ambientNormal_horizontal hU x
  have hp := horizontalQuadraticDiagonal_commutator_pairing U H x hH
  dsimp only [H] at hp
  rw [ambientNormal_commutator hU] at hp
  have hfirst : inner ℝ (normalFrobVector H)
      (normalFrobVector (complementDiagonalBlock U f * K)) =
      inner ℝ (normalFrobVector H) (normalFrobVector (Matrix.diagonal f * K)) := by
    unfold complementDiagonalBlock
    rw [Matrix.mul_assoc, Matrix.mul_assoc, hK, normalFrobVector_inner_mul_left,
      frameComplementProjection_transpose, hH]
  have hsecond : inner ℝ (normalFrobVector H)
      (normalFrobVector (K * columnDiagonalBlock U f)) =
      inner ℝ (normalFrobVector (H * U.transpose))
        (normalFrobVector ((K * U.transpose) * Matrix.diagonal f)) := by
    unfold columnDiagonalBlock
    rw [← Matrix.mul_assoc, ← Matrix.mul_assoc, normalFrobVector_inner_mul_right]
  have hsub (A B : Frame n d) : normalFrobVector (A-B) = normalFrobVector A - normalFrobVector B := rfl
  rw [hp, hsub, inner_sub_right]
  change |inner ℝ (normalFrobVector H) (normalFrobVector (complementDiagonalBlock U f * K)) -
    inner ℝ (normalFrobVector H) (normalFrobVector (K * columnDiagonalBlock U f))| ≤ _
  rw [hfirst, hsecond]
  calc
    _ ≤ |inner ℝ (normalFrobVector H) (normalFrobVector (Matrix.diagonal f * K))| +
        |inner ℝ (normalFrobVector (H * U.transpose))
          (normalFrobVector ((K * U.transpose) * Matrix.diagonal f))| := abs_sub _ _
    _ ≤ ‖normalFrobVector H‖ * (M * ‖normalFrobVector K‖) +
        ‖normalFrobVector (H * U.transpose)‖ * (M * ‖normalFrobVector (K * U.transpose)‖) := by
      apply add_le_add
      · exact (abs_real_inner_le_norm _ _).trans (mul_le_mul_of_nonneg_left
          (normalFrobVector_diagonal_mul_norm_le K f hM hf) (norm_nonneg _))
      · exact (abs_real_inner_le_norm _ _).trans (mul_le_mul_of_nonneg_left
          (normalFrobVector_mul_diagonal_norm_le (K * U.transpose) f hM hf) (norm_nonneg _))
    _ = _ := by rw [normalFrobVector_mul_parseval_transpose_norm hU,
                    normalFrobVector_mul_parseval_transpose_norm hU]; ring


theorem normalFrobVector_ambientNormal {n d : ℕ} (U : Frame n d) (x : Fin n → ℝ) :
    normalFrobVector (ambientNormal U x) =
      Matrix.toEuclideanLin (normalMapMatrix U) (WithLp.toLp 2 x) := by
  ext ⟨i,k⟩
  simpa only [normalFrobVector, ambientNormal, Matrix.toLpLin_apply, WithLp.ofLp_toLp] using
    (normalMapMatrix_mulVec U x i k).symm

theorem ambientNormal_norm_sq {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (x : Fin n → ℝ) :
    ‖normalFrobVector (ambientNormal U x)‖ ^ 2 =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hadj : LinearMap.adjoint (Matrix.toEuclideanLin (normalMapMatrix U)) =
      Matrix.toEuclideanLin (normalMapMatrix U).transpose := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      (Matrix.toEuclideanLin_conjTranspose_eq_adjoint (normalMapMatrix U)).symm
  have hcomp : (Matrix.toEuclideanLin (normalMapMatrix U).transpose).comp
      (Matrix.toEuclideanLin (normalMapMatrix U)) =
      Matrix.toEuclideanLin (projectionLaplacian (frameProjection U)) := by
    rw [← normalMapMatrix_gram hU]
    simp only [Matrix.toEuclideanLin, Matrix.toLpLin_mul_same]
  rw [normalFrobVector_ambientNormal, ← real_inner_self_eq_norm_sq,
    ← LinearMap.adjoint_inner_right, hadj]
  change inner ℝ (WithLp.toLp 2 x)
    (((Matrix.toEuclideanLin (normalMapMatrix U).transpose).comp
      (Matrix.toEuclideanLin (normalMapMatrix U))) (WithLp.toLp 2 x)) = _
  rw [hcomp]
  simp only [PiLp.inner_apply, Real.inner_apply, Matrix.toLpLin_apply,
    Matrix.mulVec, dotProduct, matrixQuadratic, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

theorem ambientNormal_norm {n d : ℕ} {U : Frame n d} (hU : IsParseval U)
    (x : Fin n → ℝ) :
    ‖normalFrobVector (ambientNormal U x)‖ =
      Real.sqrt (matrixQuadratic (projectionLaplacian (frameProjection U)) x) := by
  rw [← ambientNormal_norm_sq hU, Real.sqrt_sq (norm_nonneg _)]

def normalizedNormalPotential {n d : ℕ} (U : Frame n d) (j : Fin n) : Fin n → ℝ :=
  fun i => (Real.sqrt (rowNormSq U i))⁻¹ * normalizedFisherEigenvector U j i

def normalizedNormalFrame {n d : ℕ} (U : Frame n d) (j : Fin n) : Frame n d :=
  Matrix.of fun i k => normalizedNormalDirection U j (i,k)

theorem normalizedNormalPotential_image {n d : ℕ} (U : Frame n d) (j : Fin n) :
    normalFrobVector (ambientNormal U (normalizedNormalPotential U j)) =
      Matrix.toEuclideanLin (normalizedNormalMapMatrix U) (normalizedFisherEigenvector U j) := by
  rw [normalFrobVector_ambientNormal, normalizedNormalMapMatrix]
  have hv : WithLp.toLp 2 (normalizedNormalPotential U j) =
      Matrix.toEuclideanLin (leverageNormalizer U) (normalizedFisherEigenvector U j) := by
    ext i
    simp only [normalizedNormalPotential, leverageNormalizer, Matrix.toLpLin_apply,
      Matrix.mulVec_diagonal]
  rw [hv]
  simp only [Matrix.toEuclideanLin, Matrix.toLpLin_mul_same, LinearMap.comp_apply]

theorem normalizedNormalFrame_eq {n d : ℕ} (U : Frame n d) (j : Fin n) :
    normalizedNormalFrame U j = (Real.sqrt (normalizedFisherEigenvalue U j))⁻¹ •
      ambientNormal U (normalizedNormalPotential U j) := by
  have hv := normalizedNormalPotential_image U j
  ext i k
  have hc := congrArg (fun z : EuclideanSpace ℝ (Fin n × Fin d) => z (i,k)) hv
  simp only [normalizedNormalFrame, Matrix.of_apply, normalizedNormalDirection,
    PiLp.smul_apply, Matrix.smul_apply, smul_eq_mul, normalFrobVector] at *
  rw [hc]

theorem normalizedNormalPotential_image_norm {n d : ℕ} (U : Frame n d) (j : Fin n) :
    ‖normalFrobVector (ambientNormal U (normalizedNormalPotential U j))‖ =
      Real.sqrt (normalizedFisherEigenvalue U j) := by
  have hs := normalizedNormalMap_eigenvector_inner U j j
  rw [if_pos rfl, real_inner_self_eq_norm_sq] at hs
  rw [normalizedNormalPotential_image, ← hs, Real.sqrt_sq (norm_nonneg _)]

theorem horizontalQuadraticDiagonal_smul {n d : ℕ} (U H : Frame n d) (c : ℝ) (i : Fin n) :
    horizontalQuadraticDiagonal U (c • H) i = c ^ 2 * horizontalQuadraticDiagonal U H i := by
  simp only [horizontalQuadraticDiagonal, Matrix.transpose_smul, Matrix.mul_smul,
    rowNormSq, Matrix.smul_apply, smul_eq_mul, mul_pow, ← Finset.mul_sum]
  ring

/-- Equation (10): every actual positive normalized Fisher mode obeys the
commutator estimate in the original projection Laplacian metric. -/
theorem normalizedNormalFrame_quadratic_pairing_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (j : Fin n) (hj : 0 < normalizedFisherEigenvalue U j)
    (x : Fin n → ℝ) {M : ℝ} (hM : 0 ≤ M)
    (hf : ∀ i, |normalizedNormalPotential U j i| ≤ M) :
    |∑ i, x i * horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i| ≤
      (2 * M / Real.sqrt (normalizedFisherEigenvalue U j)) *
        Real.sqrt (matrixQuadratic (projectionLaplacian (frameProjection U)) x) := by
  have hb := ambientNormal_quadratic_pairing_le hU x (normalizedNormalPotential U j) hM hf
  rw [normalizedNormalPotential_image_norm, ambientNormal_norm hU] at hb
  rw [normalizedNormalFrame_eq]
  simp only [horizontalQuadraticDiagonal_smul]
  have heq : (∑ i, x i * ((Real.sqrt (normalizedFisherEigenvalue U j))⁻¹ ^ 2 *
      horizontalQuadraticDiagonal U (ambientNormal U (normalizedNormalPotential U j)) i)) =
      (Real.sqrt (normalizedFisherEigenvalue U j))⁻¹ ^ 2 *
        ∑ i, x i * horizontalQuadraticDiagonal U (ambientNormal U (normalizedNormalPotential U j)) i := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [heq, abs_mul, abs_of_nonneg (sq_nonneg _)]
  calc
    _ ≤ (Real.sqrt (normalizedFisherEigenvalue U j))⁻¹ ^ 2 *
      (2*M*Real.sqrt (normalizedFisherEigenvalue U j) *
        Real.sqrt (matrixQuadratic (projectionLaplacian (frameProjection U)) x)) :=
      mul_le_mul_of_nonneg_left hb (sq_nonneg _)
    _ = _ := by field_simp [(Real.sqrt_pos.mpr hj).ne']

theorem normalizedNormalPotential_abs_le {n d : ℕ} (U : Frame n d) (j i : Fin n)
    {p : ℝ} (hp : 0 < p) (hle : p ≤ rowNormSq U i) :
    |normalizedNormalPotential U j i| ≤ (Real.sqrt p)⁻¹ := by
  have hy : |normalizedFisherEigenvector U j i| ≤ 1 := by
    have h := PiLp.norm_apply_le (normalizedFisherEigenvector U j) i
    simpa only [Real.norm_eq_abs, normalizedFisherEigenvector,
      OrthonormalBasis.norm_eq_one] using h
  have hs : (Real.sqrt (rowNormSq U i))⁻¹ ≤ (Real.sqrt p)⁻¹ :=
    inv_anti₀ (Real.sqrt_pos.mpr hp) (Real.sqrt_le_sqrt hle)
  simp only [normalizedNormalPotential, abs_mul, abs_inv,
    abs_of_nonneg (Real.sqrt_nonneg _)]
  exact (mul_le_of_le_one_right (inv_nonneg.mpr (Real.sqrt_nonneg _)) hy).trans hs


/-- The quadratic row defect is linear in the covariance of the perturbation. -/
def normalQuadraticCovariance {n d : ℕ} (U : Frame n d) (i : Fin n) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ →ₗ[ℝ] ℝ where
  toFun C := (∑ k, C (i,k) (i,k)) -
    ∑ j, ∑ k, ∑ l, U i k * U i l * C (j,k) (j,l)
  map_add' C D := by
    simp only [Matrix.add_apply, mul_add, Finset.sum_add_distrib]
    ring
  map_smul' c C := by
    simp only [Matrix.smul_apply, smul_eq_mul, RingHom.id_apply]
    simp only [mul_sub, Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro j _
    apply Finset.sum_congr rfl
    intro k _
    apply Finset.sum_congr rfl
    intro l _
    ring

theorem normalQuadraticCovariance_outer {n d : ℕ} (U H : Frame n d) (i : Fin n) :
    normalQuadraticCovariance U i
        (Matrix.vecMulVec (fun p => H p.1 p.2) (fun p => H p.1 p.2)) =
      horizontalQuadraticDiagonal U H i := by
  simp only [normalQuadraticCovariance, LinearMap.coe_mk, AddHom.coe_mk,
    Matrix.vecMulVec_apply, horizontalQuadraticDiagonal, rowNormSq, Matrix.mul_apply,
    Matrix.transpose_apply, pow_two, Finset.sum_mul, Finset.mul_sum]
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  apply Finset.sum_congr rfl
  intro k _
  apply Finset.sum_congr rfl
  intro l _
  ring

theorem normalQuadraticCovariance_normalDirectionOuter {n d : ℕ}
    (U : Frame n d) (j i : Fin n) :
    normalQuadraticCovariance U i (normalDirectionOuter U j) =
      horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i := by
  have h := normalQuadraticCovariance_outer U (normalizedNormalFrame U j) i
  simpa only [normalizedNormalFrame, Matrix.of_apply, normalDirectionOuter, Prod.eta] using h

theorem normalizedNormalCovariance_base_decomposition {n d : ℕ} (U : Frame n d) :
    normalizedNormalCovariance U = ∑ j, Matrix.vecMulVec
      (fun p => baseNormalDirection U j p.1 p.2)
      (fun p => baseNormalDirection U j p.1 p.2) := by
  ext p q
  simp only [normalizedNormalCovariance, Matrix.mul_apply, Matrix.transpose_apply,
    Matrix.sum_apply, Matrix.vecMulVec_apply, baseNormalDirection_eq_column]

theorem normalizedNormalFrame_weighted_sum {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (i : Fin n) :
    (∑ j, normalizedFisherEigenvalue U j *
      horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i) =
      (projectionLaplacian (frameProjection U) *ᵥ (fun j => (rowNormSq U j)⁻¹)) i := by
  have heq := congrArg (normalQuadraticCovariance U i)
    (normalizedNormalCovariance_decomposition U)
  rw [normalizedNormalCovariance_base_decomposition] at heq
  simp only [map_sum, map_smul, normalQuadraticCovariance_outer,
    normalQuadraticCovariance_normalDirectionOuter, smul_eq_mul] at heq
  rw [← heq]
  exact horizontalQuadraticDiagonal_base_sum_eq_laplacian hU hp i

/-- Removed quadratic mean, with the explicit base covariance subtracted. -/
def normalResidualDiagonal {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) : ℝ :=
  (1 / (n : ℝ)) * ((∑ j ∈ highNormalizedModes U ρ,
    (1 - normalizedFisherEigenvalue U j) * horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i) -
    ∑ j ∈ lowNormalizedModes U ρ,
      normalizedFisherEigenvalue U j * horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i)

theorem normalResidualDiagonal_eq_removed_sub_base {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (ρ : ℝ) (i : Fin n) :
    normalResidualDiagonal U ρ i =
      (1 / (n : ℝ)) * (∑ j ∈ highNormalizedModes U ρ,
        horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i) -
      (1 / (n : ℝ)) *
        (projectionLaplacian (frameProjection U) *ᵥ (fun j => (rowNormSq U j)⁻¹)) i := by
  have hpart : highNormalizedModes U ρ = (lowNormalizedModes U ρ)ᶜ := by
    ext j
    simp [highNormalizedModes, lowNormalizedModes, not_le]
  rw [← normalizedNormalFrame_weighted_sum hU hp,
    ← Finset.sum_add_sum_compl (lowNormalizedModes U ρ)
      (fun j => normalizedFisherEigenvalue U j * horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i)]
  unfold normalResidualDiagonal
  rw [hpart]
  simp only [sub_mul, one_mul, Finset.sum_sub_distrib]
  ring


set_option maxHeartbeats 600000 in
/-- Summing the high and low spectral weights loses only the spectral deficit
`d`, rather than the number of removed modes. -/
theorem normalResidualDiagonal_pairing_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (hn : 0 < n)
    {ρ M : ℝ} (hρ : 0 < ρ) (hρhalf : ρ ≤ 1/2) (hM : 0 ≤ M)
    (hf : ∀ j i, |normalizedNormalPotential U j i| ≤ M) (x : Fin n → ℝ) :
    |∑ i, x i * normalResidualDiagonal U ρ i| ≤
      (4 * (d : ℝ) * M / ((n : ℝ) * Real.sqrt ρ)) *
        Real.sqrt (matrixQuadratic (projectionLaplacian (frameProjection U)) x) := by
  let E := Real.sqrt (matrixQuadratic (projectionLaplacian (frameProjection U)) x)
  let q := fun j => ∑ i, x i * horizontalQuadraticDiagonal U (normalizedNormalFrame U j) i
  have hE : 0 ≤ E := Real.sqrt_nonneg _
  have hsρ : 0 < Real.sqrt ρ := Real.sqrt_pos.mpr hρ
  have hsqρ : (Real.sqrt ρ)^2 = ρ := Real.sq_sqrt hρ.le
  have hd : (0 : ℝ) ≤ d := Nat.cast_nonneg d
  have hq (j : Fin n) (hj : 0 < normalizedFisherEigenvalue U j) :
      |q j| ≤ (2*M/Real.sqrt (normalizedFisherEigenvalue U j))*E :=
    normalizedNormalFrame_quadratic_pairing_le hU j hj x hM (hf j)
  have hhigh : ∀ j ∈ highNormalizedModes U ρ, |q j| ≤ (2*M/Real.sqrt ρ)*E := by
    intro j hj
    have hμ := (Finset.mem_filter.mp hj).2
    apply (hq j (hρ.trans hμ)).trans
    apply mul_le_mul_of_nonneg_right _ hE
    exact div_le_div_of_nonneg_left (by positivity) hsρ (Real.sqrt_le_sqrt hμ.le)
  have hlow : ∀ j ∈ lowNormalizedModes U ρ,
      |normalizedFisherEigenvalue U j * q j| ≤ (2*M*Real.sqrt ρ)*E := by
    intro j hj
    have hμ := normalizedFisherEigenvalue_nonneg U j
    have hμρ := (Finset.mem_filter.mp hj).2
    by_cases hz : normalizedFisherEigenvalue U j = 0
    · simp only [hz, zero_mul, abs_zero]
      positivity
    · have hμpos := lt_of_le_of_ne hμ (Ne.symm hz)
      have hsμ := Real.sq_sqrt hμ
      have hsμpos := Real.sqrt_pos.mpr hμpos
      rw [abs_mul, abs_of_nonneg hμ]
      calc
        _ ≤ normalizedFisherEigenvalue U j * ((2*M/Real.sqrt (normalizedFisherEigenvalue U j))*E) :=
          mul_le_mul_of_nonneg_left (hq j hμpos) hμ
        _ = (2*M*Real.sqrt (normalizedFisherEigenvalue U j))*E := by
          field_simp [hsμpos.ne']
          nlinarith only [congrArg (fun z : ℝ => M*E*z) hsμ]
        _ ≤ _ := mul_le_mul_of_nonneg_right
          (mul_le_mul_of_nonneg_left (Real.sqrt_le_sqrt hμρ) (by positivity)) hE
  have hpos : |∑ j ∈ highNormalizedModes U ρ, (1-normalizedFisherEigenvalue U j)*q j| ≤
      (d : ℝ)*((2*M/Real.sqrt ρ)*E) := by
    calc
      _ ≤ ∑ j ∈ highNormalizedModes U ρ, |(1-normalizedFisherEigenvalue U j)*q j| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ j ∈ highNormalizedModes U ρ,
          (1-normalizedFisherEigenvalue U j)*((2*M/Real.sqrt ρ)*E) := by
        apply Finset.sum_le_sum
        intro j hj
        rw [abs_mul, abs_of_nonneg (sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp j))]
        exact mul_le_mul_of_nonneg_left (hhigh j hj)
          (sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp j))
      _ = normalizedPositiveResidualMass U ρ * ((2*M/Real.sqrt ρ)*E) := by
        rw [normalizedPositiveResidualMass, Finset.sum_mul]
      _ ≤ _ := mul_le_mul_of_nonneg_right (normalizedPositiveResidualMass_le hU hp ρ) (by positivity)
  have hcard : ((lowNormalizedModes U ρ).card : ℝ) ≤ 2*d := by
    have hh := lowNormalizedModes_card_le hU hp (show ρ<1 by linarith)
    apply hh.trans
    apply (div_le_iff₀ (show 0<1-ρ by linarith)).2
    nlinarith [mul_nonneg hd (show 0≤1/2-ρ by linarith)]
  have hneg : |∑ j ∈ lowNormalizedModes U ρ, normalizedFisherEigenvalue U j*q j| ≤
      (2*(d : ℝ))*((2*M*Real.sqrt ρ)*E) := by
    calc
      _ ≤ ∑ j ∈ lowNormalizedModes U ρ, |normalizedFisherEigenvalue U j*q j| :=
        Finset.abs_sum_le_sum_abs _ _
      _ ≤ ∑ _j ∈ lowNormalizedModes U ρ, (2*M*Real.sqrt ρ)*E :=
        Finset.sum_le_sum (fun j hj => hlow j hj)
      _ = ((lowNormalizedModes U ρ).card : ℝ) * ((2*M*Real.sqrt ρ)*E) := by simp
      _ ≤ _ := mul_le_mul_of_nonneg_right hcard (by positivity)
  have heq : (∑ i, x i * normalResidualDiagonal U ρ i) = (1/(n:ℝ))*
      ((∑ j ∈ highNormalizedModes U ρ, (1-normalizedFisherEigenvalue U j)*q j) -
        ∑ j ∈ lowNormalizedModes U ρ, normalizedFisherEigenvalue U j*q j) := by
    unfold normalResidualDiagonal q
    simp only [mul_sub, Finset.sum_sub_distrib, Finset.mul_sum]
    congr 1 <;> rw [Finset.sum_comm] <;> apply Finset.sum_congr rfl <;>
      intro j hj <;> apply Finset.sum_congr rfl <;> intro i hi <;> ring
  rw [heq, abs_mul, abs_of_nonneg (by positivity : 0≤1/(n:ℝ))]
  have hsum : (d : ℝ)*((2*M/Real.sqrt ρ)*E)+(2*(d:ℝ))*((2*M*Real.sqrt ρ)*E) ≤
      (4*(d:ℝ)*M/Real.sqrt ρ)*E := by
    apply (mul_le_mul_iff_left₀ hsρ).mp
    have hc : 0 ≤ (d:ℝ)*M*E := by positivity
    field_simp
    nlinarith [mul_nonneg hc (show 0≤1/2-ρ by linarith)]
  calc
    _ ≤ (1/(n:ℝ))*((d : ℝ)*((2*M/Real.sqrt ρ)*E)+(2*(d:ℝ))*((2*M*Real.sqrt ρ)*E)) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      exact (abs_sub _ _).trans (add_le_add hpos hneg)
    _ ≤ (1/(n:ℝ))*((4*(d:ℝ)*M/Real.sqrt ρ)*E) :=
      mul_le_mul_of_nonneg_left hsum (by positivity)
    _ = _ := by dsimp only [E]; ring


/-- A lower leverage bound gives the squared dual-energy estimate without any
assumption about connectivity of the projection graph. -/
theorem normalResidualDiagonal_dual_energy_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0 < n) {p ρ : ℝ} (hp : 0 < p)
    (hrows : ∀ i, p ≤ rowNormSq U i) (hρ : 0 < ρ) (hρhalf : ρ ≤ 1/2)
    (x : Fin n → ℝ) :
    (∑ i, x i * normalResidualDiagonal U ρ i) ^ 2 ≤
      (16 * (d : ℝ)^2 / ((n : ℝ)^2 * p * ρ)) *
        matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hb := normalResidualDiagonal_pairing_le hU (fun i => hp.trans_le (hrows i)) hn
    hρ hρhalf (inv_nonneg.mpr (Real.sqrt_nonneg p))
    (fun j i => normalizedNormalPotential_abs_le U j i hp (hrows i)) x
  have he : 0 ≤ matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
    rw [← ambientNormal_norm_sq hU]
    positivity
  have hs := pow_le_pow_left₀ (abs_nonneg _) hb 2
  simpa only [sq_abs, mul_pow, div_pow, inv_pow, Real.sq_sqrt hp.le,
    Real.sq_sqrt hρ.le, Real.sq_sqrt he, show (4:ℝ)^2=16 by norm_num,
    div_eq_mul_inv, mul_inv, ← mul_assoc, mul_comm, mul_left_comm] using hs

/-- For rows at least half the average leverage, the residual energy is
bounded by `32 (d/n) / ρ`. -/
theorem normalResidualDiagonal_dual_energy_le_average {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0 < n) (hd : 0 < d)
    (hrows : ∀ i, (d : ℝ)/(2*(n:ℝ)) ≤ rowNormSq U i)
    {ρ : ℝ} (hρ : 0 < ρ) (hρhalf : ρ ≤ 1/2) (x : Fin n → ℝ) :
    (∑ i, x i * normalResidualDiagonal U ρ i) ^ 2 ≤
      (32 * ((d : ℝ)/(n:ℝ)) / ρ) *
        matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hnp : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hdp : (0:ℝ)<d := Nat.cast_pos.mpr hd
  have hb := normalResidualDiagonal_dual_energy_le hU hn
    (show (0:ℝ)<(d:ℝ)/(2*(n:ℝ)) by positivity) hrows hρ hρhalf x
  have hc : 16*(d:ℝ)^2/((n:ℝ)^2*((d:ℝ)/(2*(n:ℝ)))*ρ) =
      32*((d:ℝ)/(n:ℝ))/ρ := by
    field_simp [hnp.ne', hdp.ne', hρ.ne']
    ring
  rwa [hc] at hb

/-- The residual is orthogonal to the whole kernel, even when the graph has
several connected components. -/
theorem normalResidualDiagonal_orthogonal_kernel {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0 < n) {p ρ : ℝ} (hp : 0 < p)
    (hrows : ∀ i, p ≤ rowNormSq U i) (hρ : 0 < ρ) (hρhalf : ρ ≤ 1/2)
    (x : Fin n → ℝ) (hx : projectionLaplacian (frameProjection U) *ᵥ x = 0) :
    (∑ i, x i * normalResidualDiagonal U ρ i) = 0 := by
  have he : matrixQuadratic (projectionLaplacian (frameProjection U)) x = 0 := by
    calc
      _ = ∑ i, x i * (projectionLaplacian (frameProjection U) *ᵥ x) i := by
        simp only [matrixQuadratic, Matrix.mulVec, dotProduct, Finset.mul_sum, mul_assoc]
      _ = 0 := by rw [hx]; simp
  have hb := normalResidualDiagonal_dual_energy_le hU hn hp hrows hρ hρhalf x
  rw [he, mul_zero] at hb
  nlinarith [sq_nonneg (∑ i, x i * normalResidualDiagonal U ρ i)]

end Paulsen
