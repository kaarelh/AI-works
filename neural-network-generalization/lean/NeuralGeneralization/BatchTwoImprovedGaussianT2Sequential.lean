import NeuralGeneralization.BatchTwoImprovedGaussianT2
import NeuralGeneralization.RobustCouplingSequential

/-! # Sequential tensorization of sharp Gaussian transport -/
noncomputable section
open MeasureTheory ProbabilityTheory Set InformationTheory
open scoped ENNReal ProbabilityTheory
namespace NeuralGeneralization.BatchTwoImprovedGaussianTransport
open BatchTwoImprovedQuantile
variable {A B : Type*} [MeasurableSpace A] [MeasurableSpace B]

variable (π : Measure (A × B)) [IsProbabilityMeasure π]
  (κ : Kernel A ℝ) [IsMarkovKernel κ] (G : Measure ℝ) [IsProbabilityMeasure G]

def appendCoupling : Measure ((A × ℝ) × (B × ℝ)) :=
  (π ⊗ₘ ((quantileCouplingKernel κ (Kernel.const A G)).comap Prod.fst measurable_fst)).map
    (fun p => ((p.1.1, p.2.1), (p.1.2, p.2.2)))

instance appendCoupling_isProbability : IsProbabilityMeasure (appendCoupling π κ G) := by
  unfold appendCoupling
  apply Measure.isProbabilityMeasure_map
  fun_prop

theorem appendCoupling_fst :
    (appendCoupling π κ G).map Prod.fst = (π.map Prod.fst) ⊗ₘ κ := by
  have hm : Measurable (fun p : (A × B) × (ℝ × ℝ) =>
      ((p.1.1, p.2.1), (p.1.2, p.2.2))) := by fun_prop
  rw [appendCoupling, Measure.map_map measurable_fst hm]
  exact RobustCoupling.map_compProd_pair π
    ((quantileCouplingKernel κ (Kernel.const A G)).comap Prod.fst measurable_fst)
    κ Prod.fst Prod.fst measurable_fst measurable_fst
    (fun p => quantileCouplingKernel_fst κ (Kernel.const A G) p.1)

theorem appendCoupling_snd :
    (appendCoupling π κ G).map Prod.snd = (π.map Prod.snd).prod G := by
  have hm : Measurable (fun p : (A × B) × (ℝ × ℝ) =>
      ((p.1.1, p.2.1), (p.1.2, p.2.2))) := by fun_prop
  rw [appendCoupling, Measure.map_map measurable_snd hm, ← Measure.compProd_const]
  exact RobustCoupling.map_compProd_pair π
    ((quantileCouplingKernel κ (Kernel.const A G)).comap Prod.fst measurable_fst)
    (Kernel.const B G) Prod.snd Prod.snd measurable_snd measurable_snd
    (fun p => quantileCouplingKernel_snd κ (Kernel.const A G) p.1)

variable {Θ : Type*} [MeasurableSpace Θ]

/-- Measurable family version of one-coordinate coupling extension. -/
def appendCouplingKernel (piK : Kernel Θ (A × B)) [IsMarkovKernel piK]
    (κ : Kernel (Θ × A) ℝ) [IsMarkovKernel κ]
    (G : Measure ℝ) [IsProbabilityMeasure G] : Kernel Θ ((A × ℝ) × (B × ℝ)) :=
  (piK ⊗ₖ ((quantileCouplingKernel κ (Kernel.const (Θ × A) G)).comap
    (fun p : Θ × (A × B) => (p.1, p.2.1)) (by fun_prop))).map
    (fun p => ((p.1.1, p.2.1), (p.1.2, p.2.2)))

instance appendCouplingKernel_markov (piK : Kernel Θ (A × B)) [IsMarkovKernel piK]
    (κ : Kernel (Θ × A) ℝ) [IsMarkovKernel κ]
    (G : Measure ℝ) [IsProbabilityMeasure G] :
    IsMarkovKernel (appendCouplingKernel piK κ G) := by
  unfold appendCouplingKernel
  apply Kernel.IsMarkovKernel.map
  fun_prop

theorem appendCouplingKernel_apply (piK : Kernel Θ (A × B)) [IsMarkovKernel piK]
    (κ : Kernel (Θ × A) ℝ) [IsMarkovKernel κ]
    (G : Measure ℝ) [IsProbabilityMeasure G] (θ : Θ) :
    appendCouplingKernel piK κ G θ = appendCoupling (piK θ) (κ.sectR θ) G := by
  rw [appendCouplingKernel, Kernel.map_apply _ (by fun_prop),
    Kernel.compProd_apply_eq_compProd_sectR]
  unfold appendCoupling
  congr 2
  ext p
  simp only [Kernel.sectR_apply, Kernel.comap_apply, quantileCouplingKernel_apply,
    Kernel.const_apply]

/-- The squared cost added by a fresh coordinate is charged directly to twice
its conditional entropy, with no dependence on dimension or error tolerance. -/
theorem lintegral_appendCoupling_cost_le
    (F : A × B → ℝ≥0∞) (hF : Measurable F) :
    (∫⁻ p, F (p.1.1, p.2.1) + scalarSquaredCost (p.1.2, p.2.2)
      ∂appendCoupling π κ (gaussianReal 0 1)) ≤
      (∫⁻ p, F p ∂π) + 2 *
        (∫⁻ a, klDiv (κ a) (gaussianReal 0 1) ∂π.map Prod.fst) := by
  have hm : Measurable (fun p : (A × B) × (ℝ × ℝ) =>
      ((p.1.1, p.2.1), (p.1.2, p.2.2))) := by fun_prop
  rw [appendCoupling, lintegral_map (by fun_prop) hm,
    Measure.lintegral_compProd (by fun_prop)]
  simp only [Kernel.comap_apply]
  simp only [lintegral_add_left measurable_const, lintegral_const, measure_univ, mul_one]
  have hmeas : Measurable (fun a => klDiv (κ a) (gaussianReal 0 1)) :=
    NeuralGeneralization.RobustEntropy.measurable_kernel_klDiv κ
      (Kernel.const A (gaussianReal 0 1))
  have hmeas2 : Measurable (fun p : A × B => klDiv (κ p.1) (gaussianReal 0 1)) :=
    hmeas.comp measurable_fst
  calc
    _ ≤ ∫⁻ p, F p + 2 * klDiv (κ p.1) (gaussianReal 0 1) ∂π := by
      apply lintegral_mono
      intro p
      exact add_le_add le_rfl (quantileCouplingKernel_gaussian_cost_le κ p.1)
    _ = _ := by
      rw [lintegral_add_left hF, lintegral_const_mul _ hmeas2,
        lintegral_map hmeas measurable_fst]

end NeuralGeneralization.BatchTwoImprovedGaussianTransport
