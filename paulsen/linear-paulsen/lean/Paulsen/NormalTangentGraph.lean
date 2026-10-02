import Paulsen.NormalBaseGraph
import Paulsen.NormalResidualVariance

/-!
# Normal tangent graph energy through a reflection commutator

The reflection `I-2P` is orthogonal.  Its commutator identity gives the full
normal tangent graph bound directly in ambient coordinates.
-/

open Matrix
open scoped BigOperators

noncomputable section

namespace Paulsen

def diagonalCommutator {n : ℕ} (x : Fin n → ℝ) (P : Matrix (Fin n) (Fin n) ℝ) :
    Matrix (Fin n) (Fin n) ℝ := Matrix.diagonal x * P - P * Matrix.diagonal x

theorem diagonalCommutator_frob_sq {n : ℕ} (x : Fin n → ℝ) (P : Matrix (Fin n) (Fin n) ℝ) :
    ‖normalFrobVector (diagonalCommutator x P)‖^2 =
      2*graphEnergy (Matrix.of fun i j => (P i j)^2) x := by
  simp only [normalFrobVector, EuclideanSpace.real_norm_sq_eq, Fintype.sum_prod_type,
    diagonalCommutator, Matrix.sub_apply, Matrix.diagonal_mul, Matrix.mul_diagonal,
    graphEnergy, Matrix.of_apply]
  have hc : 2*(1/2:ℝ) = 1 := by norm_num
  rw [← mul_assoc, hc, one_mul]
  apply Finset.sum_congr rfl
  intro i _
  apply Finset.sum_congr rfl
  intro j _
  ring

def projectionReflection {n d : ℕ} (U : Frame n d) : Matrix (Fin n) (Fin n) ℝ :=
  1-(2:ℝ) • frameProjection U

theorem projectionReflection_transpose {n d : ℕ} (U : Frame n d) :
    (projectionReflection U).transpose = projectionReflection U := by
  simp only [projectionReflection, Matrix.transpose_sub, Matrix.transpose_one,
    Matrix.transpose_smul, frameProjection_transpose]

theorem projectionReflection_parseval {n d : ℕ} {U : Frame n d} (hU : IsParseval U) :
    IsParseval (projectionReflection U) := by
  change (projectionReflection U).transpose * projectionReflection U = 1
  rw [projectionReflection_transpose]
  simp only [projectionReflection, Matrix.sub_mul, Matrix.mul_sub, Matrix.one_mul,
    Matrix.mul_one, Matrix.smul_mul, Matrix.mul_smul,
    hU.frameProjection_idempotent]
  module

theorem normalFrobVector_parseval_mul_norm {n d : ℕ} {R : Frame n n}
    (hR : IsParseval R) (H : Frame n d) :
    ‖normalFrobVector (R*H)‖ = ‖normalFrobVector H‖ := by
  rw [← normalFrobVector_transpose_norm (R*H), Matrix.transpose_mul,
    normalFrobVector_mul_parseval_transpose_norm hR, normalFrobVector_transpose_norm]

def ambientNormalTangent {n d : ℕ} (U : Frame n d) (f : Fin n → ℝ) : Frame n n :=
  ambientNormal U f * U.transpose + U * (ambientNormal U f).transpose

theorem ambientNormalTangent_eq {n d : ℕ} (U : Frame n d) (f : Fin n → ℝ) :
    ambientNormalTangent U f = Matrix.diagonal f * frameProjection U +
      frameProjection U * Matrix.diagonal f - (2:ℝ) •
        (frameProjection U * Matrix.diagonal f * frameProjection U) := by
  unfold ambientNormalTangent ambientNormal
  simp only [Matrix.transpose_mul, Matrix.diagonal_transpose,
    frameComplementProjection_transpose]
  simp only [frameComplementProjection, Matrix.sub_mul, Matrix.mul_sub, Matrix.one_mul,
    Matrix.mul_one, Matrix.mul_assoc, frameProjection]
  module

/-- Commuting diagonal operators turn the tangent commutator into two terms
containing the original projection commutator and an orthogonal reflection. -/
theorem ambientNormalTangent_commutator {n d : ℕ} (U : Frame n d)
    (x f : Fin n → ℝ) :
    diagonalCommutator x (ambientNormalTangent U f) =
      projectionReflection U * Matrix.diagonal f * diagonalCommutator x (frameProjection U) +
        diagonalCommutator x (frameProjection U) * Matrix.diagonal f * projectionReflection U := by
  have hdf : Matrix.diagonal x * Matrix.diagonal f = Matrix.diagonal f * Matrix.diagonal x := by
    simp only [Matrix.diagonal_mul_diagonal, mul_comm]
  rw [ambientNormalTangent_eq]
  simp only [diagonalCommutator, projectionReflection, Matrix.mul_sub, Matrix.sub_mul,
    Matrix.mul_add, Matrix.add_mul, Matrix.mul_smul, Matrix.smul_mul, Matrix.one_mul,
    Matrix.mul_one]
  have h₁ : Matrix.diagonal x * (Matrix.diagonal f * frameProjection U) =
      Matrix.diagonal f * (Matrix.diagonal x * frameProjection U) := by
    rw [← Matrix.mul_assoc, hdf, Matrix.mul_assoc]
  have h₂ : frameProjection U * Matrix.diagonal x * Matrix.diagonal f =
      frameProjection U * Matrix.diagonal f * Matrix.diagonal x := by
    rw [Matrix.mul_assoc, hdf, ← Matrix.mul_assoc]
  simp only [Matrix.mul_assoc] at h₂ ⊢
  rw [h₁, h₂]
  module

