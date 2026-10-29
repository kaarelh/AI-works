import GaussianEntropyGain
import ScalarSubcriticalCost

/-! A Gaussian covariance cost pays for the subcritical baseline and the
logarithmic variance increase. The remaining row entropy is consequently
bounded by the adjusted physical charge. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

lemma gaussianVarianceCost_subcritical_identity (v : ℝ≥0) (hv : v≠0)
    {M : ℝ} (hM : 0<M) :
    gaussianVarianceCost M-subcriticalCostBaseline v-
      ((v:ℝ)⁻¹-1)/2*Real.log ((v:ℝ)*M)=
      (v:ℝ)⁻¹*gaussianVarianceCost ((v:ℝ)*M) := by
  have hvp : 0<(v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  rw [Real.log_mul hvp.ne' hM.ne']
  unfold gaussianVarianceCost subcriticalCostBaseline
  rw [Real.log_mul hvp.ne' hM.ne']
  field_simp
  <;> ring

lemma gaussianVarianceCost_subcritical_floor (v : ℝ≥0) (hv : v≠0)
    (hvone : v≤1) {M r : ℝ} (hM : 0<M) (hr : 0<r) (hbound : r≤(v:ℝ)*M) :
    subcriticalCostBaseline v+((v:ℝ)⁻¹-1)/2*Real.log r≤gaussianVarianceCost M := by
  have hvp : 0<(v:ℝ) := by exact_mod_cast (pos_iff_ne_zero.mpr hv)
  have hvl : (v:ℝ)≤1 := by exact_mod_cast hvone
  have ha : 0≤((v:ℝ)⁻¹-1)/2 := by
    have hh := (one_le_inv₀ hvp).mpr hvl
    linarith
  have hlog := mul_le_mul_of_nonneg_left (Real.log_le_log hr hbound) ha
  have hid := gaussianVarianceCost_subcritical_identity v hv hM
  have hnon : 0≤gaussianVarianceCost ((v:ℝ)*M) := by
    have hh := Real.log_le_sub_one_of_pos (mul_pos hvp hM)
    unfold gaussianVarianceCost
    linarith
  have hh := mul_nonneg (inv_nonneg.mpr hvp.le) hnon
  linarith

/-- Once Gaussian and non-Gaussian parts of a row are separated, only the
non-Gaussian part is charged to its adjusted path budget. -/
theorem nonGaussian_cost_le_adjusted {D J C p q M : ℝ}
    (v : ℝ≥0) (hv : v≠0) (hvone : v≤1)
    (hdecomp : D=J+C) (hcov : gaussianVarianceCost M≤C)
    (hp : 0<p) (hq : 0<q) (hM : 0<M) (hvariance : q≤p*((v:ℝ)*M)) :
    J≤D-subcriticalCostBaseline v-((v:ℝ)⁻¹-1)/2*Real.log (q/p) := by
  have hr : q/p≤(v:ℝ)*M := (div_le_iff₀ hp).mpr (by nlinarith only [hvariance])
  have hh := (gaussianVarianceCost_subcritical_floor v hv hvone hM (div_pos hq hp) hr).trans hcov
  linarith

#print axioms nonGaussian_cost_le_adjusted
end ConditionalNonpolynomial.Analytic
