import NeuralGeneralization.BatchTwoImprovedSampledLayer

/-! Full original-field lifting with an arbitrary measurable source sampling
kernel.  Source sampling may depend on the selected active bank. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped ProbabilityTheory ENNReal
namespace NeuralGeneralization.BatchTwoImprovedLayerComparison
open RobustCompression RobustCompressionLayerGaussian CompressionSampling
variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}
local notation "Z" => Fin N → ℝ
local notation "S" => Fin m → Fin N
local notation "R" => Fin N → Fin m → ℝ
variable {H Ω : Type*} [MeasurableSpace H] [MeasurableSpace Ω]
  [StandardBorelSpace H]
variable (Samp : Kernel (A × H) (Fin m → Fin N)) [IsMarkovKernel Samp]

/-- Full original-field coupling with the source sample retained. -/
def fullSampledLayerCoupling [NeZero N] (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q) :
    Kernel A (Ω × (S × R)) :=
  conditionalFieldLift κ o ho ρ (sampledLayerPairKernel Samp ρ.condKernel p)

instance fullSampledLayerCoupling_markov [NeZero N] (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q) :
    IsMarkovKernel (fullSampledLayerCoupling Samp κ o ho ρ p) := by
  unfold fullSampledLayerCoupling
  infer_instance

theorem fullSampledLayerCoupling_original [NeZero N]
    (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q) :
    (fullSampledLayerCoupling Samp κ o ho ρ p).fst = κ :=
  conditionalFieldLift_fst κ o ho ρ _

theorem fullSampledLayerCoupling_observables [NeZero N]
    (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q)
    (hρ : parameterMap κ o ho = ρ) (θ : A) :
    (fullSampledLayerCoupling Samp κ o ho ρ p θ).map (fun z => (o (θ,z.1),z.2)) =
      conditionalJoint ρ (sampledLayerPairKernel Samp ρ.condKernel p) θ :=
  conditionalFieldLift_observables κ o ho ρ _ hρ (sampledLayerPairKernel_fst Samp _ _) θ

theorem fullSampledLayerCoupling_active_coefficients [NeZero N]
    (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × Z) (ho : Measurable o)
    (ρ : Kernel A (H × Z)) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters ((A × H) × S) N m q) (hp : p.Contractive)
    (hρ : parameterMap κ o ho = ρ) (θ : A) :
    (fullSampledLayerCoupling Samp κ o ho ρ p θ).map (fun z => ((o (θ,z.1)).1,z.2)) =
      (ρ.fst ⊗ₖ (Samp ⊗ₖ
        residualRowsKernel p.sourceMatrix p.sourceMatrix_measurable)) θ := by
  have hh := conditionalFieldLift_active_candidate κ o ho ρ
    (sampledLayerPairKernel Samp ρ.condKernel p) hρ (sampledLayerPairKernel_fst Samp _ _) θ
  rw [sampledLayerPairKernel_snd Samp _ _ hp] at hh
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
    (∫⁻ z, F (o (θ,z.1),z.2) ∂fullSampledLayerCoupling Samp κ o ho ρ p θ) =
      ∫⁻ H, ∫⁻ I, ∫⁻ z,
        F ((H,z.1.1),(I,z.2))
        ∂layerJointKernel (ρ.condKernel.comap Prod.fst measurable_fst) p ((θ,H),I)
        ∂Samp (θ,H) ∂ρ.fst θ := by
  have hm : Measurable (fun z : Ω × (S × R) => (o (θ,z.1),z.2)) :=
    ((ho.comp measurable_prodMk_left).comp measurable_fst).prodMk measurable_snd
  rw [← lintegral_map hF hm,fullSampledLayerCoupling_observables Samp _ _ _ _ _ hρ θ]
  rw [conditionalJoint,Kernel.map_apply _ (by fun_prop),lintegral_map hF (by fun_prop)]
  rw [Kernel.lintegral_compProd _ _ _ (show Measurable (fun z : H × (Z × (S × R)) =>
    F ((z.1,z.2.1),z.2.2)) from hF.comp (by fun_prop))]
  apply lintegral_congr
  intro H
  exact sampledLayerPairKernel_cost Samp _ _ _
    (fun z => F ((H,z.1),z.2)) (hF.comp (by fun_prop))

end NeuralGeneralization.BatchTwoImprovedLayerComparison
