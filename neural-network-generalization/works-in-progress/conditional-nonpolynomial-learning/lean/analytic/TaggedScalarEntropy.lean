import ScalarCriticalReferenceChange
import TaggedScalarPath

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators NNReal
namespace ConditionalNonpolynomial.Analytic

theorem tagged_control_criticalKL (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1)≠∞) :
    klDiv (Q.prod scoreSignLaw) (taggedGaussianReference 1)≠∞ := by
  simpa only [taggedGaussianReference,one_pow,Real.toNNReal_one,score_downgrade_kl] using hKL

theorem tagged_control_priorKL (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {t : ℝ} (ht : 0<t) (hKL : klDiv Q (gaussianReal 0 1)≠∞) :
    klDiv (Q.prod scoreSignLaw) (taggedGaussianReference t)≠∞ := by
  have hv : (t^2).toNNReal≠0 := ne_of_gt (Real.toNNReal_pos.mpr (sq_pos_of_pos ht))
  simpa only [taggedGaussianReference,score_downgrade_kl] using
    (scalar_critical_reference_change Q (t^2).toNNReal hv hKL).1

theorem tagged_control_reference_change (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {t : ℝ} (ht : 0<t) (hKL : klDiv Q (gaussianReal 0 1)≠∞) :
    (klDiv (Q.prod scoreSignLaw) (taggedGaussianReference t)).toReal=
      (klDiv Q (gaussianReal 0 1)).toReal+subcriticalCostBaseline (t^2).toNNReal+
      ((t^2)⁻¹-1)/2*((∫z:ℝ,z^2 ∂Q)-1) := by
  have hv : (t^2).toNNReal≠0 := ne_of_gt (Real.toNNReal_pos.mpr (sq_pos_of_pos ht))
  have hh := (scalar_critical_reference_change Q (t^2).toNNReal hv hKL).2
  rw [Real.coe_toNNReal _ (sq_nonneg _)] at hh
  simp only [taggedGaussianReference,score_downgrade_kl,subcriticalCostBaseline,
    Real.coe_toNNReal _ (sq_nonneg _)]
  linarith

theorem tagged_controls_entropy_sum (Q : ℕ→Measure ℝ) (H : ℕ) {t : ℝ} (ht : 0<t)
    (hprob : ∀j<H,IsProbabilityMeasure (Q j))
    (hKL : ∀j<H,klDiv (Q j) (gaussianReal 0 1)≠∞) :
    (∑j∈Finset.range H,(klDiv ((Q j).prod scoreSignLaw) (taggedGaussianReference t)).toReal)=
      (∑j∈Finset.range H,(klDiv (Q j) (gaussianReal 0 1)).toReal)+
      (H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+
      ((t^2)⁻¹-1)/2*(∑j∈Finset.range H,((∫z:ℝ,z^2 ∂Q j)-1)) := by
  have hh : (∑j∈Finset.range H,(klDiv ((Q j).prod scoreSignLaw) (taggedGaussianReference t)).toReal)=
      ∑j∈Finset.range H,((klDiv (Q j) (gaussianReal 0 1)).toReal+
        subcriticalCostBaseline (t^2).toNNReal+((t^2)⁻¹-1)/2*((∫z:ℝ,z^2 ∂Q j)-1)) := by
    apply Finset.sum_congr rfl
    intro j hj
    letI := hprob j (Finset.mem_range.mp hj)
    exact tagged_control_reference_change (Q j) ht (hKL j (Finset.mem_range.mp hj))
  rw [hh]
  simp only [Finset.sum_add_distrib,Finset.sum_const,Finset.card_range,nsmul_eq_mul,Finset.mul_sum]

#print axioms tagged_controls_entropy_sum
end ConditionalNonpolynomial.Analytic
