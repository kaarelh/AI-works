import GaussianCovarianceEntropy
import TwoBallGeometry
import Mathlib.Analysis.Matrix.PosDef

/-! The full uncentered second-moment matrix and its genuine spectral entropy
bound. In particular a nonzero mean is not silently subtracted. -/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace

namespace ConditionalNonpolynomial.Analytic

variable {I : Type*} [Fintype I]

def secondMomentMatrix (Q : Measure (I → ℝ)) : Matrix I I ℝ :=
  fun i j => ∫ x : I → ℝ, x i * x j ∂Q

theorem secondMomentMatrix_isHermitian (Q : Measure (I → ℝ)) :
    (secondMomentMatrix Q).IsHermitian := by
  ext i j
  simp only [Matrix.conjTranspose_apply, star_trivial, secondMomentMatrix]
  congr 1
  funext x
  ring

theorem gaussian_coordinate_product_integrable
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (i j : I) :
    Integrable (fun x : I → ℝ => x i * x j) Q := by
  have hi := gaussian_coordinate_second_moment_integrable Q hKL i
  have hj := gaussian_coordinate_second_moment_integrable Q hKL j
  apply (hi.add hj).mono' (((measurable_pi_apply i).mul (measurable_pi_apply j)).aestronglyMeasurable)
  filter_upwards [] with x
  simp only [Pi.add_apply, Pi.mul_apply, Real.norm_eq_abs, abs_mul]
  nlinarith [sq_nonneg (|x i| - |x j|), sq_abs (x i), sq_abs (x j)]

