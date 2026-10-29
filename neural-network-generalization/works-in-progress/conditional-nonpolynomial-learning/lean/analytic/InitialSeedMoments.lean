import ChannelNetworkRecursion
import ScalarChannelConcentration

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel

def initialSeedMomentEvent {Ω : Type} [MeasurableSpace Ω] {d N : ℕ}
    (Q : Measure Ω) (b : Ω→ℝ) (seed : Ω→Fin (d+1)→ℝ) (α : ℝ) :
    Set (ChannelInitial Ω N) :=
  Prod.fst ⁻¹' finiteMomentEvent Q (channelObservables b (seedFeature seed)) α N

theorem seedFeature_measurable {Ω : Type} [MeasurableSpace Ω] {d : ℕ}
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed) (x : Cube d) :
    Measurable (seedFeature seed x) := by unfold seedFeature; fun_prop

theorem seedFeature_bound {Ω : Type} {d : ℕ} (seed : Ω→Fin (d+1)→ℝ)
    (x : Cube d) (z : Ω) : |seedFeature seed x z|≤1 := (Real.abs_tanh_lt_one _).le

theorem measurableSet_initialSeedMomentEvent {Ω : Type} [MeasurableSpace Ω] {d N : ℕ}
    (Q : Measure Ω) (b : Ω→ℝ) (hb : Measurable b)
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed) (α : ℝ) :
    MeasurableSet (initialSeedMomentEvent (N:=N) Q b seed α) :=
  (measurableSet_finiteMomentEvent Q _
    (channelObservables_measurable b (seedFeature seed) hb (seedFeature_measurable seed hseed)) α N).preimage
    measurable_fst

/-- The source's independent dummy readout has no effect on the seed event. -/
theorem initialSeedMomentEvent_probability {Ω : Type} [MeasurableSpace Ω] {d N : ℕ}
    (hN : 0<N) (Q : Measure Ω) [IsProbabilityMeasure Q]
    (b : Ω→ℝ) (hb : Measurable b) (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    {B α κ : ℝ} (hB : 1≤B) (hbB : ∀z,|b z|≤B) (hα : 0<α)
    (hwidth : (1+2*(Fintype.card (Cube d):ℝ))*B^4≤κ*((N:ℝ)*α^2)) :
    1-κ≤(initialSeedLaw N Q).real (initialSeedMomentEvent Q b seed α) := by
  have hh := scalar_channel_moment_probability Q b (seedFeature seed) hb
    (seedFeature_measurable seed hseed) hB hbB (seedFeature_bound seed) hN hα hwidth
  have hm := measurableSet_finiteMomentEvent Q _
    (channelObservables_measurable b (seedFeature seed) hb (seedFeature_measurable seed hseed)) α N
  have hmap : (initialSeedLaw N Q).map Prod.fst=Measure.pi fun _ : Fin N=>Q :=
    measurePreserving_fst.map_eq
  rw [←hmap] at hh
  simpa only [Measure.real,Measure.map_apply measurable_fst hm,initialSeedMomentEvent] using hh

#print axioms initialSeedMomentEvent_probability
end ConditionalNonpolynomial.Analytic
