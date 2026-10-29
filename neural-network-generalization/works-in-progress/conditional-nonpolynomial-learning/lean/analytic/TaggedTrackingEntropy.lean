import TaggedPhysicalAction
import ScalarChannelErrorBudget

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

theorem tagged_reused_tracking_entropy {t v r S : ℝ}
    (P : TaggedScalarPath t v r) (Q : ℕ→Measure ℝ) (H : ℕ)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hcontrol : ∀j<H,P.control j=(Q j).prod scoreSignLaw)
    (hsqrt : (∑j∈Finset.range H,Real.sqrt (klDiv (Q j) (gaussianReal 0 1)).toReal)≤S) :
    channelEntropyPrefix (fun j=>(klDiv (P.control j) (taggedGaussianReference 1)).toReal) H≤
      Real.sqrt 2*S := by
  unfold channelEntropyPrefix
  rw [Fin.sum_univ_eq_sum_range (fun j=>Real.sqrt (2*(klDiv (P.control j) (taggedGaussianReference 1)).toReal)) H]
  have heq : (∑j∈Finset.range H,Real.sqrt
      (2*(klDiv (P.control j) (taggedGaussianReference 1)).toReal))=
      Real.sqrt 2*(∑j∈Finset.range H,Real.sqrt (klDiv (Q j) (gaussianReal 0 1)).toReal) := by
    rw [Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro j hj
    letI := hprob j (Finset.mem_range.mp hj)
    rw [hcontrol j (Finset.mem_range.mp hj)]
    simp only [taggedGaussianReference,one_pow,Real.toNNReal_one,score_downgrade_kl,
      Real.sqrt_mul (show (0:ℝ)≤2 by norm_num)]
  rw [heq]
  exact mul_le_mul_of_nonneg_left hsqrt (Real.sqrt_nonneg _)

#print axioms tagged_reused_tracking_entropy
end ConditionalNonpolynomial.Analytic
