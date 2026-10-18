import NeuralGeneralization.RobustCompressionLayerBound
import NeuralGeneralization.RobustCompressionConditionalLift

/-! # The observable layer coupling, with the intermediate Gaussian removed -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.RobustCompressionLayerComparison
open RobustCompression RobustCompressionLayerGaussian

variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}

/-- A genuine measurable coupling of the old residual and all new residual
coefficient rows. The auxiliary standard Gaussian is integrated out. -/
def layerPairKernel (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) :
    Kernel A ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) :=
  (layerJointKernel P p).map (fun z => (z.1.1,z.2))

instance layerPairKernel_markov (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) : IsMarkovKernel (layerPairKernel P p) := by
  unfold layerPairKernel
  exact Kernel.IsMarkovKernel.map _ (by fun_prop)

theorem layerPairKernel_fst (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) : (layerPairKernel P p).fst = P := by
  ext θ : 1
  change ((layerPairKernel P p) θ).map Prod.fst = P θ
  rw [layerPairKernel, Kernel.map_apply _ (by fun_prop),
    Measure.map_map measurable_fst (by fun_prop)]
  exact layerJointKernel_original P p θ

theorem layerPairKernel_snd (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) :
    (layerPairKernel P p).snd = residualRowsKernel p.sourceMatrix p.sourceMatrix_measurable := by
  ext θ : 1
  change ((layerPairKernel P p) θ).map Prod.snd = _
  rw [layerPairKernel, Kernel.map_apply _ (by fun_prop),
    Measure.map_map measurable_snd (by fun_prop), residualRowsKernel_apply]
  exact layerJointKernel_coefficients P p hp θ

theorem layerPairKernel_cost (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (θ : A)
    (F : (Fin N → ℝ) × (Fin N → Fin m → ℝ) → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ z, F z ∂layerPairKernel P p θ) =
      ∫⁻ z, F (z.1.1,z.2) ∂layerJointKernel P p θ := by
  rw [layerPairKernel, Kernel.map_apply _ (by fun_prop),
    lintegral_map hF (by fun_prop)]

variable {H Ω : Type*} [MeasurableSpace H] [MeasurableSpace Ω]
  [StandardBorelSpace H]

/-- Lift the layer comparison to the full original current field, using its
actual active/residual observation. This retains dependencies on unrevealed
weights and on the exposed prefix. -/
def fullLayerCoupling (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × (Fin N → ℝ)) (ho : Measurable o)
    (ρ : Kernel A (H × (Fin N → ℝ))) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters (A × H) N m q) :
    Kernel A (Ω × (Fin N → Fin m → ℝ)) :=
  conditionalFieldLift κ o ho ρ (layerPairKernel ρ.condKernel p)

instance fullLayerCoupling_markov (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × (Fin N → ℝ)) (ho : Measurable o)
    (ρ : Kernel A (H × (Fin N → ℝ))) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters (A × H) N m q) :
    IsMarkovKernel (fullLayerCoupling κ o ho ρ p) := by
  unfold fullLayerCoupling
  infer_instance

theorem fullLayerCoupling_original (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × (Fin N → ℝ)) (ho : Measurable o)
    (ρ : Kernel A (H × (Fin N → ℝ))) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters (A × H) N m q) :
    (fullLayerCoupling κ o ho ρ p).fst = κ :=
  conditionalFieldLift_fst κ o ho ρ _

theorem fullLayerCoupling_observables (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × (Fin N → ℝ)) (ho : Measurable o)
    (ρ : Kernel A (H × (Fin N → ℝ))) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters (A × H) N m q)
    (hρ : parameterMap κ o ho = ρ) (θ : A) :
    (fullLayerCoupling κ o ho ρ p θ).map (fun z => (o (θ,z.1),z.2)) =
      conditionalJoint ρ (layerPairKernel ρ.condKernel p) θ :=
  conditionalFieldLift_observables κ o ho ρ _ hρ (layerPairKernel_fst _ _) θ

theorem fullLayerCoupling_active_coefficients (κ : Kernel A Ω) [IsMarkovKernel κ]
    (o : A × Ω → H × (Fin N → ℝ)) (ho : Measurable o)
    (ρ : Kernel A (H × (Fin N → ℝ))) [IsMarkovKernel ρ]
    (p : GaussianLayerParameters (A × H) N m q) (hp : p.Contractive)
    (hρ : parameterMap κ o ho = ρ) (θ : A) :
    (fullLayerCoupling κ o ho ρ p θ).map (fun z => ((o (θ,z.1)).1,z.2)) =
      (ρ.fst ⊗ₖ residualRowsKernel p.sourceMatrix p.sourceMatrix_measurable) θ := by
  have hh := conditionalFieldLift_active_candidate κ o ho ρ
    (layerPairKernel ρ.condKernel p) hρ (layerPairKernel_fst _ _) θ
  rw [layerPairKernel_snd _ _ hp] at hh
  exact hh

end NeuralGeneralization.RobustCompressionLayerComparison
