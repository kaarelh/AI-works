import NeuralGeneralization.RobustPosteriorConditioning
import NeuralGeneralization.NetworkSpectralTail
import NeuralGeneralization.RobustModel

/-! # Exact Gaussian readout tail and the retained posterior's KL budget -/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.RobustPosterior
open ConcreteModel

theorem smallPrior_readout_tail {d N r : ℕ}
    (hd : 0 < d) (hN : 0 < N) {σ B : ℝ} (hσ : 0 < σ)
    (hB : 8 * (N : ℝ) * σ ^ 2 ≤ B) :
    (smallPrior d N r σ).real {w | B < readoutEnergy w} ≤
      Real.exp (-B / (4 * σ ^ 2)) := by
  let e : Fin N → WeightIndex d N r := fun i => Sum.inr (Sum.inr i)
  have he : Function.Injective e := Sum.inr_injective.comp Sum.inr_injective
  have hmap : (smallPrior d N r σ).map (fun w j => whiten w (e j)) =
      Measure.pi (fun _ : Fin N => gaussianReal 0 (σ ^ 2).toNNReal) := by
    rw [show (fun (w : Weights d N r) j => whiten w (e j)) =
        (fun (v : Weights d N r) j => v (e j)) ∘ whiten from rfl,
      ← Measure.map_map (measurable_pi_lambda _ fun j => measurable_pi_apply (e j))
        (continuous_whiten d N r).measurable,
      map_smallPrior_whiten hd hN hσ]
    exact productGaussian_map_subfamily _ e he
  have hmeas : Measurable (fun w : Weights d N r => fun j => whiten w (e j)) :=
    measurable_pi_lambda _ fun j =>
      (measurable_pi_apply (e j)).comp (continuous_whiten d N r).measurable
  have hm := Measure.le_map_apply (μ := smallPrior d N r σ) hmeas.aemeasurable
    {v : Fin N → ℝ | B ≤ ∑ j, v j ^ 2}
  rw [hmap] at hm
  have hr := ENNReal.toReal_mono (measure_ne_top _ _) hm
  have hσ2 : 0 < σ ^ 2 := sq_pos_of_pos hσ
  have ht := gaussian_squaredNorm_upper_tail (ι := Fin N) (σ ^ 2).toNNReal
    (by simpa only [Real.coe_toNNReal _ hσ2.le] using hσ2) B
    (by simpa only [Fintype.card_fin, Real.coe_toNNReal _ hσ2.le] using hB)
  have hraw : (smallPrior d N r σ).real
      {w | B ≤ ∑ j, (whiten w (e j)) ^ 2} ≤ Real.exp (-B / (4 * σ ^ 2)) := by
    exact hr.trans (by simpa only [Real.coe_toNNReal _ hσ2.le, Measure.real] using ht)
  apply le_trans (measureReal_mono (μ := smallPrior d N r σ) ?_) hraw
  intro w hw
  change B ≤ ∑ j, whiten w (Sum.inr (Sum.inr j)) ^ 2
  rw [← readout_energy_eq_whitened hd hN]
  exact hw.le

variable {W : Type*} [MeasurableSpace W]

theorem conditional_tail_of_exponential_bounds
    (μ : Measure W) [IsProbabilityMeasure μ] (E F : Set W) (hE : MeasurableSet E)
    {s D B β : ℝ} (hs : 0 < s) (hs1 : s ≤ 1) (hβ : 0 < β) (hβ1 : β ≤ 1)
    (hmass : Real.exp (-D / s) ≤ μ.real E)
    (htail : μ.real F ≤ Real.exp (-B / (4 * s)))
    (hbudget : 4 * (D - Real.log β) ≤ B) :
    (cond μ E).real F ≤ β := by
  have hmasspos : 0 < μ.real E := (Real.exp_pos _).trans_le hmass
  have hratio : μ.real F / μ.real E ≤ Real.exp (-B / (4 * s)) / Real.exp (-D / s) := by
    apply (div_le_div_of_nonneg_right htail hmasspos.le).trans
    exact div_le_div_of_nonneg_left (Real.exp_pos _).le (Real.exp_pos _) hmass
  have hid : Real.exp (-B / (4 * s)) / Real.exp (-D / s) =
      Real.exp ((D - B / 4) / s) := by
    rw [← Real.exp_sub]
    congr 1
    field_simp
    ring
  rw [hid] at hratio
  have hlog : Real.log β ≤ 0 := Real.log_nonpos hβ.le hβ1
  have hexp : (D - B / 4) / s ≤ Real.log β := by
    apply (div_le_iff₀ hs).mpr
    nlinarith
  exact (cond_real_le_ratio μ E F hE).trans
    (hratio.trans ((Real.exp_le_exp.mpr hexp).trans_eq (Real.exp_log hβ)))

theorem retained_exponential_mass
    (μ : Measure W) [IsProbabilityMeasure μ] (E F : Set W)
    (hE : MeasurableSet E) (hF : MeasurableSet F)
    {s D β : ℝ} (hs : 0 < s) (hs1 : s ≤ 1) (hβ : β ≤ 1 / 2)
    (hmass : Real.exp (-D / s) ≤ μ.real E)
    (htail : (cond μ E).real Fᶜ ≤ β) :
    Real.exp (-(D + 1) / s) ≤ μ.real (E ∩ F) := by
  have hp : 0 < μ.real E := (Real.exp_pos _).trans_le hmass
  have hraw := raw_retained_mass_lower μ E F hE hF hp hmass (by linarith) htail
  have hinv : -(1 : ℝ) / s ≤ -1 := (div_le_iff₀ hs).mpr (by linarith)
  have hehalf : Real.exp (-1) ≤ (1 : ℝ) / 2 := by
    have he : (2 : ℝ) ≤ Real.exp 1 := by linarith [Real.add_one_le_exp 1]
    have hi := one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 2) he
    simpa only [one_div, ← Real.exp_neg] using hi
  have hsmall : Real.exp (-1 / s) ≤ 1 - β := by
    exact ((Real.exp_le_exp.mpr hinv).trans hehalf).trans (by linarith)
  have hid : Real.exp (-(D + 1) / s) = Real.exp (-1 / s) * Real.exp (-D / s) := by
    rw [← Real.exp_add]
    congr 1
    ring
  rw [hid]
  exact (mul_le_mul_of_nonneg_right hsmall (Real.exp_pos _).le).trans hraw

theorem retained_klDiv_bound
    (μ : Measure W) [IsProbabilityMeasure μ] (E F : Set W)
    (hE : MeasurableSet E) (hF : MeasurableSet F)
    {s D β : ℝ} (hs : 0 < s) (hs1 : s ≤ 1) (hβ : β ≤ 1 / 2)
    (hmass : Real.exp (-D / s) ≤ μ.real E)
    (htail : (cond μ E).real Fᶜ ≤ β) :
    klDiv (cond μ (E ∩ F)) μ ≤ ENNReal.ofReal ((D + 1) / s) := by
  apply klDiv_cond_le_of_mass_lower μ (E ∩ F) (hE.inter hF)
  simpa only [neg_div] using retained_exponential_mass μ E F hE hF hs hs1 hβ hmass htail

end NeuralGeneralization.RobustPosterior
