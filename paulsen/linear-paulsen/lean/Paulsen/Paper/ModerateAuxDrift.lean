import Paulsen.Paper.ModerateAuxFilter

/-!
# Helpers for `Paulsen.Paper.Moderate`: the basis-free drift formula (`rem:drift`)

`Γ_f = (I-P)[(f fᵀ) ∘ R]U` is quadratic in `f`, the kernel modes of `S` have `N_f = 0` and
hence `Γ_f = 0` (flag 9 of the blueprint), and the spectral identity
`∑_y ((1-μ)/(ρ+μ)) y yᵀ = (I-S)(ρI+S)⁻¹` gives
`m_* = (1/n)(I-P)[(D_p^{-1/2}(I-S)(ρI+S)⁻¹D_p^{-1/2}) ∘ (I-2P)]U`.
-/

namespace Paulsen.Paper.ModerateAux

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators

noncomputable section

variable {n d : ℕ}

theorem driftGamma_eq_hadamard (U : Frame n d) (f : Fin n → ℝ) :
    Linear.driftGamma U f = frameComplementProjection U *
      Matrix.hadamard (Matrix.vecMulVec f f) (projectionReflection U) * U := by
  have h : Matrix.diagonal f * (1 - (2 : ℝ) • frameProjection U) * Matrix.diagonal f =
      Matrix.hadamard (Matrix.vecMulVec f f) (projectionReflection U) := by
    ext a b
    simp only [Matrix.mul_diagonal, Matrix.diagonal_mul, Matrix.hadamard,
      Matrix.vecMulVec_apply, projectionReflection, Matrix.of_apply]
    ring
  unfold Linear.driftGamma
  rw [← h]
  simp only [Matrix.mul_assoc]

theorem ambientNormal_eq_zero_of_kernel (U : Frame n d) (j : Fin n)
    (hμ : normalizedFisherEigenvalue U j = 0) :
    ambientNormal U (normalizedNormalPotential U j) = 0 := by
  have h := normalizedNormalPotential_image_norm U j
  rw [hμ, Real.sqrt_zero, norm_eq_zero] at h
  ext i k
  have := congrArg (fun v : EuclideanSpace ℝ (Fin n × Fin d) => v (i, k)) h
  simpa [normalFrobVector] using this

theorem driftGamma_eq_zero_of_kernel (U : Frame n d) (j : Fin n)
    (hμ : normalizedFisherEigenvalue U j = 0) :
    Linear.driftGamma U (normalizedNormalPotential U j) = 0 := by
  rw [Linear.driftGamma_eq, ambientNormal_eq_zero_of_kernel U j hμ]
  simp

theorem potential_outer (U : Frame n d) (j : Fin n) :
    Matrix.vecMulVec (normalizedNormalPotential U j) (normalizedNormalPotential U j) =
      leverageNormalizer U * Matrix.vecMulVec (normalizedFisherEigenvector U j).ofLp
        (normalizedFisherEigenvector U j).ofLp * leverageNormalizer U := by
  ext a b
  simp only [normalizedNormalPotential, leverageNormalizer, Matrix.vecMulVec_apply,
    Matrix.diagonal_mul, Matrix.mul_diagonal]
  ring

