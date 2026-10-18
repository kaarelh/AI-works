import NeuralGeneralization.RobustCompressionGaussianVector
import NeuralGeneralization.RobustCompressionObservableKernel
import NeuralGeneralization.RobustGaussianGeometryScalar

/-!
# Full-field Gaussian comparison for an actual reconstructed network layer

The canonical right law consists of independent residual coefficient rows.
Only the coupling of their evaluations depends on the test feature vector.
Lifting the evaluated-vector coupling preserves the complete coefficient-row
law and the complete ideal Gaussian-vector law, measurably in the prefix.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Matrix
open scoped BigOperators NNReal ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionLayerGaussian
open RobustCompression RobustCompressionGaussian RobustGaussianGeometry

variable {A : Type*} [MeasurableSpace A] {N m q : ℕ}

def residualRowsKernel (D : A → Fin m → Fin q → ℝ) (hD : Measurable D) :
    Kernel A (Fin N → Fin m → ℝ) :=
  parameterMap (Kernel.const A
    (Measure.pi (fun _ : Fin N => Measure.pi (fun _ : Fin m => gaussianReal 0 1))))
    (fun p : A × (Fin N → Fin m → ℝ) =>
      fun i => residualDraw (residualCovariance (D p.1)) (p.2 i)) (by
        apply measurable_pi_lambda
        intro i
        exact measurable_residualDraw.comp
          ((measurable_residualCovariance.comp (hD.comp measurable_fst)).prodMk
            ((measurable_pi_apply i).comp measurable_snd)))

instance residualRowsKernel_markov (D : A → Fin m → Fin q → ℝ) (hD : Measurable D) :
    IsMarkovKernel (residualRowsKernel (N := N) D hD) := by
  unfold residualRowsKernel
  infer_instance

theorem residualRowsKernel_apply (D : A → Fin m → Fin q → ℝ)
    (hD : Measurable D) (θ : A) :
    residualRowsKernel (N := N) D hD θ =
      Measure.pi (fun _ : Fin N => sourceResidualKernel (D θ)) := by
  rw [residualRowsKernel, parameterMap_apply, Kernel.const_apply,
    Measure.pi_map_pi (f := fun (_ : Fin N) (z : Fin m → ℝ) =>
      residualDraw (residualCovariance (D θ)) z) (fun i =>
        (measurable_residualDraw.comp (measurable_const.prodMk measurable_id)).aemeasurable)]
  rfl

def residualVariance (D : Fin m → Fin q → ℝ) (h : Fin m → ℝ) (t : ℝ) : ℝ≥0 :=
  ((t / Real.sqrt (m : ℝ)) ^ 2).toNNReal * (sourceResidualVariance D h).toNNReal

def residualEvaluation (b : Fin N → ℝ) (h : Fin m → ℝ) (t : ℝ)
    (ξ : Fin N → Fin m → ℝ) : Fin N → ℝ :=
  fun i => b i + t / Real.sqrt (m : ℝ) * ∑ j, h j * ξ i j

theorem residual_scalar_affine_law (D : Fin m → Fin q → ℝ)
    (hD : ∀ u : Fin q → ℝ, ∑ i, (Matrix.of D *ᵥ u) i ^ 2 ≤ ∑ j, u j ^ 2)
    (h : Fin m → ℝ) (t b : ℝ) :
    (sourceResidualKernel D).map
      (fun z => b + t / Real.sqrt (m : ℝ) * ∑ j, h j * z j) =
        gaussianReal b (residualVariance D h t) := by
  have hf : Measurable (fun z : Fin m → ℝ => ∑ j, h j * z j) := by fun_prop
  have hg : Measurable (fun z : ℝ => t / Real.sqrt (m : ℝ) * z) := by fun_prop
  have hb : Measurable (fun z : ℝ => b + z) := by fun_prop
  change (sourceResidualKernel D).map
    ((fun z : ℝ => b + z) ∘ ((fun z : ℝ => t / Real.sqrt (m : ℝ) * z) ∘
      (fun z : Fin m → ℝ => ∑ j, h j * z j))) = _
  rw [← Measure.map_map hb (hg.comp hf), ← Measure.map_map hg hf,
    sourceResidualKernel_scalar_law D hD h, gaussianReal_map_const_mul,
    gaussianReal_map_const_add, mul_zero, zero_add]
  congr 1
  apply NNReal.coe_injective
  simp only [residualVariance, NNReal.coe_mul, NNReal.coe_mk,
    Real.coe_toNNReal _ (sq_nonneg _)]

