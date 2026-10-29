import InitialSeedNetwork
import FiniteNetworkChannelMass

/-! A literal finite-width NN construction from an iid seed, a finite adaptive
scalar-control program, and the final shifted readout. The source keeps all
auxiliary scores; the final map returns ordinary network weights. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

abbrev ChannelInitial (Ω : Type) (N : ℕ) := (Fin N→Ω)×(Fin N→ℝ)
abbrev ChannelHistory (Ω Ξ : Type) (N r : ℕ) :=
  ControlHistory (ChannelInitial Ω N) (GaussianControlRow Ξ (Fin N) N) r

def channelHistoryLaw {Ω Ξ : Type} [MeasurableSpace Ω] [MeasurableSpace Ξ]
    (N r : ℕ) (Q₀ : Measure Ω) (Q : ℕ→Measure Ξ) : Measure (ChannelHistory Ω Ξ N r) :=
  controlHistoryLaw (initialSeedLaw N Q₀) (fun j=>gaussianControlRowLaw N (Q j)) r

instance channelHistoryLaw_probability {Ω Ξ : Type} [MeasurableSpace Ω] [MeasurableSpace Ξ]
    (N r : ℕ) (Q₀ : Measure Ω) (Q : ℕ→Measure Ξ)
    [IsProbabilityMeasure Q₀] [∀n,IsProbabilityMeasure (Q n)] :
    IsProbabilityMeasure (channelHistoryLaw N r Q₀ Q) := by unfold channelHistoryLaw; infer_instance

def channelHiddenNetwork {Ω Ξ : Type} {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ) (r : ℕ) :
    ChannelHistory Ω Ξ N r→Weights d N r :=
  networkHistoryWeights σ r ∘ gaussianHistoryMap (initialSeedNetwork σ seed) Z u r

theorem channelHiddenNetwork_reference {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ} (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (P₀ : Measure Ω) [IsProbabilityMeasure P₀]
    (P : ℕ→Measure Ξ) [∀n,IsProbabilityMeasure (P n)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (hseedlaw : P₀.map seed=Measure.pi fun _ : Fin (d+1)=>gaussianReal 0 (((N:ℝ)/d)*σ^2).toNNReal)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j)) (hPlaw : ∀j,(P j).map (Z j)=gaussianReal 0 1)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (hu : ∀j,Measurable (u j)) (hnorm : ∀j h,∑i,u j h i^2=1) (r : ℕ) :
    MeasurePreserving (channelHiddenNetwork σ seed Z u r) (channelHistoryLaw N r P₀ P)
      (smallPrior d N r σ) :=
  gaussianNetwork_reference P (initialSeedLaw N P₀) hσ _
    (initialSeedNetwork_reference hN P₀ σ seed hseed hseedlaw) Z hZ hPlaw u hu hnorm r

theorem channelHistoryLaw_kl {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ω] [StandardBorelSpace Ξ]
    [Nonempty Ω] [Nonempty Ξ] (N r : ℕ)
    (Q₀ P₀ : Measure Ω) [IsProbabilityMeasure Q₀] [IsProbabilityMeasure P₀]
    (Q P : ℕ→Measure Ξ) [∀n,IsProbabilityMeasure (Q n)] [∀n,IsProbabilityMeasure (P n)] :
    klDiv (channelHistoryLaw N r Q₀ Q) (channelHistoryLaw N r P₀ P)=
      N*(klDiv Q₀ P₀+∑j : Fin r,klDiv (Q j) (P j)) := by
  unfold channelHistoryLaw
  rw [gaussianControlHistory_kl,initialSeedLaw_kl,mul_add]

theorem channelHistoryLaw_entropy {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ω] [StandardBorelSpace Ξ]
    [Nonempty Ω] [Nonempty Ξ] (N r : ℕ)
    (Q₀ P₀ : Measure Ω) [IsProbabilityMeasure Q₀] [IsProbabilityMeasure P₀]
    (Q P : ℕ→Measure Ξ) [∀n,IsProbabilityMeasure (Q n)] [∀n,IsProbabilityMeasure (P n)]
    (h₀ : klDiv Q₀ P₀≠∞) (hQ : ∀j : Fin r,klDiv (Q j) (P j)≠∞) :
    klDiv (channelHistoryLaw N r Q₀ Q) (channelHistoryLaw N r P₀ P)≠∞ ∧
    (klDiv (channelHistoryLaw N r Q₀ Q) (channelHistoryLaw N r P₀ P)).toReal=
      (N:ℝ)*((klDiv Q₀ P₀).toReal+∑j : Fin r,(klDiv (Q j) (P j)).toReal) := by
  have hs : (∑j : Fin r,klDiv (Q j) (P j))≠∞ :=
    ENNReal.sum_ne_top.mpr (fun j _=>hQ j)
  have ha := ENNReal.add_ne_top.mpr ⟨h₀,hs⟩
  rw [channelHistoryLaw_kl]
  constructor
  · exact ENNReal.mul_ne_top (by simp) ha
  · rw [ENNReal.toReal_mul,ENNReal.toReal_natCast,ENNReal.toReal_add h₀ hs,
      ENNReal.toReal_sum (fun j _=>hQ j)]

