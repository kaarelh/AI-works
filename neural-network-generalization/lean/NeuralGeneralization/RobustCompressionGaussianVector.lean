import NeuralGeneralization.RobustCompressionGaussianKernel
import NeuralGeneralization.GaussianConeRadial

/-! # Shared-noise coupling of complete Gaussian evaluation vectors -/

noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal ProbabilityTheory

namespace NeuralGeneralization.RobustCompressionGaussian

variable {I : Type*} [Fintype I]

theorem standard_gaussian_vector_affine_map (a : I → ℝ) (v : I → ℝ≥0) :
    (Measure.pi (fun _ : I => gaussianReal 0 1)).map
      (fun z i => a i + Real.sqrt (v i : ℝ) * z i) =
        Measure.pi (fun i => gaussianReal (a i) (v i)) := by
  rw [Measure.pi_map_pi (f := fun i (z : ℝ) => a i + Real.sqrt (v i : ℝ) * z)
    (fun i => by fun_prop)]
  congr 1
  funext i
  exact standard_gaussian_affine_map (a i) (v i)

def vectorGaussianCoupling (a b : I → ℝ) (v w : I → ℝ≥0) :
    RobustStatistics.ProbabilityCoupling
      (Measure.pi (fun i => gaussianReal (a i) (v i)))
      (Measure.pi (fun i => gaussianReal (b i) (w i))) where
  joint := (Measure.pi (fun _ : I => gaussianReal 0 1)).map
    (fun z => ((fun i => a i + Real.sqrt (v i : ℝ) * z i),
      (fun i => b i + Real.sqrt (w i : ℝ) * z i)))
  probability := Measure.isProbabilityMeasure_map (by fun_prop)
  left := by
    rw [Measure.map_map measurable_fst (by fun_prop)]
    exact standard_gaussian_vector_affine_map a v
  right := by
    rw [Measure.map_map measurable_snd (by fun_prop)]
    exact standard_gaussian_vector_affine_map b w

theorem gaussian_affine_difference_integrable (a b v w : ℝ) :
    Integrable (fun z : ℝ => ((a + Real.sqrt v * z) - (b + Real.sqrt w * z)) ^ 2)
      (gaussianReal 0 1) := by
  have h₁ : Integrable (fun z : ℝ => z) (gaussianReal 0 1) := by
    simpa using gaussian_power_integrable 0 1 1
  have h₂ := gaussian_power_integrable 0 1 2
  have heq : (fun z : ℝ => ((a + Real.sqrt v * z) - (b + Real.sqrt w * z)) ^ 2) =
      (fun z => (a - b) ^ 2 + (2 * (a - b) * (Real.sqrt v - Real.sqrt w)) * z +
        (Real.sqrt v - Real.sqrt w) ^ 2 * z ^ 2) := by
    funext z
    ring
  rw [heq]
  exact ((integrable_const ((a - b) ^ 2)).add
    (h₁.const_mul (2 * (a - b) * (Real.sqrt v - Real.sqrt w)))).add
      (h₂.const_mul ((Real.sqrt v - Real.sqrt w) ^ 2))

theorem vectorGaussianCoupling_error (a b : I → ℝ) (v w : I → ℝ≥0) :
    (∫ p : (I → ℝ) × (I → ℝ), ∑ i, (p.1 i - p.2 i) ^ 2
      ∂(vectorGaussianCoupling a b v w).joint) ≤
        ∑ i, ((a i - b i) ^ 2 + |(v i : ℝ) - w i|) := by
  change (∫ p : (I → ℝ) × (I → ℝ), ∑ i, (p.1 i - p.2 i) ^ 2
    ∂(Measure.pi (fun _ : I => gaussianReal 0 1)).map _) ≤ _
  rw [integral_map (by fun_prop) (by fun_prop)]
  rw [integral_finsetSum Finset.univ (fun i _ =>
    integrable_comp_eval (μ := fun _ : I => gaussianReal 0 1) (i := i)
      (gaussian_affine_difference_integrable (a i) (b i) (v i) (w i)))]
  apply Finset.sum_le_sum
  intro i hi
  rw [integral_comp_eval (μ := fun _ : I => gaussianReal 0 1) (i := i)
    (f := fun z : ℝ => ((a i + Real.sqrt (v i : ℝ) * z) -
      (b i + Real.sqrt (w i : ℝ) * z)) ^ 2) (by fun_prop)]
  exact scalar_gaussian_reconstruction_bound (a i) (b i) (v i).coe_nonneg (w i).coe_nonneg

theorem vectorGaussianCoupling_error_integrable (a b : I → ℝ) (v w : I → ℝ≥0) :
    Integrable (fun p : (I → ℝ) × (I → ℝ) => ∑ i, (p.1 i - p.2 i) ^ 2)
      (vectorGaussianCoupling a b v w).joint := by
  change Integrable _ ((Measure.pi (fun _ : I => gaussianReal 0 1)).map _)
  apply (integrable_map_measure (by fun_prop) (by fun_prop)).mpr
  exact integrable_finsetSum _ (fun i _ =>
    integrable_comp_eval (μ := fun _ : I => gaussianReal 0 1) (i := i)
      (gaussian_affine_difference_integrable (a i) (b i) (v i) (w i)))

