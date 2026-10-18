import NeuralGeneralization.RobustCouplingFiniteGrid

/-!
# Explicit raw-path interface for the large-width compressor

The interface records an actual probability law on original weights, compact
weights, and a virtual hidden path. It does not postulate score approximation.
The deterministic disturbance identity and robustness implication are proved
in `RobustCouplingFiniteGrid` and used below to derive score approximation.
-/
noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped ENNReal
namespace NeuralGeneralization.ConcreteModel
open RobustCompressionInduction

abbrev RawPathState (d N m r : ℕ) :=
  Weights d N r × (Weights d m r × HiddenPath N r)

structure RawPathCoupling {d N m r : ℕ}
    (Q : Measure (Weights d N r)) (Γ : Measure (Weights d m r)) where
  joint : Measure (RawPathState d N m r)
  probability : IsProbabilityMeasure joint
  original : joint.map Prod.fst = Q
  compact : joint.map (fun p => p.2.1) = Γ

attribute [instance] RawPathCoupling.probability

/-- An arbitrary actual history coupling is encoded in the canonical raw-path
space without discarding its virtual path or changing either weight marginal. -/
def RawPathCoupling.ofFields {Ω : Type*} [MeasurableSpace Ω] {d N m r : ℕ}
    (Q : Measure (Weights d N r)) (Γ : Measure (Weights d m r))
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (original : Ω → Weights d N r) (compact : Ω → Weights d m r)
    (path : Ω → HiddenPath N r) (ho : Measurable original)
    (hc : Measurable compact) (hp : Measurable path)
    (hleft : μ.map original = Q) (hright : μ.map compact = Γ) :
    RawPathCoupling Q Γ where
  joint := μ.map (fun ω => (original ω, compact ω, path ω))
  probability := Measure.isProbabilityMeasure_map (ho.prodMk (hc.prodMk hp)).aemeasurable
  original := by
    rw [Measure.map_map measurable_fst (ho.prodMk (hc.prodMk hp))]
    exact hleft
  compact := by
    have hm : Measurable (fun p : RawPathState d N m r => p.2.1) :=
      measurable_fst.comp measurable_snd
    rw [Measure.map_map hm (ho.prodMk (hc.prodMk hp))]
    exact hright

/-- Quantitative raw compression, with a common compact-network marginal for
all inputs. The only error assumption is on the explicit additive noise cost. -/
structure RawPathCompression {d N m r : ℕ} (φ : ℝ → ℝ)
    (Q : Measure (Weights d N r)) (Γ : Measure (Weights d m r))
    (B radius failure : ℝ) : Prop where
  bounded : ∀ᵐ v ∂Γ, boundedWeights B v
  comparison : ∀ x : Cube d, ∃ π : RawPathCoupling Q Γ,
    π.joint.real {p | (radius / 2)^2 <
      reconstructionPathCost φ p.1 p.2.1 x p.2.2} ≤ failure

def RawPathCoupling.rounded {d N m M r : ℕ}
    {Q : Measure (Weights d N r)} {Γ : Measure (Weights d m r)}
    (π : RawPathCoupling Q Γ) (hmM : m ≤ M) (B R : ℕ) :
    RobustStatistics.ProbabilityCoupling Q (Γ.map (padAndRoundCode hmM B R)) :=
  roundedFieldCoupling Q Γ π.joint Prod.fst (fun p => p.2.1)
    measurable_fst (measurable_fst.comp measurable_snd) π.original π.compact hmM B R

theorem RawPathCompression.finite_grid {d N m M r B R : ℕ}
    {Q : Measure (Weights d N r)} {Γ : Measure (Weights d m r)}
    (hmM : m ≤ M) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    {c radius failure : ℝ} (hr0 : 0 ≤ radius) (hr1 : radius ≤ 1 / 6)
    (hB : 0 < B) (hR : 0 < R) (hround : 1 / (R : ℝ) ≤ radius / 8)
    (hrob : ∀ᵐ w ∂Q, w ∈ robustEvent φ c)
    (hrad : ∀ᵐ w ∂Q, radius ≤ robustRadius c w)
    (hraw : RawPathCompression φ Q Γ B radius failure) :
    ∃ π : ∀ x : Cube d, RobustStatistics.ProbabilityCoupling Q
      (Γ.map (padAndRoundCode hmM B R)),
      ∀ x, (π x).joint.real
        (RobustStatistics.scoreFailure (fun w => networkOutput φ w x)
          (fun q => robustGridOutput d M r B R φ q x)) ≤ failure := by
  choose ρ hρ using hraw.comparison
  refine ⟨fun x => (ρ x).rounded hmM B R, ?_⟩
  intro x
  apply roundedFieldCoupling_score_failure_le Q Γ (ρ x).joint Prod.fst (fun p => p.2.1)
    measurable_fst (measurable_fst.comp measurable_snd) (ρ x).original (ρ x).compact
    hmM φ hφ x (fun p => p.2.2) hr0 hr1 hB hR hround
  · exact ae_of_ae_map (μ := (ρ x).joint) (f := Prod.fst)
      measurable_fst.aemeasurable (by rwa [(ρ x).original])
  · exact ae_of_ae_map (μ := (ρ x).joint) (f := Prod.fst)
      (p := fun w => radius ≤ robustRadius c w)
      measurable_fst.aemeasurable (by rwa [(ρ x).original])
  · have hm : Measurable (fun p : RawPathState d N m r => p.2.1) :=
      measurable_fst.comp measurable_snd
    exact ae_of_ae_map hm.aemeasurable (by rw [(ρ x).compact]; exact hraw.bounded)
  · exact hρ x


theorem measurable_reconstructionPathCost {d N m r : ℕ} (φ : ℝ → ℝ)
    (hφ : Continuous φ) (x : Cube d) :
    Measurable (fun p : RawPathState d N m r => reconstructionPathCost φ p.1 p.2.1 x p.2.2) := by
  have hφm : Measurable φ := hφ.measurable
  have hout : Measurable (fun p : RawPathState d N m r => networkOutput φ p.2.1 x) :=
    (continuous_networkOutput hφ x).measurable.comp (measurable_fst.comp measurable_snd)
  unfold reconstructionPathCost hiddenPathCost firstHidden hiddenStep
  fun_prop

theorem RawPathCoupling.ofFields_cost_event {Ω : Type*} [MeasurableSpace Ω] {d N m r : ℕ}
    (Q : Measure (Weights d N r)) (Γ : Measure (Weights d m r))
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (original : Ω → Weights d N r) (compact : Ω → Weights d m r)
    (path : Ω → HiddenPath N r) (ho : Measurable original)
    (hc : Measurable compact) (hp : Measurable path)
    (hleft : μ.map original = Q) (hright : μ.map compact = Γ)
    (φ : ℝ → ℝ) (hφ : Continuous φ) (x : Cube d) (threshold : ℝ) :
    (RawPathCoupling.ofFields Q Γ μ original compact path ho hc hp hleft hright).joint.real
      {p | threshold < reconstructionPathCost φ p.1 p.2.1 x p.2.2} =
      μ.real {ω | threshold < reconstructionPathCost φ (original ω) (compact ω) x (path ω)} := by
  exact map_measureReal_apply (ho.prodMk (hc.prodMk hp))
    (measurableSet_lt measurable_const (measurable_reconstructionPathCost φ hφ x))

end NeuralGeneralization.ConcreteModel
