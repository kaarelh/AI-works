import ChannelScoreState

/-! The finite critical network tracks the actual scalar moment recursion on
its explicitly defined empirical-moment history event. -/
noncomputable section
set_option maxHeartbeats 2000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.ConcreteModel
open NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.BatchTwoContinuousDepthCritical

def channelMetricBudget (D : ℕ→ℝ) (α : ℝ) : ℕ→ℝ
  | 0 => 8*Real.sqrt α
  | n+1 => 8*Real.sqrt α+Real.exp (Real.sqrt (2*D n))*channelMetricBudget D α n

lemma channelMetricBudget_bound (D : ℕ→ℝ) (α : ℝ) (n : ℕ) :
    channelMetricBudget D α n≤((n:ℝ)+1)*8*Real.sqrt α*
      Real.exp (channelEntropyPrefix D n) := by
  have hh := channel_error_recurrence D (channelMetricBudget D α)
    (by positivity : 0≤8*Real.sqrt α) (by positivity : 0≤8*Real.sqrt α)
    le_rfl (fun _=>le_rfl) n
  convert hh using 1 <;> ring

def criticalNetworkGoodEvent {Ω Ξ : Type} [MeasurableSpace Ω] [MeasurableSpace Ξ]
    {d N : ℕ} (hN : 0<N) (Q₀ : Measure Ω) (Q : ℕ→Measure Ξ)
    (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ) (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (α : ℝ)
    (r : ℕ) : Set (ChannelHistory Ω Ξ N r) :=
  channelGoodHistory (fun j=>(Q j).prod (standardLaw (Fin N)))
    (fun j p=>b j p.1)
    (fun j h x=>channelRowFeature (1/Real.sqrt N) seed Z (channelScoreDirection hN b₀ b) j h x)
    (initialSeedMomentEvent Q₀ b₀ seed α) α r

theorem criticalNetworkGood_state_error {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ξ] [Nonempty Ξ]
    {d N : ℕ} (hN : 0<N)
    (Q₀ : Measure Ω) [IsProbabilityMeasure Q₀]
    (Q P : ℕ→Measure Ξ) [∀j,IsProbabilityMeasure (Q j)] [∀j,IsProbabilityMeasure (P j)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (hP : ∀j,(P j).map (Z j)=gaussianReal 0 1)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : MemLp b₀ 2 Q₀)
    (hb : ∀j,Measurable (b j)) (hbLp : ∀j,MemLp (b j) 2 (Q j))
    (hunit₀ : (∫z,(b₀ z)^2 ∂Q₀)=1) (hunit : ∀j,(∫z,(b j z)^2 ∂Q j)=1)
    (hKL : ∀j,klDiv (Q j) (P j)≠∞)
    (a : ℕ→Cube d→WithLp 2 (ℝ×ℝ))
    (ha₀ : ∀x,a 0 x=canonicalCompletion (∫z,b₀ z*seedFeature seed x z ∂Q₀)
      (∫z,(seedFeature seed x z)^2 ∂Q₀))
    (hastep : ∀j x,a (j+1) x=scalarSourceMoment (Q j) (Z j) (b j) (a j x))
    {α : ℝ} (hα : 0<α) (hαquarter : α≤1/4)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r)
    (hgood : h∈criticalNetworkGoodEvent hN Q₀ Q seed Z b₀ b α r) (x : Cube d) :
    ‖channelScoreState (1/Real.sqrt N) seed Z (channelScoreDirection hN b₀ b) r h x-a r x‖≤
      channelMetricBudget (fun j=>(klDiv (Q j) (P j)).toReal) α r := by
  induction r generalizing x with
  | zero =>
      have hevent : h.1∈finiteMomentEvent Q₀ (channelObservables b₀ (seedFeature seed)) α N := hgood
      obtain ⟨hscore,herr⟩ := scalarChannelEmpirical_error Q₀ b₀ (seedFeature seed) hb₀ hunit₀
        (seedFeature_measurable seed hseed) (seedFeature_bound seed) h.1 hα hαquarter hevent x
      rw [channelScoreState_zero_eq_empirical hN _ _ _ _ _ _ _ hscore,ha₀]
      exact herr
  | succ r ih =>
      have hprev : h.1∈criticalNetworkGoodEvent hN Q₀ Q seed Z b₀ b α r := hgood.1
      have hevent : h.2∈finiteMomentEvent ((Q r).prod (standardLaw (Fin N)))
          (channelObservables (fun p=>b r p.1)
            (fun x=>channelRowFeature (1/Real.sqrt N) seed Z (channelScoreDirection hN b₀ b) r h.1 x)) α N :=
        hgood.2
      have hM := hevent (Sum.inl ())
      change |rowAverage (fun p : Ξ×(Fin N→ℝ)=>(b r p.1)^2) h.2-
        ∫p : Ξ×(Fin N→ℝ),(b r p.1)^2 ∂(Q r).prod (standardLaw (Fin N))|<α at hM
      rw [(score_product_unit (Q r) (standardLaw (Fin N)) (b r) (hbLp r) (hunit r)).2] at hM
      have hscore : 0<rowAverage (fun p : Ξ×(Fin N→ℝ)=>(b r p.1)^2) h.2 := by
        have hh := (abs_lt.mp hM).1
        linarith
      rw [channelScoreState_succ_eq_empirical hN _ _ _ _ _ _ _ _ _ hscore,hastep]
      simp_rw [critical_channel_row_eq_split] at hevent ⊢
      exact splitRowEmpirical_step (Q r) (P r) hN (Z r) (b r) (hZ r) (hb r) (hP r)
        (hbLp r) (hunit r) (hKL r) _ (channelScoreDirection_unit hN b₀ b r h.1)
        (fun x=>normalizedChannelFeature (1/Real.sqrt N) seed Z (channelScoreDirection hN b₀ b) r h.1 x)
        (a r) hα hαquarter (fun x=>ih h.1 hprev x) h.2 hevent x

