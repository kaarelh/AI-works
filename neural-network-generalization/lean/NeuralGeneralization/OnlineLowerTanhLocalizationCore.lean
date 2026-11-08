import NeuralGeneralization.OnlineLowerTanhMonotone
import NeuralGeneralization.OnlineLowerTanhCodeKernel
import NeuralGeneralization.OnlineLowerReluBalancing

/-! # Actual sine-product quantities for intrinsic tanh localization -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

def paritySineProduct {n : ℕ} (u : Fin n → ℝ) (t : ℝ) : ℝ :=
  ∏ i, |Real.sin (t*u i)|

def incomingScale {n : ℕ} (u : Fin n → ℝ) : ℝ :=
  Real.sqrt (incomingEnergy u / n)

theorem paritySineProduct_nonneg {n : ℕ} (u : Fin n → ℝ) (t : ℝ) :
    0  ≤  paritySineProduct u t := Finset.prod_nonneg (fun i _ => abs_nonneg _)

theorem paritySineProduct_le_one {n : ℕ} (u : Fin n → ℝ) (t : ℝ) :
    paritySineProduct u t  ≤  1 :=
  Finset.prod_le_one (fun i _ => abs_nonneg _) (fun i _ => Real.abs_sin_le_one _)

theorem continuous_paritySineProduct {n : ℕ} (u : Fin n → ℝ) :
    Continuous (paritySineProduct u) := by unfold paritySineProduct; fun_prop

theorem incomingScale_nonneg {n : ℕ} (u : Fin n → ℝ) : 0 ≤ incomingScale u :=
  Real.sqrt_nonneg _

theorem incomingScale_sq {n : ℕ} (u : Fin n → ℝ) :
    incomingScale u ^ 2 = incomingEnergy u / n :=
  Real.sq_sqrt (div_nonneg (incomingEnergy_nonneg u) (Nat.cast_nonneg n))

theorem incomingScale_mul_sqrt {n : ℕ} (hn : 0<n) (u : Fin n → ℝ) :
    incomingScale u * Real.sqrt (n:ℝ) = Real.sqrt (incomingEnergy u) := by
  unfold incomingScale
  rw [← Real.sqrt_mul (div_nonneg (incomingEnergy_nonneg u) (Nat.cast_nonneg n)), div_mul_cancel₀ _ (by positivity : (n:ℝ)≠0)]

/-- The product of coordinate magnitudes is bounded by the RMS to the
number of coordinates; the norm here is the actual squared Euclidean norm. -/
theorem prod_abs_le_incomingScale_pow {n : ℕ} (hn : 0<n) (u : Fin n → ℝ) :
    (∏ i, |u i|)  ≤  incomingScale u ^ n := by
  letI : Nonempty (Fin n) := ⟨⟨0,hn⟩⟩
  have hn0 : (n:ℝ)≠0 := by positivity
  have hweights : (∑ _ : Fin n, (n:ℝ)⁻¹)=1 := by simp [hn0]
  have h := Real.geom_mean_le_arith_mean_weighted Finset.univ
    (fun _ : Fin n => (n:ℝ)⁻¹) (fun i => u i^2)
    (fun _ _ => inv_nonneg.mpr (Nat.cast_nonneg n)) hweights
    (fun i _ => sq_nonneg _)
  have hpowers := pow_le_pow_left₀
    (Finset.prod_nonneg (fun i _ => Real.rpow_nonneg (sq_nonneg (u i)) _)) h n
  rw [← Finset.prod_pow] at hpowers
  simp_rw [Real.rpow_inv_natCast_pow (sq_nonneg _) (Nat.ne_of_gt hn)] at hpowers
  have hprod : (∏ i, |u i|)^2 = ∏ i, u i^2 := by
    rw [← Finset.prod_pow]
    simp only [sq_abs]
  have hscale : (incomingScale u^n)^2 = (incomingEnergy u/n)^n := by
    rw [← pow_mul, Nat.mul_comm n 2, pow_mul, incomingScale_sq]
  have h' : (∏ i, u i^2)  ≤  (incomingEnergy u/n)^n := by
    simpa [incomingEnergy, ← Finset.mul_sum, div_eq_mul_inv, mul_comm] using hpowers
  have hp : 0 ≤ ∏ i, |u i| := Finset.prod_nonneg (fun i _ => abs_nonneg _)
  have hs : 0 ≤ incomingScale u^n := pow_nonneg (incomingScale_nonneg u) _
  nlinarith

