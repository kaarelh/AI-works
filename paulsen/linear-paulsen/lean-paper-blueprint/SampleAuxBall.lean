import Paulsen.Paper.SampleAuxS3

/-!
# Helpers for `ModerateSample`: the Gaussian density bound used in (S3)

A Gaussian of variance `σ²` lies in an interval of length `ℓ` with probability at most
`ℓ/√(2πσ²)` (the maximum of its density times `ℓ`).
-/

namespace Paulsen.Paper

open Matrix MeasureTheory ProbabilityTheory Paulsen
open scoped BigOperators NNReal ENNReal

noncomputable section

/-- The density bound on an interval. -/
theorem gaussianReal_Icc_le (μ : ℝ) {v : ℝ≥0} (hv : v ≠ 0) {a b : ℝ} (hab : a ≤ b) :
    (gaussianReal μ v).real (Set.Icc a b) ≤ (b - a) * (Real.sqrt (2 * Real.pi * v))⁻¹ := by
  have hle : gaussianReal μ v (Set.Icc a b) ≤
      ENNReal.ofReal ((Real.sqrt (2 * Real.pi * v))⁻¹) * ENNReal.ofReal (b - a) := by
    rw [gaussianReal_apply μ hv, ← Real.volume_Icc, ← setLIntegral_const]
    apply setLIntegral_mono measurable_const
    intro x _
    exact ENNReal.ofReal_le_ofReal (gaussianPDFReal_le_max μ v x)
  have hfin : ENNReal.ofReal ((Real.sqrt (2 * Real.pi * v))⁻¹) * ENNReal.ofReal (b - a) ≠ ⊤ :=
    ENNReal.mul_ne_top ENNReal.ofReal_ne_top ENNReal.ofReal_ne_top
  calc (gaussianReal μ v).real (Set.Icc a b)
      ≤ (ENNReal.ofReal ((Real.sqrt (2 * Real.pi * v))⁻¹) * ENNReal.ofReal (b - a)).toReal :=
        ENNReal.toReal_mono hfin hle
    _ = (b - a) * (Real.sqrt (2 * Real.pi * v))⁻¹ := by
        rw [ENNReal.toReal_mul, ENNReal.toReal_ofReal (by positivity),
          ENNReal.toReal_ofReal (by linarith), mul_comm]

variable {κ : Type*} [Fintype κ] [DecidableEq κ]
set_option linter.unusedSectionVars false

/-- Small-ball bound for an affine image of a standard Gaussian linear functional. -/
theorem dual_smallBall_le (L : StrongDual ℝ (EuclideanSpace ℝ κ)) (hL : 0 < ‖L‖) (m r : ℝ)
    (hr : 0 ≤ r) :
    (stdGaussian (EuclideanSpace ℝ κ)).real {g | |m + L g| ≤ r} ≤
      2 * r * (Real.sqrt (2 * Real.pi * ‖L‖ ^ 2))⁻¹ := by
  have hlaw := hasLaw_dual_stdGaussian L
  set v : ℝ≥0 := (‖L‖ ^ 2).toNNReal
  have hv : v ≠ 0 := by
    simp only [v, ne_eq, Real.toNNReal_eq_zero, not_le]
    positivity
  have hvR : (v : ℝ) = ‖L‖ ^ 2 := Real.coe_toNNReal _ (sq_nonneg _)
  have hset : {g : EuclideanSpace ℝ κ | |m + L g| ≤ r} = L ⁻¹' Set.Icc (-r - m) (r - m) := by
    ext g
    simp only [Set.mem_setOf_eq, Set.mem_preimage, Set.mem_Icc, abs_le]
    constructor <;> intro h <;> constructor <;> linarith [h.1, h.2]
  rw [hset, ← map_measureReal_apply L.continuous.measurable measurableSet_Icc, hlaw.map_eq]
  have h := gaussianReal_Icc_le 0 hv (show -r - m ≤ r - m by linarith)
  rw [hvR] at h
  calc _ ≤ (r - m - (-r - m)) * (Real.sqrt (2 * Real.pi * ‖L‖ ^ 2))⁻¹ := h
    _ = _ := by ring

