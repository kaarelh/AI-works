import NetworkReadoutPlanting
import NeuralGeneralization.NetworkInputSplit

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.GaussianAngularFields

def smallInputPrior (d N : ℕ) (σ : ℝ) : Measure (Fin N×Fin (d+1)→ℝ) :=
  Measure.pi fun _=>gaussianReal 0 (((N:ℝ)/d)*σ^2).toNNReal

instance smallInputPrior_probability (d N : ℕ) (σ : ℝ) :
    IsProbabilityMeasure (smallInputPrior d N σ) := by unfold smallInputPrior; infer_instance

theorem smallPrior_input_split (d N : ℕ) (σ : ℝ) :
    MeasurePreserving (NeuralGeneralization.NetworkInputSplit.split d N) (smallPrior d N 0 σ)
      ((smallInputPrior d N σ).prod
        (NeuralGeneralization.BatchTwoContinuous.PairMoments.smallReadoutPrior N σ)) := by
  let μ : WeightIndex d N 0→Measure ℝ := fun i=>gaussianReal 0 (smallVariance d N 0 σ i).toNNReal
  have h1 := measurePreserving_piCongrLeft (α:=fun _ : WeightIndex d N 0=>ℝ) μ
    (NeuralGeneralization.NetworkInputSplit.indexJoin d N)
  have h2 := measurePreserving_sumPiEquivProdPi_symm
    (fun i=>μ (NeuralGeneralization.NetworkInputSplit.indexJoin d N i))
  have hs : MeasurePreserving (NeuralGeneralization.NetworkInputSplit.split d N).symm
      ((smallInputPrior d N σ).prod
        (NeuralGeneralization.BatchTwoContinuous.PairMoments.smallReadoutPrior N σ))
      (smallPrior d N 0 σ) := h1.comp h2
  exact hs.symm

def seedInputMatrix {Ω : Type*} {d N : ℕ} (F : Ω→Fin (d+1)→ℝ)
    (w : Fin N→Ω) : Fin N×Fin (d+1)→ℝ := fun ij=>F (w ij.1) ij.2

theorem seedInputMatrix_reference {Ω : Type*} [MeasurableSpace Ω] {d N : ℕ}
    (P : Measure Ω) [IsProbabilityMeasure P] (σ : ℝ)
    (F : Ω→Fin (d+1)→ℝ) (hF : Measurable F)
    (hrow : P.map F=Measure.pi fun _ : Fin (d+1)=>gaussianReal 0 (((N:ℝ)/d)*σ^2).toNNReal) :
    MeasurePreserving (seedInputMatrix (N:=N) F) (Measure.pi fun _ : Fin N=>P)
      (smallInputPrior d N σ) := by
  have hrows : MeasurePreserving (fun w : Fin N→Ω=>fun i=>F (w i))
      (Measure.pi fun _ : Fin N=>P)
      (Measure.pi fun _ : Fin N=>Measure.pi fun _ : Fin (d+1)=>
        gaussianReal 0 (((N:ℝ)/d)*σ^2).toNNReal) := by
    refine ⟨by fun_prop,?_⟩
    rw [Measure.pi_map_pi (fun _=>hF.aemeasurable)]
    simp only [hrow]
  exact (NeuralGeneralization.LayerGramConcentration.measurePreserving_uncurry
    (fun (_ : Fin N) (_ : Fin (d+1))=>gaussianReal 0 (((N:ℝ)/d)*σ^2).toNNReal)).comp hrows

def initialSeedNetwork {Ω : Type*} {d N : ℕ} (σ : ℝ) (F : Ω→Fin (d+1)→ℝ)
    (p : (Fin N→Ω)×(Fin N→ℝ)) : Weights d N 0 :=
  (NeuralGeneralization.NetworkInputSplit.split d N).symm
    (seedInputMatrix F p.1,physicalReadout σ p.2)

def initialSeedLaw {Ω : Type*} [MeasurableSpace Ω] (N : ℕ) (P : Measure Ω) :
    Measure ((Fin N→Ω)×(Fin N→ℝ)) :=
  (Measure.pi fun _ : Fin N=>P).prod (standardLaw (Fin N))

instance initialSeedLaw_probability {Ω : Type*} [MeasurableSpace Ω]
    (N : ℕ) (P : Measure Ω) [IsProbabilityMeasure P] :
    IsProbabilityMeasure (initialSeedLaw N P) := by unfold initialSeedLaw; infer_instance

theorem initialSeedNetwork_reference {Ω : Type*} [MeasurableSpace Ω] {d N : ℕ}
    (hN : 0<N) (P : Measure Ω) [IsProbabilityMeasure P] (σ : ℝ)
    (F : Ω→Fin (d+1)→ℝ) (hF : Measurable F)
    (hrow : P.map F=Measure.pi fun _ : Fin (d+1)=>gaussianReal 0 (((N:ℝ)/d)*σ^2).toNNReal) :
    MeasurePreserving (initialSeedNetwork σ F) (initialSeedLaw N P) (smallPrior d N 0 σ) :=
  (smallPrior_input_split d N σ).symm.comp
    ((seedInputMatrix_reference P σ F hF hrow).prod (physicalReadout_reference hN σ))

theorem initialSeedLaw_kl {Ω : Type*} [MeasurableSpace Ω] [StandardBorelSpace Ω] [Nonempty Ω]
    (N : ℕ) (Q P : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure P] :
    klDiv (initialSeedLaw N Q) (initialSeedLaw N P)=N*klDiv Q P := by
  rw [initialSeedLaw,initialSeedLaw,product_control_kl,klDiv_self,add_zero,iid_control_kl]

#print axioms initialSeedNetwork_reference
#print axioms initialSeedLaw_kl
end ConditionalNonpolynomial.Analytic
