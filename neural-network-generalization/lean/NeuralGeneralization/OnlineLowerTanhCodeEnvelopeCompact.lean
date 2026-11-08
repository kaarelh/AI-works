import NeuralGeneralization.OnlineLowerTanhCodeMixture
import NeuralGeneralization.OnlineLowerTanhLocalizationPeak

/-! # Compact-frequency extraction for a retained positive envelope -/
noncomputable section
open scoped BigOperators Topology
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

theorem code_envelope_near_zero (D : ℝ) (hD : 0≤D) (H G : ℝ→ℝ)
    (hH : ∀t,0≤H t) (hG : ∀t,0≤G t) (hGH : ∀t>0,G t≤H t^2)
    (z : ℝ) (hz : 0≤z) (hsmall : ∀t>0,H t≤8*z^3*t^3)
    (hIntG : IntegrableOn (fun t=>G t/Real.sinh (Real.pi*t/2)) (Ioi 0))
    (hExp : IntegrableOn (fun t=>Real.exp (-1*t)*H t) (Ioi 0))
    (hLap : Real.sqrt D*(∫t:ℝ in Ioi 0,Real.exp (-1*t)*H t)≤Real.pi)
    (h : ℝ) (hh : 0<h) (hh1 : h≤1) :
    Real.sqrt D*(∫t : ℝ in Ioc 0 h,
      G t/Real.sinh (Real.pi*t/2)) ≤
        16*Real.exp 1*z^3*h^2 := by
  let K := (16/Real.pi)*z^3*h^2*Real.exp 1
  have hK : 0≤K := by dsimp [K]; positivity
  have hsub : Ioc 0 h ⊆ Ioi (0:ℝ) := fun t ht => ht.1
  have hInt := hIntG.mono_set hsub
  have hExpH := hExp.mono_set hsub
  have hpoint (t : ℝ) (ht : t∈Ioc 0 h) :
      G t/Real.sinh (Real.pi*t/2) ≤
        K*(Real.exp (-1*t)*H t) := by
    have htpos : 0<t := ht.1
    have hHpos := hH t
    have hfirst : G t/Real.sinh (Real.pi*t/2)≤
        8*z^3*(t^3/Real.sinh (Real.pi*t/2))*H t := by
      have hm := mul_le_mul_of_nonneg_right (hsmall t ht.1) (hH t)
      have hprod : G t≤8*z^3*t^3*H t := by nlinarith only [hGH t ht.1,hm]
      have hd := div_le_div_of_nonneg_right hprod
        (Real.sinh_pos_iff.mpr (by positivity : 0<Real.pi*t/2)).le
      convert hd using 1 <;> first | rfl | ring
    have hker := cubic_sinh_small_bound h t ht.1 ht.2
    have hsecond := mul_le_mul_of_nonneg_left hker
      (mul_nonneg (show 0≤8*z^3 by positivity) (hH t))
    have hexp : 1≤Real.exp 1*Real.exp (-1*t) := by
      rw [←Real.exp_add]
      exact Real.one_le_exp_iff.mpr (by linarith [ht.2])
    have hthird := mul_le_mul_of_nonneg_left hexp
      (show 0≤(16/Real.pi)*z^3*h^2*H t by
        positivity)
    dsimp [K]
    calc
      _ ≤ _ := hfirst
      _ ≤ (16/Real.pi)*z^3*h^2*H t := by
        simpa only [mul_pow,div_eq_mul_inv,mul_assoc,mul_comm,mul_left_comm,show (2:ℝ)*8=16 by norm_num] using hsecond
      _ ≤ _ := by simpa only [one_mul,mul_one,mul_assoc,mul_comm,mul_left_comm] using hthird
  have hI := integral_mono_ae hInt (hExpH.const_mul K) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
    exact hpoint t ht)
  rw [integral_const_mul] at hI
  have hwhole := setIntegral_mono_set hExp
    (Filter.Eventually.of_forall (fun t => mul_nonneg (Real.exp_pos _).le (hH t) : ∀t:ℝ,0≤Real.exp (-1*t)*H t))
    (Filter.Eventually.of_forall (fun t => show t∈Ioc 0 h → t∈Ioi (0:ℝ) from fun ht => ht.1))
  have hIwhole := hI.trans (mul_le_mul_of_nonneg_left hwhole hK)
  have hscaled := mul_le_mul_of_nonneg_left hIwhole (Real.sqrt_nonneg D)
  have hlast := mul_le_mul_of_nonneg_left hLap hK
  have he : K*Real.pi=16*Real.exp 1*z^3*h^2 := by
    dsimp [K]
    field_simp
  rw [he] at hlast
  nlinarith only [hscaled,hlast]


