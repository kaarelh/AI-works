import NeuralGeneralization.RobustEntropyMoments
import Mathlib.MeasureTheory.Integral.Prod

/-! The entropy variational bound on a measurable support event. The exponential
moment is integrated only on that event, with no mass charged outside it. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped ENNReal
namespace NeuralGeneralization.RobustEntropyMoments

/-- A support-sensitive exponential change-of-measure inequality for actual
Mathlib relative entropy. -/
theorem integral_le_kl_add_on_support {Ω : Type*} [MeasurableSpace Ω]
    (Q G : Measure Ω) [IsProbabilityMeasure Q] [IsProbabilityMeasure G]
    (hKL : klDiv Q G ≠ ∞) (E : Set Ω) (hE : MeasurableSet E)
    (hsupport : ∀ᵐ x ∂Q, x ∈ E) (f : Ω → ℝ) (hf : Integrable f Q)
    (he : Integrable (E.indicator (fun x => Real.exp (f x))) G)
    (B : ℝ) (hB : (∫ x, E.indicator (fun x => Real.exp (f x)) x ∂G) ≤ Real.exp B) :
    (∫ x, f x ∂Q) ≤ (klDiv Q G).toReal + B := by
  obtain ⟨hac,hllr⟩ := klDiv_ne_top_iff.mp hKL
  have hk : Integrable (fun x => klFun (Q.rnDeriv G x).toReal) G :=
    (integrable_klFun_rnDeriv_iff hac).2 hllr
  have hshift : E.indicator (fun x => Real.exp (f x-B)) =
      fun x => Real.exp (-B)*E.indicator (fun x => Real.exp (f x)) x := by
    funext x
    by_cases hx : x ∈ E
    · simp only [Set.indicator_of_mem hx, Real.exp_sub, Real.exp_neg]
      ring
    · simp [hx]
  have he' : Integrable (E.indicator (fun x => Real.exp (f x-B))) G := by
    rw [hshift]
    exact he.const_mul _
  have hw : Integrable (fun x => (Q.rnDeriv G x).toReal*(f x-B)) G :=
    (integrable_toReal_rnDeriv_mul_iff hac).2 (hf.sub (integrable_const B))
  have hr := Measure.ae_rnDeriv_ne_zero_imp_of_ae G hsupport
  have hpoint : ∀ᵐ x ∂G, (Q.rnDeriv G x).toReal*(f x-B) ≤
      klFun (Q.rnDeriv G x).toReal+E.indicator (fun x => Real.exp (f x-B)) x-1 := by
    filter_upwards [hr] with x hx
    by_cases hxe : x ∈ E
    · simpa only [Set.indicator_of_mem hxe] using
        mul_le_klFun_add_exp (u := (Q.rnDeriv G x).toReal) ENNReal.toReal_nonneg (f x-B)
    · have hz : Q.rnDeriv G x = 0 := by by_contra hn; exact hxe (hx hn)
      simp [hz,hxe,klFun]
  have hh := integral_mono_ae hw ((hk.add he').sub (integrable_const 1)) hpoint
  have hchange : (∫ x,(Q.rnDeriv G x).toReal*(f x-B) ∂G) = (∫ x,f x ∂Q)-B := by
    rw [integral_toReal_rnDeriv_mul hac, integral_sub hf (integrable_const B)]
    simp
  have hexp : (∫ x,E.indicator (fun x => Real.exp (f x-B)) x ∂G) ≤ 1 := by
    rw [hshift, integral_const_mul]
    have ht := mul_le_mul_of_nonneg_left hB (Real.exp_pos (-B)).le
    have hid : Real.exp (-B)*Real.exp B = 1 := by rw [← Real.exp_add]; simp
    rwa [hid] at ht
  simp only [Pi.add_apply,Pi.sub_apply] at hh
  have hsum : Integrable (fun x => klFun (Q.rnDeriv G x).toReal + E.indicator (fun x => Real.exp (f x-B)) x) G := hk.add he'
  rw [hchange, integral_sub hsum (integrable_const 1), integral_add hk he',
    ← toReal_klDiv_eq_integral_klFun hac] at hh
  simp only [integral_const,probReal_univ,one_smul] at hh
  linarith

end NeuralGeneralization.RobustEntropyMoments
