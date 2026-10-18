import Mathlib.InformationTheory.KullbackLeibler.ChainRule
import Mathlib.Probability.Kernel.Disintegration.StandardBorel
import Mathlib.MeasureTheory.Constructions.Polish.Basic
import Mathlib.Probability.Kernel.Composition.MeasureComp

/-!
# Entropy monotonicity for the robust compression construction

These lemmas concern the actual measure-theoretic KL divergence. No compression
or statistical conclusion is assumed. Conditional entropy is represented by the
KL of two joint measures with the same first marginal, as in mathlib's chain rule.
-/

open MeasureTheory ProbabilityTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustEntropy

variable {α β : Type*} [MeasurableSpace α] [MeasurableSpace β]

/-- KL is unchanged by an injective measurable encoding. -/
theorem klDiv_map_embedding_of_ac (μ ν : Measure α)
    [IsFiniteMeasure μ] [IsFiniteMeasure ν] {f : α → β}
    (hf : MeasurableEmbedding f) (hμν : μ ≪ ν) :
    InformationTheory.klDiv (μ.map f) (ν.map f) = InformationTheory.klDiv μ ν := by
  rw [InformationTheory.klDiv_eq_lintegral_klFun_of_ac
    (hf.absolutelyContinuous_map hμν),
    InformationTheory.klDiv_eq_lintegral_klFun_of_ac hμν,
    hf.lintegral_map]
  apply lintegral_congr_ae
  filter_upwards [hf.rnDeriv_map μ ν] with x hx
  rw [hx]

/-- Discarding the second coordinate cannot increase KL. -/
theorem klDiv_fst_le [StandardBorelSpace β] [Nonempty β]
    (ρ σ : Measure (α × β)) [IsFiniteMeasure ρ] [IsFiniteMeasure σ] :
    InformationTheory.klDiv ρ.fst σ.fst ≤ InformationTheory.klDiv ρ σ := by
  have h := InformationTheory.klDiv_compProd_eq_add
    ρ.fst σ.fst ρ.condKernel σ.condKernel
  rw [Measure.disintegrate ρ ρ.condKernel,
    Measure.disintegrate σ σ.condKernel] at h
  rw [h]
  exact le_add_right le_rfl

/-- Data processing for measurable functions between standard Borel spaces. -/
theorem klDiv_map_le [StandardBorelSpace α] [StandardBorelSpace β]
    [Nonempty α] (μ ν : Measure α) [IsFiniteMeasure μ] [IsFiniteMeasure ν]
    {f : α → β} (hf : Measurable f) :
    InformationTheory.klDiv (μ.map f) (ν.map f) ≤ InformationTheory.klDiv μ ν := by
  by_cases htop : InformationTheory.klDiv μ ν = ∞
  · simp [htop]
  have hac := (InformationTheory.klDiv_ne_top_iff.mp htop).1
  let g : α → β × α := fun x => (f x, x)
  have hg : MeasurableEmbedding g :=
    (hf.prodMk measurable_id).measurableEmbedding (by
      intro x y h
      exact congrArg Prod.snd h)
  have h := klDiv_fst_le (μ.map g) (ν.map g)
  rw [klDiv_map_embedding_of_ac μ ν hg hac] at h
  dsimp only [g] at h
  rw [Measure.fst_map_prodMk (X := f) (Y := fun x : α => x) measurable_id,
    Measure.fst_map_prodMk (X := f) (Y := fun x : α => x) measurable_id] at h
  exact h

/-- Applying the same random channel to two laws does not increase KL. -/
theorem klDiv_comp_le [StandardBorelSpace α] [StandardBorelSpace β]
    [Nonempty α] [Nonempty β]
    (μ ν : Measure α) [IsFiniteMeasure μ] [IsFiniteMeasure ν]
    (κ : Kernel α β) [IsMarkovKernel κ] :
    InformationTheory.klDiv (κ ∘ₘ μ) (κ ∘ₘ ν) ≤ InformationTheory.klDiv μ ν := by
  have h := klDiv_map_le (μ ⊗ₘ κ) (ν ⊗ₘ κ) measurable_snd
  change InformationTheory.klDiv (μ ⊗ₘ κ).snd (ν ⊗ₘ κ).snd ≤ _ at h
  simpa only [Measure.snd_compProd, InformationTheory.klDiv_compProd_left] using h

/-- The two exact nonnegative parts of a finite joint entropy are both bounded
by the joint entropy. This is the form needed for successive conditioning. -/
theorem conditional_klDiv_le (μ ν : Measure α)
    [IsFiniteMeasure μ] [IsFiniteMeasure ν]
    (κ η : Kernel α β) [IsMarkovKernel κ] [IsMarkovKernel η] :
    InformationTheory.klDiv (μ ⊗ₘ κ) (μ ⊗ₘ η) ≤
      InformationTheory.klDiv (μ ⊗ₘ κ) (ν ⊗ₘ η) := by
  rw [InformationTheory.klDiv_compProd_eq_add μ ν κ η]
  exact le_add_self

/-- One may first expose a block and then pass the remaining joint law through
an arbitrary shared Markov channel; no independence of the exposed prefix is
required. -/
theorem klDiv_channel_le_chain [StandardBorelSpace α] [StandardBorelSpace β]
    [Nonempty α] [Nonempty β]
    {γ : Type*} [MeasurableSpace γ] [StandardBorelSpace γ] [Nonempty γ]
    (μ ν : Measure α) [IsFiniteMeasure μ] [IsFiniteMeasure ν]
    (κ η : Kernel α β) [IsMarkovKernel κ] [IsMarkovKernel η]
    (χ : Kernel (α × β) γ) [IsMarkovKernel χ] :
    InformationTheory.klDiv (χ ∘ₘ (μ ⊗ₘ κ)) (χ ∘ₘ (ν ⊗ₘ η)) ≤
      InformationTheory.klDiv μ ν +
        InformationTheory.klDiv (μ ⊗ₘ κ) (μ ⊗ₘ η) := by
  rw [← InformationTheory.klDiv_compProd_eq_add]
  exact klDiv_comp_le _ _ χ

end NeuralGeneralization.RobustEntropy
