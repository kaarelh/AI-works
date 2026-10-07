import Paulsen.Paper.ModerateAuxFilter
import Paulsen.Paper.ResolventTangent

/-!
# Helpers for `Paulsen.Paper.Moderate`: Gaussian second moments and the expected graph

* the covariance of `𝒜Z` (`lem:filter`(b)) by the push-through identity;
* the row bound for `T_{e_k}` (`lem:commutator`(b));
* covariance linearity and the decomposition
  `E𝓛(Y) = E𝓛(Y_{Z₀}) - (α/n)∑_k 𝓛(Y_{ζ_k}) - (1/n)∑_μ r_μ 𝓛(Y_{Z_y})`,
  where `α = (1+ρ)⁻¹`. The paper bounds the entire loss directly by `Ω/ρ`.
-/

namespace Paulsen.Paper.ModerateAux

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

variable {n d : ℕ}

/-! ### The adjoint pairing and `lem:filter`(b) -/

/-- `⟨𝒜H, x⟩ = ⟨H, N_x⟩_F` for horizontal `H`. -/
theorem dot_mulVec_transpose {m k : Type*} [Fintype m] [Fintype k] (A : Matrix m k ℝ)
    (a : k → ℝ) (b : m → ℝ) : (A *ᵥ a) ⬝ᵥ b = a ⬝ᵥ (A.transpose *ᵥ b) := by
  rw [dotProduct_comm, Matrix.dotProduct_mulVec, ← Matrix.mulVec_transpose, dotProduct_comm]

theorem diag_pairing_eq {U H : Frame n d} (hUH : U.transpose * H = 0) (x : Fin n → ℝ) :
    ∑ i, x i * (H * U.transpose) i i = ∑ i, ∑ k, H i k * ambientNormal U x i k := by
  have hQH := complement_mul_horizontal hUH
  have e : ∀ i, (H * U.transpose) i i = ∑ k, H i k * U i k := by
    intro i; simp [Matrix.mul_apply]
  have h1 : (∑ i, x i * (H * U.transpose) i i) =
      inner ℝ (normalFrobVector H) (normalFrobVector (Matrix.diagonal x * U)) := by
    simp only [e, normalFrobVector, PiLp.inner_apply, Real.inner_apply, Fintype.sum_prod_type,
      Matrix.diagonal_mul, Finset.mul_sum]
    apply Finset.sum_congr rfl; intro i _; apply Finset.sum_congr rfl; intro k _; ring
  have h2 : inner ℝ (normalFrobVector H) (normalFrobVector (ambientNormal U x)) =
      ∑ i, ∑ k, H i k * ambientNormal U x i k := by
    simp only [normalFrobVector, PiLp.inner_apply, Real.inner_apply, Fintype.sum_prod_type]
  rw [h1, ← h2, ambientNormal, Matrix.mul_assoc,
    normalFrobVector_inner_mul_left H (frameComplementProjection U) (Matrix.diagonal x * U),
    frameComplementProjection_transpose, hQH]

theorem moderateNoiseFrame_horizontal' {U : Frame n d} (hU : IsParseval U) (ρ : ℝ)
    (g : FrameVector n d) : U.transpose * Resolvent.moderateNoiseFrame U ρ g = 0 :=
  Resolvent.normalizedTangentNoiseFactor_horizontal hU ρ g.ofLp

theorem normalMap_eq_normalized_mul {U : Frame n d} (hp : ∀ i, 0 < rowNormSq U i) :
    normalMapMatrix U = normalizedNormalMapMatrix U *
      Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i)) := by
  rw [normalizedNormalMapMatrix, leverageNormalizer, Matrix.mul_assoc,
    Matrix.diagonal_mul_diagonal]
  have : (fun i => (Real.sqrt (rowNormSq U i))⁻¹ * Real.sqrt (rowNormSq U i)) = fun _ => 1 := by
    funext i; exact inv_mul_cancel₀ (Real.sqrt_pos.mpr (hp i)).ne'
  rw [this, Matrix.diagonal_one, Matrix.mul_one]

