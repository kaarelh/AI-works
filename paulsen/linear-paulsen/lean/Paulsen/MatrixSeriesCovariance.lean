import Paulsen.GaussianMatrixTail
import Paulsen.GaussianTangentCoupling

/-! Covariance domination for correlated symmetric Gaussian matrix series. -/

open Matrix MeasureTheory ProbabilityTheory
open scoped BigOperators
noncomputable section
namespace Paulsen

variable {ι κ ν : Type*} [Fintype ι] [DecidableEq ι] [Fintype κ] [DecidableEq κ]
  [Fintype ν] [DecidableEq ν]

def correlatedMatrixCoefficient (A : ι → Matrix ν ν ℝ) (C : Matrix ι κ ℝ)
    (s : κ) : Matrix ν ν ℝ := ∑ i, C i s • A i

omit [DecidableEq ι] [Fintype κ] [DecidableEq κ] [Fintype ν] [DecidableEq ν] in
theorem correlatedMatrixCoefficient_isHermitian (A : ι → Matrix ν ν ℝ)
    (hA : ∀ i, (A i).IsHermitian) (C : Matrix ι κ ℝ) (s : κ) :
    (correlatedMatrixCoefficient A C s).IsHermitian := by
  unfold Matrix.IsHermitian correlatedMatrixCoefficient
  simp only [Matrix.conjTranspose_sum, Matrix.conjTranspose_smul, star_trivial, (hA _).eq]

theorem euclideanQuadratic_square_eq_norm_sq (A : Matrix ν ν ℝ) (hA : A.IsHermitian)
    (x : EuclideanSpace ℝ ν) :
    euclideanQuadratic (A^2) x = ‖Matrix.toEuclideanLin A x‖^2 := by
  rw [norm_sq_gaussianImage_eq_quadratic]
  have ht : A.transpose=A := by
    simpa only [Matrix.conjTranspose_eq_transpose_of_trivial] using hA.eq
  rw [ht, pow_two]

omit [DecidableEq ι] in
theorem euclideanQuadratic_fintype_sum (A : ι → Matrix ν ν ℝ) (x : EuclideanSpace ℝ ν) :
    euclideanQuadratic (∑ i, A i) x = ∑ i, euclideanQuadratic (A i) x := by
  simp only [euclideanQuadratic, map_sum, LinearMap.sum_apply, inner_sum]

theorem correlatedMatrixCoefficient_energy_le (A : ι → Matrix ν ν ℝ)
    (C : Matrix ι κ ℝ) {v : ℝ}
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖^2≤v)
    (x : EuclideanSpace ℝ ν) :
    (∑ s, ‖Matrix.toEuclideanLin (correlatedMatrixCoefficient A C s) x‖^2) ≤
      v * ∑ i, ‖Matrix.toEuclideanLin (A i) x‖^2 := by
  let D : Matrix ν ι ℝ := Matrix.of fun r i => Matrix.toEuclideanLin (A i) x r
  have he (r : ν) (s : κ) : (D*C) r s =
      Matrix.toEuclideanLin (correlatedMatrixCoefficient A C s) x r := by
    simp only [D, Matrix.mul_apply, Matrix.of_apply, correlatedMatrixCoefficient,
      map_sum, map_smul, LinearMap.sum_apply, LinearMap.smul_apply, WithLp.ofLp_sum, Finset.sum_apply,
      PiLp.smul_apply, smul_eq_mul]
    apply Finset.sum_congr rfl
    intro i _
    ring
  have hh := entry_sq_sum_mul_le_right D C
  have hb := mul_le_mul_of_nonneg_right hC (show 0≤∑ r, ∑ i, D r i^2 by positivity)
  have hc := hh.trans hb
  simp only [he, D, Matrix.of_apply] at hc
  rw [Finset.sum_comm, Finset.sum_comm (f := fun r i =>
    (Matrix.toEuclideanLin (A i) x r)^2)] at hc
  simpa only [← EuclideanSpace.real_norm_sq_eq] using hc

