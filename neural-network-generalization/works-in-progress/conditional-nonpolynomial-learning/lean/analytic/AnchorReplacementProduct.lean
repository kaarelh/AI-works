import AnchorReplacement

/-! A Gaussian innovation which is independent of the reference anchors
stays independent after replacing only the anchor marginal. The proof uses
entropy minimality and the product chain rule, avoiding regularity assumptions
on conditional densities. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy
variable {A B : Type*} [MeasurableSpace A] [MeasurableSpace B]
  [StandardBorelSpace A] [StandardBorelSpace B] [Nonempty A] [Nonempty B]

theorem anchorReplacement_product_map
    (Q G : Measure (A × B)) [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G≠∞) (ν : Measure B) [IsProbabilityMeasure ν]
    (F : A × B → A × B) (hF : Measurable F) (hfirst : ∀p,(F p).1=p.1)
    (hprod : G.map F=G.fst.prod ν) :
    (anchorReplacement Q G).map F=Q.fst.prod ν := by
  let R := (anchorReplacement Q G).map F
  haveI : IsProbabilityMeasure R := Measure.isProbabilityMeasure_map hF.aemeasurable
  have hRF : R.fst=Q.fst := by
    change ((anchorReplacement Q G).map F).map Prod.fst=Q.fst
    rw [Measure.map_map measurable_fst hF]
    have he : Prod.fst ∘ F=Prod.fst := funext hfirst
    rw [he]
    exact anchorReplacement_fst Q G
  have ha := klDiv_map_le Q G measurable_fst
  have hf : klDiv Q.fst G.fst≠∞ := ne_top_of_le_ne_top hKL ha
  have hd := klDiv_map_le (anchorReplacement Q G) G hF
  rw [hprod,anchorReplacement_kl] at hd
  change klDiv R (G.fst.prod ν)≤klDiv Q.fst G.fst at hd
  have hc := klDiv_compProd_eq_add R.fst G.fst R.condKernel (Kernel.const A ν)
  rw [Measure.disintegrate R R.condKernel,Measure.compProd_const,Measure.compProd_const,hRF] at hc
  have hz : klDiv R (Q.fst.prod ν)=0 := by
    rw [hc] at hd
    apply le_antisymm _ (zero_le)
    exact (ENNReal.add_le_add_iff_left hf).mp (by simpa only [add_zero] using hd)
  exact klDiv_eq_zero_iff.mp hz

theorem anchorReplacement_ae_of_reference
    (Q G : Measure (A × B)) [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G≠∞) (p : A × B → Prop) (hp : ∀ᵐz ∂G,p z) :
    (∀ᵐz ∂Q,p z) ∧ ∀ᵐz ∂anchorReplacement Q G,p z := by
  have hQ := (klDiv_ne_top_iff.mp hKL).1
  have ha := klDiv_map_le Q G measurable_fst
  have hf : klDiv (anchorReplacement Q G) G≠∞ := by
    rw [anchorReplacement_kl]
    exact ne_top_of_le_ne_top hKL ha
  exact ⟨hQ hp,(klDiv_ne_top_iff.mp hf).1 hp⟩

#print axioms anchorReplacement_product_map
#print axioms anchorReplacement_ae_of_reference
end ConditionalNonpolynomial.Analytic
