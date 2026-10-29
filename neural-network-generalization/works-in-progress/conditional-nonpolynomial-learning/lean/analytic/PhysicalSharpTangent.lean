import TwoBallEntropyGap
import ScalarPhysicalGain

noncomputable section
namespace ConditionalNonpolynomial.Analytic

theorem one_moment_entropy_gain {a u D:ℝ} (ha:0<a) (hu:0<u)
    (hD:(u-1-Real.log u)/2≤D) :
    Real.log (Real.sqrt (u/(a+1)))≤(D-twoBallEntropyBaseline a)/a := by
  have ha1 : 0<a+1 := by positivity
  have hl := Real.log_le_sub_one_of_pos (div_pos hu ha1)
  rw [Real.log_div hu.ne' ha1.ne'] at hl
  have hh := mul_le_mul_of_nonneg_left hl ha1.le
  have he : (a+1)*(u/(a+1)-1)=u-(a+1) := by field_simp <;> ring
  rw [he] at hh
  rw [Real.log_sqrt (div_nonneg hu.le ha1.le),Real.log_div hu.ne' ha1.ne']
  apply (le_div_iff₀ ha).mpr
  dsimp [twoBallEntropyBaseline]
  nlinarith

theorem sharp_physical_gain_tangent {a t D:ℝ}
    (ha:0<a) (ht:0<t) (hD:0≤D) (hta:t^2*(a+1)=1) :
    Real.log (t*Real.sqrt (gaussianEntropyGain D))≤(D-twoBallEntropyBaseline a)/a := by
  have hu : 0<gaussianEntropyGain D := (by norm_num : (0:ℝ)<1).trans_le
    (gaussianEntropyGain_one_le D)
  have hc := gaussianEntropyGain_cost hD
  have hg := one_moment_entropy_gain ha hu (by
    unfold gaussianVarianceCost at hc
    exact hc.le)
  have he : t*Real.sqrt (gaussianEntropyGain D)=Real.sqrt (gaussianEntropyGain D/(a+1)) := by
    apply (sq_eq_sq₀ (by positivity) (Real.sqrt_nonneg _)).mp
    rw [mul_pow,Real.sq_sqrt hu.le,Real.sq_sqrt (by positivity)]
    apply (eq_div_iff (by positivity : a+1≠0)).mpr
    nlinarith [congrArg (fun z:ℝ=>z*gaussianEntropyGain D) hta]
  rwa [he]

#print axioms sharp_physical_gain_tangent
end ConditionalNonpolynomial.Analytic
