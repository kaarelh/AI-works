import NeuralGeneralization.BatchTwoImprovedGaussianT2Finite
import NeuralGeneralization.BatchTwoImprovedGaussianSquareRoot
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
namespace NeuralGeneralization.BatchTwoImprovedLayerComparison
open RobustCompression RobustCompressionLayerGaussian BatchTwoImprovedGaussianTransport

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

/-- Sharp Talagrand entropy replacement inside the complete coefficient coupling. -/
theorem layerJointKernel_entropy_cost (μ : Measure A) [IsProbabilityMeasure μ]
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q)
    {e t : ℝ} (he : 0 ≤ e) (ht : 0 < t)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ)
    (a : A → Fin N → ℝ) (ha : ∀ i, Measurable (fun θ => a θ i))
    (ρ : A → ℝ) (hρm : Measurable ρ) (hρ : ∀ θ, 0 ≤ ρ θ) (hρ1 : ∀ θ, ρ θ ≤ 1)
    (hbudget : (∫⁻ θ, klDiv (P θ) (Measure.pi (fun _ : Fin N => gaussianReal 0 1)) ∂μ) ≤
      ENNReal.ofReal (N * e / t ^ 2)) :
    (∫⁻ θ, ∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (a θ i + t * ρ θ * z.1.1 i) - φ (a θ i + t * ρ θ * z.1.2 i)) ^ 2)
      ∂layerJointKernel P p θ ∂μ) ≤ ENNReal.ofReal (2 * N * e) := by
  have hφm := hφ.continuous.measurable
  have heq (θ : A) :
      (∫⁻ z, ENNReal.ofReal (∑ i,
        (φ (a θ i+t*ρ θ*z.1.1 i)-φ (a θ i+t*ρ θ*z.1.2 i))^2)
        ∂layerJointKernel P p θ) =
      ∫⁻ z, ENNReal.ofReal (∑ i,
        (φ (a θ i+t*ρ θ*z.1 i)-φ (a θ i+t*ρ θ*z.2 i))^2)
        ∂finiteCouplingKernel (gaussianReal 0 1) N P θ := by
    exact layerJointKernel_old_cost P p θ
      (fun z => ENNReal.ofReal (∑ i,
        (φ (a θ i+t*ρ θ*z.1 i)-φ (a θ i+t*ρ θ*z.2 i))^2)) (by fun_prop)
  simp_rw [heq]
  apply finiteCouplingKernel_averaged μ N P he ht
    (fun θ i x => φ (a θ i+t*ρ θ*x)) _ hbudget
  intro θ i x y
  have h := hφ.dist_le_mul (a θ i+t*ρ θ*x) (a θ i+t*ρ θ*y)
  simp only [Real.dist_eq,NNReal.coe_one,one_mul] at h
  calc
    _ ≤ |(a θ i+t*ρ θ*x)-(a θ i+t*ρ θ*y)| := h
    _ = t*ρ θ*|x-y| := by
      rw [show (a θ i+t*ρ θ*x)-(a θ i+t*ρ θ*y)=t*ρ θ*(x-y) by ring,
        abs_mul,abs_of_nonneg (mul_nonneg ht.le (hρ θ))]
    _ ≤ t*|x-y| := by
      have hmul := mul_le_mul_of_nonneg_left (hρ1 θ) ht.le
      simpa using mul_le_mul_of_nonneg_right hmul (abs_nonneg (x-y))

/-- Pointwise sharp transport estimate. This form can be integrated through
an arbitrary source-index kernel without requiring naturality of a chosen
conditional Gaussian coupling under reparameterization. -/
theorem ideal_transport_cost_point
    (P : Kernel A (Fin N → ℝ)) [IsMarkovKernel P]
    (p : GaussianLayerParameters A N m q) (θ : A)
    {t : ℝ} (ht : 0 ≤ t) (hv : ∀ i, (p.idealVariance θ i:ℝ) ≤ t^2)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) :
    (∫⁻ z, ENNReal.ofReal (∑ i,
      (φ (p.idealObservable (θ,z.1) i)-φ (p.idealObservable (θ,z.2) i))^2)
      ∂finiteCouplingKernel (gaussianReal 0 1) N P θ) ≤
      ENNReal.ofReal (2*t^2)*klDiv (P θ) (Measure.pi (fun _ : Fin N => gaussianReal 0 1)) := by
  apply finiteCouplingKernel_lipschitz_cost_le N P θ ht
    (fun i x => φ (p.idealMean θ i+Real.sqrt (p.idealVariance θ i:ℝ)*x))
  intro i x y
  have hs : Real.sqrt (p.idealVariance θ i:ℝ) ≤ t := by
    have hh := Real.sq_sqrt (p.idealVariance θ i).coe_nonneg
    nlinarith [Real.sqrt_nonneg (p.idealVariance θ i:ℝ),hv i]
  have hh := hφ.dist_le_mul (p.idealMean θ i+Real.sqrt (p.idealVariance θ i:ℝ)*x)
    (p.idealMean θ i+Real.sqrt (p.idealVariance θ i:ℝ)*y)
  simp only [Real.dist_eq,NNReal.coe_one,one_mul] at hh
  calc
    _ ≤ |(p.idealMean θ i+Real.sqrt (p.idealVariance θ i:ℝ)*x)-
      (p.idealMean θ i+Real.sqrt (p.idealVariance θ i:ℝ)*y)| := hh
    _ = Real.sqrt (p.idealVariance θ i:ℝ)*|x-y| := by
      rw [show (p.idealMean θ i+Real.sqrt (p.idealVariance θ i:ℝ)*x)-
        (p.idealMean θ i+Real.sqrt (p.idealVariance θ i:ℝ)*y)=
          Real.sqrt (p.idealVariance θ i:ℝ)*(x-y) by ring,
        abs_mul,abs_of_nonneg (Real.sqrt_nonneg _)]
    _ ≤ t*|x-y| := mul_le_mul_of_nonneg_right hs (abs_nonneg _)

end NeuralGeneralization.BatchTwoImprovedLayerComparison
