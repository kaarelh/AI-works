import Mathlib.Probability.Distributions.Gaussian.Multivariate
import Mathlib.Probability.Distributions.Gaussian.Fernique
import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.Analysis.Convex.Integral
import Mathlib.Analysis.Convex.SpecificFunctions.Basic
import Mathlib.MeasureTheory.Integral.IntervalIntegral.FundThmCalculus
import Mathlib.Analysis.Calculus.ContDiff.Basic
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Deriv
import Mathlib.Analysis.Calculus.MeanValue

/-!
# Gaussian concentration from rotations

The proof rotates a pair of independent standard Gaussians through a quarter
circle, applies Jensen to the integral of the derivative, and conditions on one
of the rotated Gaussians. This avoids logarithmic Sobolev inequalities.
-/

open MeasureTheory ProbabilityTheory Real Set
open scoped ProbabilityTheory

noncomputable section

namespace Paulsen

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E]
  [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E]

/-- Every continuous linear functional of a standard Gaussian has its scalar
Gaussian moment-generating function, with variance equal to its squared norm. -/
theorem integral_exp_dual_stdGaussian (D : StrongDual ℝ E) (t : ℝ) :
    (∫ x, exp (t * D x) ∂stdGaussian E) = exp (‖D‖ ^ 2 * t ^ 2 / 2) := by
  have hmap := IsGaussian.map_eq_gaussianReal (μ := stdGaussian E) D
  have h := mgf_gaussianReal hmap t
  simpa [mgf, integral_strongDual_stdGaussian, variance_dual_stdGaussian,
    Real.toNNReal_of_nonneg (sq_nonneg ‖D‖)] using h

theorem integrable_exp_dual_stdGaussian (D : StrongDual ℝ E) (t : ℝ) :
    Integrable (fun x => exp (t * D x)) (stdGaussian E) := by
  rw [← mgf_pos_iff]
  change 0 < ∫ x, exp (t * D x) ∂stdGaussian E
  rw [integral_exp_dual_stdGaussian]
  positivity

/-- Conditioning on the first Gaussian makes a variable bounded linear
functional into an ordinary one-dimensional Gaussian MGF. -/
theorem integrable_exp_dual_pair_stdGaussian (D : E → StrongDual ℝ E)
    (hD : Continuous D) {L : ℝ} (_hL : 0 ≤ L) (hb : ∀ x, ‖D x‖ ≤ L) (t : ℝ) :
    Integrable (fun z : E × E => exp (t * D z.1 z.2))
      ((stdGaussian E).prod (stdGaussian E)) := by
  apply (integrable_prod_iff (by fun_prop)).2
  constructor
  · exact ae_of_all _ fun x => integrable_exp_dual_stdGaussian (D x) t
  · simp only [Real.norm_eq_abs, abs_exp, integral_exp_dual_stdGaussian]
    apply (integrable_const (exp (L ^ 2 * t ^ 2 / 2))).mono' (by fun_prop)
    filter_upwards with x
    rw [Real.norm_eq_abs, abs_exp]
    apply exp_le_exp.mpr
    gcongr
    exact hb x

theorem integral_exp_dual_pair_stdGaussian_le (D : E → StrongDual ℝ E)
    (hD : Continuous D) {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖D x‖ ≤ L) (t : ℝ) :
    (∫ z : E × E, exp (t * D z.1 z.2)
      ∂((stdGaussian E).prod (stdGaussian E))) ≤ exp (L ^ 2 * t ^ 2 / 2) := by
  rw [integral_prod _ (integrable_exp_dual_pair_stdGaussian D hD hL hb t)]
  simp_rw [integral_exp_dual_stdGaussian]
  have hi := (integrable_exp_dual_pair_stdGaussian D hD hL hb t).integral_prod_left
  simp_rw [integral_exp_dual_stdGaussian] at hi
  calc
    _ ≤ ∫ _ : E, exp (L ^ 2 * t ^ 2 / 2) ∂stdGaussian E := by
      apply integral_mono_ae hi (integrable_const _)
      exact ae_of_all _ fun x => by
        apply exp_le_exp.mpr
        gcongr
        exact hb x
    _ = _ := by simp

