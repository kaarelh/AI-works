import NeuralGeneralization.BoundedTilt
import Mathlib.Analysis.Calculus.ParametricIntegral
import Mathlib.Analysis.SpecialFunctions.ExpDeriv
import Mathlib.Analysis.SpecialFunctions.Log.Deriv

/-!
# Differentiating an actual bounded exponential tilt

The derivative of the log-partition function in a bounded measurable
direction is its expectation under the actual tilted probability law.
The bounded derivative is integrated using dominated differentiation.
No Gaussian law, nondegenerate covariance, or derivative certificate is assumed.
-/

noncomputable section
open MeasureTheory Real Filter
open scoped Topology
namespace NeuralGeneralization.BoundedTilt
variable {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]

/-- The partition derivative follows from a uniform local integrable bound. -/
theorem hasDerivAt_partition_line
    (V W : Ω → ℝ) (hV : Measurable V) (hW : Measurable W)
    {A B : ℝ} (hVbound : ∀ x, |V x| ≤ A) (hWbound : ∀ x, |W x| ≤ B) :
    HasDerivAt (fun t : ℝ => partition μ (fun x => V x + t * W x))
      (∫ x, Real.exp (V x) * W x ∂μ) 0 := by
  let F : ℝ → Ω → ℝ := fun t x => Real.exp (V x + t * W x)
  let F' : ℝ → Ω → ℝ := fun t x => Real.exp (V x + t * W x) * W x
  have hmeas : ∀ᶠ t : ℝ in 𝓝 0, AEStronglyMeasurable (F t) μ :=
    Filter.Eventually.of_forall (fun t => (hV.add (hW.const_mul t)).exp.aestronglyMeasurable)
  have hint : Integrable (F 0) μ := by
    simpa only [F, zero_mul, add_zero] using integrable_exp_of_bounded μ V hV hVbound
  have hmeas' : AEStronglyMeasurable (F' 0) μ := by
    have h : Measurable (fun x => Real.exp (V x) * W x) := hV.exp.mul hW
    simpa only [F', zero_mul, add_zero] using h.aestronglyMeasurable
  have hbound : ∀ᵐ x ∂μ, ∀ t ∈ Metric.ball (0 : ℝ) 1,
      ‖F' t x‖ ≤ Real.exp (A + |B|) * |B| := by
    apply ae_of_all
    intro x t ht
    have ht1 : |t| ≤ 1 := by
      have : |t| < 1 := by simpa only [Metric.mem_ball, Real.dist_eq, sub_zero] using ht
      exact this.le
    have hWx : |W x| ≤ |B| := (hWbound x).trans (le_abs_self B)
    have harg : V x + t * W x ≤ A + |B| := by
      have hprod : |t| * |W x| ≤ |B| :=
        (mul_le_mul_of_nonneg_left hWx (abs_nonneg t)).trans
          (by simpa only [one_mul] using mul_le_mul_of_nonneg_right ht1 (abs_nonneg B))
      exact add_le_add ((le_abs_self _).trans (hVbound x))
        ((le_abs_self _).trans (by simpa only [abs_mul] using hprod))
    simp only [F', Real.norm_eq_abs, abs_mul, abs_of_pos (Real.exp_pos _)]
    exact mul_le_mul (Real.exp_le_exp.mpr harg) hWx (abs_nonneg _) (Real.exp_pos _).le
  have hdiff : ∀ᵐ x ∂μ, ∀ t ∈ Metric.ball (0 : ℝ) 1,
      HasDerivAt (fun t => F t x) (F' t x) t := by
    apply ae_of_all
    intro x t ht
    simpa only [F, F', one_mul, id_eq] using
      (((hasDerivAt_id t).mul_const (W x)).const_add (V x)).exp
  have h := (hasDerivAt_integral_of_dominated_loc_of_deriv_le
    (μ := μ) (F := F) (F' := F') (bound := fun _ => Real.exp (A + |B|) * |B|)
    (Metric.ball_mem_nhds (0 : ℝ) zero_lt_one) hmeas hint hmeas' hbound
    (integrable_const _) hdiff).2
  simpa only [partition, F, F', zero_mul, add_zero] using h

/-- The log-partition derivative is the expectation under the actual tilt. -/
theorem hasDerivAt_log_partition_line
    (V W : Ω → ℝ) (hV : Measurable V) (hW : Measurable W)
    {A B : ℝ} (hVbound : ∀ x, |V x| ≤ A) (hWbound : ∀ x, |W x| ≤ B) :
    HasDerivAt (fun t : ℝ => Real.log (partition μ (fun x => V x + t * W x)))
      (∫ x, W x ∂(μ.tilted V)) 0 := by
  have hpart := hasDerivAt_partition_line μ V W hV hW hVbound hWbound
  have hZ : partition μ (fun x => V x + (0 : ℝ) * W x) ≠ 0 := by
    simpa only [zero_mul, add_zero] using (partition_pos μ V hV hVbound).ne'
  have heq : (∫ x, W x ∂(μ.tilted V)) =
      (∫ x, Real.exp (V x) * W x ∂μ) / partition μ V := by
    rw [integral_tilted_eq_density]
    simp only [density, div_mul_eq_mul_div, integral_div]
  rw [heq]
  simpa only [zero_mul, add_zero] using hpart.log hZ

end NeuralGeneralization.BoundedTilt
end