theorem gaussian_integral_dotProduct_sq
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (u : I → ℝ) :
    (∫ x : I → ℝ, (u ⬝ᵥ x)^2 ∂Q) = u ⬝ᵥ (secondMomentMatrix Q *ᵥ u) := by
  classical
  have hi (i j : I) : Integrable (fun x : I → ℝ => u i * u j * (x i * x j)) Q :=
    (gaussian_coordinate_product_integrable Q hKL i j).const_mul _
  have heq (x : I → ℝ) : (u ⬝ᵥ x)^2 =
      ∑ i, ∑ j, u i * u j * (x i * x j) := by
    simp only [dotProduct, pow_two, Finset.sum_mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  simp_rw [heq]
  rw [integral_finsetSum _ (fun i _ => integrable_finsetSum _ (fun j _ => hi i j))]
  simp only [dotProduct, Matrix.mulVec, Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [integral_finsetSum _ (fun j _ => hi i j)]
  apply Finset.sum_congr rfl
  intro j _
  rw [integral_const_mul]
  unfold secondMomentMatrix
  ring

theorem secondMomentMatrix_eigenvalue_eq_moment
    [DecidableEq I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (i : I) :
    (secondMomentMatrix_isHermitian Q).eigenvalues i =
      ∫ x : I → ℝ,
        ((secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr (WithLp.toLp 2 x) i)^2 ∂Q := by
  rw [(secondMomentMatrix_isHermitian Q).eigenvalues_eq]
  simp only [RCLike.re_to_real, star_trivial]
  rw [← gaussian_integral_dotProduct_sq Q hKL]
  apply integral_congr_ae
  filter_upwards [] with x
  rw [OrthonormalBasis.repr_apply_apply, EuclideanSpace.inner_eq_star_dotProduct]
  simp [dotProduct_comm]

theorem secondMomentMatrix_eigenvalues_pos
    [DecidableEq I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (i : I) :
    0 < (secondMomentMatrix_isHermitian Q).eigenvalues i := by
  let u := (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr
  let T := NeuralGeneralization.GaussianOrthogonal.coordinateMap u
  let G : Measure (I → ℝ) := Measure.pi fun _ : I => gaussianReal 0 1
  have hT : Measurable T := NeuralGeneralization.GaussianOrthogonal.coordinateMap_measurable u
  have hG : G.map T = G := NeuralGeneralization.GaussianOrthogonal.productGaussian_map_coordinateMap 1 u
  have hdata := NeuralGeneralization.RobustEntropy.klDiv_map_le Q G hT
  rw [hG] at hdata
  have hfinite : klDiv (Q.map T) G ≠ ∞ :=
    ne_of_lt (lt_of_le_of_lt hdata (lt_top_iff_ne_top.mpr hKL))
  haveI : IsProbabilityMeasure (Q.map T) := Measure.isProbabilityMeasure_map hT.aemeasurable
  have h := gaussian_coordinate_second_moment_pos (Q.map T) hfinite i
  rw [integral_map hT.aemeasurable (((measurable_pi_apply i).pow_const 2).aestronglyMeasurable)] at h
  rwa [secondMomentMatrix_eigenvalue_eq_moment Q hKL]

/-- Finite entropy forces the full uncentered second-moment matrix to be
strictly positive definite, even when the controlled law has nonzero mean. -/
theorem secondMomentMatrix_posDef
    [DecidableEq I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    (secondMomentMatrix Q).PosDef :=
  (secondMomentMatrix_isHermitian Q).posDef_iff_eigenvalues_pos.mpr
    (secondMomentMatrix_eigenvalues_pos Q hKL)

/-- The spectral polar-deviation budget is bounded by the actual KL divergence. -/
theorem secondMomentMatrix_polar_deviation
    [DecidableEq I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    (∑ i, (Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i) - 1)^2) ≤
      2 * (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal := by
  have h := gaussian_orthogonal_polar_deviation Q hKL
    (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr
  simpa only [secondMomentMatrix_eigenvalue_eq_moment Q hKL,
    NeuralGeneralization.GaussianOrthogonal.coordinateMap] using h

#print axioms secondMomentMatrix_posDef
#print axioms secondMomentMatrix_polar_deviation

/-- The spectral square root of the full second-moment matrix, as an actual
linear map on the coefficient space. -/
def momentSquareRoot [DecidableEq I] (Q : Measure (I → ℝ)) :
    EuclideanSpace ℝ I →ₗ[ℝ] EuclideanSpace ℝ I :=
  (secondMomentMatrix_isHermitian Q).eigenvectorBasis.toBasis.constr ℝ
    (fun i => Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i) •
      (secondMomentMatrix_isHermitian Q).eigenvectorBasis i)

def momentPolarDeviation [DecidableEq I] (Q : Measure (I → ℝ)) :
    EuclideanSpace ℝ I →ₗ[ℝ] EuclideanSpace ℝ I :=
  momentSquareRoot Q - LinearMap.id

theorem momentSquareRoot_apply_basis [DecidableEq I] (Q : Measure (I → ℝ)) (i : I) :
    momentSquareRoot Q ((secondMomentMatrix_isHermitian Q).eigenvectorBasis i) =
      Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i) •
        (secondMomentMatrix_isHermitian Q).eigenvectorBasis i := by
  exact (secondMomentMatrix_isHermitian Q).eigenvectorBasis.toBasis.constr_basis ℝ _ i

theorem momentPolarDeviation_apply_basis [DecidableEq I] (Q : Measure (I → ℝ)) (i : I) :
    momentPolarDeviation Q ((secondMomentMatrix_isHermitian Q).eigenvectorBasis i) =
      (Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i) - 1) •
        (secondMomentMatrix_isHermitian Q).eigenvectorBasis i := by
  simp only [momentPolarDeviation, LinearMap.sub_apply, LinearMap.id_apply,
    momentSquareRoot_apply_basis, sub_smul, one_smul]

/-- The constructed spectral operator really squares to the uncentered moment
matrix; it is not merely a list of proposed singular values. -/
theorem momentSquareRoot_comp_self
    [DecidableEq I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    (momentSquareRoot Q).comp (momentSquareRoot Q) =
      Matrix.toLpLin 2 2 (secondMomentMatrix Q) := by
  apply (secondMomentMatrix_isHermitian Q).eigenvectorBasis.toBasis.ext
  intro i
  simp only [OrthonormalBasis.coe_toBasis, LinearMap.comp_apply,
    momentSquareRoot_apply_basis, map_smul, smul_smul,
    ← pow_two, Real.sq_sqrt (secondMomentMatrix_eigenvalues_pos Q hKL i).le]
  rw [Matrix.toLpLin_apply,
    (secondMomentMatrix_isHermitian Q).mulVec_eigenvectorBasis]
  rfl

theorem momentPolarDeviation_frobeniusSq [DecidableEq I] (Q : Measure (I → ℝ)) :
    BooleanDepthResearch.frobeniusSq (momentPolarDeviation Q) =
      ∑ i, (Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i) - 1)^2 := by
  rw [BooleanDepthResearch.frobeniusSq_eq_sum_norm_sq _
    (secondMomentMatrix_isHermitian Q).eigenvectorBasis]
  simp only [momentPolarDeviation_apply_basis, norm_smul,
    OrthonormalBasis.norm_eq_one, mul_one, Real.norm_eq_abs, sq_abs]

/-- An actual Hilbert--Schmidt bound for sqrt(E[ZZᵀ])-I from finite KL. -/
theorem momentPolarDeviation_hilbertSchmidt_le
    [DecidableEq I] (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    BooleanDepthResearch.frobeniusSq (momentPolarDeviation Q) ≤
      2 * (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal := by
  rw [momentPolarDeviation_frobeniusSq]
  exact secondMomentMatrix_polar_deviation Q hKL

#print axioms momentPolarDeviation_hilbertSchmidt_le

end ConditionalNonpolynomial.Analytic
