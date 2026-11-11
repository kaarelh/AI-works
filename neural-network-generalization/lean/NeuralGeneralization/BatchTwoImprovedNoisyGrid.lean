import NeuralGeneralization.BatchTwoImprovedLargeWidthActivation
import NeuralGeneralization.RobustModelContinuity

/-! Finite-grid couplings with actual additive disturbances. No stability
assumption is used: the original and finite-code marginals are exact. -/
noncomputable section
set_option maxHeartbeats 600000
set_option backward.isDefEq.respectTransparency false
set_option maxRecDepth 4000
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel
open RobustCompressionInduction

abbrev NoisyGridState (d N r : ℕ) (Code : Type*) :=
  Weights d N r × (Code × NetworkDisturbance N r)

structure NoisyGridCoupling {d N r : ℕ} {Code : Type*} [MeasurableSpace Code]
    (Q : Measure (Weights d N r)) (Γ : Measure Code) where
  joint : Measure (NoisyGridState d N r Code)
  probability : IsProbabilityMeasure joint
  original : joint.map Prod.fst = Q
  code : joint.map (fun z => z.2.1) = Γ

attribute [instance] NoisyGridCoupling.probability

def NoisyGridCoupling.ofFields {Ω Code : Type*} [MeasurableSpace Ω] [MeasurableSpace Code]
    {d N r : ℕ} (Q : Measure (Weights d N r)) (Γ : Measure Code)
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (w : Ω → Weights d N r) (q : Ω → Code) (η : Ω → NetworkDisturbance N r)
    (hw : Measurable w) (hq : Measurable q) (hη : Measurable η)
    (hleft : μ.map w = Q) (hright : μ.map q = Γ) : NoisyGridCoupling Q Γ where
  joint := μ.map (fun z => (w z, q z, η z))
  probability := Measure.isProbabilityMeasure_map (hw.prodMk (hq.prodMk hη)).aemeasurable
  original := by rw [Measure.map_map measurable_fst (hw.prodMk (hq.prodMk hη))]; exact hleft
  code := by
    have hm : Measurable (fun z : NoisyGridState d N r Code => z.2.1) := measurable_fst.comp measurable_snd
    rw [Measure.map_map hm (hw.prodMk (hq.prodMk hη))]
    exact hright

def noisyGridFailure {d N r : ℕ} {Code : Type*}
    (φ : ℝ → ℝ) (output : Code → Cube d → ℝ) (x : Cube d) (radius error : ℝ) :
    Set (NoisyGridState d N r Code) :=
  {z | radius^2 ≤ noiseBudgetSq z.2.2 ∨
    error < |output z.2.1 x - noisyNetworkOutput φ z.1 x z.2.2|}

theorem measurable_noisyNetworkOutput_fields {Ω : Type*} [MeasurableSpace Ω]
    {d N r : ℕ} {φ : ℝ → ℝ} (hφ : Continuous φ) (x : Cube d)
    (w : Ω → Weights d N r) (η : Ω → NetworkDisturbance N r)
    (hw : Measurable w) (hη : Measurable η) :
    Measurable (fun z => noisyNetworkOutput φ (w z) x (η z)) := by
  have hφm := hφ.measurable
  have hf (i : Fin N) : Measurable (fun z => noisyFirstHidden φ (w z) x (η z) i) := by
    unfold noisyFirstHidden firstHidden
    fun_prop
  have hfold (ss : List (Fin r)) (H : Ω → Fin N → ℝ)
      (hH : ∀ i, Measurable (fun z => H z i)) (i : Fin N) :
      Measurable (fun z => ss.foldl (noisyHiddenStep φ (w z) (η z)) (H z) i) := by
    induction ss generalizing H with
    | nil => exact hH i
    | cons s ss ih =>
      apply ih
      intro j
      unfold noisyHiddenStep hiddenStep
      fun_prop
  have hfinal (i : Fin N) : Measurable (fun z => noisyFinalHidden φ (w z) x (η z) i) :=
    hfold _ _ hf i
  unfold noisyNetworkOutput
  fun_prop

theorem measurable_noisyGridFailure {d N r : ℕ} {Code : Type*} [MeasurableSpace Code]
    (φ : ℝ → ℝ) (hφ : Continuous φ) (output : Code → Cube d → ℝ)
    (ho : ∀ x, Measurable (fun q => output q x)) (x : Cube d) (radius error : ℝ) :
    MeasurableSet (noisyGridFailure (N := N) (r := r) φ output x radius error) := by
  have hn : Measurable (fun z : NoisyGridState d N r Code => noiseBudgetSq z.2.2) := by
    unfold noiseBudgetSq
    fun_prop
  have hz : Measurable (fun z : NoisyGridState d N r Code =>
      noisyNetworkOutput φ z.1 x z.2.2) :=
    measurable_noisyNetworkOutput_fields (Ω := NoisyGridState d N r Code)
      (d := d) (N := N) (r := r) hφ x Prod.fst (fun z => z.2.2)
      measurable_fst (measurable_snd.comp measurable_snd)
  change MeasurableSet ({z : NoisyGridState d N r Code | radius^2 ≤ noiseBudgetSq z.2.2} ∪
    {z | error < |output z.2.1 x - noisyNetworkOutput φ z.1 x z.2.2|})
  exact (measurableSet_le measurable_const hn).union
    (measurableSet_lt measurable_const (((ho x).comp
      (measurable_fst.comp measurable_snd)).sub hz).abs)

