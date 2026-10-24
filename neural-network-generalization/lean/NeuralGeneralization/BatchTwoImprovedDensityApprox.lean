import Mathlib.MeasureTheory.Function.ContinuousMapDense
import Mathlib.Analysis.SpecialFunctions.Log.NegMulLog
import Mathlib.Analysis.Calculus.MeanValue

/-! # Continuous approximations of bounded positive probability densities

The bounds concern actual L1 error and entropy, not assumed transport costs.
They are intended to extend compact Gaussian transport from continuous target
densities to arbitrary finite-entropy laws.
-/
noncomputable section
open MeasureTheory Set Filter
open scoped Topology

namespace NeuralGeneralization.BatchTwoImprovedDensityApprox

/-- Scalar clipping to a prescribed interval. -/
def clamp (a b x : ℝ) : ℝ := max a (min b x)

@[fun_prop] theorem continuous_clamp (a b : ℝ) : Continuous (clamp a b) := by
  unfold clamp
  fun_prop

theorem clamp_mem {a b : ℝ} (hab : a ≤ b) (x : ℝ) : clamp a b x ∈ Icc a b :=
  ⟨le_max_left _ _, max_le hab (min_le_left _ _)⟩

theorem abs_clamp_sub_le {a b x y : ℝ} (hy : y ∈ Icc a b) :
    |clamp a b x - y| ≤ |x-y| := by
  by_cases hxa : x < a
  · have hmin : min b x ≤ a := (min_le_right _ _).trans hxa.le
    rw [clamp, max_eq_left hmin, abs_of_nonpos (sub_nonpos.mpr hy.1),
      abs_of_nonpos (sub_nonpos.mpr (hxa.le.trans hy.1))]
    linarith
  · by_cases hbx : b < x
    · rw [clamp, min_eq_left hbx.le, max_eq_right (hy.1.trans hy.2),
        abs_of_nonneg (sub_nonneg.mpr hy.2),
        abs_of_nonneg (sub_nonneg.mpr (hy.2.trans hbx.le))]
      linarith
    · rw [clamp, min_eq_right (le_of_not_gt hbx), max_eq_right (le_of_not_gt hxa)]

