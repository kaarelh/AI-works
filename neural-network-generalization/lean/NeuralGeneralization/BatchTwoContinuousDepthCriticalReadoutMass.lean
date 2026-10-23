import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductReadout
import NeuralGeneralization.BatchTwoContinuousDepthCriticalProductMeasure

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1200000
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel NetworkReadout TowerNetwork BatchTwoContinuous.PairMoments

variable {d N r : ℕ}

theorem smallPrior_withReadout_preserving (σ : ℝ) :
    MeasurePreserving (fun p : Weights d N r×(Fin N→ℝ)=>withReadout p.1 p.2)
      ((smallPrior d N r σ).prod (smallReadoutPrior N σ)) (smallPrior d N r σ) := by
  have hs := smallPrior_weightSplit d N r σ
  have hh := (measurePreserving_fst (μ:=smallHiddenPrior d N r σ) (ν:=smallReadoutPrior N σ)).comp hs
  have hp := hh.prod (MeasurePreserving.id (smallReadoutPrior N σ))
  have h := (MeasurePreserving.symm (weightSplit d N r) hs).comp hp
  convert h using 1
  funext p
  ext i
  rcases i with ij | (sij | j) <;> rfl

theorem smallPrior_readout_event_lower (σ : ℝ)
    (A B : Set (Weights d N r)) (hA : MeasurableSet A) (hB : MeasurableSet B)
    {p : ℝ} (hp : 0≤p)
    (hsection : ∀w∈A,p≤(smallReadoutPrior N σ).real {v | withReadout w v∈B}) :
    (smallPrior d N r σ).real A*p≤(smallPrior d N r σ).real B := by
  have hm := smallPrior_withReadout_preserving (d:=d) (N:=N) (r:=r) σ
  have hh := product_event_real_lower (smallPrior d N r σ) (smallReadoutPrior N σ)
    A ((fun p : Weights d N r×(Fin N→ℝ)=>withReadout p.1 p.2)⁻¹' B)
    hA (hB.preimage hm.measurable) hp hsection
  rwa [←map_measureReal_apply hm.measurable hB,hm.map_eq] at hh

#print axioms smallPrior_readout_event_lower
end NeuralGeneralization.BatchTwoContinuousDepthCritical