theorem measurable_rawPathDisturbance {d N m r : ℕ} {φ : ℝ → ℝ}
    (hφ : Continuous φ) (x : Cube d) :
    Measurable (fun z : RawPathState d N m r =>
      pathDisturbance φ z.1 x z.2.2 (networkOutput φ z.2.1 x)) := by
  have hout := (continuous_networkOutput hφ x).measurable.comp
    (measurable_fst.comp measurable_snd : Measurable (fun z : RawPathState d N m r => z.2.1))
  have hφm := hφ.measurable
  unfold pathDisturbance firstHidden hiddenStep
  apply Measurable.prodMk
  · apply measurable_pi_lambda
    intro s
    refine Fin.cases ?_ (fun s => ?_) s <;> simp only [Fin.cases_zero, Fin.cases_succ] <;> fun_prop
  · fun_prop

/-- Round an actual raw-path coupling, retaining its disturbance as a random
variable. The strict radius has a factor-two slack over the raw RMS bound. -/
theorem RawPathCompression.noisy_grid {d N m M r B R : ℕ}
    {Q : Measure (Weights d N r)} {Γ : Measure (Weights d m r)}
    [IsProbabilityMeasure Γ] (hmM : m ≤ M)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    {radius failure : ℝ} (hrad : 0 < radius) (hB : 0 < B) (hR : 0 < R)
    (hraw : RawPathCompression φ Q Γ B radius failure) :
    ∀ x : Cube d, ∃ π : NoisyGridCoupling Q (Γ.map (padAndRoundCode hmM B R)),
      π.joint.real (noisyGridFailure φ (robustGridOutput d M r B R φ) x
        radius (1 / (R : ℝ))) ≤ failure := by
  intro x
  obtain ⟨ρ, _, hcost⟩ := hraw.validComparison x
  let q := fun z : RawPathState d N m r => padAndRoundCode hmM B R z.2.1
  let η := fun z : RawPathState d N m r =>
    pathDisturbance φ z.1 x z.2.2 (networkOutput φ z.2.1 x)
  have hq : Measurable q := (measurable_padAndRoundCode hmM B R).comp
    (measurable_fst.comp measurable_snd)
  have hη : Measurable η := measurable_rawPathDisturbance (admissibleActivation_continuous hφ) x
  have hright : ρ.joint.map q = Γ.map (padAndRoundCode hmM B R) := by
    have hm : Measurable (fun z : RawPathState d N m r => z.2.1) := measurable_fst.comp measurable_snd
    exact (Measure.map_map (measurable_padAndRoundCode hmM B R) hm).symm.trans
      (congrArg (Measure.map (padAndRoundCode hmM B R)) ρ.compact)
  let π := NoisyGridCoupling.ofFields Q _ ρ.joint Prod.fst q η measurable_fst hq hη ρ.original hright
  refine ⟨π, ?_⟩
  have hb : ∀ᵐ z ∂ρ.joint, boundedWeights B z.2.1 :=
    ae_of_ae_map (f := fun z : RawPathState d N m r => z.2.1)
      (measurable_fst.comp measurable_snd).aemeasurable
      (by rw [ρ.compact]; exact hraw.bounded)
  have hset := measurable_noisyGridFailure (N := N) (r := r) φ (admissibleActivation_continuous hφ)
    (robustGridOutput d M r B R φ) (fun _ => measurable_of_countable _) x radius (1/(R:ℝ))
  change (ρ.joint.map (fun z => (z.1, q z, η z))).real _ ≤ failure
  rw [Measure.real, Measure.map_apply (measurable_fst.prodMk (hq.prodMk hη)) hset]
  apply (ENNReal.toReal_mono (measure_ne_top _ _) (measure_mono_ae ?_)).trans hcost
  filter_upwards [hb] with z hz
  intro hbad
  change (radius/2)^2 < reconstructionPathCost φ z.1 z.2.1 x z.2.2
  by_contra h
  have hle := le_of_not_gt h
  have he : noiseBudgetSq (η z) = reconstructionPathCost φ z.1 z.2.1 x z.2.2 :=
    pathDisturbance_budget_eq_hiddenPathCost φ z.1 x z.2.2 _
  have hout : |robustGridOutput d M r B R φ (q z) x - noisyNetworkOutput φ z.1 x (η z)| ≤
      1/(R:ℝ) := by
    dsimp only [η, q]
    rw [pathDisturbance_output, abs_sub_comm]
    exact padAndRoundCode_output_close hmM φ hφ hB hR _ hz x
  rcases hbad with hn | ho
  · rw [he] at hn
    nlinarith [sq_pos_of_pos hrad]
  · exact not_lt_of_ge hout ho

end NeuralGeneralization.ConcreteModel
