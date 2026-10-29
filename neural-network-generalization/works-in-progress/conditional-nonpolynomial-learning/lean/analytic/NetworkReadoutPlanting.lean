import NetworkHistoryPrior
import ReadoutControlLaw
import NeuralGeneralization.BatchTwoContinuousPairMomentsSplit

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.NetworkReadout
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.BatchTwoContinuous.PairMoments

def physicalReadout {N : ℕ} (σ : ℝ) (z : Fin N→ℝ) : Fin N→ℝ :=
  fun i=>σ/Real.sqrt N*z i

theorem physicalReadout_reference {N : ℕ} (hN : 0<N) (σ : ℝ) :
    MeasurePreserving (physicalReadout (N:=N) σ) (standardLaw (Fin N))
      (smallReadoutPrior N σ) := by
  have hm : Measurable (physicalReadout (N:=N) σ) := by unfold physicalReadout; fun_prop
  refine ⟨hm,?_⟩
  unfold physicalReadout standardLaw smallReadoutPrior
  rw [Measure.pi_map_pi (f:=fun (_ : Fin N) (z : ℝ)=>σ/Real.sqrt N*z)
    (fun _=>(show Measurable (fun z : ℝ=>σ/Real.sqrt N*z) by fun_prop).aemeasurable)]
  congr 1
  funext i
  rw [gaussianReal_map_const_mul,mul_zero]
  congr 1
  apply NNReal.coe_injective
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  simp only [NNReal.coe_mul,NNReal.coe_mk,NNReal.coe_one,mul_one,
    Real.coe_toNNReal _ (show 0≤σ^2/(N:ℝ) by positivity)]
  rw [div_pow,Real.sq_sqrt hn.le]

/-- Replace the initial dummy readout by the final adaptive scalar channel.
Only the hidden coordinates of the previously planted network are retained. -/
def networkWithReadoutChannel {H : Type*} {d N r : ℕ}
    (σ : ℝ) (F : H→Weights d N r) (u : H→Fin N→ℝ)
    (p : H×(ℝ×(Fin N→ℝ))) : Weights d N r :=
  assemble ((weightSplit d N r (F p.1)).1)
    (physicalReadout σ (directionSplit (u p.1) p.2.1 p.2.2))

theorem networkWithReadoutChannel_reference {H : Type*} [MeasurableSpace H]
    {d N r : ℕ} (hN : 0<N) (σ : ℝ)
    (P : Measure H) [IsProbabilityMeasure P]
    (F : H→Weights d N r) (hF : MeasurePreserving F P (smallPrior d N r σ))
    (u : H→Fin N→ℝ) (hu : Measurable u) (hnorm : ∀h,∑i,u h i^2=1) :
    MeasurePreserving (networkWithReadoutChannel σ F u)
      (P.prod (readoutControlLaw N 0)) (smallPrior d N r σ) := by
  have hh : MeasurePreserving (fun h=>(weightSplit d N r (F h)).1)
      P (smallHiddenPrior d N r σ) :=
    measurePreserving_fst.comp ((smallPrior_weightSplit d N r σ).comp hF)
  have hadapt := adaptive_readout_reference P (smallHiddenPrior d N r σ)
    _ hh u hu hnorm
  have hphysical := (MeasurePreserving.id (smallHiddenPrior d N r σ)).prod
    (physicalReadout_reference hN σ)
  have hassemble := (smallPrior_weightSplit d N r σ).symm
  convert hassemble.comp (hphysical.comp hadapt) using 1
  funext p
  simp only [networkWithReadoutChannel,Function.comp_apply,Prod.map_apply,id_eq,weightSplit_symm]

/-- The actual finite-network entropy, with its adaptive final readout,
has exactly the expected additive scalar Gaussian shift cost. -/
theorem networkWithReadoutChannel_kl {H : Type*}
    [MeasurableSpace H] [StandardBorelSpace H] [Nonempty H]
    {d N r : ℕ} (hN : 0<N) (σ μ : ℝ)
    (Q P : Measure H) [IsProbabilityMeasure Q] [IsProbabilityMeasure P]
    (F : H→Weights d N r) (hF : MeasurePreserving F P (smallPrior d N r σ))
    (u : H→Fin N→ℝ) (hu : Measurable u) (hnorm : ∀h,∑i,u h i^2=1) :
    klDiv ((Q.prod (readoutControlLaw N μ)).map (networkWithReadoutChannel σ F u))
      (smallPrior d N r σ) ≤ klDiv Q P+ENNReal.ofReal (μ^2/2) := by
  have href := networkWithReadoutChannel_reference hN σ P F hF u hu hnorm
  rw [←href.map_eq]
  have hh := mapped_product_control_kl Q P (readoutControlLaw N μ) (readoutControlLaw N 0)
    (networkWithReadoutChannel σ F u) href.measurable
  simpa only [readoutControlLaw_kl] using hh

#print axioms networkWithReadoutChannel_reference
#print axioms networkWithReadoutChannel_kl
end ConditionalNonpolynomial.Analytic
