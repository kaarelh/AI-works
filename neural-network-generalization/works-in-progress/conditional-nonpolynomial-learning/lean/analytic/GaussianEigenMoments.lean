import GaussianMatchingCovariance

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianOrthogonal
variable {I : Type*} [Fintype I]

theorem gaussian_integral_dotProduct_mul (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) (u v : I→ℝ) :
    (∫x,(u ⬝ᵥ x)*(v ⬝ᵥ x) ∂Q)=u ⬝ᵥ (secondMomentMatrix Q *ᵥ v) := by
  classical
  have hi (i j:I) : Integrable (fun x:I→ℝ=>u i*v j*(x i*x j)) Q :=
    (gaussian_coordinate_product_integrable Q hKL i j).const_mul _
  have heq (x:I→ℝ) : (u ⬝ᵥ x)*(v ⬝ᵥ x)=∑i,∑j,u i*v j*(x i*x j) := by
    simp only [dotProduct,Finset.sum_mul_sum]
    apply Finset.sum_congr rfl
    intro i _
    apply Finset.sum_congr rfl
    intro j _
    ring
  simp_rw [heq]
  rw [integral_finsetSum _ (fun i _=>integrable_finsetSum _ (fun j _=>hi i j))]
  simp only [dotProduct,Matrix.mulVec,Finset.mul_sum]
  apply Finset.sum_congr rfl
  intro i _
  rw [integral_finsetSum _ (fun j _=>hi i j)]
  apply Finset.sum_congr rfl
  intro j _
  rw [integral_const_mul]
  unfold secondMomentMatrix
  ring

theorem eigen_coordinate_dotProduct [DecidableEq I] (Q : Measure (I→ℝ)) (i:I) (x:I→ℝ) :
    coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr x i=
      ((secondMomentMatrix_isHermitian Q).eigenvectorBasis i) ⬝ᵥ x := by
  unfold coordinateMap
  rw [OrthonormalBasis.repr_apply_apply,EuclideanSpace.inner_eq_star_dotProduct]
  simp only [star_trivial]
  exact dotProduct_comm _ _

theorem eigen_coordinate_cross_moment [DecidableEq I] (Q : Measure (I→ℝ))
    [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) (i j:I) :
    (∫x,coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr x i*
      coordinateMap (secondMomentMatrix_isHermitian Q).eigenvectorBasis.repr x j ∂Q)=
      if i=j then (secondMomentMatrix_isHermitian Q).eigenvalues i else 0 := by
  simp_rw [eigen_coordinate_dotProduct]
  rw [gaussian_integral_dotProduct_mul Q hKL,
    (secondMomentMatrix_isHermitian Q).mulVec_eigenvectorBasis,dotProduct_smul]
  have he : ((secondMomentMatrix_isHermitian Q).eigenvectorBasis i) ⬝ᵥ
      ((secondMomentMatrix_isHermitian Q).eigenvectorBasis j)=if i=j then 1 else 0 := by
    have hh := (secondMomentMatrix_isHermitian Q).eigenvectorBasis.inner_eq_ite i j
    rw [dotProduct_comm]
    simpa only [EuclideanSpace.inner_eq_star_dotProduct,star_trivial] using hh
  rw [he]
  split_ifs with hij
  · subst j
    simp
  · simp

#print axioms eigen_coordinate_cross_moment
end ConditionalNonpolynomial.Analytic
