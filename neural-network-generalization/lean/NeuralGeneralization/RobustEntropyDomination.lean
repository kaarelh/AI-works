import Mathlib.InformationTheory.KullbackLeibler.Basic

/-! # Relative entropy under a bounded density

The actual measure order `μ ≤ c • ν` implies `KL(μ,ν) ≤ log c` for
probability measures. No entropy estimate is included as a hypothesis.
-/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal NNReal

namespace NeuralGeneralization.RobustEntropyDomination

theorem rnDeriv_le_of_le_smul {Ω : Type*} [MeasurableSpace Ω]
    (μ ν : Measure Ω) [IsFiniteMeasure μ] [IsFiniteMeasure ν]
    (c : ℝ≥0∞) (h : μ ≤ c • ν) :
    ∀ᵐ x ∂ν, μ.rnDeriv ν x ≤ c := by
  apply ae_le_of_forall_setLIntegral_le_of_sigmaFinite
    (Measure.measurable_rnDeriv μ ν)
  intro s hs hfin
  calc
    (∫⁻ x in s, μ.rnDeriv ν x ∂ν) ≤ μ s := Measure.setLIntegral_rnDeriv_le s
    _ ≤ (c • ν) s := h s
    _ = ∫⁻ x in s, c ∂ν := by simp

theorem klFun_le_of_le {u c : ℝ} (hu : 0 ≤ u) (hc : 1 ≤ c) (huc : u ≤ c) :
    klFun u ≤ u * Real.log c - u + 1 := by
  rcases eq_or_lt_of_le hu with rfl | hu
  · simp [klFun]
  · have hlog := Real.log_le_log hu huc
    have hmul := mul_le_mul_of_nonneg_left hlog hu.le
    unfold klFun
    linarith

theorem klDiv_le_log_of_le_smul {Ω : Type*} [MeasurableSpace Ω]
    (μ ν : Measure Ω) [IsProbabilityMeasure μ] [IsProbabilityMeasure ν]
    (c : ℝ) (hc : 1 ≤ c) (h : μ ≤ ENNReal.ofReal c • ν) :
    klDiv μ ν ≤ ENNReal.ofReal (Real.log c) := by
  have hc0 : 0 ≤ c := le_trans (by norm_num) hc
  have hac : μ ≪ ν := Measure.absolutelyContinuous_of_le_smul h
  have hr := rnDeriv_le_of_le_smul μ ν (ENNReal.ofReal c) h
  have hr' : ∀ᵐ x ∂ν, (μ.rnDeriv ν x).toReal ≤ c := by
    filter_upwards [hr] with x hx
    simpa only [ENNReal.toReal_ofReal hc0] using
      ENNReal.toReal_mono ENNReal.ofReal_ne_top hx
  have hlog : 0 ≤ Real.log c := Real.log_nonneg hc
  have hk : Integrable (fun x => klFun (μ.rnDeriv ν x).toReal) ν := by
    apply (integrable_const (c * Real.log c + 1)).mono'
      ((continuous_klFun.measurable.comp (Measure.measurable_rnDeriv μ ν).ennreal_toReal).aestronglyMeasurable)
    filter_upwards [hr'] with x hx
    simp only [Function.comp_apply]
    rw [Real.norm_eq_abs, abs_of_nonneg (klFun_nonneg ENNReal.toReal_nonneg)]
    have hp := klFun_le_of_le ENNReal.toReal_nonneg hc hx
    have hm := mul_le_mul_of_nonneg_right hx hlog
    linarith [ENNReal.toReal_nonneg (a := μ.rnDeriv ν x)]
  have hi : Integrable (fun x => (μ.rnDeriv ν x).toReal) ν :=
    by
      simpa only [integrableOn_univ] using
        (Measure.integrableOn_toReal_rnDeriv (μ := μ) (ν := ν) (s := Set.univ) (by simp))
  have hb := integral_mono_ae hk
    (((hi.mul_const (Real.log c)).sub hi).add (integrable_const 1))
    (hr'.mono fun x hx => klFun_le_of_le ENNReal.toReal_nonneg hc hx)
  have hid : (∫ x, (μ.rnDeriv ν x).toReal * Real.log c -
      (μ.rnDeriv ν x).toReal + 1 ∂ν) = Real.log c := by
    have hs : Integrable (fun x => (μ.rnDeriv ν x).toReal * Real.log c -
        (μ.rnDeriv ν x).toReal) ν := (hi.mul_const _).sub hi
    rw [integral_add hs (integrable_const 1),
      integral_sub (hi.mul_const _) hi, integral_mul_const,
      Measure.integral_toReal_rnDeriv hac]
    simp
  simp only [Pi.add_apply, Pi.sub_apply] at hb
  rw [hid] at hb
  rw [klDiv_eq_integral_klFun, if_pos ⟨hac, (integrable_klFun_rnDeriv_iff hac).mp hk⟩]
  exact ENNReal.ofReal_le_ofReal hb

end NeuralGeneralization.RobustEntropyDomination
