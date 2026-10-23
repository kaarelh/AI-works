import NeuralGeneralization.BatchTwoImprovedLayerComparison
import NeuralGeneralization.RobustCompressionConditionalLift

/-! # The observable layer coupling, with the intermediate Gaussian removed -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.BatchTwoImprovedLayerComparison
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

end NeuralGeneralization.BatchTwoImprovedLayerComparison
