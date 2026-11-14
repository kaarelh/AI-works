import NeuralGeneralization.OnlineLowerTanhPeriodicExactGaussian
import NeuralGeneralization.OnlineLowerTanhPeriodicExactMaximum

/-! Strict loss from positive residual Gaussian energy, at every positive gain. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.OnlineLowerTanh

lemma periodicGaussian_integrable {a : ℝ} (ha : 0<a) (E b : ℝ) :
    Integrable (fun x : ℝ => periodicFourierResponse a (b+Real.sqrt E*x)) (gaussianReal 0 1) := by
  have hc : Continuous (periodicFourierResponse a) :=
    continuous_iff_continuousAt.mpr (fun y => (periodicFourierResponse_hasDerivAt ha y).continuousAt)
  apply (integrable_const (periodicFourierMaximum a)).mono'
    ((hc.comp (continuous_const.add (continuous_const.mul continuous_id))).aestronglyMeasurable)
  exact Filter.Eventually.of_forall (fun x => by
    simpa only [Real.norm_eq_abs,Function.comp_apply,Pi.add_apply,Pi.mul_apply,id_eq] using (periodic_maximum_and_equality_all_gain ha (b+Real.sqrt E*x)).1)

/-- All-gain bound for the literal smoothed Fourier response. -/
theorem smoothedResponse_abs_le_all_gain {a E : ℝ} (ha : 0<a) (hE : 0≤E) (b : ℝ) :
    |smoothedResponse a E b|≤periodicFourierMaximum a := by
  rw [←periodicFourierResponse_gaussian_convolution ha hE b]
  have hi := periodicGaussian_integrable ha E b
  calc
    _ ≤ ∫ x : ℝ, |periodicFourierResponse a (b+Real.sqrt E*x)| ∂gaussianReal 0 1 :=
      by simpa only [Real.norm_eq_abs] using (norm_integral_le_integral_norm
        (μ:=gaussianReal 0 1) (fun x : ℝ => periodicFourierResponse a (b+Real.sqrt E*x)))
    _ ≤ ∫ _x : ℝ, periodicFourierMaximum a ∂gaussianReal 0 1 :=
      integral_mono hi.abs (integrable_const _) (fun x =>
        (periodic_maximum_and_equality_all_gain ha (b+Real.sqrt E*x)).1)
    _ = _ := by simp

/-- Positive residual Gaussian variance strictly lowers the maximum, even
when the gain is greater than two and for arbitrary external phase. -/
theorem smoothedResponse_abs_lt_all_gain {a E : ℝ} (ha : 0<a) (hE : 0<E) (b : ℝ) :
    |smoothedResponse a E b|<periodicFourierMaximum a := by
  letI : Measure.IsOpenPosMeasure (gaussianReal (0:ℝ) (1:NNReal)) :=
    (gaussianReal_absolutelyContinuous' (0:ℝ) (by norm_num : (1:NNReal)≠0)).isOpenPosMeasure
  let f : ℝ → ℝ := fun x => periodicFourierResponse a (b+Real.sqrt E*x)
  have hc : Continuous (periodicFourierResponse a) :=
    continuous_iff_continuousAt.mpr (fun y => (periodicFourierResponse_hasDerivAt ha y).continuousAt)
  have hfc : Continuous f := hc.comp (continuous_const.add (continuous_const.mul continuous_id))
  have hi : Integrable f (gaussianReal 0 1) := periodicGaussian_integrable ha E b
  have hfbound (x : ℝ) : |f x|≤periodicFourierMaximum a :=
    (periodic_maximum_and_equality_all_gain ha _).1
  have hsqrt : Real.sqrt E ≠ 0 := ne_of_gt (Real.sqrt_pos.mpr hE)
  have hfzero : f (-b/Real.sqrt E)=0 := by
    dsimp [f]
    rw [show b+Real.sqrt E*(-b/Real.sqrt E)=0 by field_simp;ring,periodicFourierResponse_zero]
  have hpos : 0 < ∫ x : ℝ, periodicFourierMaximum a-|f x| ∂gaussianReal 0 1 := by
    apply integral_pos_of_integrable_nonneg_nonzero
      (continuous_const.sub hfc.abs) ((integrable_const _).sub hi.abs)
      (fun x => sub_nonneg.mpr (hfbound x)) (x:=-b/Real.sqrt E)
    simp only [Pi.sub_apply]
    rw [hfzero,abs_zero,sub_zero]
    exact ne_of_gt (periodic_maximum_pos_all_gain ha)
  rw [integral_sub (integrable_const _) hi.abs,integral_const] at hpos
  simp only [probReal_univ,one_smul] at hpos
  rw [←periodicFourierResponse_gaussian_convolution ha hE.le b]
  have hbnd := norm_integral_le_integral_norm (f:=f) (μ:=gaussianReal 0 1)
  simp only [Real.norm_eq_abs] at hbnd
  change |∫ x : ℝ, f x ∂gaussianReal 0 1|<periodicFourierMaximum a
  linarith

end NeuralGeneralization.OnlineLowerTanh