theorem code_envelope_middle (D : ℝ) (hD : 0≤D) (H G : ℝ→ℝ)
    (hH : ∀t,0≤H t) (hG : ∀t,0≤G t) (hGH : ∀t>0,G t≤H t^2)
    (hIntG : IntegrableOn (fun t=>G t/Real.sinh (Real.pi*t/2)) (Ioi 0))
    (hExp : IntegrableOn (fun t=>Real.exp (-1*t)*H t) (Ioi 0))
    (hLap : Real.sqrt D*(∫t:ℝ in Ioi 0,Real.exp (-1*t)*H t)≤Real.pi)
    (h T μ : ℝ) (hh : 0<h) (hhT : h≤T) (hμ : 0≤μ)
    (hpeak : ∀t∈Ioc h T, G t≤μ) :
    Real.sqrt D*(∫t : ℝ in Ioc h T,
      G t/Real.sinh (Real.pi*t/2)) ≤
        (2*Real.exp T/h)*Real.sqrt μ := by
  let K := (2/(Real.pi*h))*Real.exp T*Real.sqrt μ
  have hK : 0≤K := by dsimp [K]; positivity
  have hsub : Ioc h T ⊆ Ioi (0:ℝ) := fun t ht => hh.trans ht.1
  have hInt := hIntG.mono_set hsub
  have hExpH := hExp.mono_set hsub
  have hpoint (t : ℝ) (ht : t∈Ioc h T) :
      G t/Real.sinh (Real.pi*t/2) ≤
        K*(Real.exp (-1*t)*H t) := by
    have hHpos := hH t
    have hGpos := hG t
    have htpos := hh.trans ht.1
    have hs := Real.sinh_pos_iff.mpr (by positivity : 0<Real.pi*t/2)
    have hlow := Real.self_le_sinh_iff.mpr (show 0≤Real.pi*t/2 by positivity)
    have hk : 1/Real.sinh (Real.pi*t/2) ≤ 2/(Real.pi*h) := by
      apply (div_le_div_iff₀ hs (by positivity)).mpr
      nlinarith [Real.pi_pos,ht.1]
    have hp := Real.sqrt_le_sqrt (hpeak t ht)
    have hp2 : Real.sqrt (G t)≤H t := by
      have hh := Real.sqrt_le_sqrt (hGH t htpos)
      simpa only [Real.sqrt_sq (hH t)] using hh
    have hp' := mul_le_mul hp hp2 (Real.sqrt_nonneg (G t)) (Real.sqrt_nonneg μ)
    rw [←pow_two,Real.sq_sqrt (hG t)] at hp' 
    have hexp : 1≤Real.exp T*Real.exp (-1*t) := by
      rw [←Real.exp_add]
      exact Real.one_le_exp_iff.mpr (by linarith [ht.2])
    have h1 := mul_le_mul_of_nonneg_left hk (hG t)
    have h2 := mul_le_mul_of_nonneg_left hp' (show 0≤2/(Real.pi*h) by positivity)
    have h3 := mul_le_mul_of_nonneg_left hexp
      (show 0≤(2/(Real.pi*h))*Real.sqrt μ*H t by positivity)
    dsimp [K]
    calc
      _ ≤ (2/(Real.pi*h))*G t := by
        simpa only [div_eq_mul_inv,mul_assoc,mul_comm,mul_left_comm,one_mul] using h1
      _ ≤ (2/(Real.pi*h))*Real.sqrt μ*H t := by
        simpa only [mul_assoc] using h2
      _ ≤ _ := by simpa only [one_mul,mul_one,mul_assoc,mul_comm,mul_left_comm] using h3
  have hI := integral_mono_ae hInt (hExpH.const_mul K) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
    exact hpoint t ht)
  rw [integral_const_mul] at hI
  have hwhole := setIntegral_mono_set hExp
    (Filter.Eventually.of_forall (fun t => mul_nonneg (Real.exp_pos _).le (hH t) : ∀t:ℝ,0≤Real.exp (-1*t)*H t))
    (Filter.Eventually.of_forall (fun t => show t∈Ioc h T → t∈Ioi (0:ℝ) from fun ht => hsub ht))
  have hIwhole := hI.trans (mul_le_mul_of_nonneg_left hwhole hK)
  have hscaled := mul_le_mul_of_nonneg_left hIwhole (Real.sqrt_nonneg D)
  have hlast := mul_le_mul_of_nonneg_left hLap hK
  have he : K*Real.pi=(2*Real.exp T/h)*Real.sqrt μ := by
    dsimp [K]
    field_simp
  rw [he] at hlast
  nlinarith only [hscaled,hlast]


