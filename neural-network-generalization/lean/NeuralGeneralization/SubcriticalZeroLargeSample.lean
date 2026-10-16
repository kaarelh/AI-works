import NeuralGeneralization.LargeZeroScalar
import NeuralGeneralization.LargeSampleEvents
import NeuralGeneralization.GaussianZeroModelBridge
import NeuralGeneralization.SubcriticalNeuralEndpoints
import NeuralGeneralization.Statements

/-! The complete fixed-margin Gaussian endpoint throughout the exponential
large-sample interval, with the actual network posterior and confidence rule. -/
noncomputable section
open Filter MeasureTheory ProbabilityTheory
open scoped BigOperators Topology
namespace NeuralGeneralization.SubcriticalZeroLargeSample
open ConcreteModel LocalizedCubeBump SmallSampleCutoff AdaptiveCutoff LargeZeroScalar
  GaussianAmplitude GaussianFieldTilt FieldPosteriorBridge GaussianZeroModelBridge
  GaussianMarginConfidence SubcriticalNeuralEndpoints NetworkGaussianFunctionLimit

lemma polynomial_sample_lower {d n : ℕ} (hlog : 2≤logDimension d)
    (hmin : Real.exp (logDimension d^3)≤(n:ℝ)) : ((d:ℝ)+1)^2≤n := by
  have hh : 2*logDimension d≤logDimension d^3 := by nlinarith [sq_nonneg (logDimension d-2)]
  have he := (Real.exp_le_exp.mpr hh).trans hmin
  rw [show (2:ℝ)=(2:ℕ) by norm_num,Real.exp_nat_mul] at he
  simpa only [logDimension,Real.exp_log (by positivity : (0:ℝ)<(d:ℝ)+1)] using he

lemma eventually_auxiliaryLevel_large (k : ℕ) (a : ℝ) (ha : 0≤a) :
    ∀ᶠ d : ℕ in atTop, 10240≤(auxiliaryLevel d k a)^2 := by
  have he : 0<1-spectralExponent k := by
    have hh := neural_exponent_le_half k
    change spectralExponent k≤1/2 at hh
    linarith
  have ht : Tendsto (fun d : ℕ=>(auxiliaryRate/131072)*(d:ℝ)^(1-spectralExponent k)) atTop atTop :=
    ((tendsto_rpow_atTop he).comp tendsto_natCast_atTop_atTop).const_mul_atTop
      (div_pos auxiliaryRate_pos (by norm_num))
  filter_upwards [eventually_ge_atTop 262144,ht.eventually_ge_atTop 10240] with d hd hbound
  exact hbound.trans (auxiliaryLevel_sq_lower hd k a ha)

