import Mathlib.MeasureTheory.Measure.Prokhorov
import Mathlib.MeasureTheory.Measure.LevyProkhorovMetric
import Mathlib.MeasureTheory.Function.AEEqOfLIntegral

/-! Compactness and support tools for actual probability measures in the weak topology. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory Filter Set
open scoped Topology ENNReal
namespace NeuralGeneralization.WeakLimitTools
variable {E : Type*} [MeasurableSpace E] [MetricSpace E]
  [CompleteSpace E] [SecondCountableTopology E] [BorelSpace E]

/-- Weak limits put no mass on an open set whose probabilities vanish. -/
theorem open_null_of_tendsto {μ : ProbabilityMeasure E} {μs : ℕ → ProbabilityMeasure E}
    (hμ : Tendsto μs atTop (𝓝 μ)) {U : Set E} (hU : IsOpen U)
    (hzero : Tendsto (fun j => (μs j : Measure E).real U) atTop (𝓝 0)) :
    (μ : Measure E) U = 0 := by
  have hz : Tendsto (fun j => (μs j : Measure E) U) atTop (𝓝 0) := by
    have h := (ENNReal.continuous_ofReal.tendsto (0 : ℝ)).comp hzero
    simpa only [Function.comp_def, Measure.real, ENNReal.ofReal_toReal (measure_ne_top _ _),
      ENNReal.ofReal_zero] using h
  apply le_antisymm (b := (0 : ℝ≥0∞)) _ bot_le
  simpa only [hz.liminf_eq] using ProbabilityMeasure.le_liminf_measure_open_of_tendsto hμ hU

/-- Closed support is preserved under weak convergence. -/
theorem ae_closed_of_tendsto {μ : ProbabilityMeasure E} {μs : ℕ → ProbabilityMeasure E}
    (hμ : Tendsto μs atTop (𝓝 μ)) {C : Set E} (hC : IsClosed C)
    (hs : ∀ᶠ j in atTop, ∀ᵐ x ∂(μs j : Measure E), x ∈ C) :
    ∀ᵐ x ∂(μ : Measure E), x ∈ C := by
  apply ae_iff.mpr
  apply open_null_of_tendsto hμ hC.isOpen_compl
  apply tendsto_const_nhds.congr'
  filter_upwards [hs] with j hj
  have hz : (μs j : Measure E) Cᶜ = 0 := ae_iff.mp hj
  simp only [Measure.real, hz, ENNReal.toReal_zero]

/-- Concentration in a single compact set makes a sequence tight. The finitely
many initial measures are included, not discarded. -/
theorem tight_of_compact_concentration (μs : ℕ → ProbabilityMeasure E)
    {K : Set E} (hK : IsCompact K)
    (hzero : Tendsto (fun j => (μs j : Measure E) Kᶜ) atTop (𝓝 0)) :
    IsTightMeasureSet (Set.range fun j => (μs j : Measure E)) := by
  rw [isTightMeasureSet_iff_exists_isCompact_measure_compl_le]
  intro ε hε
  obtain ⟨J, hJ⟩ := eventually_atTop.mp (hzero.eventually (gt_mem_nhds hε))
  have hp (j : Fin J) : ∃ C : Set E, IsCompact C ∧ (μs j : Measure E) Cᶜ ≤ ε := by
    have ht : IsTightMeasureSet {(μs j : Measure E)} := isTightMeasureSet_singleton
    obtain ⟨C, hc, hm⟩ := isTightMeasureSet_iff_exists_isCompact_measure_compl_le.mp ht ε hε
    exact ⟨C,hc,hm _ (by simp)⟩
  choose C hC hm using hp
  refine ⟨K ∪ ⋃ j : Fin J, C j, hK.union (isCompact_iUnion hC), ?_⟩
  rintro _ ⟨j,rfl⟩
  by_cases hj : j < J
  · exact (measure_mono (compl_subset_compl.mpr (subset_union_of_subset_right
      (subset_iUnion C ⟨j,hj⟩) K))).trans (hm ⟨j,hj⟩)
  · exact (measure_mono (compl_subset_compl.mpr subset_union_left)).trans (hJ j (by omega)).le

/-- Every sequence concentrating in one compact set has a weakly convergent subsequence. -/
theorem exists_weak_subsequence (μs : ℕ → ProbabilityMeasure E)
    {K : Set E} (hK : IsCompact K)
    (hzero : Tendsto (fun j => (μs j : Measure E).real Kᶜ) atTop (𝓝 0)) :
    ∃ μ : ProbabilityMeasure E, ∃ u : ℕ → ℕ,
      StrictMono u ∧ Tendsto (μs ∘ u) atTop (𝓝 μ) := by
  have hz : Tendsto (fun j => (μs j : Measure E) Kᶜ) atTop (𝓝 0) := by
    have h := (ENNReal.continuous_ofReal.tendsto (0 : ℝ)).comp hzero
    simpa only [Function.comp_def, Measure.real, ENNReal.ofReal_toReal (measure_ne_top _ _),
      ENNReal.ofReal_zero] using h
  have ht := tight_of_compact_concentration μs hK hz
  have he : {((μ : ProbabilityMeasure E) : Measure E) | μ ∈ Set.range μs} =
      Set.range (fun j => (μs j : Measure E)) := by ext; simp
  have hc := isCompact_closure_of_isTightMeasureSet (S := Set.range μs) (he ▸ ht)
  obtain ⟨μ,_,u,hu,hlim⟩ := hc.tendsto_subseq (fun j => subset_closure (mem_range_self j))
  exact ⟨μ,u,hu,hlim⟩

end NeuralGeneralization.WeakLimitTools
