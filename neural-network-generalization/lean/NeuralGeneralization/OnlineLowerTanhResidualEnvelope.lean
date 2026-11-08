import NeuralGeneralization.OnlineLowerTanhResidualSaddle
import NeuralGeneralization.OnlineLowerTanhPhaseBezout

/-! # Global envelopes for perturbed odd-lattice products -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.OnlineLowerTanh

lemma abs_sin_le_exp_cos_square (x : ℝ) :
    |Real.sin x| ≤ Real.exp (-(Real.cos x)^2/2) := by
  have he := Real.add_one_le_exp (-(Real.cos x)^2)
  have htrig := Real.sin_sq_add_cos_sq x
  have hexp : (Real.exp (-(Real.cos x)^2/2))^2 = Real.exp (-(Real.cos x)^2) := by
    rw [pow_two, ← Real.exp_add]
    congr 1
    ring
  nlinarith [sq_abs (Real.sin x), abs_nonneg (Real.sin x), Real.exp_pos (-(Real.cos x)^2/2)]

lemma sine_product_cosine_envelope {ι : Type*} [Fintype ι] (z : ι → ℝ) :
    |∏ i, Real.sin (z i)| ≤ Real.exp (-(∑ i, (Real.cos (z i))^2)/2) := by
  rw [Finset.abs_prod]
  calc
    _ ≤ ∏ i, Real.exp (-(Real.cos (z i))^2/2) :=
      Finset.prod_le_prod (fun i _ => abs_nonneg _) (fun i _ => abs_sin_le_exp_cos_square _)
    _ = _ := by rw [← Real.exp_sum, ← Finset.sum_div, Finset.sum_neg_distrib]

lemma cosine_perturbation_square (x h : ℝ) :
    (Real.cos (x+h))^2 ≥ (Real.cos x)^2/2-h^2 := by
  have hd := Real.abs_cos_sub_cos_le (x+h) x
  simp only [add_sub_cancel_left] at hd
  have hsq : (Real.cos (x+h)-Real.cos x)^2 ≤ h^2 := by
    exact sq_le_sq.mpr hd
  nlinarith [sq_nonneg (2*Real.cos (x+h)-Real.cos x)]

/-- The residual energy pays a bounded additive term in the exponent, even
away from the local windows where Taylor expansion is valid. -/
theorem residual_sine_product_envelope {ι : Type*} [Fintype ι]
    (q d : ι → ℝ) (A t : ℝ) :
    |∏ i, Real.sin ((A*q i+d i)*t)| ≤
      Real.exp (-(∑ i, (Real.cos (A*q i*t))^2)/4+
        t^2*(∑ i, (d i)^2)/2) := by
  apply (sine_product_cosine_envelope (fun i => (A*q i+d i)*t)).trans
  apply Real.exp_le_exp.mpr
  have hs := Finset.sum_le_sum (s := Finset.univ) (fun i _ =>
    cosine_perturbation_square (A*q i*t) (d i*t))
  simp only [mul_pow, Finset.sum_sub_distrib, ← Finset.sum_div, ← Finset.sum_mul] at hs
  have he (i : ι) : A*q i*t+d i*t = (A*q i+d i)*t := by ring
  simp_rw [he] at hs
  nlinarith

