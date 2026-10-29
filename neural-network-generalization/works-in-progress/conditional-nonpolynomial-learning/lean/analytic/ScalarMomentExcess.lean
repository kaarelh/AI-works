import TaggedScalarEntropy

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic

theorem scalar_moment_excess_bound (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1)≠∞) :
    (∫z:ℝ,z^2 ∂Q)-1≤
      2*Real.sqrt 2*Real.sqrt (klDiv Q (gaussianReal 0 1)).toReal+
      2*(klDiv Q (gaussianReal 0 1)).toReal := by
  have hp := scalar_gaussian_polar_deviation Q hKL
  have hM := scalar_gaussian_second_moment_pos Q hKL
  have hD : 0≤(klDiv Q (gaussianReal 0 1)).toReal := ENNReal.toReal_nonneg
  have hs := Real.sq_sqrt (show 0≤2*(klDiv Q (gaussianReal 0 1)).toReal by positivity)
  have hsM := Real.sq_sqrt hM.le
  have hsqrt : Real.sqrt (∫z:ℝ,z^2 ∂Q)≤1+Real.sqrt (2*(klDiv Q (gaussianReal 0 1)).toReal) := by
    nlinarith [Real.sqrt_nonneg (∫z:ℝ,z^2 ∂Q),
      Real.sqrt_nonneg (2*(klDiv Q (gaussianReal 0 1)).toReal)]
  have hsq := pow_le_pow_left₀ (Real.sqrt_nonneg _) hsqrt 2
  rw [Real.sqrt_mul (by norm_num : (0:ℝ)≤2)] at hs hsq
  nlinarith

theorem scalar_moment_excess_sum (Q : ℕ→Measure ℝ) (H : ℕ)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hKL : ∀j<H,klDiv (Q j) (gaussianReal 0 1)≠∞) :
    (∑j∈Finset.range H,((∫z:ℝ,z^2 ∂Q j)-1))≤
      2*Real.sqrt 2*(∑j∈Finset.range H,Real.sqrt (klDiv (Q j) (gaussianReal 0 1)).toReal)+
      2*(∑j∈Finset.range H,(klDiv (Q j) (gaussianReal 0 1)).toReal) := by
  calc
    _ ≤ ∑j∈Finset.range H,(2*Real.sqrt 2*Real.sqrt (klDiv (Q j) (gaussianReal 0 1)).toReal+
      2*(klDiv (Q j) (gaussianReal 0 1)).toReal) := by
      apply Finset.sum_le_sum
      intro j hj
      letI := hprob j (Finset.mem_range.mp hj)
      exact scalar_moment_excess_bound (Q j) (hKL j (Finset.mem_range.mp hj))
    _ = _ := by rw [Finset.sum_add_distrib,Finset.mul_sum,Finset.mul_sum]

#print axioms scalar_moment_excess_sum
end ConditionalNonpolynomial.Analytic
