import GaussianShiftKL
import NeuralGeneralization.GaussianLinear
import NeuralGeneralization.GaussianAngularFields
import Mathlib.MeasureTheory.Measure.Real

/-! Final Gaussian readout of the finite-width planted channel. Features are
signed by the desired Boolean labels, so positive output means correctness. -/
noncomputable section
set_option linter.unusedSectionVars false
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianTail

variable {X : Type*} [Fintype X] {N : ℕ}

def readoutChannelMean (N : ℕ) (v κ : ℝ) : ℝ :=
  Real.sqrt N*(1+κ)/(2*Real.sqrt v)

def shiftedReadoutLaw (u : Fin N→ℝ) (μ : ℝ) : Measure (Fin N→ℝ) :=
  Measure.pi (fun i=>gaussianReal (μ*u i) 1)

instance shiftedReadoutLaw_probability (u : Fin N→ℝ) (μ : ℝ) :
    IsProbabilityMeasure (shiftedReadoutLaw u μ) := by unfold shiftedReadoutLaw; infer_instance

lemma shiftedReadoutLaw_map (u : Fin N→ℝ) (μ : ℝ) :
    (standardLaw (Fin N)).map (fun z i=>z i+μ*u i)=shiftedReadoutLaw u μ := by
  unfold standardLaw shiftedReadoutLaw
  rw [Measure.pi_map_pi (f:=fun (i : Fin N) (z : ℝ)=>z+μ*u i)
    (fun i=>(show Measurable (fun z : ℝ=>z+μ*u i) by fun_prop).aemeasurable)]
  simp only [gaussianReal_map_add_const,zero_add]

/-- Exact leading readout entropy coefficient for a unit score vector. -/
theorem readout_channel_kl (hN : 0<N) (u : Fin N→ℝ) (hu : ∑i,u i^2=1)
    {v : ℝ} (hv : 0<v) (κ : ℝ) :
    klDiv (shiftedReadoutLaw u (readoutChannelMean N v κ)) (standardLaw (Fin N))≠∞ ∧
    (klDiv (shiftedReadoutLaw u (readoutChannelMean N v κ)) (standardLaw (Fin N))).toReal=
      (N:ℝ)*(1+κ)^2/(8*v) := by
  constructor
  · exact ConditionalAnalytic.gaussianMeanPi_kl_ne_top _ 1 (by norm_num)
  · unfold shiftedReadoutLaw standardLaw
    rw [ConditionalAnalytic.gaussianMeanPi_kl_toReal _ 1 (by norm_num)]
    simp only [mul_pow,←Finset.mul_sum,hu,mul_one,NNReal.coe_one]
    unfold readoutChannelMean
    have hn : (0:ℝ)<N := by exact_mod_cast hN
    rw [div_pow,mul_pow,Real.sq_sqrt hn.le,mul_pow,Real.sq_sqrt hv.le]
    ring

lemma readout_channel_mean_margin (hN : 0<N) (u h : Fin N→ℝ)
    {v κ : ℝ} (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1)
    (hcorr : Real.sqrt v*(1-κ/8)≤(∑i,u i*h i)/Real.sqrt N) :
    1/2+κ/4≤(∑i,readoutChannelMean N v κ*u i*h i)/N := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hsN : Real.sqrt N≠0 := (Real.sqrt_pos.mpr hn).ne'
  have hsv : Real.sqrt v≠0 := (Real.sqrt_pos.mpr hv).ne'
  have heq : (∑i,readoutChannelMean N v κ*u i*h i)/N=
      ((1+κ)/(2*Real.sqrt v))*((∑i,u i*h i)/Real.sqrt N) := by
    simp only [readoutChannelMean,mul_assoc,←Finset.mul_sum]
    field_simp
    rw [Real.sq_sqrt hn.le]
    ring
  rw [heq]
  have hh := mul_le_mul_of_nonneg_left hcorr
    (show 0≤(1+κ)/(2*Real.sqrt v) by positivity)
  have he : ((1+κ)/(2*Real.sqrt v))*(Real.sqrt v*(1-κ/8))=(1+κ)*(1-κ/8)/2 := by
    field_simp
  rw [he] at hh
  have hsq : κ^2≤κ := by nlinarith
  nlinarith

