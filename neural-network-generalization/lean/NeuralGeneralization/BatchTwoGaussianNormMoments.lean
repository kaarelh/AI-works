import NeuralGeneralization.GaussianTail
import NeuralGeneralization.GaussianReadout
import Mathlib.MeasureTheory.Integral.Pi

/-!
# High moments of actual Gaussian vectors

The moment order is arbitrary. This is useful when it grows with width or
with inverse variance, rather than remaining fixed in a central limit limit.
The proof optimizes the exact square moment-generating function.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal

namespace NeuralGeneralization.GaussianNormMoments

theorem power_le_exponential (u A : ℝ) (hu : 0 ≤ u) (hA : 0 < A) (p : ℕ) :
    u^p ≤ A^p * Real.exp ((p : ℝ)*(u/A-1)) := by
  have hz : u/A ≤ Real.exp (u/A-1) := by
    linarith only [Real.add_one_le_exp (u/A-1)]
  have hp := pow_le_pow_left₀ (div_nonneg hu hA.le) hz p
  rw [div_pow, ← Real.exp_nat_mul] at hp
  exact (div_le_iff₀ (pow_pos hA p)).mp hp |>.trans_eq (mul_comm _ _)

theorem integral_power_le_of_exp {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) (u : Ω → ℝ) (hu : AEStronglyMeasurable u μ)
    (hu0 : ∀ᵐ x ∂μ, 0 ≤ u x) (A : ℝ) (hA : 0 < A) (p : ℕ)
    (hi : Integrable (fun x => Real.exp ((p : ℝ)*u x/A)) μ)
    (hb : (∫ x, Real.exp ((p : ℝ)*u x/A) ∂μ) ≤ Real.exp p) :
    Integrable (fun x => u x^p) μ ∧ (∫ x, u x^p ∂μ) ≤ A^p := by
  have hdom : ∀ᵐ x ∂μ, u x^p ≤
      A^p * Real.exp (-(p : ℝ)) * Real.exp ((p : ℝ)*u x/A) := by
    filter_upwards [hu0] with x hx
    have h := power_le_exponential (u x) A hx hA p
    have he : (p : ℝ)*(u x/A-1) = -(p : ℝ) + (p : ℝ)*u x/A := by ring
    simpa only [he,Real.exp_add,mul_assoc] using h
  have hI := hi.const_mul (A^p*Real.exp (-(p : ℝ)))
  have hpow : Integrable (fun x => u x^p) μ := hI.mono' (hu.pow p) (by
    filter_upwards [hdom,hu0] with x hx hx0
    simpa only [Real.norm_eq_abs,abs_of_nonneg (pow_nonneg hx0 p)] using hx)
  refine ⟨hpow,?_⟩
  calc
    _ ≤ ∫ x, A^p * Real.exp (-(p : ℝ)) * Real.exp ((p : ℝ)*u x/A) ∂μ :=
      integral_mono_ae hpow hI hdom
    _ = A^p * Real.exp (-(p : ℝ)) * (∫ x, Real.exp ((p : ℝ)*u x/A) ∂μ) :=
      integral_const_mul _ _
    _ ≤ A^p * Real.exp (-(p : ℝ)) * Real.exp p := by gcongr
    _ = A^p := by rw [mul_assoc,←Real.exp_add]; simp

theorem gaussian_norm_square_mgf {ι : Type*} [Fintype ι]
    (v : ℝ≥0) (s : ℝ) (hs : 0 < 1-2*s*(v : ℝ)) :
    (∫ x : ι → ℝ, Real.exp (s*∑ i, x i^2)
      ∂(Measure.pi fun _ => gaussianReal 0 v)) =
        (Real.sqrt (1-2*s*(v : ℝ)))⁻¹ ^ Fintype.card ι := by
  have hf : (fun x : ι → ℝ => Real.exp (s*∑ i, x i^2)) =
      fun x => ∏ i, Real.exp (s*x i^2) := by
    funext x
    rw [Finset.mul_sum,Real.exp_sum]
  rw [hf,integral_fintype_prod_eq_prod (μ := fun _ : ι => gaussianReal 0 v) (f := fun (_ : ι) (x : ℝ) => Real.exp (s*x^2))]
  simp only [GaussianTail.integral_exp_mul_sq_gaussianReal v s hs,
    Finset.prod_const,Finset.card_univ]

