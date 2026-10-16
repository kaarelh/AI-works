import Mathlib.MeasureTheory.Measure.Decomposition.RadonNikodym

/-!
# Lifting a dominated observation law through a measurable representation

A submeasure of an observed law lifts to a submeasure of any representation of
that law. This retains conditioning on information outside the observation
without claiming that the outside information is independent of representation
noise.
-/
noncomputable section
open MeasureTheory
open scoped ENNReal
namespace NeuralGeneralization

/-- A finite submeasure of a measurable pushforward has a dominated lift. -/
theorem exists_dominated_measure_lift
    {Ω X : Type*} [MeasurableSpace Ω] [MeasurableSpace X]
    (μ : Measure Ω) [IsFiniteMeasure μ] (F : Ω → X) (hF : Measurable F)
    (ρ : Measure X) [IsFiniteMeasure ρ] (hρ : ρ ≤ μ.map F) :
    ∃ κ : Measure Ω, κ ≤ μ ∧ κ.map F = ρ := by
  let w := ρ.rnDeriv (μ.map F)
  let κ := μ.withDensity (fun x => w (F x))
  have hw : Measurable w := ρ.measurable_rnDeriv (μ.map F)
  have hle : κ ≤ μ := by
    have hwle := Measure.rnDeriv_le_one_of_le hρ
    have hp : (fun x => w (F x)) ≤ᵐ[μ] (1 : Ω → ℝ≥0∞) :=
      ae_of_ae_map hF.aemeasurable hwle
    have hh := withDensity_mono hp
    simpa only [withDensity_one] using hh
  refine ⟨κ, hle, ?_⟩
  have hmap : κ.map F = (μ.map F).withDensity w := by
    ext s hs
    rw [Measure.map_apply hF hs, withDensity_apply _ (hs.preimage hF),
      withDensity_apply _ hs, setLIntegral_map hs hw hF]
  rw [hmap]
  exact Measure.withDensity_rnDeriv_eq ρ (μ.map F) (Measure.absolutelyContinuous_of_le hρ)


/-- The lift can preserve a measurable support restriction. -/
theorem exists_dominated_measure_lift_restrict
    {Ω X : Type*} [MeasurableSpace Ω] [MeasurableSpace X]
    (μ : Measure Ω) [IsFiniteMeasure μ] (F : Ω → X) (hF : Measurable F)
    (S : Set X) (hS : MeasurableSet S)
    (ρ : Measure X) [IsFiniteMeasure ρ] (hρ : ρ ≤ (μ.map F).restrict S) :
    ∃ κ : Measure Ω, κ ≤ μ.restrict (F ⁻¹' S) ∧ κ.map F = ρ := by
  have hm : (μ.restrict (F ⁻¹' S)).map F = (μ.map F).restrict S :=
    (Measure.restrict_map hF hS).symm
  apply exists_dominated_measure_lift (μ.restrict (F ⁻¹' S)) F hF ρ
  rwa [hm]

end NeuralGeneralization
