import PhysicalShortEvaluationRanges
import PhysicalAbsoluteCompression

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel

theorem physicalGainProduct_le_rawEntropy {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : physicalGainProduct P H≤Real.exp (canonicalEntropySum P) := by
  have hg (j:ℕ) : physicalLayerGain P j≤Real.exp (Real.sqrt (2*physicalLayerCost P j)) := by
    have hD : 0≤physicalLayerCost P j := ENNReal.toReal_nonneg
    have hv : 0<gaussianEntropyGain (physicalLayerCost P j) :=
      lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le _)
    have hd := sqrt_deviation_sq_le_gaussian_cost _ hv
    have he := gaussianEntropyGain_cost hD
    unfold gaussianVarianceCost at he
    have hs := Real.le_sqrt_of_sq_le (show (Real.sqrt (gaussianEntropyGain (physicalLayerCost P j))-1)^2≤
      2*physicalLayerCost P j by linarith)
    have hsmall : Real.sqrt (gaussianEntropyGain (physicalLayerCost P j))≤
        Real.exp (Real.sqrt (2*physicalLayerCost P j)) := by
      linarith [Real.add_one_le_exp (Real.sqrt (2*physicalLayerCost P j))]
    rw [physicalLayerGain_eq]
    exact (mul_le_of_le_one_left (Real.sqrt_nonneg _) P.scale_le_one).trans hsmall
  have hh := Finset.prod_le_prod (fun j (_:j∈Finset.range H)=>(physicalLayerGain_pos P j).le)
    (fun j (_:j∈Finset.range H)=>hg j)
  change physicalGainProduct P H≤_ at hh
  simpa only [←Real.exp_sum,canonicalEntropySum] using hh

#print axioms physicalGainProduct_le_rawEntropy
end ConditionalNonpolynomial.Analytic.PhysicalShort
