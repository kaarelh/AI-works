import NeuralGeneralization.CompressionSampling
import NeuralGeneralization.CompressionConclusion

/-!
# Norm compression for the actual finite neural network

This theorem constructs the row truncation and the finite independent sampling
law, proves the three event bounds, chooses an actual sample, and rescales its
readout. It assumes no compression or Gaussian concentration conclusion.
-/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.CompressionSampling
open ConcreteModel

/-- Actual norm-bounded networks have bounded-width, bounded-coefficient
    representatives of the same strict global-margin Boolean function. -/
theorem norm_compression {d N r K : ℕ} (hd : 1 ≤ d) (hN : 0 < N) (hK : 1 ≤ K)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) (f : BooleanFunction d)
    (w : Weights d N r) (hw : weightedSquaredNorm w ≤ (K : ℝ))
    (hmargin : w ∈ marginEvent φ (1 / 2) f) :
    ∃ v : Weights d (compressionWidth d r K) r,
      v ∈ marginEvent φ (1 / 2) f ∧
      boundedWeights (compressionWidth d r K) v ∧ weightedSquaredNorm v ≤ 9 * (K : ℝ) := by
  letI : NeZero N := ⟨Nat.ne_of_gt hN⟩
  let M := compressionWidth d r K
  let ρ : ℝ := (compressionQ r K : ℝ)⁻¹
  let q : ℝ := Real.sqrt (N : ℝ)
  have hM : 0 < M := compressionWidth_pos d r K hK
  have hNR : 0 < (N : ℝ) := by exact_mod_cast hN
  have hKR : 1 ≤ (K : ℝ) := by exact_mod_cast hK
  have hKp : 0 < (K : ℝ) := by linarith
  have hρ : 0 < ρ := inv_pos.mpr (by exact_mod_cast compressionQ_pos r K hK)
  have hq : 0 < q := Real.sqrt_pos.2 hNR
  have hqsq : q ^ 2 = (N : ℝ) := Real.sq_sqrt hNR.le
  let u := prunedWeights ρ q w
  have hu : weightedSquaredNorm u ≤ (K : ℝ) := (prunedWeights_cost_le ρ q w).trans hw
  obtain ⟨I,hcost,hmass,hrows,hread⟩ := exists_good_sampling_lists (M := M) hM φ hφ.1
    hρ hq hqsq hKp w u hw hu
    (prunedWeights_internal_bound hρ.le hq.le w)
    (prunedWeights_output_bound hρ.le hq.le w)
    (compressionWidth_row_bound d r K hK)
  exact compression_from_good_lists hd hN hK φ hφ f w hw hmargin I hcost hmass hrows hread

end NeuralGeneralization.CompressionSampling
