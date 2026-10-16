import NeuralGeneralization.GaussianAmplitudeObservation
import NeuralGeneralization.GaussianNoiseSplit

/-!
# Finite Gaussian amplitude under arbitrary global margin conditioning

This proves the finite Gaussian amplitude lemma directly for a genuine Gaussian
field. The conditioning event may depend on every field coordinate, while the
covariance floor is required only for the selected coordinates.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianAmplitude
open FiniteDifferential GaussianAngularFields GaussianAngularPrice GaussianFieldTilt

variable {X I J : Type*} [Fintype X] [Fintype I] [Fintype J] [DecidableEq I]

omit [Fintype I] [DecidableEq I] in
lemma fieldLaw_map_selection (A : X → J → ℝ) (s : I → X) :
    (fieldLaw A).map (fun z => z ∘ s) = fieldLaw (fun i => A (s i)) := by
  have hs : Measurable (fun z : X → ℝ => z ∘ s) := by fun_prop
  unfold fieldLaw
  rw [Measure.map_map hs (fieldLinear A).continuous.measurable]
  rfl

/-- A dominated submeasure of a finite Gaussian law inherits the amplitude
estimate from an actual independent-noise decomposition of its covariance. -/
theorem field_submeasure_small_output_count
    (A : I → J → ℝ) (a σ t : ℝ) (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (hfloor : Matrix.PosSemidef (fun i j => gram A i j-(if i=j then σ^2 else 0)))
    (ρ : Measure (I → ℝ)) [IsFiniteMeasure ρ]
    (hρ : ρ ≤ (fieldLaw A).restrict {z | ∀ i, a < |z i|})
    (hρpos : ρ Set.univ ≠ 0) :
    (∫ z, smallMeanCount ((a+σ*t)/2) z ∂cond ρ Set.univ) ≤
      Real.log (1/ρ.real Set.univ)/smallBall t +
      (4*σ^2/(a+σ*t)^2)*(2*(Fintype.card I : ℝ)+4*Real.log (1/ρ.real Set.univ)) := by
  obtain ⟨B,hB⟩ := exists_noise_representation A σ hfloor
  apply observed_small_output_count (standardLaw I) (fieldLinear B)
    (fieldLinear B).continuous.measurable a σ t hσ ht ha ρ _ hρpos
  change ρ ≤ (((standardLaw I).prod (standardLaw I)).map
    (fun x => fun i => fieldLinear B x.1 i+σ*x.2 i)).restrict _
  rwa [hB]

/-- Actual finite Gaussian amplitude under arbitrary positive-probability
conditioning that imposes the fixed margin on the selected coordinates. -/
theorem finite_gaussian_amplitude
    (A : X → J → ℝ) (s : I → X) (a σ t : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (hfloor : Matrix.PosSemidef (fun i j => gram (fun i => A (s i)) i j-
      (if i=j then σ^2 else 0)))
    (E : Set (X → ℝ)) (_hE : MeasurableSet E)
    (hEpos : fieldLaw A E ≠ 0)
    (hmargin : ∀ z ∈ E, ∀ i, a < |z (s i)|) :
    (∫ z, smallMeanCount ((a+σ*t)/2) (z ∘ s) ∂cond (fieldLaw A) E) ≤
      Real.log (1/(fieldLaw A).real E)/smallBall t +
      (4*σ^2/(a+σ*t)^2)*(2*(Fintype.card I : ℝ)+
        4*Real.log (1/(fieldLaw A).real E)) := by
  let μ := fieldLaw A
  let F : (X → ℝ) → (I → ℝ) := fun z => z ∘ s
  have hF : Measurable F := by unfold F; fun_prop
  let ρ := (μ.restrict E).map F
  have hmass : ρ Set.univ = μ E := by
    rw [Measure.map_apply hF MeasurableSet.univ, Set.preimage_univ,
      Measure.restrict_apply_univ]
  have hρpos : ρ Set.univ ≠ 0 := by rwa [hmass]
  have hmassReal : ρ.real Set.univ = μ.real E := congrArg ENNReal.toReal hmass
  let S : Set (I → ℝ) := {z | ∀ i, a < |z i|}
  have hS : MeasurableSet S := by
    have heq : S = ⋂ i, {z | a < |z i|} := by ext z; simp [S]
    rw [heq]
    exact MeasurableSet.iInter fun i => measurableSet_lt measurable_const (measurable_pi_apply i).abs
  have hsub : E ⊆ F ⁻¹' S := fun z hz => hmargin z hz
  have hρ : ρ ≤ (fieldLaw (fun i => A (s i))).restrict S := by
    have hm := Measure.map_mono (Measure.restrict_mono_set μ hsub) hF
    rw [← Measure.restrict_map hF hS] at hm
    change ρ ≤ ((fieldLaw A).map (fun z => z ∘ s)).restrict S at hm
    rwa [fieldLaw_map_selection] at hm
  have hcond : (cond μ E).map F = cond ρ Set.univ := by
    unfold ProbabilityTheory.cond
    rw [Measure.map_smul, Measure.restrict_univ, hmass]
  have hi : (∫ z, smallMeanCount ((a+σ*t)/2) (z ∘ s) ∂cond μ E) =
      ∫ z, smallMeanCount ((a+σ*t)/2) z ∂cond ρ Set.univ := by
    rw [← hcond]
    exact (integral_map hF.aemeasurable (measurable_smallMeanCount _).aestronglyMeasurable).symm
  rw [hi]
  have hh := field_submeasure_small_output_count (fun i => A (s i)) a σ t hσ ht ha
    hfloor ρ hρ hρpos
  simpa only [hmassReal] using hh

end NeuralGeneralization.GaussianAmplitude
