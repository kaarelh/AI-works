import NeuralGeneralization.RobustEntropyActiveQueries
import NeuralGeneralization.RobustCouplingTwoScale
import Mathlib.Probability.Kernel.Disintegration.StandardBorel

/-! # Actual conditional residual kernels and their averaged entropy

The conditional kernel is mathlib's disintegration of the genuine joint query
law. The entropy budget is an identity, not a hypothesis about conditioning.
The external parameter may include the entire untouched future network.
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal ProbabilityTheory

namespace NeuralGeneralization.RobustEntropy

variable {A H V : Type*} [MeasurableSpace A] [MeasurableSpace H] [MeasurableSpace V]
    [StandardBorelSpace H] [StandardBorelSpace V] [Nonempty V]

/-- Entropy of the actual conditional residual, integrated over active data. -/
theorem conditional_residual_entropy_eq
    (ρ : Kernel A (H × V)) [IsMarkovKernel ρ]
    (G : Measure V) [IsProbabilityMeasure G] (a : A) :
    (∫⁻ h, klDiv (ρ.condKernel (a,h)) G ∂ρ.fst a) =
      klDiv (ρ a) ((ρ.fst a).prod G) := by
  have hh := klDiv_compProd_same_left_eq_lintegral (ρ.fst a)
    (Kernel.sectR ρ.condKernel a) (Kernel.const H G)
  rw [← Kernel.compProd_apply_eq_compProd_sectR, Kernel.disintegrate,
    Measure.compProd_const] at hh
  simpa only [Kernel.sectR_apply, Kernel.const_apply] using hh.symm

/-- Full averaged identity for the genuine joint law of external parameters
and active observations. All singular/infinite-KL fibers are included. -/
theorem averaged_conditional_residual_entropy_eq
    (μ : Measure A) [IsProbabilityMeasure μ]
    (ρ : Kernel A (H × V)) [IsMarkovKernel ρ]
    (G : Measure V) [IsProbabilityMeasure G] :
    (∫⁻ p, klDiv (ρ.condKernel p) G ∂μ ⊗ₘ ρ.fst) =
      ∫⁻ a, klDiv (ρ a) ((ρ.fst a).prod G) ∂μ := by
  have hm : Measurable (fun p : A × H => klDiv (ρ.condKernel p) G) :=
    measurable_kernel_klDiv ρ.condKernel (Kernel.const (A × H) G)
  rw [Measure.lintegral_compProd hm]
  exact lintegral_congr fun a => conditional_residual_entropy_eq ρ G a

/-- The Gaussian replacement theorem now consumes an entropy bound on the
actual exposed pair, rather than assuming a bound for a conditional kernel. -/
theorem queried_activation_replacement
    (μ : Measure A) [IsProbabilityMeasure μ] (n : ℕ)
    (ρ : Kernel A (H × (Fin n → ℝ))) [IsMarkovKernel ρ]
    {δ t : ℝ} (hδ : 0 < δ) (hδ1 : δ ≤ 1) (ht : 0 < t)
    (φ : ℝ → ℝ) (hφ : LipschitzWith 1 φ) (hφbound : ∀ z, |φ z| ≤ 1)
    (offset : A × H → Fin n → ℝ)
    (hoffset : ∀ i, Measurable (fun p => offset p i))
    (length : A × H → ℝ) (hlength : Measurable length)
    (hlength0 : ∀ p, 0 ≤ length p) (hlength1 : ∀ p, length p ≤ 1)
    (hcost : (∫⁻ a, klDiv (ρ a)
      ((ρ.fst a).prod (RobustCoupling.standardGaussianVector n)) ∂μ) ≤
      ENNReal.ofReal (n * δ ^ 3 / t ^ 2)) :
    (∫⁻ θ, ∫⁻ p, ENNReal.ofReal
      (∑ i, (φ (offset θ i + t * length θ * p.1 i) -
        φ (offset θ i + t * length θ * p.2 i)) ^ 2)
      ∂RobustCoupling.finiteCouplingKernel (gaussianReal 0 1) n ρ.condKernel θ
      ∂μ ⊗ₘ ρ.fst) ≤ ENNReal.ofReal (14*n*δ) := by
  apply RobustCoupling.finiteCouplingKernel_activation_replacement
    (μ ⊗ₘ ρ.fst) n ρ.condKernel hδ hδ1 ht φ hφ hφbound
    offset hoffset length hlength hlength0 hlength1
  rwa [averaged_conditional_residual_entropy_eq]

end NeuralGeneralization.RobustEntropy
