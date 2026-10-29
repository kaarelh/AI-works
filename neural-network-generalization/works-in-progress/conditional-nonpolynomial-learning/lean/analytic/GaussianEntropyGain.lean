import ScalarSubcriticalCost
import Mathlib.Analysis.Calculus.MeanValue
import Mathlib.Topology.Order.IntermediateValue

/-! The sharp Gaussian second-moment gain, constructed as the actual inverse
of the scalar Gaussian entropy cost. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

def gaussianVarianceCost (x : ℝ) : ℝ := (x-1-Real.log x)/2

lemma gaussianVarianceCost_continuousOn : ContinuousOn gaussianVarianceCost (Ici 1) := by
  unfold gaussianVarianceCost
  exact ((continuousOn_id.sub continuousOn_const).sub
    (Real.continuousOn_log.mono (fun x hx => by simp only [mem_Ici] at hx; exact ne_of_gt (by linarith)))).div_const 2

lemma gaussianVarianceCost_strictMonoOn : StrictMonoOn gaussianVarianceCost (Ici 1) := by
  intro a ha b hb hab
  have ha0 : 0<a := by exact lt_of_lt_of_le (by norm_num) ha
  have hr : 1<b/a := (one_lt_div ha0).mpr hab
  have hl := Real.log_lt_sub_one_of_pos (by positivity : 0<b/a) (ne_of_gt hr)
  rw [Real.log_div (by linarith : b≠0) ha0.ne'] at hl
  have hratio : b/a-1 ≤ b-a := by
    have hm := mul_nonneg (sub_nonneg.mpr (le_of_lt hab)) (sub_nonneg.mpr ha)
    apply (sub_le_iff_le_add).mpr
    apply (div_le_iff₀ ha0).mpr
    nlinarith
  unfold gaussianVarianceCost
  linarith

lemma log_le_half_of_two_le {x : ℝ} (hx : 2≤x) : Real.log x≤x/2 := by
  have hx0 : 0<x/2 := by linarith
  have h := Real.log_le_sub_one_of_pos hx0
  rw [Real.log_div (by linarith : x≠0) (by norm_num)] at h
  have h2 := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  linarith

theorem exists_gaussianEntropyGain {D : ℝ} (hD : 0≤D) :
    ∃ x : ℝ, 1≤x ∧ gaussianVarianceCost x=D := by
  have hV : 1≤4*D+4 := by linarith
  have hcost : D≤gaussianVarianceCost (4*D+4) := by
    have hl := log_le_half_of_two_le (x:=4*D+4) (by linarith)
    unfold gaussianVarianceCost
    linarith
  have hc : ContinuousOn gaussianVarianceCost (Icc 1 (4*D+4)) :=
    gaussianVarianceCost_continuousOn.mono (fun x hx => hx.1)
  have hh := intermediate_value_Icc hV hc
    (show D∈Icc (gaussianVarianceCost 1) (gaussianVarianceCost (4*D+4)) from
      ⟨by simpa [gaussianVarianceCost] using hD,hcost⟩)
  obtain ⟨x,hx,he⟩ := hh
  exact ⟨x,hx.1,he⟩

def gaussianEntropyGain (D : ℝ) : ℝ :=
  if h : 0≤D then Classical.choose (exists_gaussianEntropyGain h) else 1

theorem gaussianEntropyGain_one_le (D : ℝ) : 1≤gaussianEntropyGain D := by
  unfold gaussianEntropyGain
  split
  · exact (Classical.choose_spec (exists_gaussianEntropyGain ‹0≤D›)).1
  · exact le_rfl

theorem gaussianEntropyGain_cost {D : ℝ} (hD : 0≤D) :
    gaussianVarianceCost (gaussianEntropyGain D)=D := by
  rw [gaussianEntropyGain,dif_pos hD]
  exact (Classical.choose_spec (exists_gaussianEntropyGain hD)).2

theorem gaussianVarianceCost_le_iff {D x : ℝ} (hD : 0≤D) (hx : 1≤x) :
    gaussianVarianceCost x≤D ↔ x≤gaussianEntropyGain D := by
  nth_rw 1 [← gaussianEntropyGain_cost hD]
  exact gaussianVarianceCost_strictMonoOn.le_iff_le hx (gaussianEntropyGain_one_le D)

theorem actual_scalar_moment_le_gain
    (Q : Measure ℝ) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (gaussianReal 0 1) ≠ ∞) :
    (∫ z : ℝ,z^2 ∂Q)≤gaussianEntropyGain ((klDiv Q (gaussianReal 0 1)).toReal) := by
  by_cases h : 1≤∫ z : ℝ,z^2 ∂Q
  · exact (gaussianVarianceCost_le_iff ENNReal.toReal_nonneg h).mp
      (scalar_gaussian_second_moment_entropy Q hKL)
  · exact (le_of_not_ge h).trans (gaussianEntropyGain_one_le _)

