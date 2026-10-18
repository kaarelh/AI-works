import NeuralGeneralization.RobustCouplingPathBudget

/-!
# Success-indicator path costs and abort bookkeeping

An aborted virtual path is not charged to the small reconstruction error.
Only the cost multiplied by the current success indicator propagates through
an exact history marginal. Abort probability is added separately at the end.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel
open RobustCompressionInduction

/-- Path-cost recursion on the live branch; arbitrary costs after abort do not
enter this inequality. -/
theorem successIndicator_cost_step_le {U V : Type*}
    (previous : V → U) (oldGood : Set U) (newGood : Set V)
    (oldCost : U → ℝ) (newCost localCost : V → ℝ)
    (hold0 : ∀ u, 0 ≤ oldCost u)
    (hgood : newGood ⊆ previous ⁻¹' oldGood)
    (hcost : ∀ v ∈ newGood, newCost v = oldCost (previous v) + localCost v)
    (v : V) :
    newGood.indicator newCost v ≤
      oldGood.indicator oldCost (previous v) + newGood.indicator localCost v := by
  by_cases hv : v ∈ newGood
  · have hvold : previous v ∈ oldGood := hgood hv
    rw [indicator_of_mem hv, indicator_of_mem hvold, indicator_of_mem hv, hcost v hv]
  · rw [indicator_of_notMem hv, indicator_of_notMem hv, add_zero]
    exact indicator_nonneg (fun u _ => hold0 u) _

/-- The preceding history need only have the correct marginal. No independence
of its path, its network, or the next sampled layer is assumed. -/
theorem integral_successIndicator_cost_step_le {U V : Type*}
    [MeasurableSpace U] [MeasurableSpace V]
    (ν : Measure U) (μ : Measure V)
    (previous : V → U) (hp : Measurable previous) (hmarginal : μ.map previous = ν)
    (oldGood : Set U) (newGood : Set V)
    (hOld : MeasurableSet oldGood) (hNew : MeasurableSet newGood)
    (oldCost : U → ℝ) (newCost localCost : V → ℝ)
    (hOldCost : Measurable oldCost) (hNewCost : Measurable newCost)
    (hold0 : ∀ u, 0 ≤ oldCost u) (hnew0 : ∀ v, 0 ≤ newCost v)
    (hgood : newGood ⊆ previous ⁻¹' oldGood)
    (hcost : ∀ v ∈ newGood, newCost v = oldCost (previous v) + localCost v)
    (hiOld : Integrable (oldGood.indicator oldCost) ν)
    (hiLocal : Integrable (newGood.indicator localCost) μ) :
    Integrable (newGood.indicator newCost) μ ∧
      (∫ v, newGood.indicator newCost v ∂μ) ≤
        (∫ u, oldGood.indicator oldCost u ∂ν) +
          ∫ v, newGood.indicator localCost v ∂μ := by
  have hpres : MeasurePreserving previous μ ν := ⟨hp, hmarginal⟩
  have hiOld' := hpres.integrable_comp_of_integrable hiOld
  have hpoint := successIndicator_cost_step_le previous oldGood newGood oldCost newCost
    localCost hold0 hgood hcost
  have hi : Integrable (newGood.indicator newCost) μ := by
    apply (hiOld'.add hiLocal).mono' (hNewCost.indicator hNew).aestronglyMeasurable
    exact Filter.Eventually.of_forall fun v => by
      rw [Real.norm_eq_abs, abs_of_nonneg (indicator_nonneg (fun v _ => hnew0 v) v)]
      exact hpoint v
  refine ⟨hi, ?_⟩
  have h := integral_mono hi (hiOld'.add hiLocal) hpoint
  change (∫ v, newGood.indicator newCost v ∂μ) ≤
    ∫ v, (oldGood.indicator oldCost ∘ previous) v + newGood.indicator localCost v ∂μ at h
  rw [integral_add hiOld' hiLocal] at h
  simp only [Function.comp_def] at h
  have heq : (∫ v, oldGood.indicator oldCost (previous v) ∂μ) =
      ∫ u, oldGood.indicator oldCost u ∂ν := by
    rw [← hmarginal, integral_map hp.aemeasurable (hOldCost.indicator hOld).aestronglyMeasurable]
  simpa only [Pi.add_apply, heq] using h

variable {Ω : Type*} [MeasurableSpace Ω]

/-- Markov's inequality is applied only to the nonnegative live-path cost.
Failed paths are covered by the explicit abort event. -/
theorem reconstructionPathCost_tail_le_stopped {d N m r : ℕ}
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (original : Ω → Weights d N r) (compact : Ω → Weights d m r)
    (path : Ω → HiddenPath N r) (φ : ℝ → ℝ) (x : Cube d)
    (good : Set Ω) {radius E abort readout : ℝ} (hr : 0 < radius)
    (hi : Integrable (good.indicator
      (fun ω => hiddenPathCost φ (original ω) x (path ω))) μ)
    (hm : (∫ ω, good.indicator
      (fun ω => hiddenPathCost φ (original ω) x (path ω)) ω ∂μ) ≤ E)
    (habort : μ.real goodᶜ ≤ abort)
    (hreadout : μ.real (good ∩ {ω | radius / 8 < |networkOutput φ (compact ω) x -
      ∑ i, original ω (Sum.inr (Sum.inr i)) * path ω (Fin.last r) i|}) ≤ readout) :
    μ.real {ω | (radius / 2)^2 <
      reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ≤
        abort + 8 * E / radius^2 + readout := by
  let masked : Ω → ℝ := good.indicator (fun ω => hiddenPathCost φ (original ω) x (path ω))
  let discrepancy : Ω → ℝ := fun ω => networkOutput φ (compact ω) x -
    ∑ i, original ω (Sum.inr (Sum.inr i)) * path ω (Fin.last r) i
  have hsub : {ω | (radius / 2)^2 <
      reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ⊆
      goodᶜ ∪ ({ω | radius^2 / 8 ≤ masked ω} ∪
        (good ∩ {ω | radius / 8 < |discrepancy ω|})) := by
    intro ω hω
    by_cases hg : ω ∈ good
    · apply Or.inr
      by_cases hh : radius^2 / 8 ≤ masked ω
      · exact Or.inl hh
      · apply Or.inr
        refine ⟨hg, ?_⟩
        by_contra hd
        have hhidden : hiddenPathCost φ (original ω) x (path ω) ≤ radius^2 / 8 := by
          have hlt := lt_of_not_ge hh
          simpa only [masked, indicator_of_mem hg] using hlt.le
        have hclose := reconstructionPathCost_le_of_local φ (original ω) (compact ω)
          x (path ω) hr.le hhidden (le_of_not_gt hd)
        exact (not_lt_of_ge hclose) hω
    · exact Or.inl hg
  have hmarkov := mul_meas_ge_le_integral_of_nonneg
    (μ := μ) (Filter.Eventually.of_forall (fun ω =>
      indicator_nonneg (fun a _ => hiddenPathCost_nonneg φ (original a) x (path a)) ω)) hi (radius^2 / 8)
  have htail : μ.real {ω | radius^2 / 8 ≤ masked ω} ≤ 8 * E / radius^2 := by
    apply (le_div_iff₀ (sq_pos_of_pos hr)).mpr
    nlinarith
  have hunion := (measureReal_union_le goodᶜ _ (μ := μ)).trans
    (add_le_add habort ((measureReal_union_le _ _).trans (add_le_add htail hreadout)))
  exact (measureReal_mono hsub).trans (hunion.trans_eq (by ring))

end NeuralGeneralization.ConcreteModel
