import NeuralGeneralization.OnlineLowerReluWalshIntegral
import Mathlib.Analysis.SpecialFunctions.Gamma.Basic
import Mathlib.MeasureTheory.Integral.Prod

/-!
# Numerical normalization of the ReLU Fourier representation

This closes the remaining numerical-integral exclusion in the ReLU paper's
coverage audit. The existing full-line normalizer is exactly `Real.pi`.
The proof averages the absolutely integrable cosine kernel against
`exp (-s)` on the positive half-line, applies Fubini, and evaluates the
reversed integral as the Cauchy kernel. Evenness then gives the paper's
literal half-line formulas, including its `1 / pi` Walsh prefactor.
-/

noncomputable section
namespace NeuralGeneralization.OnlineLowerRelu
open MeasureTheory Set

/-- The exponential average of a cosine is the Cauchy kernel. -/
theorem integral_exp_neg_mul_cos (t : ℝ) :
    (∫ s : ℝ in Ioi 0, Real.exp (-s) * Real.cos (t * s)) = (1 + t ^ 2)⁻¹ := by
  let a : ℂ := -1 + t * Complex.I
  have ha : a.re < 0 := by simp [a]
  have hr (s : ℝ) : (Complex.exp (a * s)).re =
      Real.exp (-s) * Real.cos (t * s) := by
    simp [Complex.exp_re, a]
  have hi := integrableOn_exp_mul_complex_Ioi ha 0
  have h := congrArg Complex.re (integral_exp_mul_complex_Ioi ha 0)
  have hcomm := integral_re hi
  simp only [RCLike.re_to_complex] at hcomm
  rw [← hcomm] at h
  simp only [hr] at h
  convert h using 1
  simp [a, Complex.div_re, Complex.normSq_apply, pow_two]

theorem integrableOn_exp_neg_mul_cos (t : ℝ) :
    IntegrableOn (fun s : ℝ => Real.exp (-s) * Real.cos (t * s)) (Ioi 0) := by
  have hi := (integrableOn_exp_mul_complex_Ioi (a := -1 + t * Complex.I)
    (by simp) 0).re
  simpa [IntegrableOn, Complex.exp_re] using hi

theorem integrableOn_exp_neg_mul_self :
    IntegrableOn (fun s : ℝ => Real.exp (-s) * s) (Ioi 0) := by
  simpa only [show (2 : ℝ) - 1 = 1 by norm_num, Real.rpow_one] using (Real.GammaIntegral_convergent (s := 2) (by norm_num))

theorem integral_exp_neg_mul_self :
    (∫ s : ℝ in Ioi 0, Real.exp (-s) * s) = 1 := by
  simpa only [show (2 : ℝ) - 1 = 1 by norm_num, Real.rpow_one, Real.Gamma_nat_eq_factorial, Nat.factorial_one, Nat.cast_one, Real.Gamma_ofNat_eq_factorial] using (Real.Gamma_eq_integral (s := 2) (by norm_num)).symm

/-- Absolute integrability justifies exchanging the exponential average and
Fourier integration. -/
theorem integrable_exp_cosineKernel_product :
    Integrable (fun p : ℝ × ℝ => Real.exp (-p.1) * cosineKernel p.1 p.2)
      ((volume.restrict (Ioi 0)).prod volume) := by
  apply (integrable_prod_iff (by unfold cosineKernel; fun_prop)).2
  refine ⟨Filter.Eventually.of_forall (fun s =>
    by simpa using (integrable_cosineKernel s).const_mul (Real.exp (-s))), ?_⟩
  have he (s : ℝ) : (∫ t : ℝ, ‖Real.exp (-s) * cosineKernel s t‖) =
      Real.exp (-s) * |s| * fourierAbsConstant := by
    simp_rw [Real.norm_eq_abs, abs_of_nonneg (mul_nonneg (Real.exp_pos _).le
      (cosineKernel_nonneg _ _))]
    rw [integral_const_mul, integral_cosineKernel, mul_assoc]
  simp_rw [he]
  apply (integrableOn_exp_neg_mul_self.mul_const fourierAbsConstant).congr
  filter_upwards [self_mem_ae_restrict measurableSet_Ioi] with s hs
  simp only [abs_of_pos (show 0 < s from hs)]