def finiteChannelNetwork {Ω Ξ : Type} {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ) (r : ℕ)
    (uout : ChannelHistory Ω Ξ N r→Fin N→ℝ) :
    ChannelHistory Ω Ξ N r×(ℝ×(Fin N→ℝ))→Weights d N r :=
  networkWithReadoutChannel σ (channelHiddenNetwork σ seed Z u r) uout

theorem finiteChannelNetwork_reference {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ} (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (P₀ : Measure Ω) [IsProbabilityMeasure P₀]
    (P : ℕ→Measure Ξ) [∀n,IsProbabilityMeasure (P n)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (hseedlaw : P₀.map seed=Measure.pi fun _ : Fin (d+1)=>gaussianReal 0 (((N:ℝ)/d)*σ^2).toNNReal)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j)) (hPlaw : ∀j,(P j).map (Z j)=gaussianReal 0 1)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (hu : ∀j,Measurable (u j)) (hnorm : ∀j h,∑i,u j h i^2=1) (r : ℕ)
    (uout : ChannelHistory Ω Ξ N r→Fin N→ℝ)
    (hout : Measurable uout) (houtnorm : ∀h,∑i,uout h i^2=1) :
    MeasurePreserving (finiteChannelNetwork σ seed Z u r uout)
      ((channelHistoryLaw N r P₀ P).prod (readoutControlLaw N 0)) (smallPrior d N r σ) :=
  networkWithReadoutChannel_reference hN σ _ _
    (channelHiddenNetwork_reference hN hσ P₀ P seed hseed hseedlaw Z hZ hPlaw u hu hnorm r)
    uout hout houtnorm

/-- A successful concrete finite channel gives a raw event-mass lower bound
under the exact original NN prior, with no loss in the leading energy cost. -/
theorem finiteChannelNetwork_raw_mass {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ω] [StandardBorelSpace Ξ]
    [Nonempty Ω] [Nonempty Ξ] {d N : ℕ} (hN : 0<N) {σ : ℝ} (hσ : 0<σ)
    (Q₀ P₀ : Measure Ω) [IsProbabilityMeasure Q₀] [IsProbabilityMeasure P₀]
    (Q P : ℕ→Measure Ξ) [∀n,IsProbabilityMeasure (Q n)] [∀n,IsProbabilityMeasure (P n)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (hseedlaw : P₀.map seed=Measure.pi fun _ : Fin (d+1)=>gaussianReal 0 (((N:ℝ)/d)*σ^2).toNNReal)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j)) (hPlaw : ∀j,(P j).map (Z j)=gaussianReal 0 1)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (hu : ∀j,Measurable (u j)) (hnorm : ∀j h,∑i,u j h i^2=1) (r : ℕ)
    (uout : ChannelHistory Ω Ξ N r→Fin N→ℝ)
    (hout : Measurable uout) (houtnorm : ∀h,∑i,uout h i^2=1)
    (h₀ : klDiv Q₀ P₀≠∞) (hQ : ∀j : Fin r,klDiv (Q j) (P j)≠∞)
    (E : Set (Weights d N r)) (hE : MeasurableSet E) (μ : ℝ)
    {A τ κ : ℝ} (hA : 0≤A) (hτ : 0<τ) (hκ0 : 0≤κ) (hκ : κ≤τ/(4*(A+τ)))
    (hsuccess : 1-κ≤((channelHistoryLaw N r Q₀ Q).prod (readoutControlLaw N μ)).real
      (finiteChannelNetwork σ seed Z u r uout ⁻¹' E))
    (hcost : (N:ℝ)*((klDiv Q₀ P₀).toReal+∑j : Fin r,(klDiv (Q j) (P j)).toReal)+μ^2/2
      ≤(N:ℝ)*(A+τ/4)) (hwidth : Real.log 2≤(N:ℝ)*τ/4) :
    Real.exp (-(N:ℝ)*(A+τ))≤(smallPrior d N r σ).real E := by
  have href := channelHiddenNetwork_reference hN hσ P₀ P seed hseed hseedlaw Z hZ hPlaw u hu hnorm r
  obtain ⟨hfinite,hentropy⟩ := channelHistoryLaw_entropy N r Q₀ P₀ Q P h₀ hQ
  apply finite_network_channel_mass_with_slack hN σ μ
    (channelHistoryLaw N r Q₀ Q) (channelHistoryLaw N r P₀ P)
    (channelHiddenNetwork σ seed Z u r) href uout hout houtnorm E hE
    hfinite hA hτ hκ0 hκ hsuccess
  · rwa [hentropy]
  · exact hwidth

#print axioms finiteChannelNetwork_reference
#print axioms channelHistoryLaw_entropy
#print axioms finiteChannelNetwork_raw_mass
end ConditionalNonpolynomial.Analytic
