import NeuralGeneralization.OnlineLowerBernsteinMoments
import Mathlib.Analysis.Calculus.ParametricIntegral
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Sqrt
import Mathlib.Analysis.Calculus.Deriv.Inv

/-! Differentiation of the actual tilted moments on the compact unit interval. -/

noncomputable section
open MeasureTheory Set Filter
open scoped Topology

namespace NeuralGeneralization.OnlineLowerBernstein

theorem moment_hasDerivAt (j : ℕ) (t : ℝ) :
    HasDerivAt (moment j) (-moment (j + 1) t) t := by
  let μ := volume.restrict (Ioc (0 : ℝ) 1)
  let F : ℝ → ℝ → ℝ := fun x u => u ^ j * Real.exp (-u * x)
  let F' : ℝ → ℝ → ℝ := fun x u => -(u ^ (j + 1) * Real.exp (-u * x))
  let bound : ℝ → ℝ := fun _ => Real.exp (|t| + 1)
  have hdiff (u x : ℝ) : HasDerivAt (fun z => F z u) (F' x u) x := by
    convert! ((((hasDerivAt_id x).const_mul (-u)).exp).const_mul (u ^ j)) using 1 <;>
      (try dsimp [F, F']) <;> ring
  have hbound : ∀ᵐ u ∂μ, ∀ x ∈ Metric.ball t 1, ‖F' x u‖ ≤ bound u := by
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with u hu
    intro x hx
    have hu0 : 0 ≤ u := hu.1.le
    have hu1 : u ≤ 1 := hu.2
    have hpow : u ^ (j + 1) ≤ 1 := pow_le_one₀ hu0 hu1
    have hxt : |x - t| < 1 := by simpa [Real.dist_eq] using hx
    have hxabs : |x| ≤ |t| + 1 := by
      have h := abs_add_le (x - t) t
      rw [sub_add_cancel] at h
      linarith
    have harg : -u * x ≤ |t| + 1 := by
      calc
        -u * x ≤ |u * x| := by simpa using neg_le_abs (u * x)
        _ = u * |x| := by rw [abs_mul, abs_of_nonneg hu0]
        _ ≤ |x| := mul_le_of_le_one_left (abs_nonneg x) hu1
        _ ≤ |t| + 1 := hxabs
    dsimp [F', bound]
    simp only [abs_neg]
    rw [abs_of_nonneg
      (mul_nonneg (pow_nonneg hu0 _) (Real.exp_pos _).le)]
    calc
      _ ≤ Real.exp (-u * x) := mul_le_of_le_one_left (Real.exp_pos _).le hpow
      _ ≤ Real.exp (|t| + 1) := Real.exp_le_exp.mpr harg
  have hFint : Integrable (F t) μ := (momentIntegrand_integrable j t).1
  have hFmeas : ∀ᶠ x in 𝓝 t, AEStronglyMeasurable (F x) μ :=
    Eventually.of_forall fun x => (momentIntegrand_continuous j x).aestronglyMeasurable
  have hF'meas : AEStronglyMeasurable (F' t) μ :=
    (momentIntegrand_continuous (j + 1) t).neg.aestronglyMeasurable
  have hbi : Integrable bound μ := integrable_const _
  have key := (hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (Metric.ball_mem_nhds t (by norm_num : (0 : ℝ) < 1)) hFmeas hFint
      hF'meas hbound hbi (Eventually.of_forall fun u x _ => hdiff u x)).2
  convert! key using 1
  · funext x
    simp only [moment, intervalIntegral.integral_of_le (show (0 : ℝ) ≤ 1 by norm_num)]
    rfl
  · simp only [moment, intervalIntegral.integral_of_le (show (0 : ℝ) ≤ 1 by norm_num)]
    simp [μ, F', integral_neg]

/-- A smooth definition at zero: on `t > 0` this is
`sqrt(t / (1 - exp(-t)))`, without a removable singularity in the definition. -/
def kernel (t : ℝ) : ℝ := 1 / Real.sqrt (moment 0 t)

def kernelPrime (t : ℝ) : ℝ :=
  firstKernelDerivative (moment 0 t) (moment 1 t)

def kernelSecond (t : ℝ) : ℝ :=
  secondKernelDerivative (moment 0 t) (moment 1 t) (moment 2 t)

theorem kernel_pos (t : ℝ) : 0 < kernel t :=
  div_pos zero_lt_one (Real.sqrt_pos.mpr (moment_pos 0 t))

theorem kernelPrime_pos (t : ℝ) : 0 < kernelPrime t :=
  firstKernelDerivative_pos _ _ (moment_pos 0 t) (moment_pos 1 t)

theorem kernelSecond_lt_half_prime (t : ℝ) : kernelSecond t < kernelPrime t / 2 :=
  actual_secondKernelDerivative_lt_half_first t

theorem kernelPrime_eq (t : ℝ) :
    kernelPrime t = moment 1 t * kernel t ^ 3 / 2 := by
  unfold kernelPrime kernel firstKernelDerivative
  field_simp

theorem kernelSecond_eq (t : ℝ) :
    kernelSecond t = 3 * moment 1 t ^ 2 * kernel t ^ 5 / 4 -
      moment 2 t * kernel t ^ 3 / 2 := by
  unfold kernelSecond kernel secondKernelDerivative
  field_simp

theorem kernel_hasDerivAt (t : ℝ) : HasDerivAt kernel (kernelPrime t) t := by
  have hq := moment_hasDerivAt 0 t
  have hs := Real.sqrt_pos.mpr (moment_pos 0 t)
  have h := (hq.sqrt (moment_pos 0 t).ne').inv hs.ne'
  convert! h using 1
  · funext x
    simp [kernel, one_div]
  · simp only [kernelPrime, firstKernelDerivative, zero_add] 
    field_simp

theorem kernelPrime_hasDerivAt (t : ℝ) :
    HasDerivAt kernelPrime (kernelSecond t) t := by
  have h := ((moment_hasDerivAt 1 t).mul ((kernel_hasDerivAt t).pow 3)).div_const 2
  convert! h using 1
  · funext x
    exact kernelPrime_eq x
  · rw [kernelSecond_eq, kernelPrime_eq]
    norm_num
    ring

/-- The integrand defining the cost kernel is strictly positive before
averaging with the arcsine measure. -/
theorem positive_bernstein_integrand (t u : ℝ) (hu0 : 0 < u) (hu1 : u ≤ 1) :
    0 < u * kernelPrime (t * u) / 2 - u ^ 2 * kernelSecond (t * u) := by
  have hp := kernelPrime_pos (t * u)
  have hsecond := kernelSecond_lt_half_prime (t * u)
  have hsmall : u ^ 2 ≤ u := by nlinarith
  have hstrict := mul_lt_mul_of_pos_left hsecond (sq_pos_of_pos hu0)
  have hhalf : (0 : ℝ) ≤ kernelPrime (t * u) / 2 :=
    (div_pos hp (by norm_num)).le
  have hupper := mul_le_mul_of_nonneg_right hsmall hhalf
  nlinarith

end NeuralGeneralization.OnlineLowerBernstein
