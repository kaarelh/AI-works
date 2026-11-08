import NeuralGeneralization.OnlineLowerTanhSinePowers
import Mathlib.Analysis.SpecialFunctions.ImproperIntegrals
import Mathlib.MeasureTheory.Group.Integral

/-! # Absolute versus signed Laplace integrals of odd sine powers

Splitting once at a half-period proves the exact folding factor without
an infinite-series differentiation or a convexity assumption on a kernel.
-/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

def laplaceSinePower (p : ℕ) (c a : ℝ) : ℝ :=
  ∫ t : ℝ in Ioi 0, Real.exp (-c*t) * Real.sin (a*t)^p

def laplaceAbsSinePower (p : ℕ) (c a : ℝ) : ℝ :=
  ∫ t : ℝ in Ioi 0, Real.exp (-c*t) * |Real.sin (a*t)|^p

theorem integrable_laplace_sinePower (p : ℕ) (c a : ℝ) (hc : 0 < c) :
    IntegrableOn (fun t : ℝ => Real.exp (-c*t)*Real.sin (a*t)^p) (Ioi 0) := by
  apply (integrableOn_exp_mul_Ioi (show -c < 0 by linarith) 0).mono'
  · exact (by fun_prop : Continuous (fun t : ℝ => Real.exp (-c*t)*Real.sin (a*t)^p)).aestronglyMeasurable
  · filter_upwards [] with t
    simp only [Real.norm_eq_abs, abs_mul, abs_of_pos (Real.exp_pos _), abs_pow]
    exact mul_le_of_le_one_right (Real.exp_pos _).le (pow_le_one₀ (abs_nonneg _) (Real.abs_sin_le_one _) )

theorem integrable_laplace_absSinePower (p : ℕ) (c a : ℝ) (hc : 0 < c) :
    IntegrableOn (fun t : ℝ => Real.exp (-c*t)*|Real.sin (a*t)|^p) (Ioi 0) := by
  simpa only [IntegrableOn, Real.norm_eq_abs,abs_mul,abs_of_pos (Real.exp_pos _),abs_pow] using
    (integrable_laplace_sinePower p c a hc).norm

theorem integral_Ioi_translate (f : ℝ → ℝ) (h : ℝ) :
    (∫ t : ℝ in Ioi h, f t) = ∫ t : ℝ in Ioi 0, f (t+h) := by
  have he : (fun t : ℝ => t+h) ⁻¹' Ioi h = Ioi 0 := by
    ext t
    simp only [mem_preimage,mem_Ioi]
    constructor <;> intro ht <;> linarith
  have hm := (measurePreserving_add_right (volume : Measure ℝ) h).setIntegral_preimage_emb
    (MeasurableEquiv.addRight h).measurableEmbedding f (Ioi h)
  rw [he] at hm
  exact hm.symm

/-- The common folding factor depends on the half-period and Laplace
parameter, and is independent of the odd exponent. -/
theorem laplace_abs_eq_factor_signed (p : ℕ) (hp : Odd p)
    (c a : ℝ) (hc : 0 < c) (ha : 0 < a) :
    laplaceAbsSinePower p c a =
      (1 + Real.exp (-c*(Real.pi/a))) / (1 - Real.exp (-c*(Real.pi/a))) *
        laplaceSinePower p c a := by
  let h := Real.pi/a
  let z := Real.exp (-c*h)
  have hh : 0 < h := div_pos Real.pi_pos ha
  have hah : a*h = Real.pi := by dsimp [h]; field_simp
  have hs (t : ℝ) : Real.sin (a*(t+h)) = -Real.sin (a*t) := by
    rw [mul_add,hah,Real.sin_add_pi]
  have he (t : ℝ) : Real.exp (-c*(t+h)) = z * Real.exp (-c*t) := by
    rw [mul_add,Real.exp_add]
    exact mul_comm _ _
  have htail : (∫ t : ℝ in Ioi h, Real.exp (-c*t)*Real.sin (a*t)^p) =
      -z * laplaceSinePower p c a := by
    rw [integral_Ioi_translate]
    simp_rw [he,hs,hp.neg_pow]
    unfold laplaceSinePower
    rw [← integral_const_mul]
    congr 1
    funext t
    ring
  have habstail : (∫ t : ℝ in Ioi h, Real.exp (-c*t)*|Real.sin (a*t)|^p) =
      z * laplaceAbsSinePower p c a := by
    rw [integral_Ioi_translate]
    simp_rw [he,hs,abs_neg]
    unfold laplaceAbsSinePower
    rw [← integral_const_mul]
    congr 1
    funext t
    ring
  have hlocal : (∫ t in 0..h, Real.exp (-c*t)*|Real.sin (a*t)|^p) =
      ∫ t in 0..h, Real.exp (-c*t)*Real.sin (a*t)^p := by
    apply intervalIntegral.integral_congr
    intro t ht
    rw [uIcc_of_le hh.le] at ht
    have harg : a*t ∈ Icc 0 Real.pi := by
      constructor
      · exact mul_nonneg ha.le ht.1
      · calc a*t ≤ a*h := mul_le_mul_of_nonneg_left ht.2 ha.le
             _ = Real.pi := hah
    dsimp only
    rw [abs_of_nonneg (Real.sin_nonneg_of_mem_Icc harg)]
  have hsplit := intervalIntegral.integral_Ioi_sub_Ioi (integrable_laplace_sinePower p c a hc) hh.le
  have habssplit := intervalIntegral.integral_Ioi_sub_Ioi (integrable_laplace_absSinePower p c a hc) hh.le
  rw [htail] at hsplit
  rw [habstail,hlocal] at habssplit
  change laplaceSinePower p c a - -z*laplaceSinePower p c a = _ at hsplit
  change laplaceAbsSinePower p c a - z*laplaceAbsSinePower p c a = _ at habssplit
  have hz : z < 1 := Real.exp_lt_one_iff.mpr (by nlinarith)
  change laplaceAbsSinePower p c a = (1+z)/(1-z)*laplaceSinePower p c a
  rw [div_mul_eq_mul_div]
  apply (eq_div_iff (by linarith : 1-z ≠ 0)).mpr
  nlinarith [hsplit,habssplit]

end NeuralGeneralization.OnlineLowerTanh