/-- The hadamard sandwich `A ↦ (I-P)(A ∘ R)U` as a linear map. -/
def hadamardSandwich (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ →ₗ[ℝ] Frame n d where
  toFun A := frameComplementProjection U * Matrix.hadamard A (projectionReflection U) * U
  map_add' A B := by
    simp only [Matrix.add_hadamard, Matrix.mul_add, Matrix.add_mul]
  map_smul' c A := by
    simp only [Matrix.smul_hadamard, Matrix.mul_smul, Matrix.smul_mul, RingHom.id_apply]

theorem residualWeight_div_eq {ρ μ : ℝ} (hμ : 0 < μ) :
    Smooth.residualWeight ρ μ / μ = (1 - μ) / (ρ + μ) := by
  unfold Smooth.residualWeight
  field_simp

/-- `rem:drift`: `m_* = (1/n)(I-P)[(D_p^{-1/2}(I-S)(ρI+S)⁻¹D_p^{-1/2}) ∘ (I-2P)]U`. -/
theorem driftMean_formula (U : Frame n d) {ρ : ℝ} (hρ : 0 < ρ) :
    Linear.driftMean U ρ = (1 / (n : ℝ)) • (frameComplementProjection U *
      Matrix.hadamard (leverageNormalizer U * (1 - normalizedFisher U) *
          (ρ • 1 + normalizedFisher U)⁻¹ * leverageNormalizer U)
        (projectionReflection U) * U) := by
  set Φ := hadamardSandwich U
  have hΓ : ∀ j, Linear.driftGamma U (normalizedNormalPotential U j) =
      Φ (Matrix.vecMulVec (normalizedNormalPotential U j) (normalizedNormalPotential U j)) :=
    fun j => driftGamma_eq_hadamard U _
  have hsum : ∑ j ∈ highNormalizedModes U 0,
      (Smooth.residualWeight ρ (normalizedFisherEigenvalue U j) /
        normalizedFisherEigenvalue U j) • Linear.driftGamma U (normalizedNormalPotential U j) =
      ∑ j, ((1 - normalizedFisherEigenvalue U j) / (ρ + normalizedFisherEigenvalue U j)) •
        Linear.driftGamma U (normalizedNormalPotential U j) := by
    rw [← Finset.sum_subset (Finset.subset_univ (highNormalizedModes U 0))]
    · apply Finset.sum_congr rfl
      intro j hj
      rw [residualWeight_div_eq (Finset.mem_filter.mp hj).2]
    · intro j _ hj
      have hz : normalizedFisherEigenvalue U j = 0 := by
        have hn := normalizedFisherEigenvalue_nonneg U j
        have hh : ¬0 < normalizedFisherEigenvalue U j := by
          simpa only [highNormalizedModes, Finset.mem_filter, Finset.mem_univ, true_and] using hj
        linarith
      rw [driftGamma_eq_zero_of_kernel U j hz, smul_zero]
  unfold Linear.driftMean
  rw [hsum]
  congr 1
  have hY : ∑ j, ((1 - normalizedFisherEigenvalue U j) / (ρ + normalizedFisherEigenvalue U j)) •
      Matrix.vecMulVec (normalizedNormalPotential U j) (normalizedNormalPotential U j) =
      leverageNormalizer U * ((1 - normalizedFisher U) * (ρ • 1 + normalizedFisher U)⁻¹) *
        leverageNormalizer U := by
    rw [← spectral_rational U hρ, Finset.mul_sum, Finset.sum_mul]
    apply Finset.sum_congr rfl
    intro j _
    rw [potential_outer, Matrix.mul_smul, Matrix.smul_mul]
  calc ∑ j, ((1 - normalizedFisherEigenvalue U j) / (ρ + normalizedFisherEigenvalue U j)) •
        Linear.driftGamma U (normalizedNormalPotential U j)
      = ∑ j, Φ (((1 - normalizedFisherEigenvalue U j) / (ρ + normalizedFisherEigenvalue U j)) •
          Matrix.vecMulVec (normalizedNormalPotential U j) (normalizedNormalPotential U j)) := by
        apply Finset.sum_congr rfl; intro j _; rw [hΓ, map_smul]
    _ = Φ (∑ j, ((1 - normalizedFisherEigenvalue U j) / (ρ + normalizedFisherEigenvalue U j)) •
          Matrix.vecMulVec (normalizedNormalPotential U j) (normalizedNormalPotential U j)) :=
        (map_sum Φ _ _).symm
    _ = _ := by
        rw [hY]
        simp only [Φ, hadamardSandwich, LinearMap.coe_mk, AddHom.coe_mk, Matrix.mul_assoc]

end

end Paulsen.Paper.ModerateAux
