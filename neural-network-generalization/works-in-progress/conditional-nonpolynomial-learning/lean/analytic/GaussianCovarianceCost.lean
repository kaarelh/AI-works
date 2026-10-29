import GaussianMatchingCovariance
import GaussianWhiteningOperator
import ScalarOccupation

noncomputable section
set_option maxHeartbeats 1800000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I] [DecidableEq I]

/-- Gaussian entropy cost of the actual uncentered second-moment matrix. -/
def gaussianCovarianceCost (Q : Measure (I→ℝ)) : ℝ :=
  (∑i,((secondMomentMatrix_isHermitian Q).eigenvalues i-1-
    Real.log ((secondMomentMatrix_isHermitian Q).eigenvalues i)))/2

theorem gaussianCovarianceCost_nonneg (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    0≤gaussianCovarianceCost Q := by
  unfold gaussianCovarianceCost
  apply div_nonneg _ (by norm_num)
  apply Finset.sum_nonneg
  intro i _
  have hh := Real.log_le_sub_one_of_pos (secondMomentMatrix_eigenvalues_pos Q hKL i)
  linarith

theorem gaussianCovarianceCost_decomposition (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    klDiv Q (matchingGaussian Q)≠∞ ∧
      (klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal=
        (klDiv Q (matchingGaussian Q)).toReal+gaussianCovarianceCost Q :=
  gaussian_full_moment_entropy_decomposition Q hKL

theorem gaussianCovarianceCost_le_kl (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    gaussianCovarianceCost Q≤(klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)).toReal := by
  have h := (gaussianCovarianceCost_decomposition Q hKL).2
  linarith [ENNReal.toReal_nonneg (a:=klDiv Q (matchingGaussian Q))]

theorem gaussian_eigenvalue_sqrt_le (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) (i : I) :
    Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)≤
      1+Real.sqrt (2*gaussianCovarianceCost Q) := by
  have he (j : I) : 0≤(secondMomentMatrix_isHermitian Q).eigenvalues j-1-
      Real.log ((secondMomentMatrix_isHermitian Q).eigenvalues j) := by
    have hh := Real.log_le_sub_one_of_pos (secondMomentMatrix_eigenvalues_pos Q hKL j)
    linarith
  have hs := Finset.single_le_sum (fun j (_ : j∈Finset.univ)=>he j) (Finset.mem_univ i)
  have hd := sqrt_deviation_sq_le_gaussian_cost _ (secondMomentMatrix_eigenvalues_pos Q hKL i)
  have hbound : (Real.sqrt ((secondMomentMatrix_isHermitian Q).eigenvalues i)-1)^2≤
      2*gaussianCovarianceCost Q := by unfold gaussianCovarianceCost; linarith
  have hh := Real.le_sqrt_of_sq_le hbound
  linarith

theorem gaussian_eigenvalue_le (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) (i : I) :
    (secondMomentMatrix_isHermitian Q).eigenvalues i≤
      (1+Real.sqrt (2*gaussianCovarianceCost Q))^2 := by
  have hh := pow_le_pow_left₀ (Real.sqrt_nonneg _) (gaussian_eigenvalue_sqrt_le Q hKL i) 2
  rwa [Real.sq_sqrt (secondMomentMatrix_eigenvalues_pos Q hKL i).le] at hh

theorem gaussianFeaturePreconditioner_norm_covarianceCost
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    ‖gaussianFeaturePreconditioner Q‖≤1+Real.sqrt (2*gaussianCovarianceCost Q) :=
  gaussianFeaturePreconditioner_norm Q hKL (by positivity) (gaussian_eigenvalue_le Q hKL)

theorem gaussianFeaturePreconditioner_norm_exp_covarianceCost
    (Q : Measure (I→ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I=>gaussianReal 0 1)≠∞) :
    ‖gaussianFeaturePreconditioner Q‖≤Real.exp (Real.sqrt (2*gaussianCovarianceCost Q)) := by
  apply (gaussianFeaturePreconditioner_norm_covarianceCost Q hKL).trans
  linarith [Real.add_one_le_exp (Real.sqrt (2*gaussianCovarianceCost Q))]

#print axioms gaussianCovarianceCost_decomposition
#print axioms gaussian_eigenvalue_sqrt_le
#print axioms gaussianFeaturePreconditioner_norm_covarianceCost
end ConditionalNonpolynomial.Analytic
