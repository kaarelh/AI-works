import NeuralGeneralization.OnlineLowerTanhAbsoluteMoment
import Mathlib.Topology.Order.Compact

noncomputable section
open scoped Topology
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

def normalizedSineKernel (a t:ℝ) : ℝ := absoluteSineKernel 3 a t/a

def sineEnvelope (a:ℝ) : ℝ := absoluteSineMoment 3 a/a

lemma normalizedSineKernel_nonneg {a t:ℝ} (ha:0<a) (ht:0<t) :
    0≤normalizedSineKernel a t := div_nonneg (absoluteSineKernel_nonneg _ _ _ ht) ha.le

lemma normalizedSineKernel_small {a t:ℝ} (ha:0<a) (ht:0<t) :
    normalizedSineKernel a t≤a^2*t^3/Real.sinh (Real.pi*t/2) := by
  have hs : 0<Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
  have hsin : |Real.sin (a*t)|≤a*t := by
    simpa only [abs_of_pos (mul_pos ha ht)] using (Real.abs_sin_le_abs (x:=a*t))
  have hp:=pow_le_pow_left₀ (abs_nonneg _) hsin 3
  unfold normalizedSineKernel absoluteSineKernel
  apply (div_le_iff₀ ha).mpr
  apply (div_le_iff₀ hs).mpr
  field_simp [hs.ne']
  nlinarith

lemma normalizedSineKernel_large {a t:ℝ} (ha:0<a) (ht:0<t) :
    normalizedSineKernel a t≤a⁻¹/Real.sinh (Real.pi*t/2) := by
  have hs : 0<Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
  have hp : |Real.sin (a*t)|^3≤1 := pow_le_one₀ (abs_nonneg _) (Real.abs_sin_le_one _)
  unfold normalizedSineKernel absoluteSineKernel
  calc
    _ ≤ (1/Real.sinh (Real.pi*t/2))/a := by gcongr
    _ = _ := by ring

lemma normalizedSineKernel_bound {a t:ℝ} (ha:0<a) (ht:0<t) :
    ‖normalizedSineKernel a t‖≤(4/Real.pi)*Real.exp (-(Real.pi/4)*t) := by
  rw [Real.norm_eq_abs,abs_of_nonneg (normalizedSineKernel_nonneg ha ht)]
  have hh:=sine_sinh_bound a (Real.pi/2) t (by positivity) ht
  have hkernel:=absoluteSineKernel_abs_le_sine 3 (by norm_num) a t
  rw [abs_of_nonneg (absoluteSineKernel_nonneg _ _ _ ht)] at hkernel
  unfold normalizedSineKernel
  apply (div_le_iff₀ ha).mpr
  calc
    _ ≤ |Real.sin (a*t)/Real.sinh (Real.pi*t/2)| := hkernel
    _ ≤ (4/Real.pi*Real.exp (-(Real.pi/4)*t))*a := by
      convert hh using 1 <;> try rw [abs_of_pos ha]
      · congr 2; ring
      · ring_nf

lemma normalizedSineKernel_tendsto_zero (t:ℝ) (ht:0<t) :
    Tendsto (fun a=>normalizedSineKernel a t) (𝓝[>] (0:ℝ)) (𝓝 0) := by
  have ha : ∀ᶠ a:ℝ in 𝓝[>] (0:ℝ),0<a := self_mem_nhdsWithin
  apply squeeze_zero' (ha.mono (fun a h=>normalizedSineKernel_nonneg h ht))
    (ha.mono (fun a h=>normalizedSineKernel_small h ht))
  have hh : Continuous (fun a:ℝ=>a^2*t^3/Real.sinh (Real.pi*t/2)) := by fun_prop
  have h := (hh.continuousAt (x:=0)).tendsto.mono_left
    (show (𝓝[>] (0:ℝ))≤𝓝 (0:ℝ) from nhdsWithin_le_nhds)
  simpa only [zero_pow (by decide : (2:ℕ)≠0),zero_mul,zero_div] using h

lemma normalizedSineKernel_tendsto_infty (t:ℝ) (ht:0<t) :
    Tendsto (fun a=>normalizedSineKernel a t) atTop (𝓝 0) := by
  have ha : ∀ᶠ a:ℝ in atTop,0<a := eventually_gt_atTop 0
  apply squeeze_zero' (ha.mono (fun a h=>normalizedSineKernel_nonneg h ht))
    (ha.mono (fun a h=>normalizedSineKernel_large h ht))
  simpa using tendsto_inv_atTop_zero.div_const (Real.sinh (Real.pi*t/2))

lemma sineEnvelope_eq_integral (a:ℝ) :
    sineEnvelope a=∫t:ℝ in Ioi 0, normalizedSineKernel a t := by
  unfold sineEnvelope absoluteSineMoment normalizedSineKernel
  rw [integral_div]

lemma sineEnvelope_tendsto_of_kernel {l:Filter ℝ} [l.IsCountablyGenerated]
    (ha:∀ᶠa in l,0<a)
    (hk:∀t:ℝ,0<t→Tendsto (fun a=>normalizedSineKernel a t) l (𝓝 0)) :
    Tendsto sineEnvelope l (𝓝 0) := by
  have hh := tendsto_integral_filter_of_dominated_convergence
    (μ:=volume.restrict (Ioi (0:ℝ)))
    (F:=normalizedSineKernel) (f:=fun _=>0)
    (fun t:ℝ=>(4/Real.pi)*Real.exp (-(Real.pi/4)*t))
    (Eventually.of_forall (fun a=>by
      apply Measurable.aestronglyMeasurable
      unfold normalizedSineKernel absoluteSineKernel
      fun_prop))
    (by
      filter_upwards [ha] with a ha
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact normalizedSineKernel_bound ha ht)
    ((integrableOn_exp_mul_Ioi (show -(Real.pi/4)<0 by nlinarith [Real.pi_pos]) 0).const_mul (4/Real.pi))
    (by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact hk t ht)
  simpa only [←sineEnvelope_eq_integral,integral_zero] using hh

theorem sineEnvelope_tendsto_zero : Tendsto sineEnvelope (𝓝[>] (0:ℝ)) (𝓝 0) :=
  sineEnvelope_tendsto_of_kernel self_mem_nhdsWithin normalizedSineKernel_tendsto_zero

theorem sineEnvelope_tendsto_infty : Tendsto sineEnvelope atTop (𝓝 0) :=
  sineEnvelope_tendsto_of_kernel (eventually_gt_atTop 0) normalizedSineKernel_tendsto_infty

theorem continuousOn_sineEnvelope : ContinuousOn sineEnvelope (Ioi 0) := by
  exact (continuous_absoluteSineMoment 3 (by norm_num)).continuousOn.div
    continuous_id.continuousOn (fun a ha=>ne_of_gt ha)

/-- Every positive superlevel of the scalar envelope lies in a compact gain interval. -/
theorem sineEnvelope_superlevel_compact {δ:ℝ} (hδ:0<δ) :
    ∃b B:ℝ,0<b ∧ b≤B ∧ ∀a:ℝ,0<a→δ≤sineEnvelope a→a∈Icc b B := by
  have hlo := (tendsto_order.mp sineEnvelope_tendsto_zero).2 δ hδ
  obtain ⟨b,hb,hsmall⟩ := mem_nhdsGT_iff_exists_Ioo_subset.mp hlo
  have hhi := (tendsto_order.mp sineEnvelope_tendsto_infty).2 δ hδ
  obtain ⟨B,hlarge⟩ := hhi.exists_forall_of_atTop
  refine ⟨b,max b B,hb,le_max_left _ _,?_⟩
  intro a ha hδa
  constructor
  · by_contra hh
    have hless := hsmall ⟨ha,lt_of_not_ge hh⟩
    exact (not_lt_of_ge hδa) hless
  · by_contra hh
    have hBa : B≤a := (le_max_right b B).trans (le_of_lt (lt_of_not_ge hh))
    exact (not_lt_of_ge hδa) (hlarge a hBa)

/-- The localization envelope is globally bounded independently of gain. -/
theorem sineEnvelope_bounded : ∃G:ℝ,0<G ∧ ∀a:ℝ,0<a→sineEnvelope a≤G := by
  obtain ⟨b,B,hb,hbB,hlevel⟩:=sineEnvelope_superlevel_compact (δ:=1) (by norm_num)
  have hc : ContinuousOn sineEnvelope (Icc b B) :=
    continuousOn_sineEnvelope.mono (fun a ha=>lt_of_lt_of_le hb ha.1)
  obtain ⟨G,hG⟩ := isCompact_Icc.bddAbove_image hc
  refine ⟨max 1 G,lt_of_lt_of_le (by norm_num) (le_max_left _ _),?_⟩
  intro a ha
  by_cases hsmall:sineEnvelope a<1
  · exact hsmall.le.trans (le_max_left _ _)
  · exact (hG (mem_image_of_mem sineEnvelope (hlevel a ha (le_of_not_gt hsmall)))).trans
      (le_max_right _ _)

end NeuralGeneralization.OnlineLowerTanh
