import ChannelSlackBudget

noncomputable section
set_option maxHeartbeats 2400000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

theorem actualUniformChannel_raw_mass_of_width {Ω Ξ : Type}
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
    (r : ℕ) (f : BooleanFunction d) {v vres B S : ℝ}
    (hv : 0<v) (hv1 : v≤1)
    (hterminal : ∀x,a r x=canonicalCompletion (labelReal (f x)*Real.sqrt v) (v+vres))
    (hS : channelEntropyPrefix (fun j=>(klDiv (Q j) (R j)).toReal) r≤S)
    (hB : 1≤B) (hb₀B : ∀z,|b₀ z|≤B) (hbB : ∀j z,|b j z|≤B)
    {A τ : ℝ} (hA : 0≤A) (hτ : 0<τ)
    (hbase : t^2*((klDiv Q₀ P₀).toReal+(∑j : Fin r,(klDiv (Q j) (P j)).toReal))+1/(8*v)≤A)
    (hwidth : finiteChannelWidthBudget (Fintype.card (Cube d)) r B S v
      (channelSlackProbability A τ) τ≤(N:ℝ)) :
    Real.exp (-(N:ℝ)*(A+τ)/t^2)≤(smallPrior d N r (t/Real.sqrt N)).real
      (marginEvent Real.tanh (1/2) f) := by
  let κ := channelSlackProbability A τ
  let α := channelMomentPrecision r S v κ
  let κstep := channelFailureAllocation r κ
  have hκ : 0<κ := channelSlackProbability_pos hA hτ
  have hκ1 : κ≤1 := channelSlackProbability_le_one hA hτ
  have hS0 : 0≤S := (channelEntropyPrefix_nonneg _ _).trans hS
  obtain ⟨_,hαquarter,hmom,hread,hlog⟩ := finiteChannelWidthBudget_conditions
    (Nat.cast_nonneg _) hS0 hv hv1 hκ hκ1 hτ hwidth
  have hα : 0<α := channelMomentPrecision_pos r S hv hκ
  have hmetric := channelMetricBudget_of_entropy_bound _ r hv.le hκ.le hS
  have hκstep : 0≤κstep := (channelFailureAllocation_pos r hκ).le
  have hκstep1 : κstep≤1 := channelFailureAllocation_le_one r hκ1
  have hfailure : κstep+(∑_j : Fin r,κstep)≤κ/2 :=
    (channelFailureAllocation_total r κ).le
  exact actualUniformChannel_raw_mass hN ht ht1 Q₀ P₀ Q P R seed hseed hseedlaw hKL₀ Z hZ hP hR
    b₀ b hb₀ hb hb₀Lp hbLp hunit₀ hunit hKL hKLR a ha₀ hastep r f
    hv hκ hκ1 hα hαquarter hterminal hmetric (fun _=>B) (fun _=>κstep)
    hB (fun _=>hB) hb₀B hbB (fun _=>hκstep) (fun _=>hκstep1) hmom (fun _=>hmom)
    hfailure hread hA hτ (channelSlackProbability_entropy hA hτ)
    (channelSlackProbability_readout hA hτ) hbase hlog

