import PhysicalLongPrecisionResources
import CriticalPrimitiveResources

noncomputable section
set_option maxHeartbeats 1000000
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalLong
open ConditionalNonpolynomial.AnalyticLookup

def longEvaluationLogCoefficient (C : ℝ) (b : ℕ) : ℝ :=
  (2*C+Real.log 768+(b:ℝ))/Real.log 2+1

def longRoundingResourceExponent (C : ℝ) (b : ℕ) : ℕ :=
  b+⌈C*(1+1/Real.log 2)⌉₊+7

lemma longEvaluationLogCoefficient_nonneg {C : ℝ} (hC : 0≤C) (b : ℕ) :
    0≤longEvaluationLogCoefficient C b := by
  have hl := Real.log_nonneg (show (1:ℝ)≤768 by norm_num)
  have h2 := Real.log_pos (show (1:ℝ)<2 by norm_num)
  unfold longEvaluationLogCoefficient
  positivity

 theorem longEvaluation_resources {Λ ξ C R : ℝ} (hΛ : 0≤Λ) (hξ : 0<ξ)
    (hC : 0≤C) (hR : 2≤R) (b : ℕ)
    (hbudget : Λ≤C*(1+Real.log R)) (hξinv : ξ⁻¹≤R^b) :
    (longEvaluationIterations Λ ξ:ℝ)≤longEvaluationLogCoefficient C b*(1+Real.log R) ∧
      (longEvaluationRounding Λ ξ)⁻¹≤R^(longRoundingResourceExponent C b) := by
  have hR0 : 0<R := by linarith
  have hlog : 0≤Real.log R := Real.log_nonneg (by linarith)
  have hp : 1≤R^b := one_le_pow₀ (by linarith)
  have hi := inv_nonneg.mpr hξ.le
  have h2 : 0<Real.log 2 := Real.log_pos (by norm_num)
  have h768 : 0≤Real.log 768 := Real.log_nonneg (by norm_num)
  have hinner : 384*(1+ξ⁻¹)≤768*R^b := by nlinarith
  have hl := Real.log_le_log (by positivity : 0<384*(1+ξ⁻¹)) hinner
  rw [Real.log_mul (by norm_num : (768:ℝ)≠0) (pow_ne_zero _ hR0.ne'),Real.log_pow] at hl
  have hk := causalSignIterations_bound (E:=0) (by norm_num) hΛ hi
  have hnum : 2*Λ+0+Real.log (384*(1+ξ⁻¹))≤
      (2*C+Real.log 768+(b:ℝ))*(1+Real.log R) := by
    nlinarith [mul_nonneg h768 hlog,Nat.cast_nonneg b (α:=ℝ)]
  have hbound := hk.trans (add_le_add (div_le_div_of_nonneg_right hnum h2.le) (le_refl 1))
  have hiter : (longEvaluationIterations Λ ξ:ℝ)≤longEvaluationLogCoefficient C b*(1+Real.log R) := by
    apply hbound.trans
    unfold longEvaluationLogCoefficient
    have hn : 0≤2*C+Real.log 768+(b:ℝ) := by positivity
    simp only [div_eq_mul_inv]
    nlinarith only [hlog]
  have h64 : (64:ℝ)≤R^6 := by
    have hh := pow_le_pow_left₀ (by norm_num : (0:ℝ)≤2) hR 6
    norm_num at hh
    exact hh
  have hsum : 1+ξ⁻¹≤R^(b+1) := by
    have hh := resource_add_one hR hξinv
    linarith
  have hexp : Real.exp Λ≤R^(⌈C*(1+1/Real.log 2)⌉₊) :=
    (Real.exp_le_exp.mpr hbudget).trans (exp_log_envelope_pow hC hR)
  have hr := resource_mul hR (resource_mul hR h64 hsum (by positivity)) hexp (Real.exp_nonneg _)
  have hr' : (longEvaluationRounding Λ ξ)⁻¹≤R^(longRoundingResourceExponent C b) := by
    simp only [longEvaluationRounding,causalSignRounding,zero_add,one_div,inv_inv]
    convert hr using 1 <;> unfold longRoundingResourceExponent <;> congr 1 <;> omega
  exact ⟨hiter,hr'⟩

#print axioms longEvaluation_resources
end ConditionalNonpolynomial.Analytic.PhysicalLong
