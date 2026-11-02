import NeuralGeneralization.RobustOutputRescaling

/-! Raw interval certificates can be sharpened by clipping before testing
support membership. The interval may vary with the input. -/
noncomputable section
namespace NeuralGeneralization.RobustCertificates
open ConcreteModel

/-- Monotonicity alone gives the exact endpoint test used in the paper. -/
theorem monotone_interval_change (F : ℝ → ℝ) (hF : Monotone F)
    {z z' B : ℝ} (hz : |z'-z| ≤ B) :
    |F z'-F z| ≤ max (F (z+B)-F z) (F z-F (z-B)) := by
  have hh := abs_le.mp hz
  have hlo := hF (show z-B ≤ z' by linarith)
  have hhi := hF (show z' ≤ z+B by linarith)
  apply abs_le.mpr
  constructor
  · have hm := le_max_right (F (z+B)-F z) (F z-F (z-B))
    linarith
  · have hm := le_max_left (F (z+B)-F z) (F z-F (z-B))
    linarith

lemma clippedScore_monotone : Monotone clippedScore := by
  intro x y h
  unfold clippedScore
  exact max_le_max_left _ (min_le_min_left _ h)

/-- A raw-output interval implies global clipped support whenever its
clipped endpoint excursions obey the displayed tolerance. -/
theorem interval_support {d N r : ℕ} (w : Weights d N r) (c : ℝ) (B : Cube d → ℝ)
    (hraw : ∀ x η,noiseBudgetSq η ≤ (robustRadius c w)^2 →
      |noisyNetworkOutput Real.tanh w x η-networkOutput Real.tanh w x| ≤ B x)
    (hend : ∀ x,max
      (clippedScore (networkOutput Real.tanh w x+B x)-clippedScore (networkOutput Real.tanh w x))
      (clippedScore (networkOutput Real.tanh w x)-clippedScore (networkOutput Real.tanh w x-B x)) ≤ 1/16) :
    w ∈ robustEvent Real.tanh c := by
  intro x η hη
  exact (monotone_interval_change clippedScore clippedScore_monotone (hraw x η hη)).trans (hend x)

end NeuralGeneralization.RobustCertificates
