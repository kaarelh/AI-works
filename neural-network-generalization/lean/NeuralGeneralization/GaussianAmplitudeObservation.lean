import NeuralGeneralization.GaussianAmplitudeDominated
import NeuralGeneralization.GaussianConditionalSubspace

/-!
# Transporting amplitude estimates through observed Gaussian laws

This step handles conditioning on coordinates outside the chosen observation:
the observed restricted measure is lifted by its Radon–Nikodym derivative,
without asserting independence of the extra conditioning event.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.GaussianAmplitude

/-- An arbitrary submeasure of the noisy observation law, supported on the
margin event, satisfies the same actual conditional amplitude estimate. -/
theorem observed_small_output_count
    {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι]
    (μ : Measure Ω) [IsProbabilityMeasure μ] (H : Ω → ι → ℝ)
    (hH : Measurable H) (a σ t : ℝ)
    (hσ : 0 < σ) (ht : 0 ≤ t) (ha : σ/2 ≤ a)
    (ρ : Measure (ι → ℝ)) [IsFiniteMeasure ρ]
    (hρ : ρ ≤ ((μ.prod (Measure.pi fun _i : ι => gaussianReal 0 1)).map
      (fun x => fun i => H x.1 i+σ*x.2 i)).restrict {z | ∀ i, a < |z i|})
    (hρpos : ρ Set.univ ≠ 0) :
    (∫ z, smallMeanCount ((a+σ*t)/2) z ∂cond ρ Set.univ) ≤
      Real.log (1/ρ.real Set.univ)/smallBall t +
      (4*σ^2/(a+σ*t)^2)*(2*(Fintype.card ι : ℝ)+4*Real.log (1/ρ.real Set.univ)) := by
  let ν := Measure.pi fun _i : ι => gaussianReal 0 1
  let F : Ω × (ι → ℝ) → (ι → ℝ) := fun x i => H x.1 i+σ*x.2 i
  have hF : Measurable F := by
    apply measurable_pi_lambda
    intro i
    exact ((measurable_pi_apply i).comp (hH.comp measurable_fst)).add
      (measurable_const.mul ((measurable_pi_apply i).comp measurable_snd))
  let S : Set (ι → ℝ) := {z | ∀ i, a < |z i|}
  have hS : MeasurableSet S := by
    have heq : S = ⋂ i, {z | a < |z i|} := by ext z; simp [S]
    rw [heq]
    exact MeasurableSet.iInter fun i => measurableSet_lt measurable_const (measurable_pi_apply i).abs
  obtain ⟨κ,hκ,hmap⟩ := exists_dominated_measure_lift_restrict (μ.prod ν) F hF S hS ρ hρ
  have hκbase : κ ≤ μ.prod ν := hκ.trans Measure.restrict_le_self
  letI : IsFiniteMeasure κ := isFiniteMeasure_of_le _ hκbase
  have hmass : κ Set.univ = ρ Set.univ := by
    rw [← hmap, Measure.map_apply hF MeasurableSet.univ, Set.preimage_univ]
  have hκpos : κ Set.univ ≠ 0 := by rwa [hmass]
  have hmassReal : κ.real Set.univ = ρ.real Set.univ := congrArg ENNReal.toReal hmass
  have hmapcond : (cond κ Set.univ).map F = cond ρ Set.univ := by
    have hh := GaussianConditionalSubspace.map_cond_preimage κ F hF Set.univ MeasurableSet.univ
    simpa only [Set.preimage_univ, hmap] using hh
  have hi : (∫ z, smallMeanCount ((a+σ*t)/2) z ∂cond ρ Set.univ) =
      ∫ x, smallMeanCount ((a+σ*t)/2) (F x) ∂cond κ Set.univ := by
    rw [← hmapcond]
    exact integral_map hF.aemeasurable (measurable_smallMeanCount _).aestronglyMeasurable
  rw [hi]
  have hh := normalized_small_output_count μ H hH a σ t hσ ht ha κ hκ hκpos
  simpa only [hmassReal] using hh

end NeuralGeneralization.GaussianAmplitude