theorem ambientNormalTangent_commutator_norm_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (x f : Fin n → ℝ) {M : ℝ} (hM : 0 ≤ M)
    (hf : ∀ i, |f i|≤M) :
    ‖normalFrobVector (diagonalCommutator x (ambientNormalTangent U f))‖ ≤
      2*M*‖normalFrobVector (diagonalCommutator x (frameProjection U))‖ := by
  rw [ambientNormalTangent_commutator, normalFrobVector_add]
  let K := diagonalCommutator x (frameProjection U)
  have hR := projectionReflection_parseval hU
  calc
    _ ≤ ‖normalFrobVector (projectionReflection U * Matrix.diagonal f * K)‖ +
        ‖normalFrobVector (K * Matrix.diagonal f * projectionReflection U)‖ := norm_add_le _ _
    _ = ‖normalFrobVector (Matrix.diagonal f * K)‖ + ‖normalFrobVector (K * Matrix.diagonal f)‖ := by
      rw [Matrix.mul_assoc, normalFrobVector_parseval_mul_norm hR]
      rw [← projectionReflection_transpose U, normalFrobVector_mul_parseval_transpose_norm hR]
    _ ≤ M*‖normalFrobVector K‖+M*‖normalFrobVector K‖ :=
      add_le_add (normalFrobVector_diagonal_mul_norm_le K f hM hf)
        (normalFrobVector_mul_diagonal_norm_le K f hM hf)
    _ = _ := by ring

theorem ambientNormalTangent_graphEnergy_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (x f : Fin n → ℝ) {M : ℝ} (hM : 0≤M)
    (hf : ∀ i, |f i|≤M) :
    graphEnergy (Matrix.of fun i j => (ambientNormalTangent U f i j)^2) x ≤
      4*M^2*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hh := pow_le_pow_left₀ (norm_nonneg _)
    (ambientNormalTangent_commutator_norm_le hU x f hM hf) 2
  rw [mul_pow, mul_pow, diagonalCommutator_frob_sq,
    diagonalCommutator_frob_sq] at hh
  have he : graphEnergy (Matrix.of fun i j => (frameProjection U i j)^2) x =
      matrixQuadratic (projectionLaplacian (frameProjection U)) x := (hU.laplacian_energy x).symm
  rw [he] at hh
  nlinarith only [hh]


theorem normalTangentFrame_eq_ambient {n d : ℕ} (U : Frame n d) (j : Fin n) :
    normalTangentFrame U j = (Real.sqrt (normalizedFisherEigenvalue U j))⁻¹ •
      ambientNormalTangent U (normalizedNormalPotential U j) := by
  simp only [normalTangentFrame, normalizedNormalFrame_eq, Matrix.smul_mul,
    Matrix.transpose_smul, Matrix.mul_smul, ambientNormalTangent, smul_add]

theorem graphEnergy_entry_square_smul {n : ℕ} (Y : Frame n n) (c : ℝ) (x : Fin n → ℝ) :
    graphEnergy (Matrix.of fun i j => ((c • Y) i j)^2) x =
      c^2*graphEnergy (Matrix.of fun i j => (Y i j)^2) x := by
  simp only [graphEnergy, Matrix.of_apply, Matrix.smul_apply, smul_eq_mul, mul_pow,
    mul_assoc, ← Finset.mul_sum]
  ring

theorem normalTangentFrame_graphEnergy_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (j : Fin n) (hj : 0 < normalizedFisherEigenvalue U j)
    (x : Fin n → ℝ) {M : ℝ} (hM : 0≤M)
    (hf : ∀ i, |normalizedNormalPotential U j i|≤M) :
    graphEnergy (Matrix.of fun i k => (normalTangentFrame U j i k)^2) x ≤
      (4*M^2/normalizedFisherEigenvalue U j)*
        matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  rw [normalTangentFrame_eq_ambient, graphEnergy_entry_square_smul, inv_pow,
    Real.sq_sqrt hj.le]
  have hh := mul_le_mul_of_nonneg_left
    (ambientNormalTangent_graphEnergy_le hU x (normalizedNormalPotential U j) hM hf)
    (inv_nonneg.mpr hj.le)
  apply hh.trans_eq
  ring

theorem graphEnergy_finset_sum_eq {n : ℕ} {ι : Type*} (s : Finset ι)
    (Y : ι → Frame n n) (x : Fin n → ℝ) :
    graphEnergy (∑ j ∈ s, Y j) x = ∑ j ∈ s, graphEnergy (Y j) x := by
  classical
  induction s using Finset.induction_on with
  | empty => simp [graphEnergy]
  | @insert j s hj ih =>
    rw [Finset.sum_insert hj, Finset.sum_insert hj, graphEnergy_add_eq, ih]

