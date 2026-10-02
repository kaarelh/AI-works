import Paulsen.TangentSeed
import Mathlib.Analysis.InnerProductSpace.Projection.FiniteDimensional
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.LinearAlgebra.FiniteDimensional.Lemmas

/-!
# The row and global tangent subspaces

Noise is a Euclidean vector indexed by matrix entries. Row tangency and
cancellation of the linear frame-operator perturbation are actual linear
constraints. Adding the global constraint removes at most d² dimensions.
-/

namespace Paulsen

open Matrix Module
open scoped BigOperators

noncomputable section

abbrev FrameVector (n d : ℕ) := EuclideanSpace ℝ (Fin n × Fin d)

def frameOfVector {n d : ℕ} (z : FrameVector n d) : Frame n d :=
  fun i j => z (i, j)

/-- The n rowwise inner products with the input frame. -/
def rowTangentMap {n d : ℕ} (X : Frame n d) : FrameVector n d →ₗ[ℝ] (Fin n → ℝ) where
  toFun z i := ∑ j, X i j * z (i, j)
  map_add' z w := by
    funext i
    simp only [PiLp.add_apply, mul_add, Finset.sum_add_distrib, Pi.add_apply]
  map_smul' a z := by
    funext i
    simp only [PiLp.smul_apply, smul_eq_mul, Pi.smul_apply, mul_left_comm,
      Finset.mul_sum, RingHom.id_apply]

/-- The first derivative of the frame operator in a matrix-entry direction. -/
def globalTangentMap {n d : ℕ} (X : Frame n d) : FrameVector n d →ₗ[ℝ] Frame d d where
  toFun z := X.transpose * frameOfVector z + (frameOfVector z).transpose * X
  map_add' z w := by
    ext j k
    simp only [Matrix.add_apply, Matrix.mul_apply, Matrix.transpose_apply,
      frameOfVector, PiLp.add_apply, mul_add, add_mul, Finset.sum_add_distrib]
    ring
  map_smul' a z := by
    ext j k
    simp only [Matrix.add_apply, Matrix.mul_apply, Matrix.transpose_apply,
      frameOfVector, PiLp.smul_apply, smul_eq_mul, Matrix.smul_apply,
      RingHom.id_apply]
    simp only [mul_left_comm, mul_assoc, mul_add, Finset.mul_sum]

def rowTangentSpace {n d : ℕ} (X : Frame n d) : Submodule ℝ (FrameVector n d) :=
  (rowTangentMap X).ker

def globalTangentSpace {n d : ℕ} (X : Frame n d) : Submodule ℝ (FrameVector n d) :=
  rowTangentSpace X ⊓ (globalTangentMap X).ker

def removedTangentSpace {n d : ℕ} (X : Frame n d) : Submodule ℝ (FrameVector n d) :=
  (globalTangentSpace X)ᗮ ⊓ rowTangentSpace X

theorem mem_rowTangentSpace {n d : ℕ} (X : Frame n d) (z : FrameVector n d) :
    z ∈ rowTangentSpace X ↔ ∀ i, rowDot X (frameOfVector z) i = 0 := by
  change (fun i => ∑ j, X i j * z (i, j)) = 0 ↔ _
  simp only [funext_iff, Pi.zero_apply, rowDot, frameOfVector]

theorem mem_globalTangentSpace {n d : ℕ} (X : Frame n d) (z : FrameVector n d) :
    z ∈ globalTangentSpace X ↔
      (∀ i, rowDot X (frameOfVector z) i = 0) ∧
      X.transpose * frameOfVector z + (frameOfVector z).transpose * X = 0 := by
  change (z ∈ rowTangentSpace X ∧ (globalTangentMap X) z = 0) ↔ _
  rw [mem_rowTangentSpace]
  rfl

theorem globalTangentSpace_le_rowTangentSpace {n d : ℕ} (X : Frame n d) :
    globalTangentSpace X ≤ rowTangentSpace X := inf_le_left

