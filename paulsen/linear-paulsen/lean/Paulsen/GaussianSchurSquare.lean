import Paulsen.HadamardGaussianVariance
import Paulsen.GaussianMaximumEnergy
import Paulsen.GaussianTangentCoupling
import Paulsen.GaussianRotationConcentration
import Mathlib.MeasureTheory.SpecificCodomains.Pi

/-!
# Gaussian squared-entry matrices: symmetrization and polarization

All random matrices are actual deterministic images of standard Gaussians.
Integrability is supplied internally before symmetrization and rotation.
-/

namespace Paulsen
open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators ProbabilityTheory Matrix.Norms.Elementwise
noncomputable section

local instance {n : ℕ} : ContinuousENorm (Matrix (Fin n) (Fin n) ℝ) :=
  inferInstanceAs (ContinuousENorm (Fin n → Fin n → ℝ))

/-- The matrix-to-Euclidean-operator identification, bundled continuously. -/
def matrixEuclideanOperator {n : ℕ} : Matrix (Fin n) (Fin n) ℝ →L[ℝ]
    (EuclideanSpace ℝ (Fin n) →L[ℝ] EuclideanSpace ℝ (Fin n)) :=
  ((Matrix.toEuclideanLin (𝕜 := ℝ)).trans LinearMap.toContinuousLinearMap).toContinuousLinearMap

@[simp] theorem matrixEuclideanOperator_apply {n : ℕ} (A : Matrix (Fin n) (Fin n) ℝ) :
    matrixEuclideanOperator A = (Matrix.toEuclideanLin A).toContinuousLinearMap := rfl

/-- Bochner symmetrization in a normed space, with all integrability explicit. -/
theorem integral_norm_centered_le_pair {α F : Type*} [MeasurableSpace α]
    [NormedAddCommGroup F] [NormedSpace ℝ F] [CompleteSpace F]
    (μ : Measure α) [IsProbabilityMeasure μ] (f : α → F) (hf : Integrable f μ) :
    (∫ x, ‖f x - ∫ y, f y ∂μ‖ ∂μ) ≤
      ∫ z : α × α, ‖f z.1 - f z.2‖ ∂μ.prod μ := by
  have hp : Integrable (fun z : α × α => ‖f z.1 - f z.2‖) (μ.prod μ) :=
    ((hf.comp_fst μ).sub (hf.comp_snd μ)).norm
  rw [integral_prod _ hp]
  apply integral_mono ((hf.sub (integrable_const _)).norm) hp.integral_prod_left
  intro x
  have he : (∫ y, f x - f y ∂μ) = f x - ∫ y, f y ∂μ := by
    rw [integral_sub (integrable_const _) hf]
    simp
  change ‖f x - ∫ y, f y ∂μ‖ ≤ ∫ y, ‖f x - f y‖ ∂μ
  rw [← he]
  exact norm_integral_le_integral_norm _

variable {κ : Type*} [Fintype κ] [DecidableEq κ]

def gaussianMatrixImage {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ)
    (g : EuclideanSpace ℝ κ) : Matrix (Fin n) (Fin n) ℝ :=
  frameOfVector (Matrix.toEuclideanLin C g)

def gaussianSchurSquare {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ)
    (g : EuclideanSpace ℝ κ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => (gaussianMatrixImage C g i j) ^ 2

def gaussianSchurProduct {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ)
    (g h : EuclideanSpace ℝ κ) : Matrix (Fin n) (Fin n) ℝ :=
  Matrix.of fun i j => gaussianMatrixImage C g i j * gaussianMatrixImage C h i j

theorem integrable_gaussianSchurSquare {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ) :
    Integrable (gaussianSchurSquare C) (stdGaussian (EuclideanSpace ℝ κ)) := by
  apply Integrable.of_eval
  intro i
  apply Integrable.of_eval
  intro j
  exact (memLp_sq_gaussianCoordinate C (i,j)).integrable (by norm_num)

theorem integrable_gaussianSchurProduct {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ) :
    Integrable (fun z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ => gaussianSchurProduct C z.1 z.2)
      ((stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ))) := by
  apply Integrable.of_eval
  intro i
  apply Integrable.of_eval
  intro j
  have hi : Integrable (gaussianCoordinate C (i,j)) (stdGaussian (EuclideanSpace ℝ κ)) :=
    (gaussianCoordinate C (i,j)).integrable_comp IsGaussian.integrable_id
  exact hi.mul_prod hi

theorem integrable_gaussianSchurProduct_operator_norm {n : ℕ}
    (C : Matrix (Fin n × Fin n) κ ℝ) :
    Integrable (fun z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ =>
      ‖matrixEuclideanOperator (gaussianSchurProduct C z.1 z.2)‖)
      ((stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ))) :=
  (matrixEuclideanOperator.integrable_comp (integrable_gaussianSchurProduct C)).norm

/-- Exact 45-degree polarization identity, entry by entry. -/
theorem gaussianSchurSquare_quarterRotation {n : ℕ} (C : Matrix (Fin n × Fin n) κ ℝ)
    (z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ) :
    gaussianSchurSquare C (quarterRotation (1 / 2) z).1 -
      gaussianSchurSquare C (quarterRotation (1 / 2) z).2 =
        (2 : ℝ) • gaussianSchurProduct C z.1 z.2 := by
  have ha : Real.pi / 2 * (1 / 2 : ℝ) = Real.pi / 4 := by ring
  ext i j
  simp only [gaussianSchurSquare, gaussianSchurProduct, gaussianMatrixImage, frameOfVector,
    Matrix.of_apply, Matrix.sub_apply, Matrix.smul_apply, smul_eq_mul,
    quarterRotation, ContinuousLinearMap.rotation_apply, ha,
    Real.cos_pi_div_four, Real.sin_pi_div_four, map_add, map_smul,
    PiLp.add_apply, PiLp.smul_apply, smul_eq_mul]
  nlinarith [Real.sq_sqrt (by norm_num : (0 : ℝ) ≤ 2)]

