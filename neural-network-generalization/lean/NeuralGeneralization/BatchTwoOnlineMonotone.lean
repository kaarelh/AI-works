import NeuralGeneralization.BatchTwoOnlinePosterior
import Mathlib.Probability.ProductMeasure

/-! # Passing uniform finite-horizon bounds to infinite nonnegative totals -/
noncomputable section
open scoped BigOperators ENNReal
open MeasureTheory
namespace NeuralGeneralization.BatchTwoOnline
variable {Ω : Type*} [MeasurableSpace Ω]

lemma nonnegative_partial_monotone (g : ℕ → Ω → ℝ) (hg : ∀ n ω, 0 ≤ g n ω) (ω : Ω) :
    Monotone (fun n => ∑ i∈Finset.range n, g i ω) := by
  intro n k hnk
  exact Finset.sum_le_sum_of_subset_of_nonneg (Finset.range_mono hnk) (fun i _ _ => hg i ω)

lemma infinite_total_eq_iSup (g : ℕ → Ω → ℝ) (hg : ∀ n ω, 0 ≤ g n ω) (ω : Ω) :
    (∑' n, ENNReal.ofReal (g n ω)) = ⨆ n, ENNReal.ofReal (∑ i∈Finset.range n,g i ω) := by
  rw [ENNReal.tsum_eq_iSup_nat]
  congr 1
  funext n
  exact (ENNReal.ofReal_sum_of_nonneg (fun i _ => hg i ω)).symm

/-- Tonelli turns a bound at every finite horizon into the same infinite
expected-total bound; no finite stopping-time hypothesis is used. -/
theorem infinite_expectation_le_of_prefix
    (μ : Measure Ω) (g : ℕ → Ω → ℝ) (hg : ∀ n ω, 0 ≤ g n ω)
    (hmeas : ∀ n, Measurable (g n)) (B : ℝ≥0∞)
    (hB : ∀ n, (∫⁻ ω, ENNReal.ofReal (∑ i∈Finset.range n,g i ω) ∂μ) ≤ B) :
    (∫⁻ ω, ∑' n,ENNReal.ofReal (g n ω) ∂μ) ≤ B := by
  rw [lintegral_tsum (fun n => (hmeas n).ennreal_ofReal.aemeasurable), ENNReal.tsum_eq_iSup_nat]
  apply iSup_le
  intro n
  rw [← lintegral_finset_sum (Finset.range n) (fun i _ => (hmeas i).ennreal_ofReal)]
  simpa only [← ENNReal.ofReal_sum_of_nonneg (fun i _ => hg i _)] using hB n

/-- Continuity from below preserves an exact strict upper-tail bound when
passing from every finite prefix to the entire nonnegative series. -/
theorem infinite_tail_le_of_prefix
    (μ : Measure Ω) (g : ℕ → Ω → ℝ) (hg : ∀ n ω, 0 ≤ g n ω)
    (U : ℝ) (hU : 0 ≤ U) (δ : ℝ≥0∞)
    (hδ : ∀ n, μ {ω | U < ∑ i∈Finset.range n,g i ω} ≤ δ) :
    μ {ω | ENNReal.ofReal U < ∑' n,ENNReal.ofReal (g n ω)} ≤ δ := by
  have he : {ω | ENNReal.ofReal U < ∑' n,ENNReal.ofReal (g n ω)} =
      ⋃ n, {ω | U < ∑ i∈Finset.range n,g i ω} := by
    ext ω
    simp only [Set.mem_setOf_eq, Set.mem_iUnion, infinite_total_eq_iSup g hg ω,
      lt_iSup_iff, ENNReal.ofReal_lt_ofReal_iff_of_nonneg hU]
  have hm : Monotone (fun n => {ω | U < ∑ i∈Finset.range n,g i ω}) := by
    intro n k hnk ω hω
    exact hω.trans_le (nonnegative_partial_monotone g hg ω hnk)
  rw [he, hm.measure_iUnion]
  exact iSup_le hδ

end NeuralGeneralization.BatchTwoOnline
