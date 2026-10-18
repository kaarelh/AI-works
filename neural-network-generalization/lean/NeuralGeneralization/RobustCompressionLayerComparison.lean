import NeuralGeneralization.RobustCompressionLayerGaussian
import NeuralGeneralization.RobustCompressionLayerClipping
import NeuralGeneralization.RobustCompressionLayerCost
import NeuralGeneralization.RobustCouplingTwoScale
import NeuralGeneralization.RobustCompressionGluingKernel

/-! # A genuine common-coefficient comparison for one entropy-compressed layer

The two-scale entropy coupling is glued to the full Gaussian-field coupling.
The resulting measurable kernel retains the original residual evaluations,
the intermediate standard Gaussian evaluations, and every canonical residual
coefficient row. Its coefficient marginal is the prescribed input-independent
one; no pointwise choice of coefficients or comparison measure is made.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal
namespace NeuralGeneralization.RobustCompressionLayerComparison
open RobustCompression RobustCoupling RobustCompressionLayerGaussian

variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}

def layerJointKernel (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) :
    Kernel A (((Fin N → ℝ) × (Fin N → ℝ)) × (Fin N → Fin m → ℝ)) :=
  glueKernel (finiteCouplingKernel (gaussianReal 0 1) N P) p.fullCoupling

instance layerJointKernel_markov (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) : IsMarkovKernel (layerJointKernel P p) := by
  unfold layerJointKernel
  infer_instance

theorem layer_shared_gaussian (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) :
    (finiteCouplingKernel (gaussianReal 0 1) N P).snd = p.fullCoupling.fst := by
  ext θ : 1
  exact (finiteCouplingKernel_snd (gaussianReal 0 1) N P θ).trans
    (p.fullCoupling_fst hp θ).symm

theorem layerJointKernel_old (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (θ : A) :
    (layerJointKernel P p θ).map Prod.fst = finiteCouplingKernel (gaussianReal 0 1) N P θ := by
  exact congrArg (fun K : Kernel A ((Fin N → ℝ) × (Fin N → ℝ)) => K θ)
    (glueKernel_old (finiteCouplingKernel (gaussianReal 0 1) N P) p.fullCoupling)

theorem layerJointKernel_new (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) (θ : A) :
    (layerJointKernel P p θ).map (fun z => (z.1.2, z.2)) = p.fullCoupling θ := by
  have hh := congrArg (fun K : Kernel A ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) => K θ)
    (glueKernel_new (finiteCouplingKernel (gaussianReal 0 1) N P) p.fullCoupling
      (layer_shared_gaussian P p hp))
  rwa [Kernel.map_apply _ (by fun_prop)] at hh

theorem layerJointKernel_original (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (θ : A) :
    (layerJointKernel P p θ).map (fun z => z.1.1) = P θ := by
  have hh := congrArg (fun μ => μ.map Prod.fst) (layerJointKernel_old P p θ)
  rw [Measure.map_map measurable_fst measurable_fst] at hh
  exact hh.trans (finiteCouplingKernel_fst (gaussianReal 0 1) N P θ)

/-- The coefficient marginal is independent of the test feature and of the
conditional residual law P; it is exactly the canonical Gaussian row law. -/
theorem layerJointKernel_coefficients (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) (θ : A) :
    (layerJointKernel P p θ).map Prod.snd =
      Measure.pi (fun _ : Fin N => RobustGaussianGeometry.sourceResidualKernel (p.sourceMatrix θ)) := by
  have hh := congrArg (fun μ => μ.map Prod.snd) (layerJointKernel_new P p hp θ)
  rw [Measure.map_map measurable_snd (by fun_prop)] at hh
  exact hh.trans (p.fullCoupling_snd θ)

theorem layerJointKernel_old_cost (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (θ : A)
    (F : (Fin N → ℝ) × (Fin N → ℝ) → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ z, F z.1 ∂layerJointKernel P p θ) =
      ∫⁻ z, F z ∂finiteCouplingKernel (gaussianReal 0 1) N P θ := by
  have hh := lintegral_map hF measurable_fst (μ := layerJointKernel P p θ)
  rw [layerJointKernel_old] at hh
  exact hh.symm

theorem layerJointKernel_new_cost (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) (θ : A)
    (F : (Fin N → ℝ) × (Fin N → Fin m → ℝ) → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ z, F (z.1.2,z.2) ∂layerJointKernel P p θ) =
      ∫⁻ z, F z ∂p.fullCoupling θ := by
  have hh := lintegral_map hF (by fun_prop :
    Measurable (fun z : ((Fin N → ℝ) × (Fin N → ℝ)) × (Fin N → Fin m → ℝ) => (z.1.2,z.2)))
    (μ := layerJointKernel P p θ)
  rw [layerJointKernel_new P p hp θ] at hh
  exact hh.symm

/-- Averaged actual conditional entropy controls the residual-replacement cost
inside the complete canonical-coefficient coupling. -/
theorem layerJointKernel_entropy_cost (μ : Measure A) [IsProbabilityMeasure μ]
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q)
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hφbound : ∀ z, |φ z| ≤ 1)
    (a : A → Fin N → ℝ) (ha : ∀ i, Measurable (fun θ => a θ i))
    (ρ : A → ℝ) (hρm : Measurable ρ) (hρ : ∀ θ, 0 ≤ ρ θ) (hρ1 : ∀ θ, ρ θ ≤ 1)
    (hbudget : (∫⁻ θ, klDiv (P θ) (standardGaussianVector N) ∂μ) ≤
      ENNReal.ofReal (N * δ ^ 3 / t ^ 2)) :
    (∫⁻ θ, ∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (a θ i + t * ρ θ * z.1.1 i) - φ (a θ i + t * ρ θ * z.1.2 i)) ^ 2)
      ∂layerJointKernel P p θ ∂μ) ≤ ENNReal.ofReal (14 * N * δ) := by
  have hφm := hφ.continuous.measurable
  have heq (θ : A) :
      (∫⁻ z, ENNReal.ofReal (∑ i,
        (φ (a θ i + t * ρ θ * z.1.1 i) - φ (a θ i + t * ρ θ * z.1.2 i)) ^ 2)
        ∂layerJointKernel P p θ) =
      ∫⁻ z, ENNReal.ofReal (∑ i,
        (φ (a θ i + t * ρ θ * z.1 i) - φ (a θ i + t * ρ θ * z.2 i)) ^ 2)
        ∂finiteCouplingKernel (gaussianReal 0 1) N P θ := by
    exact layerJointKernel_old_cost P p θ
      (fun z => ENNReal.ofReal (∑ i,
        (φ (a θ i + t * ρ θ * z.1 i) - φ (a θ i + t * ρ θ * z.2 i)) ^ 2)) (by fun_prop)
  simp_rw [heq]
  exact finiteCouplingKernel_activation_replacement μ N P hδ hδ1 ht
    φ hφ hφbound a ha ρ hρm hρ hρ1 hbudget

