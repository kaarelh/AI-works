import NeuralGeneralization.BatchTwoActivationFullNetworkEventsLaw
import NeuralGeneralization.BatchTwoContinuousPairMomentsSplit

/-! Multiplication of genuine conditional event probabilities under the actual
independent Gaussian network blocks. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1400000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel BatchTwoActivation NetworkLayerSplit TowerNetwork

/-- A measurable event with uniformly large sections above a measurable set
has at least the product mass. No measurable selection is involved. -/
theorem product_event_real_lower {X Y : Type*} [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (ν : Measure Y) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (A : Set X) (B : Set (X×Y)) (hA : MeasurableSet A) (hB : MeasurableSet B)
    {p : ℝ} (hp : 0≤p) (hsection : ∀ x∈A,p≤ν.real {y | (x,y)∈B}) :
    μ.real A*p≤(μ.prod ν).real B := by
  have hbound : μ A*ENNReal.ofReal p≤(μ.prod ν) B := by
    rw [Measure.prod_apply hB]
    calc
      μ A*ENNReal.ofReal p = ∫⁻x,A.indicator (fun _=>ENNReal.ofReal p) x ∂μ := by
        rw [lintegral_indicator hA,lintegral_const]
        simp [mul_comm]
      _ ≤ _ := by
        apply lintegral_mono
        intro x
        by_cases hx : x∈A
        · rw [indicator_of_mem hx]
          exact (ENNReal.ofReal_le_iff_le_toReal (measure_ne_top _ _)).2 (hsection x hx)
        · rw [indicator_of_notMem hx]
          exact zero_le
  have hh := ENNReal.toReal_mono (measure_ne_top (μ.prod ν) B) hbound
  simpa only [ENNReal.toReal_mul,ENNReal.toReal_ofReal hp,Measure.real] using hh

theorem smallPrior_append_event_lower {d N r : ℕ} (σ : ℝ)
    (A : Set (Weights d N r)) (B : Set (Weights d N (r+1)))
    (hA : MeasurableSet A) (hB : MeasurableSet B) {p : ℝ} (hp : 0≤p)
    (htransition : ∀ w∈A,p≤(activationMatrixPrior N σ).real
      {a | appendLayer w (fun i j=>a (i,j))∈B}) :
    (smallPrior d N r σ).real A*p≤(smallPrior d N (r+1) σ).real B := by
  have hs := MeasurePreserving.symm (split d N r) (activationSmallPrior_split d N r σ)
  have hm := hB.preimage hs.measurable
  have hh := product_event_real_lower (smallPrior d N r σ) (activationMatrixPrior N σ)
    A ((split d N r).symm ⁻¹' B) hA hm hp (by
      intro w hw
      simpa only [mem_preimage,split_symm_apply] using htransition w hw)
  have he : ((smallPrior d N r σ).prod (activationMatrixPrior N σ)).real
      ((split d N r).symm ⁻¹' B)=(smallPrior d N (r+1) σ).real B := by
    rw [←hs.map_eq,map_measureReal_apply hs.measurable hB]
  rwa [he] at hh

/-- Finite products of uniform adaptive transition probabilities under the
literal full network law (the readout is carried independently). -/
theorem smallPrior_event_chain_lower {d N : ℕ} (σ : ℝ)
    (A : (r : ℕ)→Set (Weights d N r)) (hA : ∀r,MeasurableSet (A r))
    (p : ℕ→ℝ) (hp : ∀r,0≤p r) {a : ℝ} (ha : 0≤a)
    (hseed : a≤(smallPrior d N 0 σ).real (A 0))
    (htransition : ∀r,∀w∈A r,p r≤(activationMatrixPrior N σ).real
      {b | appendLayer w (fun i j=>b (i,j))∈A (r+1)}) (r : ℕ) :
    a*(∏s∈Finset.range r,p s)≤(smallPrior d N r σ).real (A r) := by
  induction r with
  | zero => simpa using hseed
  | succ r ih =>
    rw [Finset.prod_range_succ,←mul_assoc]
    exact (mul_le_mul_of_nonneg_right ih (hp r)).trans
      (smallPrior_append_event_lower σ (A r) (A (r+1)) (hA r) (hA (r+1)) (hp r) (htransition r))

end NeuralGeneralization.BatchTwoContinuousDepthCritical
