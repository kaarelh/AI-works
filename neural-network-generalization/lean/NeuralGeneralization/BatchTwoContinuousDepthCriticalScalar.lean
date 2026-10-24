import NeuralGeneralization.BatchTwoNeuralConverseRelays
import NeuralGeneralization.BatchTwoNonGaussianSmallBallKernel
import NeuralGeneralization.BatchTwoNonGaussianGaussianInstance
import NeuralGeneralization.GaussianProductStein

/-! Scalar estimates for the zero-cost Gaussian cooling layers in the critical
continuous-depth lower bound. All functions and expectations are actual tanh
and Gaussian objects. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical
open ConcreteModel TanhDifferential BatchTwoNonGaussian

theorem tanh_quartic_loss_nonneg {x : ℝ} (hx : 0≤x) (hx1 : x≤1) :
    x^4/6≤x^2-(Real.tanh x)^2 := by
  have hs (t : ℝ) (ht : 0≤t) (ht1 : t≤1) : t^2/2≤(Real.tanh t)^2 := by
    have hp : 0<1+t^2 := by positivity
    have hl := BatchTwoNeuralConverse.tanh_lower_square_root ht
    have hr : 0≤t/Real.sqrt (1+t^2) := by positivity
    have hh := pow_le_pow_left₀ hr hl 2
    rw [div_pow,Real.sq_sqrt hp.le] at hh
    have hh' := (div_le_iff₀ hp).mp hh
    have ht2 : t^2≤1 := by nlinarith
    nlinarith [sq_nonneg (Real.tanh t),mul_nonneg (sq_nonneg (Real.tanh t)) (sub_nonneg.mpr ht2)]
  let g : ℝ→ℝ := fun t=>t-Real.tanh t-t^3/6
  have hg (t : ℝ) : HasDerivAt g ((Real.tanh t)^2-t^2/2) t := by
    convert! (((hasDerivAt_id t).sub (hasDerivAt_tanh_first t)).sub
      (((hasDerivAt_id t).pow 3).div_const 6)) using 1 <;>
      simp [g,tanhFirst] <;> ring
  have hm : MonotoneOn g (Icc 0 1) := monotoneOn_of_deriv_nonneg (convex_Icc 0 1)
    (fun t _ => (hg t).continuousAt.continuousWithinAt)
    (fun t _ => (hg t).differentiableAt.differentiableWithinAt)
    (fun t ht => by
      rw [(hg t).deriv]
      have hti : t∈Icc (0:ℝ) 1 := interior_subset ht
      exact sub_nonneg.mpr (hs t hti.1 hti.2))
  have hg0 := hm (show (0:ℝ)∈Icc 0 1 by norm_num) ⟨hx,hx1⟩ hx
  simp only [g,Real.tanh_zero,sub_zero,zero_pow,zero_div] at hg0
  have ht0 : 0≤Real.tanh x := by simpa only [Real.tanh_zero] using BatchTwoNonGaussian.tanh_monotone hx
  have htx : Real.tanh x≤x := by
    have hh := abs_tanh_le_abs x
    rwa [abs_of_nonneg ht0,abs_of_nonneg hx] at hh
  have hh := mul_nonneg (sub_nonneg.mpr htx) ht0
  have hh' := mul_le_mul_of_nonneg_left hg0 hx
  nlinarith

theorem tanh_quartic_loss {x : ℝ} (hx : |x|≤1) : x^4/6≤x^2-(Real.tanh x)^2 := by
  rcases le_total 0 x with h | h
  · exact tanh_quartic_loss_nonneg h ((le_abs_self x).trans hx)
  · have hh := tanh_quartic_loss_nonneg (neg_nonneg.mpr h) (by simpa [abs_of_nonpos h] using hx)
    simpa only [Real.tanh_neg,neg_sq,show (-x)^4=x^4 by ring] using hh

def coolingSecondMoment (q : ℝ) : ℝ :=
  ∫ z, (Real.tanh (Real.sqrt q*z))^2 ∂gaussianReal 0 1

def coolingDerivative (q : ℝ) : ℝ :=
  ∫ z, tanhFirst (Real.sqrt q*z) ∂gaussianReal 0 1

theorem cooling_second_integrable (q : ℝ) :
    Integrable (fun z=> (Real.tanh (Real.sqrt q*z))^2) (gaussianReal 0 1) := by
  apply Integrable.of_bound (by fun_prop) 1
  filter_upwards [] with z
  rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
  exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le

theorem cooling_derivative_integrable (q : ℝ) :
    Integrable (fun z=> tanhFirst (Real.sqrt q*z)) (gaussianReal 0 1) := by
  apply Integrable.of_bound (by fun_prop) 1
  filter_upwards [] with z
  exact abs_tanhFirst_le_one _

theorem coolingDerivative_eq (q : ℝ) : coolingDerivative q=1-coolingSecondMoment q := by
  unfold coolingDerivative coolingSecondMoment tanhFirst
  rw [integral_sub (integrable_const _) (cooling_second_integrable q)]
  simp

theorem coolingSecondMoment_nonneg (q : ℝ) : 0≤coolingSecondMoment q := integral_nonneg (fun _ => sq_nonneg _)

theorem coolingDerivative_pos (q : ℝ) : 0<coolingDerivative q := by
  unfold coolingDerivative
  apply (integral_pos_iff_support_of_nonneg (fun z=>tanhFirst_nonneg _) (cooling_derivative_integrable q)).mpr
  have he : Function.support (fun z=>tanhFirst (Real.sqrt q*z))=univ := by
    ext z
    simp only [Function.mem_support,mem_univ,iff_true]
    unfold tanhFirst
    have hh := (sq_lt_one_iff_abs_lt_one _).mpr (Real.abs_tanh_lt_one (Real.sqrt q*z))
    linarith
  rw [he]
  simp

theorem coolingSecondMoment_le (q : ℝ) (hq : 0≤q) : coolingSecondMoment q≤q := by
  have hi : Integrable (fun z:ℝ=>q*z^2) (gaussianReal 0 1) := standardGaussian.square_integrable.const_mul q
  have hm := integral_mono (cooling_second_integrable q) hi (fun z=>by
    have hs := pow_le_pow_left₀ (abs_nonneg _) (abs_tanh_le_abs (Real.sqrt q*z)) 2
    simpa only [sq_abs,mul_pow,Real.sq_sqrt hq] using hs)
  have hg : (∫ z:ℝ,z^2 ∂gaussianReal 0 1)=1 := standardGaussian.square_integral
  rw [integral_const_mul,hg,mul_one] at hm
  exact hm

end NeuralGeneralization.BatchTwoContinuousDepthCritical