/-- Exact gain identity after multiplying the reference standard deviation
by sqrt(v); valid uniformly for every positive v. -/
theorem gaussianEntropyGain_adjusted_identity {D : ℝ} (hD : 0≤D)
    (v : ℝ≥0) (hv : v ≠ 0) :
    let a : ℝ := (v:ℝ)⁻¹-1
    let g := Real.log (Real.sqrt (v:ℝ)*Real.sqrt (gaussianEntropyGain D))
    D-subcriticalCostBaseline v = a*g+
      (1+a)/2*(Real.exp (2*g)-1-2*g) := by
  dsimp only
  have hvp : 0<(v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  have hgp : 0<gaussianEntropyGain D := lt_of_lt_of_le (by norm_num) (gaussianEntropyGain_one_le D)
  have hl : Real.log (Real.sqrt (v:ℝ)*Real.sqrt (gaussianEntropyGain D)) =
      (Real.log (v:ℝ)+Real.log (gaussianEntropyGain D))/2 := by
    rw [Real.log_mul (Real.sqrt_pos.mpr hvp).ne' (Real.sqrt_pos.mpr hgp).ne',
      Real.log_sqrt hvp.le,Real.log_sqrt hgp.le]
    ring
  have he : Real.exp (2*Real.log (Real.sqrt (v:ℝ)*Real.sqrt (gaussianEntropyGain D))) =
      (v:ℝ)*gaussianEntropyGain D := by
    rw [hl,show 2*((Real.log (v:ℝ)+Real.log (gaussianEntropyGain D))/2)=
      Real.log (v:ℝ)+Real.log (gaussianEntropyGain D) by ring,
      Real.exp_add,Real.exp_log hvp,Real.exp_log hgp]
  rw [he,hl]
  have hc := gaussianEntropyGain_cost hD
  unfold gaussianVarianceCost at hc
  nth_rw 1 [← hc]
  unfold subcriticalCostBaseline
  field_simp
  <;> ring

#print axioms actual_scalar_moment_le_gain
#print axioms gaussianEntropyGain_adjusted_identity

lemma exp_two_remainder_nonneg (g : ℝ) : 0≤Real.exp (2*g)-1-2*g := by
  linarith [Real.add_one_le_exp (2*g)]

lemma exp_two_remainder_ge_square {g : ℝ} (hg : 0≤g) :
    g^2≤Real.exp (2*g)-1-2*g := by
  have h := Real.add_one_le_exp g
  have hh := pow_le_pow_left₀ (by linarith : 0≤g+1) h 2
  have he : Real.exp (2*g)=(Real.exp g)^2 := by
    rw [show 2*g=g+g by ring,Real.exp_add,pow_two]
  rw [he]
  nlinarith

/-- Algebraic consequence of the exact adjusted gain identity. Both gain
estimates are uniform in the subcritical parameter a. -/
theorem adjusted_gain_bounds {a e g u : ℝ} (ha : 0≤a) (he : 0≤e)
    (hu : u≤3*Real.sqrt e)
    (hidentity : a*g+(1+a)/2*(Real.exp (2*g)-1-2*g)=a*u/2+e) :
    g≤2*Real.sqrt e ∧ (0<a → g≤u/2+e/a) := by
  have hr := exp_two_remainder_nonneg g
  constructor
  · by_contra hn
    have hgp : 0<g := lt_of_le_of_lt (by positivity) (lt_of_not_ge hn)
    have hs := Real.sq_sqrt he
    have hs0 := Real.sqrt_nonneg e
    have hexp := exp_two_remainder_ge_square hgp.le
    have hrem : g^2/2≤(1+a)/2*(Real.exp (2*g)-1-2*g) := by
      nlinarith [mul_nonneg ha hr]
    have hau := mul_le_mul_of_nonneg_left hu ha
    have hgap := mul_nonneg ha (show 0≤g-3*Real.sqrt e/2 by linarith)
    nlinarith
  · intro hap
    have hrem := mul_nonneg (show 0≤(1+a)/2 by positivity) hr
    have hh : a*(g-u/2)≤e := by nlinarith
    have hd : g-u/2≤e/a := (le_div_iff₀ hap).mpr (by nlinarith)
    linarith

#print axioms adjusted_gain_bounds
end ConditionalNonpolynomial.Analytic
