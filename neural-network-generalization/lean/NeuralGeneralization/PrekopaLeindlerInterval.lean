import NeuralGeneralization.PositiveCDFTransport
import Mathlib.Analysis.MeanInequalities

/-! The one-dimensional Prékopa--Leindler inequality for positive
continuous functions on a compact interval, proved by actual CDF transport. -/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.PrekopaLeindlerInterval
open PositiveCDFTransport

def mix (t x y : ℝ) : ℝ := (1 - t) * x + t * y

theorem mix_mem_Icc {a b t x y : ℝ} (ht : t ∈ Icc 0 1)
    (hx : x ∈ Icc a b) (hy : y ∈ Icc a b) : mix t x y ∈ Icc a b := by
  unfold mix
  have hα : 0 ≤ 1 - t := sub_nonneg.mpr ht.2
  constructor
  · have h₁ := mul_le_mul_of_nonneg_left hx.1 hα
    have h₂ := mul_le_mul_of_nonneg_left hy.1 ht.1
    nlinarith
  · have h₁ := mul_le_mul_of_nonneg_left hx.2 hα
    have h₂ := mul_le_mul_of_nonneg_left hy.2 ht.1
    nlinarith

theorem transport_weight_identity {u v F G t : ℝ}
    (hu : 0 < u) (hv : 0 < v) (hF : 0 < F) (hG : 0 < G) :
    u ^ (1-t) * v ^ t * ((G / v) * (u / F)) ^ t = u * (G / F) ^ t := by
  rw [Real.mul_rpow (div_pos hG hv).le (div_pos hu hF).le,
    Real.div_rpow hG.le hv.le, Real.div_rpow hu.le hF.le, Real.div_rpow hG.le hF.le]
  have hvpow : v ^ t ≠ 0 := (Real.rpow_pos_of_pos hv t).ne'
  have hFpow : F ^ t ≠ 0 := (Real.rpow_pos_of_pos hF t).ne'
  have huadd : u ^ (1-t) * u ^ t = u := by
    rw [← Real.rpow_add hu, sub_add_cancel, Real.rpow_one]
  field_simp
  nlinarith [congrArg (fun z : ℝ => z * G ^ t) huadd]

theorem transport_weight_bound {u v F G t h : ℝ}
    (hu : 0 < u) (hv : 0 < v) (hF : 0 < F) (hG : 0 < G) (ht : t ∈ Icc 0 1)
    (hh : u ^ (1-t) * v ^ t ≤ h) :
    u * (G / F) ^ t ≤ h * ((1-t) + t * ((G / v) * (u / F))) := by
  have hr : 0 < (G / v) * (u / F) := mul_pos (div_pos hG hv) (div_pos hu hF)
  have ham := Real.geom_mean_le_arith_mean2_weighted (sub_nonneg.mpr ht.2) ht.1
    (show (0 : ℝ) ≤ 1 by norm_num) hr.le (by ring : (1-t)+t=1)
  simp only [Real.one_rpow, one_mul, mul_one] at ham
  have hcoef : 0 ≤ (1-t) + t * ((G / v) * (u / F)) :=
    add_nonneg (sub_nonneg.mpr ht.2) (mul_nonneg ht.1 hr.le)
  rw [← transport_weight_identity hu hv hF hG]
  exact (mul_le_mul_of_nonneg_left ham
    (mul_pos (Real.rpow_pos_of_pos hu _) (Real.rpow_pos_of_pos hv _)).le).trans
      (mul_le_mul_of_nonneg_right hh hcoef)

theorem mass_weight_identity {F G t : ℝ} (hF : 0 < F) (hG : 0 < G) :
    F * (G / F) ^ t = F ^ (1-t) * G ^ t := by
  rw [Real.div_rpow hG.le hF.le]
  have hpow : F ^ (1-t) * F ^ t = F := by
    rw [← Real.rpow_add hF, sub_add_cancel, Real.rpow_one]
  have hne := (Real.rpow_pos_of_pos hF t).ne'
  field_simp
  nlinarith [congrArg (fun z : ℝ => z * G ^ t) hpow]

set_option maxHeartbeats 600000 in
/-- Actual one-dimensional integral inequality. No transport, optimization,
or marginalization theorem is assumed. -/
theorem prekopa_leindler_interval {f g h : ℝ → ℝ} {a b t : ℝ}
    (hf : Continuous f) (hg : Continuous g) (hh : Continuous h)
    (hfpos : ∀ x, 0 < f x) (hgpos : ∀ x, 0 < g x)
    (hab : a < b) (ht : t ∈ Icc 0 1)
    (hpoint : ∀ x ∈ Icc a b, ∀ y ∈ Icc a b,
      f x ^ (1-t) * g y ^ t ≤ h (mix t x y)) :
    mass f a b ^ (1-t) * mass g a b ^ t ≤ mass h a b := by
  let T := transport hg hgpos hab f
  let T' := fun x => (mass g a b / g (T x)) * (f x / mass f a b)
  let S := fun x => mix t x (T x)
  let S' := fun x => (1-t) + t * T' x
  have hF : 0 < mass f a b := mass_pos hf hfpos hab
  have hG : 0 < mass g a b := mass_pos hg hgpos hab
  have hT : Continuous T := continuous_transport hf hg hgpos hab
  have hT' : Continuous T' :=
    (continuous_const.div (hg.comp hT) (fun x => (hgpos _).ne')).mul (hf.div_const _)
  have hS : Continuous S := (continuous_const.mul continuous_id).add (continuous_const.mul hT)
  have hS' : Continuous S' := continuous_const.add (continuous_const.mul hT')
  have hderiv (x : ℝ) (hx : x ∈ Ioo a b) : HasDerivAt S (S' x) x := by
    dsimp only [S, S', mix]
    convert ((hasDerivAt_id x).const_mul (1-t)).add
      ((hasDerivAt_transport hf hfpos hg hgpos hab hx).const_mul t) using 1
    all_goals try simp only [T', T, mul_one]
    all_goals rfl
  have hTa : T a = a := by
    dsimp only [T, transport]
    rw [cdf_left, quantile_zero]
  have hTb : T b = b := by
    dsimp only [T, transport]
    rw [cdf_right hf hfpos hab, quantile_one]
  have hSa : S a = a := by dsimp [S, mix]; rw [hTa]; ring
  have hSb : S b = b := by dsimp [S, mix]; rw [hTb]; ring
  have hTmem (x : ℝ) : T x ∈ Icc a b := quantile_mem_Icc hg hgpos hab _
  have hchange : (∫ x in a..b, h (S x) * S' x) = mass h a b := by
    have hs := intervalIntegral.integral_comp_mul_deriv'' (a := a) (b := b) hS.continuousOn
      (fun x hx => (hderiv x (by simpa only [min_eq_left hab.le, max_eq_right hab.le] using hx)).hasDerivWithinAt)
      hS'.continuousOn hh.continuousOn
    simpa only [Function.comp_def, hSa, hSb, mass] using hs
  rw [← mass_weight_identity hF hG, ← hchange]
  unfold mass
  rw [← intervalIntegral.integral_mul_const]
  apply intervalIntegral.integral_mono_on hab.le
    ((hf.mul_const _).intervalIntegrable a b) (((hh.comp hS).mul hS').intervalIntegrable a b)
  intro x hx
  exact transport_weight_bound (hfpos x) (hgpos (T x)) hF hG ht (hpoint x hx (T x) (hTmem x))

end NeuralGeneralization.PrekopaLeindlerInterval
end