theorem code_envelope_tail (D : ℝ) (hD : 0≤D) (H G : ℝ→ℝ)
    (hH : ∀t,0≤H t) (hH1 : ∀t,H t≤1) (hG : ∀t,0≤G t) (hGH : ∀t>0,G t≤H t^2)
    (hIntG : IntegrableOn (fun t=>G t/Real.sinh (Real.pi*t/2)) (Ioi 0))
    (hExp : IntegrableOn (fun t=>Real.exp (-(Real.pi/8)*t)*H t) (Ioi 0))
    (hLap : Real.sqrt D*(∫t:ℝ in Ioi 0,Real.exp (-(Real.pi/8)*t)*H t)≤Real.pi/(Real.pi/8))
    (T : ℝ) (hT : 1≤T) :
    Real.sqrt D*(∫t : ℝ in Ioi T,
      G t/Real.sinh (Real.pi*t/2)) ≤
        (32/Real.pi)*Real.exp (-(Real.pi/8)*T) := by
  let c := Real.pi/8
  let L := (4/Real.pi)*Real.exp (-c*T)
  have hc : 0<c := by dsimp [c]; positivity
  have hL : 0≤L := by dsimp [L]; positivity
  have hsub : Ioi T ⊆ Ioi (0:ℝ) := by
    intro t ht
    have hh : T<t := ht
    show 0<t
    linarith
  have hInt := hIntG.mono_set hsub
  have hExpT := hExp.mono_set hsub
  have hI := integral_mono_ae hInt (hExpT.const_mul L) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    have hpoint := inv_sinh_tail_bound T t hT (show T≤t from le_of_lt ht)
    have h := mul_le_mul_of_nonneg_left hpoint (hG t)
    dsimp [L,c]
    have htpos : 0<t := lt_of_lt_of_le (by linarith : 0<T) (le_of_lt ht)
    have hGH' : G t≤H t := by nlinarith only [hGH t htpos,hH t,hH1 t]
    have hh := mul_le_mul_of_nonneg_left hGH' (show 0≤((4/Real.pi)*Real.exp (-(Real.pi/8)*T))*Real.exp (-(Real.pi/8)*t) by positivity)
    have h' : G t/Real.sinh (Real.pi*t/2)≤
        ((4/Real.pi)*Real.exp (-(Real.pi/8)*T))*Real.exp (-(Real.pi/8)*t)*G t := by
      simpa only [div_eq_mul_inv,one_mul,mul_comm,mul_left_comm,mul_assoc] using h
    simpa only [mul_assoc] using h'.trans hh)
  rw [integral_const_mul] at hI
  have hwhole := setIntegral_mono_set hExp
    (Filter.Eventually.of_forall (fun t => mul_nonneg (Real.exp_pos _).le (hH t)))
    (Filter.Eventually.of_forall (fun t => show t∈Ioi T → t∈Ioi (0:ℝ) from fun ht => hsub ht))
  have hIwhole := hI.trans (mul_le_mul_of_nonneg_left hwhole hL)
  have hIscaled := mul_le_mul_of_nonneg_left hIwhole (Real.sqrt_nonneg D)
  have hlast := mul_le_mul_of_nonneg_left hLap hL
  have he : L*(Real.pi/c)=(32/Real.pi)*Real.exp (-(Real.pi/8)*T) := by
    dsimp [L,c]
    field_simp
    ring
  rw [he] at hlast
  nlinarith only [hIscaled,hlast]


end NeuralGeneralization.OnlineLowerTanh
