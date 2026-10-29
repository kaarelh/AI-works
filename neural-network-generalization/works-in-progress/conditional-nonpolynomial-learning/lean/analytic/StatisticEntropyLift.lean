import AnchorFiniteReplacement

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.RobustEntropy

variable {Ω Y : Type*} [MeasurableSpace Ω] [MeasurableSpace Y]
  [StandardBorelSpace Ω] [StandardBorelSpace Y] [Nonempty Ω] [Nonempty Y]

/-- Lift a controlled statistic to the reference probability space through
its genuine regular conditional distribution. -/
def statisticEntropyJoint (μ : Measure Ω) [IsFiniteMeasure μ] (F : Ω → Y) (Q : Measure Y) :
    Measure (Y × Ω) := Q ⊗ₘ (μ.map (anchorGraph F)).condKernel

def statisticEntropyLift (μ : Measure Ω) [IsFiniteMeasure μ] (F : Ω → Y) (Q : Measure Y) :
    Measure Ω := (statisticEntropyJoint μ F Q).snd

lemma statisticEntropyJoint_probability (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : Ω → Y) (Q : Measure Y) [IsProbabilityMeasure Q] :
    IsProbabilityMeasure (statisticEntropyJoint μ F Q) := by
  unfold statisticEntropyJoint
  infer_instance

lemma statisticEntropyLift_probability (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : Ω → Y) (Q : Measure Y) [IsProbabilityMeasure Q] :
    IsProbabilityMeasure (statisticEntropyLift μ F Q) := by
  letI := statisticEntropyJoint_probability μ F Q
  unfold statisticEntropyLift
  infer_instance

lemma statisticEntropyJoint_fst (μ : Measure Ω) [IsProbabilityMeasure μ]
    (F : Ω → Y) (Q : Measure Y) [IsProbabilityMeasure Q] : (statisticEntropyJoint μ F Q).fst=Q :=
  Measure.fst_compProd Q _

theorem statisticEntropyJoint_kl (μ : Measure Ω) [IsProbabilityMeasure μ]
    {F : Ω → Y} (hF : Measurable F) (Q : Measure Y) [IsProbabilityMeasure Q] :
    klDiv (statisticEntropyJoint μ F Q) (μ.map (anchorGraph F))=klDiv Q (μ.map F) := by
  letI : IsProbabilityMeasure (μ.map (anchorGraph F)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph hF).aemeasurable
  have hh := klDiv_compProd_left Q (μ.map (anchorGraph F)).fst (μ.map (anchorGraph F)).condKernel
  rw [Measure.disintegrate (μ.map (anchorGraph F)) (μ.map (anchorGraph F)).condKernel,anchorGraph_fst] at hh
  exact hh

theorem statisticEntropyJoint_graph (μ : Measure Ω) [IsProbabilityMeasure μ]
    {F : Ω → Y} (hF : Measurable F) (Q : Measure Y) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (μ.map F)≠∞) :
    ∀ᵐp ∂statisticEntropyJoint μ F Q,F p.2=p.1 := by
  have hfinite : klDiv (statisticEntropyJoint μ F Q) (μ.map (anchorGraph F))≠∞ := by
    rw [statisticEntropyJoint_kl μ hF Q]
    exact hKL
  letI := statisticEntropyJoint_probability μ F Q
  have hac := (klDiv_ne_top_iff.mp hfinite).1
  apply hac
  change ∀ᵐp ∂μ.map (anchorGraph F),F p.2=p.1
  rw [ae_map_iff (measurable_anchorGraph hF).aemeasurable]
  · exact Filter.Eventually.of_forall fun x => rfl
  · exact measurableSet_eq_fun (hF.comp measurable_snd) measurable_fst

/-- The lifted law has exactly the prescribed controlled statistic. -/
theorem statisticEntropyLift_map (μ : Measure Ω) [IsProbabilityMeasure μ]
    {F : Ω → Y} (hF : Measurable F) (Q : Measure Y) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (μ.map F)≠∞) : (statisticEntropyLift μ F Q).map F=Q := by
  unfold statisticEntropyLift Measure.snd
  rw [Measure.map_map hF measurable_snd]
  have heq : F ∘ Prod.snd=ᵐ[statisticEntropyJoint μ F Q] Prod.fst :=
    statisticEntropyJoint_graph μ hF Q hKL
  rw [Measure.map_congr heq]
  exact statisticEntropyJoint_fst μ F Q

/-- Lifting changes neither the actual controlled statistic nor its exact
relative entropy, including non-injective and singular Gaussian statistics. -/
theorem statisticEntropyLift_kl (μ : Measure Ω) [IsProbabilityMeasure μ]
    {F : Ω → Y} (hF : Measurable F) (Q : Measure Y) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (μ.map F)≠∞) : klDiv (statisticEntropyLift μ F Q) μ=klDiv Q (μ.map F) := by
  letI := statisticEntropyJoint_probability μ F Q
  letI := statisticEntropyLift_probability μ F Q
  letI : IsProbabilityMeasure (μ.map (anchorGraph F)) :=
    Measure.isProbabilityMeasure_map (measurable_anchorGraph hF).aemeasurable
  apply le_antisymm
  · have hh := klDiv_map_le (statisticEntropyJoint μ F Q) (μ.map (anchorGraph F)) measurable_snd
    change klDiv (statisticEntropyLift μ F Q) (μ.map (anchorGraph F)).snd≤_ at hh
    rw [anchorGraph_snd μ hF,statisticEntropyJoint_kl μ hF Q] at hh
    exact hh
  · have hh := klDiv_map_le (statisticEntropyLift μ F Q) μ hF
    rw [statisticEntropyLift_map μ hF Q hKL] at hh
    exact hh

#print axioms statisticEntropyLift_map
#print axioms statisticEntropyLift_kl
end ConditionalNonpolynomial.Analytic
