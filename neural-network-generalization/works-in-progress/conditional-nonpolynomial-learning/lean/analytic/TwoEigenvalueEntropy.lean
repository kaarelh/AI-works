import GaussianMatchingCovariance
import Mathlib.Analysis.SpecialFunctions.Log.Deriv

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory Matrix
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

def twoBallEntropyBaseline (a : ℝ) : ℝ := (a-Real.log (a+1))/2
def twoBallEntropyGap (a : ℝ) : ℝ :=
  ((a+1)*Real.log (a+1)-(a+2)*Real.log ((a+2)/2))/2

theorem log_arithmetic_mean (u v : ℝ) (hu : 0<u) (hv : 0<v) :
    Real.log u+Real.log v≤2*Real.log ((u+v)/2) := by
  let q := (u+v)/2
  have hq : 0<q := by dsimp [q]; positivity
  have h1 := Real.log_le_sub_one_of_pos (div_pos hu hq)
  have h2 := Real.log_le_sub_one_of_pos (div_pos hv hq)
  rw [Real.log_div hu.ne' hq.ne'] at h1
  rw [Real.log_div hv.ne' hq.ne'] at h2
  have he : u/q+v/q=2 := by dsimp [q]; field_simp <;> ring
  dsimp [q] at *
  linarith

theorem two_moment_entropy_gain (a u v D : ℝ) (ha : 0<a)
    (hu : 0<u) (hv : 0<v)
    (hD : (u-1-Real.log u+v-1-Real.log v)/2≤D) :
    Real.log (Real.sqrt ((u+v)/(2*(a+1))))≤
      (D-twoBallEntropyBaseline a-twoBallEntropyGap a)/a := by
  let q := (u+v)/2
  have hq : 0<q := by dsimp [q]; positivity
  have ha1 : 0<a+1 := by positivity
  have ha2 : 0<a+2 := by positivity
  have hm := log_arithmetic_mean u v hu hv
  have hcost : q-1-Real.log q≤D := by dsimp [q]; linarith
  have hx : 0<q/((a+2)/2) := by positivity
  have hl := Real.log_le_sub_one_of_pos hx
  rw [Real.log_div hq.ne' (by positivity : (a+2)/2≠0)] at hl
  have hm' := mul_le_mul_of_nonneg_left hl (by positivity : 0≤(a+2)/2)
  have hc : ((a+2)/2)*(q/((a+2)/2)-1)=q-(a+2)/2 := by field_simp <;> ring
  rw [hc] at hm'
  have hg : a/2*(Real.log q-Real.log (a+1))≤
      D-twoBallEntropyBaseline a-twoBallEntropyGap a := by
    dsimp [twoBallEntropyBaseline,twoBallEntropyGap]
    nlinarith
  have he : (u+v)/(2*(a+1))=q/(a+1) := by dsimp [q]; field_simp <;> ring
  rw [he,Real.log_sqrt (div_nonneg hq.le ha1.le),Real.log_div hq.ne' ha1.ne']
  exact (le_div_iff₀ ha).mpr (by nlinarith)

theorem secondMomentMatrix_two_eigenvalues_entropy
    {I : Type*} [Fintype I] [DecidableEq I]
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)≠∞)
    (i j : I) (hij : i≠j) :
    (((secondMomentMatrix_isHermitian Q).eigenvalues i-1-
      Real.log ((secondMomentMatrix_isHermitian Q).eigenvalues i))+
      ((secondMomentMatrix_isHermitian Q).eigenvalues j-1-
      Real.log ((secondMomentMatrix_isHermitian Q).eigenvalues j)))/2≤
      (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal := by
  classical
  let w := (secondMomentMatrix_isHermitian Q).eigenvalues
  have hn (k : I) : 0≤w k-1-Real.log (w k) := by
    have h := Real.log_le_sub_one_of_pos (secondMomentMatrix_eigenvalues_pos Q hKL k)
    dsimp [w]; linarith
  have hs : (∑k∈({i,j}:Finset I),(w k-1-Real.log (w k)))≤
      ∑k : I,(w k-1-Real.log (w k)) :=
    Finset.sum_le_sum_of_subset_of_nonneg (Finset.subset_univ _) (fun k _ _ => hn k)
  simp only [Finset.sum_pair hij] at hs
  obtain ⟨_,he⟩ := gaussian_full_moment_entropy_decomposition Q hKL
  have hnKL : 0≤(klDiv Q (matchingGaussian Q)).toReal := ENNReal.toReal_nonneg
  dsimp [w] at hs
  linarith

#print axioms two_moment_entropy_gain
#print axioms secondMomentMatrix_two_eigenvalues_entropy
end ConditionalNonpolynomial.Analytic
