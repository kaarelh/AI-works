import NeuralGeneralization.SquaredSamplingLogBudget

/-! Transfer from compact feature laws to arbitrary measurable random
features whose norm bound holds only almost everywhere. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory Filter
open scoped BigOperators
namespace NeuralGeneralization.SquaredSampling
variable {Ω X E : Type*} [MeasurableSpace Ω] [MeasurableSpace X]
variable [NormedAddCommGroup E] [NormedSpace ℝ E]

lemma empiricalDeviation_congr_ae (μ : Measure Ω) [IsProbabilityMeasure μ]
    {F G : Ω → E} (h : F =ᵐ[μ] G) (n : ℕ) :
    empiricalDeviation μ n F =ᵐ[Measure.pi (fun _ : Fin n => μ)] empiricalDeviation μ n G := by
  have hs := Measure.ae_eq_pi (μ:=fun _ : Fin n => μ) (fun _ => h)
  filter_upwards [hs] with s hs
  unfold empiricalDeviation sampleSum
  rw [integral_congr_ae h]
  congr 3
  exact Finset.sum_congr rfl (fun i _ => congrFun hs i)

variable [TopologicalSpace X] [CompactSpace X] [T2Space X]
variable [BorelSpace X] [SecondCountableTopology X] [CompleteSpace E]

lemma empiricalDeviation_pullback (μ : Measure Ω) [IsProbabilityMeasure μ]
    (b : Ω → X) (hb : Measurable b) (F : X → E) (hF : Continuous F) (n : ℕ)
    (s : Fin n → Ω) :
    empiricalDeviation (μ.map b) n F (fun i => b (s i)) =
      empiricalDeviation μ n (fun x => F (b x)) s := by
  unfold empiricalDeviation sampleSum
  rw [integral_map hb.aemeasurable hF.aestronglyMeasurable]

lemma empiricalDeviation_integral_map (μ : Measure Ω) [IsProbabilityMeasure μ]
    (b : Ω → X) (hb : Measurable b) (F : X → E) (hF : Continuous F) (n : ℕ) :
    (∫ s,empiricalDeviation μ n (fun x => F (b x)) s ∂Measure.pi (fun _ : Fin n => μ)) =
      ∫ s,empiricalDeviation (μ.map b) n F s ∂Measure.pi (fun _ : Fin n => μ.map b) := by
  haveI : IsProbabilityMeasure (μ.map b) := Measure.isProbabilityMeasure_map hb.aemeasurable
  have hm : Measurable (fun s : Fin n → Ω => fun i => b (s i)) :=
    measurable_pi_iff.mpr (fun i => hb.comp (measurable_pi_apply i))
  have hi := integral_map (μ:=Measure.pi (fun _ : Fin n => μ)) hm.aemeasurable
    (continuous_empiricalDeviation (μ.map b) n hF).aestronglyMeasurable
  rw [Measure.pi_map_pi (fun _ : Fin n => hb.aemeasurable)] at hi
  simp_rw [empiricalDeviation_pullback μ b hb F hF n] at hi
  exact hi.symm

lemma empiricalDeviation_integrable_pullback (μ : Measure Ω) [IsProbabilityMeasure μ]
    (b : Ω → X) (hb : Measurable b) (F : X → E) (hF : Continuous F) (n : ℕ) :
    Integrable (empiricalDeviation μ n (fun x => F (b x))) (Measure.pi (fun _ : Fin n => μ)) := by
  haveI : IsProbabilityMeasure (μ.map b) := Measure.isProbabilityMeasure_map hb.aemeasurable
  have hm : MeasurePreserving (fun s : Fin n → Ω => fun i => b (s i))
      (Measure.pi (fun _ => μ)) (Measure.pi (fun _ => μ.map b)) :=
    measurePreserving_pi _ _ (fun _ => ⟨hb,rfl⟩)
  have hh := hm.integrable_comp_of_integrable
    (compact_integrable _ (continuous_empiricalDeviation (μ.map b) n hF))
  simpa only [Function.comp_def,empiricalDeviation_pullback μ b hb F hF n] using hh

abbrev BoundedFeature (D : ℕ) := Metric.closedBall (0 : ProcessVector D) (Real.sqrt (D:ℝ))
instance {D : ℕ} : CompactSpace (BoundedFeature D) :=
  isCompact_iff_compactSpace.mp (isCompact_closedBall _ _)

variable {D : ℕ}

def boundFeature (z : ProcessVector D) : BoundedFeature D :=
  if h : ‖z‖ ≤ Real.sqrt (D:ℝ) then ⟨z,by simpa using h⟩
  else ⟨0,by simp [Real.sqrt_nonneg]⟩

lemma measurable_boundFeature : Measurable (boundFeature (D:=D)) := by
  apply Measurable.subtype_mk
  change Measurable (fun z : ProcessVector D => (boundFeature z).val)
  have he : (fun z : ProcessVector D => (boundFeature z).val) =
      fun z => if ‖z‖ ≤ Real.sqrt (D:ℝ) then z else 0 := by
    funext z
    unfold boundFeature
    split_ifs <;> rfl
  rw [he]
  exact Measurable.ite (isClosed_le continuous_norm continuous_const).measurableSet
    measurable_id measurable_const

lemma boundFeature_eq_ae (μ : Measure Ω) (a : Ω → ProcessVector D)
    (hrow : ∀ᵐ x ∂μ,‖a x‖^2 ≤ D) :
    (fun x => (boundFeature (a x)).val) =ᵐ[μ] a := by
  filter_upwards [hrow] with x hx
  have hnorm : ‖a x‖ ≤ Real.sqrt (D:ℝ) :=
    (Real.le_sqrt (norm_nonneg _) (Nat.cast_nonneg D)).mpr hx
  simp [boundFeature,hnorm]

lemma boundedFeature_sq_le (z : BoundedFeature D) : ‖z.val‖^2 ≤ D := by
  have hh : ‖z.val‖ ≤ Real.sqrt (D:ℝ) := by simpa only [Metric.mem_closedBall,dist_zero_right] using z.property
  exact (Real.le_sqrt (norm_nonneg _) (Nat.cast_nonneg D)).mp hh

end NeuralGeneralization.SquaredSampling
