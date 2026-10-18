import NeuralGeneralization.RobustCouplingRawPath

/-! # Quantitative conversion of local hidden error and readout tails

The readout error consumes part of the same additive disturbance budget as the
hidden path. The threshold allocation here leaves explicit room for both.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel
open RobustCompressionInduction

variable {Ω : Type*} [MeasurableSpace Ω]

theorem reconstructionPathCost_tail_le {d N m r : ℕ}
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (original : Ω → Weights d N r) (compact : Ω → Weights d m r)
    (path : Ω → HiddenPath N r) (φ : ℝ → ℝ) (x : Cube d)
    {radius E β : ℝ} (hr : 0 < radius)
    (hi : Integrable (fun ω => hiddenPathCost φ (original ω) x (path ω)) μ)
    (hm : (∫ ω, hiddenPathCost φ (original ω) x (path ω) ∂μ) ≤ E)
    (hreadout : μ.real {ω | radius / 8 < |networkOutput φ (compact ω) x -
      ∑ i, original ω (Sum.inr (Sum.inr i)) * path ω (Fin.last r) i|} ≤ β) :
    μ.real {ω | (radius / 2)^2 <
      reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ≤
        8 * E / radius^2 + β := by
  let hidden : Ω → ℝ := fun ω => hiddenPathCost φ (original ω) x (path ω)
  let discrepancy : Ω → ℝ := fun ω => networkOutput φ (compact ω) x -
    ∑ i, original ω (Sum.inr (Sum.inr i)) * path ω (Fin.last r) i
  have hsub : {ω | (radius / 2)^2 <
      reconstructionPathCost φ (original ω) (compact ω) x (path ω)} ⊆
      {ω | radius^2 / 8 ≤ hidden ω} ∪ {ω | radius / 8 < |discrepancy ω|} := by
    intro ω hω
    by_contra hn
    have hh : hidden ω < radius^2 / 8 := lt_of_not_ge (fun h => hn (Or.inl h))
    have hd : |discrepancy ω| ≤ radius / 8 := le_of_not_gt (fun h => hn (Or.inr h))
    have hd2 : discrepancy ω ^ 2 ≤ (radius / 8)^2 := by
      exact (sq_le_sq).mpr (by simpa only [abs_of_nonneg (by positivity : 0 ≤ radius / 8)] using hd)
    change (radius / 2)^2 < hidden ω + discrepancy ω ^ 2 at hω
    nlinarith [sq_pos_of_pos hr]
  have hmarkov := mul_meas_ge_le_integral_of_nonneg
    (μ := μ) (Filter.Eventually.of_forall (fun ω =>
      hiddenPathCost_nonneg φ (original ω) x (path ω))) hi (radius^2 / 8)
  have htail : μ.real {ω | radius^2 / 8 ≤ hidden ω} ≤ 8 * E / radius^2 := by
    apply (le_div_iff₀ (sq_pos_of_pos hr)).mpr
    nlinarith
  exact (measureReal_mono hsub).trans
    ((measureReal_union_le _ _).trans (add_le_add htail hreadout))

/-- Explicit room remains after combining hidden Markov error and readout
sampling/clipping: 1/8 + 1/64 < 1/4 of the squared radius. -/
theorem reconstructionPathCost_le_of_local {d N m r : ℕ}
    (φ : ℝ → ℝ) (w : Weights d N r) (v : Weights d m r)
    (x : Cube d) (h : HiddenPath N r) {radius : ℝ} (hr : 0 ≤ radius)
    (hh : hiddenPathCost φ w x h ≤ radius^2 / 8)
    (hz : |networkOutput φ v x - ∑ i, w (Sum.inr (Sum.inr i)) * h (Fin.last r) i| ≤ radius / 8) :
    reconstructionPathCost φ w v x h ≤ (radius / 2)^2 := by
  have hz2 : (networkOutput φ v x - ∑ i, w (Sum.inr (Sum.inr i)) * h (Fin.last r) i)^2 ≤
      (radius / 8)^2 := by
    exact (sq_le_sq).mpr (by simpa only [abs_of_nonneg (by positivity : 0 ≤ radius / 8)] using hz)
  unfold reconstructionPathCost
  nlinarith [sq_nonneg radius]

end NeuralGeneralization.ConcreteModel
