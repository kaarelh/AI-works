import ChannelNetworkRecursion
import InitialSeedMoments
import SplitRowChannelError
import ScalarChannelHistorySuccess
import ScalarChannelErrorBudget

/-! The concrete score direction and scalar state of the planted critical
network. These are functions of actual finite network histories. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def channelScoreArray {Ω Ξ : Type} {N : ℕ} (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) :
    (r : ℕ)→ChannelHistory Ω Ξ N r→Fin N→ℝ
  | 0,h => fun i=>b₀ (h.1 i)
  | r+1,h => fun i=>b r (h.2 i).1

theorem channelScoreArray_measurable {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {N : ℕ}
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : Measurable b₀) (hb : ∀r,Measurable (b r))
    (r : ℕ) : Measurable (channelScoreArray (N:=N) b₀ b r) := by
  cases r <;> unfold channelScoreArray <;> fun_prop

def channelScoreDirection {Ω Ξ : Type} {N : ℕ} (hN : 0<N)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (r : ℕ) (h : ChannelHistory Ω Ξ N r) : Fin N→ℝ :=
  scoreUnit hN (channelScoreArray b₀ b r h)

theorem channelScoreDirection_measurable {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {N : ℕ} (hN : 0<N)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : Measurable b₀) (hb : ∀r,Measurable (b r))
    (r : ℕ) : Measurable (channelScoreDirection hN b₀ b r) :=
  (scoreUnit_measurable hN).comp (channelScoreArray_measurable b₀ b hb₀ hb r)

theorem channelScoreDirection_unit {Ω Ξ : Type} {N : ℕ} (hN : 0<N)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (r : ℕ) (h : ChannelHistory Ω Ξ N r) :
    ∑i,(channelScoreDirection hN b₀ b r h i)^2=1 := scoreUnit_squared hN _

def normalizedChannelFeature {Ω Ξ : Type} {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (x : Cube d) (i : Fin N) : ℝ :=
  channelFeatures σ seed Z u r h x i/Real.sqrt N

def channelScoreState {Ω Ξ : Type} {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (x : Cube d) : WithLp 2 (ℝ×ℝ) :=
  canonicalCompletion (directionCoefficient (u r h) (normalizedChannelFeature σ seed Z u r h x))
    (∑i,(normalizedChannelFeature σ seed Z u r h x i)^2)

lemma normalized_array_square {N : ℕ} (hN : 0<N) (h : Fin N→ℝ) :
    (∑i,(h i/Real.sqrt N)^2)=(∑i,(h i)^2)/(N:ℝ) := by
  simp only [div_pow,Real.sq_sqrt (Nat.cast_nonneg N),Finset.sum_div]

lemma normalized_array_pairing {N : ℕ} (u h : Fin N→ℝ) :
    directionCoefficient u (fun i=>h i/Real.sqrt N)=
      (∑i,u i*h i)/Real.sqrt N := by
  unfold directionCoefficient
  simp only [mul_div_assoc,Finset.sum_div]

theorem critical_channel_row_eq_split {Ω Ξ : Type} {d N : ℕ}
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (x : Cube d) :
    channelRowFeature (1/Real.sqrt N) seed Z u r h x=
      splitRowFeature (Z r) (u r h)
        (normalizedChannelFeature (1/Real.sqrt N) seed Z u r h x) := by
  funext p
  unfold channelRowFeature splitRowFeature normalizedChannelFeature
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  ring

/-- Exact state of the initial layer on its positive empirical-score event. -/
theorem channelScoreState_zero_eq_empirical {Ω Ξ : Type} {d N : ℕ} (hN : 0<N)
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (h : ChannelInitial Ω N) (x : Cube d)
    (hscore : 0<rowAverage (fun z=>(b₀ z)^2) h.1) :
    channelScoreState σ seed Z (channelScoreDirection hN b₀ b) 0 h x=
      scalarChannelEmpirical b₀ (seedFeature seed x) h.1 := by
  unfold channelScoreState normalizedChannelFeature
  rw [normalized_array_pairing,normalized_array_square hN]
  simp only [channelFeatures_zero,channelScoreDirection,channelScoreArray]
  rw [scoreUnit_pairing hN _ _ hscore]
  rfl

/-- Exact state after each actual layer, including the normalized score
direction used by the following layer and final readout. -/
theorem channelScoreState_succ_eq_empirical {Ω Ξ : Type} {d N : ℕ} (hN : 0<N)
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (r : ℕ) (h : ChannelHistory Ω Ξ N r)
    (w : GaussianControlRow Ξ (Fin N) N) (x : Cube d)
    (hscore : 0<rowAverage (fun p : Ξ×(Fin N→ℝ)=>(b r p.1)^2) w) :
    channelScoreState σ seed Z (channelScoreDirection hN b₀ b) (r+1) (h,w) x=
      scalarChannelEmpirical (fun p=>b r p.1)
        (channelRowFeature σ seed Z (channelScoreDirection hN b₀ b) r h x) w := by
  unfold channelScoreState normalizedChannelFeature
  rw [normalized_array_pairing,normalized_array_square hN]
  simp only [channelFeatures_succ,channelScoreDirection,channelScoreArray]
  rw [scoreUnit_pairing hN _ _ hscore]
  rfl

#print axioms channelScoreState_succ_eq_empirical
end ConditionalNonpolynomial.Analytic
