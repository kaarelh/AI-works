import NeuralGeneralization.ValidStateMeasurability
import NeuralGeneralization.RobustTargetAllWidths

/-! The original target cylinder is stable under all disturbances, and so
also under disturbances confined to the activation box. Its mass is unchanged. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.ValidState
open ConcreteModel
variable {d C N r : ℕ}

theorem target_mass (hd : 0 < d) (B : LayeredBooleanCircuit d C r) (hCN : C ≤ N)
    {c σ : ℝ} (hc : 0 < c) (hσ : 0 < σ) (hscale : (N:ℝ)*σ^2 ≤ 1) :
    Real.exp (-digitalMassPolynomial d C r c/σ^2) ≤
      (smallPrior d N r σ).real (support Real.tanh c ∩ marginEvent Real.tanh (1/2) B.computes) := by
  apply (robust_boolean_target_mass hd B hCN hc hσ hscale).trans
  exact measureReal_mono (fun w hw => ⟨original_support_subset Real.tanh c hw.1,hw.2⟩)

end NeuralGeneralization.ValidState