/-- A quarter-circle rotation, parametrized by the unit interval. -/
def quarterRotation (t : ℝ) (z : E × E) : E × E :=
  ContinuousLinearMap.rotation (π / 2 * t) z

omit [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E] in
theorem continuous_quarterRotation :
    Continuous (fun p : ℝ × (E × E) => quarterRotation p.1 p.2) := by
  simp only [quarterRotation, ContinuousLinearMap.rotation_apply]
  fun_prop

/-- The derivative of a function along the quarter-circle path. -/
def rotationDerivative (D : E → StrongDual ℝ E) (t : ℝ) (z : E × E) : ℝ :=
  (π / 2) * D (quarterRotation t z).1 (quarterRotation t z).2

omit [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E] in
theorem continuous_rotationDerivative (D : E → StrongDual ℝ E) (hD : Continuous D) :
    Continuous (fun p : ℝ × (E × E) => rotationDerivative D p.1 p.2) := by
  unfold rotationDerivative
  exact continuous_const.mul
    ((hD.comp continuous_quarterRotation.fst).clm_apply continuous_quarterRotation.snd)

omit [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E] in
theorem hasDerivAt_comp_quarterRotation (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    (z : E × E) (t : ℝ) :
    HasDerivAt (fun t => F (quarterRotation t z).1)
      (rotationDerivative (fderiv ℝ F) t z) t := by
  have hc := (Real.hasDerivAt_cos (π / 2 * t)).comp t
    ((hasDerivAt_id t).const_mul (π / 2))
  have hs := (Real.hasDerivAt_sin (π / 2 * t)).comp t
    ((hasDerivAt_id t).const_mul (π / 2))
  have hpath := (hc.smul_const z.1).add (hs.smul_const z.2)
  convert! (hF.differentiable_one (quarterRotation t z).1).hasFDerivAt.comp_hasDerivAt
    t hpath using 1
  simp [rotationDerivative, quarterRotation, ContinuousLinearMap.rotation_apply,
    map_add, map_smul]
  ring

/-- Lebesgue measure on `[0,1]`, a probability measure. -/
def unitIntervalProbability : Measure ℝ := volume.restrict (Icc 0 1)

instance : IsProbabilityMeasure unitIntervalProbability := by
  constructor
  simp [unitIntervalProbability]

theorem integral_unitIntervalProbability (f : ℝ → ℝ) :
    (∫ t, f t ∂unitIntervalProbability) = ∫ t in (0 : ℝ)..1, f t := by
  rw [intervalIntegral.integral_of_le (by norm_num)]
  exact integral_Icc_eq_integral_Ioc

omit [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E] in
/-- The fundamental theorem of calculus along a quarter circle. -/
theorem integral_rotationDerivative (F : E → ℝ) (hF : ContDiff ℝ 1 F) (z : E × E) :
    (∫ t, rotationDerivative (fderiv ℝ F) t z ∂unitIntervalProbability) =
      F z.2 - F z.1 := by
  rw [integral_unitIntervalProbability]
  have hD : Continuous (fderiv ℝ F) := hF.continuous_fderiv (by norm_num)
  have hR := continuous_rotationDerivative (fderiv ℝ F) hD
  have hp : Continuous (fun t : ℝ => (t, z)) := continuous_id.prodMk continuous_const
  have hcont : Continuous (fun t => rotationDerivative (fderiv ℝ F) t z) := by
    simpa only [Function.comp_def] using! hR.comp hp
  rw [intervalIntegral.integral_eq_sub_of_hasDerivAt
    (fun t _ => hasDerivAt_comp_quarterRotation F hF z t) (hcont.intervalIntegrable 0 1)]
  simp [quarterRotation, ContinuousLinearMap.rotation_apply]

omit [FiniteDimensional ℝ E] [MeasurableSpace E] [BorelSpace E] in
/-- Jensen bounds the exponential of the difference by the average of the
exponentiated path derivatives. -/
theorem exp_sub_le_integral_exp_rotationDerivative (F : E → ℝ)
    (hF : ContDiff ℝ 1 F) (z : E × E) (s : ℝ) :
    exp (s * (F z.2 - F z.1)) ≤
      ∫ t, exp (s * rotationDerivative (fderiv ℝ F) t z) ∂unitIntervalProbability := by
  have hD : Continuous (fderiv ℝ F) := hF.continuous_fderiv (by norm_num)
  have hR := continuous_rotationDerivative (fderiv ℝ F) hD
  have hp : Continuous (fun t : ℝ => (t, z)) := continuous_id.prodMk continuous_const
  have hc : Continuous (fun t => s * rotationDerivative (fderiv ℝ F) t z) := by
    simpa only [Function.comp_def] using! (continuous_const.mul (hR.comp hp) :
      Continuous (fun t : ℝ => s * (fun p : ℝ × (E × E) =>
        rotationDerivative (fderiv ℝ F) p.1 p.2) (t, z)))
  have hi : Integrable (fun t => s * rotationDerivative (fderiv ℝ F) t z)
      unitIntervalProbability := hc.continuousOn.integrableOn_compact isCompact_Icc
  have he : Integrable (fun t => exp (s * rotationDerivative (fderiv ℝ F) t z))
      unitIntervalProbability := hc.rexp.continuousOn.integrableOn_compact isCompact_Icc
  have h := convexOn_exp.map_integral_le continuous_exp.continuousOn isClosed_univ
    (ae_of_all _ fun _ => mem_univ _) hi he
  rw [integral_const_mul, integral_rotationDerivative F hF z] at h
  exact h

theorem measurePreserving_quarterRotation (t : ℝ) :
    MeasurePreserving (quarterRotation (E := E) t)
      ((stdGaussian E).prod (stdGaussian E)) ((stdGaussian E).prod (stdGaussian E)) := by
  constructor
  · exact (ContinuousLinearMap.rotation (π / 2 * t)).continuous.measurable
  · exact IsGaussian.map_rotation_eq_self integral_id_stdGaussian _

theorem integrable_exp_rotationDerivative_stdGaussian (D : E → StrongDual ℝ E)
    (hD : Continuous D) {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖D x‖ ≤ L) (s t : ℝ) :
    Integrable (fun z : E × E => exp (s * rotationDerivative D t z))
      ((stdGaussian E).prod (stdGaussian E)) := by
  have hi := (measurePreserving_quarterRotation (E := E) t).integrable_comp_of_integrable
    (integrable_exp_dual_pair_stdGaussian D hD hL hb (s * (π / 2)))
  simpa [rotationDerivative, Function.comp_def, mul_assoc] using hi

theorem integral_exp_rotationDerivative_stdGaussian_le (D : E → StrongDual ℝ E)
    (hD : Continuous D) {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖D x‖ ≤ L) (s t : ℝ) :
    (∫ z : E × E, exp (s * rotationDerivative D t z)
      ∂((stdGaussian E).prod (stdGaussian E))) ≤ exp (L ^ 2 * (s * (π / 2)) ^ 2 / 2) := by
  have hmap := (measurePreserving_quarterRotation (E := E) t).map_eq
  have heq := integral_map (μ := (stdGaussian E).prod (stdGaussian E)) (φ := quarterRotation (E := E) t)
    (f := fun z : E × E => exp ((s * (π / 2)) * D z.1 z.2))
    (measurePreserving_quarterRotation t).measurable.aemeasurable (by fun_prop)
  rw [hmap] at heq
  calc
    _ = ∫ z : E × E, exp ((s * (π / 2)) * D z.1 z.2)
        ∂((stdGaussian E).prod (stdGaussian E)) := by
      simpa [rotationDerivative, mul_assoc] using heq.symm
    _ ≤ _ := integral_exp_dual_pair_stdGaussian_le D hD hL hb _

/-- The exponential path derivative is jointly integrable in angle and in the
Gaussian pair. Conditional MGFs give a uniform integrable majorant. -/
theorem integrable_exp_rotationDerivative_joint (D : E → StrongDual ℝ E)
    (hD : Continuous D) {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖D x‖ ≤ L) (s : ℝ) :
    Integrable (fun p : ℝ × (E × E) => exp (s * rotationDerivative D p.1 p.2))
      (unitIntervalProbability.prod ((stdGaussian E).prod (stdGaussian E))) := by
  have hc : Continuous (fun p : ℝ × (E × E) => exp (s * rotationDerivative D p.1 p.2)) :=
    (continuous_const.mul (continuous_rotationDerivative D hD)).rexp
  apply (integrable_prod_iff hc.aestronglyMeasurable).2
  constructor
  · exact ae_of_all _ fun t => integrable_exp_rotationDerivative_stdGaussian D hD hL hb s t
  · simp only [Real.norm_eq_abs, abs_exp]
    apply (integrable_const (exp (L ^ 2 * (s * (π / 2)) ^ 2 / 2))).mono'
      hc.aestronglyMeasurable.integral_prod_right'
    filter_upwards with t
    rw [Real.norm_eq_abs, abs_of_nonneg (integral_nonneg fun _ => (exp_pos _).le)]
    exact integral_exp_rotationDerivative_stdGaussian_le D hD hL hb s t

theorem integrable_exp_sub_stdGaussian (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖fderiv ℝ F x‖ ≤ L) (s : ℝ) :
    Integrable (fun z : E × E => exp (s * (F z.2 - F z.1)))
      ((stdGaussian E).prod (stdGaussian E)) := by
  have hD : Continuous (fderiv ℝ F) := hF.continuous_fderiv (by norm_num)
  have hi := (integrable_exp_rotationDerivative_joint (fderiv ℝ F) hD hL hb s).integral_prod_right
  apply hi.mono' (by fun_prop)
  filter_upwards with z
  rw [Real.norm_eq_abs, abs_exp]
  exact exp_sub_le_integral_exp_rotationDerivative F hF z s

/-- Symmetrized Gaussian MGF bound proved by the rotation argument. -/
theorem integral_exp_sub_stdGaussian_le (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖fderiv ℝ F x‖ ≤ L) (s : ℝ) :
    (∫ z : E × E, exp (s * (F z.2 - F z.1))
      ∂((stdGaussian E).prod (stdGaussian E))) ≤ exp (π ^ 2 * s ^ 2 * L ^ 2 / 8) := by
  have hD : Continuous (fderiv ℝ F) := hF.continuous_fderiv (by norm_num)
  have hj := integrable_exp_rotationDerivative_joint (fderiv ℝ F) hD hL hb s
  calc
    _ ≤ ∫ z : E × E, ∫ t, exp (s * rotationDerivative (fderiv ℝ F) t z)
        ∂unitIntervalProbability ∂((stdGaussian E).prod (stdGaussian E)) := by
      apply integral_mono_ae (integrable_exp_sub_stdGaussian F hF hL hb s)
        hj.integral_prod_right
      exact ae_of_all _ fun z => exp_sub_le_integral_exp_rotationDerivative F hF z s
    _ = ∫ t, ∫ z : E × E, exp (s * rotationDerivative (fderiv ℝ F) t z)
        ∂((stdGaussian E).prod (stdGaussian E)) ∂unitIntervalProbability :=
      (integral_integral_swap hj).symm
    _ ≤ ∫ _t : ℝ, exp (L ^ 2 * (s * (π / 2)) ^ 2 / 2)
        ∂unitIntervalProbability := by
      apply integral_mono_ae hj.integral_prod_left (integrable_const _)
      exact ae_of_all _ fun t => integral_exp_rotationDerivative_stdGaussian_le
        (fderiv ℝ F) hD hL hb s t
    _ = _ := by simp only [integral_const, probReal_univ, one_smul]; congr 1; ring

/-- A smooth function with bounded derivative is integrable under a standard
Gaussian. Boundedness of the function itself is not needed. -/
theorem integrable_of_bounded_fderiv_stdGaussian (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖fderiv ℝ F x‖ ≤ L) :
    Integrable F (stdGaussian E) := by
  have hlip : LipschitzWith ⟨L, hL⟩ F :=
    lipschitzWith_of_nnnorm_fderiv_le hF.differentiable_one (fun x => hb x)
  have hi : Integrable (fun x : E => L * ‖x‖ + ‖F 0‖) (stdGaussian E) :=
    (IsGaussian.integrable_fun_id.norm.const_mul L).add (integrable_const _)
  apply hi.mono' hF.continuous.aestronglyMeasurable
  exact ae_of_all _ fun x => by
    have h := hlip.dist_le_mul x 0
    simp only [dist_eq_norm, sub_zero] at h
    calc
      ‖F x‖ ≤ ‖F x - F 0‖ + ‖F 0‖ := norm_le_norm_sub_add _ _
      _ ≤ _ := add_le_add h le_rfl

/-- Centering a random variable by an independent copy is an application of
Jensen's inequality. The section integrability holds almost everywhere by Fubini. -/
theorem exp_centered_le_integral_exp_sub_ae {α : Type*} [MeasurableSpace α]
    (μ : Measure α) [IsProbabilityMeasure μ] (F : α → ℝ) (hF : Integrable F μ)
    (s : ℝ) (he : Integrable (fun z : α × α => exp (s * (F z.2 - F z.1))) (μ.prod μ)) :
    ∀ᵐ x ∂μ, exp (s * (F x - ∫ y, F y ∂μ)) ≤ ∫ y, exp (s * (F x - F y)) ∂μ := by
  filter_upwards [he.prod_left_ae] with x hx
  have hi : Integrable (fun y => s * (F x - F y)) μ :=
    ((integrable_const (F x)).sub hF).const_mul s
  have hj := convexOn_exp.map_integral_le continuous_exp.continuousOn isClosed_univ
    (ae_of_all _ fun _ => mem_univ _) hi hx
  simpa only [integral_const_mul, integral_sub (integrable_const _) hF,
    integral_const, probReal_univ, one_smul] using hj

theorem integrable_exp_centered_stdGaussian (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖fderiv ℝ F x‖ ≤ L) (s : ℝ) :
    Integrable (fun x => exp (s * (F x - ∫ y, F y ∂stdGaussian E))) (stdGaussian E) := by
  have hi := integrable_exp_sub_stdGaussian F hF hL hb s
  have hFi := integrable_of_bounded_fderiv_stdGaussian F hF hL hb
  apply hi.integral_prod_right.mono' (by fun_prop)
  filter_upwards [exp_centered_le_integral_exp_sub_ae (stdGaussian E) F hFi s hi] with x hx
  simpa only [Real.norm_eq_abs, abs_exp] using hx

/-- Dimension-free centered Gaussian MGF bound, obtained from an independent
copy and a quarter-circle rotation. -/
theorem mgf_centered_stdGaussian_le (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    {L : ℝ} (hL : 0 ≤ L) (hb : ∀ x, ‖fderiv ℝ F x‖ ≤ L) (s : ℝ) :
    mgf (fun x => F x - ∫ y, F y ∂stdGaussian E) (stdGaussian E) s ≤
      exp (π ^ 2 * s ^ 2 * L ^ 2 / 8) := by
  have hi := integrable_exp_sub_stdGaussian F hF hL hb s
  have hFi := integrable_of_bounded_fderiv_stdGaussian F hF hL hb
  calc
    _ ≤ ∫ x, ∫ y, exp (s * (F x - F y)) ∂stdGaussian E ∂stdGaussian E := by
      apply integral_mono_ae (integrable_exp_centered_stdGaussian F hF hL hb s)
        hi.integral_prod_right
      exact exp_centered_le_integral_exp_sub_ae (stdGaussian E) F hFi s hi
    _ = ∫ z : E × E, exp (s * (F z.2 - F z.1))
        ∂((stdGaussian E).prod (stdGaussian E)) := (integral_prod_symm _ hi).symm
    _ ≤ _ := integral_exp_sub_stdGaussian_le F hF hL hb s

/-- One-sided Gaussian concentration for a continuously differentiable function
whose derivative has norm at most `L`. -/
theorem stdGaussian_smooth_upper_tail (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    {L : ℝ} (hL : 0 < L) (hb : ∀ x, ‖fderiv ℝ F x‖ ≤ L)
    {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | u ≤ F x - ∫ y, F y ∂stdGaussian E} ≤
      exp (-2 * u ^ 2 / (π ^ 2 * L ^ 2)) := by
  let s := 4 * u / (π ^ 2 * L ^ 2)
  have hs : 0 ≤ s := by dsimp [s]; positivity
  calc
    _ ≤ exp (-s * u) *
        mgf (fun x => F x - ∫ y, F y ∂stdGaussian E) (stdGaussian E) s :=
      measure_ge_le_exp_mul_mgf u hs (integrable_exp_centered_stdGaussian F hF hL.le hb s)
    _ ≤ exp (-s * u) * exp (π ^ 2 * s ^ 2 * L ^ 2 / 8) :=
      mul_le_mul_of_nonneg_left (mgf_centered_stdGaussian_le F hF hL.le hb s) (exp_pos _).le
    _ = _ := by
      rw [← exp_add]
      congr 1
      dsimp [s]
      field_simp
      ring

theorem stdGaussian_smooth_lower_tail (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    {L : ℝ} (hL : 0 < L) (hb : ∀ x, ‖fderiv ℝ F x‖ ≤ L)
    {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | F x - ∫ y, F y ∂stdGaussian E ≤ -u} ≤
      exp (-2 * u ^ 2 / (π ^ 2 * L ^ 2)) := by
  have hn : ∀ x, ‖fderiv ℝ (fun x => -F x) x‖ ≤ L := by
    intro x
    simpa only [fderiv_fun_neg, norm_neg] using hb x
  have h := stdGaussian_smooth_upper_tail (fun x => -F x) hF.neg hL hn hu
  convert h using 1
  congr 1
  ext x
  simp only [mem_setOf_eq, integral_neg]
  constructor <;> intro hx <;> linarith

/-- Two-sided Gaussian concentration, with an absolute constant independent of
the dimension. The proof uses only the scalar Gaussian MGF and rotations. -/
theorem stdGaussian_smooth_abs_tail (F : E → ℝ) (hF : ContDiff ℝ 1 F)
    {L : ℝ} (hL : 0 < L) (hb : ∀ x, ‖fderiv ℝ F x‖ ≤ L)
    {u : ℝ} (hu : 0 ≤ u) :
    (stdGaussian E).real {x | u ≤ |F x - ∫ y, F y ∂stdGaussian E|} ≤
      2 * exp (-2 * u ^ 2 / (π ^ 2 * L ^ 2)) := by
  have hset : {x | u ≤ |F x - ∫ y, F y ∂stdGaussian E|} =
      {x | u ≤ F x - ∫ y, F y ∂stdGaussian E} ∪
      {x | F x - ∫ y, F y ∂stdGaussian E ≤ -u} := by
    ext x
    simp only [mem_setOf_eq, mem_union, le_abs]
    constructor <;> rintro (h | h)
    · exact Or.inl h
    · exact Or.inr (by linarith)
    · exact Or.inl h
    · exact Or.inr (by linarith)
  rw [hset]
  calc
    _ ≤ _ := measureReal_union_le _ _
    _ ≤ exp (-2 * u ^ 2 / (π ^ 2 * L ^ 2)) + exp (-2 * u ^ 2 / (π ^ 2 * L ^ 2)) :=
      add_le_add (stdGaussian_smooth_upper_tail F hF hL hb hu)
        (stdGaussian_smooth_lower_tail F hF hL hb hu)
    _ = _ := by ring

end Paulsen
