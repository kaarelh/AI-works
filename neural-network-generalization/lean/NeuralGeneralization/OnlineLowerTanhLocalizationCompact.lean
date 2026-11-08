import NeuralGeneralization.OnlineLowerTanhLocalizationScale
import NeuralGeneralization.OnlineLowerTanhLocalizationTail

/-! # Quantitative compact-frequency estimates for sine-product peaks -/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

lemma parity_kernel_cubic_point (r : ℕ) (hr : 3≤r) (u : Fin (2*r+1) → ℝ)
    (t : ℝ) (ht : 0<t) :
    paritySineProduct u t/Real.sinh (Real.pi*t/2) ≤
      incomingScale u^3*(t^3/Real.sinh (Real.pi*t/2))*Real.sqrt (paritySineProduct u t) := by
  have hs := sqrt_paritySineProduct_cubic (by omega : 6≤2*r+1) u t ht.le
  have hm := mul_le_mul_of_nonneg_right hs (Real.sqrt_nonneg (paritySineProduct u t))
  rw [← pow_two,Real.sq_sqrt (paritySineProduct_nonneg u t)] at hm
  have hd := div_le_div_of_nonneg_right hm
    (Real.sinh_pos_iff.mpr (by positivity : 0<Real.pi*t/2)).le
  simpa only [mul_pow,div_eq_mul_inv,mul_assoc,mul_comm,mul_left_comm] using hd

lemma cubic_sinh_small_bound (h t : ℝ) (ht : 0<t) (hth : t≤h) :
    t^3/Real.sinh (Real.pi*t/2) ≤ (2/Real.pi)*h^2 := by
  have hs := Real.sinh_pos_iff.mpr (by positivity : 0<Real.pi*t/2)
  have hl := Real.self_le_sinh_iff.mpr (show 0≤Real.pi*t/2 by positivity)
  have hm := mul_le_mul_of_nonneg_right hl (show 0≤(2/Real.pi)*h^2 by positivity)
  have hid : (Real.pi*t/2)*((2/Real.pi)*h^2)=t*h^2 := by field_simp
  rw [hid] at hm
  apply (div_le_iff₀ hs).mpr
  have hsq := pow_le_pow_left₀ ht.le hth 2
  have hmul := mul_le_mul_of_nonneg_left hsq ht.le
  nlinarith only [hm,hmul]

/-- A fixed short interval loses quadratically in its length, uniformly
in dimension, using the square-root sine-product Laplace estimate. -/
theorem parity_absolute_kernel_near_zero (r : ℕ) (hr : 3≤r)
    (u : Fin (2*r+1) → ℝ) (h : ℝ) (hh : 0<h) (hh1 : h≤1) :
    Real.sqrt (2*r+1:ℕ)*(∫t : ℝ in Ioc 0 h,
      paritySineProduct u t/Real.sinh (Real.pi*t/2)) ≤
        4*Real.exp 1*incomingScale u^3*h^2 := by
  let K := (2/Real.pi)*incomingScale u^3*h^2*Real.exp 1
  have hK : 0≤K := by dsimp [K]; positivity [incomingScale_nonneg u]
  obtain ⟨hExp,hLap⟩ := sqrt_paritySineProduct_laplace r (by omega) u 1 (by norm_num)
  have hsub : Ioc 0 h ⊆ Ioi (0:ℝ) := fun t ht => ht.1
  have hInt := (integrable_parity_absolute_kernel rfl u).mono_set hsub
  have hExpH := hExp.mono_set hsub
  have hpoint (t : ℝ) (ht : t∈Ioc 0 h) :
      paritySineProduct u t/Real.sinh (Real.pi*t/2) ≤
        K*(Real.exp (-1*t)*Real.sqrt (paritySineProduct u t)) := by
    have hfirst := parity_kernel_cubic_point r hr u t ht.1
    have hker := cubic_sinh_small_bound h t ht.1 ht.2
    have hsecond := mul_le_mul_of_nonneg_left hker
      (mul_nonneg (pow_nonneg (incomingScale_nonneg u) 3) (Real.sqrt_nonneg (paritySineProduct u t)))
    have hexp : 1≤Real.exp 1*Real.exp (-1*t) := by
      rw [←Real.exp_add]
      exact Real.one_le_exp_iff.mpr (by linarith [ht.2])
    have hthird := mul_le_mul_of_nonneg_left hexp
      (show 0≤(2/Real.pi)*incomingScale u^3*h^2*Real.sqrt (paritySineProduct u t) by
        positivity [incomingScale_nonneg u])
    dsimp [K]
    calc
      _ ≤ _ := hfirst
      _ ≤ (2/Real.pi)*incomingScale u^3*h^2*Real.sqrt (paritySineProduct u t) := by
        simpa only [mul_pow,div_eq_mul_inv,mul_assoc,mul_comm,mul_left_comm] using hsecond
      _ ≤ _ := by simpa only [one_mul,mul_one,mul_assoc,mul_comm,mul_left_comm] using hthird
  have hI := integral_mono_ae hInt (hExpH.const_mul K) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
    exact hpoint t ht)
  rw [integral_const_mul] at hI
  have hwhole := setIntegral_mono_set hExp
    (Filter.Eventually.of_forall (fun t => by positivity : ∀t:ℝ,0≤Real.exp (-1*t)*Real.sqrt (paritySineProduct u t)))
    (Filter.Eventually.of_forall (fun t => show t∈Ioc 0 h → t∈Ioi (0:ℝ) from fun ht => ht.1))
  have hIwhole := hI.trans (mul_le_mul_of_nonneg_left hwhole hK)
  have hscaled := mul_le_mul_of_nonneg_left hIwhole (Real.sqrt_nonneg (2*r+1:ℕ))
  have hlast := mul_le_mul_of_nonneg_left hLap hK
  have he : K*(2*Real.pi/1)=4*Real.exp 1*incomingScale u^3*h^2 := by
    dsimp [K]
    field_simp
    ring
  rw [he] at hlast
  nlinarith only [hscaled,hlast]

