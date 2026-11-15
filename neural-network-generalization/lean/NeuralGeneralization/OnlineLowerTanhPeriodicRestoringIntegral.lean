import NeuralGeneralization.OnlineLowerTanhPeriodicExactRestoringFourier
import NeuralGeneralization.OnlineLowerTanhPeriodicExactMaximum
import Mathlib.MeasureTheory.Integral.Bochner.Basic

/-! Integration of restoring curvature for arbitrary real random variables. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.OnlineLowerTanh

lemma periodicFourierResponse_integrable_comp {Ω : Type*} [MeasurableSpace Ω]
    {ν : Measure Ω} [IsProbabilityMeasure ν] {Z : Ω → ℝ} (hZ : Measurable Z)
    {a : ℝ} (ha : 0<a) : Integrable (fun x => periodicFourierResponse a (Z x)) ν := by
  have hc : Continuous (periodicFourierResponse a) :=
    continuous_iff_continuousAt.mpr (fun y => (periodicFourierResponse_hasDerivAt ha y).continuousAt)
  apply (integrable_const (periodicFourierMaximum a)).mono'
    (hc.measurable.comp hZ).aestronglyMeasurable
  exact Filter.Eventually.of_forall (fun x => by
    simpa only [Real.norm_eq_abs,Function.comp_apply] using (periodic_maximum_and_equality_all_gain ha (Z x)).1)

lemma periodicFourierSecond_integrable_comp {Ω : Type*} [MeasurableSpace Ω]
    {ν : Measure Ω} [IsProbabilityMeasure ν] {Z : Ω → ℝ} (hZ : Measurable Z)
    {a : ℝ} (ha : 0<a) : Integrable (fun x => periodicFourierSecond a (Z x)) ν := by
  have hm : Measurable (fun x => periodicFourierSecond a (Z x)) := by
    unfold periodicFourierSecond
    apply Measurable.tsum
    intro j
    fun_prop
  apply (integrable_const (periodicFrequency a^2 *
    (∑'j : ℕ, periodicCoefficient a j*(2*(j:ℝ)+1)^2))).mono' hm.aestronglyMeasurable
  exact Filter.Eventually.of_forall (fun x => by
    simpa only [Real.norm_eq_abs] using periodicFourierSecond_abs_bound ha (Z x))

/-- Integrating the pointwise restoring inequality at eighty percent of the
maximum forces a uniformly negative average curvature. -/
theorem restoring_integral_eighty {Ω : Type*} [MeasurableSpace Ω]
    {ν : Measure Ω} [IsProbabilityMeasure ν] {U V : Ω → ℝ}
    (hU : Integrable U ν) (hV : Integrable V ν)
    {A μ F : ℝ} (hA : 0<A) (hμ : μ<3/4) (hF : 0<F)
    (hpoint : ∀ x, V x ≤ A*(μ/2*F-(1-μ/2)*U x))
    (hmean : (4/5:ℝ)*F ≤ ∫ x, U x ∂ν) :
    (∫ x, V x ∂ν) ≤ -(1/2:ℝ)*A*(1-μ)*F ∧
      -(1/2:ℝ)*A*(1-μ)*F < 0 := by
  have hupper := integral_mono hV
    (((integrable_const (μ/2*F)).sub (hU.const_mul (1-μ/2))).const_mul A) hpoint
  simp only [Pi.sub_apply] at hupper
  rw [integral_const_mul,integral_sub (integrable_const _) (hU.const_mul _),
    integral_const_mul] at hupper
  simp only [integral_const_mul,integral_const,probReal_univ,one_smul] at hupper
  have hcoef : 0 ≤ A*(1-μ/2) := mul_nonneg hA.le (by linarith)
  have hmean' := mul_le_mul_of_nonneg_left hmean hcoef
  have hmuF : (μ-3/4)*F ≤ 0 := mul_nonpos_of_nonpos_of_nonneg (by linarith) hF.le
  have hmuAF := mul_nonpos_of_nonneg_of_nonpos hA.le hmuF
  constructor
  · nlinarith
  · have := mul_pos (mul_pos hA (by linarith : 0<1-μ)) hF
    nlinarith

end NeuralGeneralization.OnlineLowerTanh