/-- `E φ((m + L g)/s) ≤ P(|m + L g| ≤ 2hs)` for `φ ∈ [0,1]` vanishing outside `[-2h,2h]`. -/
theorem integral_phi_affine_le (φ : ℝ → ℝ) (hφc : Continuous φ)
    (hφ01 : ∀ x, 0 ≤ φ x ∧ φ x ≤ 1) {h : ℝ} (hφ0 : ∀ x, 2 * h < |x| → φ x = 0)
    (L : StrongDual ℝ (EuclideanSpace ℝ κ)) (m : ℝ) {s : ℝ} (hs : 0 < s) :
    ∫ g, φ ((m + L g) / s) ∂stdGaussian (EuclideanSpace ℝ κ) ≤
      (stdGaussian (EuclideanSpace ℝ κ)).real {g | |m + L g| ≤ 2 * h * s} := by
  set S : Set (EuclideanSpace ℝ κ) := {g | |m + L g| ≤ 2 * h * s}
  have hS : MeasurableSet S := by
    apply measurableSet_le _ measurable_const
    exact (measurable_const.add L.continuous.measurable).abs
  have hpt : ∀ g, φ ((m + L g) / s) ≤ S.indicator 1 g := by
    intro g
    by_cases hg : g ∈ S
    · rw [Set.indicator_of_mem hg]; exact (hφ01 _).2
    · rw [Set.indicator_of_notMem hg]
      have : 2 * h < |(m + L g) / s| := by
        rw [abs_div, abs_of_pos hs, lt_div_iff₀ hs]
        simp only [S, Set.mem_setOf_eq, not_le] at hg
        exact hg
      rw [hφ0 _ this]
  have hint : Integrable (fun g => φ ((m + L g) / s)) (stdGaussian (EuclideanSpace ℝ κ)) := by
    apply (integrable_const (1 : ℝ)).mono'
    · exact (hφc.comp ((continuous_const.add L.continuous).div_const s)).aestronglyMeasurable
    · exact ae_of_all _ fun g => by
        rw [Real.norm_eq_abs, abs_of_nonneg (hφ01 _).1]; exact (hφ01 _).2
  calc ∫ g, φ ((m + L g) / s) ∂stdGaussian (EuclideanSpace ℝ κ)
      ≤ ∫ g, S.indicator 1 g ∂stdGaussian (EuclideanSpace ℝ κ) :=
        integral_mono hint ((integrable_const (1 : ℝ)).indicator hS) hpt
    _ = _ := integral_indicator_one hS

/-- Combined: `E φ((m + tL g)/s) ≤ 4hs/(t√(2π‖L‖²))`. -/
theorem integral_phi_affine_le_density (φ : ℝ → ℝ) (hφc : Continuous φ)
    (hφ01 : ∀ x, 0 ≤ φ x ∧ φ x ≤ 1) {h : ℝ} (hh : 0 < h) (hφ0 : ∀ x, 2 * h < |x| → φ x = 0)
    (L : StrongDual ℝ (EuclideanSpace ℝ κ)) (hL : 0 < ‖L‖) (m : ℝ) {s t : ℝ} (hs : 0 < s)
    (ht : 0 < t) :
    ∫ g, φ ((m + t * L g) / s) ∂stdGaussian (EuclideanSpace ℝ κ) ≤
      4 * h * s / t * (Real.sqrt (2 * Real.pi * ‖L‖ ^ 2))⁻¹ := by
  have h1 := integral_phi_affine_le φ hφc hφ01 hφ0 (t • L) m hs
  have htL : ‖t • L‖ = t * ‖L‖ := by rw [norm_smul, Real.norm_eq_abs, abs_of_pos ht]
  have h2 := dual_smallBall_le (t • L) (by rw [htL]; positivity) m (2 * h * s) (by positivity)
  simp only [_root_.smul_apply, smul_eq_mul] at h1 h2
  refine h1.trans (h2.trans (le_of_eq ?_))
  rw [htL, mul_pow, show 2 * Real.pi * (t ^ 2 * ‖L‖ ^ 2) = t ^ 2 * (2 * Real.pi * ‖L‖ ^ 2) by ring,
    Real.sqrt_mul (sq_nonneg t), Real.sqrt_sq ht.le, mul_inv]
  field_simp
  ring

end

end Paulsen.Paper