/-- Correlation in the scalar Gaussian coordinates costs at most the covariance
operator bound, with no independence assumption on the output coordinates. -/
theorem correlatedMatrixCoefficient_variance_le (A : ι → Matrix ν ν ℝ)
    (hA : ∀ i, (A i).IsHermitian) (C : Matrix ι κ ℝ) {v : ℝ}
    (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖^2≤v) :
    (v • (∑ i, (A i)^2) - ∑ s, (correlatedMatrixCoefficient A C s)^2).PosSemidef := by
  have hB := correlatedMatrixCoefficient_isHermitian A hA C
  rw [Matrix.posSemidef_iff_dotProduct_mulVec]
  refine ⟨?_, ?_⟩
  · unfold Matrix.IsHermitian
    simp only [Matrix.conjTranspose_sub, Matrix.conjTranspose_smul, star_trivial,
      Matrix.conjTranspose_sum, Matrix.conjTranspose_pow, (hA _).eq, (hB _).eq]
  · intro x
    have hh := correlatedMatrixCoefficient_energy_le A C hC (WithLp.toLp 2 x)
    have he : euclideanQuadratic
        (v • (∑ i, (A i)^2) - ∑ s, (correlatedMatrixCoefficient A C s)^2)
        (WithLp.toLp 2 x) =
        v*(∑ i, ‖Matrix.toEuclideanLin (A i) (WithLp.toLp 2 x)‖^2) -
          ∑ s, ‖Matrix.toEuclideanLin (correlatedMatrixCoefficient A C s) (WithLp.toLp 2 x)‖^2 := by
      simp only [euclideanQuadratic, map_sub, map_smul, LinearMap.sub_apply,
        LinearMap.smul_apply, inner_sub_right, real_inner_smul_right]
      change v*euclideanQuadratic (∑ i, (A i)^2) _ -
        euclideanQuadratic (∑ s, (correlatedMatrixCoefficient A C s)^2) _ = _
      simp only [euclideanQuadratic_fintype_sum, euclideanQuadratic_square_eq_norm_sq _ (hA _),
        euclideanQuadratic_square_eq_norm_sq _ (hB _)]
    have hn : 0≤euclideanQuadratic
        (v • (∑ i, (A i)^2) - ∑ s, (correlatedMatrixCoefficient A C s)^2)
        (WithLp.toLp 2 x) := by rw [he]; linarith
    simpa only [euclideanQuadratic, PiLp.inner_apply, Real.inner_apply, Matrix.toLpLin_apply,
      Matrix.mulVec, dotProduct, star_trivial, mul_comm] using hn

/-- A scalar variance bound composes with covariance domination. -/
theorem correlatedMatrixCoefficient_scalar_variance_le (A : ι → Matrix ν ν ℝ)
    (hA : ∀ i, (A i).IsHermitian) (C : Matrix ι κ ℝ) {v w : ℝ}
    (hv : 0≤v) (hC : ‖(Matrix.toEuclideanLin C).toContinuousLinearMap‖^2≤v)
    (hAvar : (w • (1 : Matrix ν ν ℝ) - ∑ i, (A i)^2).PosSemidef) :
    ((v*w) • (1 : Matrix ν ν ℝ) -
      ∑ s, (correlatedMatrixCoefficient A C s)^2).PosSemidef := by
  have hh := (hAvar.smul hv).add (correlatedMatrixCoefficient_variance_le A hA C hC)
  convert hh using 1
  module

omit [DecidableEq ι] [DecidableEq κ] [Fintype ν] [DecidableEq ν] in
/-- The coefficients represent the actual linear image of the Gaussian input. -/
theorem correlatedMatrixCoefficient_series (A : ι → Matrix ν ν ℝ)
    (C : Matrix ι κ ℝ) (g : κ → ℝ) :
    gaussianMatrixSeries (correlatedMatrixCoefficient A C) g =
      gaussianMatrixSeries A (C *ᵥ g) := by
  unfold gaussianMatrixSeries correlatedMatrixCoefficient
  simp only [Finset.smul_sum, smul_smul, Matrix.mulVec, dotProduct, Finset.sum_smul]
  rw [Finset.sum_comm]
  simp only [mul_comm]