theorem residualRows_evaluation_law (D : A → Fin m → Fin q → ℝ)
    (hD : Measurable D) (θ : A)
    (hcontract : ∀ u : Fin q → ℝ, ∑ i, (Matrix.of (D θ) *ᵥ u) i ^ 2 ≤ ∑ j, u j ^ 2)
    (b : Fin N → ℝ) (h : Fin m → ℝ) (t : ℝ) :
    (residualRowsKernel D hD θ).map (residualEvaluation b h t) =
      Measure.pi (fun i => gaussianReal (b i) (residualVariance (D θ) h t)) := by
  rw [residualRowsKernel_apply]
  unfold residualEvaluation
  rw [Measure.pi_map_pi (f := fun i (z : Fin m → ℝ) =>
    b i + t / Real.sqrt (m : ℝ) * ∑ j, h j * z j)
      (fun i => (by fun_prop : Measurable (fun z : Fin m → ℝ =>
        b i + t / Real.sqrt (m : ℝ) * ∑ j, h j * z j)).aemeasurable)]
  congr 1
  funext i
  exact residual_scalar_affine_law (D θ) hcontract h t (b i)

theorem measurable_residualVariance (D : A → Fin m → Fin q → ℝ)
    (hD : Measurable D) (h : A → Fin m → ℝ) (hh : Measurable h) (t : ℝ) :
    Measurable (fun θ => residualVariance (D θ) (h θ) t) := by
  unfold residualVariance sourceResidualVariance
  fun_prop

theorem measurable_residualEvaluation (b : A → Fin N → ℝ) (hb : Measurable b)
    (h : A → Fin m → ℝ) (hh : Measurable h) (t : ℝ) :
    Measurable (fun p : A × (Fin N → Fin m → ℝ) => residualEvaluation (b p.1) (h p.1) t p.2) := by
  unfold residualEvaluation
  fun_prop

def idealEvaluation (a : Fin N → ℝ) (v : Fin N → ℝ≥0) (Z : Fin N → ℝ) : Fin N → ℝ :=
  fun i => a i + Real.sqrt (v i : ℝ) * Z i

theorem measurable_idealEvaluation (a : A → Fin N → ℝ) (ha : Measurable a)
    (v : A → Fin N → ℝ≥0) (hv : Measurable v) :
    Measurable (fun p : A × (Fin N → ℝ) => idealEvaluation (a p.1) (v p.1) p.2) := by
  unfold idealEvaluation
  fun_prop

structure GaussianLayerParameters (A : Type*) [MeasurableSpace A] (N m q : ℕ) where
  idealMean : A → Fin N → ℝ
  finiteMean : A → Fin N → ℝ
  idealVariance : A → Fin N → ℝ≥0
  sourceMatrix : A → Fin m → Fin q → ℝ
  sourceFeature : A → Fin m → ℝ
  scale : ℝ
  idealMean_measurable : Measurable idealMean
  finiteMean_measurable : Measurable finiteMean
  idealVariance_measurable : Measurable idealVariance
  sourceMatrix_measurable : Measurable sourceMatrix
  sourceFeature_measurable : Measurable sourceFeature

namespace GaussianLayerParameters

def finiteVariance (p : GaussianLayerParameters A N m q) (θ : A) (_i : Fin N) : ℝ≥0 :=
  residualVariance (p.sourceMatrix θ) (p.sourceFeature θ) p.scale

theorem finiteVariance_measurable (p : GaussianLayerParameters A N m q) :
    Measurable p.finiteVariance :=
  measurable_pi_lambda _ (fun _ => measurable_residualVariance p.sourceMatrix
    p.sourceMatrix_measurable p.sourceFeature p.sourceFeature_measurable p.scale)

def evaluationCoupling (p : GaussianLayerParameters A N m q) :
    Kernel A ((Fin N → ℝ) × (Fin N → ℝ)) :=
  vectorGaussianKernel p.idealMean p.finiteMean p.idealVariance p.finiteVariance
    p.idealMean_measurable p.finiteMean_measurable p.idealVariance_measurable
    p.finiteVariance_measurable