/-- Rank-nullity for the global constraint restricted to the row tangent space. -/
theorem tangent_codimension_le {n d : ℕ} (X : Frame n d) :
    finrank ℝ (rowTangentSpace X) - finrank ℝ (globalTangentSpace X) ≤ d ^ 2 := by
  let f := (globalTangentMap X).comp (rowTangentSpace X).subtype
  have hker : f.ker = (globalTangentSpace X).comap (rowTangentSpace X).subtype := by
    ext z
    change (globalTangentMap X) z.val = 0 ↔
      z.val ∈ rowTangentSpace X ∧ (globalTangentMap X) z.val = 0
    exact ⟨fun h => ⟨z.property, h⟩, fun h => h.2⟩
  have hdim : finrank ℝ f.ker = finrank ℝ (globalTangentSpace X) := by
    rw [hker]
    exact (Submodule.comapSubtypeEquivOfLe (globalTangentSpace_le_rowTangentSpace X)).finrank_eq
  have hrank := f.finrank_range_add_finrank_ker
  rw [hdim] at hrank
  have hrange : finrank ℝ f.range ≤ d ^ 2 := by
    have h := f.range.finrank_le
    simpa only [Frame, finrank_matrix, Fintype.card_fin, finrank_self, mul_one, pow_two] using h
  omega

/-- The discarded directions form an actual subspace of dimension at most d². -/
theorem removedTangentSpace_finrank_le {n d : ℕ} (X : Frame n d) :
    finrank ℝ (removedTangentSpace X) ≤ d ^ 2 := by
  have hdim := Submodule.finrank_add_inf_finrank_orthogonal
    (globalTangentSpace_le_rowTangentSpace X)
  have hb := tangent_codimension_le X
  change finrank ℝ (globalTangentSpace X) + finrank ℝ (removedTangentSpace X) =
    finrank ℝ (rowTangentSpace X) at hdim
  omega

/-- Orthogonal projection supplies both tangent constraints automatically. -/
theorem globalTangentProjection_constraints {n d : ℕ}
    (X : Frame n d) (z : FrameVector n d) :
    (∀ i, rowDot X (frameOfVector ((globalTangentSpace X).starProjection z)) i = 0) ∧
      X.transpose * frameOfVector ((globalTangentSpace X).starProjection z) +
        (frameOfVector ((globalTangentSpace X).starProjection z)).transpose * X = 0 :=
  (mem_globalTangentSpace X _).mp ((globalTangentSpace X).starProjection_apply_mem z)

theorem globalTangentProjection_after_rowProjection {n d : ℕ} (X : Frame n d) :
    (globalTangentSpace X).starProjection.comp (rowTangentSpace X).starProjection =
      (globalTangentSpace X).starProjection :=
  Submodule.starProjection_comp_starProjection_of_le (globalTangentSpace_le_rowTangentSpace X)

theorem rowProjection_after_globalTangentProjection {n d : ℕ} (X : Frame n d) :
    (rowTangentSpace X).starProjection.comp (globalTangentSpace X).starProjection =
      (globalTangentSpace X).starProjection := by
  apply ContinuousLinearMap.ext
  intro z
  exact Submodule.starProjection_eq_self_iff.mpr
    (globalTangentSpace_le_rowTangentSpace X ((globalTangentSpace X).starProjection_apply_mem z))

/-- The difference of the two nested projections is itself the orthogonal
projection onto exactly the discarded tangent directions. -/
theorem removedTangentProjection_eq_sub {n d : ℕ} (X : Frame n d) :
    (removedTangentSpace X).starProjection =
      (rowTangentSpace X).starProjection - (globalTangentSpace X).starProjection := by
  apply ContinuousLinearMap.ext
  intro z
  change (removedTangentSpace X).starProjection z =
    (rowTangentSpace X).starProjection z - (globalTangentSpace X).starProjection z
  have hcomp : (globalTangentSpace X).starProjection ((rowTangentSpace X).starProjection z) =
      (globalTangentSpace X).starProjection z := by
    exact congrArg (fun f : FrameVector n d →L[ℝ] FrameVector n d => f z)
      (globalTangentProjection_after_rowProjection X)
  apply Submodule.eq_starProjection_of_mem_of_inner_eq_zero
  · constructor
    · have h := (globalTangentSpace X).sub_starProjection_mem_orthogonal
        ((rowTangentSpace X).starProjection z)
      rwa [hcomp] at h
    · exact (rowTangentSpace X).sub_mem ((rowTangentSpace X).starProjection_apply_mem z)
        (globalTangentSpace_le_rowTangentSpace X ((globalTangentSpace X).starProjection_apply_mem z))
  · intro y hy
    change y ∈ (globalTangentSpace X)ᗮ ∧ y ∈ rowTangentSpace X at hy
    have hrow := (rowTangentSpace X).starProjection_inner_eq_zero z y hy.2
    have hglobal : inner ℝ ((globalTangentSpace X).starProjection z) y = 0 :=
      hy.1 _ ((globalTangentSpace X).starProjection_apply_mem z)
    change inner ℝ (z - ((rowTangentSpace X).starProjection z -
      (globalTangentSpace X).starProjection z)) y = 0
    rw [show z - ((rowTangentSpace X).starProjection z - (globalTangentSpace X).starProjection z) =
      (z - (rowTangentSpace X).starProjection z) + (globalTangentSpace X).starProjection z by abel,
      inner_add_left, hrow, hglobal, add_zero]