theorem positiveResidualEntryLoss_graphEnergy_eq {n d : ℕ} (U : Frame n d)
    (ρ : ℝ) (x : Fin n → ℝ) :
    graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x = (1/(n:ℝ))*
      ∑ j ∈ highNormalizedModes U ρ, (1-normalizedFisherEigenvalue U j)*
        graphEnergy (Matrix.of fun i k => (normalTangentFrame U j i k)^2) x := by
  have he : Matrix.of (positiveResidualEntryLoss U ρ) = (1/(n:ℝ)) •
      ∑ j ∈ highNormalizedModes U ρ, (1-normalizedFisherEigenvalue U j) •
        Matrix.of (fun i k => (normalTangentFrame U j i k)^2) := by
    ext i k
    simp only [Matrix.of_apply, positiveResidualEntryLoss_formula, Matrix.smul_apply,
      Matrix.sum_apply, smul_eq_mul]
  rw [he, graphEnergy_smul_eq, graphEnergy_finset_sum_eq]
  simp only [graphEnergy_smul_eq]

/-- Spectral trace weights bound the positive graph loss in the original
projection Laplacian metric. -/
theorem positiveResidualEntryLoss_graphEnergy_le {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) {p ρ : ℝ} (hp : 0<p) (hrows : ∀ i, p≤rowNormSq U i)
    (hρ : 0<ρ) (x : Fin n → ℝ) :
    graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x ≤
      (4*(d:ℝ)/((n:ℝ)*p*ρ))*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  let L := matrixQuadratic (projectionLaplacian (frameProjection U)) x
  have hL : 0≤L := by dsimp only [L]; rw [← ambientNormal_norm_sq hU]; positivity
  have hpos (i : Fin n) : 0<rowNormSq U i := hp.trans_le (hrows i)
  have hmode (j : Fin n) (hj : j ∈ highNormalizedModes U ρ) :
      graphEnergy (Matrix.of fun i k => (normalTangentFrame U j i k)^2) x ≤ (4/(p*ρ))*L := by
    have hμ := (Finset.mem_filter.mp hj).2
    have hb := normalTangentFrame_graphEnergy_le hU j (hρ.trans hμ) x
      (inv_nonneg.mpr (Real.sqrt_nonneg p))
      (fun i => normalizedNormalPotential_abs_le U j i hp (hrows i))
    rw [inv_pow, Real.sq_sqrt hp.le] at hb
    calc
      _ ≤ (4*p⁻¹/normalizedFisherEigenvalue U j)*L := hb
      _ ≤ (4*p⁻¹/ρ)*L := mul_le_mul_of_nonneg_right
        (div_le_div_of_nonneg_left (by positivity) hρ hμ.le) hL
      _ = _ := by ring
  rw [positiveResidualEntryLoss_graphEnergy_eq]
  calc
    _ ≤ (1/(n:ℝ))* ∑ j ∈ highNormalizedModes U ρ,
        (1-normalizedFisherEigenvalue U j)*((4/(p*ρ))*L) := by
      apply mul_le_mul_of_nonneg_left _ (by positivity)
      exact Finset.sum_le_sum fun j hj => mul_le_mul_of_nonneg_left (hmode j hj)
        (sub_nonneg.mpr (normalizedFisherEigenvalue_le_one hU hpos j))
    _ = (1/(n:ℝ))*normalizedPositiveResidualMass U ρ*((4/(p*ρ))*L) := by
      rw [normalizedPositiveResidualMass, ← Finset.sum_mul]
      ring
    _ ≤ (1/(n:ℝ))*(d:ℝ)*((4/(p*ρ))*L) := by
      apply mul_le_mul_of_nonneg_right _ (by positivity)
      exact mul_le_mul_of_nonneg_left (normalizedPositiveResidualMass_le hU hpos ρ) (by positivity)
    _ = _ := by ring

theorem positiveResidualEntryLoss_graphEnergy_le_average {n d : ℕ} {U : Frame n d}
    (hU : IsParseval U) (hn : 0<n) (hd : 0<d)
    (hrows : ∀ i, (d:ℝ)/(2*(n:ℝ))≤rowNormSq U i) {ρ : ℝ} (hρ : 0<ρ) (x : Fin n → ℝ) :
    graphEnergy (Matrix.of (positiveResidualEntryLoss U ρ)) x ≤
      (8/ρ)*matrixQuadratic (projectionLaplacian (frameProjection U)) x := by
  have hn' : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hd' : (0:ℝ)<d := Nat.cast_pos.mpr hd
  have hh := positiveResidualEntryLoss_graphEnergy_le hU
    (show (0:ℝ)<(d:ℝ)/(2*(n:ℝ)) by positivity) hrows hρ x
  have he : 4*(d:ℝ)/((n:ℝ)*((d:ℝ)/(2*(n:ℝ)))*ρ) = 8/ρ := by
    field_simp
    norm_num
  rwa [he] at hh

end Paulsen