/-- Failure probability under a fixed isotropic Gaussian mean-shift readout.
The bound is simultaneous over every supplied input and keeps strict margins. -/
theorem readout_channel_failure_bound (hN : 0<N) (u : Fin N→ℝ) (h : X→Fin N→ℝ)
    {v κ : ℝ} (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1)
    (hbound : ∀x i,|h x i|≤1)
    (hcorr : ∀x,Real.sqrt v*(1-κ/8)≤(∑i,u i*h x i)/Real.sqrt N) :
    (shiftedReadoutLaw u (readoutChannelMean N v κ)).real
      {z | ∃x,(∑i,z i*h x i)/N≤1/2} ≤
        (Fintype.card X:ℝ)*Real.exp (-(N:ℝ)*κ^2/32) := by
  classical
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  let μ := readoutChannelMean N v κ
  have hm : Measurable (fun z : Fin N→ℝ=>fun i=>z i+μ*u i) := by fun_prop
  have hE : MeasurableSet {z : Fin N→ℝ | ∃x,(∑i,z i*h x i)/N≤1/2} := by
    have heq : {z : Fin N→ℝ | ∃x,(∑i,z i*h x i)/N≤1/2}=
        ⋃x : X,{z | (∑i,z i*h x i)/N≤1/2} := by ext z; simp
    rw [heq]
    apply MeasurableSet.iUnion
    intro x
    exact measurableSet_le (by fun_prop) measurable_const
  rw [←shiftedReadoutLaw_map u μ,Measure.real,Measure.map_apply hm hE]
  change (standardLaw (Fin N)).real {z | ∃x,(∑i,(z i+μ*u i)*h x i)/N≤1/2}≤_
  have hsubset : {z : Fin N→ℝ | ∃x,(∑i,(z i+μ*u i)*h x i)/N≤1/2} ⊆
      ⋃x : X,{z | (N:ℝ)*κ/4≤∑i,(-h x i)*z i} := by
    intro z hz
    obtain ⟨x,hx⟩ := hz
    refine Set.mem_iUnion.mpr ⟨x,?_⟩
    have hmean := readout_channel_mean_margin hN u (h x) hv hκ hκ1 (hcorr x)
    have heq : (∑i,(z i+μ*u i)*h x i)/N=
        (∑i,z i*h x i)/N+(∑i,μ*u i*h x i)/N := by
      simp only [add_mul,Finset.sum_add_distrib,add_div]
    rw [heq] at hx
    have hh : (∑i,z i*h x i)/N≤ -κ/4 := by dsimp [μ] at hx; linarith
    have hh2 := (div_le_iff₀ hn).mp hh
    simp only [neg_mul,Finset.sum_neg_distrib]
    have he : (∑i,h x i*z i)=∑i,z i*h x i := by apply Finset.sum_congr rfl; intros; ring
    change (N:ℝ)*κ/4≤ -(∑i,h x i*z i)
    rw [he]
    linarith
  have htail (x : X) : (standardLaw (Fin N)).real
      {z | (N:ℝ)*κ/4≤∑i,(-h x i)*z i}≤Real.exp (-(N:ℝ)*κ^2/32) := by
    have hvar : (∑i,(-h x i)^2*((1:ℝ≥0):ℝ))≤N := by
      simp only [NNReal.coe_one,mul_one,neg_sq]
      calc
        _≤∑_i : Fin N,(1:ℝ) := Finset.sum_le_sum (fun i _=>by nlinarith [(abs_le.mp (hbound x i)).1,(abs_le.mp (hbound x i)).2])
        _=_ := by simp
    have hh := gaussian_linear_form_upper_tail (fun _ : Fin N=>(1:ℝ≥0))
      (fun i=>-h x i) N ((N:ℝ)*κ/4) hn (by positivity) hvar
    convert hh using 1
    congr 1
    field_simp
    ring
  calc
    _≤(standardLaw (Fin N)).real (⋃x : X,{z | (N:ℝ)*κ/4≤∑i,(-h x i)*z i}) := measureReal_mono hsubset
    _≤∑x : X,(standardLaw (Fin N)).real {z | (N:ℝ)*κ/4≤∑i,(-h x i)*z i} := measureReal_iUnion_fintype_le _
    _≤∑_x : X,Real.exp (-(N:ℝ)*κ^2/32) := Finset.sum_le_sum (fun x _=>htail x)
    _=_ := by simp

