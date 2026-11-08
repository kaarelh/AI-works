import NeuralGeneralization.OnlineLowerTanhCodeNearZero
import NeuralGeneralization.OnlineLowerTanhLocalizationScale

/-! # Scale control for actual transversal products -/
noncomputable section
open scoped BigOperators
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

/-- The absolute full-code frequency integral has a cubic small-scale
bound. This also establishes its integrability without a retained-code
or an odd-degree hypothesis. -/
theorem trimmedRailProduct_kernel_cubic (p r : ℕ) (hp : 2≤p) (hr : 1≤r)
    (hD : 6≤p*(2*r)) (a b : Fin p→Fin (2*r)→ℝ) (z : ℝ) (hz : 0≤z)
    (he : (∑ i : Fin p,∑ k : Fin (2*r),((a i k)^2+(b i k)^2))≤(p*(2*r):ℕ)*z^2) :
    IntegrableOn (fun t => trimmedRailProduct p (2*r) a b t / Real.sinh (Real.pi*t/2)) (Ioi 0) ∧
    Real.sqrt ((p*r:ℕ):ℝ)*(∫ t : ℝ in Ioi 0,
      trimmedRailProduct p (2*r) a b t / Real.sinh (Real.pi*t/2)) ≤
        (65536/Real.pi^3)*z^3 := by
  let c : ℝ := Real.pi/8
  let K : ℝ := 8192/Real.pi^3
  have hc : 0<c := by dsimp [c];positivity
  obtain ⟨hInt,hLap⟩ := sqrt_trimmedRailProduct_laplace p r hp hr a b c hc
  have hpoint (t : ℝ) (ht : 0<t) :
      trimmedRailProduct p (2*r) a b t / Real.sinh (Real.pi*t/2) ≤
        (K*z^3)*(Real.exp (-c*t)*Real.sqrt (trimmedRailProduct p (2*r) a b t)) := by
    have hcube := sqrt_trimmedRailProduct_cubic p (2*r) (by omega) (by omega) hD a b t z ht.le hz he
    have hs0 := Real.sqrt_nonneg (trimmedRailProduct p (2*r) a b t)
    have hsq := Real.sq_sqrt (trimmedRailProduct_nonneg p (2*r) a b t)
    have hprod := mul_le_mul_of_nonneg_right hcube hs0
    have hker := cubic_sinh_exp_bound (Real.pi/2) t (by positivity) ht
    have heK : 8*(128/(Real.pi/2)^3)=K := by dsimp [K];field_simp;ring
    have hec : -((Real.pi/2)/4)*t = -c*t := by dsimp [c];ring
    rw [hec,show Real.pi/2*t=Real.pi*t/2 by ring] at hker
    have hsin : 0<Real.sinh (Real.pi*t/2) := Real.sinh_pos_iff.mpr (by positivity)
    have hfirst := div_le_div_of_nonneg_right hprod hsin.le
    rw [←pow_two,hsq] at hfirst
    have hsecond := mul_le_mul_of_nonneg_right hker
      (mul_nonneg (show 0≤8*z^3 by positivity) hs0)
    apply hfirst.trans
    convert hsecond using 1 <;> (try dsimp [K]) <;> field_simp <;> ring
  have hi : IntegrableOn (fun t => trimmedRailProduct p (2*r) a b t / Real.sinh (Real.pi*t/2)) (Ioi 0) := by
    apply (hInt.const_mul (K*z^3)).mono'
    · apply Measurable.aestronglyMeasurable
      unfold trimmedRailProduct
      fun_prop
    · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      have htpos : 0<t := ht
      rw [Real.norm_eq_abs,abs_of_nonneg (div_nonneg (trimmedRailProduct_nonneg _ _ _ _ _)
        (Real.sinh_pos_iff.mpr (by positivity)).le)]
      exact hpoint t ht
  refine ⟨hi,?_⟩
  have hI := integral_mono_ae hi (hInt.const_mul (K*z^3)) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    exact hpoint t ht)
  rw [integral_const_mul] at hI
  have hI' := mul_le_mul_of_nonneg_left hI (Real.sqrt_nonneg ((p*r:ℕ):ℝ))
  have hL := mul_le_mul_of_nonneg_left hLap (show 0≤K*z^3 by dsimp [K];positivity)
  have heq : (K*z^3)*(Real.pi/c)=(65536/Real.pi^3)*z^3 := by
    dsimp [K,c]
    field_simp
    ring
  rw [heq] at hL
  nlinarith only [hI',hL]

/-- The elementary exponential estimate that gives a square-root scale
bound after summing the csch Laplace mixture. -/
theorem sqrt_time_exp_bound (c t : ℝ) (hc : 0<c) (ht : 0≤t) :
    Real.sqrt t*Real.exp (-c*t) ≤ (1/Real.sqrt c)*Real.exp (-(c/2)*t) := by
  have hct : c*t≤Real.exp (c*t) := by linarith [Real.add_one_le_exp (c*t)]
  have hs := Real.sqrt_le_sqrt hct
  have hexp : Real.sqrt (Real.exp (c*t))=Real.exp (c*t/2) := (Real.exp_half _).symm
  rw [Real.sqrt_mul hc.le,hexp] at hs
  have h := mul_le_mul_of_nonneg_right hs (Real.exp_pos (-c*t)).le
  have he : Real.exp (c*t/2)*Real.exp (-c*t)=Real.exp (-(c/2)*t) := by
    rw [←Real.exp_add];congr 1;ring
  rw [mul_assoc,he] at h
  have hd : Real.sqrt t*Real.exp (-c*t) ≤ Real.exp (-(c/2)*t)/Real.sqrt c :=
    (le_div_iff₀ (Real.sqrt_pos.mpr hc)).mpr (by nlinarith only [h])
  simpa only [div_eq_mul_inv,one_mul,mul_comm] using hd


/-- A uniform Laplace estimate with square-root dependence on the RMS
scale. The c^(-3/2) factor is summable over the csch frequencies. -/
theorem trimmedRailProduct_laplace_sqrt_scale (p r : ℕ) (hp : 2≤p) (hr : 1≤r)
    (a b : Fin p→Fin (2*r)→ℝ) (z c : ℝ) (hz : 0≤z) (hc : 0<c)
    (he : (∑ i : Fin p,∑ k : Fin (2*r),((a i k)^2+(b i k)^2))≤(p*(2*r):ℕ)*z^2) :
    IntegrableOn (fun t => Real.exp (-c*t)*trimmedRailProduct p (2*r) a b t) (Ioi 0) ∧
    Real.sqrt ((p*r:ℕ):ℝ)*(∫ t : ℝ in Ioi 0,
      Real.exp (-c*t)*trimmedRailProduct p (2*r) a b t) ≤
        (2*Real.pi*Real.sqrt (2*z))/(c*Real.sqrt c) := by
  have hc2 : 0<c/2 := by positivity
  obtain ⟨hi,hL⟩ := sqrt_trimmedRailProduct_laplace p r hp hr a b (c/2) hc2
  let K : ℝ := Real.sqrt (2*z)/Real.sqrt c
  have hK : 0≤K := by dsimp [K];positivity
  have hpoint (t : ℝ) (ht : 0≤t) :
      Real.exp (-c*t)*trimmedRailProduct p (2*r) a b t ≤
        K*(Real.exp (-(c/2)*t)*Real.sqrt (trimmedRailProduct p (2*r) a b t)) := by
    have hF := trimmedRailProduct_nonneg p (2*r) a b t
    have hs := Real.sqrt_le_sqrt (trimmedRailProduct_linear p (2*r)
      (by omega) (by omega) a b t z ht hz he)
    rw [Real.sqrt_mul (by positivity : 0≤2*z)] at hs
    have hm := mul_le_mul_of_nonneg_right hs (Real.sqrt_nonneg (trimmedRailProduct p (2*r) a b t))
    rw [←pow_two,Real.sq_sqrt hF] at hm
    have hm' := mul_le_mul_of_nonneg_left hm (Real.exp_pos (-c*t)).le
    have htE := sqrt_time_exp_bound c t hc ht
    have htE' := mul_le_mul_of_nonneg_right htE
      (mul_nonneg (Real.sqrt_nonneg (2*z)) (Real.sqrt_nonneg (trimmedRailProduct p (2*r) a b t)))
    apply hm'.trans
    convert htE' using 1 <;> (try dsimp [K]) <;> ring
  have hInt : IntegrableOn (fun t => Real.exp (-c*t)*trimmedRailProduct p (2*r) a b t) (Ioi 0) := by
    apply (hi.const_mul K).mono'
    · apply Measurable.aestronglyMeasurable
      unfold trimmedRailProduct
      fun_prop
    · filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
      rw [Real.norm_eq_abs,abs_of_nonneg (mul_nonneg (Real.exp_pos _).le (trimmedRailProduct_nonneg _ _ _ _ _))]
      exact hpoint t (le_of_lt ht)
  refine ⟨hInt,?_⟩
  have hI := integral_mono_ae hInt (hi.const_mul K) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    exact hpoint t (le_of_lt ht))
  rw [integral_const_mul] at hI
  have hI' := mul_le_mul_of_nonneg_left hI (Real.sqrt_nonneg ((p*r:ℕ):ℝ))
  have hL' := mul_le_mul_of_nonneg_left hL hK
  have heq : K*(Real.pi/(c/2))=(2*Real.pi*Real.sqrt (2*z))/(c*Real.sqrt c) := by
    dsimp [K]
    field_simp
  rw [heq] at hL'
  nlinarith only [hI',hL']

end NeuralGeneralization.OnlineLowerTanh
