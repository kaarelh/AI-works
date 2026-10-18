import NeuralGeneralization.RobustEntropyResidualKernel

/-! # Compressing an active observation preserves the residual entropy budget

The residual coordinate is retained exactly.  The reference law is the actual
first marginal times a fixed reference residual law, so data processing applies
without any replacement of the first marginal or any invertibility assumption.
-/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustEntropy

variable {A U V Y : Type*} [MeasurableSpace A] [MeasurableSpace U]
  [MeasurableSpace V] [MeasurableSpace Y]

theorem fst_map_active (P : Measure (U × Y)) {f : U → V}
    (hf : Measurable f) :
    (P.map (Prod.map f id)).fst = P.fst.map f := by
  rw [Measure.fst, Measure.map_map measurable_fst (hf.prodMap measurable_id),
    Measure.fst, Measure.map_map hf measurable_fst]
  rfl

theorem snd_map_active (P : Measure (U × Y)) {f : U → V}
    (hf : Measurable f) :
    (P.map (Prod.map f id)).snd = P.snd := by
  rw [Measure.snd, Measure.map_map measurable_snd (hf.prodMap measurable_id)]
  rfl

/-- Keeping the residual but compressing its active side-information cannot
increase its conditional relative entropy. -/
theorem klDiv_active_map_le
    [StandardBorelSpace U] [StandardBorelSpace V] [StandardBorelSpace Y]
    [Nonempty U] [Nonempty Y]
    (P : Measure (U × Y)) [IsFiniteMeasure P]
    (G : Measure Y) [IsFiniteMeasure G] {f : U → V} (hf : Measurable f) :
    klDiv (P.map (Prod.map f id))
      ((P.map (Prod.map f id)).fst.prod G) ≤ klDiv P (P.fst.prod G) := by
  have href : (P.fst.prod G).map (Prod.map f id) = (P.fst.map f).prod G := by
    rw [← Measure.map_prod_map P.fst G hf measurable_id, Measure.map_id]
  rw [fst_map_active P hf, ← href]
  exact klDiv_map_le P (P.fst.prod G) (hf.prodMap measurable_id)

/-- A parameter-dependent map of only the active coordinate. -/
def activeMapKernel (κ : Kernel A (U × Y)) (f : A × U → V) :
    Kernel A (V × Y) :=
  parameterMap κ (fun p => (f (p.1,p.2.1),p.2.2))

instance activeMapKernel_finite (κ : Kernel A (U × Y)) [IsFiniteKernel κ]
    (f : A × U → V) : IsFiniteKernel (activeMapKernel κ f) := by
  unfold activeMapKernel
  infer_instance

theorem measurable_activeMap {f : A × U → V} (hf : Measurable f) :
    Measurable (fun p : A × (U × Y) => (f (p.1,p.2.1),p.2.2)) :=
  (hf.comp (measurable_fst.prodMk (measurable_fst.comp measurable_snd))).prodMk
    (measurable_snd.comp measurable_snd)

theorem activeMapKernel_markov (κ : Kernel A (U × Y)) [IsMarkovKernel κ]
    (f : A × U → V) (hf : Measurable f) :
    IsMarkovKernel (activeMapKernel κ f) := by
  unfold activeMapKernel parameterMap
  exact Kernel.IsMarkovKernel.map _ (measurable_activeMap hf)

theorem activeMapKernel_apply (κ : Kernel A (U × Y)) [IsMarkovKernel κ]
    (f : A × U → V) (hf : Measurable f) (a : A) :
    activeMapKernel κ f a = (κ a).map (Prod.map (fun u => f (a,u)) id) :=
  parameterMap_apply κ (measurable_activeMap hf) a

theorem activeMapKernel_fst (κ : Kernel A (U × Y)) [IsMarkovKernel κ]
    (f : A × U → V) (hf : Measurable f) :
    (activeMapKernel κ f).fst = parameterMap κ.fst f := by
  ext a : 1
  rw [Kernel.fst_apply, activeMapKernel_apply κ f hf,
    parameterMap_apply κ.fst hf a]
  exact fst_map_active (κ a) (hf.comp measurable_prodMk_left)

theorem activeMapKernel_snd (κ : Kernel A (U × Y)) [IsMarkovKernel κ]
    (f : A × U → V) (hf : Measurable f) :
    (activeMapKernel κ f).snd = κ.snd := by
  ext a : 1
  rw [Kernel.snd_apply, activeMapKernel_apply κ f hf, Kernel.snd_apply]
  exact snd_map_active (κ a) (hf.comp measurable_prodMk_left)

theorem activeMapKernel_cost
    [StandardBorelSpace U] [StandardBorelSpace V] [StandardBorelSpace Y]
    [Nonempty U] [Nonempty Y]
    (κ : Kernel A (U × Y)) [IsMarkovKernel κ]
    (f : A × U → V) (hf : Measurable f)
    (G : Measure Y) [IsProbabilityMeasure G] (a : A) :
    klDiv (activeMapKernel κ f a) (((activeMapKernel κ f).fst a).prod G) ≤
      klDiv (κ a) ((κ.fst a).prod G) := by
  rw [Kernel.fst_apply, activeMapKernel_apply κ f hf]
  exact klDiv_active_map_le (κ a) G (hf.comp measurable_prodMk_left)

theorem activeMapKernel_averaged_cost
    [StandardBorelSpace U] [StandardBorelSpace V] [StandardBorelSpace Y]
    [Nonempty U] [Nonempty Y]
    (μ : Measure A) (κ : Kernel A (U × Y)) [IsMarkovKernel κ]
    (f : A × U → V) (hf : Measurable f)
    (G : Measure Y) [IsProbabilityMeasure G] :
    (∫⁻ a, klDiv (activeMapKernel κ f a)
      (((activeMapKernel κ f).fst a).prod G) ∂μ) ≤
      ∫⁻ a, klDiv (κ a) ((κ.fst a).prod G) ∂μ := by
  exact lintegral_mono (activeMapKernel_cost κ f hf G)

/-- The actual disintegration of the compressed law inherits the original
joint residual-entropy budget, averaged over the external parameter. -/
theorem activeMapKernel_averaged_conditional_cost
    [StandardBorelSpace U] [StandardBorelSpace V] [StandardBorelSpace Y]
    [Nonempty U] [Nonempty Y]
    (μ : Measure A) [IsProbabilityMeasure μ]
    (κ : Kernel A (U × Y)) [IsMarkovKernel κ]
    (f : A × U → V) (hf : Measurable f)
    (G : Measure Y) [IsProbabilityMeasure G] :
    (∫⁻ p, klDiv ((activeMapKernel κ f).condKernel p) G
      ∂μ ⊗ₘ (activeMapKernel κ f).fst) ≤
      ∫⁻ a, klDiv (κ a) ((κ.fst a).prod G) ∂μ := by
  letI := activeMapKernel_markov κ f hf
  rw [averaged_conditional_residual_entropy_eq]
  exact activeMapKernel_averaged_cost μ κ f hf G

end NeuralGeneralization.RobustEntropy
