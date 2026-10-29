import UniformChannelTracking
import UniformReadoutSuccess
import UniformChannelReference
import ActualCriticalChannelMass

/-! End-to-end finite-width success of the actual critical Gaussian network,
from a genuine bounded-score scalar moment program. -/
noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

theorem actualUniformChannel_success {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ξ] [Nonempty Ξ]
    {d N : ℕ} (hN : 0<N) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q₀ : Measure Ω) [IsProbabilityMeasure Q₀]
    (Q P : ℕ→Measure Ξ) [∀j,IsProbabilityMeasure (Q j)] [∀j,IsProbabilityMeasure (P j)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (hP : ∀j,(P j).map (Z j)=gaussianReal 0 1)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : Measurable b₀) (hb : ∀j,Measurable (b j))
    (hb₀Lp : MemLp b₀ 2 Q₀) (hbLp : ∀j,MemLp (b j) 2 (Q j))
    (hunit₀ : (∫z,(b₀ z)^2 ∂Q₀)=1) (hunit : ∀j,(∫z,(b j z)^2 ∂Q j)=1)
    (hKL : ∀j,klDiv (Q j) (P j)≠∞)
    (a : ℕ→Cube d→WithLp 2 (ℝ×ℝ))
    (ha₀ : ∀x,a 0 x=canonicalCompletion (∫z,b₀ z*seedFeature seed x z ∂Q₀)
      (∫z,(seedFeature seed x z)^2 ∂Q₀))
    (hastep : ∀j x,a (j+1) x=scalarSourceMoment (Q j) (Z j) (b j) (residualScale t (a j x)))
    (r : ℕ) (f : BooleanFunction d) {v vres α κ κ₀ B₀ : ℝ}
    (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1) (hα : 0<α) (hαquarter : α≤1/4)
    (hterminal : ∀x,a r x=canonicalCompletion (labelReal (f x)*Real.sqrt v) (v+vres))
    (hmetric : channelMetricBudget (fun j=>(klDiv (Q j) (P j)).toReal) α r≤κ*Real.sqrt v/8)
    (B κstep : ℕ→ℝ) (hB₀ : 1≤B₀) (hB : ∀j,1≤B j)
    (hb₀B : ∀z,|b₀ z|≤B₀) (hbB : ∀j z,|b j z|≤B j)
    (hkstep : ∀j,0≤κstep j) (hkstep1 : ∀j,κstep j≤1)
    (hwidth₀ : (1+2*(Fintype.card (Cube d):ℝ))*B₀^4≤κ₀*((N:ℝ)*α^2))
    (hwidth : ∀j,(1+2*(Fintype.card (Cube d):ℝ))*(B j)^4≤κstep j*((N:ℝ)*α^2))
    (hfailure : κ₀+(∑j : Fin r,κstep j)≤κ/2)
    (hreadout : 64*(Fintype.card (Cube d):ℝ)≤(N:ℝ)*κ^3) :
    1-κ≤((channelHistoryLaw N r Q₀ Q).prod (readoutControlLaw N (readoutChannelMean N (t^2*v) κ))).real
      (finiteChannelNetwork (t/Real.sqrt N) seed (standardizedChannelScalar t Z) (channelScoreDirection hN b₀ b) r
        (channelScoreDirection hN b₀ b r) ⁻¹' marginEvent Real.tanh (1/2) f) := by
  let u := channelScoreDirection hN b₀ b
  have hu : ∀j,Measurable (u j) := channelScoreDirection_measurable hN b₀ b hb₀ hb
  have hunorm : ∀j h,∑i,u j h i^2=1 := channelScoreDirection_unit hN b₀ b
  let G := uniformNetworkGoodEvent hN t Q₀ Q seed Z b₀ b α r
  have hG : MeasurableSet G := uniformNetworkGood_measurable hN t Q₀ Q seed hseed Z hZ b₀ b hb₀ hb α r
  have hprob := uniformNetworkGood_probability hN t Q₀ Q seed hseed Z hZ b₀ b hb₀ hb
    B κstep hB₀ hB hb₀B hbB hkstep hkstep1 hα hwidth₀ hwidth r
  have hcorr (h : ChannelHistory Ω Ξ N r) (hh : h∈G) (x : Cube d) :
      Real.sqrt v*(1-κ/8)≤(∑i,u r h i*signedHiddenFeatures f
        (channelHiddenNetwork (t/Real.sqrt N) seed (standardizedChannelScalar t Z) u r h) x i)/Real.sqrt N := by
    have he := uniformNetworkGood_state_error hN ht ht1 Q₀ Q P seed hseed Z hZ hP b₀ b hb₀Lp hb hbLp
      hunit₀ hunit hKL a ha₀ hastep hα hαquarter r h hh x
    rw [hterminal x] at he
    have hs : labelReal (f x)=1 ∨ labelReal (f x)= -1 := by cases f x <;> simp
    exact channelScoreState_readout_correlation (t/Real.sqrt N) seed (standardizedChannelScalar t Z) u r h x hs (he.trans hmetric)
  have hsuccess := uniformReadout_history_success hN ht ht1 (channelHistoryLaw N r Q₀ Q)
    (channelHiddenNetwork (t/Real.sqrt N) seed (standardizedChannelScalar t Z) u r)
    (channelHiddenNetwork_measurable (t/Real.sqrt N) seed hseed (standardizedChannelScalar t Z) (standardizedChannelScalar_measurable t Z hZ) u hu r)
    (u r) (hu r) (hunorm r) f G hG hv hκ hκ1 hcorr hreadout
  change 1-κ≤((channelHistoryLaw N r Q₀ Q).prod (readoutControlLaw N (readoutChannelMean N (t^2*v) κ))).real
    (networkWithReadoutChannel (t/Real.sqrt N) (channelHiddenNetwork (t/Real.sqrt N) seed (standardizedChannelScalar t Z) u r)
      (u r) ⁻¹' marginEvent Real.tanh (1/2) f)
  linarith


theorem actualUniformChannel_raw_mass {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ω] [StandardBorelSpace Ξ] [Nonempty Ω] [Nonempty Ξ]
    {d N : ℕ} (hN : 0<N) {t : ℝ} (ht : 0<t) (ht1 : t≤1)
    (Q₀ P₀ : Measure Ω) [IsProbabilityMeasure Q₀] [IsProbabilityMeasure P₀]
    (Q P R : ℕ→Measure Ξ) [∀j,IsProbabilityMeasure (Q j)] [∀j,IsProbabilityMeasure (P j)] [∀j,IsProbabilityMeasure (R j)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (hseedlaw : P₀.map seed=Measure.pi fun _ : Fin (d+1)=>
      gaussianReal 0 (((N:ℝ)/d)*(t/Real.sqrt N)^2).toNNReal)
    (hKL₀ : klDiv Q₀ P₀≠∞)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (hP : ∀j,(P j).map (Z j)=gaussianReal 0 (t^2).toNNReal)
    (hR : ∀j,(R j).map (Z j)=gaussianReal 0 1)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : Measurable b₀) (hb : ∀j,Measurable (b j))
    (hb₀Lp : MemLp b₀ 2 Q₀) (hbLp : ∀j,MemLp (b j) 2 (Q j))
    (hunit₀ : (∫z,(b₀ z)^2 ∂Q₀)=1) (hunit : ∀j,(∫z,(b j z)^2 ∂Q j)=1)
    (hKL : ∀j,klDiv (Q j) (P j)≠∞) (hKLR : ∀j,klDiv (Q j) (R j)≠∞)
    (a : ℕ→Cube d→WithLp 2 (ℝ×ℝ))
    (ha₀ : ∀x,a 0 x=canonicalCompletion (∫z,b₀ z*seedFeature seed x z ∂Q₀)
      (∫z,(seedFeature seed x z)^2 ∂Q₀))
    (hastep : ∀j x,a (j+1) x=scalarSourceMoment (Q j) (Z j) (b j) (residualScale t (a j x)))
    (r : ℕ) (f : BooleanFunction d) {v vres α κ κ₀ B₀ : ℝ}
    (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1) (hα : 0<α) (hαquarter : α≤1/4)
    (hterminal : ∀x,a r x=canonicalCompletion (labelReal (f x)*Real.sqrt v) (v+vres))
    (hmetric : channelMetricBudget (fun j=>(klDiv (Q j) (R j)).toReal) α r≤κ*Real.sqrt v/8)
    (B κstep : ℕ→ℝ) (hB₀ : 1≤B₀) (hB : ∀j,1≤B j)
    (hb₀B : ∀z,|b₀ z|≤B₀) (hbB : ∀j z,|b j z|≤B j)
    (hkstep : ∀j,0≤κstep j) (hkstep1 : ∀j,κstep j≤1)
    (hwidth₀ : (1+2*(Fintype.card (Cube d):ℝ))*B₀^4≤κ₀*((N:ℝ)*α^2))
    (hwidth : ∀j,(1+2*(Fintype.card (Cube d):ℝ))*(B j)^4≤κstep j*((N:ℝ)*α^2))
    (hfailure : κ₀+(∑j : Fin r,κstep j)≤κ/2)
    (hreadout : 64*(Fintype.card (Cube d):ℝ)≤(N:ℝ)*κ^3)
    {A τ : ℝ} (hA : 0≤A) (hτ : 0<τ) (hκslack : κ≤τ/(4*(A+τ)))
    (hcostslack : 3*κ*A≤τ/4)
    (hbase : t^2*((klDiv Q₀ P₀).toReal+(∑j : Fin r,(klDiv (Q j) (P j)).toReal))+1/(8*v)≤A)
    (hlogwidth : Real.log 2≤(N:ℝ)*τ/4) :
    Real.exp (-(N:ℝ)*(A+τ)/t^2)≤(smallPrior d N r (t/Real.sqrt N)).real
      (marginEvent Real.tanh (1/2) f) := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have ht2 : 0<t^2 := sq_pos_of_pos ht
  have hσ : 0<t/Real.sqrt (N:ℝ) := by positivity
  let u := channelScoreDirection hN b₀ b
  have hu : ∀j,Measurable (u j) := channelScoreDirection_measurable hN b₀ b hb₀ hb
  have hunorm : ∀j h,∑i,u j h i^2=1 := channelScoreDirection_unit hN b₀ b
  have hsuccess := actualUniformChannel_success hN ht ht1 Q₀ Q R seed hseed Z hZ hR
    b₀ b hb₀ hb hb₀Lp hbLp hunit₀ hunit hKLR a ha₀ hastep r f hv hκ hκ1 hα hαquarter
    hterminal hmetric B κstep hB₀ hB hb₀B hbB hkstep hkstep1 hwidth₀ hwidth hfailure hreadout
  let D := (klDiv Q₀ P₀).toReal+∑j : Fin r,(klDiv (Q j) (P j)).toReal
  have hD : 0≤D := by positivity
  have hrate := readout_inflated_cost hv (mul_nonneg ht2.le hD) hκ.le hκ1 hbase hcostslack
  have hrate' : D+(1+κ)^2/(8*(t^2*v))≤A/t^2+(τ/t^2)/4 := by
    apply (mul_le_mul_iff_right₀ ht2).mp
    calc
      _ = t^2*D+(1+κ)^2/(8*v) := by field_simp
      _ ≤ A+τ/4 := hrate
      _ = _ := by field_simp
  have hcost : (N:ℝ)*D+(readoutChannelMean N (t^2*v) κ)^2/2≤
      (N:ℝ)*(A/t^2+(τ/t^2)/4) := by
    rw [readoutChannelMean_energy hN (mul_pos ht2 hv)]
    calc
      _ = (N:ℝ)*(D+(1+κ)^2/(8*(t^2*v))) := by ring
      _ ≤ _ := mul_le_mul_of_nonneg_left hrate' hn.le
  have hslack : κ≤(τ/t^2)/(4*(A/t^2+τ/t^2)) := by
    have he : (τ/t^2)/(4*(A/t^2+τ/t^2))=τ/(4*(A+τ)) := by field_simp
    rwa [he]
  have hlog : Real.log 2≤(N:ℝ)*(τ/t^2)/4 := by
    apply hlogwidth.trans
    have ht21 : t^2≤1 := by nlinarith
    have hh : τ≤τ/t^2 := (le_div_iff₀ ht2).mpr (by nlinarith)
    nlinarith
  have hprior (j : ℕ) : (P j).map (standardizedChannelScalar t Z j)=gaussianReal 0 1 :=
    standardizedScalar_reference (P j) (Z j) (hZ j) ht (hP j)
  have hh := finiteChannelNetwork_raw_mass hN hσ Q₀ P₀ Q P seed hseed hseedlaw
    (standardizedChannelScalar t Z) (standardizedChannelScalar_measurable t Z hZ) hprior
    u hu hunorm r (u r) (hu r) (hunorm r) hKL₀ (fun j=>hKL j)
    (marginEvent Real.tanh (1/2) f)
    (isOpen_marginEvent NeuralGeneralization.TanhDifferential.continuous_tanh (1/2) f).measurableSet
    (readoutChannelMean N (t^2*v) κ) (div_nonneg hA ht2.le) (div_pos hτ ht2)
    hκ.le hslack hsuccess hcost hlog
  convert hh using 1 <;> congr 1 <;> ring

#print axioms actualUniformChannel_success
#print axioms actualUniformChannel_raw_mass
end ConditionalNonpolynomial.Analytic