/-- The reversed integral is exactly the Cauchy kernel away from the null
point at zero. -/
theorem integral_exp_cosineKernel (t : ℝ) (ht : t ≠ 0) :
    (∫ s : ℝ in Ioi 0, Real.exp (-s) * cosineKernel s t) = (1 + t ^ 2)⁻¹ := by
  have he : (fun s : ℝ => Real.exp (-s) * cosineKernel s t) =
      fun s => (Real.exp (-s) - Real.exp (-s) * Real.cos (t * s)) / t ^ 2 := by
    funext s
    unfold cosineKernel
    ring
  rw [he, integral_div, integral_sub (integrableOn_exp_neg_Ioi 0)
    (integrableOn_exp_neg_mul_cos t), integral_exp_neg_Ioi_zero,
    integral_exp_neg_mul_cos]
  have hd : 1 + t ^ 2 ≠ 0 := by positivity
  field_simp [ht, hd]
  ring

/-- Exact evaluation of the full-line normalizer used in the ReLU proofs. -/
theorem fourierAbsConstant_eq_pi : fourierAbsConstant = Real.pi := by
  have hs := integral_integral_swap (f := fun s t : ℝ => Real.exp (-s) * cosineKernel s t)
    integrable_exp_cosineKernel_product
  have hl : (∫ s : ℝ in Ioi 0, ∫ t : ℝ,
      Real.exp (-s) * cosineKernel s t) = fourierAbsConstant := by
    simp_rw [integral_const_mul, integral_cosineKernel, ← mul_assoc]
    rw [integral_mul_const]
    have he : (∫ s : ℝ in Ioi 0, Real.exp (-s) * |s|) = 1 := by
      convert integral_exp_neg_mul_self using 1
      apply setIntegral_congr_fun measurableSet_Ioi
      intro s hs
      simp only [abs_of_pos (show 0 < s from hs)]
    rw [he, one_mul]
  have hr : (∫ t : ℝ, ∫ s : ℝ in Ioi 0,
      Real.exp (-s) * cosineKernel s t) = Real.pi := by
    calc
      _ = ∫ t : ℝ, (1 + t ^ 2)⁻¹ := by
        apply integral_congr_ae
        have hn : ∀ᵐ t : ℝ ∂volume, t ≠ 0 := by
          simp [ae_iff]
        filter_upwards [hn] with t ht
        exact integral_exp_cosineKernel t ht
      _ = Real.pi := integral_univ_inv_one_add_sq
  exact hl.symm.trans (hs.trans hr)

/-- Passing from a full-line even integral to the paper's positive half-line. -/
theorem integral_even_eq_twice_Ioi (f : ℝ → ℝ) (hf : Function.Even f) :
    (∫ t : ℝ, f t) = 2 * ∫ t : ℝ in Ioi 0, f t := by
  have he (t : ℝ) : f |t| = f t := by
    rcases le_total 0 t with ht | ht
    · rw [abs_of_nonneg ht]
    · rw [abs_of_nonpos ht, hf]
  simpa only [he] using (integral_comp_abs (f := f))

/-- The exact numerical absolute-value representation printed in the paper. -/
theorem abs_eq_cosine_integral_pi (z : ℝ) :
    |z| = (2 / Real.pi) * ∫ t : ℝ in Ioi 0, (1 - Real.cos (t * z)) / t ^ 2 := by
  have he : Function.Even (cosineKernel z) := by
    intro t
    simp [cosineKernel, neg_mul]
  rw [abs_eq_cosine_integral, fourierAbsConstant_eq_pi,
    integral_even_eq_twice_Ioi _ he]
  unfold cosineKernel
  ring

/-- ReLU's representation with the literal numerical coefficient. -/
theorem relu_eq_cosine_integral_pi (z : ℝ) :
    max z 0 = z / 2 + (1 / Real.pi) *
      ∫ t : ℝ in Ioi 0, (1 - Real.cos (t * z)) / t ^ 2 := by
  have he : Function.Even (cosineKernel z) := by
    intro t
    simp [cosineKernel, neg_mul]
  rw [relu_eq_cosine_integral, fourierAbsConstant_eq_pi,
    integral_even_eq_twice_Ioi _ he]
  unfold cosineKernel
  ring

/-- The trigonometric product has the parity of its Walsh degree. -/
theorem trigProduct_neg {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) :
    trigProduct S (fun i => -u i) = (-1 : ℝ)^S.card * trigProduct S u := by
  classical
  have hp (i : Fin d) :
      (if i ∈ S then Real.sin (-u i) else Real.cos (-u i)) =
      (if i ∈ S then (-1 : ℝ) else 1) *
        (if i ∈ S then Real.sin (u i) else Real.cos (u i)) := by
    by_cases hi : i ∈ S <;> simp [hi]
  simp only [trigProduct, hp, Finset.prod_mul_distrib]
  simp

