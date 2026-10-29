import SmoothedTanhBounds
import ScalarBellman
import Mathlib.Analysis.Convex.Deriv

noncomputable section
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.BatchTwoContinuousDepthCritical
open NeuralGeneralization.TanhDifferential NeuralGeneralization.BatchTwoNonGaussian

theorem tanh_concave_nonnegative : ConcaveOn ℝ (Ici 0) Real.tanh := by
  apply AntitoneOn.concaveOn_of_deriv (convex_Ici 0) continuous_tanh.continuousOn
    (fun x _ => (hasDerivAt_tanh_first x).differentiableAt.differentiableWithinAt)
  intro x hx y hy hxy
  rw [(hasDerivAt_tanh_first x).deriv,(hasDerivAt_tanh_first y).deriv]
  have hx0 : 0 ≤ x := interior_subset hx
  have ht0 : 0 ≤ Real.tanh x := by simpa only [Real.tanh_zero] using tanh_monotone hx0
  have hm := tanh_monotone hxy
  unfold tanhFirst
  nlinarith

theorem tanh_subscale {t x : ℝ} (ht : 0 ≤ t) (ht1 : t ≤ 1) (hx : 0 ≤ x) :
    t*Real.tanh x ≤ Real.tanh (t*x) := by
  have hh := tanh_concave_nonnegative.2 (show x ∈ Ici 0 from hx)
    (show (0:ℝ) ∈ Ici 0 by norm_num) ht (show 0 ≤ 1-t by linarith) (by ring : t+(1-t)=1)
  simpa only [smul_eq_mul,Real.tanh_zero,mul_zero,add_zero] using hh

theorem shiftedMean_scaled_square_bounds {r t : ℝ} (hr : 0 ≤ r) (hr1 : r ≤ 1)
    (ht : 0 ≤ t) (ht1 : t ≤ 1) (z : ℝ) :
    (1-r)^2*t^2*(Real.tanh z)^2 ≤ (shiftedMean r (t*z))^2 ∧
      (shiftedMean r (t*z))^2 ≤ (Real.tanh z)^2 := by
  have hpos (x : ℝ) (hx : 0 ≤ x) :
      (1-r)^2*t^2*(Real.tanh x)^2 ≤ (shiftedMean r (t*x))^2 ∧
        (shiftedMean r (t*x))^2 ≤ (Real.tanh x)^2 := by
    have hb := shiftedMean_tanh_bounds hr (mul_nonneg ht hx)
    have hc := tanh_subscale ht ht1 hx
    have hm := tanh_monotone (show t*x ≤ x by nlinarith)
    have hx0 : 0 ≤ Real.tanh x := by simpa only [Real.tanh_zero] using tanh_monotone hx
    have hsig : 0 ≤ shiftedMean r (t*x) := shiftedMean_nonneg (mul_nonneg ht hx) r
    have hlow : (1-r)*t*Real.tanh x ≤ shiftedMean r (t*x) := by
      have hp := mul_le_mul_of_nonneg_left hc (show 0 ≤ 1-r by linarith)
      nlinarith
    have hlow0 : 0 ≤ (1-r)*t*Real.tanh x := mul_nonneg (mul_nonneg (by linarith) ht) hx0
    constructor
    · have hs := pow_le_pow_left₀ hlow0 hlow 2
      simpa only [mul_pow] using hs
    · exact pow_le_pow_left₀ hsig (hb.2.trans hm) 2
  rcases le_total 0 z with hz | hz
  · exact hpos z hz
  · have hh := hpos (-z) (by linarith)
    simpa only [mul_neg,shiftedMean_odd,neg_sq,Real.tanh_neg] using hh

def controlledSignal (Q : Measure ℝ) (a r : ℝ) : ℝ :=
  ∫ z, (shiftedMean r (Real.sqrt a*z))^2 ∂Q

