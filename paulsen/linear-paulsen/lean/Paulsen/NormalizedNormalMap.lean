import Paulsen.Projection
import Mathlib.Analysis.Matrix.Order
import Mathlib.Analysis.Matrix.PosDef
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
# Leverage-normalized normal directions

The ambient normal map is `s ↦ (I-UUᵀ) Diag(s) U`. Vectorizing its output
avoids a choice of orthonormal basis for the complement of the column space.
Its Gram matrix is exactly the projection Laplacian. Normalizing by the row
leverage gives a positive contraction whose spectral deficit has trace `d`.
-/

open Matrix
open scoped BigOperators

noncomputable section

namespace Paulsen

def frameComplementProjection {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  1 - frameProjection U

theorem frameComplementProjection_transpose {n d : ℕ} (U : Frame n d) :
    (frameComplementProjection U).transpose = frameComplementProjection U := by
  simp [frameComplementProjection, frameProjection_transpose]

theorem IsParseval.frameComplementProjection_idempotent {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) :
    frameComplementProjection U * frameComplementProjection U = frameComplementProjection U := by
  simp only [frameComplementProjection, Matrix.sub_mul, Matrix.mul_sub, Matrix.one_mul,
    Matrix.mul_one, hU.frameProjection_idempotent]
  abel

/-- Matrix of the actual normal map, with the output matrix vectorized. -/
def normalMapMatrix {n d : ℕ} (U : Frame n d) :
    Matrix (Fin n × Fin d) (Fin n) ℝ :=
  fun z i => frameComplementProjection U z.1 i * U i z.2

theorem normalMapMatrix_mulVec {n d : ℕ} (U : Frame n d) (s : Fin n → ℝ)
    (i : Fin n) (a : Fin d) :
    (normalMapMatrix U *ᵥ s) (i, a) =
      (frameComplementProjection U * Matrix.diagonal s * U) i a := by
  rw [Matrix.mul_apply]
  simp only [normalMapMatrix, Matrix.mulVec, dotProduct, Matrix.mul_diagonal]
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- The Fisher/Gram identity is derived from the concrete normal map. -/
theorem normalMapMatrix_gram {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    (normalMapMatrix U).transpose * normalMapMatrix U =
      projectionLaplacian (frameProjection U) := by
  have hQ : (frameComplementProjection U).transpose * frameComplementProjection U =
      frameComplementProjection U := by
    rw [frameComplementProjection_transpose, hU.frameComplementProjection_idempotent]
  ext i j
  calc
    _ = ((frameComplementProjection U).transpose * frameComplementProjection U) i j *
        frameProjection U i j := by
      simp only [normalMapMatrix, Matrix.mul_apply, Matrix.transpose_apply, frameProjection,
        Fintype.sum_prod_type, Finset.sum_mul, Finset.mul_sum]
      conv_rhs => rw [Finset.sum_comm]
      apply Finset.sum_congr rfl
      intro r _
      apply Finset.sum_congr rfl
      intro a _
      ring
    _ = frameComplementProjection U i j * frameProjection U i j := by rw [hQ]
    _ = _ := by
      by_cases hij : i = j
      · subst j
        simp only [frameComplementProjection, Matrix.sub_apply, Matrix.one_apply_eq,
          projectionLaplacian, Matrix.diagonal_apply_eq, Matrix.of_apply]
        ring
      · simp only [frameComplementProjection, Matrix.sub_apply, Matrix.one_apply,
          projectionLaplacian, Matrix.diagonal_apply, Matrix.of_apply, hij, if_false]
        ring

def leverageNormalizer {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal (fun i => (Real.sqrt (rowNormSq U i))⁻¹)

def normalizedNormalMapMatrix {n d : ℕ} (U : Frame n d) :
    Matrix (Fin n × Fin d) (Fin n) ℝ := normalMapMatrix U * leverageNormalizer U

/-- The normalized Fisher matrix on diagonal perturbations. -/
def normalizedFisher {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  (normalizedNormalMapMatrix U).transpose * normalizedNormalMapMatrix U

/-- The normalized squared projection entries, the spectral deficit of Fisher. -/
def normalizedOverlap {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  leverageNormalizer U * Matrix.of (fun i j => (frameProjection U i j) ^ 2) * leverageNormalizer U

theorem normalizedFisher_eq_normalized_laplacian {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) :
    normalizedFisher U = leverageNormalizer U * projectionLaplacian (frameProjection U) *
      leverageNormalizer U := by
  simp only [normalizedFisher, normalizedNormalMapMatrix, Matrix.transpose_mul]
  have hD : (leverageNormalizer U).transpose = leverageNormalizer U := by
    simp [leverageNormalizer]
  rw [hD]
  simp only [Matrix.mul_assoc]
  rw [← Matrix.mul_assoc (normalMapMatrix U).transpose,
    normalMapMatrix_gram hU]

theorem normalizedFisher_add_overlap {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) :
    normalizedFisher U + normalizedOverlap U = 1 := by
  rw [normalizedFisher_eq_normalized_laplacian hU]
  unfold normalizedOverlap projectionLaplacian
  rw [Matrix.mul_sub, Matrix.sub_mul]
  simp only [sub_add_cancel]
  ext i j
  simp only [leverageNormalizer, Matrix.diagonal_mul_diagonal, Matrix.diagonal_apply,
    Matrix.one_apply]
  by_cases hij : i = j
  · subst j
    simp only [if_true, frameProjection_diagonal]
    have hs := Real.sq_sqrt (hp i).le
    have hn := (Real.sqrt_pos.mpr (hp i)).ne'
    field_simp
    nlinarith
  · simp [hij]

theorem normalizedFisher_posSemidef {n d : ℕ} (U : Frame n d) :
    (normalizedFisher U).PosSemidef := by
  simpa only [normalizedFisher, Matrix.conjTranspose_eq_transpose_of_trivial] using
    Matrix.posSemidef_conjTranspose_mul_self (normalizedNormalMapMatrix U)

theorem normalizedOverlap_posSemidef {n d : ℕ} (U : Frame n d) :
    (normalizedOverlap U).PosSemidef := by
  have hP : (frameProjection U).PosSemidef := by
    simpa only [frameProjection, Matrix.conjTranspose_eq_transpose_of_trivial] using
      Matrix.posSemidef_self_mul_conjTranspose U
  have hW : (Matrix.of (fun i j => (frameProjection U i j) ^ 2)).PosSemidef := by
    simpa only [Matrix.hadamard, pow_two] using hP.hadamard hP
  have h := hW.mul_mul_conjTranspose_same (leverageNormalizer U)
  simpa [normalizedOverlap, leverageNormalizer] using h

theorem normalizedOverlap_trace {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) :
    (normalizedOverlap U).trace = d := by
  calc
    _ = (frameProjection U).trace := by
      unfold Matrix.trace
      apply Finset.sum_congr rfl
      intro i _
      simp only [normalizedOverlap, leverageNormalizer, Matrix.diag_apply,
        Matrix.mul_diagonal, Matrix.diagonal_mul, Matrix.of_apply, frameProjection_diagonal]
      have hs := Real.sq_sqrt (hp i).le
      have hn := (Real.sqrt_pos.mpr (hp i)).ne'
      field_simp
      nlinarith
    _ = (U.transpose * U).trace := Matrix.trace_mul_comm _ _
    _ = _ := by rw [hU]; simp

/-- Eigenvalues of the normalized Fisher matrix, with multiplicities. -/
def normalizedFisherEigenvalue {n d : ℕ} (U : Frame n d) : Fin n → ℝ :=
  (normalizedFisher_posSemidef U).isHermitian.eigenvalues

theorem normalizedFisherEigenvalue_nonneg {n d : ℕ} (U : Frame n d) (i : Fin n) :
    0 ≤ normalizedFisherEigenvalue U i :=
  (normalizedFisher_posSemidef U).eigenvalues_nonneg i

/-- The normalization turns Fisher into a positive contraction. -/
theorem normalizedFisherEigenvalue_le_one {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (i : Fin n) :
    normalizedFisherEigenvalue U i ≤ 1 := by
  let hs := (normalizedFisher_posSemidef U).isHermitian
  let y := hs.eigenvectorBasis i
  have hcomp : (1 - normalizedFisher U).PosSemidef := by
    have heq : 1 - normalizedFisher U = normalizedOverlap U := by
      rw [← normalizedFisher_add_overlap hU hp]
      abel
    rw [heq]
    exact normalizedOverlap_posSemidef U
  have hq := hcomp.dotProduct_mulVec_nonneg (fun j => y j)
  have hy : (fun j => y j) ⬝ᵥ (fun j => y j) = 1 := by
    have hi := hs.eigenvectorBasis.inner_eq_ite i i
    simpa only [EuclideanSpace.inner_eq_star_dotProduct, star_trivial, if_true] using hi
  have he : normalizedFisherEigenvalue U i =
      (fun j => y j) ⬝ᵥ (normalizedFisher U *ᵥ (fun j => y j)) := by
    simpa only [normalizedFisherEigenvalue, RCLike.re_to_real, star_trivial] using hs.eigenvalues_eq i
  simp only [star_trivial, Matrix.sub_mulVec, Matrix.one_mulVec, dotProduct_sub] at hq
  rw [hy, ← he] at hq
  linarith

/-- The total spectral deficit is exactly the rank of the input frame. -/
theorem normalizedFisher_deficit_sum {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) :
    (∑ i, (1 - normalizedFisherEigenvalue U i)) = d := by
  have ht := congrArg Matrix.trace (normalizedFisher_add_overlap hU hp)
  rw [Matrix.trace_add, normalizedOverlap_trace hU hp] at ht
  have he := (normalizedFisher_posSemidef U).isHermitian.trace_eq_sum_eigenvalues
  simp only [RCLike.ofReal_real_eq_id, id_eq] at he
  change (normalizedFisher U).trace = ∑ i, normalizedFisherEigenvalue U i at he
  simp only [Finset.sum_sub_distrib, Finset.sum_const, Finset.card_univ,
    Fintype.card_fin, nsmul_eq_mul, mul_one, ← he]
  simp only [Matrix.trace_one, Fintype.card_fin] at ht
  linarith

def lowNormalizedModes {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Finset (Fin n) :=
  Finset.univ.filter (fun i => normalizedFisherEigenvalue U i ≤ ρ)

def highNormalizedModes {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Finset (Fin n) :=
  Finset.univ.filter (fun i => ρ < normalizedFisherEigenvalue U i)

/-- Exactly the low modes consume a definite amount of the trace deficit. -/
theorem lowNormalizedModes_card_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : ρ < 1) :
    ((lowNormalizedModes U ρ).card : ℝ) ≤ (d : ℝ) / (1 - ρ) := by
  apply (le_div_iff₀ (sub_pos.mpr hρ)).2
  calc
    _ = ∑ _i ∈ lowNormalizedModes U ρ, (1 - ρ) := by simp; ring
    _ ≤ ∑ i ∈ lowNormalizedModes U ρ, (1 - normalizedFisherEigenvalue U i) := by
      apply Finset.sum_le_sum
      intro i hi
      have hm := (Finset.mem_filter.mp hi).2
      linarith
    _ ≤ ∑ i, (1 - normalizedFisherEigenvalue U i) :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun i _ _ => sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp i))
    _ = _ := normalizedFisher_deficit_sum hU hp

/-- Trace of the positive residual in the spectral truncation decomposition. -/
def normalizedPositiveResidualMass {n d : ℕ} (U : Frame n d) (ρ : ℝ) : ℝ :=
  ∑ i ∈ highNormalizedModes U ρ, (1 - normalizedFisherEigenvalue U i)

/-- Trace of the negative residual; zero eigenvalues contribute zero. -/
def normalizedNegativeResidualMass {n d : ℕ} (U : Frame n d) (ρ : ℝ) : ℝ :=
  ∑ i ∈ lowNormalizedModes U ρ, normalizedFisherEigenvalue U i

theorem normalizedPositiveResidualMass_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (ρ : ℝ) :
    normalizedPositiveResidualMass U ρ ≤ d := by
  calc
    _ ≤ ∑ i, (1 - normalizedFisherEigenvalue U i) :=
      Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _)
        (fun i _ _ => sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp i))
    _ = _ := normalizedFisher_deficit_sum hU hp

theorem normalizedNegativeResidualMass_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ1 : ρ < 1) :
    normalizedNegativeResidualMass U ρ ≤ ρ * (d : ℝ) / (1 - ρ) := by
  calc
    _ ≤ ∑ _i ∈ lowNormalizedModes U ρ, ρ := by
      apply Finset.sum_le_sum
      intro i hi
      exact (Finset.mem_filter.mp hi).2
    _ = ρ * ((lowNormalizedModes U ρ).card : ℝ) := by simp [mul_comm]
    _ ≤ ρ * ((d : ℝ) / (1 - ρ)) :=
      mul_le_mul_of_nonneg_left (lowNormalizedModes_card_le hU hp hρ1) hρ0
    _ = _ := by ring

theorem normalizedNegativeResidualMass_le_two_mul {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ : ρ ≤ 1 / 2) :
    normalizedNegativeResidualMass U ρ ≤ 2 * ρ * d := by
  have hρ1 : ρ < 1 := by linarith
  apply (normalizedNegativeResidualMass_le hU hp hρ0 hρ1).trans
  apply (div_le_iff₀ (sub_pos.mpr hρ1)).2
  have hd : (0 : ℝ) ≤ d := Nat.cast_nonneg d
  nlinarith [mul_nonneg (mul_nonneg hρ0 hd) (show 0 ≤ 1 / 2 - ρ by linarith)]

/-- The eigenbasis in the diagonal-coordinate space. -/
def normalizedFisherEigenvector {n d : ℕ} (U : Frame n d) (i : Fin n) :
    EuclideanSpace ℝ (Fin n) :=
  (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis i

theorem normalizedFisher_eigenvector {n d : ℕ} (U : Frame n d) (i : Fin n) :
    Matrix.toEuclideanLin (normalizedFisher U) (normalizedFisherEigenvector U i) =
      normalizedFisherEigenvalue U i • normalizedFisherEigenvector U i := by
  apply WithLp.ofLp_injective 2
  simpa only [Matrix.ofLp_toLpLin, WithLp.ofLp_smul, Matrix.toLin'_apply,
    normalizedFisherEigenvector, normalizedFisherEigenvalue] using
    (normalizedFisher_posSemidef U).isHermitian.mulVec_eigenvectorBasis i

/-- Images of distinct Fisher eigenvectors are orthogonal, and their squared
norms are the corresponding Fisher eigenvalues. -/
theorem normalizedNormalMap_eigenvector_inner {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    inner ℝ (Matrix.toEuclideanLin (normalizedNormalMapMatrix U) (normalizedFisherEigenvector U i))
      (Matrix.toEuclideanLin (normalizedNormalMapMatrix U) (normalizedFisherEigenvector U j)) =
      if i = j then normalizedFisherEigenvalue U j else 0 := by
  have hadj : LinearMap.adjoint (Matrix.toEuclideanLin (normalizedNormalMapMatrix U)) =
      Matrix.toEuclideanLin (normalizedNormalMapMatrix U).transpose := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using
      (Matrix.toEuclideanLin_conjTranspose_eq_adjoint (normalizedNormalMapMatrix U)).symm
  have hcomp : (Matrix.toEuclideanLin (normalizedNormalMapMatrix U).transpose).comp
      (Matrix.toEuclideanLin (normalizedNormalMapMatrix U)) =
      Matrix.toEuclideanLin (normalizedFisher U) := by
    simp only [normalizedFisher, Matrix.toEuclideanLin, Matrix.toLpLin_mul_same]
  rw [← LinearMap.adjoint_inner_right, hadj]
  change inner ℝ (normalizedFisherEigenvector U i)
    (((Matrix.toEuclideanLin (normalizedNormalMapMatrix U).transpose).comp
      (Matrix.toEuclideanLin (normalizedNormalMapMatrix U))) (normalizedFisherEigenvector U j)) = _
  rw [hcomp, normalizedFisher_eigenvector, real_inner_smul_right]
  have hi := (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis.inner_eq_ite i j
  change inner ℝ (normalizedFisherEigenvector U i) (normalizedFisherEigenvector U j) = _ at hi
  rw [hi]
  split_ifs <;> simp

/-- The actual unit normal direction associated with a positive Fisher mode.
At a zero mode this definition is zero. -/
def normalizedNormalDirection {n d : ℕ} (U : Frame n d) (i : Fin n) :
    EuclideanSpace ℝ (Fin n × Fin d) :=
  (Real.sqrt (normalizedFisherEigenvalue U i))⁻¹ •
    Matrix.toEuclideanLin (normalizedNormalMapMatrix U) (normalizedFisherEigenvector U i)

theorem normalizedNormalDirection_inner {n d : ℕ} (U : Frame n d)
    (i j : Fin n) (hi : 0 < normalizedFisherEigenvalue U i)
    (hj : 0 < normalizedFisherEigenvalue U j) :
    inner ℝ (normalizedNormalDirection U i) (normalizedNormalDirection U j) =
      if i = j then 1 else 0 := by
  simp only [normalizedNormalDirection, real_inner_smul_left, real_inner_smul_right,
    normalizedNormalMap_eigenvector_inner]
  by_cases hij : i = j
  · subst j
    simp only [if_true]
    have hs := Real.sq_sqrt hi.le
    have hn := (Real.sqrt_pos.mpr hi).ne'
    field_simp
    nlinarith
  · simp [hij]

theorem normalizedNormalDirections_orthonormal {n d : ℕ} (U : Frame n d) :
    Orthonormal ℝ (fun i : {i : Fin n // 0 < normalizedFisherEigenvalue U i} =>
      normalizedNormalDirection U i.val) := by
  rw [orthonormal_iff_ite]
  intro i j
  simpa only [Subtype.val_inj] using normalizedNormalDirection_inner U i.val j.val i.property j.property

/-- The high-mode directions used in the truncation are an actual orthonormal
family in the ambient tangent matrix space. -/
theorem highNormalizedNormalDirections_orthonormal {n d : ℕ} (U : Frame n d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) :
    Orthonormal ℝ (fun i : highNormalizedModes U ρ => normalizedNormalDirection U i.val) := by
  rw [orthonormal_iff_ite]
  intro i j
  have hi : 0 < normalizedFisherEigenvalue U i.val :=
    lt_of_le_of_lt hρ (Finset.mem_filter.mp i.property).2
  have hj : 0 < normalizedFisherEigenvalue U j.val :=
    lt_of_le_of_lt hρ (Finset.mem_filter.mp j.property).2
  simpa only [Subtype.val_inj] using normalizedNormalDirection_inner U i.val j.val hi hj

/-- Covariance decomposes along the images of any orthonormal basis. -/
theorem matrix_covariance_eq_sum_image_outer {ι κ : Type*} [Fintype ι] [Fintype κ]
    [DecidableEq ι] [DecidableEq κ]
    (M : Matrix κ ι ℝ) (b : OrthonormalBasis ι ℝ (EuclideanSpace ℝ ι)) :
    M * M.transpose = ∑ i, Matrix.vecMulVec
      (fun p => Matrix.toEuclideanLin M (b i) p)
      (fun p => Matrix.toEuclideanLin M (b i) p) := by
  ext p q
  have h := b.sum_inner_mul_inner (WithLp.toLp 2 (M p)) (WithLp.toLp 2 (M q))
  simpa only [Matrix.mul_apply, Matrix.transpose_apply, Matrix.sum_apply,
    Matrix.vecMulVec_apply, Matrix.toLpLin_apply, Matrix.mulVec, dotProduct,
    PiLp.inner_apply, Real.inner_apply, WithLp.ofLp_toLp, mul_comm] using! h.symm

/-- The ambient covariance represented by the normalized normal map. -/
def normalizedNormalCovariance {n d : ℕ} (U : Frame n d) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  normalizedNormalMapMatrix U * (normalizedNormalMapMatrix U).transpose

def normalDirectionOuter {n d : ℕ} (U : Frame n d) (i : Fin n) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.vecMulVec (fun p => normalizedNormalDirection U i p)
    (fun p => normalizedNormalDirection U i p)

theorem normalDirectionOuter_trace_of_pos {n d : ℕ} (U : Frame n d) (i : Fin n)
    (hi : 0 < normalizedFisherEigenvalue U i) :
    (normalDirectionOuter U i).trace = 1 := by
  have h := normalizedNormalDirection_inner U i i hi hi
  simpa only [normalDirectionOuter, Matrix.trace_vecMulVec,
    EuclideanSpace.inner_eq_star_dotProduct, star_trivial, if_true] using h

theorem normalDirectionOuter_posSemidef {n d : ℕ} (U : Frame n d) (i : Fin n) :
    (normalDirectionOuter U i).PosSemidef := by
  simpa only [normalDirectionOuter, star_trivial] using
    Matrix.posSemidef_vecMulVec_self_star (fun p => normalizedNormalDirection U i p)

theorem normalizedNormalCovariance_decomposition {n d : ℕ} (U : Frame n d) :
    normalizedNormalCovariance U = ∑ i, normalizedFisherEigenvalue U i • normalDirectionOuter U i := by
  rw [normalizedNormalCovariance, matrix_covariance_eq_sum_image_outer _
    (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis]
  apply Finset.sum_congr rfl
  intro i _
  by_cases hi : normalizedFisherEigenvalue U i = 0
  · have hz : Matrix.toEuclideanLin (normalizedNormalMapMatrix U) (normalizedFisherEigenvector U i) = 0 := by
      apply (inner_self_eq_zero (𝕜 := ℝ)).mp
      simpa only [if_true, hi] using normalizedNormalMap_eigenvector_inner U i i
    simp only [hi, zero_smul]
    change Matrix.vecMulVec
      (fun p => Matrix.toEuclideanLin (normalizedNormalMapMatrix U) (normalizedFisherEigenvector U i) p)
      (fun p => Matrix.toEuclideanLin (normalizedNormalMapMatrix U) (normalizedFisherEigenvector U i) p) = 0
    rw [hz]
    simp
    rfl
  · have hpos := lt_of_le_of_ne (normalizedFisherEigenvalue_nonneg U i) (Ne.symm hi)
    have hs := Real.sq_sqrt hpos.le
    have hn := (Real.sqrt_pos.mpr hpos).ne'
    ext p q
    simp only [normalDirectionOuter, normalizedNormalDirection, Matrix.smul_apply,
      smul_eq_mul, Matrix.vecMulVec_apply, PiLp.smul_apply, normalizedFisherEigenvector]
    field_simp
    rw [hs]

def normalizedHighProjection {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  ∑ i ∈ highNormalizedModes U ρ, normalDirectionOuter U i

def normalizedPositiveResidual {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  ∑ i ∈ highNormalizedModes U ρ, (1 - normalizedFisherEigenvalue U i) • normalDirectionOuter U i

def normalizedNegativeResidual {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  ∑ i ∈ lowNormalizedModes U ρ, normalizedFisherEigenvalue U i • normalDirectionOuter U i

/-- The actual ambient truncation has the base covariance plus a positive
residual minus a negative residual. -/
theorem normalizedHighProjection_decomposition {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    normalizedHighProjection U ρ = normalizedNormalCovariance U +
      normalizedPositiveResidual U ρ - normalizedNegativeResidual U ρ := by
  have hpart : highNormalizedModes U ρ = (lowNormalizedModes U ρ)ᶜ := by
    ext i
    simp [highNormalizedModes, lowNormalizedModes, not_le]
  have hsum := Finset.sum_add_sum_compl (lowNormalizedModes U ρ)
    (fun i => normalizedFisherEigenvalue U i • normalDirectionOuter U i)
  rw [← hpart] at hsum
  rw [normalizedHighProjection, normalizedNormalCovariance_decomposition,
    normalizedPositiveResidual, normalizedNegativeResidual, ← hsum]
  have hhigh : (∑ i ∈ highNormalizedModes U ρ, normalizedFisherEigenvalue U i • normalDirectionOuter U i) +
      (∑ i ∈ highNormalizedModes U ρ, (1 - normalizedFisherEigenvalue U i) • normalDirectionOuter U i) =
      ∑ i ∈ highNormalizedModes U ρ, normalDirectionOuter U i := by
    rw [← Finset.sum_add_distrib]
    apply Finset.sum_congr rfl
    intro i _
    rw [← add_smul]
    simp
  rw [← hhigh]
  abel

theorem normalizedHighProjection_posSemidef {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (normalizedHighProjection U ρ).PosSemidef :=
  Matrix.posSemidef_sum _ (fun i _ => normalDirectionOuter_posSemidef U i)

theorem normalDirectionOuter_mul {n d : ℕ} (U : Frame n d) (i j : Fin n)
    (hi : 0 < normalizedFisherEigenvalue U i) (hj : 0 < normalizedFisherEigenvalue U j) :
    normalDirectionOuter U i * normalDirectionOuter U j =
      if i = j then normalDirectionOuter U i else 0 := by
  have hdot := normalizedNormalDirection_inner U i j hi hj
  rw [EuclideanSpace.inner_eq_star_dotProduct] at hdot
  simp only [star_trivial] at hdot
  rw [dotProduct_comm] at hdot
  unfold normalDirectionOuter
  rw [Matrix.vecMulVec_mul_vecMulVec, hdot]
  by_cases hij : i = j
  · subst j
    simp
  · simp [hij]

/-- The high-mode matrix is an orthogonal projection, not merely a covariance
with the correct trace. -/
theorem normalizedHighProjection_idempotent {n d : ℕ} (U : Frame n d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) :
    normalizedHighProjection U ρ * normalizedHighProjection U ρ =
      normalizedHighProjection U ρ := by
  unfold normalizedHighProjection
  rw [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i hi
  have hip : 0 < normalizedFisherEigenvalue U i :=
    lt_of_le_of_lt hρ (Finset.mem_filter.mp hi).2
  rw [Finset.mul_sum]
  calc
    _ = ∑ j ∈ highNormalizedModes U ρ, if i = j then normalDirectionOuter U i else 0 := by
      apply Finset.sum_congr rfl
      intro j hj
      exact normalDirectionOuter_mul U i j hip
        (lt_of_le_of_lt hρ (Finset.mem_filter.mp hj).2)
    _ = _ := by simp [hi]

theorem normalizedPositiveResidual_posSemidef {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) (ρ : ℝ) :
    (normalizedPositiveResidual U ρ).PosSemidef := by
  apply Matrix.posSemidef_sum
  intro i _
  exact (normalDirectionOuter_posSemidef U i).smul
    (sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hp i))

theorem normalizedNegativeResidual_posSemidef {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (normalizedNegativeResidual U ρ).PosSemidef := by
  apply Matrix.posSemidef_sum
  intro i _
  exact (normalDirectionOuter_posSemidef U i).smul (normalizedFisherEigenvalue_nonneg U i)

theorem normalizedHighProjection_trace {n d : ℕ} (U : Frame n d) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (normalizedHighProjection U ρ).trace = (highNormalizedModes U ρ).card := by
  rw [normalizedHighProjection, Matrix.trace_sum]
  calc
    _ = ∑ _i ∈ highNormalizedModes U ρ, (1 : ℝ) := by
      apply Finset.sum_congr rfl
      intro i hi
      exact normalDirectionOuter_trace_of_pos U i (lt_of_le_of_lt hρ (Finset.mem_filter.mp hi).2)
    _ = _ := by simp

theorem normalizedPositiveResidual_trace {n d : ℕ} (U : Frame n d) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (normalizedPositiveResidual U ρ).trace = normalizedPositiveResidualMass U ρ := by
  rw [normalizedPositiveResidual, Matrix.trace_sum]
  apply Finset.sum_congr rfl
  intro i hi
  rw [Matrix.trace_smul, normalDirectionOuter_trace_of_pos U i
    (lt_of_le_of_lt hρ (Finset.mem_filter.mp hi).2)]
  simp

theorem normalizedNegativeResidual_trace {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (normalizedNegativeResidual U ρ).trace = normalizedNegativeResidualMass U ρ := by
  rw [normalizedNegativeResidual, Matrix.trace_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [Matrix.trace_smul]
  by_cases hi : normalizedFisherEigenvalue U i = 0
  · simp [hi]
  · rw [normalDirectionOuter_trace_of_pos U i
      (lt_of_le_of_ne (normalizedFisherEigenvalue_nonneg U i) (Ne.symm hi))]
    simp

/-- The positive residual has trace at most `d`, uniformly in the ambient row
count, even though the removed projection may have rank much larger than `d`. -/
theorem normalizedPositiveResidual_trace_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (normalizedPositiveResidual U ρ).trace ≤ d := by
  rw [normalizedPositiveResidual_trace U hρ]
  exact normalizedPositiveResidualMass_le hU hp ρ

theorem normalizedNegativeResidual_trace_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ}
    (hρ0 : 0 ≤ ρ) (hρ : ρ ≤ 1 / 2) :
    (normalizedNegativeResidual U ρ).trace ≤ 2 * ρ * d := by
  rw [normalizedNegativeResidual_trace]
  exact normalizedNegativeResidualMass_le_two_mul hU hp hρ0 hρ

end Paulsen
