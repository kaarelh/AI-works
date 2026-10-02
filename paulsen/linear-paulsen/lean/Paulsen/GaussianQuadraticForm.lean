import Paulsen.Graph
import Paulsen.GaussianQuadraticTail
import Mathlib.Analysis.Matrix.Spectrum
import Mathlib.Probability.Distributions.Gaussian.Multivariate

/-!
# General symmetric Gaussian quadratic forms

The spectral theorem and the basis-independent standard Gaussian law turn the
proved diagonal quadratic-form estimates into estimates for symmetric matrices.
-/

open MeasureTheory ProbabilityTheory WithLp Unitary
open scoped BigOperators ProbabilityTheory NNReal

noncomputable section

namespace Paulsen

variable {ι : Type*} [Fintype ι] [DecidableEq ι]

/-- The quadratic form of a real matrix on Euclidean space. -/
def euclideanQuadratic (A : Matrix ι ι ℝ) (x : EuclideanSpace ℝ ι) : ℝ :=
  inner ℝ x (Matrix.toEuclideanLin A x)

theorem euclideanQuadratic_eq_matrixQuadratic (A : Matrix ι ι ℝ)
    (x : EuclideanSpace ℝ ι) :
    euclideanQuadratic A x = matrixQuadratic A (fun i => x i) := by
  simp [euclideanQuadratic, EuclideanSpace.inner_eq_star_dotProduct,
    Matrix.toLpLin_apply, Matrix.mulVec, dotProduct, matrixQuadratic,
    Finset.sum_mul, mul_assoc]
  apply Finset.sum_congr rfl
  intro i hi
  apply Finset.sum_congr rfl
  intro j hj
  ring

