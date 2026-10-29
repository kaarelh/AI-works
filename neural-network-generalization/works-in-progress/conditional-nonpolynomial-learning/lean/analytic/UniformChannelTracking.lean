import ActualChannelTracking
import ScaledSplitRowChannel

/-! Finite-width tracking uniform in every physical prefactor 0<t≤1.
The tracking entropy is relative to the critical Gaussian reference. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def standardizedChannelScalar {Ξ : Type} (t : ℝ) (Z : ℕ→Ξ→ℝ) (j : ℕ) (z : Ξ) : ℝ := Z j z/t

theorem standardizedChannelScalar_measurable {Ξ : Type} [MeasurableSpace Ξ]
    (t : ℝ) (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j)) (j : ℕ) :
    Measurable (standardizedChannelScalar t Z j) := (hZ j).div_const t

theorem uniform_channel_row_eq_scaledSplit {Ω Ξ : Type} {d N : ℕ} (t : ℝ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (x : Cube d) :
    channelRowFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z) u r h x=
      scaledSplitRowFeature t (Z r) (u r h)
        (normalizedChannelFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z) u r h x) := by
  funext p
  unfold channelRowFeature scaledSplitRowFeature normalizedChannelFeature standardizedChannelScalar
  congr 1
  apply Finset.sum_congr rfl
  intro j _
  ring