/-- Rotation replaces the difference of two Gaussian squares by twice their
independent entrywise product, preserving the actual product Gaussian measure. -/
theorem integral_gaussianSchurSquare_difference {n : ℕ}
    (C : Matrix (Fin n × Fin n) κ ℝ) :
    (∫ z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ,
      ‖matrixEuclideanOperator (gaussianSchurSquare C z.1 - gaussianSchurSquare C z.2)‖
      ∂((stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ)))) =
      2 * ∫ z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ,
        ‖matrixEuclideanOperator (gaussianSchurProduct C z.1 z.2)‖
        ∂((stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ))) := by
  have hf := ((integrable_gaussianSchurSquare C).comp_fst (stdGaussian (EuclideanSpace ℝ κ))).sub
    ((integrable_gaussianSchurSquare C).comp_snd (stdGaussian (EuclideanSpace ℝ κ)))
  have hi : Integrable (fun z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ =>
      ‖matrixEuclideanOperator (gaussianSchurSquare C z.1 - gaussianSchurSquare C z.2)‖)
      ((stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ))) :=
    (matrixEuclideanOperator.integrable_comp hf).norm
  have hmp := measurePreserving_quarterRotation (E := EuclideanSpace ℝ κ) (1 / 2)
  have hrot := integral_map (μ := (stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ)))
    hmp.measurable.aemeasurable (by rw [hmp.map_eq]; exact hi.aestronglyMeasurable)
  rw [hmp.map_eq] at hrot
  rw [hrot]
  simp only [gaussianSchurSquare_quarterRotation, map_smul, norm_smul,
    Real.norm_ofNat, integral_const_mul]

/-- Symmetrization and rotation for the actual centered Schur square. -/
theorem integral_gaussianSchurSquare_centered_le {n : ℕ}
    (C : Matrix (Fin n × Fin n) κ ℝ) :
    (∫ g, ‖matrixEuclideanOperator
      (gaussianSchurSquare C g - ∫ h, gaussianSchurSquare C h ∂stdGaussian (EuclideanSpace ℝ κ))‖
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      2 * ∫ z : EuclideanSpace ℝ κ × EuclideanSpace ℝ κ,
        ‖matrixEuclideanOperator (gaussianSchurProduct C z.1 z.2)‖
        ∂((stdGaussian (EuclideanSpace ℝ κ)).prod (stdGaussian (EuclideanSpace ℝ κ))) := by
  have h := integral_norm_centered_le_pair (stdGaussian (EuclideanSpace ℝ κ))
    (fun g => matrixEuclideanOperator (gaussianSchurSquare C g))
    (matrixEuclideanOperator.integrable_comp (integrable_gaussianSchurSquare C))
  have hmean : (∫ y, matrixEuclideanOperator (gaussianSchurSquare C y)
      ∂stdGaussian (EuclideanSpace ℝ κ)) =
      matrixEuclideanOperator (∫ y, gaussianSchurSquare C y ∂stdGaussian (EuclideanSpace ℝ κ)) := by
    exact matrixEuclideanOperator.integral_comp_comm (integrable_gaussianSchurSquare C)
  rw [hmean] at h
  simp only [← map_sub] at h
  exact h.trans_eq (integral_gaussianSchurSquare_difference C)

/-- Each entry of the actual Gaussian square mean is the corresponding coefficient energy. -/
theorem gaussianSchurSquare_integral_entry {n : ℕ}
    (C : Matrix (Fin n × Fin n) κ ℝ) (i j : Fin n) :
    (∫ g, gaussianSchurSquare C g ∂stdGaussian (EuclideanSpace ℝ κ)) i j =
      ∑ s, C (i,j) s ^ 2 := by
  have hi : (∫ g, gaussianSchurSquare C g ∂stdGaussian (EuclideanSpace ℝ κ)) i =
      ∫ g, gaussianSchurSquare C g i ∂stdGaussian (EuclideanSpace ℝ κ) := by
    exact eval_integral (fun r => (integrable_gaussianSchurSquare C).eval r) i
  have hj : (∫ g, gaussianSchurSquare C g i ∂stdGaussian (EuclideanSpace ℝ κ)) j =
      ∫ g, gaussianSchurSquare C g i j ∂stdGaussian (EuclideanSpace ℝ κ) := by
    exact eval_integral (fun k => ((integrable_gaussianSchurSquare C).eval i).eval k) j
  rw [hi, hj]
  let D : Matrix Unit κ ℝ := Matrix.of fun _ s => C (i,j) s
  have he (g : EuclideanSpace ℝ κ) : gaussianSchurSquare C g i j =
      ‖Matrix.toEuclideanLin D g‖ ^ 2 := by
    simp only [EuclideanSpace.real_norm_sq_eq, gaussianSchurSquare, gaussianMatrixImage,
      frameOfVector, Matrix.of_apply, Matrix.toLpLin_apply, D, Matrix.mulVec, dotProduct]
    simp
  simp_rw [he]
  simpa only [D, Matrix.of_apply, Fintype.sum_unique] using integral_norm_sq_gaussianImage D

end
end Paulsen
