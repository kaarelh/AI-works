import NeuralGeneralization.OnlineLowerBernsteinBounds
import NeuralGeneralization.OnlineLowerArcsine
import NeuralGeneralization.OnlineLowerCostIntegral

/-!
# Arcsine averages of the concrete smooth kernel

All averages use the actual normalized beta(1/2,1/2) measure. The derivative
and domination statements below are the analytic inputs to the Laplace identity.
-/

noncomputable section
open MeasureTheory Set Filter
open scoped Topology

namespace NeuralGeneralization.OnlineLowerBernstein

def arcAverage (j : ℕ) (f : ℝ → ℝ) (t : ℝ) : ℝ :=
  ∫ u, u ^ j * f (t * u) ∂arcsineMeasure

theorem scaled_integrand_bound (j : ℕ) (f : ℝ → ℝ) (C t u : ℝ)
    (hC : 0 ≤ C) (hf : ∀ x, |f x| ≤ C * Real.exp (|x| / 2))
    (hu0 : 0 ≤ u) (hu1 : u ≤ 1) :
    |u ^ j * f (t * u)| ≤ C * Real.exp (|t| / 2) := by
  have hup : u ^ j ≤ 1 := pow_le_one₀ hu0 hu1
  have harg : |t * u| ≤ |t| := by
    rw [abs_mul, abs_of_nonneg hu0]
    exact mul_le_of_le_one_right (abs_nonneg t) hu1
  calc
    _ = u ^ j * |f (t * u)| := by rw [abs_mul, abs_of_nonneg (pow_nonneg hu0 j)]
    _ ≤ |f (t * u)| := mul_le_of_le_one_left (abs_nonneg _) hup
    _ ≤ C * Real.exp (|t * u| / 2) := hf _
    _ ≤ C * Real.exp (|t| / 2) := mul_le_mul_of_nonneg_left
      (Real.exp_le_exp.mpr (by linarith)) hC

theorem arcAverage_integrable (j : ℕ) (f : ℝ → ℝ) (C t : ℝ)
    (hc : Continuous f) (hC : 0 ≤ C)
    (hf : ∀ x, |f x| ≤ C * Real.exp (|x| / 2)) :
    Integrable (fun u => u ^ j * f (t * u)) arcsineMeasure := by
  apply (integrable_const (C * Real.exp (|t| / 2))).mono'
    (((continuous_id.pow j).mul (hc.comp (continuous_const.mul continuous_id))).aestronglyMeasurable)
  filter_upwards [arcsine_ae_mem] with u hu
  change |u ^ j * f (t * u)| ≤ C * Real.exp (|t| / 2)
  exact scaled_integrand_bound j f C t u hC hf hu.1.le hu.2.le

theorem arcAverage_abs_bound (j : ℕ) (f : ℝ → ℝ) (C t : ℝ)
    (hC : 0 ≤ C) (hf : ∀ x, |f x| ≤ C * Real.exp (|x| / 2)) :
    |arcAverage j f t| ≤ C * Real.exp (|t| / 2) := by
  have h := norm_integral_le_of_norm_le_const (μ := arcsineMeasure) (f := fun u => u ^ j * f (t * u))
    (C := C * Real.exp (|t| / 2)) ?_
  · simpa [arcAverage, Real.norm_eq_abs] using h
  · filter_upwards [arcsine_ae_mem] with u hu
    simpa only [Real.norm_eq_abs] using scaled_integrand_bound j f C t u hC hf hu.1.le hu.2.le

