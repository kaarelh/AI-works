import NeuralGeneralization.RobustCouplingSmallWidth
import NeuralGeneralization.RobustCompressionInductionPath

/-!
# From an actual noisy reconstruction to one finite-grid coupling

The latent comparison law may retain the entire original network and all
virtual hidden states. Its original and compact-network marginals are preserved
exactly when the compact network is padded and rounded. The compact marginal,
and hence the grid law, can be the same for every input even when the latent
comparison coupling depends on the input.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel
open RobustCompressionInduction

/-- The full disturbance includes the sampled readout discrepancy. Thus the
unrounded compact output is exactly the noisy original output. -/
def reconstructionPathCost {d N m r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (v : Weights d m r) (x : Cube d)
    (h : HiddenPath N r) : ℝ :=
  hiddenPathCost φ w x h +
    (networkOutput φ v x - ∑ i, w (Sum.inr (Sum.inr i)) * h (Fin.last r) i)^2

theorem reconstructionPathCost_nonneg {d N m r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (v : Weights d m r) (x : Cube d) (h : HiddenPath N r) :
    0 ≤ reconstructionPathCost φ w v x h := by
  exact add_nonneg (hiddenPathCost_nonneg φ w x h) (sq_nonneg _)

theorem rounded_path_score_close {d N m M r B R : ℕ}
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (w : Weights d N r) (v : Weights d m r) (x : Cube d) (h : HiddenPath N r)
    {c radius : ℝ} (hw : w ∈ robustEvent φ c)
    (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1 / 6) (hr : radius ≤ robustRadius c w)
    (hB : 0 < B) (hR : 0 < R) (hv : boundedWeights B v)
    (hround : 1 / (R : ℝ) ≤ radius / 8)
    (hcost : reconstructionPathCost φ w v x h ≤ (radius / 2)^2) :
    |clippedScore (robustGridOutput d M r B R φ (padAndRoundCode hmM B R v) x) -
      clippedScore (networkOutput φ w x)| ≤ 1 / 12 := by
  let η := pathDisturbance φ w x h (networkOutput φ v x)
  have hnoise : noiseBudgetSq η ≤ (radius / 2)^2 := by
    rw [pathDisturbance_budget_eq_hiddenPathCost]
    exact hcost
  apply RobustStatistics.robust_score_close_of_noisy_compression φ c w x η _ radius
    hw hr0 hr1 hr hnoise
  rw [pathDisturbance_output]
  rw [abs_sub_comm]
  exact (padAndRoundCode_output_close hmM φ hφ hB hR v hv x).trans hround

variable {Ω : Type*} [MeasurableSpace Ω]

/-- Push the compact field of an actual latent comparison law into the finite
grid. Both prescribed marginals are exact; no independence is imposed. -/
def roundedFieldCoupling {d N m M r : ℕ}
    (Q : Measure (Weights d N r)) (Γ : Measure (Weights d m r))
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (original : Ω → Weights d N r) (compact : Ω → Weights d m r)
    (ho : Measurable original) (hc : Measurable compact)
    (hleft : μ.map original = Q) (hright : μ.map compact = Γ)
    (hmM : m ≤ M) (B R : ℕ) :
    RobustStatistics.ProbabilityCoupling Q
      (Γ.map (padAndRoundCode (d := d) (r := r) hmM B R)) where
  joint := μ.map (fun ω => (original ω, padAndRoundCode hmM B R (compact ω)))
  probability := Measure.isProbabilityMeasure_map
    (ho.prodMk ((measurable_padAndRoundCode hmM B R).comp hc)).aemeasurable
  left := by
    have hm : Measurable (fun ω => (original ω, padAndRoundCode hmM B R (compact ω))) :=
      ho.prodMk ((measurable_padAndRoundCode hmM B R).comp hc)
    rw [Measure.map_map measurable_fst hm]
    exact hleft
  right := by
    have hm : Measurable (fun ω => (original ω, padAndRoundCode hmM B R (compact ω))) :=
      ho.prodMk ((measurable_padAndRoundCode hmM B R).comp hc)
    rw [Measure.map_map measurable_snd hm, ← hright,
      Measure.map_map (measurable_padAndRoundCode hmM B R) hc]
    rfl

/-- The only remaining probability loss is the actual additive-disturbance
budget failure. The readout discrepancy is included in that budget; rounding
uses the separately allocated radius/8. -/
theorem roundedFieldCoupling_score_failure_le {d N m M r B R : ℕ}
    (Q : Measure (Weights d N r)) (Γ : Measure (Weights d m r))
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (original : Ω → Weights d N r) (compact : Ω → Weights d m r)
    (ho : Measurable original) (hc : Measurable compact)
    (hleft : μ.map original = Q) (hright : μ.map compact = Γ)
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (x : Cube d) (path : Ω → HiddenPath N r)
    {c radius α : ℝ} (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1 / 6)
    (hB : 0 < B) (hR : 0 < R) (hround : 1 / (R : ℝ) ≤ radius / 8)
    (hrob : ∀ᵐ ω ∂μ, original ω ∈ robustEvent φ c)
    (hrad : ∀ᵐ ω ∂μ, radius ≤ robustRadius c (original ω))
    (hbound : ∀ᵐ ω ∂μ, boundedWeights B (compact ω))
    (hfail : μ.real {ω | (radius / 2)^2 <
      reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ≤ α) :
    (roundedFieldCoupling Q Γ μ original compact ho hc hleft hright hmM B R).joint.real
      (RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
        (fun q => robustGridOutput d M r B R φ q x)) ≤ α := by
  have hmap : Measurable (fun ω => (original ω, padAndRoundCode hmM B R (compact ω))) :=
    ho.prodMk ((measurable_padAndRoundCode hmM B R).comp hc)
  have hs := RobustStatistics.measurable_scoreFailure
    (fun w : Weights d N r => networkOutput φ w x)
    (fun q : RobustOutputCode d M r B R => robustGridOutput d M r B R φ q x)
    (continuous_networkOutput (admissibleActivation_continuous hφ) x).measurable
    (measurable_of_countable _)
  change (μ.map (fun ω => (original ω, padAndRoundCode hmM B R (compact ω)))).real _ ≤ α
  rw [measureReal_def, Measure.map_apply hmap hs]
  refine (ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono_ae ?_)).trans hfail
  filter_upwards [hrob, hrad, hbound] with ω hw hr hv
  intro hbad
  by_contra hcost
  have hclose := rounded_path_score_close hmM φ hφ (original ω) (compact ω) x
    (path ω) hw hr0 hr1 hr hB hR hv hround (le_of_not_gt hcost)
  exact (not_lt_of_ge hclose) hbad

end NeuralGeneralization.ConcreteModel
