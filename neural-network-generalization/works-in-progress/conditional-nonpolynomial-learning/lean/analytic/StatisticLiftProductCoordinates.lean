import StatisticEntropyLift
import ProductControlEntropy

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1500000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy
variable {Ω Y A B : Type*}
  [MeasurableSpace Ω] [MeasurableSpace Y] [MeasurableSpace A] [MeasurableSpace B]
  [StandardBorelSpace Ω] [StandardBorelSpace Y] [StandardBorelSpace A] [StandardBorelSpace B]
  [Nonempty Ω] [Nonempty Y] [Nonempty A] [Nonempty B]

/-- Exact entropy minimality forces an untouched product conditional law. -/
theorem probability_eq_product_of_kl_le (P : Measure (A×B)) [IsProbabilityMeasure P]
    (μ : Measure A) [IsProbabilityMeasure μ] (ν : Measure B) [IsProbabilityMeasure ν]
    (hf : klDiv P.fst μ≠∞) (hcost : klDiv P (μ.prod ν)≤klDiv P.fst μ) :
    P=P.fst.prod ν := by
  have hc := klDiv_compProd_eq_add P.fst μ P.condKernel (Kernel.const A ν)
  rw [Measure.disintegrate P P.condKernel,Measure.compProd_const,Measure.compProd_const] at hc
  have hz : klDiv P (P.fst.prod ν)=0 := by
    rw [hc] at hcost
    apply le_antisymm _ zero_le
    exact (ENNReal.add_le_add_iff_left hf).mp (by simpa only [add_zero] using hcost)
  exact klDiv_eq_zero_iff.mp hz

/-- If a statistic is equivalent to the first component of independent
reference coordinates, its genuine conditional lift changes only that
component and leaves the second component independent. -/
theorem statisticEntropyLift_product_coordinates
    (μ : Measure Ω) [IsProbabilityMeasure μ] (Q : Measure Ω) [IsProbabilityMeasure Q]
    (hQ : klDiv Q μ≠∞) (F : Ω→Y) (hF : Measurable F)
    (E : Ω→A×B) (hE : Measurable E)
    (μA : Measure A) [IsProbabilityMeasure μA] (μB : Measure B) [IsProbabilityMeasure μB]
    (hprod : μ.map E=μA.prod μB)
    (f : A→Y) (hf : Measurable f) (g : Y→A) (hg : Measurable g)
    (hFof : ∀x,F x=f (E x).1) (hUof : ∀x,(E x).1=g (F x)) :
    (statisticEntropyLift μ F (Q.map F)).map E=
      (Q.map (Prod.fst ∘ E)).prod μB := by
  let U := Prod.fst ∘ E
  have hU : Measurable U := measurable_fst.comp hE
  have hQD : klDiv (Q.map F) (μ.map F)≠∞ :=
    ne_top_of_le_ne_top hQ (klDiv_map_le Q μ hF)
  letI : IsProbabilityMeasure (Q.map F) := Measure.isProbabilityMeasure_map hF.aemeasurable
  let L := statisticEntropyLift μ F (Q.map F)
  letI : IsProbabilityMeasure L := statisticEntropyLift_probability μ F (Q.map F)
  let P := L.map E
  haveI : IsProbabilityMeasure P := Measure.isProbabilityMeasure_map hE.aemeasurable
  have hLU : L.map U=Q.map U := by
    have he : U=g ∘ F := funext hUof
    rw [he,←Measure.map_map hg hF,statisticEntropyLift_map μ hF (Q.map F) hQD,
      Measure.map_map hg hF]
  have hPF : P.fst=Q.map U := by
    change (L.map E).map Prod.fst=Q.map U
    rw [Measure.map_map measurable_fst hE]
    exact hLU
  have hμU : μ.map U=μA := by
    have hh := congrArg Measure.fst hprod
    change (μ.map E).map Prod.fst=_ at hh
    rw [Measure.map_map measurable_fst hE,Measure.fst_prod] at hh
    exact hh
  have hcostF : klDiv (Q.map F) (μ.map F)≤klDiv (Q.map U) μA := by
    have he : F=f ∘ U := funext hFof
    rw [he,←Measure.map_map hf hU,←Measure.map_map hf hU,hμU]
    exact klDiv_map_le (Q.map U) μA hf
  have hfinite : klDiv P.fst μA≠∞ := by
    rw [hPF,←hμU]
    exact ne_top_of_le_ne_top hQ (klDiv_map_le Q μ hU)
  have hcost : klDiv P (μA.prod μB)≤klDiv P.fst μA := by
    have hd := klDiv_map_le L μ hE
    rw [hprod,statisticEntropyLift_kl μ hF (Q.map F) hQD] at hd
    exact hd.trans (by rw [hPF]; exact hcostF)
  change P=(Q.map U).prod μB
  rw [probability_eq_product_of_kl_le P μA μB hfinite hcost,hPF]

#print axioms statisticEntropyLift_product_coordinates
end ConditionalNonpolynomial.Analytic
