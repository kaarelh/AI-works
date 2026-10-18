import Mathlib.Probability.ConditionalProbability
import Mathlib.InformationTheory.KullbackLeibler.Basic
import Mathlib.MeasureTheory.Measure.Decomposition.Lebesgue
import Mathlib.Tactic.FieldSimp
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Positivity

/-! # Exact conditioning and restoration of discarded posterior mass -/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory

namespace NeuralGeneralization.RobustPosterior

variable {W : Type*} [MeasurableSpace W]

theorem cond_real_eq_ratio (μ : Measure W) (E A : Set W) (hE : MeasurableSet E) :
    (cond μ E).real A = μ.real (E ∩ A) / μ.real E := by
  rw [Measure.real, cond_apply hE, ENNReal.toReal_mul, ENNReal.toReal_inv]
  simp only [Measure.real, div_eq_mul_inv, mul_comm]

theorem cond_real_le_ratio (μ : Measure W) [IsFiniteMeasure μ]
    (E A : Set W) (hE : MeasurableSet E) :
    (cond μ E).real A ≤ μ.real A / μ.real E := by
  rw [cond_real_eq_ratio μ E A hE]
  exact div_le_div_of_nonneg_right (measureReal_mono Set.inter_subset_right) measureReal_nonneg

theorem cond_null_of_disjoint (μ : Measure W) (E A : Set W) (hE : MeasurableSet E)
    (hdis : Disjoint E A) : (cond μ E).real A = 0 := by
  rw [cond_real_eq_ratio μ E A hE, Set.disjoint_iff_inter_eq_empty.mp hdis]
  simp

theorem retained_restore (Q : Measure W) [IsProbabilityMeasure Q]
    (F A : Set W) (hF : MeasurableSet F) (hFpos : 0 < Q.real F) :
    Q.real A ≤ Q.real Fᶜ + (cond Q F).real A := by
  have hFle : Q.real F ≤ 1 := (measureReal_mono (Set.subset_univ _)).trans_eq probReal_univ
  have hpart : Q.real (F ∩ A) ≤ (cond Q F).real A := by
    rw [cond_real_eq_ratio Q F A hF]
    apply (le_div_iff₀ hFpos).mpr
    exact mul_le_of_le_one_right measureReal_nonneg hFle
  have hsub : A ⊆ (F ∩ A) ∪ Fᶜ := by
    intro w hw
    by_cases hmem : w ∈ F
    · exact Or.inl ⟨hmem, hw⟩
    · exact Or.inr hmem
  have hh := (measureReal_mono (μ := Q) hsub).trans (measureReal_union_le _ _)
  linarith

theorem retained_restore_of_tail (Q : Measure W) [IsProbabilityMeasure Q]
    (F A : Set W) (hF : MeasurableSet F) (hFpos : 0 < Q.real F)
    {β : ℝ} (htail : Q.real Fᶜ ≤ β) :
    Q.real A ≤ β + (cond Q F).real A := by
  have h := retained_restore Q F A hF hFpos
  linarith

theorem raw_retained_mass_lower (μ : Measure W) [IsProbabilityMeasure μ]
    (E F : Set W) (hE : MeasurableSet E) (hF : MeasurableSet F)
    (hEpos : 0 < μ.real E) {a β : ℝ} (ha : a ≤ μ.real E)
    (hβ : β ≤ 1) (htail : (cond μ E).real Fᶜ ≤ β) :
    (1 - β) * a ≤ μ.real (E ∩ F) := by
  have hE0 : μ E ≠ 0 := by
    intro h
    simp only [Measure.real, h, ENNReal.toReal_zero] at hEpos
    exact (lt_irrefl 0) hEpos
  letI : IsProbabilityMeasure (cond μ E) := cond_isProbabilityMeasure hE0
  have hkeep : 1 - β ≤ (cond μ E).real F := by
    rw [probReal_compl_eq_one_sub hF] at htail
    linarith
  rw [cond_real_eq_ratio μ E F hE] at hkeep
  have hmul := (le_div_iff₀ hEpos).mp hkeep
  exact (mul_le_mul_of_nonneg_left ha (sub_nonneg.mpr hβ)).trans hmul

/-- The actual log density of conditioning is constant almost everywhere
under the conditional law. This is not a postulated entropy budget. -/
theorem cond_llr_ae (μ : Measure W) [IsProbabilityMeasure μ]
    (E : Set W) (hE : MeasurableSet E) (hE0 : μ E ≠ 0) :
    llr (cond μ E) μ =ᵐ[cond μ E] fun _ => -Real.log (μ.real E) := by
  have hd := Measure.rnDeriv_smul_left_of_ne_top (μ.restrict E) μ
    (ENNReal.inv_ne_top.mpr hE0)
  have hr := Measure.rnDeriv_restrict_self μ hE
  have hac : cond μ E ≪ μ := cond_absolutelyContinuous
  have hd' := hac.ae_le hd
  have hr' := hac.ae_le hr
  filter_upwards [hd', hr', ae_cond_mem (μ := μ) hE] with w hw hwr hmem
  change Real.log ((cond μ E).rnDeriv μ w).toReal = _
  change ((cond μ E).rnDeriv μ) w = _ at hw
  rw [hw]
  simp only [Pi.smul_apply]
  rw [hwr, Set.indicator_of_mem hmem]
  simp only [Pi.one_apply, smul_eq_mul, mul_one, ENNReal.toReal_inv, Real.log_inv]
  rfl

/-- Exact KL cost of the literal normalized restriction of a probability law. -/
theorem klDiv_cond_eq (μ : Measure W) [IsProbabilityMeasure μ]
    (E : Set W) (hE : MeasurableSet E) (hE0 : μ E ≠ 0) :
    klDiv (cond μ E) μ = ENNReal.ofReal (-Real.log (μ.real E)) := by
  letI : IsProbabilityMeasure (cond μ E) := cond_isProbabilityMeasure hE0
  have hllr := cond_llr_ae μ E hE hE0
  have hi : Integrable (llr (cond μ E) μ) (cond μ E) :=
    (integrable_const (-Real.log (μ.real E))).congr hllr.symm
  rw [klDiv_of_ac_of_integrable cond_absolutelyContinuous hi, integral_congr_ae hllr]
  simp

theorem klDiv_cond_le_of_mass_lower (μ : Measure W) [IsProbabilityMeasure μ]
    (E : Set W) (hE : MeasurableSet E) {K : ℝ}
    (hmass : Real.exp (-K) ≤ μ.real E) :
    klDiv (cond μ E) μ ≤ ENNReal.ofReal K := by
  have hp : 0 < μ.real E := (Real.exp_pos _).trans_le hmass
  have hE0 : μ E ≠ 0 := by
    intro hh
    simp only [Measure.real, hh, ENNReal.toReal_zero] at hp
    exact (lt_irrefl 0) hp
  rw [klDiv_cond_eq μ E hE hE0]
  apply ENNReal.ofReal_le_ofReal
  have hlog := Real.log_le_log (Real.exp_pos (-K)) hmass
  rw [Real.log_exp] at hlog
  linarith

end NeuralGeneralization.RobustPosterior