/-- The Gaussian matrix-series tail on Euclidean standard Gaussian space. -/
theorem stdGaussian_matrixSeries_operator_norm_tail
    (A : κ → Matrix ν ν ℝ) (hA : ∀ s, (A s).IsHermitian)
    (v : ℝ) (hv : 0≤v)
    (hvar : (v • (1 : Matrix ν ν ℝ) - ∑ s, (A s)^2).PosSemidef)
    (p : ℕ) (hp : 0<p) (u : ℝ) (hu : 0<u) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
      {g | u ≤ ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A (fun s => g s))).toContinuousLinearMap‖} ≤
      (Fintype.card ν : ℝ)*(2*(p:ℝ)*v)^p/u^(2*p) := by
  have hm : MeasurableSet {g : EuclideanSpace ℝ κ |
      u ≤ ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A (fun s => g s))).toContinuousLinearMap‖} :=
    (isClosed_le continuous_const
      ((continuous_gaussianMatrixSeries_operator_norm A).comp (by fun_prop))).measurableSet
  rw [← map_pi_eq_stdGaussian, Measure.real, Measure.map_apply (by fun_prop) hm]
  exact gaussianMatrixSeries_operator_norm_tail A hA v hv hvar p hp u hu

/-- The logarithmic expected-norm estimate on standard Euclidean Gaussian space. -/
theorem stdGaussian_matrixSeries_expected_operator_norm_le [Nonempty ν]
    (A : κ → Matrix ν ν ℝ) (hA : ∀ s, (A s).IsHermitian)
    (v : ℝ) (hv : 0<v)
    (hvar : (v • (1 : Matrix ν ν ℝ) - ∑ s, (A s)^2).PosSemidef) :
    (∫ g : EuclideanSpace ℝ κ,
      ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A (fun s => g s))).toContinuousLinearMap‖
      ∂stdGaussian (EuclideanSpace ℝ κ)) ≤
      2*Real.sqrt (2*Real.exp 1*v*(Real.log (Fintype.card ν : ℝ)+2)) := by
  have hc : Continuous (fun g : EuclideanSpace ℝ κ =>
      ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A (fun s => g s))).toContinuousLinearMap‖) :=
    (continuous_gaussianMatrixSeries_operator_norm A).comp (by fun_prop)
  rw [← map_pi_eq_stdGaussian, integral_map (by fun_prop) hc.aestronglyMeasurable]
  exact gaussianMatrixSeries_expected_operator_norm_log_bound A hA v hv hvar

/-- Exponential tail on Euclidean Gaussian space. -/
theorem stdGaussian_matrixSeries_operator_norm_tail_exp
    (A : κ → Matrix ν ν ℝ) (hA : ∀ s, (A s).IsHermitian)
    (v : ℝ) (hv : 0≤v)
    (hvar : (v • (1 : Matrix ν ν ℝ) - ∑ s, (A s)^2).PosSemidef)
    (p : ℕ) (hp : 0<p) (u : ℝ) (hu : 0<u)
    (hu2 : 2*Real.exp 1*(p:ℝ)*v≤u^2) :
    (stdGaussian (EuclideanSpace ℝ κ)).real
      {g | u ≤ ‖(Matrix.toEuclideanLin (gaussianMatrixSeries A (fun s => g s))).toContinuousLinearMap‖} ≤
      (Fintype.card ν : ℝ)*Real.exp (-(p:ℝ)) := by
  refine (stdGaussian_matrixSeries_operator_norm_tail A hA v hv hvar p hp u hu).trans ?_
  rw [mul_div_assoc]
  exact mul_le_mul_of_nonneg_left (gaussian_matrix_moment_ratio_le_exp p v u hv hu hu2)
    (Nat.cast_nonneg _)

end Paulsen
