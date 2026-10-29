import ScalarChannelPopulation
import ScalarChannelConcentration

/-! Actual iid empirical scalar-channel state, with a single finite moment
event simultaneously controlling every input. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic NeuralGeneralization.BatchTwoContinuousDepthCritical
open NeuralGeneralization.GaussianAngularFields

variable {Ω X I : Type*} [MeasurableSpace Ω] [Fintype X] [Fintype I]

def scalarChannelEmpirical {N : ℕ} (b f : Ω→ℝ) (w : Fin N→Ω) :
    WithLp 2 (ℝ×ℝ) :=
  canonicalCompletion (rowAverage (fun z=>b z*f z) w /
    Real.sqrt (rowAverage (fun z=>(b z)^2) w)) (rowAverage (fun z=>(f z)^2) w)

theorem scalarChannelEmpirical_error (Q : Measure Ω) [IsProbabilityMeasure Q]
    (b : Ω→ℝ) (f : X→Ω→ℝ) (hb : MemLp b 2 Q)
    (hunit : (∫z,(b z)^2 ∂Q)=1) (hf : ∀x,Measurable (f x))
    (hfB : ∀x z,|f x z|≤1) {N : ℕ} (w : Fin N→Ω) {α : ℝ}
    (hα : 0<α) (hαquarter : α≤1/4)
    (hevent : w∈finiteMomentEvent Q (channelObservables b f) α N) (x : X) :
    0<rowAverage (fun z=>(b z)^2) w ∧
      ‖scalarChannelEmpirical b (f x) w-
        canonicalCompletion (∫z,b z*f x z ∂Q) (∫z,(f x z)^2 ∂Q)‖≤8*Real.sqrt α := by
  have hM := hevent (Sum.inl ())
  have hp := hevent (Sum.inr (Sum.inl x))
  have hq := hevent (Sum.inr (Sum.inr x))
  change |rowAverage (fun z=>(b z)^2) w-(∫z,(b z)^2 ∂Q)|<α at hM
  rw [hunit] at hM
  have hc := scalarScore_integral_bound Q b (f x) hb hunit (hf x) (hfB x)
  obtain ⟨hpos,hcorr,hmetric⟩ := scalar_channel_sampling_metric hα hαquarter hM hp hq.le hc
  exact ⟨hpos,hmetric⟩

/-- The empirical update inherits the population's dimension-free Gaussian
entropy gain, plus its independently controlled sampling error. -/
theorem scalarChannelEmpirical_step (Q : Measure Ω) [IsProbabilityMeasure Q]
    (Z : X→Ω→I→ℝ) (hZ : ∀x,Measurable (Z x))
    (b : Ω→ℝ) (hb : MemLp b 2 Q) (hunit : (∫z,(b z)^2 ∂Q)=1)
    (a a' : X→EuclideanSpace ℝ I)
    (hKL : ∀x,klDiv (Q.map (Z x)) (standardLaw I)≠∞)
    {N : ℕ} (w : Fin N→Ω) {α e D : ℝ} (hα : 0<α) (hαquarter : α≤1/4)
    (hcost : ∀x,(klDiv (Q.map (Z x)) (standardLaw I)).toReal≤D)
    (hclose : ∀x,‖a x-a' x‖≤e)
    (hevent : w∈finiteMomentEvent Q
      (channelObservables b (fun x=>scalarChannelFeature (Z x) (a x))) α N) (x : X) :
    ‖scalarChannelEmpirical b (scalarChannelFeature (Z x) (a x)) w-
      scalarChannelMoment Q (Z x) b (a' x)‖≤
      8*Real.sqrt α+Real.exp (Real.sqrt (2*D))*e := by
  have hs := (scalarChannelEmpirical_error Q b
    (fun x=>scalarChannelFeature (Z x) (a x)) hb hunit
    (fun x=>scalarChannelFeature_measurable (Z x) (hZ x) (a x))
    (fun x=>scalarChannelFeature_bound (Z x) (a x)) w hα hαquarter hevent x).2
  have hp := scalarChannelMoment_lipschitz_exp Q (Z x) (hZ x) b hb hunit
    (hKL x) (a x) (a' x)
  have hgain : Real.exp (Real.sqrt (2*(klDiv (Q.map (Z x)) (standardLaw I)).toReal))≤
      Real.exp (Real.sqrt (2*D)) := Real.exp_le_exp.mpr
        (Real.sqrt_le_sqrt (by linarith [hcost x]))
  have hmul := mul_le_mul hgain (hclose x) (norm_nonneg _) (Real.exp_pos _).le
  have ht := dist_triangle
    (scalarChannelEmpirical b (scalarChannelFeature (Z x) (a x)) w)
    (scalarChannelMoment Q (Z x) b (a x)) (scalarChannelMoment Q (Z x) b (a' x))
  simp only [dist_eq_norm] at ht
  exact ht.trans (add_le_add hs (hp.trans hmul))

#print axioms scalarChannelEmpirical_error
#print axioms scalarChannelEmpirical_step
end ConditionalNonpolynomial.Analytic