/-- Literal half-line Walsh formula, including arbitrary bias and unused
coordinates, with exactly the manuscript's `1 / pi` prefactor. -/
theorem relu_walsh_integral_even_pi {d r : ℕ} (S : Finset (Fin d))
    (hS : 2 ≤ S.card) (hcard : S.card = 2 * r) (b : ℝ) (u : Fin d → ℝ) :
    walshCoefficients (fun x => max (cubeAffine b u x) 0) S =
      (-1 : ℝ) ^ (r + 1) / Real.pi * ∫ t : ℝ in Ioi 0,
        Real.cos (t * b) * trigProduct S (fun i => t * u i) / t ^ 2 := by
  have he : Function.Even (fun t : ℝ =>
      Real.cos (t * b) * trigProduct S (fun i => t * u i) / t ^ 2) := by
    intro t
    simp only [neg_mul, Real.cos_neg, neg_sq, trigProduct_neg, hcard, pow_mul]
    norm_num
  rw [relu_walsh_integral_even S hS hcard, fourierAbsConstant_eq_pi,
    integral_even_eq_twice_Ioi _ he]
  ring

/-- The actual Fourier potential is the paper's normalized half-line
integral, even without a nonzero-support assumption. -/
theorem supportFourierPotential_eq_integral_pi {d : ℕ}
    (S : Finset (Fin d)) (u : Fin d → ℝ) :
    supportFourierPotential S u = (1 / Real.pi) *
      ∫ t : ℝ in Ioi 0, |trigProduct S (fun i => t * u i)| / t ^ 2 := by
  have he : Function.Even (fun t : ℝ => |trigKernel S u t|) := by
    intro t
    simp [trigKernel, neg_mul, trigProduct_neg, abs_div, abs_mul, abs_pow]
  rw [supportFourierPotential, fourierAbsConstant_eq_pi,
    integral_even_eq_twice_Ioi _ he]
  simp only [trigKernel, abs_div, abs_pow, sq_abs]
  ring

open scoped BigOperators

/-- The single product in the formal development is the manuscript's
product over the active coordinates times the product over its complement. -/
theorem trigProduct_eq_split {d : ℕ} (S : Finset (Fin d)) (u : Fin d → ℝ) :
    trigProduct S u = (∏ i ∈ S, Real.sin (u i)) *
      ∏ i ∈ Finset.univ \ S, Real.cos (u i) := by
  classical
  simp [trigProduct, Finset.prod_ite, Finset.sdiff_eq_filter]

/-- Equation (Fourier-integral) with its stated absolute convergence,
literal coordinate products, degree sign, and numerical prefactor. -/
theorem relu_walsh_integral_paper {d : ℕ} (S : Finset (Fin d))
    (hS : 2 ≤ S.card) (heven : Even S.card) (b : ℝ) (u : Fin d → ℝ) :
    let kernel : ℝ → ℝ := fun t => Real.cos (b * t) *
      (∏ i ∈ S, Real.sin (u i * t)) *
      (∏ i ∈ Finset.univ \ S, Real.cos (u i * t)) / t ^ 2
    IntegrableOn kernel (Ioi 0) ∧
    walshCoefficients (fun x => max (cubeAffine b u x) 0) S =
      (-1 : ℝ) ^ (S.card / 2 + 1) / Real.pi * ∫ t : ℝ in Ioi 0, kernel t := by
  dsimp only
  obtain ⟨r, hr⟩ := heven
  have hcard : S.card = 2 * r := by omega
  have hprod (t : ℝ) : Real.cos (b * t) *
      (∏ i ∈ S, Real.sin (u i * t)) *
      (∏ i ∈ Finset.univ \ S, Real.cos (u i * t)) / t ^ 2 =
      Real.cos (t * b) * trigProduct S (fun i => t * u i) / t ^ 2 := by
    rw [trigProduct_eq_split]
    simp only [mul_comm t]
    ring
  simp_rw [hprod]
  constructor
  · have hS0 : S ≠ ∅ := by intro h; simp [h] at hS
    simpa only [trigKernel, mul_div_assoc] using
      (integrable_cos_mul_trigKernel S hS0 hcard b u).integrableOn (s := Ioi 0)
  · have hdegree : S.card / 2 = r := by omega
    rw [hdegree]
    exact relu_walsh_integral_even_pi S hS hcard b u

end NeuralGeneralization.OnlineLowerRelu