theorem gaussian_norm_square_mgf_integrable {ι : Type*} [Fintype ι]
    (v : ℝ≥0) (s : ℝ) (hs : 0 < 1-2*s*(v : ℝ)) :
    Integrable (fun x : ι → ℝ => Real.exp (s*∑ i, x i^2))
      (Measure.pi fun _ => gaussianReal 0 v) := by
  apply Integrable.of_integral_ne_zero
  rw [gaussian_norm_square_mgf v s hs]
  exact pow_ne_zero _ (inv_ne_zero (Real.sqrt_pos.mpr hs).ne')

theorem optimized_square_mgf_bound {m p : ℕ} (hm : 0 < m) (hp : 0 < p)
    (v : ℝ) (hv : 0 < v) :
    0 < 1-2*((p : ℝ)/(v*(m+2*p)))*v ∧
    (Real.sqrt (1-2*((p : ℝ)/(v*(m+2*p)))*v))⁻¹ ^ m ≤ Real.exp p := by
  have hmR : (0 : ℝ) < m := by exact_mod_cast hm
  have hpR : (0 : ℝ) < p := by exact_mod_cast hp
  have hden : (0 : ℝ) < m+2*p := by positivity
  have he : 1-2*((p : ℝ)/(v*(m+2*p)))*v = (m : ℝ)/(m+2*p) := by
    field_simp
    <;> ring
  have ha : 0 < 1-2*((p : ℝ)/(v*(m+2*p)))*v := by rw [he]; positivity
  refine ⟨ha,?_⟩
  apply (Real.log_le_iff_le_exp (pow_pos (inv_pos.mpr (Real.sqrt_pos.mpr ha)) m)).mp
  rw [Real.log_pow,Real.log_inv,Real.log_sqrt ha.le]
  have hlog := mul_le_mul_of_nonneg_left
    (Real.one_sub_inv_le_log_of_pos ha) hmR.le
  have hid : (m : ℝ)*((1-2*((p : ℝ)/(v*(m+2*p)))*v)⁻¹-1)=2*p := by
    rw [he]
    field_simp
    <;> ring
  nlinarith only [hlog,hid]

theorem gaussian_norm_power_bound_pos {ι : Type*} [Fintype ι]
    (hι : 0 < Fintype.card ι) (v : ℝ≥0) (hv : 0 < (v : ℝ))
    (p : ℕ) (hp : 0 < p) :
    Integrable (fun x : ι → ℝ => (∑ i, x i^2)^p)
      (Measure.pi fun _ => gaussianReal 0 v) ∧
    (∫ x : ι → ℝ, (∑ i, x i^2)^p ∂(Measure.pi fun _ => gaussianReal 0 v)) ≤
      ((v : ℝ)*(Fintype.card ι+2*p))^p := by
  have hh := optimized_square_mgf_bound hι hp (v : ℝ) hv
  apply integral_power_le_of_exp _ _
    ((show Continuous (fun x : ι → ℝ => ∑ i, x i^2) by fun_prop).aestronglyMeasurable)
    (Filter.Eventually.of_forall (by intro x; positivity))
    ((v : ℝ)*(Fintype.card ι+2*p)) (by positivity) p
  · convert gaussian_norm_square_mgf_integrable (ι := ι) v _ hh.1 using 1 <;>
      ext x <;> congr 1 <;> ring
  · have he : (fun x : ι → ℝ => Real.exp ((p : ℝ)*(∑ i, x i^2)/
        ((v : ℝ)*(Fintype.card ι+2*p)))) =
        fun x => Real.exp (((p : ℝ)/((v : ℝ)*(Fintype.card ι+2*p)))*(∑ i, x i^2)) := by
      funext x; congr 1; ring
    rw [he,gaussian_norm_square_mgf v _ hh.1]
    exact hh.2

/-- Uniform in dimension, variance, and moment order, including the zero
variance and empty-vector cases. -/
theorem gaussian_norm_power_bound {ι : Type*} [Fintype ι]
    (v : ℝ≥0) (p : ℕ) (hp : 0 < p) :
    Integrable (fun x : ι → ℝ => (∑ i, x i^2)^p)
      (Measure.pi fun _ => gaussianReal 0 v) ∧
    (∫ x : ι → ℝ, (∑ i, x i^2)^p ∂(Measure.pi fun _ => gaussianReal 0 v)) ≤
      ((v : ℝ)*(Fintype.card ι+2*p))^p := by
  classical
  by_cases hι : 0 < Fintype.card ι
  · by_cases hv : 0 < (v : ℝ)
    · exact gaussian_norm_power_bound_pos hι v hv p hp
    · have hv0 : v = 0 := by ext; simpa using le_antisymm (le_of_not_gt hv) v.coe_nonneg
      subst v
      have hz : ∀ᵐ x : ι → ℝ ∂(Measure.pi fun _ => gaussianReal 0 0), ∀ i, x i = 0 := by
        rw [Filter.eventually_all]
        intro i
        have h := measurePreserving_eval (fun _ : ι => gaussianReal 0 0) i
        exact ae_of_ae_map (p := fun t : ℝ => t=0) h.measurable.aemeasurable (by rw [h.map_eq]; simp)
      have he : (fun x : ι → ℝ => (∑ i, x i^2)^p) =ᵐ[Measure.pi fun _ => gaussianReal 0 0] 0 := by
        filter_upwards [hz] with x hx
        simp [hx,Nat.ne_of_gt hp]
      refine ⟨(integrable_const (0 : ℝ)).congr he.symm,?_⟩
      rw [integral_congr_ae he]
      simp [Nat.ne_of_gt hp]
  · haveI : IsEmpty ι := Fintype.card_eq_zero_iff.mp (Nat.eq_zero_of_not_pos hι)
    constructor
    · simpa [Nat.ne_of_gt hp] using (integrable_const (0 : ℝ) :
        Integrable (fun _ : ι → ℝ => (0 : ℝ)) (Measure.pi fun _ => gaussianReal 0 v))
    · simp only [Finset.univ_eq_empty,Finset.sum_empty,zero_pow (Nat.ne_of_gt hp),integral_zero]
      positivity

theorem gaussian_norm_power_lintegral {ι : Type*} [Fintype ι]
    (v : ℝ≥0) (p : ℕ) (hp : 0 < p) :
    (∫⁻ x : ι → ℝ, ENNReal.ofReal ((∑ i, x i^2)^p)
      ∂(Measure.pi fun _ => gaussianReal 0 v)) ≤
      ENNReal.ofReal (((v : ℝ)*(Fintype.card ι+2*p))^p) := by
  have h := gaussian_norm_power_bound (ι := ι) v p hp
  rw [←ofReal_integral_eq_lintegral_ofReal h.1
    (Filter.Eventually.of_forall (by intro x; positivity))]
  exact ENNReal.ofReal_le_ofReal h.2

theorem gaussian_scalar_power_lintegral (v : ℝ≥0) (p : ℕ) (hp : 0 < p) :
    (∫⁻ x : ℝ, ENNReal.ofReal ((x^2)^p) ∂gaussianReal 0 v) ≤
      ENNReal.ofReal (((v : ℝ)*(1+2*p))^p) := by
  have h := gaussian_norm_power_lintegral (ι := Fin 1) v p hp
  have he := (measurePreserving_eval (fun _ : Fin 1 => gaussianReal 0 v) 0).lintegral_comp
    (show Measurable (fun x : ℝ => ENNReal.ofReal ((x^2)^p)) by fun_prop)
  rw [←he]
  simpa only [Fin.sum_univ_one,Fintype.card_fin,Nat.cast_one,Function.eval] using h

theorem scalar_linear_power_lintegral {ι : Type*} [Fintype ι]
    (c : ι → ℝ) (v : ℝ≥0) (p : ℕ) (hp : 0 < p) :
    (∫⁻ a : ι → ℝ, ENNReal.ofReal (((∑ i, c i*a i)^2)^p)
      ∂(Measure.pi fun _ => gaussianReal 0 v)) ≤
      ENNReal.ofReal ((((v : ℝ)*∑ i, c i^2)*(1+2*p))^p) := by
  have h := gaussian_scalar_power_lintegral
    (((v : ℝ)*∑ i, c i^2).toNNReal) p hp
  rw [←GaussianReadout.scalar_linear_law c v,
    lintegral_map (show Measurable (fun t : ℝ => ENNReal.ofReal ((t^2)^p)) by fun_prop)
      (show Measurable (fun a : ι → ℝ => ∑ i, c i*a i) by fun_prop)] at h
  simpa only [Real.toNNReal_of_nonneg (show 0 ≤ (v : ℝ)*∑ i, c i^2 by positivity),NNReal.coe_mk] using h

#print axioms gaussian_norm_power_lintegral
#print axioms scalar_linear_power_lintegral

end NeuralGeneralization.GaussianNormMoments