theorem vectorGaussianCoupling_activation_error (a b : I → ℝ) (v w : I → ℝ≥0)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) :
    (∫ p : (I → ℝ) × (I → ℝ), ∑ i, (φ (p.1 i) - φ (p.2 i)) ^ 2
      ∂(vectorGaussianCoupling a b v w).joint) ≤
        ∑ i, ((a i - b i) ^ 2 + |(v i : ℝ) - w i|) := by
  have hpoint (p : (I → ℝ) × (I → ℝ)) :
      (∑ i, (φ (p.1 i) - φ (p.2 i)) ^ 2) ≤ ∑ i, (p.1 i - p.2 i) ^ 2 := by
    apply Finset.sum_le_sum
    intro i hi
    have hh := hφ.dist_le_mul (p.1 i) (p.2 i)
    simp only [Real.dist_eq, NNReal.coe_one, one_mul] at hh
    exact (sq_le_sq).mpr hh
  have hright := vectorGaussianCoupling_error_integrable a b v w
  have hm : Measurable (fun p : (I → ℝ) × (I → ℝ) =>
      ∑ i, (φ (p.1 i) - φ (p.2 i)) ^ 2) := by
    have hφm := hφ.continuous.measurable
    fun_prop
  have hleft := hright.mono' hm.aestronglyMeasurable
    (Filter.Eventually.of_forall (fun p => by
      rw [Real.norm_eq_abs, abs_of_nonneg (Finset.sum_nonneg (fun i _ => sq_nonneg _))]
      exact hpoint p))
  exact (integral_mono hleft hright hpoint).trans (vectorGaussianCoupling_error a b v w)

variable {A : Type*} [MeasurableSpace A]

def vectorGaussianKernel (a b : A → I → ℝ) (v w : A → I → ℝ≥0)
    (_ha : Measurable a) (_hb : Measurable b)
    (_hv : Measurable v) (_hw : Measurable w) : Kernel A ((I → ℝ) × (I → ℝ)) :=
  (Kernel.id ×ₖ Kernel.const A (Measure.pi (fun _ : I => gaussianReal 0 1))).map
    (fun p : A × (I → ℝ) =>
      ((fun i => a p.1 i + Real.sqrt (v p.1 i : ℝ) * p.2 i),
        (fun i => b p.1 i + Real.sqrt (w p.1 i : ℝ) * p.2 i)))

instance vectorGaussianKernel_markov (a b : A → I → ℝ) (v w : A → I → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) :
    IsMarkovKernel (vectorGaussianKernel a b v w ha hb hv hw) := by
  unfold vectorGaussianKernel
  apply Kernel.IsMarkovKernel.map
  fun_prop

theorem vectorGaussianKernel_apply (a b : A → I → ℝ) (v w : A → I → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A) :
    vectorGaussianKernel a b v w ha hb hv hw θ =
      (vectorGaussianCoupling (a θ) (b θ) (v θ) (w θ)).joint := by
  rw [vectorGaussianKernel, Kernel.map_apply _ (by fun_prop),
    Kernel.prod_apply, Kernel.id_apply, Kernel.const_apply,
    Measure.dirac_prod, Measure.map_map (by fun_prop) measurable_prodMk_left]
  rfl

theorem vectorGaussianKernel_fst (a b : A → I → ℝ) (v w : A → I → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A) :
    (vectorGaussianKernel a b v w ha hb hv hw θ).map Prod.fst =
      Measure.pi (fun i => gaussianReal (a θ i) (v θ i)) := by
  rw [vectorGaussianKernel_apply]
  exact (vectorGaussianCoupling (a θ) (b θ) (v θ) (w θ)).left

theorem vectorGaussianKernel_snd (a b : A → I → ℝ) (v w : A → I → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A) :
    (vectorGaussianKernel a b v w ha hb hv hw θ).map Prod.snd =
      Measure.pi (fun i => gaussianReal (b θ i) (w θ i)) := by
  rw [vectorGaussianKernel_apply]
  exact (vectorGaussianCoupling (a θ) (b θ) (v θ) (w θ)).right

theorem vectorGaussianKernel_error (a b : A → I → ℝ) (v w : A → I → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A) :
    (∫ p : (I → ℝ) × (I → ℝ), ∑ i, (p.1 i - p.2 i) ^ 2
      ∂vectorGaussianKernel a b v w ha hb hv hw θ) ≤
        ∑ i, ((a θ i - b θ i) ^ 2 + |(v θ i : ℝ) - w θ i|) := by
  rw [vectorGaussianKernel_apply]
  exact vectorGaussianCoupling_error (a θ) (b θ) (v θ) (w θ)

theorem vectorGaussianKernel_activation_error (a b : A → I → ℝ) (v w : A → I → ℝ≥0)
    (ha : Measurable a) (hb : Measurable b)
    (hv : Measurable v) (hw : Measurable w) (θ : A)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) :
    (∫ p : (I → ℝ) × (I → ℝ), ∑ i, (φ (p.1 i) - φ (p.2 i)) ^ 2
      ∂vectorGaussianKernel a b v w ha hb hv hw θ) ≤
        ∑ i, ((a θ i - b θ i) ^ 2 + |(v θ i : ℝ) - w θ i|) := by
  rw [vectorGaussianKernel_apply]
  exact vectorGaussianCoupling_activation_error (a θ) (b θ) (v θ) (w θ) φ hφ

end NeuralGeneralization.RobustCompressionGaussian
