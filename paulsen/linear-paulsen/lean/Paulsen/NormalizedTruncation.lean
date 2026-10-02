import Paulsen.NormalizedNormalMap

/-!
# Covariance of leverage-normalized truncation

Concrete spectral projections and covariance bounds for the normal map.
-/

open Matrix
open scoped BigOperators

noncomputable section

namespace Paulsen

def fisherDirectionOuter {n d : ℕ} (U : Frame n d) (i : Fin n) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.vecMulVec (fun p => normalizedFisherEigenvector U i p)
    (fun p => normalizedFisherEigenvector U i p)

theorem fisherDirectionOuter_posSemidef {n d : ℕ} (U : Frame n d) (i : Fin n) :
    (fisherDirectionOuter U i).PosSemidef := by
  simpa only [fisherDirectionOuter, star_trivial] using
    Matrix.posSemidef_vecMulVec_self_star (fun p => normalizedFisherEigenvector U i p)

theorem fisherDirectionOuter_trace {n d : ℕ} (U : Frame n d) (i : Fin n) :
    (fisherDirectionOuter U i).trace = 1 := by
  have h := (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis.inner_eq_ite i i
  simpa only [fisherDirectionOuter, normalizedFisherEigenvector, Matrix.trace_vecMulVec,
    EuclideanSpace.inner_eq_star_dotProduct, star_trivial, if_true] using h

theorem sum_fisherDirectionOuter {n d : ℕ} (U : Frame n d) :
    (∑ i, fisherDirectionOuter U i) = 1 := by
  have h := matrix_covariance_eq_sum_image_outer (1 : Matrix (Fin n) (Fin n) ℝ)
    (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis
  simpa only [Matrix.transpose_one, Matrix.one_mul, Matrix.toEuclideanLin,
    Matrix.toLpLin_one, LinearMap.id_apply, fisherDirectionOuter, normalizedFisherEigenvector]
    using h.symm

theorem toEuclideanLin_vecMulVec_apply {ι : Type*} [Fintype ι] [DecidableEq ι]
    (x y : EuclideanSpace ℝ ι) :
    Matrix.toEuclideanLin (Matrix.vecMulVec (fun i => x i) (fun i => x i)) y =
      inner ℝ x y • x := by
  ext p
  simp only [Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, Matrix.vecMulVec_apply,
    PiLp.smul_apply, smul_eq_mul, EuclideanSpace.inner_eq_star_dotProduct, star_trivial]
  simp only [Finset.sum_mul]
  apply Finset.sum_congr rfl
  intro i _
  ring

theorem fisherDirectionOuter_eigenvector {n d : ℕ} (U : Frame n d) (i j : Fin n) :
    Matrix.toEuclideanLin (fisherDirectionOuter U i) (normalizedFisherEigenvector U j) =
      if i = j then normalizedFisherEigenvector U i else 0 := by
  rw [fisherDirectionOuter, toEuclideanLin_vecMulVec_apply]
  have hi := (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis.inner_eq_ite i j
  change inner ℝ (normalizedFisherEigenvector U i) (normalizedFisherEigenvector U j) = _ at hi
  rw [hi]
  split_ifs <;> simp

theorem normalizedFisher_spectral_decomposition {n d : ℕ} (U : Frame n d) :
    normalizedFisher U = ∑ i, normalizedFisherEigenvalue U i • fisherDirectionOuter U i := by
  apply Matrix.toEuclideanLin.injective
  apply (normalizedFisher_posSemidef U).isHermitian.eigenvectorBasis.toBasis.ext
  intro j
  change Matrix.toEuclideanLin (normalizedFisher U) (normalizedFisherEigenvector U j) =
    Matrix.toEuclideanLin (∑ i, normalizedFisherEigenvalue U i • fisherDirectionOuter U i)
      (normalizedFisherEigenvector U j)
  rw [normalizedFisher_eigenvector]
  simp only [map_sum, map_smul, LinearMap.sum_apply, LinearMap.smul_apply,
    fisherDirectionOuter_eigenvector, smul_ite, smul_zero]
  simp

def lowFisherProjection {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  ∑ i ∈ lowNormalizedModes U ρ, fisherDirectionOuter U i

def lowFisherCovariance {n d : ℕ} (U : Frame n d) (ρ : ℝ) : Matrix (Fin n) (Fin n) ℝ :=
  ∑ i ∈ lowNormalizedModes U ρ, normalizedFisherEigenvalue U i • fisherDirectionOuter U i

theorem lowFisherProjection_posSemidef {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (lowFisherProjection U ρ).PosSemidef :=
  Matrix.posSemidef_sum _ (fun i _ => fisherDirectionOuter_posSemidef U i)

theorem lowFisherProjection_trace {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (lowFisherProjection U ρ).trace = (lowNormalizedModes U ρ).card := by
  simp [lowFisherProjection, Matrix.trace_sum, fisherDirectionOuter_trace]

theorem lowFisherProjection_trace_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : ρ < 1) :
    (lowFisherProjection U ρ).trace ≤ (d : ℝ) / (1 - ρ) := by
  rw [lowFisherProjection_trace]
  exact lowNormalizedModes_card_le hU hp hρ

theorem lowFisherCovariance_posSemidef {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (lowFisherCovariance U ρ).PosSemidef := by
  apply Matrix.posSemidef_sum
  intro i _
  exact (fisherDirectionOuter_posSemidef U i).smul (normalizedFisherEigenvalue_nonneg U i)

theorem scalar_sub_lowFisherCovariance_posSemidef {n d : ℕ} (U : Frame n d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) : (ρ • (1 : Matrix (Fin n) (Fin n) ℝ) - lowFisherCovariance U ρ).PosSemidef := by
  have hid : ρ • (1 : Matrix (Fin n) (Fin n) ℝ) - lowFisherCovariance U ρ =
      (∑ i ∈ lowNormalizedModes U ρ, (ρ - normalizedFisherEigenvalue U i) • fisherDirectionOuter U i) +
      ∑ i ∈ (lowNormalizedModes U ρ)ᶜ, ρ • fisherDirectionOuter U i := by
    rw [← sum_fisherDirectionOuter U, Finset.smul_sum, lowFisherCovariance,
      ← Finset.sum_add_sum_compl (lowNormalizedModes U ρ) (fun i => ρ • fisherDirectionOuter U i)]
    simp only [sub_smul, Finset.sum_sub_distrib]
    abel
  rw [hid]
  apply Matrix.PosSemidef.add
  · apply Matrix.posSemidef_sum
    intro i hi
    exact (fisherDirectionOuter_posSemidef U i).smul
      (sub_nonneg.mpr (Finset.mem_filter.mp hi).2)
  · exact Matrix.posSemidef_sum _ (fun i _ => (fisherDirectionOuter_posSemidef U i).smul hρ)

theorem one_sub_lowFisherProjection_posSemidef {n d : ℕ} (U : Frame n d) (ρ : ℝ) :
    (1 - lowFisherProjection U ρ).PosSemidef := by
  have hid : (1 : Matrix (Fin n) (Fin n) ℝ) - lowFisherProjection U ρ =
      ∑ i ∈ (lowNormalizedModes U ρ)ᶜ, fisherDirectionOuter U i := by
    rw [← sum_fisherDirectionOuter U, lowFisherProjection,
      ← Finset.sum_add_sum_compl (lowNormalizedModes U ρ) (fisherDirectionOuter U)]
    abel
  rw [hid]
  exact Matrix.posSemidef_sum _ (fun i _ => fisherDirectionOuter_posSemidef U i)

theorem lowFisherProjection_diagonal_nonneg {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) :
    0 ≤ lowFisherProjection U ρ i i := (lowFisherProjection_posSemidef U ρ).diag_nonneg

theorem lowFisherProjection_diagonal_le_one {n d : ℕ} (U : Frame n d) (ρ : ℝ) (i : Fin n) :
    lowFisherProjection U ρ i i ≤ 1 := by
  have h := (one_sub_lowFisherProjection_posSemidef U ρ).diag_nonneg (i := i)
  simpa only [Matrix.sub_apply, Matrix.one_apply_eq, sub_nonneg] using h

/-- Only a bounded number of rows can have large leverage in the low-eigenspace
projection. This budget scales with `d`, independently of `n`. -/
theorem lowFisherProjection_large_diagonal_card_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hp : ∀ i, 0 < rowNormSq U i) {ρ t : ℝ}
    (hρ : ρ < 1) (ht : 0 < t) :
    ((Finset.univ.filter (fun i => t ≤ lowFisherProjection U ρ i i)).card : ℝ) ≤
      (d : ℝ) / ((1 - ρ) * t) := by
  apply (le_div_iff₀ (mul_pos (sub_pos.mpr hρ) ht)).2
  have hsum : ((Finset.univ.filter (fun i => t ≤ lowFisherProjection U ρ i i)).card : ℝ) * t ≤
      (lowFisherProjection U ρ).trace := by
    calc
      _ = ∑ _i ∈ Finset.univ.filter (fun i => t ≤ lowFisherProjection U ρ i i), t := by simp
      _ ≤ ∑ i ∈ Finset.univ.filter (fun i => t ≤ lowFisherProjection U ρ i i),
          lowFisherProjection U ρ i i :=
        Finset.sum_le_sum (fun i hi => (Finset.mem_filter.mp hi).2)
      _ ≤ ∑ i, lowFisherProjection U ρ i i :=
        Finset.sum_le_sum_of_subset_of_nonneg (Finset.filter_subset _ _)
          (fun i _ _ => lowFisherProjection_diagonal_nonneg U ρ i)
      _ = _ := rfl
  have htotal := lowFisherProjection_trace_le hU hp hρ
  have hb := (le_div_iff₀ (sub_pos.mpr hρ)).mp (hsum.trans htotal)
  nlinarith

theorem normalizedNormalDirection_pullback {n d : ℕ} (U : Frame n d) (i : Fin n)
    (hi : 0 < normalizedFisherEigenvalue U i) :
    Matrix.toEuclideanLin (normalizedNormalMapMatrix U).transpose (normalizedNormalDirection U i) =
      Real.sqrt (normalizedFisherEigenvalue U i) • normalizedFisherEigenvector U i := by
  have hcomp : (Matrix.toEuclideanLin (normalizedNormalMapMatrix U).transpose).comp
      (Matrix.toEuclideanLin (normalizedNormalMapMatrix U)) =
      Matrix.toEuclideanLin (normalizedFisher U) := by
    simp only [normalizedFisher, Matrix.toEuclideanLin, Matrix.toLpLin_mul_same]
  rw [normalizedNormalDirection, map_smul]
  change (Real.sqrt (normalizedFisherEigenvalue U i))⁻¹ •
    (((Matrix.toEuclideanLin (normalizedNormalMapMatrix U).transpose).comp
      (Matrix.toEuclideanLin (normalizedNormalMapMatrix U))) (normalizedFisherEigenvector U i)) = _
  rw [hcomp, normalizedFisher_eigenvector, smul_smul]
  congr 1
  have hs := Real.sq_sqrt hi.le
  have hn := (Real.sqrt_pos.mpr hi).ne'
  field_simp
  nlinarith

theorem matrix_outer_conjugation {ι κ : Type*} [Fintype ι]
    (M : Matrix κ ι ℝ) (x : ι → ℝ) :
    M * Matrix.vecMulVec x x * M.transpose = Matrix.vecMulVec (M *ᵥ x) (M *ᵥ x) := by
  rw [Matrix.mul_vecMulVec, Matrix.vecMulVec_mul, Matrix.vecMul_transpose]

theorem normalDirectionOuter_pullback {n d : ℕ} (U : Frame n d) (i : Fin n)
    (hi : 0 < normalizedFisherEigenvalue U i) :
    (normalizedNormalMapMatrix U).transpose * normalDirectionOuter U i * normalizedNormalMapMatrix U =
      normalizedFisherEigenvalue U i • fisherDirectionOuter U i := by
  have hv : (normalizedNormalMapMatrix U).transpose *ᵥ (fun p => normalizedNormalDirection U i p) =
      fun p => Real.sqrt (normalizedFisherEigenvalue U i) * normalizedFisherEigenvector U i p := by
    have h := congrArg (WithLp.ofLp (p := 2)) (normalizedNormalDirection_pullback U i hi)
    simpa only [Matrix.ofLp_toLpLin, Matrix.toLin'_apply, WithLp.ofLp_smul, Pi.smul_apply, smul_eq_mul] using! h
  have heq := matrix_outer_conjugation (normalizedNormalMapMatrix U).transpose
    (fun p => normalizedNormalDirection U i p)
  rw [Matrix.transpose_transpose] at heq
  rw [normalDirectionOuter, heq, hv]
  ext p q
  simp only [fisherDirectionOuter, Matrix.vecMulVec_apply, Matrix.smul_apply, smul_eq_mul]
  have hs := Real.sq_sqrt hi.le
  calc
    _ = (Real.sqrt (normalizedFisherEigenvalue U i)) ^ 2 *
        (normalizedFisherEigenvector U i p * normalizedFisherEigenvector U i q) := by ring
    _ = _ := by rw [hs]

theorem normalizedHighProjection_pullback {n d : ℕ} (U : Frame n d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (normalizedNormalMapMatrix U).transpose * normalizedHighProjection U ρ * normalizedNormalMapMatrix U =
      ∑ i ∈ highNormalizedModes U ρ, normalizedFisherEigenvalue U i • fisherDirectionOuter U i := by
  rw [normalizedHighProjection, Matrix.mul_sum, Matrix.sum_mul]
  apply Finset.sum_congr rfl
  intro i hi
  exact normalDirectionOuter_pullback U i (lt_of_le_of_lt hρ (Finset.mem_filter.mp hi).2)

/-- Exact covariance identity for the normalized diagonal derivative after
removing the high normal modes. -/
theorem normalizedTruncation_covariance {n d : ℕ} (U : Frame n d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (normalizedNormalMapMatrix U).transpose * (1 - normalizedHighProjection U ρ) *
      normalizedNormalMapMatrix U = lowFisherCovariance U ρ := by
  have hpart : highNormalizedModes U ρ = (lowNormalizedModes U ρ)ᶜ := by
    ext i
    simp [highNormalizedModes, lowNormalizedModes, not_le]
  rw [Matrix.mul_sub, Matrix.sub_mul, Matrix.mul_one,
    show (normalizedNormalMapMatrix U).transpose * normalizedNormalMapMatrix U = normalizedFisher U from rfl,
    normalizedHighProjection_pullback U hρ, normalizedFisher_spectral_decomposition,
    hpart, lowFisherCovariance,
    ← Finset.sum_add_sum_compl (lowNormalizedModes U ρ)
      (fun i => normalizedFisherEigenvalue U i • fisherDirectionOuter U i)]
  abel

theorem normalizedTruncation_covariance_le {n d : ℕ} (U : Frame n d)
    {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (ρ • (1 : Matrix (Fin n) (Fin n) ℝ) -
      (normalizedNormalMapMatrix U).transpose * (1 - normalizedHighProjection U ρ) *
        normalizedNormalMapMatrix U).PosSemidef := by
  rw [normalizedTruncation_covariance U hρ]
  exact scalar_sub_lowFisherCovariance_posSemidef U hρ

def leverageRoot {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i))

theorem leverageRoot_transpose {n d : ℕ} (U : Frame n d) :
    (leverageRoot U).transpose = leverageRoot U := by simp [leverageRoot]

theorem leverageRoot_mul_self {n d : ℕ} (U : Frame n d) :
    leverageRoot U * leverageRoot U = Matrix.diagonal (rowNormSq U) := by
  simp only [leverageRoot, Matrix.diagonal_mul_diagonal]
  congr 1
  ext i
  exact Real.mul_self_sqrt (rowNormSq_nonneg U i)

theorem normalizedNormalMap_mul_leverageRoot {n d : ℕ} (U : Frame n d)
    (hp : ∀ i, 0 < rowNormSq U i) :
    normalizedNormalMapMatrix U * leverageRoot U = normalMapMatrix U := by
  have hD : leverageNormalizer U * leverageRoot U = 1 := by
    simp only [leverageNormalizer, leverageRoot, Matrix.diagonal_mul_diagonal]
    have he : (fun i => (Real.sqrt (rowNormSq U i))⁻¹ * Real.sqrt (rowNormSq U i)) = fun _ => 1 := by
      funext i
      exact inv_mul_cancel₀ (Real.sqrt_pos.mpr (hp i)).ne'
    rw [he, Matrix.diagonal_one]
  rw [normalizedNormalMapMatrix, Matrix.mul_assoc, hD, Matrix.mul_one]

/-- Undoing leverage normalization gives the exact retained covariance of the
original diagonal derivative. -/
theorem normalTruncation_covariance {n d : ℕ} (U : Frame n d)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (normalMapMatrix U).transpose * (1 - normalizedHighProjection U ρ) * normalMapMatrix U =
      leverageRoot U * lowFisherCovariance U ρ * leverageRoot U := by
  calc
    _ = leverageRoot U * ((normalizedNormalMapMatrix U).transpose *
        (1 - normalizedHighProjection U ρ) * normalizedNormalMapMatrix U) * leverageRoot U := by
      conv_lhs => rw [← normalizedNormalMap_mul_leverageRoot U hp]
      simp only [Matrix.transpose_mul, leverageRoot_transpose, Matrix.mul_assoc]
    _ = _ := by rw [normalizedTruncation_covariance U hρ]

/-- The covariance inequality in the original, unnormalized row coordinates. -/
theorem normalTruncation_covariance_le {n d : ℕ} (U : Frame n d)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) :
    (ρ • Matrix.diagonal (rowNormSq U) -
      (normalMapMatrix U).transpose * (1 - normalizedHighProjection U ρ) * normalMapMatrix U).PosSemidef := by
  rw [normalTruncation_covariance U hp hρ]
  have h := (scalar_sub_lowFisherCovariance_posSemidef U hρ).mul_mul_conjTranspose_same (leverageRoot U)
  simpa only [Matrix.conjTranspose_eq_transpose_of_trivial, leverageRoot_transpose,
    Matrix.mul_sub, Matrix.sub_mul, Matrix.mul_smul, Matrix.smul_mul, Matrix.mul_one,
    leverageRoot_mul_self] using h

theorem normalTruncation_covariance_diagonal_le {n d : ℕ} (U : Frame n d)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 ≤ ρ) (i : Fin n) :
    ((normalMapMatrix U).transpose * ((1 : Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ) -
      normalizedHighProjection U ρ) * normalMapMatrix U) i i ≤
      ρ * rowNormSq U i := by
  have h := (normalTruncation_covariance_le U hp hρ).diag_nonneg (i := i)
  simpa only [Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul, Matrix.diagonal_apply_eq,
    sub_nonneg] using h

end Paulsen
