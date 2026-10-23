import NeuralGeneralization.BatchTwoNonGaussianDensity
import Mathlib.MeasureTheory.Integral.Bochner.Set
import Mathlib.MeasureTheory.Group.Integral

/-! The exact translation estimate for every symmetric measurable event of the
actual finite product prior.  The proof averages opposite translates of the
density, so neither relative entropy nor a concentration assumption is needed. -/

noncomputable section
open MeasureTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoNonGaussian

private theorem opposite_exp_lower {p q c b k : ℝ}
    (hp : p ≤ c + b + k) (hq : q ≤ c - b + k) :
    2 * Real.exp (-k) * Real.exp (-c) ≤ Real.exp (-p) + Real.exp (-q) := by
  have h1 : Real.exp (-c - k) * Real.exp (-b) ≤ Real.exp (-p) := by
    rw [← Real.exp_add]
    apply Real.exp_le_exp.mpr
    linarith
  have h2 : Real.exp (-c - k) * Real.exp b ≤ Real.exp (-q) := by
    rw [← Real.exp_add]
    apply Real.exp_le_exp.mpr
    linarith
  have hs : 2 ≤ Real.exp (-b) + Real.exp b := by
    linarith [Real.add_one_le_exp b, Real.add_one_le_exp (-b)]
  have hm := mul_le_mul_of_nonneg_left hs (Real.exp_nonneg (-c - k))
  have he : Real.exp (-c - k) = Real.exp (-k) * Real.exp (-c) := by
    rw [← Real.exp_add]
    congr 1
    ring
  rw [he] at h1 h2 hm
  nlinarith

namespace CoordinateLaw
variable {I : Type*} [Fintype I]

/-- Dimension-free symmetrized density estimate, before integrating any event. -/
theorem paired_productDensity_lower (ν : CoordinateLaw) (x a : I → ℝ) :
    2 * Real.exp (-(ν.upperCurvature / 2 * ∑ i, (a i) ^ 2)) * ν.productDensity x ≤
      ν.productDensity (x + a) + ν.productDensity (x - a) := by
  have hp : (∑ i, ν.potential ((x + a) i)) ≤
      (∑ i, ν.potential (x i)) + (∑ i, a i * deriv ν.potential (x i)) +
        ν.upperCurvature / 2 * ∑ i, (a i) ^ 2 := by
    have h := Finset.sum_le_sum (s := Finset.univ)
      (fun i _ => ν.translated_potential_upper (x i) (a i))
    simp only [Finset.sum_sub_distrib, Finset.sum_add_distrib, ← Finset.mul_sum] at h
    simp only [Pi.add_apply]
    linarith
  have hq : (∑ i, ν.potential ((x - a) i)) ≤
      (∑ i, ν.potential (x i)) - (∑ i, a i * deriv ν.potential (x i)) +
        ν.upperCurvature / 2 * ∑ i, (a i) ^ 2 := by
    have h := Finset.sum_le_sum (s := Finset.univ)
      (fun i _ => ν.translated_potential_upper (x i) (-a i))
    simp only [neg_mul, neg_sq, Finset.sum_sub_distrib, Finset.sum_add_distrib,
      Finset.sum_neg_distrib, ← Finset.mul_sum, ← sub_eq_add_neg] at h
    simp only [Pi.sub_apply]
    linarith
  have h := mul_le_mul_of_nonneg_left (opposite_exp_lower hp hq)
    (pow_nonneg (inv_nonneg.mpr ν.normalizer_pos.le) (Fintype.card I))
  rw [ν.productDensity_exp x, ν.productDensity_exp (x + a), ν.productDensity_exp (x - a)]
  nlinarith

theorem product_real_eq_integral (ν : CoordinateLaw) (E : Set (I → ℝ))
    (hE : MeasurableSet E) :
    (Measure.pi fun _ : I => ν.law).real E = ∫ x in E, ν.productDensity x := by
  rw [measureReal_def, ν.product_eq_withDensity, withDensity_apply _ hE,
    ← ofReal_integral_eq_lintegral_ofReal ν.integrable_productDensity.restrict
      (ae_of_all _ ν.productDensity_nonneg),
    ENNReal.toReal_ofReal (integral_nonneg ν.productDensity_nonneg)]

/-- Translating a symmetric event costs at most the upper-curvature quadratic
energy, exactly as in the paper's Lemma 3.1. -/
theorem symmetric_event_translation (ν : CoordinateLaw) (E : Set (I → ℝ))
    (hE : MeasurableSet E) (hsym : ∀ x, -x ∈ E ↔ x ∈ E) (a : I → ℝ) :
    (Measure.pi fun _ : I => ν.law).real E *
        Real.exp (-(ν.upperCurvature / 2 * ∑ i, (a i) ^ 2)) ≤
      (Measure.pi fun _ : I => ν.law).real {x | x - a ∈ E} := by
  have htrans : MeasurableSet {x : I → ℝ | x - a ∈ E} :=
    hE.preimage (by fun_prop)
  rw [ν.product_real_eq_integral E hE, ν.product_real_eq_integral _ htrans]
  have hiPlus := (ν.integrable_productDensity.comp_add_right a).restrict (s := E)
  have hiMinus := (ν.integrable_productDensity.comp_sub_right a).restrict (s := E)
  have hiOrig := ν.integrable_productDensity.restrict (s := E)
  have hpoint := integral_mono
    (hiOrig.const_mul (2 * Real.exp (-(ν.upperCurvature / 2 * ∑ i, (a i) ^ 2))))
    (hiPlus.add hiMinus) (fun x => ν.paired_productDensity_lower x a)
  simp only [Pi.add_apply] at hpoint
  rw [integral_add hiPlus hiMinus, integral_const_mul] at hpoint
  have hreflect : (∫ x in E, ν.productDensity (x - a)) =
      ∫ x in E, ν.productDensity (x + a) := by
    have h := (Measure.measurePreserving_neg (volume : Measure (I → ℝ))).setIntegral_preimage_emb
      (MeasurableEquiv.neg (I → ℝ)).measurableEmbedding
      (fun x => ν.productDensity (x - a)) E
    have hpre : (fun x : I → ℝ => -x) ⁻¹' E = E := Set.ext hsym
    rw [hpre] at h
    have heq : (fun x : I → ℝ => ν.productDensity (-x - a)) =
        fun x => ν.productDensity (x + a) := by
      funext x
      rw [show -x - a = -(x + a) by abel, ν.productDensity_neg]
    simpa only [heq] using h.symm
  have hshift : (∫ x in {x | x - a ∈ E}, ν.productDensity x) =
      ∫ x in E, ν.productDensity (x + a) := by
    have h := (measurePreserving_add_right (volume : Measure (I → ℝ)) a).setIntegral_preimage_emb
      (MeasurableEquiv.addRight a).measurableEmbedding ν.productDensity {x | x - a ∈ E}
    simpa only [Set.preimage_setOf_eq, add_sub_cancel_right, Set.setOf_mem_eq] using h.symm
  rw [hreflect] at hpoint
  rw [hshift]
  nlinarith

end CoordinateLaw
end NeuralGeneralization.BatchTwoNonGaussian