theorem layerJointKernel_gaussian_cost (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) (θ : A)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1)
    {Emean Evariance : ℝ}
    (hmean : ∀ i, (p.idealMean θ i - p.finiteMean θ i)^2 ≤ Emean)
    (hvariance : ∀ i, |(p.idealVariance θ i : ℝ)-p.finiteVariance θ i| ≤ Evariance) :
    (∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.idealObservable (θ,z.1.2) i)-φ (p.finiteObservable (θ,z.2) i))^2)
      ∂layerJointKernel P p θ) ≤ ENNReal.ofReal ((N : ℝ)*(Emean+Evariance)) := by
  have hφm := hφ.continuous.measurable
  rw [layerJointKernel_new_cost P p hp θ
    (fun z => ENNReal.ofReal (∑ i,
      (φ (p.idealObservable (θ,z.1) i)-φ (p.finiteObservable (θ,z.2) i))^2)) (by
        have h₁ : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) =>
            p.idealObservable (θ,z.1)) :=
          p.idealObservable_measurable.comp (measurable_const.prodMk measurable_fst)
        have h₂ : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) =>
            p.finiteObservable (θ,z.2)) :=
          p.finiteObservable_measurable.comp (measurable_const.prodMk measurable_snd)
        fun_prop)]
  exact RobustCompressionLayerCost.activation_vector_cost_lintegral_le
    (p.fullCoupling θ) φ hφm hb _ _
    ((p.idealObservable_measurable.comp measurable_prodMk_left).comp measurable_fst)
    ((p.finiteObservable_measurable.comp measurable_prodMk_left).comp measurable_snd)
    (p.fullCoupling_activation_error_uniform hp θ φ hφ hmean hvariance)

theorem layerJointKernel_clipping_cost (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (hp : p.Contractive) (θ : A)
    (hh : ∀ j, |p.sourceFeature θ j| ≤ 1) (ht : |p.scale| ≤ 1)
    {B : ℝ} (hB : 0 < B) (hm : 0 < m)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hb : ∀ z, |φ z| ≤ 1) :
    (∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.finiteObservable (θ,z.2) i)-φ (p.clippedFiniteObservable B (θ,z.2) i))^2)
      ∂layerJointKernel P p θ) ≤ ENNReal.ofReal (64*(N : ℝ)*m/B^2) := by
  have hφm := hφ.continuous.measurable
  have h₁ : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) =>
      p.finiteObservable (θ,z.2)) :=
    p.finiteObservable_measurable.comp (measurable_const.prodMk measurable_snd)
  have h₂ : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) =>
      p.clippedFiniteObservable B (θ,z.2)) :=
    (p.clippedFiniteObservable_measurable B).comp (measurable_const.prodMk measurable_snd)
  have heq := layerJointKernel_new_cost P p hp θ
    (fun z => ENNReal.ofReal (∑ i,
      (φ (p.finiteObservable (θ,z.2) i)-φ (p.clippedFiniteObservable B (θ,z.2) i))^2)) (by fun_prop)
  rw [heq]
  exact RobustCompressionLayerCost.activation_vector_cost_lintegral_le
    (p.fullCoupling θ) φ hφm hb _ _ h₁ h₂
    (p.fullCoupling_activation_clipping_error hp θ hh ht hB hm φ hφ hb)

end NeuralGeneralization.RobustCompressionLayerComparison