/-- If every product value in a compact frequency interval is small,
its weighted mass is controlled by the square root of that height. -/
theorem parity_absolute_kernel_middle (r : ℕ) (hr : 0<r)
    (u : Fin (2*r+1) → ℝ) (h T μ : ℝ) (hh : 0<h) (hhT : h≤T) (hμ : 0≤μ)
    (hpeak : ∀t∈Ioc h T, paritySineProduct u t≤μ) :
    Real.sqrt (2*r+1:ℕ)*(∫t : ℝ in Ioc h T,
      paritySineProduct u t/Real.sinh (Real.pi*t/2)) ≤
        (4*Real.exp T/h)*Real.sqrt μ := by
  let K := (2/(Real.pi*h))*Real.exp T*Real.sqrt μ
  have hK : 0≤K := by dsimp [K]; positivity
  obtain ⟨hExp,hLap⟩ := sqrt_paritySineProduct_laplace r hr u 1 (by norm_num)
  have hsub : Ioc h T ⊆ Ioi (0:ℝ) := fun t ht => hh.trans ht.1
  have hInt := (integrable_parity_absolute_kernel rfl u).mono_set hsub
  have hExpH := hExp.mono_set hsub
  have hpoint (t : ℝ) (ht : t∈Ioc h T) :
      paritySineProduct u t/Real.sinh (Real.pi*t/2) ≤
        K*(Real.exp (-1*t)*Real.sqrt (paritySineProduct u t)) := by
    have htpos := hh.trans ht.1
    have hs := Real.sinh_pos_iff.mpr (by positivity : 0<Real.pi*t/2)
    have hlow := Real.self_le_sinh_iff.mpr (show 0≤Real.pi*t/2 by positivity)
    have hk : 1/Real.sinh (Real.pi*t/2) ≤ 2/(Real.pi*h) := by
      apply (div_le_div_iff₀ hs (by positivity)).mpr
      nlinarith [Real.pi_pos,ht.1]
    have hp := Real.sqrt_le_sqrt (hpeak t ht)
    have hp' := mul_le_mul_of_nonneg_right hp (Real.sqrt_nonneg (paritySineProduct u t))
    rw [←pow_two,Real.sq_sqrt (paritySineProduct_nonneg u t)] at hp'
    have hexp : 1≤Real.exp T*Real.exp (-1*t) := by
      rw [←Real.exp_add]
      exact Real.one_le_exp_iff.mpr (by linarith [ht.2])
    have h1 := mul_le_mul_of_nonneg_left hk (paritySineProduct_nonneg u t)
    have h2 := mul_le_mul_of_nonneg_left hp' (show 0≤2/(Real.pi*h) by positivity)
    have h3 := mul_le_mul_of_nonneg_left hexp
      (show 0≤(2/(Real.pi*h))*Real.sqrt μ*Real.sqrt (paritySineProduct u t) by positivity)
    dsimp [K]
    calc
      _ ≤ (2/(Real.pi*h))*paritySineProduct u t := by
        simpa only [div_eq_mul_inv,mul_assoc,mul_comm,mul_left_comm,one_mul] using h1
      _ ≤ (2/(Real.pi*h))*Real.sqrt μ*Real.sqrt (paritySineProduct u t) := by
        simpa only [mul_assoc] using h2
      _ ≤ _ := by simpa only [one_mul,mul_one,mul_assoc,mul_comm,mul_left_comm] using h3
  have hI := integral_mono_ae hInt (hExpH.const_mul K) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
    exact hpoint t ht)
  rw [integral_const_mul] at hI
  have hwhole := setIntegral_mono_set hExp
    (Filter.Eventually.of_forall (fun t => by positivity : ∀t:ℝ,0≤Real.exp (-1*t)*Real.sqrt (paritySineProduct u t)))
    (Filter.Eventually.of_forall (fun t => show t∈Ioc h T → t∈Ioi (0:ℝ) from fun ht => hsub ht))
  have hIwhole := hI.trans (mul_le_mul_of_nonneg_left hwhole hK)
  have hscaled := mul_le_mul_of_nonneg_left hIwhole (Real.sqrt_nonneg (2*r+1:ℕ))
  have hlast := mul_le_mul_of_nonneg_left hLap hK
  have he : K*(2*Real.pi/1)=(4*Real.exp T/h)*Real.sqrt μ := by
    dsimp [K]
    field_simp
    ring
  rw [he] at hlast
  nlinarith only [hscaled,hlast]

end NeuralGeneralization.OnlineLowerTanh
