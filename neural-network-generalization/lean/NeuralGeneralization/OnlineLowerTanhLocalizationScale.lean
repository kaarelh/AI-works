import NeuralGeneralization.OnlineLowerTanhProductLaplace
import NeuralGeneralization.OnlineLowerTanhSineIntegrable

/-! # Quantitative RMS scale localization without coordinate counting -/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- A polynomially weighted hyperbolic kernel is bounded by an exponential.
The deliberately loose constant follows from the linear exponential bound. -/
theorem cubic_sinh_exp_bound (b t : ℝ) (hb : 0 < b) (ht : 0 < t) :
    t^3/Real.sinh (b*t)  ≤  (128/b^3)*Real.exp (-(b/4)*t) := by
  have hs : 0 < Real.sinh (b*t) := Real.sinh_pos_iff.mpr (mul_pos hb ht)
  have hlow := sinh_exp_lower (b*t) (mul_pos hb ht).le
  have hx : 0  ≤  b*t/8 := by positivity
  have hxe : b*t/8  ≤  Real.exp (b*t/8) := by linarith [Real.add_one_le_exp (b*t/8)]
  have hsq := pow_le_pow_left₀ hx hxe 2
  have heq : Real.exp (b*t/8)^2=Real.exp (b*t/4) := by
    rw [← Real.exp_nat_mul]
    congr 1
    norm_num
    ring
  rw [heq] at hsq
  have hprod : Real.exp (b*t/2)*Real.exp (-(b/4)*t)=Real.exp (b*t/4) := by
    rw [← Real.exp_add]
    congr 1
    ring
  have hmul := mul_le_mul_of_nonneg_right hlow
    (show 0  ≤  (128/b^3)*Real.exp (-(b/4)*t) by positivity)
  have hid : (b*t/2*Real.exp (b*t/2))*((128/b^3)*Real.exp (-(b/4)*t)) =
      (64/b^2)*t*Real.exp (b*t/4) := by
    calc
      _ = (b*t/2)*(128/b^3)*(Real.exp (b*t/2)*Real.exp (-(b/4)*t)) := by ring
      _ = _ := by rw [hprod]; field_simp; ring
  rw [hid] at hmul
  have htsq : t^2  ≤  (64/b^2)*Real.exp (b*t/4) := by
    rw [div_mul_eq_mul_div]
    apply (le_div_iff₀ (sq_pos_of_pos hb)).mpr
    nlinarith only [hsq]
  have hcube := mul_le_mul_of_nonneg_right htsq ht.le
  apply (div_le_iff₀ hs).mpr
  nlinarith only [hcube,hmul]

/-- A high-degree product obeys a cubic gain bound after taking its square
root. This combines the RMS AM--GM bound with the universal bound by one. -/
theorem sqrt_paritySineProduct_cubic {n : ℕ} (hn : 6 ≤ n) (u : Fin n → ℝ)
    (t : ℝ) (ht : 0 ≤ t) :
    Real.sqrt (paritySineProduct u t)  ≤  (incomingScale u*t)^3 := by
  have hnpos : 0 < n := by omega
  have hx : 0  ≤  incomingScale u*t := mul_nonneg (incomingScale_nonneg u) ht
  have hP := paritySineProduct_nonneg u t
  have hsq := Real.sq_sqrt hP
  have hs0 := Real.sqrt_nonneg (paritySineProduct u t)
  by_cases hx1 : incomingScale u*t  ≤  1
  · have hpow := pow_le_pow_of_le_one hx hx1 hn
    have hnear := paritySineProduct_near_zero hnpos u t ht
    have heq : ((incomingScale u*t)^3)^2 = (incomingScale u*t)^6 := by ring
    have hpos := pow_nonneg hx 3
    nlinarith
  · have h1 : 1  ≤  incomingScale u*t := (lt_of_not_ge hx1).le
    have hp : (1:ℝ)  ≤  (incomingScale u*t)^3 := one_le_pow₀ h1
    have hs : Real.sqrt (paritySineProduct u t)  ≤  1 := by
      simpa using Real.sqrt_le_sqrt (paritySineProduct_le_one u t)
    exact hs.trans hp

