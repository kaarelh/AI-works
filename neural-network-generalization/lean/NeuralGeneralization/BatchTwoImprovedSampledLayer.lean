import NeuralGeneralization.BatchTwoImprovedLayerPair
import NeuralGeneralization.RobustCompressionSampling

/-! # Integrating the shared source bank inside the conditional comparison

The source indices are sampled after the actual active observation is exposed.
This keeps its original disintegration unchanged and gives exactly the same
input-independent candidate source/coefficient marginal for every test input.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory ENNReal
namespace NeuralGeneralization.BatchTwoImprovedLayerComparison
open RobustCompression RobustCompressionLayerGaussian CompressionSampling

variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}
local notation "Z" => Fin N → ℝ
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ
variable (Samp : Kernel A (Fin m → Fin N)) [IsMarkovKernel Samp]

def sampledLayerPairKernel [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) : Kernel A (Z × (S × R)) :=
  (Samp ⊗ₖ
    layerPairKernel (P.comap Prod.fst measurable_fst) p).map
      (fun z => (z.2.1,(z.1,z.2.2)))

instance sampledLayerPairKernel_markov [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) :
    IsMarkovKernel (sampledLayerPairKernel Samp P p) := by
  unfold sampledLayerPairKernel
  exact Kernel.IsMarkovKernel.map _ (by fun_prop)

theorem sampledLayerPairKernel_fst [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) :
    (sampledLayerPairKernel Samp P p).fst = P := by
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
    ((fun z : Z × R => z.1) ⁻¹' s) ∂Samp θ) = _
  simp_rw [hf]
  simp

theorem sampledLayerPairKernel_snd [NeZero N] (P : Kernel A Z) [IsMarkovKernel P]
    (p : GaussianLayerParameters (A × S) N m q) (hp : p.Contractive) :
    (sampledLayerPairKernel Samp P p).snd =
      Samp ⊗ₖ
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
    (∫⁻ z, F z ∂sampledLayerPairKernel Samp P p θ) =
      ∫⁻ I, ∫⁻ z, F (z.1.1,(I,z.2))
        ∂layerJointKernel (P.comap Prod.fst measurable_fst) p (θ,I)
        ∂Samp θ := by
  rw [sampledLayerPairKernel,Kernel.map_apply _ (by fun_prop),
    lintegral_map hF (by fun_prop)]
  rw [Kernel.lintegral_compProd _ _ _ (show Measurable (fun z : S × (Z × R) => F (z.2.1,(z.1,z.2.2))) from hF.comp (by fun_prop))]
  apply lintegral_congr
  intro I
  exact layerPairKernel_cost _ _ _ (fun z => F (z.1,(I,z.2))) (hF.comp (by fun_prop))

end NeuralGeneralization.BatchTwoImprovedLayerComparison
