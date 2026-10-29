import GaussianQuadraticTilt
import GaussianMomentMatrix

/-! Full Gaussian/non-Gaussian entropy decomposition in the actual spectral
coordinates of the uncentered second-moment matrix. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianOrthogonal
variable {I : Type*} [Fintype I]

theorem coordinateMap_comp_inverse
    (u : EuclideanSpace ℝ I ≃ₗᵢ[ℝ] EuclideanSpace ℝ I) :
    coordinateMap u.symm ∘ coordinateMap u = id := by
  funext x
  simp [coordinateMap]

theorem orthogonal_kl_invariant
    (Q P : Measure (I → ℝ)) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (u : EuclideanSpace ℝ I ≃ₗᵢ[ℝ] EuclideanSpace ℝ I) :
    klDiv (Q.map (coordinateMap u)) (P.map (coordinateMap u)) = klDiv Q P := by
  have hT := coordinateMap_measurable u
  have hU := coordinateMap_measurable u.symm
  haveI : IsProbabilityMeasure (Q.map (coordinateMap u)) := Measure.isProbabilityMeasure_map hT.aemeasurable
  haveI : IsProbabilityMeasure (P.map (coordinateMap u)) := Measure.isProbabilityMeasure_map hT.aemeasurable
  apply le_antisymm
  · exact NeuralGeneralization.RobustEntropy.klDiv_map_le Q P hT
  · have h := NeuralGeneralization.RobustEntropy.klDiv_map_le
      (Q.map (coordinateMap u)) (P.map (coordinateMap u)) hU
    simpa only [Measure.map_map hU hT,coordinateMap_comp_inverse,Measure.map_id] using h

def matchingEigenvariances [DecidableEq I] (Q : Measure (I → ℝ)) : I → ℝ≥0 :=
  fun i => Real.toNNReal ((secondMomentMatrix_isHermitian Q).eigenvalues i)

/-- The centered Gaussian having the actual uncentered second moments of Q.
It is defined by independent Gaussian eigen-coordinates and the actual
orthogonal eigenbasis map, not by an abstract covariance existence premise. -/
def matchingGaussian [DecidableEq I] (Q : Measure (I → ℝ)) : Measure (I → ℝ) :=
  (Measure.pi fun i => gaussianReal 0 (matchingEigenvariances Q i)).map
    (coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr.symm)

instance matchingGaussian_probability [DecidableEq I] (Q : Measure (I → ℝ)) :
    IsProbabilityMeasure (matchingGaussian Q) :=
  Measure.isProbabilityMeasure_map (coordinateMap_measurable _).aemeasurable

theorem matchingEigenvariances_pos [DecidableEq I]
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) (i : I) :
    0 < matchingEigenvariances Q i :=
  Real.toNNReal_pos.mpr (secondMomentMatrix_eigenvalues_pos Q hKL i)

theorem matchingGaussian_eigen_map [DecidableEq I] (Q : Measure (I → ℝ)) :
    (matchingGaussian Q).map (coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr) =
      Measure.pi fun i => gaussianReal 0 (matchingEigenvariances Q i) := by
  unfold matchingGaussian
  rw [Measure.map_map (coordinateMap_measurable _) (coordinateMap_measurable _)]
  have he := coordinateMap_comp_inverse (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr.symm
  simp only [LinearIsometryEquiv.symm_symm] at he
  rw [he,Measure.map_id]

theorem gaussian_full_moment_entropy_decomposition [DecidableEq I]
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    klDiv Q (matchingGaussian Q) ≠ ∞ ∧
      (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal =
        (klDiv Q (matchingGaussian Q)).toReal +
        (∑ i, ((secondMomentMatrix_isHermitian Q).eigenvalues i-1-
          Real.log ((secondMomentMatrix_isHermitian Q).eigenvalues i)))/2 := by
  let u := (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr
  let T := coordinateMap u
  let G : Measure (I → ℝ) := Measure.pi fun _ : I => gaussianReal 0 1
  have hT : Measurable T := coordinateMap_measurable u
  have hG : G.map T=G := productGaussian_map_coordinateMap 1 u
  have hrotate := orthogonal_kl_invariant Q G u
  rw [hG] at hrotate
  have hfinite : klDiv (Q.map T) G ≠ ∞ := by rwa [hrotate]
  haveI : IsProbabilityMeasure (Q.map T) := Measure.isProbabilityMeasure_map hT.aemeasurable
  have hm (i : I) : (∫ x : I → ℝ, x i^2 ∂Q.map T) = (matchingEigenvariances Q i:ℝ) := by
    rw [integral_map hT.aemeasurable (((measurable_pi_apply i).pow_const 2).aestronglyMeasurable)]
    rw [matchingEigenvariances,Real.coe_toNNReal _ (secondMomentMatrix_eigenvalues_pos Q hKL i).le,
      secondMomentMatrix_eigenvalue_eq_moment Q hKL]
    rfl
  have hd := gaussian_matching_diagonal_entropy_decomposition (Q.map T) hfinite
    (matchingEigenvariances Q) (fun i => (matchingEigenvariances_pos Q hKL i).ne') hm
  have hng := orthogonal_kl_invariant Q (matchingGaussian Q) u
  rw [matchingGaussian_eigen_map] at hng
  rw [hrotate,hng] at hd
  simp only [matchingEigenvariances,Real.coe_toNNReal _
    (secondMomentMatrix_eigenvalues_pos Q hKL _).le] at hd
  exact hd

#print axioms gaussian_full_moment_entropy_decomposition
end ConditionalNonpolynomial.Analytic
