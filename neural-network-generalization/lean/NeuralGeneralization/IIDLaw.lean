import Mathlib.MeasureTheory.Constructions.Pi

/-! # Actual finite products of a probability measure -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.CompressionSampling
variable {α : Type*} [MeasurableSpace α]

/-- Independent draws, one per sample position. -/
def iidSamples (ν : Measure α) (M : ℕ) : Measure (Fin M → α) :=
  Measure.pi (fun _ : Fin M => ν)

instance iidSamples_probability (ν : Measure α) [IsProbabilityMeasure ν] (M : ℕ) :
    IsProbabilityMeasure (iidSamples ν M) := by
  unfold iidSamples
  infer_instance


end NeuralGeneralization.CompressionSampling