theorem criticalNetworkGood_measurable {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ} (hN : 0<N)
    (Q₀ : Measure Ω) [IsProbabilityMeasure Q₀]
    (Q : ℕ→Measure Ξ) [∀j,IsProbabilityMeasure (Q j)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : Measurable b₀) (hb : ∀j,Measurable (b j))
    (α : ℝ) (r : ℕ) :
    MeasurableSet (criticalNetworkGoodEvent hN Q₀ Q seed Z b₀ b α r) := by
  have hu := channelScoreDirection_measurable hN b₀ b hb₀ hb
  have hrow (j : ℕ) (x : Cube d) : Measurable
      (fun p : ChannelHistory Ω Ξ N j×(Ξ×(Fin N→ℝ))=>
        channelRowFeature (1/Real.sqrt N) seed Z (channelScoreDirection hN b₀ b) j p.1 x p.2) :=
    channelRowFeature_measurable (1/Real.sqrt N) seed hseed Z hZ
      (channelScoreDirection hN b₀ b) hu j x
  exact measurableSet_channelGoodHistory
    (H := ChannelInitial Ω N) (Ω := Ξ×(Fin N→ℝ)) (X := Cube d) (N := N)
    (fun j=>(Q j).prod (standardLaw (Fin N))) (fun j p=>b j p.1)
    (fun j=>(hb j).comp measurable_fst)
    (fun j h x=>channelRowFeature (1/Real.sqrt N) seed Z (channelScoreDirection hN b₀ b) j h x)
    hrow
    (initialSeedMomentEvent Q₀ b₀ seed α)
    (measurableSet_initialSeedMomentEvent Q₀ b₀ hb₀ seed hseed α) α r

/-- An explicit width bound makes the actual entire network history good.
The learner's source law here is exactly the control law used by the concrete
finite network constructor, not a hypothetical sequence of independent events. -/
theorem criticalNetworkGood_probability {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] {d N : ℕ} (hN : 0<N)
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
      (criticalNetworkGoodEvent hN Q₀ Q seed Z b₀ b α r) := by
  have hu := channelScoreDirection_measurable hN b₀ b hb₀ hb
  have hrow (j : ℕ) (x : Cube d) : Measurable
      (fun p : ChannelHistory Ω Ξ N j×(Ξ×(Fin N→ℝ))=>
        channelRowFeature (1/Real.sqrt N) seed Z (channelScoreDirection hN b₀ b) j p.1 x p.2) :=
    channelRowFeature_measurable (1/Real.sqrt N) seed hseed Z hZ
      (channelScoreDirection hN b₀ b) hu j x
  have hinit := initialSeedMomentEvent_probability hN Q₀ b₀ hb₀ seed hseed
    hB₀ hb₀B hα hwidth₀
  exact channelGoodHistory_probability
    (H := ChannelInitial Ω N) (Ω := Ξ×(Fin N→ℝ)) (X := Cube d) (N := N)
    (initialSeedLaw N Q₀)
    (fun j=>(Q j).prod (standardLaw (Fin N))) (fun j p=>b j p.1)
    (fun j=>(hb j).comp measurable_fst) hN
    (fun j h x=>channelRowFeature (1/Real.sqrt N) seed Z (channelScoreDirection hN b₀ b) j h x)
    hrow
    B κ hB (fun j p=>hbB j p.1)
    (fun j h x p=>channelRowFeature_bound (1/Real.sqrt N) seed Z
      (channelScoreDirection hN b₀ b) j h x p)
    hκ hκ1 hα hwidth (initialSeedMomentEvent Q₀ b₀ seed α)
    (measurableSet_initialSeedMomentEvent Q₀ b₀ hb₀ seed hseed α) hinit r

theorem channelScoreState_readout_correlation {Ω Ξ : Type} {d N : ℕ}
    (σ : ℝ) (seed : Ω→Fin (d+1)→ℝ) (Z : ℕ→Ξ→ℝ)
    (u : (j : ℕ)→ChannelHistory Ω Ξ N j→Fin N→ℝ)
    (r : ℕ) (h : ChannelHistory Ω Ξ N r) (x : Cube d)
    {f v vres κ : ℝ} (hf : f=1 ∨ f= -1)
    (herr : ‖channelScoreState σ seed Z u r h x-
      canonicalCompletion (f*Real.sqrt v) (v+vres)‖≤κ*Real.sqrt v/8) :
    Real.sqrt v*(1-κ/8)≤
      (∑i,u r h i*(f*channelFeatures σ seed Z u r h x i))/Real.sqrt N := by
  have hh := canonicalCompletion_signed_correlation hf herr
  change Real.sqrt v*(1-κ/8)≤
    f*directionCoefficient (u r h) (normalizedChannelFeature σ seed Z u r h x) at hh
  unfold normalizedChannelFeature at hh
  rw [normalized_array_pairing] at hh
  have heq : (∑i,u r h i*(f*channelFeatures σ seed Z u r h x i))/Real.sqrt N=
      f*((∑i,u r h i*channelFeatures σ seed Z u r h x i)/Real.sqrt N) := by
    rw [←mul_div_assoc,Finset.mul_sum]
    congr 1
    apply Finset.sum_congr rfl
    intro i _
    ring
  rw [heq]
  exact hh

#print axioms criticalNetworkGood_state_error
#print axioms criticalNetworkGood_probability
#print axioms channelScoreState_readout_correlation
end ConditionalNonpolynomial.Analytic