def uniformNetworkGoodEvent {Ω Ξ : Type} [MeasurableSpace Ω] [MeasurableSpace Ξ]
    {d N : ℕ} (hN : 0<N) (t : ℝ) (Q₀ : Measure Ω) (Q : ℕ→Measure Ξ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ) (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (α : ℝ)
    (r : ℕ) : Set (ChannelHistory Ω Ξ N r) :=
  channelGoodHistory (fun j=>(Q j).prod (standardLaw (Fin N)))
    (fun j p=>b j p.1)
    (fun j h x=>channelRowFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
      (channelScoreDirection hN b₀ b) j h x)
    (initialSeedMomentEvent Q₀ b₀ seed α) α r

theorem uniformNetworkGood_state_error {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ξ] [Nonempty Ξ]
    {d N : ℕ} (hN : 0<N) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q₀ : Measure Ω) [IsProbabilityMeasure Q₀]
    (Q R : ℕ→Measure Ξ) [∀j,IsProbabilityMeasure (Q j)] [∀j,IsProbabilityMeasure (R j)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (hR : ∀j,(R j).map (Z j)=gaussianReal 0 1)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : MemLp b₀ 2 Q₀)
    (hb : ∀j,Measurable (b j)) (hbLp : ∀j,MemLp (b j) 2 (Q j))
    (hunit₀ : (∫z,(b₀ z)^2 ∂Q₀)=1) (hunit : ∀j,(∫z,(b j z)^2 ∂Q j)=1)
    (hKL : ∀j,klDiv (Q j) (R j)≠∞)
    (a : ℕ→Cube d→WithLp 2 (ℝ×ℝ))
    (ha₀ : ∀x,a 0 x=canonicalCompletion (∫z,b₀ z*seedFeature seed x z ∂Q₀)
      (∫z,(seedFeature seed x z)^2 ∂Q₀))
    (hastep : ∀j x,a (j+1) x=scalarSourceMoment (Q j) (Z j) (b j) (residualScale t (a j x)))
    {α : ℝ} (hα : 0<α) (hαquarter : α≤1/4)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r)
    (hgood : h∈uniformNetworkGoodEvent hN t Q₀ Q seed Z b₀ b α r) (x : Cube d) :
    ‖channelScoreState (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
      (channelScoreDirection hN b₀ b) r h x-a r x‖≤
      channelMetricBudget (fun j=>(klDiv (Q j) (R j)).toReal) α r := by
  induction r generalizing x with
  | zero =>
      have hevent : h.1∈finiteMomentEvent Q₀ (channelObservables b₀ (seedFeature seed)) α N := hgood
      obtain ⟨hscore,herr⟩ := scalarChannelEmpirical_error Q₀ b₀ (seedFeature seed) hb₀ hunit₀
        (seedFeature_measurable seed hseed) (seedFeature_bound seed) h.1 hα hαquarter hevent x
      rw [channelScoreState_zero_eq_empirical hN _ _ _ _ _ _ _ hscore,ha₀]
      exact herr
  | succ r ih =>
      have hprev : h.1∈uniformNetworkGoodEvent hN t Q₀ Q seed Z b₀ b α r := hgood.1
      have hevent : h.2∈finiteMomentEvent ((Q r).prod (standardLaw (Fin N)))
          (channelObservables (fun p=>b r p.1)
            (fun x=>channelRowFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
              (channelScoreDirection hN b₀ b) r h.1 x)) α N := hgood.2
      have hM := hevent (Sum.inl ())
      change |rowAverage (fun p : Ξ×(Fin N→ℝ)=>(b r p.1)^2) h.2-
        ∫p : Ξ×(Fin N→ℝ),(b r p.1)^2 ∂(Q r).prod (standardLaw (Fin N))|<α at hM
      rw [(score_product_unit (Q r) (standardLaw (Fin N)) (b r) (hbLp r) (hunit r)).2] at hM
      have hscore : 0<rowAverage (fun p : Ξ×(Fin N→ℝ)=>(b r p.1)^2) h.2 := by
        have hh := (abs_lt.mp hM).1
        linarith
      rw [channelScoreState_succ_eq_empirical hN _ _ _ _ _ _ _ _ _ hscore,hastep]
      simp_rw [uniform_channel_row_eq_scaledSplit] at hevent ⊢
      exact scaledSplitRowEmpirical_step (Q r) (R r) hN ht ht1 (Z r) (b r) (hZ r) (hb r) (hR r)
        (hbLp r) (hunit r) (hKL r) _ (channelScoreDirection_unit hN b₀ b r h.1)
        (fun x=>normalizedChannelFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
          (channelScoreDirection hN b₀ b) r h.1 x)
        (a r) hα hαquarter (fun x=>ih h.1 hprev x) h.2 hevent x

theorem uniformNetworkGood_measurable {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ} (hN : 0<N) (t : ℝ)
    (Q₀ : Measure Ω) [IsProbabilityMeasure Q₀]
    (Q : ℕ→Measure Ξ) [∀j,IsProbabilityMeasure (Q j)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : Measurable b₀) (hb : ∀j,Measurable (b j))
    (α : ℝ) (r : ℕ) :
    MeasurableSet (uniformNetworkGoodEvent hN t Q₀ Q seed Z b₀ b α r) := by
  have hu := channelScoreDirection_measurable hN b₀ b hb₀ hb
  have hz := standardizedChannelScalar_measurable t Z hZ
  have hrow (j : ℕ) (x : Cube d) : Measurable
      (fun p : ChannelHistory Ω Ξ N j×(Ξ×(Fin N→ℝ))=>
        channelRowFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
          (channelScoreDirection hN b₀ b) j p.1 x p.2) :=
    channelRowFeature_measurable (t/Real.sqrt N) seed hseed (standardizedChannelScalar t Z) hz
      (channelScoreDirection hN b₀ b) hu j x
  exact measurableSet_channelGoodHistory
    (H := ChannelInitial Ω N) (Ω := Ξ×(Fin N→ℝ)) (X := Cube d) (N := N)
    (fun j=>(Q j).prod (standardLaw (Fin N))) (fun j p=>b j p.1)
    (fun j=>(hb j).comp measurable_fst)
    (fun j h x=>channelRowFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
      (channelScoreDirection hN b₀ b) j h x) hrow
    (initialSeedMomentEvent Q₀ b₀ seed α)
    (measurableSet_initialSeedMomentEvent Q₀ b₀ hb₀ seed hseed α) α r

theorem uniformNetworkGood_probability {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ} (hN : 0<N) (t : ℝ)
    (Q₀ : Measure Ω) [IsProbabilityMeasure Q₀]
    (Q : ℕ→Measure Ξ) [∀j,IsProbabilityMeasure (Q j)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : Measurable b₀) (hb : ∀j,Measurable (b j))
    {B₀ α κ₀ : ℝ} (B κ : ℕ→ℝ) (hB₀ : 1≤B₀) (hB : ∀j,1≤B j)
    (hb₀B : ∀z,|b₀ z|≤B₀) (hbB : ∀j z,|b j z|≤B j)
    (hκ : ∀j,0≤κ j) (hκ1 : ∀j,κ j≤1) (hα : 0<α)
    (hwidth₀ : (1+2*(Fintype.card (Cube d):ℝ))*B₀^4≤κ₀*((N:ℝ)*α^2))
    (hwidth : ∀j,(1+2*(Fintype.card (Cube d):ℝ))*(B j)^4≤κ j*((N:ℝ)*α^2))
    (r : ℕ) :
    1-κ₀-(∑j : Fin r,κ j)≤(channelHistoryLaw N r Q₀ Q).real
      (uniformNetworkGoodEvent hN t Q₀ Q seed Z b₀ b α r) := by
  have hu := channelScoreDirection_measurable hN b₀ b hb₀ hb
  have hz := standardizedChannelScalar_measurable t Z hZ
  have hrow (j : ℕ) (x : Cube d) : Measurable
      (fun p : ChannelHistory Ω Ξ N j×(Ξ×(Fin N→ℝ))=>
        channelRowFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
          (channelScoreDirection hN b₀ b) j p.1 x p.2) :=
    channelRowFeature_measurable (t/Real.sqrt N) seed hseed (standardizedChannelScalar t Z) hz
      (channelScoreDirection hN b₀ b) hu j x
  have hinit := initialSeedMomentEvent_probability hN Q₀ b₀ hb₀ seed hseed hB₀ hb₀B hα hwidth₀
  exact channelGoodHistory_probability
    (H := ChannelInitial Ω N) (Ω := Ξ×(Fin N→ℝ)) (X := Cube d) (N := N)
    (initialSeedLaw N Q₀)
    (fun j=>(Q j).prod (standardLaw (Fin N))) (fun j p=>b j p.1)
    (fun j=>(hb j).comp measurable_fst) hN
    (fun j h x=>channelRowFeature (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
      (channelScoreDirection hN b₀ b) j h x) hrow
    B κ hB (fun j p=>hbB j p.1)
    (fun j h x p=>channelRowFeature_bound (t/Real.sqrt N) seed (standardizedChannelScalar t Z)
      (channelScoreDirection hN b₀ b) j h x p)
    hκ hκ1 hα hwidth (initialSeedMomentEvent Q₀ b₀ seed α)
    (measurableSet_initialSeedMomentEvent Q₀ b₀ hb₀ seed hseed α) hinit r

#print axioms uniformNetworkGood_state_error
#print axioms uniformNetworkGood_probability
end ConditionalNonpolynomial.Analytic
