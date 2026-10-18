import NeuralGeneralization.RobustCompressionGaussian
import NeuralGeneralization.RobustCompressionGluingKernel

/-! # Jointly measurable shared-noise Gaussian reconstruction -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped NNReal ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionGaussian

variable {A : Type*} [MeasurableSpace A]

def scalarGaussianKernel (a b : A → ℝ) (v w : A → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) : Kernel A (ℝ × ℝ) :=
  (Kernel.id ×ₖ Kernel.const A (gaussianReal 0 1)).map
    (fun p : A × ℝ =>
      (a p.1 + Real.sqrt (v p.1 : ℝ) * p.2,
        b p.1 + Real.sqrt (w p.1 : ℝ) * p.2))

instance scalarGaussianKernel_markov (a b : A → ℝ) (v w : A → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) :
    IsMarkovKernel (scalarGaussianKernel a b v w ha hb hv hw) := by
  unfold scalarGaussianKernel
  apply Kernel.IsMarkovKernel.map
  fun_prop

theorem scalarGaussianKernel_apply (a b : A → ℝ) (v w : A → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A) :
    scalarGaussianKernel a b v w ha hb hv hw θ =
      (scalarGaussianCoupling (a θ) (b θ) (v θ) (w θ)).joint := by
  rw [scalarGaussianKernel, Kernel.map_apply _ (by fun_prop),
    Kernel.prod_apply, Kernel.id_apply, Kernel.const_apply,
    Measure.dirac_prod, Measure.map_map (by fun_prop) measurable_prodMk_left]
  rfl

theorem scalarGaussianKernel_fst (a b : A → ℝ) (v w : A → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A) :
    (scalarGaussianKernel a b v w ha hb hv hw θ).map Prod.fst = gaussianReal (a θ) (v θ) := by
  rw [scalarGaussianKernel_apply]
  exact (scalarGaussianCoupling (a θ) (b θ) (v θ) (w θ)).left

theorem scalarGaussianKernel_snd (a b : A → ℝ) (v w : A → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A) :
    (scalarGaussianKernel a b v w ha hb hv hw θ).map Prod.snd = gaussianReal (b θ) (w θ) := by
  rw [scalarGaussianKernel_apply]
  exact (scalarGaussianCoupling (a θ) (b θ) (v θ) (w θ)).right

theorem scalarGaussianKernel_error (a b : A → ℝ) (v w : A → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A) :
    (∫ p : ℝ × ℝ, (p.1 - p.2) ^ 2 ∂scalarGaussianKernel a b v w ha hb hv hw θ) ≤
      (a θ - b θ) ^ 2 + |(v θ : ℝ) - w θ| := by
  rw [scalarGaussianKernel_apply]
  exact scalarGaussianCoupling_error (a θ) (b θ) (v θ) (w θ)

end NeuralGeneralization.RobustCompressionGaussian