lemma fiber_weighted_sum_lower {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (label : Fin n → ι) (f : ι → ℝ) {α : ℝ}
    (hf : ∀ j, 0 ≤ f j)
    (hfreq : ∀ j, α*(n:ℝ) ≤ ((Finset.univ.filter (fun i => label i=j)).card:ℝ)) :
    α*(n:ℝ)*(∑ j, f j) ≤ ∑ i, f (label i) := by
  rw [← Finset.sum_fiberwise' Finset.univ label f]
  simp only [Finset.sum_const, nsmul_eq_mul]
  rw [Finset.mul_sum]
  apply Finset.sum_le_sum
  intro j _
  exact mul_le_mul_of_nonneg_right (hfreq j) (hf j)

lemma bezout_energy_pos {ι : Type*} [Fintype ι] (q c : ι → ℤ)
    (hbezout : ∑ j, c j*q j = 1) : 0 < ∑ j, (c j:ℝ)^2 := by
  have hb : (∑ j, (c j:ℝ)*(q j:ℝ)) = 1 := by exact_mod_cast hbezout
  have hh := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ (fun j => (c j:ℝ)) (fun j => (q j:ℝ))
  rw [hb] at hh
  have hq : 0 ≤ ∑ j, (q j:ℝ)^2 := Finset.sum_nonneg (fun j _ => sq_nonneg _)
  by_contra hn
  have hc : (∑ j, (c j:ℝ)^2) ≤ 0 := le_of_not_gt hn
  have hm := mul_nonpos_of_nonpos_of_nonneg hc hq
  nlinarith

/-- Positive frequencies transfer the alphabet coercivity to all physical
coordinates. The frequency coefficient is the literal cardinality of each
fiber of `label`. -/
theorem residual_alphabet_cosine_lower {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (label : Fin n → ι) (q c : ι → ℤ)
    (hq : ∀ j, Odd (q j)) (hbezout : ∑ j, c j*q j = 1)
    {α : ℝ} (hα : 0 ≤ α)
    (hfreq : ∀ j, α*(n:ℝ) ≤ ((Finset.univ.filter (fun i => label i=j)).card:ℝ))
    (A t : ℝ) :
    α*(n:ℝ)*(phaseError true (2*A*t/Real.pi))^2/(∑ j, (c j:ℝ)^2) ≤
      ∑ i, (Real.cos (A*(q (label i):ℝ)*t))^2 := by
  have hc := odd_alphabet_cosine_coercivity Finset.univ q c (fun j _ => hq j) hbezout
    (2*A*t/Real.pi)
  have he (j : ι) : Real.pi*((q j:ℝ)*(2*A*t/Real.pi))/2 = A*(q j:ℝ)*t := by
    field_simp
  simp_rw [he] at hc
  have hm := mul_le_mul_of_nonneg_left hc (mul_nonneg hα (Nat.cast_nonneg n))
  have hf := fiber_weighted_sum_lower label (fun j => (Real.cos (A*(q j:ℝ)*t))^2)
    (fun j => sq_nonneg _) hfreq
  have hC := bezout_energy_pos q c hbezout
  apply (div_le_iff₀ hC).mpr
  nlinarith [mul_le_mul_of_nonneg_left hf hC.le]

/-- Global Gaussian localization to the common odd-lattice peaks, with an
explicit constant from any Bezout vector. -/
theorem residual_alphabet_product_envelope {ι : Type*} [Fintype ι] [DecidableEq ι]
    {n : ℕ} (label : Fin n → ι) (q c : ι → ℤ)
    (hq : ∀ j, Odd (q j)) (hbezout : ∑ j, c j*q j = 1)
    {α : ℝ} (hα : 0 ≤ α)
    (hfreq : ∀ j, α*(n:ℝ) ≤ ((Finset.univ.filter (fun i => label i=j)).card:ℝ))
    (d : Fin n → ℝ) (A t : ℝ) :
    |∏ i, Real.sin ((A*(q (label i):ℝ)+d i)*t)| ≤
      Real.exp (-α*(n:ℝ)*(phaseError true (2*A*t/Real.pi))^2/(4*∑ j, (c j:ℝ)^2)+
        t^2*(∑ i, (d i)^2)/2) := by
  have hp := residual_sine_product_envelope (fun i => (q (label i):ℝ)) d A t
  have hc := residual_alphabet_cosine_lower label q c hq hbezout hα hfreq A t
  apply hp.trans
  apply Real.exp_le_exp.mpr
  have he : -α*(n:ℝ)*(phaseError true (2*A*t/Real.pi))^2/(4*∑ j, (c j:ℝ)^2) =
      -(α*(n:ℝ)*(phaseError true (2*A*t/Real.pi))^2/(∑ j, (c j:ℝ)^2))/4 := by ring
  rw [he]
  linarith

end NeuralGeneralization.OnlineLowerTanh
