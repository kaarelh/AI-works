import NeuralGeneralization.RobustEntropySelection
import NeuralGeneralization.RobustEntropyKernel
import Mathlib.Probability.Kernel.Composition.Prod

/-! # Finite entropy queries for genuine conditional laws

The entropy function is the KL divergence of actual measurable pushforwards.
Its measurability and its budget bound follow from kernel Radon--Nikodym
derivatives and data processing, rather than being assumptions on a cost oracle.
-/

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustEntropy

variable {A W V I : Type*} [MeasurableSpace A] [MeasurableSpace W]
  [MeasurableSpace V]

/-- Push a kernel through a map which also depends measurably on its parameter. -/
def parameterMap (κ : Kernel A W) (F : A × W → V) : Kernel A V :=
  (Kernel.id ×ₖ κ).map F

instance parameterMap_finite (κ : Kernel A W) [IsFiniteKernel κ]
    (F : A × W → V) : IsFiniteKernel (parameterMap κ F) := by
  unfold parameterMap
  infer_instance

theorem parameterMap_apply (κ : Kernel A W) [IsFiniteKernel κ]
    {F : A × W → V} (hF : Measurable F) (a : A) :
    parameterMap κ F a = (κ a).map (fun w => F (a,w)) := by
  rw [parameterMap, Kernel.map_apply _ hF, Kernel.prod_apply,
    Kernel.id_apply, Measure.dirac_prod, Measure.map_map hF measurable_prodMk_left]
  rfl

theorem measurable_projected_klDiv [MeasurableSpace.CountablyGenerated V]
    (κ η : Kernel A W) [IsFiniteKernel κ] [IsFiniteKernel η]
    {F : A × W → V} (hF : Measurable F) :
    Measurable (fun a => klDiv ((κ a).map (fun w => F (a,w)))
      ((η a).map (fun w => F (a,w)))) := by
  simpa only [parameterMap_apply _ hF] using
    measurable_kernel_klDiv (parameterMap κ F) (parameterMap η F)

/-- Genuine relative entropy of the evaluations exposed by a finite input set. -/
def queryEntropy (κ η : Kernel A W) (F : Finset I → A × W → V)
    (S : Finset I) (a : A) : ℝ :=
  (klDiv ((κ a).map (fun w => F S (a,w)))
    ((η a).map (fun w => F S (a,w)))).toReal

theorem measurable_queryEntropy [MeasurableSpace.CountablyGenerated V]
    (κ η : Kernel A W) [IsFiniteKernel κ] [IsFiniteKernel η]
    (F : Finset I → A × W → V) (hF : ∀ S, Measurable (F S)) (S : Finset I) :
    Measurable (queryEntropy κ η F S) :=
  (measurable_projected_klDiv κ η (hF S)).ennreal_toReal

theorem queryEntropy_le [StandardBorelSpace W] [StandardBorelSpace V] [Nonempty W]
    (κ η : Kernel A W) [IsFiniteKernel κ] [IsFiniteKernel η]
    (F : Finset I → A × W → V) (hF : ∀ S, Measurable (F S))
    (S : Finset I) (a : A) (hfin : klDiv (κ a) (η a) ≠ ∞) :
    queryEntropy κ η F S a ≤ (klDiv (κ a) (η a)).toReal := by
  exact ENNReal.toReal_mono hfin
    (klDiv_map_le (κ a) (η a) ((hF S).comp measurable_prodMk_left))

/-- One measurable finite query list, with rank budget derived from the
actual full conditional KL. Null parameter fibers of infinite KL need no claim. -/
theorem exists_measurable_entropy_queries
    [Fintype I] [DecidableEq I] [MeasurableSpace (Finset I)]
    [StandardBorelSpace W] [StandardBorelSpace V] [Nonempty W]
    (κ η : Kernel A W) [IsFiniteKernel κ] [IsFiniteKernel η]
    (F : Finset I → A × W → V) (hF : ∀ S, Measurable (F S))
    (δ : ℝ) (hδ : 0 ≤ δ) :
    ∃ J : A → Finset I, Measurable J ∧
      (∀ a, klDiv (κ a) (η a) ≠ ∞ →
        δ * (J a).card ≤ (klDiv (κ a) (η a)).toReal) ∧
      (∀ a i, queryEntropy κ η F (insert i (J a)) a -
        queryEntropy κ η F (J a) a ≤ δ) := by
  let E := queryEntropy κ η F
  refine ⟨RobustEntropySelection.selectedSet E δ,
    RobustEntropySelection.measurable_selectedSet E
      (measurable_queryEntropy κ η F hF) δ, ?_, ?_⟩
  · intro a ha
    exact RobustEntropySelection.selectedSet_card_budget E δ a _
      ENNReal.toReal_nonneg (fun S => queryEntropy_le κ η F hF S a ha)
  · exact fun a i => RobustEntropySelection.selectedSet_increment_le E δ hδ a i

/-- Exact entropy cost of exposing a coordinate with an independent reference
law. In Gaussian application the reference identity is proved by orthogonality. -/
theorem klDiv_product_chain [StandardBorelSpace V] [Nonempty V]
    (ρ : Measure (W × V)) [IsFiniteMeasure ρ]
    (ν : Measure W) [IsFiniteMeasure ν] (G : Measure V) [IsProbabilityMeasure G] :
    klDiv ρ (ν.prod G) = klDiv ρ.fst ν + klDiv ρ (ρ.fst.prod G) := by
  have h := klDiv_compProd_eq_add ρ.fst ν ρ.condKernel (Kernel.const W G)
  simpa only [Measure.disintegrate, Measure.compProd_const] using h

theorem conditional_cost_le_of_increment [StandardBorelSpace V] [Nonempty V]
    (ρ : Measure (W × V)) [IsFiniteMeasure ρ]
    (ν : Measure W) [IsFiniteMeasure ν] (G : Measure V) [IsProbabilityMeasure G]
    (hfin : klDiv ρ (ν.prod G) ≠ ∞) (δ : ℝ)
    (hinc : (klDiv ρ (ν.prod G)).toReal - (klDiv ρ.fst ν).toReal ≤ δ) :
    klDiv ρ (ρ.fst.prod G) ≤ ENNReal.ofReal δ := by
  have h := klDiv_product_chain ρ ν G
  have hfin' : klDiv ρ.fst ν + klDiv ρ (ρ.fst.prod G) ≠ ∞ := by rwa [← h]
  have hparts := ENNReal.add_ne_top.mp hfin'
  have hr := congrArg ENNReal.toReal h
  rw [ENNReal.toReal_add hparts.1 hparts.2] at hr
  have hc : (klDiv ρ (ρ.fst.prod G)).toReal ≤ δ := by linarith
  rw [← ENNReal.ofReal_toReal hparts.2]
  exact ENNReal.ofReal_le_ofReal hc

end NeuralGeneralization.RobustEntropy
