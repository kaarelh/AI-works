import FiniteChannelConstruction
import NeuralGeneralization.TowerNetwork

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.TowerNetwork

def seedFeature {Ω : Type} {d : ℕ} (seed : Ω→Fin (d+1)→ℝ)
    (x : Cube d) (z : Ω) : ℝ := Real.tanh (∑j,seed z j*inputVector x j)

def channelFeatures {Ω Ξ : Type} {d N : ℕ} (σ : ℝ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (x : Cube d) : Fin N→ℝ :=
  finalHidden Real.tanh (channelHiddenNetwork σ seed Z u r h) x

theorem channelHiddenNetwork_succ {Ω Ξ : Type} {d N : ℕ} (σ : ℝ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (w : GaussianControlRow Ξ (Fin N) N) :
    channelHiddenNetwork σ seed Z u (r+1) (h,w)=
      appendLayer (channelHiddenNetwork σ seed Z u r h)
        (fun i j=>σ*directionSplit (u r h) (Z r (w i).1) (w i).2 j) := by
  change (NeuralGeneralization.NetworkLayerSplit.split d N r).symm
    (channelHiddenNetwork σ seed Z u r h,
      physicalMatrix σ (directionSplitRows (Z r) (u r h) w))=_
  rw [NeuralGeneralization.NetworkLayerSplit.split_symm_apply]
  rfl

theorem channelFeatures_zero {Ω Ξ : Type} {d N : ℕ} (σ : ℝ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (h : ChannelInitial Ω N) (x : Cube d) (i : Fin N) :
    channelFeatures σ seed Z u 0 h x i=seedFeature seed x (h.1 i) := rfl

def channelRowFeature {Ω Ξ : Type} {d N : ℕ} (σ : ℝ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (x : Cube d)
    (p : Ξ×(Fin N→ℝ)) : ℝ :=
  Real.tanh (∑j,σ*directionSplit (u r h) (Z r p.1) p.2 j*
    channelFeatures σ seed Z u r h x j)

theorem channelFeatures_succ {Ω Ξ : Type} {d N : ℕ} (σ : ℝ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (w : GaussianControlRow Ξ (Fin N) N)
    (x : Cube d) (i : Fin N) :
    channelFeatures σ seed Z u (r+1) (h,w) x i=channelRowFeature σ seed Z u r h x (w i) := by
  unfold channelFeatures
  rw [channelHiddenNetwork_succ,finalHidden_appendLayer]
  rfl

theorem initialSeedNetwork_measurable {Ω : Type} [MeasurableSpace Ω] {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed) :
    Measurable (initialSeedNetwork (N:=N) σ seed) := by
  unfold initialSeedNetwork
  apply (NeuralGeneralization.NetworkInputSplit.split d N).symm.measurable.comp
  unfold seedInputMatrix physicalReadout
  fun_prop

theorem channelHiddenNetwork_measurable {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (hu : ∀j,Measurable (u j)) (r : ℕ) :
    Measurable (channelHiddenNetwork σ seed Z u r) :=
  (networkHistoryWeights_measurable σ r).comp
    (gaussianHistoryMap_measurable _ (initialSeedNetwork_measurable σ seed hseed) Z hZ u hu r)

theorem channelFeatures_measurable {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (hu : ∀j,Measurable (u j)) (r : ℕ) (x : Cube d) :
    Measurable (fun h=>channelFeatures σ seed Z u r h x) := by
  apply measurable_pi_lambda
  intro i
  exact (continuous_finalHidden NeuralGeneralization.TanhDifferential.continuous_tanh x i).measurable.comp
    (channelHiddenNetwork_measurable σ seed hseed Z hZ u hu r)

theorem channelRowFeature_measurable {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (hu : ∀j,Measurable (u j)) (r : ℕ) (x : Cube d) :
    Measurable (fun p : ChannelHistory Ω Ξ N r×(Ξ×(Fin N→ℝ))=>
      channelRowFeature σ seed Z u r p.1 x p.2) := by
  have hfeatures := channelFeatures_measurable σ seed hseed Z hZ u hu r x
  unfold channelRowFeature directionSplit
  fun_prop

theorem channelRowFeature_bound {Ω Ξ : Type} {d N : ℕ} (σ : ℝ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (x : Cube d) (p : Ξ×(Fin N→ℝ)) :
    |channelRowFeature σ seed Z u r h x p|≤1 := (Real.abs_tanh_lt_one _).le

#print axioms channelFeatures_succ
#print axioms channelRowFeature_measurable
end ConditionalNonpolynomial.Analytic
