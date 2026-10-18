import NeuralGeneralization.RobustCouplingSmallWidth
import NeuralGeneralization.RobustCompressionAllocations

/-! # Explicit polynomial resources instantiated in the small-width compressor

This combines the actual Gaussian KL-to-grid coupling with the independently
proved natural-number resource formulas. The candidate law is one pushforward
of the original network law and is common to all Boolean inputs.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel
namespace RobustCompressionInput

theorem small_width_grid_coupling (p : RobustCompressionInput)
    {N : ℕ} (hd : 0 < p.dimension) (hN : 0 < N) (hNM : N ≤ p.widthBound)
    (hA : 0 < p.inverseFailure) (hR : 0 < p.inverseRadius)
    {σ t α : ℝ} (ht : 0 < t) (ht1 : t ^ 2 ≤ 1) (hscale : t ^ 2 = N * σ ^ 2)
    (hα : (p.inverseFailure : ℝ)⁻¹ ≤ α)
    (Q : Measure (Weights p.dimension N (p.depth - 2))) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior p.dimension N (p.depth - 2) σ) ≤
      ENNReal.ofReal (N * (p.energy : ℝ) / t ^ 2))
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) :
    (smallWidthGridCoupling Q hNM p.weightBound p.inverseOutputError).joint.real
      (gridOutputFailure p.dimension N p.widthBound (p.depth - 2)
        p.weightBound p.inverseOutputError φ) ≤ α := by
  apply smallWidthGridCoupling_of_kl hd hN hNM (Nat.cast_nonneg _) ht ht1 hscale
    Q hKL φ hφ p.weightBound_pos
  · dsimp [inverseOutputError]
    positivity
  · exact small_width_energy_allocation p hA hα

theorem small_width_grid_score_coupling (p : RobustCompressionInput)
    {N : ℕ} (hd : 0 < p.dimension) (hN : 0 < N) (hNM : N ≤ p.widthBound)
    (hA : 0 < p.inverseFailure) (hR : 2 ≤ p.inverseRadius)
    {σ t α : ℝ} (ht : 0 < t) (ht1 : t ^ 2 ≤ 1) (hscale : t ^ 2 = N * σ ^ 2)
    (hα : (p.inverseFailure : ℝ)⁻¹ ≤ α)
    (Q : Measure (Weights p.dimension N (p.depth - 2))) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (smallPrior p.dimension N (p.depth - 2) σ) ≤
      ENNReal.ofReal (N * (p.energy : ℝ) / t ^ 2))
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (x : Cube p.dimension) :
    (smallWidthGridCoupling Q hNM p.weightBound p.inverseOutputError).joint.real
      (RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
        (fun q => robustGridOutput p.dimension p.widthBound (p.depth - 2)
          p.weightBound p.inverseOutputError φ q x)) ≤ α := by
  apply smallWidthGridCoupling_score_failure_le Q hNM φ x
  · have hden : (12 : ℝ) ≤ p.inverseOutputError := by
      have h : 12 ≤ p.inverseOutputError := by dsimp [inverseOutputError]; omega
      exact_mod_cast h
    exact one_div_le_one_div_of_le (by norm_num) hden
  · exact small_width_grid_coupling p hd hN hNM hA (by omega) ht ht1 hscale hα Q hKL φ hφ

end RobustCompressionInput
end NeuralGeneralization.ConcreteModel