/-- `lem:filter`(b), the covariance identity. -/
theorem integral_diag_pairing_sq {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (x : Fin n → ℝ) :
    ∫ g, (∑ i, x i * (Resolvent.moderateNoiseFrame U ρ g * U.transpose) i i) ^ 2
        ∂stdGaussian (FrameVector n d) =
      (1 / (n : ℝ)) * matrixQuadratic
        (Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i)) *
          (ρ • (normalizedFisher U *
            (ρ • 1 + normalizedFisher U)⁻¹)) *
          Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i))) x := by
  set F := Resolvent.normalizedTangentNoiseFactor U ρ
  set w : Fin n × Fin d → ℝ := normalMapMatrix U *ᵥ x
  set Dh := Matrix.diagonal (fun i => Real.sqrt (rowNormSq U i))
  have hpt : ∀ g : FrameVector n d,
      (∑ i, x i * (Resolvent.moderateNoiseFrame U ρ g * U.transpose) i i) =
        ∑ p, (Matrix.toEuclideanLin F g) p * w p := by
    intro g
    rw [diag_pairing_eq (moderateNoiseFrame_horizontal' hU ρ g), Fintype.sum_prod_type]
    apply Finset.sum_congr rfl; intro i _; apply Finset.sum_congr rfl; intro k _
    congr 1
    simp only [w, normalMapMatrix_mulVec]
    rfl
  simp_rw [hpt]
  rw [integral_sq_linear_stdGaussian, Resolvent.normalizedTangentNoiseFactor_covariance hU hρ.le,
    Resolvent.covariance_rational_formula hU hp hρ, Matrix.smul_mulVec, dotProduct_smul,
    smul_eq_mul, mq_eq_dot]
  congr 1
  have hw : w = normalizedNormalMapMatrix U *ᵥ (Dh *ᵥ x) := by
    simp only [w, Dh, Matrix.mulVec_mulVec, ← normalMap_eq_normalized_mul hp]
  have hDt : Dh.transpose = Dh := Matrix.diagonal_transpose _
  set C := ρ • (horizontalProjectionMatrix U *
    (ρ • 1 + normalizedNormalCovariance U)⁻¹)
  set N := normalizedNormalMapMatrix U
  calc w ⬝ᵥ (C *ᵥ w) = (Dh *ᵥ x) ⬝ᵥ (N.transpose *ᵥ (C *ᵥ (N *ᵥ (Dh *ᵥ x)))) := by
        rw [hw, dot_mulVec_transpose]
    _ = (Dh *ᵥ x) ⬝ᵥ ((N.transpose * C * N) *ᵥ (Dh *ᵥ x)) := by
        simp only [Matrix.mulVec_mulVec, Matrix.mul_assoc]
    _ = x ⬝ᵥ (Dh.transpose *ᵥ ((N.transpose * C * N) *ᵥ (Dh *ᵥ x))) := dot_mulVec_transpose _ _ _
    _ = _ := by
        rw [filtered_compress hU hρ, hDt]
        simp only [Matrix.mulVec_mulVec, Matrix.mul_assoc]

/-! ### `lem:commutator`(b): the row bound for `T_{e_k}` -/

theorem nfv_single_mul_sq (K : Matrix (Fin n) (Fin n) ℝ) (k : Fin n) :
    ‖normalFrobVector (Matrix.diagonal (Pi.single k 1) * K)‖ ^ 2 = ∑ j, K k j ^ 2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp [normalFrobVector, Fintype.sum_prod_type, Matrix.diagonal_mul, Pi.single_apply]

theorem nfv_mul_single_sq (K : Matrix (Fin n) (Fin n) ℝ) (k : Fin n) :
    ‖normalFrobVector (K * Matrix.diagonal (Pi.single k 1))‖ ^ 2 = ∑ i, K i k ^ 2 := by
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [normalFrobVector, Fintype.sum_prod_type, Matrix.mul_diagonal, Pi.single_apply]
  apply Finset.sum_congr rfl; intro i _
  simp

theorem tangent_single_commutator_sq_le {U : Frame n d} (hU : IsParseval U) (k : Fin n)
    (x : Fin n → ℝ) :
    ‖normalFrobVector (diagonalCommutator x (ambientNormalTangent U (Pi.single k 1)))‖ ^ 2 ≤
      4 * ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2 := by
  set K := diagonalCommutator x (frameProjection U)
  have hR := projectionReflection_parseval hU
  have hK : ∀ i j, K i j = (x i - x j) * frameProjection U i j := by
    intro i j
    simp only [K, diagonalCommutator, Matrix.sub_apply, Matrix.diagonal_mul, Matrix.mul_diagonal]
    ring
  have ha : ‖normalFrobVector (Matrix.diagonal (Pi.single k 1) * K)‖ ^ 2 =
      ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2 := by
    rw [nfv_single_mul_sq]
    apply Finset.sum_congr rfl; intro j _; rw [hK]; ring
  have hb : ‖normalFrobVector (K * Matrix.diagonal (Pi.single k 1))‖ ^ 2 =
      ∑ j, frameProjection U k j ^ 2 * (x k - x j) ^ 2 := by
    rw [nfv_mul_single_sq]
    apply Finset.sum_congr rfl; intro j _; rw [hK, frameProjection_symm U j k]; ring
  have hle : ‖normalFrobVector (diagonalCommutator x (ambientNormalTangent U (Pi.single k 1)))‖ ≤
      ‖normalFrobVector (Matrix.diagonal (Pi.single k 1) * K)‖ +
        ‖normalFrobVector (K * Matrix.diagonal (Pi.single k 1))‖ := by
    rw [ambientNormalTangent_commutator, normalFrobVector_add]
    calc _ ≤ ‖normalFrobVector (projectionReflection U * Matrix.diagonal (Pi.single k 1) * K)‖ +
          ‖normalFrobVector (K * Matrix.diagonal (Pi.single k 1) * projectionReflection U)‖ :=
          norm_add_le _ _
      _ = _ := by
          rw [Matrix.mul_assoc, normalFrobVector_parseval_mul_norm hR]
          rw [← projectionReflection_transpose U, normalFrobVector_mul_parseval_transpose_norm hR]
  have h0 := norm_nonneg (normalFrobVector (diagonalCommutator x
    (ambientNormalTangent U (Pi.single k 1))))
  have h2 := pow_le_pow_left₀ h0 hle 2
  nlinarith [sq_nonneg (‖normalFrobVector (Matrix.diagonal (Pi.single k 1) * K)‖ -
    ‖normalFrobVector (K * Matrix.diagonal (Pi.single k 1))‖)]

/-! ### The expected graph as a sum over a covariance representation -/

theorem tcg_outer (U H : Frame n d) (x : Fin n → ℝ) :
    tangentCovarianceGraph U x (Matrix.vecMulVec (fun p => H p.1 p.2) (fun p => H p.1 p.2)) =
      graphEnergy (Matrix.of fun i j => ((H * U.transpose + U * H.transpose) i j) ^ 2) x := by
  rw [tangentCovarianceGraph_eq]
  congr 1
  ext i j
  simp only [Matrix.of_apply, tangentCovarianceEntry_outer]

/-- The unfiltered noise `Z₀ ∼ N(0, I/n)` in ambient coordinates. -/
def unfilteredFrame (U : Frame n d) (g : FrameVector n d) : Frame n d :=
  frameOfVector (Matrix.toEuclideanLin ((Real.sqrt (n : ℝ))⁻¹ • horizontalProjectionMatrix U) g)

theorem unconditioned_apply (U : Frame n d) (g : FrameVector n d) (i j : Fin n) :
    Matrix.toEuclideanLin (unconditionedTangentFactor U) g (i, j) =
      (unfilteredFrame U g * U.transpose + U * (unfilteredFrame U g).transpose) i j := by
  rw [← tangentLiftMatrix_mulVec]
  have e : (fun p : Fin n × Fin d => unfilteredFrame U g p.1 p.2) =
      ((Real.sqrt (n : ℝ))⁻¹ • horizontalProjectionMatrix U) *ᵥ g.ofLp := rfl
  rw [e]
  simp only [unconditionedTangentFactor, Matrix.toLpLin_apply, Matrix.smul_mulVec,
    Matrix.mulVec_smul, ← Matrix.mulVec_mulVec]

theorem integral_unfiltered_graph (U : Frame n d) (hU : IsParseval U) (x : Fin n → ℝ) :
    ∫ g, graphEnergy (Matrix.of fun i j =>
        ((unfilteredFrame U g * U.transpose + U * (unfilteredFrame U g).transpose) i j) ^ 2) x
        ∂stdGaussian (FrameVector n d) =
      (1 / (n : ℝ)) * tangentCovarianceGraph U x (horizontalProjectionMatrix U) := by
  have h := integral_gaussianImage_graphEnergy_eq_covariance (unconditionedTangentFactor U) x
  simp_rw [unconditioned_apply] at h
  rw [h, unconditionedTangentFactor_covariance hU, tangentCovarianceGraph_eq,
    ← graphEnergy_smul_eq]
  rfl

theorem integral_unfiltered_entry_sq (U : Frame n d) (hU : IsParseval U) (i j : Fin n)
    (hij : i ≠ j) :
    ∫ g, ((unfilteredFrame U g * U.transpose + U * (unfilteredFrame U g).transpose) i j) ^ 2
        ∂stdGaussian (FrameVector n d) =
      (rowNormSq U i + rowNormSq U j - 2 * rowNormSq U i * rowNormSq U j -
        2 * (frameProjection U i j) ^ 2) / (n : ℝ) := by
  have h := integral_sq_unconditionedTangent_offDiagonal hU i j hij
  simp_rw [unconditioned_apply] at h
  exact h

theorem integral_filtered_graph_eq {U : Frame n d} (hU : IsParseval U)
    (hp : ∀ i, 0 < rowNormSq U i) {ρ : ℝ} (hρ : 0 < ρ) (x : Fin n → ℝ) :
    ∫ g, graphEnergy (Matrix.of fun i j =>
        ((Resolvent.moderateNoiseFrame U ρ g * U.transpose +
          U * (Resolvent.moderateNoiseFrame U ρ g).transpose) i j) ^ 2) x
        ∂stdGaussian (FrameVector n d) =
      ∫ g, graphEnergy (Matrix.of fun i j =>
        ((unfilteredFrame U g * U.transpose + U * (unfilteredFrame U g).transpose) i j) ^ 2) x
        ∂stdGaussian (FrameVector n d) -
      (Resolvent.baseWeight ρ / (n : ℝ)) * ∑ k, graphEnergy (Matrix.of fun i j =>
        ((baseNormalDirection U k * U.transpose + U * (baseNormalDirection U k).transpose) i j)
          ^ 2) x -
      (1 / (n : ℝ)) * ∑ j ∈ highNormalizedModes U 0,
        Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) *
          graphEnergy (Matrix.of fun i k =>
            ((normalizedNormalFrame U j * U.transpose +
              U * (normalizedNormalFrame U j).transpose) i k) ^ 2) x := by
  have hY : ∀ g, (Resolvent.moderateNoiseFrame U ρ g * U.transpose +
      U * (Resolvent.moderateNoiseFrame U ρ g).transpose) =
      gaussianMatrixImage (Resolvent.retainedTangentFactor U ρ) g :=
    fun g => (Resolvent.moderateNoiseFrame_tangent U ρ g).symm
  simp_rw [hY]
  have h1 := Resolvent.integral_retainedTangent_graphEnergy_eq hU hρ.le x
  change ∫ g, graphEnergy (Matrix.of fun i j =>
    (Matrix.toEuclideanLin (Resolvent.retainedTangentFactor U ρ) g (i, j)) ^ 2) x
      ∂stdGaussian (FrameVector n d) = _
  rw [h1, integral_unfiltered_graph U hU]
  have hcov : Resolvent.covariance U ρ = horizontalProjectionMatrix U -
      Resolvent.baseWeight ρ • normalizedNormalCovariance U - Resolvent.modeSum U (Resolvent.residualWeight ρ) := by
    have hh := Resolvent.residual_decomposition hU hp hρ.le
    rw [sub_sub, ← hh]; abel
  rw [hcov, map_sub, map_sub, map_smul, normalizedNormalCovariance_base_decomposition, map_sum]
  simp only [smul_eq_mul]
  simp only [tcg_outer]
  have hR : tangentCovarianceGraph U x (Resolvent.modeSum U (Resolvent.residualWeight ρ)) =
      ∑ j ∈ highNormalizedModes U 0, Resolvent.residualWeight ρ (normalizedFisherEigenvalue U j) *
        graphEnergy (Matrix.of fun i k => ((normalizedNormalFrame U j * U.transpose +
          U * (normalizedNormalFrame U j).transpose) i k) ^ 2) x := by
    rw [Resolvent.modeSum, map_sum]
    apply Finset.sum_congr rfl; intro j _
    rw [map_smul, smul_eq_mul, ← tcg_outer]
    rfl
  rw [hR]
  ring

end

end Paulsen.Paper.ModerateAux
