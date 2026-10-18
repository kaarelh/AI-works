import NeuralGeneralization.RobustCompressionTerminalSampling

/-! # Exact physical scaling of the preserved original terminal readout -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.RobustCompressionInduction
open ConcreteModel RobustCompressionBlockMoments RobustCompressionReadout
open RobustCompressionSampling

variable {d N m s r : ℕ}

theorem coordinateScale_readout (i : Fin N) :
    coordinateScale d N r (Sum.inr (Sum.inr i)) = 1 / Real.sqrt (N : ℝ) := by
  simp [coordinateScale, smallVariance]

/-- Preserving standardized readout coordinates preserves the actual physical
coefficients t z/N, including their exact original network normalization. -/
theorem terminalCoefficients_actual {σ : ℝ} (hσ : 0 < σ) (hN : 0 < N)
    (w : Weights d N r) (z : FutureWeights N 0)
    (hz : ∀ i, z (Sum.inr i) = standardizedWeights σ w (Sum.inr (Sum.inr i))) :
    terminalCoefficients (σ * Real.sqrt (N : ℝ)) z = physicalReadout w := by
  funext i
  unfold terminalCoefficients physicalReadout
  rw [hz]
  unfold standardizedWeights whiten
  rw [coordinateScale_readout]
  have hs : (Real.sqrt (N : ℝ))^2 = N := Real.sq_sqrt (Nat.cast_nonneg N)
  have hs0 : Real.sqrt (N : ℝ) ≠ 0 := (Real.sqrt_pos.mpr (Nat.cast_pos.mpr hN)).ne'
  field_simp
  rw [hs]
  ring

theorem terminalEnergy_actual {σ : ℝ} (hσ : 0 < σ) (hN : 0 < N)
    (w : Weights d N r) (z : FutureWeights N 0)
    (hz : ∀ i, z (Sum.inr i) = standardizedWeights σ w (Sum.inr (Sum.inr i))) :
    terminalEnergy (σ * Real.sqrt (N : ℝ)) z = readoutEnergy w := by
  unfold terminalEnergy
  rw [terminalCoefficients_actual hσ hN w z hz]
  exact physicalReadout_energy hN w

theorem terminalOriginalOutput_actual {σ : ℝ} (hσ : 0 < σ) (hN : 0 < N)
    (φ : ℝ → ℝ) (w : Weights d N r) (p : TerminalState d N m s)
    (hz : ∀ i, p.2 (Sum.inr i) = standardizedWeights σ w (Sum.inr (Sum.inr i)))
    (x : Cube d) :
    terminalOriginalOutput φ (σ * Real.sqrt (N : ℝ)) p x =
      ∑ i, w (Sum.inr (Sum.inr i)) * activeHidden φ p.1 x i := by
  unfold terminalOriginalOutput
  rw [terminalCoefficients_actual hσ hN w p.2 hz]
  exact physicalReadout_value hN w (activeHidden φ p.1) x

end NeuralGeneralization.RobustCompressionInduction