/-- The absolute tanh Fourier integral is at most cubic in RMS gain, with
an absolute dimension-free coefficient. -/
theorem parity_absolute_kernel_cubic (r : ℕ) (hr : 3 ≤ r)
    (u : Fin (2*r+1) → ℝ) :
    Real.sqrt (2*r+1:ℕ)*(∫t : ℝ in Ioi 0,
      paritySineProduct u t/Real.sinh (Real.pi*t/2))  ≤ 
        (16384/Real.pi^3)*incomingScale u^3 := by
  let c := Real.pi/8
  let K := 1024/Real.pi^3
  have hc : 0 < c := by dsimp [c]; positivity
  obtain ⟨hInt,hLap⟩ := sqrt_paritySineProduct_laplace r (by omega) u c hc
  have hpoint (t : ℝ) (ht : 0 < t) :
      paritySineProduct u t/Real.sinh (Real.pi*t/2)  ≤ 
        (K*incomingScale u^3)*(Real.exp (-c*t)*Real.sqrt (paritySineProduct u t)) := by
    have hcube := sqrt_paritySineProduct_cubic (by omega : 6 ≤ 2*r+1) u t ht.le
    have hs0 := Real.sqrt_nonneg (paritySineProduct u t)
    have hsq := Real.sq_sqrt (paritySineProduct_nonneg u t)
    have hprod := mul_le_mul_of_nonneg_right hcube hs0
    have hker := cubic_sinh_exp_bound (Real.pi/2) t (by positivity) ht
    have heK : 128/(Real.pi/2)^3=K := by dsimp [K]; field_simp; ring
    have hec : -((Real.pi/2)/4)*t = -c*t := by dsimp [c]; ring
    rw [heK,hec,show Real.pi/2*t=Real.pi*t/2 by ring] at hker
    have hsin : 0 < Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
    have hfirst := div_le_div_of_nonneg_right hprod hsin.le
    rw [← pow_two,hsq] at hfirst
    have hsecond := mul_le_mul_of_nonneg_right hker
      (mul_nonneg (pow_nonneg (incomingScale_nonneg u) 3) hs0)
    apply hfirst.trans
    convert hsecond using 1  <;> ring
  have hI := integral_mono_ae (integrable_parity_absolute_kernel rfl u)
    (hInt.const_mul (K*incomingScale u^3)) (by
      filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      exact hpoint t ht)
  rw [integral_const_mul] at hI
  have hI' := mul_le_mul_of_nonneg_left hI (Real.sqrt_nonneg (2*r+1:ℕ))
  have hL := mul_le_mul_of_nonneg_left hLap
    (mul_nonneg (show 0 ≤ K by dsimp [K]; positivity) (pow_nonneg (incomingScale_nonneg u) 3))
  have he : (K*incomingScale u^3)*(2*Real.pi/c) =
      (16384/Real.pi^3)*incomingScale u^3 := by dsimp [K,c]; field_simp; ring
  rw [he] at hL
  nlinarith only [hI',hL]

/-- Competitiveness forces a positive uniform lower bound on squared RMS
gain. No asymptotic dimension threshold is needed beyond degree seven. -/
theorem competitive_scale_lower_square (r : ℕ) (hr : 3 ≤ r)
    (u : Fin (2*r+1) → ℝ) (c : ℝ) (hc : 0 < c)
    (hu : 0 < incomingEnergy u)
    (hcomp : c*Real.sqrt (incomingEnergy u)  ≤  (2*r+1:ℕ)*|parityCorrelation u 0|) :
    c  ≤  (16384/Real.pi^3)*incomingScale u^2 := by
  have hz : 0 < incomingScale u := Real.sqrt_pos.mpr (div_pos hu (by positivity))
  have hroot : 0 < Real.sqrt (2*r+1:ℕ) := Real.sqrt_pos.mpr (by positivity)
  have hs := incomingScale_mul_sqrt (by omega : 0 < 2*r+1) u
  have hr2 := Real.sq_sqrt (show (0:ℝ) ≤ (2*r+1:ℕ) by positivity)
  have hscore : c*incomingScale u  ≤  Real.sqrt (2*r+1:ℕ)*|parityCorrelation u 0| := by
    apply (mul_le_mul_iff_left₀ hroot).mp
    rw [← hs] at hcomp
    calc
      c*incomingScale u*Real.sqrt (2*r+1:ℕ) = c*(incomingScale u*Real.sqrt (2*r+1:ℕ)) := by ring
      _  ≤  _ := hcomp
      _ = (Real.sqrt (2*r+1:ℕ)*|parityCorrelation u 0|)*Real.sqrt (2*r+1:ℕ) := by
        rw [mul_right_comm,← pow_two,hr2]
  have hcoef := mul_le_mul_of_nonneg_left (parityCorrelation_le_absolute_kernel rfl u 0) hroot.le
  have hkernel := parity_absolute_kernel_cubic r hr u
  have h := hscore.trans (hcoef.trans hkernel)
  apply (mul_le_mul_iff_left₀ hz).mp
  nlinarith only [h]

end NeuralGeneralization.OnlineLowerTanh