theorem arcAverage_hasDerivAt (j : ℕ) (f f' : ℝ → ℝ) (C C' t : ℝ)
    (hd : ∀ x, HasDerivAt f (f' x) x) (hc' : Continuous f')
    (hC : 0 ≤ C) (hC' : 0 ≤ C')
    (hf : ∀ x, |f x| ≤ C * Real.exp (|x| / 2))
    (hf' : ∀ x, |f' x| ≤ C' * Real.exp (|x| / 2)) :
    HasDerivAt (arcAverage j f) (arcAverage (j + 1) f' t) t := by
  have hc : Continuous f := continuous_iff_continuousAt.mpr fun x => (hd x).continuousAt
  let F : ℝ → ℝ → ℝ := fun x u => u ^ j * f (x * u)
  let F' : ℝ → ℝ → ℝ := fun x u => u ^ (j + 1) * f' (x * u)
  let bound : ℝ → ℝ := fun _ => C' * Real.exp ((|t| + 1) / 2)
  have hdiff (u x : ℝ) : HasDerivAt (fun z => F z u) (F' x u) x := by
    convert! (((hd (x * u)).comp x ((hasDerivAt_id x).mul_const u)).const_mul (u ^ j)) using 1 <;>
      (try dsimp [F, F']) <;> ring
  have hbound : ∀ᵐ u ∂arcsineMeasure, ∀ x ∈ Metric.ball t 1, ‖F' x u‖ ≤ bound u := by
    filter_upwards [arcsine_ae_mem] with u hu
    intro x hx
    have hxt : |x - t| < 1 := by simpa [Real.dist_eq] using hx
    have hxabs : |x| ≤ |t| + 1 := by
      have h := abs_add_le (x - t) t
      rw [sub_add_cancel] at h
      linarith
    calc
      _ ≤ C' * Real.exp (|x| / 2) := by
        simpa [F', Real.norm_eq_abs] using
          scaled_integrand_bound (j + 1) f' C' x u hC' hf' hu.1.le hu.2.le
      _ ≤ bound u := mul_le_mul_of_nonneg_left
        (Real.exp_le_exp.mpr (by linarith)) hC'
  have hi := arcAverage_integrable j f C t hc hC hf
  have hm : ∀ᶠ x in 𝓝 t, AEStronglyMeasurable (F x) arcsineMeasure :=
    Eventually.of_forall fun x =>
      ((continuous_id.pow j).mul (hc.comp (continuous_const.mul continuous_id))).aestronglyMeasurable
  have hm' : AEStronglyMeasurable (F' t) arcsineMeasure :=
    ((continuous_id.pow (j + 1)).mul (hc'.comp (continuous_const.mul continuous_id))).aestronglyMeasurable
  exact (hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (Metric.ball_mem_nhds t (by norm_num : (0 : ℝ) < 1)) hm hi hm' hbound
      (integrable_const _) (Eventually.of_forall fun u x _ => hdiff u x)).2

theorem moment_continuous (j : ℕ) : Continuous (moment j) :=
  continuous_iff_continuousAt.mpr fun t => (moment_hasDerivAt j t).continuousAt

theorem kernel_continuous : Continuous kernel :=
  continuous_iff_continuousAt.mpr fun t => (kernel_hasDerivAt t).continuousAt

theorem kernelPrime_continuous : Continuous kernelPrime :=
  continuous_iff_continuousAt.mpr fun t => (kernelPrime_hasDerivAt t).continuousAt

theorem kernelSecond_continuous : Continuous kernelSecond := by
  have hs := Real.continuous_sqrt.comp (moment_continuous 0)
  have hn (p : ℕ) (a : ℝ) (ha : 0 < a) (t : ℝ) :
      a * Real.sqrt (moment 0 t) ^ p ≠ 0 :=
    (mul_pos ha (pow_pos (Real.sqrt_pos.mpr (moment_pos 0 t)) p)).ne'
  unfold kernelSecond secondKernelDerivative
  exact (((continuous_const.mul ((moment_continuous 1).pow 2)).div
    (continuous_const.mul (hs.pow 5)) (hn 5 4 (by norm_num))).sub
      ((moment_continuous 2).div (continuous_const.mul (hs.pow 3)) (hn 3 2 (by norm_num))))

def B (t : ℝ) : ℝ := arcAverage 0 kernel t
def Bprime (t : ℝ) : ℝ := arcAverage 1 kernelPrime t
def Bsecond (t : ℝ) : ℝ := arcAverage 2 kernelSecond t
def positiveKernel (t : ℝ) : ℝ := Bprime t / 2 - Bsecond t

theorem B_hasDerivAt (t : ℝ) : HasDerivAt B (Bprime t) t := by
  exact arcAverage_hasDerivAt 0 kernel kernelPrime 1 (1 / 2) t
    kernel_hasDerivAt kernelPrime_continuous (by norm_num) (by norm_num)
    (fun x => by simpa [abs_of_pos (kernel_pos x)] using kernel_bound x) kernelPrime_abs_bound

theorem Bprime_hasDerivAt (t : ℝ) : HasDerivAt Bprime (Bsecond t) t :=
  arcAverage_hasDerivAt 1 kernelPrime kernelSecond (1 / 2) (5 / 4) t
    kernelPrime_hasDerivAt kernelSecond_continuous (by norm_num) (by norm_num)
    kernelPrime_abs_bound kernelSecond_abs_bound

theorem B_zero : B 0 = 1 := by
  simp [B, arcAverage, kernel_zero]

theorem Bprime_zero : Bprime 0 = 1 / 8 := by
  norm_num [Bprime, arcAverage, kernelPrime_zero, integral_mul_const, arcsine_mean]

theorem B_abs_bound (t : ℝ) : |B t| ≤ Real.exp (|t| / 2) := by
  simpa [B] using arcAverage_abs_bound 0 kernel 1 t (by norm_num)
    (fun x => by simpa [abs_of_pos (kernel_pos x)] using kernel_bound x)

theorem Bprime_abs_bound (t : ℝ) : |Bprime t| ≤ (1 / 2) * Real.exp (|t| / 2) :=
  arcAverage_abs_bound 1 kernelPrime (1 / 2) t (by norm_num) kernelPrime_abs_bound

theorem Bsecond_abs_bound (t : ℝ) : |Bsecond t| ≤ (5 / 4) * Real.exp (|t| / 2) :=
  arcAverage_abs_bound 2 kernelSecond (5 / 4) t (by norm_num) kernelSecond_abs_bound

end NeuralGeneralization.OnlineLowerBernstein
