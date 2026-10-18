import NeuralGeneralization.RobustEntropyChain
import Mathlib.Probability.Kernel.RadonNikodym
import Mathlib.Probability.Kernel.MeasurableLIntegral
import Mathlib.Probability.Kernel.CompProdEqIff

/-!
# Measurability of genuine conditional relative entropy

On countably generated output spaces, mathlib provides a jointly measurable
kernel Radon--Nikodym derivative. Combining it with the KL integrand gives
measurability of the actual extended-real KL, including singular conditional
laws (where its value is infinity).
-/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal ProbabilityTheory Classical

namespace NeuralGeneralization.RobustEntropy

variable {A Y : Type*} [MeasurableSpace A] [MeasurableSpace Y]
    [MeasurableSpace.CountableOrCountablyGenerated A Y]

/-- Jointly measurable density formula for finite-kernel KL. -/
theorem kernel_klDiv_eq (κ η : Kernel A Y) [IsFiniteKernel κ] [IsFiniteKernel η]
    (a : A) :
    klDiv (κ a) (η a) =
      if κ a ≪ η a then
        ∫⁻ y, ENNReal.ofReal (klFun (Kernel.rnDeriv κ η a y).toReal) ∂η a
      else ∞ := by
  by_cases hac : κ a ≪ η a
  · rw [if_pos hac, klDiv_eq_lintegral_klFun_of_ac hac]
    apply lintegral_congr_ae
    filter_upwards [Kernel.rnDeriv_eq_rnDeriv_measure (κ := κ) (η := η) (a := a)]
      with y hy
    rw [hy]
  · simp [hac, klDiv_of_not_ac hac]

/-- No finite-KL or absolute-continuity condition is needed for measurability. -/
theorem measurable_kernel_klDiv (κ η : Kernel A Y)
    [IsFiniteKernel κ] [IsFiniteKernel η] :
    Measurable (fun a => klDiv (κ a) (η a)) := by
  have hi : Measurable (fun a =>
      ∫⁻ y, ENNReal.ofReal (klFun (Kernel.rnDeriv κ η a y).toReal) ∂η a) := by
    apply Measurable.lintegral_kernel_prod_right
    exact ENNReal.measurable_ofReal.comp
      (continuous_klFun.measurable.comp (Kernel.measurable_rnDeriv κ η).ennreal_toReal)
  simpa only [kernel_klDiv_eq] using
    hi.ite (Kernel.measurableSet_absolutelyContinuous κ η) measurable_const

/-- The joint density of two kernels with the same first marginal is the
jointly measurable conditional density. -/
theorem rnDeriv_compProd_same_left (μ : Measure A) [IsFiniteMeasure μ]
    (κ η : Kernel A Y) [IsFiniteKernel κ] [IsFiniteKernel η]
    (hac : μ ⊗ₘ κ ≪ μ ⊗ₘ η) :
    (μ ⊗ₘ κ).rnDeriv (μ ⊗ₘ η) =ᵐ[μ ⊗ₘ η]
      (fun p => Kernel.rnDeriv κ η p.1 p.2) := by
  have hk : ∀ᵐ a ∂μ, κ a = η.withDensity (κ.rnDeriv η) a := by
    filter_upwards [hac.kernel_of_compProd] with a ha
    exact (Kernel.withDensity_rnDeriv_eq ha).symm
  have hj : μ ⊗ₘ κ =
      (μ ⊗ₘ η).withDensity (fun p => Kernel.rnDeriv κ η p.1 p.2) := by
    rw [Measure.compProd_congr hk, Measure.compProd_withDensity]
    exact Kernel.measurable_rnDeriv κ η
  rw [hj]
  exact Measure.rnDeriv_withDensity _ (Kernel.measurable_rnDeriv κ η)

/-- Integral conditional-KL chain rule. Unlike mathlib's general-space chain
rule, this form uses countably generated output spaces to ensure the actual
conditional KL is measurable. Both sides allow infinity. -/
theorem klDiv_compProd_same_left_eq_lintegral (μ : Measure A) [IsFiniteMeasure μ]
    (κ η : Kernel A Y) [IsFiniteKernel κ] [IsFiniteKernel η] :
    klDiv (μ ⊗ₘ κ) (μ ⊗ₘ η) = ∫⁻ a, klDiv (κ a) (η a) ∂μ := by
  by_cases hac : μ ⊗ₘ κ ≪ μ ⊗ₘ η
  · rw [klDiv_eq_lintegral_klFun_of_ac hac]
    calc
      (∫⁻ p, ENNReal.ofReal (klFun ((μ ⊗ₘ κ).rnDeriv (μ ⊗ₘ η) p).toReal)
          ∂μ ⊗ₘ η) =
          ∫⁻ p, ENNReal.ofReal (klFun (Kernel.rnDeriv κ η p.1 p.2).toReal)
          ∂μ ⊗ₘ η := by
        apply lintegral_congr_ae
        filter_upwards [rnDeriv_compProd_same_left μ κ η hac] with p hp
        rw [hp]
      _ = ∫⁻ a, ∫⁻ y, ENNReal.ofReal
          (klFun (Kernel.rnDeriv κ η a y).toReal) ∂η a ∂μ := by
        apply Measure.lintegral_compProd
        exact ENNReal.measurable_ofReal.comp
          (continuous_klFun.measurable.comp (Kernel.measurable_rnDeriv κ η).ennreal_toReal)
      _ = ∫⁻ a, klDiv (κ a) (η a) ∂μ := by
        apply lintegral_congr_ae
        filter_upwards [hac.kernel_of_compProd] with a ha
        rw [kernel_klDiv_eq, if_pos ha]
  · rw [klDiv_of_not_ac hac]
    symm
    by_contra hfinite
    have hgood := ae_lt_top (measurable_kernel_klDiv κ η) hfinite
    apply hac
    apply Measure.absolutelyContinuous_compProd_right_iff.mpr
    filter_upwards [hgood] with a ha
    exact (klDiv_ne_top_iff.mp ha.ne).1

end NeuralGeneralization.RobustEntropy