theorem globalTangentProjection_norm_le {n d : ℕ} (X : Frame n d) :
    ‖(globalTangentSpace X).starProjection‖ ≤ 1 :=
  (globalTangentSpace X).starProjection_norm_le

/-- The tangent projection as a concrete matrix on vectorized entries. -/
def globalTangentProjectionMatrix {n d : ℕ} (X : Frame n d) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  Matrix.toEuclideanLin.symm (globalTangentSpace X).starProjection.toLinearMap

theorem globalTangentProjectionMatrix_toEuclideanLin {n d : ℕ} (X : Frame n d) :
    Matrix.toEuclideanLin (globalTangentProjectionMatrix X) =
      (globalTangentSpace X).starProjection.toLinearMap :=
  Matrix.toEuclideanLin.apply_symm_apply _

/-- Multiplying a standard Gaussian by this factor produces covariance
(1/n) times the global tangent projection. -/
def tangentNoiseFactor {n d : ℕ} (X : Frame n d) :
    Matrix (Fin n × Fin d) (Fin n × Fin d) ℝ :=
  (1 / Real.sqrt (n : ℝ)) • globalTangentProjectionMatrix X

theorem tangentNoiseFactor_toContinuousLinearMap {n d : ℕ} (X : Frame n d) :
    (Matrix.toEuclideanLin (tangentNoiseFactor X)).toContinuousLinearMap =
      (1 / Real.sqrt (n : ℝ)) • (globalTangentSpace X).starProjection := by
  apply ContinuousLinearMap.ext
  intro z
  simp only [tangentNoiseFactor, map_smul, globalTangentProjectionMatrix_toEuclideanLin,
    LinearMap.coe_toContinuousLinearMap', FunLike.coe_smul, Pi.smul_apply,
    ContinuousLinearMap.coe_coe]

/-- The exact scaled projection factor satisfies the norm hypothesis used
by the Gaussian quadratic-form variance estimates. -/
theorem tangentNoiseFactor_operator_norm_sq_le {n d : ℕ} (X : Frame n d) (hn : 0 < n) :
    ‖(Matrix.toEuclideanLin (tangentNoiseFactor X)).toContinuousLinearMap‖ ^ 2 ≤
      1 / (n : ℝ) := by
  rw [tangentNoiseFactor_toContinuousLinearMap, norm_smul, Real.norm_eq_abs,
    abs_of_nonneg (by positivity : 0 ≤ 1 / Real.sqrt (n : ℝ)), mul_pow]
  have hproj : ‖(globalTangentSpace X).starProjection‖ ^ 2 ≤ 1 := by
    have h := pow_le_pow_left₀ (norm_nonneg _) (globalTangentProjection_norm_le X) 2
    simpa only [one_pow] using h
  calc
    (1 / Real.sqrt (n : ℝ)) ^ 2 * ‖(globalTangentSpace X).starProjection‖ ^ 2 ≤
        (1 / Real.sqrt (n : ℝ)) ^ 2 := by
      simpa only [mul_one] using mul_le_mul_of_nonneg_left hproj (sq_nonneg _)
    _ = 1 / (n : ℝ) := by rw [div_pow, one_pow, Real.sq_sqrt (Nat.cast_nonneg n)]

/-- Every realization of the projected noise satisfies both exact linear
tangent constraints, before any probabilistic estimates are applied. -/
theorem tangentNoiseFactor_constraints {n d : ℕ} (X : Frame n d) (g : FrameVector n d) :
    (∀ i, rowDot X (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)) i = 0) ∧
      X.transpose * frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g) +
        (frameOfVector (Matrix.toEuclideanLin (tangentNoiseFactor X) g)).transpose * X = 0 := by
  apply (mem_globalTangentSpace X _).mp
  have hid : Matrix.toEuclideanLin (tangentNoiseFactor X) g =
      (1 / Real.sqrt (n : ℝ)) • (globalTangentSpace X).starProjection g := by
    exact congrArg (fun f : FrameVector n d →L[ℝ] FrameVector n d => f g)
      (tangentNoiseFactor_toContinuousLinearMap X)
  rw [hid]
  exact (globalTangentSpace X).smul_mem _ ((globalTangentSpace X).starProjection_apply_mem g)

end

end Paulsen