/-- An explicit Lipschitz bound for the entropy integrand on a compact positive
interval. No continuity claim at the zero derivative singularity is needed. -/
theorem abs_mul_log_sub_le {a b x y : ℝ} (ha : 0 < a)
    (hx : x ∈ Icc a b) (hy : y ∈ Icc a b) :
    |x*Real.log x - y*Real.log y| ≤
      (|Real.log a| + |Real.log b| + 1) * |x-y| := by
  have hab : a ≤ b := hx.1.trans hx.2
  have hder (z : ℝ) (hz : z ∈ Icc a b) :
      HasDerivWithinAt (fun z : ℝ => z * Real.log z)
        (Real.log z + 1) (Icc a b) z :=
    (Real.hasDerivAt_mul_log (ha.trans_le hz.1).ne').hasDerivWithinAt
  have hbound (z : ℝ) (hz : z ∈ Icc a b) :
      ‖Real.log z + 1‖ ≤ |Real.log a| + |Real.log b| + 1 := by
    have hlo := Real.log_le_log ha hz.1
    have hhi := Real.log_le_log (ha.trans_le hz.1) hz.2
    have habs : |Real.log z| ≤ |Real.log a| + |Real.log b| := by
      apply abs_le.mpr
      constructor
      · linarith [neg_abs_le (Real.log a), abs_nonneg (Real.log b)]
      · linarith [le_abs_self (Real.log b), abs_nonneg (Real.log a)]
    rw [Real.norm_eq_abs]
    exact (abs_add_le _ _).trans (by simpa using add_le_add_right habs 1)
  have h := (convex_Icc a b).norm_image_sub_le_of_norm_hasDerivWithin_le
    hder hbound hy hx
  simpa only [Real.norm_eq_abs] using h

/-- Clamping an L1 approximation does not increase its error against a target
already in the specified interval. -/
theorem exists_continuous_clamped_approx (μ : Measure ℝ) [IsFiniteMeasure μ]
    [μ.WeaklyRegular] (ρ : ℝ → ℝ) (hρ : Integrable ρ μ)
    {a b ε : ℝ} (hab : a ≤ b) (hbound : ∀ᵐ x ∂μ, ρ x ∈ Icc a b)
    (hε : 0 < ε) :
    ∃ h : ℝ → ℝ, Continuous h ∧ (∀ x, h x ∈ Icc a b) ∧
      Integrable h μ ∧ (∫ x, |h x - ρ x| ∂μ) ≤ ε := by
  obtain ⟨g, hg, hgi⟩ := hρ.exists_boundedContinuous_integral_sub_le hε
  let h := fun x => clamp a b (g x)
  have hc : Continuous h := (continuous_clamp a b).comp g.continuous
  have hb (x : ℝ) : h x ∈ Icc a b := clamp_mem hab _
  have hi : Integrable h μ := by
    apply (integrable_const (|a| + |b|)).mono' hc.aestronglyMeasurable
    filter_upwards with x
    rw [Real.norm_eq_abs]
    apply abs_le.mpr
    constructor
    · linarith [(hb x).1, neg_abs_le a, abs_nonneg b]
    · linarith [(hb x).2, le_abs_self b, abs_nonneg a]
  refine ⟨h, hc, hb, hi, ?_⟩
  have herr := integral_mono_ae (hi.sub hρ).abs (hρ.sub hgi).norm ?_
  · exact herr.trans hg
  · filter_upwards [hbound] with x hx
    rw [Real.norm_eq_abs, Pi.sub_apply, Pi.sub_apply, abs_sub_comm (ρ x) (g x)]
    exact abs_clamp_sub_le hx


/-- Normalizing a nonnegative approximate density costs at most a second copy
of its original L1 error. -/
theorem normalized_l1_error_le (μ : Measure ℝ) (h ρ : ℝ → ℝ)
    (hi : Integrable h μ) (hρi : Integrable ρ μ)
    (hpos : ∀ x, 0 ≤ h x) (hρmass : ∫ x, ρ x ∂μ = 1)
    (hz : 0 < ∫ x, h x ∂μ) :
    (∫ x, |h x / (∫ y, h y ∂μ) - ρ x| ∂μ) ≤
      2 * ∫ x, |h x - ρ x| ∂μ := by
  let z := ∫ x, h x ∂μ
  have hmass : |z - 1| ≤ ∫ x, |h x - ρ x| ∂μ := by
    have h := norm_integral_le_integral_norm (f := fun x => h x - ρ x) (μ := μ)
    rw [integral_sub hi hρi, hρmass] at h
    simpa only [Real.norm_eq_abs, z] using h
  have hnorm : (∫ x, |h x / z - h x| ∂μ) = |z-1| := by
    have heq : (fun x => |h x / z - h x|) =
        (fun x => |1/z-1| * h x) := by
      funext x
      rw [show h x / z - h x = (1/z-1)*h x by ring,
        abs_mul, abs_of_nonneg (hpos x)]
    rw [heq, integral_const_mul]
    change |1/z-1| * z = |z-1|
    calc
      _ = |1/z-1| * |z| := by rw [abs_of_pos (show 0 < z from hz)]
      _ = |(1/z-1)*z| := (abs_mul _ _).symm
      _ = |1-z| := by congr 1; field_simp [(show 0 < z from hz).ne']
      _ = |z-1| := abs_sub_comm _ _
  have hpoint (x : ℝ) : |h x/z - ρ x| ≤ |h x/z-h x| + |h x-ρ x| := by
    simpa only [sub_add_sub_cancel] using abs_add_le (h x/z-h x) (h x-ρ x)
  have hmono := integral_mono ((hi.div_const z).sub hρi).abs
    (((hi.div_const z).sub hi).abs.add ((hi.sub hρi).abs)) hpoint
  simp only [Pi.add_apply, Pi.sub_apply] at hmono
  have hni : Integrable (fun x => |h x / z - h x|) μ := ((hi.div_const z).sub hi).abs
  have hri : Integrable (fun x => |h x - ρ x|) μ := (hi.sub hρi).abs
  rw [integral_add hni hri, hnorm] at hmono
  change (∫ x, |h x/z-ρ x| ∂μ) ≤ _
  linarith

/-- Positive bounded densities have integrable entropy integrands. -/
theorem integrable_mul_log_of_bounds (μ : Measure ℝ) [IsFiniteMeasure μ]
    (ρ : ℝ → ℝ) (hρ : AEStronglyMeasurable ρ μ) {a b : ℝ}
    (ha : 0 < a) (hbound : ∀ᵐ x ∂μ, ρ x ∈ Icc a b) :
    Integrable (fun x => ρ x * Real.log (ρ x)) μ := by
  have hmeas : AEStronglyMeasurable (fun x => ρ x * Real.log (ρ x)) μ :=
    Real.continuous_mul_log.comp_aestronglyMeasurable hρ
  apply (integrable_const (|b| * (|Real.log a| + |Real.log b|))).mono' hmeas
  filter_upwards [hbound] with x hx
  have hxpos := ha.trans_le hx.1
  have hla := Real.log_le_log ha hx.1
  have hlb := Real.log_le_log hxpos hx.2
  have hl : |Real.log (ρ x)| ≤ |Real.log a| + |Real.log b| := by
    apply abs_le.mpr
    constructor
    · linarith [neg_abs_le (Real.log a), abs_nonneg (Real.log b)]
    · linarith [le_abs_self (Real.log b), abs_nonneg (Real.log a)]
  rw [Real.norm_eq_abs, abs_mul, abs_of_pos hxpos]
  exact mul_le_mul (hx.2.trans (le_abs_self b)) hl (abs_nonneg _)
    (abs_nonneg b)

/-- A bounded positive probability density admits positive continuous,
normalized approximations with explicit L1 and entropy-integrand errors. -/
theorem exists_continuous_normalized_approx (μ : Measure ℝ)
    [IsProbabilityMeasure μ] [μ.WeaklyRegular]
    (ρ : ℝ → ℝ) (hρ : Integrable ρ μ) (hρmass : ∫ x, ρ x ∂μ = 1)
    {a b ε : ℝ} (ha : 0 < a) (hab : a ≤ b)
    (hbound : ∀ᵐ x ∂μ, ρ x ∈ Icc a b) (hε : 0 < ε) (hεsmall : ε ≤ 1/2) :
    ∃ h : ℝ → ℝ, Continuous h ∧ (∀ x, h x ∈ Icc (a/2) (2*b)) ∧
      Integrable h μ ∧ (∫ x, h x ∂μ) = 1 ∧
      (∫ x, |h x - ρ x| ∂μ) ≤ 2*ε ∧
      (∫ x, |h x*Real.log (h x) - ρ x*Real.log (ρ x)| ∂μ) ≤
        2 * (|Real.log (a/2)| + |Real.log (2*b)| + 1) * ε := by
  obtain ⟨g, hgc, hgb, hgi, hge⟩ :=
    exists_continuous_clamped_approx μ ρ hρ hab hbound hε
  let z := ∫ x, g x ∂μ
  have hzerror : |z-1| ≤ ε := by
    have h := norm_integral_le_integral_norm (f := fun x => g x - ρ x) (μ := μ)
    rw [integral_sub hgi hρ, hρmass] at h
    have h' : |z-1| ≤ ∫ x, |g x - ρ x| ∂μ := by
      simpa only [Real.norm_eq_abs, z] using h
    exact h'.trans hge
  have hzr := abs_le.mp hzerror
  have hzlo : (1:ℝ)/2 ≤ z := by linarith
  have hzhi : z ≤ 2 := by linarith
  have hz : 0 < z := by linarith
  let h := fun x => g x/z
  have hhc : Continuous h := hgc.div_const z
  have hhi : Integrable h μ := hgi.div_const z
  have hhb (x : ℝ) : h x ∈ Icc (a/2) (2*b) := by
    constructor
    · apply (le_div_iff₀ hz).mpr
      have h := mul_le_mul_of_nonneg_left hzhi (by positivity : 0 ≤ a/2)
      linarith [(hgb x).1]
    · apply (div_le_iff₀ hz).mpr
      have hbpos : 0 ≤ b := (ha.trans_le hab).le
      nlinarith [(hgb x).2, mul_le_mul_of_nonneg_left hzlo hbpos]
  have hρb : ∀ᵐ x ∂μ, ρ x ∈ Icc (a/2) (2*b) := by
    filter_upwards [hbound] with x hx
    have hbpos : 0 ≤ b := (ha.trans_le hab).le
    constructor <;> linarith [hx.1, hx.2]
  have hmass : (∫ x, h x ∂μ) = 1 := by
    rw [show h = (fun x => g x/z) from rfl, integral_div]
    exact div_self hz.ne'
  have herror : (∫ x, |h x-ρ x| ∂μ) ≤ 2*ε :=
    (normalized_l1_error_le μ g ρ hgi hρ (fun x => (ha.trans_le (hgb x).1).le)
      hρmass hz).trans (mul_le_mul_of_nonneg_left hge (by norm_num))
  refine ⟨h, hhc, hhb, hhi, hmass, herror, ?_⟩
  let C := |Real.log (a/2)| + |Real.log (2*b)| + 1
  have hC : 0 ≤ C := by dsimp [C]; positivity
  have hhe := integrable_mul_log_of_bounds μ h hhi.aestronglyMeasurable
    (by positivity : 0 < a/2) (Eventually.of_forall hhb)
  have hρe := integrable_mul_log_of_bounds μ ρ hρ.aestronglyMeasurable
    (by positivity : 0 < a/2) hρb
  have hm := integral_mono_ae (hhe.sub hρe).abs (((hhi.sub hρ).abs).const_mul C) ?_
  · rw [integral_const_mul] at hm
    have hs := mul_le_mul_of_nonneg_left herror hC
    dsimp [C] at hm hs
    linarith
  · filter_upwards [hρb] with x hx
    exact abs_mul_log_sub_le (by positivity : 0 < a/2) (hhb x) hx

end NeuralGeneralization.BatchTwoImprovedDensityApprox