/-- Gamma zero has exponentially large full-parity sample complexity, with
strict global margin, width-first posterior, and confidence above two thirds. -/
theorem eventually_zero_large_sample_lower_bound (k : ℕ) (a : ℝ) (ha : 0<a) :
    ∃ c : ℝ,0<c ∧ ∀ᶠ d : ℕ in atTop,∀ n : ℕ,
      Real.exp (logDimension d^3)≤(n:ℝ) → (n:ℝ)≤Real.exp (c*(d:ℝ)) →
      (3/4:ℝ)≤sampleProbability (uniformLaw d) n (fun s=>
        (1/16:ℝ)≤Filter.liminf (MainStatements.parityFailure d k n a 0 s) atTop) := by
  classical
  let A : ℝ := (2:ℝ)^79
  have hA : (2:ℝ)^79≤A := le_rfl
  have hA0 : 0≤A := by positivity
  have hA1 : 1≤A := by dsimp [A]; norm_num
  obtain ⟨Cg,hCg,hgood⟩ := eventually_largeSampleGood_probability k A hA0
  obtain ⟨U,hU,hspectrum⟩ := actual_spectral_budget k
  let b0 : ℝ := auxiliaryRate/131072
  have hb0 : 0<b0 := div_pos auxiliaryRate_pos (by norm_num)
  let Ccost : ℝ := 4*largeConditioningConstant k a/b0
  have hCcost : 0<Ccost := by dsimp [Ccost]; have := largeConditioningConstant_pos k a; positivity
  let C : ℝ := max 1 (max Cg (max (2*A*U) Ccost))
  have hC : 1≤C := le_max_left _ _
  have hCCg : Cg≤C := (le_max_left _ _).trans (le_max_right _ _)
  have hCU : 2*A*U≤C := (le_max_left _ _).trans ((le_max_right _ _).trans (le_max_right _ _))
  have hCCost : Ccost≤C := (le_max_right _ _).trans ((le_max_right _ _).trans (le_max_right _ _))
  have hC0 : 0<C := by linarith only [hC]
  obtain ⟨cHead,hcHead,hbudgets⟩ := eventually_large_head_and_tail A C U (1/2048) (1/(2048*C))
    hA hC (by linarith only [hU]) (by norm_num) (by positivity)
  let c : ℝ := min cHead (min (1/1000) (auxiliaryRate/8))
  have hc : 0<c := lt_min hcHead (lt_min (by norm_num) (by positivity [auxiliaryRate_pos]))
  have hcHead' : c≤cHead := min_le_left _ _
  have hc1000 : c≤1/1000 := (min_le_right cHead _).trans (min_le_left _ _)
  have hcAux : c≤auxiliaryRate/8 := (min_le_right _ _).trans (min_le_right _ _)
  refine ⟨c,hc,?_⟩
  filter_upwards [hgood,hbudgets,eventually_large_conditioning_cost_probability k a (1/16) ha.le (by norm_num),
    eventually_large_conditioning_budget_exp k a (auxiliaryRate/4) (by positivity [auxiliaryRate_pos]),
    eventually_neural_amplitude_scale k a ha,eventually_auxiliaryLevel_large k a ha.le,
    logDimension_tendsto.eventually_ge_atTop 2,eventually_ge_atTop 262144]
    with d hgood hbudgets hcostprob hcostexp hamp hblevel hdlog hd n hmin hn
  have hd0 : 0<d := by omega
  have hdR : (0:ℝ)<d := Nat.cast_pos.mpr hd0
  have hpoly := polynomial_sample_lower hdlog hmin
  have hn4 : 4≤n := by
    have hd1 : (1:ℝ)≤d := by exact_mod_cast (show 1≤d by omega)
    have hh : (4:ℝ)≤n := by nlinarith only [hpoly,hd1,sq_nonneg ((d:ℝ)-1)]
    exact_mod_cast hh
  have hn0 : 0<n := by omega
  letI : Nonempty (Fin n) := Fin.pos_iff_nonempty.mp hn0
  have hnHead := hn.trans (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right hcHead' hdR.le))
  have hn1000 : (n:ℝ)≤Real.exp ((d:ℝ)/1000) := by
    have hh := hn.trans (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right hc1000 hdR.le))
    rw [show (1/1000:ℝ)*(d:ℝ)=(d:ℝ)/1000 by ring] at hh
    exact hh
  have hnAux : (n:ℝ)≤Real.exp ((auxiliaryRate/8)*(d:ℝ)) :=
    hn.trans (Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_right hcAux hdR.le))
  have hn128 : (n:ℝ)≤Real.exp ((d:ℝ)/128) := hn1000.trans (Real.exp_le_exp.mpr (by nlinarith only [hdR.le]))
  obtain ⟨r,hcut,hupper,hhead⟩ := hbudgets n hmin hnHead
  let u : ℕ := r+additionalBand d
  let β : ℝ := dampingExponent k
  let T : ℝ := (r:ℝ)^(-β)
  let W : ℝ := (d:ℝ)^(2*β)*(r:ℝ)^(-β)
  let G : ℝ := normalizedGram C d k r n
  let ellH : ℝ := U*T/((r:ℝ)*((d+1).choose (r+2):ℝ))
  let ellU : ℝ := U/((d+1).choose (u+2):ℝ)
  let b : ℝ := auxiliaryLevel d k a
  let costBound : ℝ := largeConditioningConstant k a*(n:ℝ)*((d:ℝ)+1)^(1+β)*(cutoffDamping k r:ℝ)
  have hr : 0<r := by have := hcut.positive; omega
  have hrd : r≤d := by have := hcut.degree_le; omega
  have hu : u≤d := by dsimp [u]; have := hcut.degree_le; omega
  have hrR : (1:ℝ)≤r := by exact_mod_cast hcut.positive
  have hrdR : (r:ℝ)≤d := by exact_mod_cast hrd
  have hβ0 : 0≤β := (dampingExponent_pos k).le
  have hβhalf : 2*β≤1 := by have hh := neural_exponent_le_half k; change β≤1/2 at hh; linarith only [hh]
  obtain ⟨hW,hWT,hWd⟩ := zero_weight_bounds hrR hrdR hβ0 hβhalf
  have hT : 0<T := Real.rpow_pos_of_pos (Nat.cast_pos.mpr hr) _
  have hU0 : 0<U := by linarith only [hU]
  have hK : 0<((d+1).choose (r+2):ℝ) := Nat.cast_pos.mpr (Nat.choose_pos (by have := hcut.degree_le; omega))
  have hKU : 0<((d+1).choose (u+2):ℝ) := Nat.cast_pos.mpr (Nat.choose_pos (by dsimp [u]; have := hcut.degree_le; omega))
  have hellH : 0<ellH := by dsimp [ellH]; positivity
  have hellU : 0<ellU := by dsimp [ellU]; positivity
  have hL : 0≤Real.log (8*(n:ℝ)) := (by norm_num : (0:ℝ)≤1).trans (log_eight_sample_ge_one hn0)
  have hG : 0<G := by dsimp [G,normalizedGram]; change 0<C*T*(1+_+_); positivity
  have hthreshold : (lowDimension d r:ℝ)*Real.log (8*(n:ℝ))≤n := by
    have hh := mul_le_mul_of_nonneg_right hA1 (show 0≤(lowDimension d r:ℝ)*Real.log (8*(n:ℝ)) by positivity)
    nlinarith only [hh,hcut.threshold]
  have hsample := hgood n r _ hn4 hn128 hcut
  have hcost := hcostprob r n hr hrd hpoly hthreshold hn1000
  let Ecost : (Fin n→ClippingCube d)→Prop := fun s=>∀ f : BooleanFunction d,
    Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix (walshCoefficients (arcsineProfile d (k+1))))).real
      (conditioningEvent id a f s))≤costBound
  have hcost' : (15:ℝ)/16≤sampleProbability (uniformLaw d) n Ecost := by
    norm_num only [show (1:ℝ)-1/16=15/16 by norm_num] at hcost
    exact hcost
  have hinter := sampleProbability_inter_lower (uniformLaw d)
    (LargeSampleGood d k r n (normalizedGram Cg d k r n)) Ecost
  have hprob : (3:ℝ)/4≤sampleProbability (uniformLaw d) n (fun s=>
      LargeSampleGood d k r n (normalizedGram Cg d k r n) s∧Ecost s) := by
    linarith only [hinter,hsample,hcost']
  apply hprob.trans
  apply sampleProbability_mono
  intro s hs
  have hsg : LargeSampleGood d k r n G s := hs.1.mono (normalizedGram_mono hCCg d k r hn0)
  let E : Set (ClippingCube d→ℝ) := conditioningEvent id a (parity d) s
  let w := walshCoefficients (arcsineProfile d (k+1))
  let D : ℝ := Real.log (1/(fieldLaw (WalshGaussianEnergy.matrix w)).real E)
  let B : ℝ := D/b^2
  have hE : MeasurableSet E := measurableSet_conditioningEvent id (fun x=>measurable_pi_apply x) a (parity d) s
  have hEpos : fieldLaw (WalshGaussianEnergy.matrix w) E≠0 :=
    conditioning_probability_ne_zero w (iterated_arcsine_coefficient_pos d k) ha.le (parity d) s
  have hD : 0≤D := by
    apply Real.log_nonneg
    have hp : 0<(fieldLaw (WalshGaussianEnergy.matrix w)).real E := ENNReal.toReal_pos hEpos (measure_ne_top _ _)
    exact (le_div_iff₀ hp).mpr (by simp)
  have hcosts : D≤costBound := hs.2 (parity d)
  have hb : 0<b := auxiliaryLevel_pos d k a ha
  have hB : 0≤B := div_nonneg hD (sq_nonneg _)
  have hnormalized : B≤C*(n:ℝ)*W := by
    have hh := normalized_conditioning_cost (by omega) hr k a b b0 D hb0 hamp.2.1 hcosts
    change B≤Ccost*(n:ℝ)*W at hh
    exact hh.trans (mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_right hCCost (Nat.cast_nonneg n)) hW)
  have hnell : (n:ℝ)*ellH≤C*Real.log (8*(n:ℝ))*T/(r:ℝ) := by
    have hnxt := next_threshold_binomial hA0 hn0 (by have := hcut.degree_le; omega) hcut.next_threshold
    have hh := sampled_eigenvalue_budget hL hA0 hU0.le hT.le (Nat.cast_pos.mpr hr) hK
      (Nat.cast_nonneg n) hnxt (le_refl ellH)
    change (n:ℝ)*ellH≤(2*A*U)*Real.log (8*(n:ℝ))*T/(r:ℝ) at hh
    exact hh.trans (by gcongr)
  have hhead' := hhead G B ellH W T hG.le hB hellH.le hW hT.le hWT (le_refl G) hnell hnormalized
  have htail' : ellU*B≤1/2048 := by
    have hh := normalized_upper_tail hC0.le hellU.le hWd hnormalized hupper
    change ellU*B≤C*(1/(2048*C)) at hh
    convert hh using 1; field_simp
  have htH : (∑ S∈Finset.univ \ adaptiveLowBand d r,w S)≤1 := by
    rw [show (∑ S∈Finset.univ \ adaptiveLowBand d r,w S)=walshSpectralTail (arcsineProfile d (k+1)) (r+1) from adaptive_tail_trace d k r]
    exact SmallSampleCutoff.spectral_tail_le_one d (k+1) (r+1)
  have htU : (∑ S∈Finset.univ \ adaptiveLowBand d u,w S)≤1 := by
    rw [show (∑ S∈Finset.univ \ adaptiveLowBand d u,w S)=walshSpectralTail (arcsineProfile d (k+1)) (u+1) from adaptive_tail_trace d k u]
    exact SmallSampleCutoff.spectral_tail_le_one d (k+1) (u+1)
  have hDB : D=B*b^2 := by dsimp [B]; field_simp
  have hhead'' : (u:ℝ)^2*(4*G*B/(n:ℝ)+ellH*B)≤(d:ℝ)^2/2048 := by
    simpa only [one_div,mul_comm,div_eq_mul_inv,one_mul] using hhead'
  obtain ⟨hheadfinal,htailfinal⟩ := gaussian_zero_moment_budgets (n:=n) (G:=G) (ellH:=ellH) hu htH htU hblevel hDB hhead'' htail' 
  have hspecH := (hspectrum d r hcut.positive hcut.odd (by have := hcut.degree_le; omega)).1
  have huodd : Odd u := hcut.odd.add_even (additionalBand_even d)
  have hspecU := (hspectrum d u (by dsimp [u]; omega) huodd (by dsimp [u]; have := hcut.degree_le; omega)).2.2.2
  have hmaxH : ∀ S∈Finset.univ \ adaptiveLowBand d r,w S≤ellH := by
    intro S hS
    have hsdeg : r<S.card := by simpa only [Finset.mem_sdiff,Finset.mem_univ,mem_adaptiveLowBand,true_and,not_le] using hS
    exact hspecH S hsdeg
  have hmaxU : ∀ S∈Finset.univ \ adaptiveLowBand d u,w S≤ellU := by
    intro S hS
    have hsdeg : u<S.card := by simpa only [Finset.mem_sdiff,Finset.mem_univ,mem_adaptiveLowBand,true_and,not_le] using hS
    exact hspecU S hsdeg
  have hamplitude : (∫ z,amplitudeFraction b z ∂cond (fieldLaw (WalshGaussianEnergy.matrix w)) E)≤1/32 := by
    apply hamp.2.2 E hE hEpos (fun z hz x=>hz.1 x)
    apply hcosts.trans
    have hnAux' : (n:ℝ)≤Real.exp (((auxiliaryRate/4)/2)*(d:ℝ)) := by
      rw [show ((auxiliaryRate/4)/2)*(d:ℝ)=(auxiliaryRate/8)*(d:ℝ) by ring]
      exact hnAux
    have hh := hcostexp r n hr hnAux'
    rw [show (auxiliaryRate/4)*(d:ℝ)=auxiliaryExponent d/4 by unfold auxiliaryExponent; ring] at hh
    exact hh
  have hfailure := GaussianZeroDeterministic.confidence_failure_lower hd0 w
    (fun S=>(iterated_arcsine_coefficient_pos d k S).le) s
    (adaptiveLowBand d r) (adaptiveLowBand d u) (fun S hS=>(mem_adaptiveLowBand S).mp hS)
    (by simpa only [Fintype.card_fin] using hsg.coercivity)
    G ellH ellU b hG hellH hellU hb hmaxH hmaxU hsg.gram E hE hEpos
    (fun z hz j=>by have hh := hz.2 j; simpa only [id_eq,labelReal_parity] using hh.le)
    (by simpa only [Fintype.card_fin] using hheadfinal) htailfinal hamplitude
  have ht := gamma_zero_confidence_liminf hd0 k a (parity d) s (uniformLaw d) (13/20) (by norm_num)
  rw [uniform_bufferedFailure_eq] at ht
  change ConfidenceClipping.failure (correctConfidence (parity d)
    (posterior (GaussianSignPosteriorBridge.walshFunctionMass w a) (consistent (parity d) s))) (13/20)≤_ at ht
  rw [buffered_failure_eq w ha.le] at ht
  exact hfailure.trans ht

end NeuralGeneralization.SubcriticalZeroLargeSample