instance evaluationCoupling_markov (p : GaussianLayerParameters A N m q) :
    IsMarkovKernel p.evaluationCoupling := by unfold evaluationCoupling; infer_instance

def idealObservable (p : GaussianLayerParameters A N m q) : A × (Fin N → ℝ) → (Fin N → ℝ) :=
  fun z => idealEvaluation (p.idealMean z.1) (p.idealVariance z.1) z.2

theorem idealObservable_measurable (p : GaussianLayerParameters A N m q) :
    Measurable p.idealObservable :=
  measurable_idealEvaluation _ p.idealMean_measurable _ p.idealVariance_measurable

def finiteObservable (p : GaussianLayerParameters A N m q) :
    A × (Fin N → Fin m → ℝ) → (Fin N → ℝ) :=
  fun z => residualEvaluation (p.finiteMean z.1) (p.sourceFeature z.1) p.scale z.2

theorem finiteObservable_measurable (p : GaussianLayerParameters A N m q) :
    Measurable p.finiteObservable :=
  measurable_residualEvaluation _ p.finiteMean_measurable _ p.sourceFeature_measurable _

def originalKernel (_p : GaussianLayerParameters A N m q) : Kernel A (Fin N → ℝ) :=
  Kernel.const A (Measure.pi (fun _ : Fin N => gaussianReal 0 1))

instance originalKernel_markov (p : GaussianLayerParameters A N m q) :
    IsMarkovKernel p.originalKernel := by unfold originalKernel; infer_instance

def coefficientKernel (p : GaussianLayerParameters A N m q) : Kernel A (Fin N → Fin m → ℝ) :=
  residualRowsKernel p.sourceMatrix p.sourceMatrix_measurable

instance coefficientKernel_markov (p : GaussianLayerParameters A N m q) :
    IsMarkovKernel p.coefficientKernel := by unfold coefficientKernel; infer_instance

/-- This is the actual jointly measurable full-field comparison. The right
coefficient kernel depends on the sampled matrix only, not on the test feature.
-/
def fullCoupling (p : GaussianLayerParameters A N m q) :
    Kernel A ((Fin N → ℝ) × (Fin N → Fin m → ℝ)) :=
  liftBothObservablesKernel p.originalKernel p.coefficientKernel
    p.idealObservable p.idealObservable_measurable
    p.finiteObservable p.finiteObservable_measurable p.evaluationCoupling

instance fullCoupling_markov (p : GaussianLayerParameters A N m q) :
    IsMarkovKernel p.fullCoupling := by unfold fullCoupling; infer_instance

theorem ideal_observable_law (p : GaussianLayerParameters A N m q) :
    parameterMap p.originalKernel p.idealObservable p.idealObservable_measurable =
      p.evaluationCoupling.fst := by
  ext θ : 1
  rw [parameterMap_apply]
  change (Measure.pi (fun _ : Fin N => gaussianReal 0 1)).map
    (idealEvaluation (p.idealMean θ) (p.idealVariance θ)) = _
  rw [Kernel.fst_apply, evaluationCoupling, vectorGaussianKernel_fst]
  exact standard_gaussian_vector_affine_map _ _

def Contractive (p : GaussianLayerParameters A N m q) : Prop :=
  ∀ θ u, ∑ i, (Matrix.of (p.sourceMatrix θ) *ᵥ u) i ^ 2 ≤ ∑ j, u j ^ 2

theorem finite_observable_law (p : GaussianLayerParameters A N m q) (hp : p.Contractive) :
    parameterMap p.coefficientKernel p.finiteObservable p.finiteObservable_measurable =
      p.evaluationCoupling.snd := by
  ext θ : 1
  rw [parameterMap_apply]
  change (residualRowsKernel p.sourceMatrix p.sourceMatrix_measurable θ).map
    (residualEvaluation (p.finiteMean θ) (p.sourceFeature θ) p.scale) = _
  rw [residualRows_evaluation_law _ _ θ (hp θ), Kernel.snd_apply,
    evaluationCoupling, vectorGaussianKernel_snd]
  rfl

theorem fullCoupling_fst (p : GaussianLayerParameters A N m q) (hp : p.Contractive) (θ : A) :
    (p.fullCoupling θ).map Prod.fst = Measure.pi (fun _ : Fin N => gaussianReal 0 1) := by
  have hh := liftBothObservablesKernel_fst p.originalKernel p.coefficientKernel
    p.idealObservable p.idealObservable_measurable
    p.finiteObservable p.finiteObservable_measurable p.evaluationCoupling
    p.ideal_observable_law (p.finite_observable_law hp)
  exact congrArg (fun K : Kernel A (Fin N → ℝ) => K θ) hh