/-- The matrix eigenbasis consists of eigenvectors of its Euclidean linear map. -/
theorem toEuclideanLin_eigenvector (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (i : ι) :
    Matrix.toEuclideanLin A (hA.eigenvectorBasis i) =
      hA.eigenvalues i • hA.eigenvectorBasis i := by
  apply WithLp.ofLp_injective 2
  simpa only [Matrix.ofLp_toLpLin, WithLp.ofLp_smul, Matrix.toLin'_apply] using
    hA.mulVec_eigenvectorBasis i

/-- Exact diagonalization after synthesis in the orthonormal eigenbasis. -/
theorem euclideanQuadratic_eigenbasis (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (x : ι → ℝ) :
    euclideanQuadratic A (∑ i, x i • hA.eigenvectorBasis i) =
      ∑ i, hA.eigenvalues i * (x i) ^ 2 := by
  unfold euclideanQuadratic
  simp only [map_sum, map_smul, toEuclideanLin_eigenvector A hA,
    sum_inner, inner_sum, real_inner_smul_left, real_inner_smul_right,
    OrthonormalBasis.inner_eq_ite]
  simp only [mul_ite, mul_zero]
  apply Finset.sum_congr rfl
  intro i hi
  simp only [Finset.sum_ite_eq', Finset.mem_univ, if_true]
  ring

/-- The centered quadratic form is a sum of centered squares in this basis. -/
theorem centered_euclideanQuadratic_eigenbasis (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (x : ι → ℝ) :
    euclideanQuadratic A (∑ i, x i • hA.eigenvectorBasis i) - A.trace =
      ∑ i, hA.eigenvalues i * ((x i) ^ 2 - 1) := by
  rw [euclideanQuadratic_eigenbasis, hA.trace_eq_sum_eigenvalues]
  simp [mul_sub, Finset.sum_sub_distrib, RCLike.ofReal_real_eq_id]

/-- The sum of eigenvalue squares equals the squared Frobenius norm. -/
theorem eigenvalues_sq_sum_eq_entry_sq_sum (A : Matrix ι ι ℝ) (hA : A.IsHermitian) :
    (∑ i, (hA.eigenvalues i) ^ 2) = ∑ i, ∑ j, (A i j) ^ 2 := by
  have hspec : A = conjStarAlgAut ℝ _ hA.eigenvectorUnitary
      (Matrix.diagonal hA.eigenvalues) := by
    simpa only [Function.comp_def, RCLike.ofReal_real_eq_id, id_eq] using hA.spectral_theorem
  have htrace : (A * A).trace = ∑ i, (hA.eigenvalues i) ^ 2 := by
    calc
      (A * A).trace = (conjStarAlgAut ℝ _ hA.eigenvectorUnitary
          (Matrix.diagonal hA.eigenvalues * Matrix.diagonal hA.eigenvalues)).trace := by
        rw [map_mul, ← hspec]
      _ = (Matrix.diagonal hA.eigenvalues * Matrix.diagonal hA.eigenvalues).trace := by
        rw [conjStarAlgAut_apply, Matrix.trace_mul_cycle, Unitary.coe_star_mul_self,
          Matrix.one_mul]
      _ = _ := by
        rw [Matrix.diagonal_mul_diagonal, Matrix.trace_diagonal]
        simp only [pow_two]
  rw [← htrace]
  simp only [Matrix.trace, Matrix.diag_apply, Matrix.mul_apply]
  apply Finset.sum_congr rfl
  intro i hi
  apply Finset.sum_congr rfl
  intro j hj
  rw [(Matrix.isHermitian_iff_isSymm.mp hA).apply i j]
  ring

/-- Variance of a centered symmetric quadratic form under standard Gaussian measure. -/
theorem variance_euclideanQuadratic_stdGaussian (A : Matrix ι ι ℝ) (hA : A.IsHermitian) :
    variance (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace)
      (stdGaussian (EuclideanSpace ℝ ι)) = 2 * ∑ i, ∑ j, (A i j) ^ 2 := by
  have hg : Measurable (fun x : ι → ℝ => ∑ i, x i • hA.eigenvectorBasis i) := by fun_prop
  rw [stdGaussian_eq_map_pi_orthonormalBasis hA.eigenvectorBasis,
    variance_map (by unfold euclideanQuadratic; fun_prop) hg.aemeasurable]
  have hfun : (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace) ∘
      (fun y : ι → ℝ => ∑ i, y i • hA.eigenvectorBasis i) =
      fun y : ι → ℝ => ∑ i, hA.eigenvalues i * ((y i) ^ 2 - 1) := by
    ext y
    exact centered_euclideanQuadratic_eigenbasis A hA y
  rw [hfun]
  have h := variance_sum_centered_gaussian_squares (fun _ : ι => (1 : ℝ≥0)) hA.eigenvalues
  simp only [NNReal.coe_one, one_pow, mul_one] at h
  rw [h, eigenvalues_sq_sum_eq_entry_sq_sum A hA]

/-- Exact moment-generating function of a centered symmetric Gaussian quadratic form.
Orthogonal invariance is supplied by the standard Gaussian law, not assumed. -/
theorem mgf_euclideanQuadratic_stdGaussian (A : Matrix ι ι ℝ) (hA : A.IsHermitian)
    (s : ℝ) (hs : ∀ i, 0 < 1 - 2 * s * hA.eigenvalues i) :
    mgf (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace)
      (stdGaussian (EuclideanSpace ℝ ι)) s =
      ∏ i, Real.exp (-s * hA.eigenvalues i) /
        Real.sqrt (1 - 2 * s * hA.eigenvalues i) := by
  have hg : Measurable (fun x : ι → ℝ => ∑ i, x i • hA.eigenvectorBasis i) := by fun_prop
  rw [stdGaussian_eq_map_pi_orthonormalBasis hA.eigenvectorBasis,
    mgf_map hg.aemeasurable (by unfold euclideanQuadratic; fun_prop)]
  have hfun : (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace) ∘
      (fun y : ι → ℝ => ∑ i, y i • hA.eigenvectorBasis i) =
      fun y : ι → ℝ => ∑ i, hA.eigenvalues i * ((y i) ^ 2 - 1) := by
    ext y
    exact centered_euclideanQuadratic_eigenbasis A hA y
  rw [hfun]
  simpa only [NNReal.coe_one, mul_one] using
    mgf_sum_centered_gaussian_squares (fun _ : ι => (1 : ℝ≥0)) hA.eigenvalues s
      (by simpa only [NNReal.coe_one, mul_one] using hs)

/-- Two-sided Bernstein tail for a general real symmetric Gaussian quadratic form.
The variance parameter is the squared Frobenius norm; the scale parameter bounds
the absolute eigenvalues. -/
theorem euclideanQuadratic_stdGaussian_abs_tail (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (B V u : ℝ)
    (hB : 0 < B) (hV : 0 < V) (hu : 0 ≤ u)
    (hspectrum : ∀ i, |hA.eigenvalues i| ≤ B)
    (henergy : (∑ i, ∑ j, (A i j) ^ 2) ≤ V) :
    (stdGaussian (EuclideanSpace ℝ ι)).real
      {x | u ≤ |euclideanQuadratic A x - A.trace|} ≤
      2 * Real.exp (-min (u ^ 2 / (16 * V)) (u / (16 * B))) := by
  have hg : Measurable (fun x : ι → ℝ => ∑ i, x i • hA.eigenvectorBasis i) := by fun_prop
  rw [stdGaussian_eq_map_pi_orthonormalBasis hA.eigenvectorBasis,
    map_measureReal_apply hg (by unfold euclideanQuadratic; measurability)]
  have hset : (fun y : ι → ℝ => ∑ i, y i • hA.eigenvectorBasis i) ⁻¹'
      {x | u ≤ |euclideanQuadratic A x - A.trace|} =
      {y : ι → ℝ | u ≤ |∑ i, hA.eigenvalues i * ((y i) ^ 2 - 1)|} := by
    ext y
    simp only [Set.mem_preimage, Set.mem_setOf_eq, centered_euclideanQuadratic_eigenbasis]
  rw [hset]
  have heigenenergy : (∑ i, (hA.eigenvalues i) ^ 2) ≤ V := by
    rwa [eigenvalues_sq_sum_eq_entry_sq_sum A hA]
  simpa only [NNReal.coe_one, one_pow, mul_one] using
    gaussian_quadratic_abs_tail (fun _ : ι => (1 : ℝ≥0)) hA.eigenvalues B V u hB hV hu
      (by simpa only [NNReal.coe_one, mul_one] using hspectrum)
      (by simpa only [NNReal.coe_one, one_pow, mul_one] using heigenenergy)

/-- The usual Euclidean operator norm bounds every absolute eigenvalue. -/
theorem abs_eigenvalue_le_euclidean_operator_norm (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (i : ι) :
    |hA.eigenvalues i| ≤ ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ := by
  have h := (Matrix.toEuclideanLin A).toContinuousLinearMap.le_opNorm
    (hA.eigenvectorBasis i)
  simpa only [LinearMap.coe_toContinuousLinearMap', toEuclideanLin_eigenvector A hA,
    norm_smul, Real.norm_eq_abs, hA.eigenvectorBasis.orthonormal.norm_eq_one, mul_one] using h

/-- Bernstein tail in the standard operator/Frobenius norm parameters. -/
theorem euclideanQuadratic_stdGaussian_abs_tail_of_operator_norm
    (A : Matrix ι ι ℝ) (hA : A.IsHermitian) (B V u : ℝ)
    (hB : 0 < B) (hV : 0 < V) (hu : 0 ≤ u)
    (hnorm : ‖(Matrix.toEuclideanLin A).toContinuousLinearMap‖ ≤ B)
    (henergy : (∑ i, ∑ j, (A i j) ^ 2) ≤ V) :
    (stdGaussian (EuclideanSpace ℝ ι)).real
      {x | u ≤ |euclideanQuadratic A x - A.trace|} ≤
      2 * Real.exp (-min (u ^ 2 / (16 * V)) (u / (16 * B))) :=
  euclideanQuadratic_stdGaussian_abs_tail A hA B V u hB hV hu
    (fun i => (abs_eigenvalue_le_euclidean_operator_norm A hA i).trans hnorm) henergy

/-- Finite exponential moments throughout the spectral domain. -/
theorem integrable_exp_euclideanQuadratic_stdGaussian (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) (s : ℝ) (hs : ∀ i, 0 < 1 - 2 * s * hA.eigenvalues i) :
    Integrable (fun x : EuclideanSpace ℝ ι =>
      Real.exp (s * (euclideanQuadratic A x - A.trace)))
      (stdGaussian (EuclideanSpace ℝ ι)) := by
  apply Integrable.of_integral_ne_zero
  change mgf (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace)
    (stdGaussian (EuclideanSpace ℝ ι)) s ≠ 0
  rw [mgf_euclideanQuadratic_stdGaussian A hA s hs]
  apply Finset.prod_ne_zero_iff.2
  intro i hi
  exact div_ne_zero (Real.exp_ne_zero _) (Real.sqrt_pos.2 (hs i)).ne'

/-- Centered symmetric quadratic forms are square integrable. -/
theorem memLp_centered_euclideanQuadratic_stdGaussian (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) :
    MemLp (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace) 2
      (stdGaussian (EuclideanSpace ℝ ι)) := by
  have hg : Measurable (fun x : ι → ℝ => ∑ i, x i • hA.eigenvectorBasis i) := by fun_prop
  rw [stdGaussian_eq_map_pi_orthonormalBasis hA.eigenvectorBasis]
  apply (memLp_map_measure_iff (by unfold euclideanQuadratic; fun_prop)
    hg.aemeasurable).2
  have hfun : (fun x : EuclideanSpace ℝ ι => euclideanQuadratic A x - A.trace) ∘
      (fun y : ι → ℝ => ∑ i, y i • hA.eigenvectorBasis i) =
      fun y : ι → ℝ => ∑ i, hA.eigenvalues i * ((y i) ^ 2 - 1) := by
    ext y
    exact centered_euclideanQuadratic_eigenbasis A hA y
  rw [hfun]
  apply memLp_finsetSum
  intro i hi
  have hm := ((memLp_square_gaussianReal 1).sub (memLp_const (1 : ℝ))).const_mul
    (hA.eigenvalues i)
  exact hm.comp_measurePreserving (measurePreserving_eval (fun _ : ι => gaussianReal 0 1) i)

/-- The trace is exactly the Gaussian mean of the quadratic form. -/
theorem integral_centered_euclideanQuadratic_stdGaussian (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) :
    (∫ x : EuclideanSpace ℝ ι, euclideanQuadratic A x - A.trace
      ∂stdGaussian (EuclideanSpace ℝ ι)) = 0 := by
  have hg : Measurable (fun x : ι → ℝ => ∑ i, x i • hA.eigenvectorBasis i) := by fun_prop
  rw [stdGaussian_eq_map_pi_orthonormalBasis hA.eigenvectorBasis,
    integral_map hg.aemeasurable (by unfold euclideanQuadratic; fun_prop)]
  simp_rw [centered_euclideanQuadratic_eigenbasis A hA]
  have hm (i : ι) : Integrable (fun y : ℝ => hA.eigenvalues i * (y ^ 2 - 1))
      (gaussianReal 0 1) :=
    (((memLp_square_gaussianReal 1).sub (memLp_const (1 : ℝ))).const_mul
      (hA.eigenvalues i)).integrable (by norm_num)
  rw [integral_finsetSum Finset.univ (fun i _ =>
    (integrable_comp_eval (μ := fun _ : ι => gaussianReal 0 1) (i := i) (hm i)))]
  apply Finset.sum_eq_zero
  intro i hi
  rw [integral_comp_eval (μ := fun _ : ι => gaussianReal 0 1) (i := i)
    (f := fun y : ℝ => hA.eigenvalues i * (y ^ 2 - 1)) (by fun_prop), integral_const_mul,
    integral_sub ((memLp_square_gaussianReal 1).integrable (by norm_num)) (integrable_const _),
    integral_pow_two_gaussianReal]
  simp

/-- The centered second moment equals twice the squared Frobenius norm. -/
theorem integral_sq_centered_euclideanQuadratic_stdGaussian (A : Matrix ι ι ℝ)
    (hA : A.IsHermitian) :
    (∫ x : EuclideanSpace ℝ ι, (euclideanQuadratic A x - A.trace) ^ 2
      ∂stdGaussian (EuclideanSpace ℝ ι)) = 2 * ∑ i, ∑ j, (A i j) ^ 2 := by
  rw [← variance_of_integral_eq_zero (by unfold euclideanQuadratic; fun_prop)
    (integral_centered_euclideanQuadratic_stdGaussian A hA)]
  exact variance_euclideanQuadratic_stdGaussian A hA

end Paulsen