lemma readout_bad_measurable (h : X→Fin N→ℝ) :
    MeasurableSet {z : Fin N→ℝ | ∃x,(∑i,z i*h x i)/N≤1/2} := by
  have heq : {z : Fin N→ℝ | ∃x,(∑i,z i*h x i)/N≤1/2}=
      ⋃x : X,{z | (∑i,z i*h x i)/N≤1/2} := by ext z; simp
  rw [heq]
  exact MeasurableSet.iUnion (fun x=>measurableSet_le (by fun_prop) measurable_const)

/-- Simultaneous strict-margin success under the actual shifted Gaussian law. -/
theorem readout_channel_success_bound (hN : 0<N) (u : Fin N→ℝ) (h : X→Fin N→ℝ)
    {v κ : ℝ} (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1)
    (hbound : ∀x i,|h x i|≤1)
    (hcorr : ∀x,Real.sqrt v*(1-κ/8)≤(∑i,u i*h x i)/Real.sqrt N) :
    1-(Fintype.card X:ℝ)*Real.exp (-(N:ℝ)*κ^2/32) ≤
      (shiftedReadoutLaw u (readoutChannelMean N v κ)).real
        {z | ∀x,1/2<(∑i,z i*h x i)/N} := by
  have hh := readout_channel_failure_bound hN u h hv hκ hκ1 hbound hcorr
  have hc := measureReal_add_measureReal_compl
    (μ:=shiftedReadoutLaw u (readoutChannelMean N v κ)) (readout_bad_measurable h)
  have heq : {z : Fin N→ℝ | ∃x,(∑i,z i*h x i)/N≤1/2}ᶜ=
      {z | ∀x,1/2<(∑i,z i*h x i)/N} := by ext z; simp
  rw [heq,probReal_univ] at hc
  linarith

lemma readout_tail_le_half {N : ℕ} (hN : 0<N) {κ : ℝ} (hκ : 0<κ) (m : ℕ)
    (hwidth : 64*(m:ℝ)≤(N:ℝ)*κ^3) :
    (m:ℝ)*Real.exp (-(N:ℝ)*κ^2/32)≤κ/2 := by
  have hn : (0:ℝ)<N := by exact_mod_cast hN
  have hx : 0<(N:ℝ)*κ^2/32 := by positivity
  have he : Real.exp (-((N:ℝ)*κ^2/32))≤1/((N:ℝ)*κ^2/32) := by
    rw [Real.exp_neg,←one_div]
    apply one_div_le_one_div_of_le hx
    have hh := Real.add_one_le_exp ((N:ℝ)*κ^2/32)
    linarith
  have hh := mul_le_mul_of_nonneg_left he (Nat.cast_nonneg m)
  have hfinal : (m:ℝ)*(1/((N:ℝ)*κ^2/32))≤κ/2 := by
    rw [mul_one_div]
    apply (div_le_iff₀ hx).mpr
    nlinarith
  simpa only [neg_div,neg_mul] using hh.trans hfinal

/-- A simple polynomial width condition gives success at least 1−κ/2.
The exponential tail above is stronger when its logarithmic form is useful. -/
theorem readout_channel_success (hN : 0<N) (u : Fin N→ℝ) (h : X→Fin N→ℝ)
    {v κ : ℝ} (hv : 0<v) (hκ : 0<κ) (hκ1 : κ≤1)
    (hbound : ∀x i,|h x i|≤1)
    (hcorr : ∀x,Real.sqrt v*(1-κ/8)≤(∑i,u i*h x i)/Real.sqrt N)
    (hwidth : 64*(Fintype.card X:ℝ)≤(N:ℝ)*κ^3) :
    1-κ/2≤(shiftedReadoutLaw u (readoutChannelMean N v κ)).real
      {z | ∀x,1/2<(∑i,z i*h x i)/N} := by
  have hh : 1-κ/2≤1-(Fintype.card X:ℝ)*Real.exp (-(N:ℝ)*κ^2/32) := by
    linarith [readout_tail_le_half hN hκ (Fintype.card X) hwidth]
  exact hh.trans (readout_channel_success_bound hN u h hv hκ hκ1 hbound hcorr)

#print axioms readout_channel_success
#print axioms readout_channel_kl
#print axioms readout_channel_failure_bound
end ConditionalNonpolynomial.Analytic