theorem actualCriticalChannel_raw_mass_of_width {Ω Ξ : Type}
    [MeasurableSpace Ω] [MeasurableSpace Ξ] [StandardBorelSpace Ω] [StandardBorelSpace Ξ] [Nonempty Ω] [Nonempty Ξ]
    {d N : ℕ} (hN : 0<N)
    (Q₀ P₀ : Measure Ω) [IsProbabilityMeasure Q₀] [IsProbabilityMeasure P₀]
    (Q P : ℕ→Measure Ξ) [∀j,IsProbabilityMeasure (Q j)] [∀j,IsProbabilityMeasure (P j)]
    (seed : Ω→Fin (d+1)→ℝ) (hseed : Measurable seed)
    (hseedlaw : P₀.map seed=Measure.pi fun _ : Fin (d+1)=>
      gaussianReal 0 (((N:ℝ)/d)*(1/Real.sqrt N)^2).toNNReal)
    (hKL₀ : klDiv Q₀ P₀≠∞)
    (Z : ℕ→Ξ→ℝ) (hZ : ∀j,Measurable (Z j))
    (hP : ∀j,(P j).map (Z j)=gaussianReal 0 1)
    (b₀ : Ω→ℝ) (b : ℕ→Ξ→ℝ) (hb₀ : Measurable b₀) (hb : ∀j,Measurable (b j))
    (hb₀Lp : MemLp b₀ 2 Q₀) (hbLp : ∀j,MemLp (b j) 2 (Q j))
    (hunit₀ : (∫z,(b₀ z)^2 ∂Q₀)=1) (hunit : ∀j,(∫z,(b j z)^2 ∂Q j)=1)
    (hKL : ∀j,klDiv (Q j) (P j)≠∞)
    (a : ℕ→Cube d→WithLp 2 (ℝ×ℝ))
    (ha₀ : ∀x,a 0 x=canonicalCompletion (∫z,b₀ z*seedFeature seed x z ∂Q₀)
      (∫z,(seedFeature seed x z)^2 ∂Q₀))
    (hastep : ∀j x,a (j+1) x=scalarSourceMoment (Q j) (Z j) (b j) (a j x))
    (r : ℕ) (f : BooleanFunction d) {v vres B S : ℝ}
    (hv : 0<v) (hv1 : v≤1)
    (hterminal : ∀x,a r x=canonicalCompletion (labelReal (f x)*Real.sqrt v) (v+vres))
    (hS : channelEntropyPrefix (fun j=>(klDiv (Q j) (P j)).toReal) r≤S)
    (hB : 1≤B) (hb₀B : ∀z,|b₀ z|≤B) (hbB : ∀j z,|b j z|≤B)
    {A τ : ℝ} (hA : 0≤A) (hτ : 0<τ)
    (hbase : (klDiv Q₀ P₀).toReal+(∑j : Fin r,(klDiv (Q j) (P j)).toReal)+1/(8*v)≤A)
    (hwidth : finiteChannelWidthBudget (Fintype.card (Cube d)) r B S v
      (channelSlackProbability A τ) τ≤(N:ℝ)) :
    Real.exp (-(N:ℝ)*(A+τ))≤(smallPrior d N r (1/Real.sqrt N)).real
      (marginEvent Real.tanh (1/2) f) := by
  let κ := channelSlackProbability A τ
  let α := channelMomentPrecision r S v κ
  let κstep := channelFailureAllocation r κ
  have hκ : 0<κ := channelSlackProbability_pos hA hτ
  have hκ1 : κ≤1 := channelSlackProbability_le_one hA hτ
  have hS0 : 0≤S := (channelEntropyPrefix_nonneg _ _).trans hS
  obtain ⟨_,hαquarter,hmom,hread,hlog⟩ := finiteChannelWidthBudget_conditions
    (Nat.cast_nonneg _) hS0 hv hv1 hκ hκ1 hτ hwidth
  have hα : 0<α := channelMomentPrecision_pos r S hv hκ
  have hmetric := channelMetricBudget_of_entropy_bound _ r hv.le hκ.le hS
  have hκstep : 0≤κstep := (channelFailureAllocation_pos r hκ).le
  have hκstep1 : κstep≤1 := channelFailureAllocation_le_one r hκ1
  have hfailure : κstep+(∑_j : Fin r,κstep)≤κ/2 :=
    (channelFailureAllocation_total r κ).le
  exact actualCriticalChannel_raw_mass hN Q₀ P₀ Q P seed hseed hseedlaw hKL₀ Z hZ hP
    b₀ b hb₀ hb hb₀Lp hbLp hunit₀ hunit hKL a ha₀ hastep r f
    hv hκ hκ1 hα hαquarter hterminal hmetric (fun _=>B) (fun _=>κstep)
    hB (fun _=>hB) hb₀B hbB (fun _=>hκstep) (fun _=>hκstep1) hmom (fun _=>hmom)
    hfailure hread hA hτ (channelSlackProbability_entropy hA hτ)
    (channelSlackProbability_readout hA hτ) hbase hlog

#print axioms actualUniformChannel_raw_mass_of_width
#print axioms actualCriticalChannel_raw_mass_of_width
end ConditionalNonpolynomial.Analytic
