import NeuralGeneralization.BatchTwoManuscriptGrid
import NeuralGeneralization.BatchTwoManuscriptLargeWidth
import NeuralGeneralization.BatchTwoManuscriptSmallWidth
import NeuralGeneralization.BatchTwoImprovedNoisyAllWidths

/-! Actual pre-stability compression into the literal J grid, at every width. -/
noncomputable section
set_option autoImplicit false
set_option maxHeartbeats 1000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped ENNReal
namespace NeuralGeneralization.BatchTwoManuscriptResources
open ConcreteModel RobustCompressionInduction

theorem raw_noisy_grid (p : Input) {N m : ℕ}
    {Q : Measure (Weights p.dimension N (p.depth-2))}
    {Γ : Measure (Weights p.dimension m (p.depth-2))} [IsProbabilityMeasure Γ]
    (hmM : m≤widthBound p) {φ : ℝ→ℝ} (hφ : admissibleActivation φ)
    (hraw : RawPathCompression φ Q Γ (weightBound p) (p.radius/2) p.failure) :
    ∀x : Cube p.dimension,∃π : NoisyGridCoupling Q (Γ.map (padRoundCode p hmM)),
      π.joint.real (noisyGridFailure φ (gridOutput p φ) x (p.radius/2) (p.radius/16))≤p.failure := by
  intro x
  obtain ⟨ρ, _, hcost⟩ := hraw.validComparison x
  let q := fun z : RawPathState p.dimension N m (p.depth-2) => padRoundCode p hmM z.2.1
  let η := fun z : RawPathState p.dimension N m (p.depth-2) =>
    pathDisturbance φ z.1 x z.2.2 (networkOutput φ z.2.1 x)
  have hq : Measurable q := (measurable_padRoundCode p hmM).comp
    (measurable_fst.comp measurable_snd)
  have hη : Measurable η := measurable_rawPathDisturbance (admissibleActivation_continuous hφ) x
  have hright : ρ.joint.map q = Γ.map (padRoundCode p hmM) := by
    have hm : Measurable (fun z : RawPathState p.dimension N m (p.depth-2) => z.2.1) := measurable_fst.comp measurable_snd
    exact (Measure.map_map (measurable_padRoundCode p hmM) hm).symm.trans
      (congrArg (Measure.map (padRoundCode p hmM)) ρ.compact)
  let π := NoisyGridCoupling.ofFields Q _ ρ.joint Prod.fst q η measurable_fst hq hη ρ.original hright
  refine ⟨π, ?_⟩
  have hb : ∀ᵐ z ∂ρ.joint, boundedWeights (weightBound p) z.2.1 :=
    ae_of_ae_map (f := fun z : RawPathState p.dimension N m (p.depth-2) => z.2.1)
      (measurable_fst.comp measurable_snd).aemeasurable
      (by rw [ρ.compact]; exact hraw.bounded)
  have hset := measurable_noisyGridFailure (N := N) (r := p.depth-2) φ (admissibleActivation_continuous hφ)
    (gridOutput p φ) (fun _ => measurable_of_countable _) x (p.radius/2) (p.radius/16)
  change (ρ.joint.map (fun z => (z.1, q z, η z))).real _ ≤ p.failure
  rw [Measure.real, Measure.map_apply (measurable_fst.prodMk (hq.prodMk hη)) hset]
  apply (ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono_ae ?_)).trans hcost
  filter_upwards [hb] with z hz
  intro hbad
  change ((p.radius/2)/2)^2 < reconstructionPathCost φ z.1 z.2.1 x z.2.2
  by_contra h
  have hle := le_of_not_gt h
  have he : noiseBudgetSq (η z) = reconstructionPathCost φ z.1 z.2.1 x z.2.2 :=
    pathDisturbance_budget_eq_hiddenPathCost φ z.1 x z.2.2 _
  have hout : |gridOutput p φ (q z) x - noisyNetworkOutput φ z.1 x (η z)| ≤
      p.radius/16 := by
    dsimp only [η, q]
    rw [pathDisturbance_output, abs_sub_comm]
    exact padRoundCode_output_close p hmM hφ _ hz x
  rcases hbad with hn | ho
  · rw [he] at hn
    nlinarith [sq_pos_of_pos p.radius_pos]
  · exact not_lt_of_ge hout ho

theorem small_noisy_grid (p : Input) {N : ℕ}
    (Q : Measure (Weights p.dimension N (p.depth-2))) [IsProbabilityMeasure Q]
    (hNM : N≤widthBound p) {φ : ℝ→ℝ} (hφ : admissibleActivation φ)
    (htail : Q.real {w | ¬boundedWeights (weightBound p) w}≤p.failure) :
    ∀x : Cube p.dimension,∃π : NoisyGridCoupling Q (Q.map (padRoundCode p hNM)),
      π.joint.real (noisyGridFailure φ (gridOutput p φ) x (p.radius/2) (p.radius/16))≤p.failure := by
  intro x
  let q := padRoundCode p hNM
  have hq : Measurable q := measurable_padRoundCode p hNM
  let π := NoisyGridCoupling.ofFields Q (Q.map q) Q id q (fun _ => 0)
    measurable_id hq measurable_const Measure.map_id rfl
  refine ⟨π, ?_⟩
  have hset := measurable_noisyGridFailure (N := N) (r := p.depth-2) φ
    (admissibleActivation_continuous hφ) (gridOutput p φ)
    (fun _ => measurable_of_countable _) x (p.radius/2) (p.radius/16)
  change (Q.map (fun w => (w, q w, (0 : NetworkDisturbance N (p.depth-2))))).real _ ≤ p.failure
  have hm : Measurable (fun w : Weights p.dimension N (p.depth-2) => (w, q w, (0 : NetworkDisturbance N (p.depth-2)))) :=
    measurable_id.prodMk (hq.prodMk measurable_const)
  rw [Measure.real, Measure.map_apply hm hset]
  refine (ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono ?_)).trans htail
  intro w hbad hb
  change (p.radius/2)^2 ≤ noiseBudgetSq (0 : NetworkDisturbance N (p.depth-2)) ∨
    p.radius/16 < |gridOutput p φ (q w) x - noisyNetworkOutput φ w x 0| at hbad
  rw [noiseBudgetSq_zero, noisyNetworkOutput_zero] at hbad
  rcases hbad with hn | ho
  · exact not_le_of_gt (sq_pos_of_pos (by have := p.radius_pos; positivity : 0<p.radius/2)) hn
  · have hh := padRoundCode_output_close p hNM hφ w hb x
    rw [abs_sub_comm] at hh
    exact not_lt_of_ge hh ho

end NeuralGeneralization.BatchTwoManuscriptResources
