import NeuralGeneralization.BatchTwoNonGaussianCurvature
import Mathlib.MeasureTheory.Integral.Bochner.ContinuousLinearMap
import Mathlib.MeasureTheory.Measure.Haar.NormedSpace
import Mathlib.MeasureTheory.Integral.Pi

/-! Ordinary densities, reflection symmetry, and the finite-dimensional product
density of the actual non-Gaussian coordinate law. -/

noncomputable section
open MeasureTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian
namespace CoordinateLaw

def density (ν : CoordinateLaw) (x : ℝ) : ℝ :=
  Real.exp (-ν.potential x) / ν.normalizer

theorem density_pos (ν : CoordinateLaw) (x : ℝ) : 0 < ν.density x :=
  div_pos (Real.exp_pos _) ν.normalizer_pos

theorem density_nonneg (ν : CoordinateLaw) (x : ℝ) : 0 ≤ ν.density x :=
  (ν.density_pos x).le

@[fun_prop] theorem continuous_density (ν : CoordinateLaw) : Continuous ν.density :=
  (Real.continuous_exp.comp ν.smooth.continuous.neg).div_const _

@[fun_prop] theorem measurable_density (ν : CoordinateLaw) : Measurable ν.density :=
  ν.continuous_density.measurable

theorem integrable_density (ν : CoordinateLaw) : Integrable ν.density :=
  ν.integrable_exp_potential.div_const _

theorem law_eq_withDensity (ν : CoordinateLaw) :
    ν.law = volume.withDensity (fun x => ENNReal.ofReal (ν.density x)) :=
  ν.density_eq

theorem integral_eq_density (ν : CoordinateLaw) (f : ℝ → ℝ) :
    (∫ x, f x ∂ν.law) = ∫ x, ν.density x * f x := by
  rw [ν.law_eq_withDensity,
    integral_withDensity_eq_integral_toReal_smul ν.measurable_density.ennreal_ofReal
      (ae_of_all _ (fun _ => ENNReal.ofReal_lt_top))]
  simp only [ENNReal.toReal_ofReal (ν.density_nonneg _), smul_eq_mul]

theorem integrable_iff_density (ν : CoordinateLaw) (f : ℝ → ℝ) :
    Integrable f ν.law ↔ Integrable (fun x => ν.density x * f x) := by
  rw [ν.law_eq_withDensity,
    integrable_withDensity_iff_integrable_smul' ν.measurable_density.ennreal_ofReal
      (ae_of_all _ (fun _ => ENNReal.ofReal_lt_top))]
  simp only [ENNReal.toReal_ofReal (ν.density_nonneg _), smul_eq_mul]

@[simp] theorem density_neg (ν : CoordinateLaw) (x : ℝ) : ν.density (-x) = ν.density x := by
  simp [density, ν.even x]

theorem integral_reflection (ν : CoordinateLaw) (f : ℝ → ℝ) :
    (∫ x, f (-x) ∂ν.law) = ∫ x, f x ∂ν.law := by
  rw [ν.integral_eq_density, ν.integral_eq_density]
  have h := integral_neg_eq_self (fun x => ν.density x * f x) (μ := volume)
  simpa only [ν.density_neg] using h

theorem integral_eq_zero_of_odd (ν : CoordinateLaw) {f : ℝ → ℝ}
    (hf : Function.Odd f) : (∫ x, f x ∂ν.law) = 0 := by
  have h := ν.integral_reflection f
  have heq : (fun x => f (-x)) = fun x => -f x := funext hf
  rw [heq, integral_neg] at h
  linarith

@[simp] theorem integral_id (ν : CoordinateLaw) : (∫ x : ℝ, x ∂ν.law) = 0 :=
  ν.integral_eq_zero_of_odd (fun _ => rfl)

theorem integral_density (ν : CoordinateLaw) : (∫ x, ν.density x) = 1 := by
  have h := ν.integral_eq_density (fun _ => 1)
  simpa using h.symm