theorem paritySineProduct_near_zero {n : ℕ} (hn : 0<n) (u : Fin n → ℝ)
    (t : ℝ) (ht : 0 ≤ t) : paritySineProduct u t  ≤  (incomingScale u*t)^n := by
  calc
    _  ≤  ∏ i, t*|u i| := by
      apply Finset.prod_le_prod (fun i _ => abs_nonneg _)
      intro i _
      exact Real.abs_sin_le_abs.trans (by rw [abs_mul,abs_of_nonneg ht])
    _ = t^n * ∏ i, |u i| := by simp [Finset.prod_mul_distrib]
    _  ≤  t^n * incomingScale u^n := mul_le_mul_of_nonneg_left
      (prod_abs_le_incomingScale_pow hn u) (pow_nonneg ht _)
    _ = (incomingScale u*t)^n := by rw [mul_pow,mul_comm]

theorem integrable_parity_absolute_kernel {n r : ℕ} (hn : n=2*r+1) (u : Fin n → ℝ) :
    IntegrableOn (fun t => paritySineProduct u t / Real.sinh (Real.pi*t/2)) (Ioi 0) := by
  apply (integrable_parity_sine_kernel hn u).norm.congr
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
  have htpos : 0<t := ht
  simp only [Real.norm_eq_abs, abs_div, Finset.abs_prod]
  rw [abs_of_pos (Real.sinh_pos_iff.mpr (by positivity))]
  rfl

theorem parityCorrelation_le_absolute_kernel {n r : ℕ} (hn : n=2*r+1)
    (u : Fin n → ℝ) (b : ℝ) :
    |parityCorrelation u b|  ≤ 
      ∫ t : ℝ in Ioi 0, paritySineProduct u t / Real.sinh (Real.pi*t/2) := by
  rw [parityCorrelation_sine_integral hn, abs_mul, abs_pow]
  simp only [abs_neg, abs_one, one_pow, one_mul]
  apply (abs_integral_le_integral_abs).trans
  have habs : IntegrableOn (fun t => |Real.cos (t*b)*(∏i,Real.sin (t*u i)) /
      Real.sinh (Real.pi*t/2)|) (Ioi 0) := by
    apply (integrable_parity_absolute_kernel hn u).mono'
    · exact (by fun_prop : Measurable (fun t => |Real.cos (t*b)*(∏i,Real.sin (t*u i)) /
        Real.sinh (Real.pi*t/2)|)).aestronglyMeasurable
    · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      have htpos : 0<t := ht
      rw [Real.norm_eq_abs,abs_abs,abs_div,abs_mul,Finset.abs_prod,
        abs_of_pos (Real.sinh_pos_iff.mpr (by positivity))]
      exact div_le_div_of_nonneg_right
        (mul_le_of_le_one_left (paritySineProduct_nonneg u t) (Real.abs_cos_le_one _)) (by positivity)
  apply integral_mono_ae habs (integrable_parity_absolute_kernel hn u)
  filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
  have htpos : 0<t := ht
  rw [abs_div,abs_mul,Finset.abs_prod,abs_of_pos (Real.sinh_pos_iff.mpr (by positivity))]
  exact div_le_div_of_nonneg_right
    (mul_le_of_le_one_left (paritySineProduct_nonneg u t) (Real.abs_cos_le_one _)) (by positivity)

/-- Every competitive intrinsic atom has bounded RMS scale, without any
localization or sharp intrinsic theorem being assumed. -/
theorem competitive_scale_upper (r : ℕ) (u : Fin (2*r+1) → ℝ) (c : ℝ) (hc : 0<c)
    (hcomp : c*Real.sqrt (incomingEnergy u)  ≤  (2*r+1:ℕ)*|parityCorrelation u 0|) :
    incomingScale u  ≤  2/c := by
  have hcap := parityCorrelation_sqrt_cap r u 0
  have hn : 0<2*r+1 := by omega
  have hs := incomingScale_mul_sqrt hn u
  have hr := Real.sq_sqrt (show (0:ℝ) ≤ (2*r+1:ℕ) by positivity)
  have hroot := Real.sqrt_pos.mpr (show (0:ℝ)<(2*r+1:ℕ) by positivity)
  have hmul := mul_le_mul_of_nonneg_left hcap hroot.le
  have hmul' : (2*r+1:ℕ)*|parityCorrelation u 0| ≤ Real.sqrt (2*r+1:ℕ)*2 := by
    calc
      _ = Real.sqrt (2*r+1:ℕ)*(Real.sqrt (2*r+1:ℕ)*|parityCorrelation u 0|) := by
        rw [← mul_assoc, ← pow_two, hr]
      _ ≤ _ := hmul
  have hnorm : c*incomingScale u ≤ 2 := by
    apply (mul_le_mul_iff_left₀ hroot).mp
    have h := hcomp.trans hmul'
    rw [← hs] at h
    nlinarith only [h]
  exact (le_div_iff₀ hc).mpr (by nlinarith)

end NeuralGeneralization.OnlineLowerTanh
