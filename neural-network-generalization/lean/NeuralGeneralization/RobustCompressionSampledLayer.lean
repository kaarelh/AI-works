import NeuralGeneralization.RobustCompressionLayerPair
import NeuralGeneralization.RobustCompressionSampling

/-! # Integrating the shared source bank inside the conditional comparison

The source indices are sampled after the actual active observation is exposed.
This keeps its original disintegration unchanged and gives exactly the same
input-independent candidate source/coefficient marginal for every test input.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory ENNReal
namespace NeuralGeneralization.RobustCompressionLayerComparison
open RobustCompression RobustCompressionLayerGaussian CompressionSampling

variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}
local notation "Z" => Fin N → ℝ
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ

def sampledLayerPairKernel [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) : Kernel A (Z × (S × R)) :=
  ((Kernel.const A (iidSamples (uniformIndexLaw N) m)) ⊗ₖ
    layerPairKernel (P.comap Prod.fst measurable_fst) p).map
      (fun z => (z.2.1,(z.1,z.2.2)))

instance sampledLayerPairKernel_markov [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) :
    IsMarkovKernel (sampledLayerPairKernel P p) := by
  unfold sampledLayerPairKernel
  exact Kernel.IsMarkovKernel.map _ (by fun_prop)

theorem sampledLayerPairKernel_fst [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) :
    (sampledLayerPairKernel P p).fst = P := by
  ext θ s hs
  rw [Kernel.fst_apply, Measure.map_apply measurable_fst hs,
    sampledLayerPairKernel, Kernel.map_apply _ (by fun_prop),
    Measure.map_apply (by fun_prop) (measurable_fst hs),
    Kernel.compProd_apply ((measurable_fst hs).preimage (by fun_prop))]
  have hf (I : S) :
      layerPairKernel (P.comap Prod.fst measurable_fst) p (θ,I)
        ((fun z : Z × R => z.1) ⁻¹' s) = P θ s := by
    have hh := congrArg (fun K : Kernel (A × S) Z => K (θ,I) s)
      (layerPairKernel_fst (P.comap Prod.fst measurable_fst) p)
    rw [Kernel.fst_apply,Measure.map_apply measurable_fst hs,Kernel.comap_apply] at hh
    exact hh
  change (∫⁻ I, layerPairKernel (P.comap Prod.fst measurable_fst) p (θ,I)
    ((fun z : Z × R => z.1) ⁻¹' s) ∂Kernel.const A (iidSamples (uniformIndexLaw N) m) θ) = _
  simp_rw [hf]
  simp

theorem sampledLayerPairKernel_snd [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) (hp : p.Contractive) :
    (sampledLayerPairKernel P p).snd =
      (Kernel.const A (iidSamples (uniformIndexLaw N) m)) ⊗ₖ
        residualRowsKernel p.sourceMatrix p.sourceMatrix_measurable := by
  rw [Kernel.snd_eq,sampledLayerPairKernel, ← Kernel.map_comp_right _ (by fun_prop) measurable_snd]
  have he : (Prod.snd ∘ (fun z : S × (Z × R) => (z.2.1,(z.1,z.2.2)))) =
      Prod.map id Prod.snd := rfl
  rw [he, ← kernel_compProd_map _ _ Prod.snd measurable_snd, ← Kernel.snd_eq,
    layerPairKernel_snd _ _ hp]

/-- Exact cost identity, retaining the sampled source indices and eliminating
only the intermediate standard Gaussian. -/
theorem sampledLayerPairKernel_cost [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) (θ : A)
    (F : Z × (S × R) → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ z, F z ∂sampledLayerPairKernel P p θ) =
      ∫⁻ I, ∫⁻ z, F (z.1.1,(I,z.2))
        ∂layerJointKernel (P.comap Prod.fst measurable_fst) p (θ,I)
        ∂iidSamples (uniformIndexLaw N) m := by
  rw [sampledLayerPairKernel,Kernel.map_apply _ (by fun_prop),
    lintegral_map hF (by fun_prop)]
  rw [Kernel.lintegral_compProd _ _ _ (show Measurable (fun z : S × (Z × R) => F (z.2.1,(z.1,z.2.2))) from hF.comp (by fun_prop))]
  simp only [Kernel.const_apply]
  apply lintegral_congr
  intro I
  exact layerPairKernel_cost _ _ _ (fun z => F (z.1,(I,z.2))) (hF.comp (by fun_prop))

variable {H Ω : Type*} [MeasurableSpace H] [MeasurableSpace Ω]
  [StandardBorelSpace H]

/-- Full original-field coupling with the source sample retained. -/
def fullSampledLayerCoupling [NeZero N] (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q) :
    Kernel A (Ω × (S × R)) :=
  conditionalFieldLift κ o ho ρ (sampledLayerPairKernel ρ.condKernel p)

instance fullSampledLayerCoupling_markov [NeZero N] (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q) :
    IsMarkovKernel (fullSampledLayerCoupling κ o ho ρ p) := by
  unfold fullSampledLayerCoupling
  infer_instance

theorem fullSampledLayerCoupling_original [NeZero N]
    (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q) :
    (fullSampledLayerCoupling κ o ho ρ p).fst = κ :=
  conditionalFieldLift_fst κ o ho ρ _

theorem fullSampledLayerCoupling_observables [NeZero N]
    (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q)
    (hρ : parameterMap κ o ho = ρ) (θ : A) :
    (fullSampledLayerCoupling κ o ho ρ p θ).map (fun z => (o (θ,z.1),z.2)) =
      conditionalJoint ρ (sampledLayerPairKernel ρ.condKernel p) θ :=
  conditionalFieldLift_observables κ o ho ρ _ hρ (sampledLayerPairKernel_fst _ _) θ

theorem fullSampledLayerCoupling_active_coefficients [NeZero N]
    (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q) (hp : p.Contractive)
    (hρ : parameterMap κ o ho = ρ) (θ : A) :
    (fullSampledLayerCoupling κ o ho ρ p θ).map (fun z => ((o (θ,z.1)).1,z.2)) =
      (ρ.fst ⊗ₖ ((Kernel.const (A × H) (iidSamples (uniformIndexLaw N) m)) ⊗ₖ
        residualRowsKernel p.sourceMatrix p.sourceMatrix_measurable)) θ := by
  have hh := conditionalFieldLift_active_candidate κ o ho ρ
    (sampledLayerPairKernel ρ.condKernel p) hρ (sampledLayerPairKernel_fst _ _) θ
  rw [sampledLayerPairKernel_snd _ _ hp] at hh
  exact hh

/-- Exact three-stage integration formula for the full-field comparison. It
also applies to a measurable success-masked cost. -/
theorem fullSampledLayerCoupling_cost [NeZero N]
    (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q)
    (hρ : parameterMap κ o ho = ρ) (θ : A)
    (F : (H × Z) × (S × R) → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ z, F (o (θ,z.1),z.2) ∂fullSampledLayerCoupling κ o ho ρ p θ) =
      ∫⁻ H, ∫⁻ I, ∫⁻ z,
        F ((H,z.1.1),(I,z.2))
        ∂layerJointKernel (ρ.condKernel.comap Prod.fst measurable_fst) p ((θ,H),I)
        ∂iidSamples (uniformIndexLaw N) m ∂ρ.fst θ := by
  have hm : Measurable (fun z : Ω × (S × R) => (o (θ,z.1),z.2)) :=
    ((ho.comp measurable_prodMk_left).comp measurable_fst).prodMk measurable_snd
  rw [← lintegral_map hF hm,fullSampledLayerCoupling_observables _ _ _ _ _ hρ θ]
  rw [conditionalJoint,Kernel.map_apply _ (by fun_prop),lintegral_map hF (by fun_prop)]
  rw [Kernel.lintegral_compProd _ _ _ (show Measurable (fun z : H × (Z × (S × R)) =>
    F ((z.1,z.2.1),z.2.2)) from hF.comp (by fun_prop))]
  apply lintegral_congr
  intro H
  exact sampledLayerPairKernel_cost _ _ _
    (fun z => F ((H,z.1),z.2)) (hF.comp (by fun_prop))

end NeuralGeneralization.RobustCompressionLayerComparison
