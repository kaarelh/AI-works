import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Integral.Bochner.Basic
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity
import Mathlib.Tactic.Ring
import Mathlib.Tactic.FieldSimp

/-!
# Entropy controls the L1 distance of probability densities

The scalar inequalities below are proved directly for the actual KL
integrand. They are intended for the common-density coupling used in robust
compression. No transport or coupling estimate is assumed.
-/

noncomputable section
open MeasureTheory InformationTheory

namespace NeuralGeneralization.RobustPinsker

/-- The squared Hellinger integrand is bounded by the KL integrand. -/
theorem sqrt_sub_one_sq_le_klFun {x : ℝ} (hx : 0 ≤ x) :
    (Real.sqrt x - 1) ^ 2 ≤ klFun x := by
  have hs := Real.sq_sqrt hx
  have hnon := klFun_nonneg (Real.sqrt_nonneg x)
  have hid : klFun x - (Real.sqrt x - 1) ^ 2 =
      2 * Real.sqrt x * klFun (Real.sqrt x) := by
    unfold klFun
    rw [Real.log_sqrt hx]
    calc
      x * Real.log x + 1 - x - (Real.sqrt x - 1) ^ 2 =
          (Real.sqrt x) ^ 2 * Real.log x + 1 - (Real.sqrt x) ^ 2 -
            (Real.sqrt x - 1) ^ 2 := by rw [hs]
      _ = 2 * Real.sqrt x * (Real.sqrt x * (Real.log x / 2) + 1 - Real.sqrt x) := by ring
  have hp : 0 ≤ 2 * Real.sqrt x * klFun (Real.sqrt x) := by positivity
  linarith

/-- A Young-inequality form avoids division by zero at zero relative entropy.
After integration against a probability reference with density of mass one,
this gives `L1 ≤ KL/s + s` for every positive s. -/
theorem abs_sub_one_le_klFun_div_add {x s : ℝ} (hx : 0 ≤ x) (hs : 0 < s) :
    |x - 1| ≤ klFun x / s + s * (x + 1) / 2 := by
  have hroot : 0 ≤ Real.sqrt x := Real.sqrt_nonneg x
  have hsquare := Real.sq_sqrt hx
  have habs : |x - 1| = |Real.sqrt x - 1| * (Real.sqrt x + 1) := by
    rw [← abs_of_nonneg (by positivity : 0 ≤ Real.sqrt x + 1), ← abs_mul]
    congr 1
    nlinarith
  have hyoung := sq_nonneg (|Real.sqrt x - 1| - s * (Real.sqrt x + 1) / 2)
  have hkl := sqrt_sub_one_sq_le_klFun hx
  have hrootbound : (Real.sqrt x + 1) ^ 2 ≤ 2 * (x + 1) := by
    nlinarith [sq_nonneg (Real.sqrt x - 1)]
  have habssq : |Real.sqrt x - 1| ^ 2 = (Real.sqrt x - 1) ^ 2 := sq_abs _
  rw [habs]
  apply (mul_le_mul_iff_right₀ hs).mp
  have hrewrite : s * (klFun x / s + s * (x + 1) / 2) =
      klFun x + s ^ 2 * (x + 1) / 2 := by field_simp
  rw [hrewrite]
  nlinarith [mul_le_mul_of_nonneg_left hrootbound (sq_nonneg s)]

/-- A direct integral form for probability densities and genuine finite KL. -/
theorem integral_abs_rnDeriv_sub_one_le {Ω : Type*} [MeasurableSpace Ω]
    (μ ν : Measure Ω) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (hfinite : klDiv μ ν ≠ ⊤) {s : ℝ} (hs : 0 < s) :
    (∫ x, |(μ.rnDeriv ν x).toReal - 1| ∂ν) ≤
      (klDiv μ ν).toReal / s + s := by
  obtain ⟨hac, hint⟩ := klDiv_ne_top_iff.mp hfinite
  have hd : Integrable (fun x => (μ.rnDeriv ν x).toReal) ν :=
    Measure.integrable_toReal_rnDeriv
  have hk : Integrable (fun x => klFun (μ.rnDeriv ν x).toReal) ν :=
    (integrable_klFun_rnDeriv_iff hac).mpr hint
  have hleft := (hd.sub (integrable_const 1)).abs
  have hright := (hk.div_const s).add (((hd.add (integrable_const 1)).const_mul s).div_const 2)
  have hb := integral_mono hleft hright
    (fun x => abs_sub_one_le_klFun_div_add ENNReal.toReal_nonneg hs)
  have hadd : (∫ x, klFun (μ.rnDeriv ν x).toReal / s +
        s * ((μ.rnDeriv ν x).toReal + 1) / 2 ∂ν) =
      (∫ x, klFun (μ.rnDeriv ν x).toReal / s ∂ν) +
        ∫ x, s * ((μ.rnDeriv ν x).toReal + 1) / 2 ∂ν :=
    integral_add (hk.div_const s)
      (((hd.add (integrable_const 1)).const_mul s).div_const 2)
  calc
    _ ≤ ∫ x, klFun (μ.rnDeriv ν x).toReal / s +
        s * ((μ.rnDeriv ν x).toReal + 1) / 2 ∂ν := hb
    _ = (klDiv μ ν).toReal / s + s := by
      rw [hadd, integral_div, integral_div, integral_const_mul]
      have hsum : (∫ x, (μ.rnDeriv ν x).toReal + 1 ∂ν) =
          (∫ x, (μ.rnDeriv ν x).toReal ∂ν) + ∫ _x, (1 : ℝ) ∂ν :=
        integral_add hd (integrable_const 1)
      rw [hsum, Measure.integral_toReal_rnDeriv hac,
        ← toReal_klDiv_eq_integral_klFun hac]
      simp
      ring

/-- A Pinsker-type estimate (with a deliberately loose constant): the L1
distance of a probability density from one is at most twice sqrt(KL). -/
theorem integral_abs_rnDeriv_sub_one_le_sqrt {Ω : Type*} [MeasurableSpace Ω]
    (μ ν : Measure Ω) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (hfinite : klDiv μ ν ≠ ⊤) :
    (∫ x, |(μ.rnDeriv ν x).toReal - 1| ∂ν) ≤
      2 * Real.sqrt (klDiv μ ν).toReal := by
  by_cases hzero : (klDiv μ ν).toReal = 0
  · have hkzero : klDiv μ ν = 0 :=
      by simpa [hzero] using (ENNReal.ofReal_toReal hfinite).symm
    have hsame := klDiv_eq_zero_iff.mp hkzero
    subst μ
    have hae : (fun x => |(ν.rnDeriv ν x).toReal - 1|) =ᵐ[ν] fun _ => (0 : ℝ) := by
      filter_upwards [Measure.rnDeriv_self ν] with x hx
      simp [hx]
    rw [integral_congr_ae hae]
    simp
  · have hpos : 0 < (klDiv μ ν).toReal :=
      lt_of_le_of_ne ENNReal.toReal_nonneg (Ne.symm hzero)
    have hroot : 0 < Real.sqrt (klDiv μ ν).toReal := Real.sqrt_pos.mpr hpos
    have hb := integral_abs_rnDeriv_sub_one_le μ ν hfinite hroot
    have heq : (klDiv μ ν).toReal / Real.sqrt (klDiv μ ν).toReal =
        Real.sqrt (klDiv μ ν).toReal := by
      apply (div_eq_iff hroot.ne').2
      nlinarith [Real.sq_sqrt hpos.le]
    rw [heq] at hb
    linarith

end NeuralGeneralization.RobustPinsker