theorem measure_eq_integral (ν : CoordinateLaw) (s : Set ℝ) (hs : MeasurableSet s) :
    ν.law s = ENNReal.ofReal (∫ x in s, ν.density x) := by
  rw [ν.law_eq_withDensity, withDensity_apply _ hs]
  exact (ofReal_integral_eq_lintegral_ofReal ν.integrable_density.restrict
    (ae_of_all _ ν.density_nonneg)).symm

section Product
variable {I : Type*} [Fintype I]

def productDensity (ν : CoordinateLaw) (x : I → ℝ) : ℝ := ∏ i, ν.density (x i)

theorem productDensity_nonneg (ν : CoordinateLaw) (x : I → ℝ) :
    0 ≤ ν.productDensity x :=
  Finset.prod_nonneg (fun i _ => ν.density_nonneg _)

@[fun_prop] theorem measurable_productDensity (ν : CoordinateLaw) :
    Measurable (ν.productDensity : (I → ℝ) → ℝ) := by
  unfold productDensity
  exact Finset.measurable_prod _ (fun i _ => ν.measurable_density.comp (measurable_pi_apply i))

theorem integrable_productDensity (ν : CoordinateLaw) :
    Integrable (ν.productDensity : (I → ℝ) → ℝ) :=
  Integrable.fintype_prod (fun _ => ν.integrable_density)

theorem product_eq_withDensity (ν : CoordinateLaw) :
    (Measure.pi fun _ : I => ν.law) =
      (volume : Measure (I → ℝ)).withDensity (fun x => ENNReal.ofReal (ν.productDensity x)) := by
  apply Measure.pi_eq
  intro s hs
  rw [withDensity_apply _ (MeasurableSet.univ_pi hs)]
  rw [← ofReal_integral_eq_lintegral_ofReal ν.integrable_productDensity.restrict
    (ae_of_all _ ν.productDensity_nonneg)]
  change ENNReal.ofReal (∫ x, ν.productDensity x
    ∂(Measure.pi fun _ : I => (volume : Measure ℝ)).restrict (Set.univ.pi s)) = _
  rw [Measure.restrict_pi_pi]
  change ENNReal.ofReal (∫ x, ∏ i, ν.density (x i)
    ∂Measure.pi fun i => (volume : Measure ℝ).restrict (s i)) = _
  rw [integral_fintype_prod_eq_prod]
  simp_rw [ν.measure_eq_integral _ (hs _)]
  exact ENNReal.ofReal_prod_of_nonneg (fun i _ => integral_nonneg ν.density_nonneg)

theorem integral_product_eq_density (ν : CoordinateLaw) (f : (I → ℝ) → ℝ) :
    (∫ x, f x ∂Measure.pi (fun _ : I => ν.law)) = ∫ x, ν.productDensity x * f x := by
  rw [ν.product_eq_withDensity,
    integral_withDensity_eq_integral_toReal_smul ν.measurable_productDensity.ennreal_ofReal
      (ae_of_all _ (fun _ => ENNReal.ofReal_lt_top))]
  simp only [ENNReal.toReal_ofReal (ν.productDensity_nonneg _), smul_eq_mul]

theorem productDensity_exp (ν : CoordinateLaw) (x : I → ℝ) :
    ν.productDensity x = ν.normalizer⁻¹ ^ Fintype.card I *
      Real.exp (-(∑ i, ν.potential (x i))) := by
  simp only [productDensity, density, div_eq_mul_inv]
  rw [Finset.prod_mul_distrib, ← Real.exp_sum]
  simp only [Finset.prod_const, Finset.card_univ, Finset.sum_neg_distrib]
  ring

@[simp] theorem productDensity_neg (ν : CoordinateLaw) (x : I → ℝ) :
    ν.productDensity (-x) = ν.productDensity x := by
  simp [productDensity]

end Product
end CoordinateLaw
end NeuralGeneralization.BatchTwoNonGaussian
