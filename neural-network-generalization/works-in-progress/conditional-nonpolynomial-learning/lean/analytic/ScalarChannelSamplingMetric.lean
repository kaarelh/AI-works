import CanonicalCompletion
import NeuralGeneralization.BatchTwoContinuousDepthCriticalControlNormalize

noncomputable section
open scoped BigOperators
namespace ConditionalAnalytic
open ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

/-- The empirical score normalization and residual-norm completion lose only
the square root of the raw empirical-moment error, with no width dependence. -/
theorem scalar_channel_sampling_metric {M p c q qhat α : ℝ}
    (hα : 0<α) (hαquarter : α≤1/4)
    (hM : |M-1|<α) (hp : |p-c|<α) (hq : |qhat-q|≤α) (hc : |c|≤1) :
    0<M ∧ |p/Real.sqrt M-c|<4*α ∧
      ‖canonicalCompletion (p/Real.sqrt M) qhat-canonicalCompletion c q‖≤8*Real.sqrt α := by
  obtain ⟨hMpos,hcerr⟩ := normalized_scalar_error hα (by linarith) hM hp hc
  refine ⟨hMpos,hcerr,?_⟩
  have hnorm : |p/Real.sqrt M|≤2 := by
    have hh := abs_add_le (p/Real.sqrt M-c) c
    rw [sub_add_cancel] at hh
    linarith
  have he := canonicalCompletion_error (p/Real.sqrt M) c qhat q 2 (4*α)
    (by norm_num) (by positivity) (by simpa only [Real.norm_eq_abs] using hnorm)
    (by simpa only [Real.norm_eq_abs] using hc.trans (by norm_num : (1:ℝ)≤2))
    (by simpa only [Real.norm_eq_abs] using hcerr.le) (hq.trans (by linarith))
  apply he.trans
  have hs : (Real.sqrt α)^2=α := Real.sq_sqrt hα.le
  have hroot : Real.sqrt ((1+2*2)*(4*α))≤5*Real.sqrt α := by
    apply (Real.sqrt_le_iff).mpr
    constructor
    · positivity
    · nlinarith
  have hsmall : 4*α≤2*Real.sqrt α := by
    have hsq : α^2≤α/4 := by nlinarith [mul_nonneg hα.le (sub_nonneg.mpr hαquarter)]
    nlinarith [Real.sqrt_nonneg α]
  linarith [Real.sqrt_nonneg α]

#print axioms scalar_channel_sampling_metric
end ConditionalAnalytic
