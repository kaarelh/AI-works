import NeuralGeneralization.GaussianSignCDF
import Mathlib.Probability.CDF
import Mathlib.Analysis.Convex.Function

/-! Logarithmic concavity of the actual scalar CDF under finite strict
Gaussian sign conditioning. No marginal log-concavity certificate is assumed. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.GaussianConditionalLogCDF
open PrekopaLeindlerInterval GaussianCoordinateIntegration GaussianSignCDF GaussianSignCone
variable {I J : Type*} [Fintype I] [Fintype J]

def conditionedOutput (A : J → I → ℝ) (u : I → ℝ) : Measure ℝ :=
  (cond (law I) (signCone A)).map (linear u)

theorem measurable_linear (u : I → ℝ) : Measurable (linear u) := by
  unfold linear
  fun_prop

theorem conditionedOutput_isProbability (A : J → I → ℝ) (u : I → ℝ)
    (hprob : law I (signCone A) ≠ 0) : IsProbabilityMeasure (conditionedOutput A u) := by
  letI := cond_isProbabilityMeasure hprob
  unfold conditionedOutput
  exact Measure.isProbabilityMeasure_map (measurable_linear u).aemeasurable

theorem cdf_formula (A : J → I → ℝ) (u : I → ℝ)
    (hprob : law I (signCone A) ≠ 0) (t : ℝ) :
    cdf (conditionedOutput A u) t =
      (law I).real (strictCDFSet A u t) / (law I).real (signCone A) := by
  letI := conditionedOutput_isProbability A u hprob
  rw [cdf_eq_real, measureReal_def, conditionedOutput,
    Measure.map_apply (measurable_linear u) measurableSet_Iic,
    cond_apply (measurableSet_signCone A), ENNReal.toReal_mul, ENNReal.toReal_inv]
  rw [strictCDFSet_eq]
  simp only [measureReal_def]
  ring

theorem normalized_rpow_identity {x y P θ : ℝ} (hx : 0 ≤ x) (hy : 0 ≤ y) (hP : 0 < P) :
    (x/P)^(1-θ)*(y/P)^θ = (x^(1-θ)*y^θ)/P := by
  rw [Real.div_rpow hx hP.le, Real.div_rpow hy hP.le, div_mul_div_comm]
  congr 1
  rw [← Real.rpow_add hP, sub_add_cancel, Real.rpow_one]

theorem cdf_multiplicative_logConcave (A : J → I → ℝ) (u : I → ℝ)
    (hprob : law I (signCone A) ≠ 0) (s t : ℝ) {θ : ℝ} (hθ : θ ∈ Icc 0 1) :
    cdf (conditionedOutput A u) s ^ (1-θ) * cdf (conditionedOutput A u) t ^ θ ≤
      cdf (conditionedOutput A u) (mix θ s t) := by
  rw [cdf_formula A u hprob, cdf_formula A u hprob, cdf_formula A u hprob]
  have hP : 0 < (law I).real (signCone A) :=
    ENNReal.toReal_pos hprob (measure_ne_top _ _)
  rw [normalized_rpow_identity (measureReal_nonneg) (measureReal_nonneg) hP]
  exact div_le_div_of_nonneg_right (strictCDF_mass_logConcave A u s t hθ) hP.le

theorem concaveOn_log_of_multiplicative {F : ℝ → ℝ} (hpos : ∀ x, 0 < F x)
    (hM : ∀ x y θ, θ ∈ Icc 0 1 → F x^(1-θ)*F y^θ ≤ F (mix θ x y)) :
    ConcaveOn ℝ univ (fun x => Real.log (F x)) := by
  refine ⟨convex_univ, ?_⟩
  intro x _ y _ a b ha hb hab
  have hb1 : b ≤ 1 := by linarith
  have hab' : 1-b = a := by linarith
  have hm := Real.log_le_log
    (mul_pos (Real.rpow_pos_of_pos (hpos x) _) (Real.rpow_pos_of_pos (hpos y) _))
    (hM x y b ⟨hb,hb1⟩)
  rw [Real.log_mul (Real.rpow_pos_of_pos (hpos x) _).ne'
    (Real.rpow_pos_of_pos (hpos y) _).ne', Real.log_rpow (hpos x), Real.log_rpow (hpos y)] at hm
  simpa only [smul_eq_mul, mix, hab'] using hm

/-- In the nondegenerate mixture setting the CDF is strictly increasing;
this implies its positivity. All log-concavity is proved from the actual
Gaussian sign-conditioned measure. -/
theorem concaveOn_log_cdf (A : J → I → ℝ) (u : I → ℝ)
    (hprob : law I (signCone A) ≠ 0)
    (hmono : StrictMono (cdf (conditionedOutput A u))) :
    ConcaveOn ℝ univ (fun t => Real.log (cdf (conditionedOutput A u) t)) := by
  apply concaveOn_log_of_multiplicative
  · intro t
    exact (cdf_nonneg (conditionedOutput A u) (t-1)).trans_lt (hmono (by linarith))
  · intro s t θ hθ
    exact cdf_multiplicative_logConcave A u hprob s t hθ

end NeuralGeneralization.GaussianConditionalLogCDF
end