def controlledResidual (Q : Measure ℝ) (a r : ℝ) : ℝ :=
  ∫ z, shiftedVariance r (Real.sqrt a*z) ∂Q

theorem controlledSignal_integrable (Q : Measure ℝ) [IsProbabilityMeasure Q] (a r : ℝ) :
    Integrable (fun z : ℝ => (shiftedMean r (Real.sqrt a*z))^2) Q := by
  apply Integrable.of_bound
    ((shiftedMean_continuous.comp (continuous_const.prodMk (by fun_prop))).pow 2).aestronglyMeasurable 1
  filter_upwards [] with z
  change ‖(shiftedMean r (Real.sqrt a*z))^2‖ ≤ 1
  rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
  exact (sq_le_one_iff_abs_le_one _).mpr (shiftedMean_abs_le_one _ _)

theorem controlledSignal_bounds (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {a q r : ℝ} (ha : 0 ≤ a) (hq : 0 < q) (haq : a ≤ q)
    (hr : 0 ≤ r) (hr1 : r ≤ 1) :
    (1-r)^2*(a/q)*scalarTransition q Q ≤ controlledSignal Q a r ∧
      controlledSignal Q a r ≤ scalarTransition q Q := by
  let t := Real.sqrt a/Real.sqrt q
  have ht : 0 ≤ t := by dsimp [t]; positivity
  have ht1 : t ≤ 1 := (div_le_one (Real.sqrt_pos.mpr hq)).mpr (Real.sqrt_le_sqrt haq)
  have he (z : ℝ) : t*(Real.sqrt q*z)=Real.sqrt a*z := by
    dsimp [t]
    field_simp
  have ht2 : t^2=a/q := by dsimp [t]; rw [div_pow,Real.sq_sqrt ha,Real.sq_sqrt hq.le]
  have hp (z : ℝ) := shiftedMean_scaled_square_bounds hr hr1 ht ht1 (Real.sqrt q*z)
  simp only [he,ht2] at hp
  have hv : Integrable (fun z : ℝ => (Real.tanh (Real.sqrt q*z))^2) Q := by
    apply Integrable.of_bound (by fun_prop) 1
    filter_upwards [] with z
    rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
    exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le
  have hlo := integral_mono (hv.const_mul ((1-r)^2*(a/q)))
    (controlledSignal_integrable Q a r) (fun z => (hp z).1)
  rw [integral_const_mul] at hlo
  exact ⟨hlo,integral_mono (controlledSignal_integrable Q a r) hv (fun z => (hp z).2)⟩

theorem controlledResidual_integrable (Q : Measure ℝ) [IsProbabilityMeasure Q] (a r : ℝ) :
    Integrable (fun z : ℝ => shiftedVariance r (Real.sqrt a*z)) Q := by
  apply Integrable.of_bound
    ((shiftedVariance_continuous.comp (continuous_const.prodMk (by fun_prop))).aestronglyMeasurable) 1
  filter_upwards [] with z
  change ‖shiftedVariance r (Real.sqrt a*z)‖ ≤ 1
  rw [Real.norm_eq_abs,abs_of_nonneg (shiftedVariance_nonneg _ _)]
  exact shiftedVariance_le_one _ _

theorem controlledResidual_bounds (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {r : ℝ} (hr : 0 ≤ r) (a : ℝ) : 0 ≤ controlledResidual Q a r ∧ controlledResidual Q a r ≤ r := by
  refine ⟨integral_nonneg (fun z => shiftedVariance_nonneg _ _),?_⟩
  have hh := integral_mono (controlledResidual_integrable Q a r) (integrable_const r)
    (fun z => shiftedVariance_le hr (Real.sqrt a*z))
  simpa only [controlledResidual,integral_const,probReal_univ,smul_eq_mul,one_mul] using hh

#print axioms controlledSignal_bounds
#print axioms controlledResidual_bounds
end ConditionalNonpolynomial.Analytic