theorem fullCoupling_snd (p : GaussianLayerParameters A N m q) (θ : A) :
    (p.fullCoupling θ).map Prod.snd =
      Measure.pi (fun _ : Fin N => sourceResidualKernel (p.sourceMatrix θ)) := by
  have hh := liftBothObservablesKernel_snd p.originalKernel p.coefficientKernel
    p.idealObservable p.idealObservable_measurable
    p.finiteObservable p.finiteObservable_measurable p.evaluationCoupling
  have he := congrArg (fun K : Kernel A (Fin N → Fin m → ℝ) => K θ) hh
  change (p.fullCoupling θ).map Prod.snd = residualRowsKernel _ _ θ at he
  rwa [residualRowsKernel_apply] at he

theorem fullCoupling_evaluations (p : GaussianLayerParameters A N m q) (hp : p.Contractive)
    (θ : A) :
    (p.fullCoupling θ).map (fun z => (p.idealObservable (θ, z.1), p.finiteObservable (θ, z.2))) =
      p.evaluationCoupling θ :=
  liftBothObservablesKernel_comparison p.originalKernel p.coefficientKernel
    p.idealObservable p.idealObservable_measurable
    p.finiteObservable p.finiteObservable_measurable p.evaluationCoupling
    p.ideal_observable_law (p.finite_observable_law hp) θ

theorem fullCoupling_activation_error (p : GaussianLayerParameters A N m q) (hp : p.Contractive)
    (θ : A) (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) :
    (∫ z, ∑ i, (φ (p.idealObservable (θ, z.1) i) -
      φ (p.finiteObservable (θ, z.2) i)) ^ 2 ∂p.fullCoupling θ) ≤
        ∑ i, ((p.idealMean θ i - p.finiteMean θ i) ^ 2 +
          |(p.idealVariance θ i : ℝ) - p.finiteVariance θ i|) := by
  have hh := vectorGaussianKernel_activation_error p.idealMean p.finiteMean
    p.idealVariance p.finiteVariance p.idealMean_measurable p.finiteMean_measurable
    p.idealVariance_measurable p.finiteVariance_measurable θ φ hφ
  change (∫ z : (Fin N → ℝ) × (Fin N → ℝ), ∑ i, (φ (z.1 i) - φ (z.2 i)) ^ 2
    ∂p.evaluationCoupling θ) ≤ _ at hh
  rw [← p.fullCoupling_evaluations hp θ] at hh
  have hmap : Measurable (fun z : (Fin N → ℝ) × (Fin N → Fin m → ℝ) =>
      (p.idealObservable (θ, z.1), p.finiteObservable (θ, z.2))) :=
    ((p.idealObservable_measurable.comp measurable_prodMk_left).comp measurable_fst).prodMk
      ((p.finiteObservable_measurable.comp measurable_prodMk_left).comp measurable_snd)
  have hφm := hφ.continuous.measurable
  rw [integral_map hmap.aemeasurable (by fun_prop)] at hh
  exact hh

theorem fullCoupling_activation_error_uniform (p : GaussianLayerParameters A N m q)
    (hp : p.Contractive) (θ : A) (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ)
    {Emean Evariance : ℝ}
    (hmean : ∀ i, (p.idealMean θ i - p.finiteMean θ i) ^ 2 ≤ Emean)
    (hvariance : ∀ i, |(p.idealVariance θ i : ℝ) - p.finiteVariance θ i| ≤ Evariance) :
    (∫ z, ∑ i, (φ (p.idealObservable (θ, z.1) i) -
      φ (p.finiteObservable (θ, z.2) i)) ^ 2 ∂p.fullCoupling θ) ≤
        (N : ℝ) * (Emean + Evariance) := by
  refine (p.fullCoupling_activation_error hp θ φ hφ).trans ?_
  have hh := Finset.sum_le_sum (fun i (_ : i ∈ Finset.univ) =>
    add_le_add (hmean i) (hvariance i))
  simpa only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul] using hh

end GaussianLayerParameters

end NeuralGeneralization.RobustCompressionLayerGaussian
