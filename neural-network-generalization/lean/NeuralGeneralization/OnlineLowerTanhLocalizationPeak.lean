import NeuralGeneralization.OnlineLowerTanhLocalizationCompact
import NeuralGeneralization.OnlineLowerTanhLatticePeak

/-! # A competitive actual parity coefficient has a compact positive peak -/
noncomputable section
open scoped Topology
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

theorem parity_absolute_kernel_split {n r : ℕ} (hn : n=2*r+1)
    (u : Fin n → ℝ) (h T : ℝ) (hh : 0≤ h) (hhT : h≤ T) :
    (∫t : ℝ in Ioi 0,paritySineProduct u t/Real.sinh (Real.pi*t/2)) =
      (∫t : ℝ in Ioc 0 h,paritySineProduct u t/Real.sinh (Real.pi*t/2)) +
      (∫t : ℝ in Ioc h T,paritySineProduct u t/Real.sinh (Real.pi*t/2)) +
      (∫t : ℝ in Ioi T,paritySineProduct u t/Real.sinh (Real.pi*t/2)) := by
  have hi := integrable_parity_absolute_kernel hn u
  have h1 := intervalIntegral.integral_Ioi_sub_Ioi hi hh
  have h2 := intervalIntegral.integral_Ioi_sub_Ioi
    (hi.mono_set (Ioi_subset_Ioi hh)) hhT
  rw [intervalIntegral.integral_of_le hh] at h1
  rw [intervalIntegral.integral_of_le hhT] at h2
  linarith

/-- Quantitative peak extraction from three explicit mass bounds. -/
theorem parity_compact_peak_of_bounds (r : ℕ) (hr : 3≤ r)
    (u : Fin (2*r+1) → ℝ) (A β h T μ : ℝ)
    (hA : 0≤ A) (hscale : incomingScale u≤ A) (hβ : 0<β)
    (hcoef : β≤ Real.sqrt (2*r+1:ℕ)*|parityCorrelation u 0|)
    (hh : 0< h) (hh1 : h≤1) (hT : 1≤ T) (hμ : 0<μ)
    (hnear : 4*Real.exp 1*A^3*h^2≤β/4)
    (htail : (32/Real.pi)*Real.exp (-(Real.pi/8)*T)≤β/4)
    (hmid : (4*Real.exp T/h)*Real.sqrt μ≤β/4) :
    ∃t∈Ioc h T, μ< paritySineProduct u t := by
  by_contra hnone
  have hpoint : ∀t∈Ioc h T,paritySineProduct u t≤μ := by
    intro t ht
    exact le_of_not_gt (fun hp => hnone ⟨t,ht,hp⟩)
  have h0 := parity_absolute_kernel_near_zero r hr u h hh hh1
  have h1 := parity_absolute_kernel_middle r (by omega) u h T μ hh (hh1.trans hT) hμ.le hpoint
  have h2 := parity_absolute_kernel_tail rfl u T hT
  have hmass := mul_le_mul_of_nonneg_left
    (parityCorrelation_le_absolute_kernel rfl u 0) (Real.sqrt_nonneg (2*r+1:ℕ))
  have hsplit := parity_absolute_kernel_split rfl u h T hh.le (hh1.trans hT)
  have hscaled := congrArg (fun x : ℝ => Real.sqrt (2*r+1:ℕ)*x) hsplit
  have hscale3 := pow_le_pow_left₀ (incomingScale_nonneg u) hscale 3
  have hs := mul_le_mul_of_nonneg_left hscale3 (show 0≤4*Real.exp 1*h^2 by positivity)
  nlinarith only [hcoef,hmass,hscaled,h0,h1,h2,hnear,htail,hmid,hs,hβ]

/-- All numerical choices used by peak extraction can be made once,
independently of the dimension and incoming vector. -/
theorem exists_peak_parameters (A β : ℝ) (hA : 0< A) (hβ : 0<β) :
    ∃h T μ : ℝ, 0< h ∧ h≤1 ∧ 1≤ T ∧ 0<μ ∧ μ≤1/4 ∧
      4*Real.exp 1*A^3*h^2≤β/4 ∧
      (32/Real.pi)*Real.exp (-(Real.pi/8)*T)≤β/4 ∧
      (4*Real.exp T/h)*Real.sqrt μ≤β/4 := by
  let h := min 1 (Real.sqrt (β/(16*Real.exp 1*A^3)))
  have hh : 0< h := lt_min (by norm_num) (Real.sqrt_pos.mpr (by positivity))
  have hh1 : h≤1 := min_le_left _ _
  have hhsq : h^2≤β/(16*Real.exp 1*A^3) := by
    have hs := pow_le_pow_left₀ hh.le (min_le_right 1 (Real.sqrt (β/(16*Real.exp 1*A^3)))) 2
    simpa only [Real.sq_sqrt (by positivity : 0≤β/(16*Real.exp 1*A^3))] using hs
  have hnear : 4*Real.exp 1*A^3*h^2≤β/4 := by
    have hd := (le_div_iff₀ (show 0<16*Real.exp 1*A^3 by positivity)).mp hhsq
    nlinarith only [hd]
  have htend : Tendsto (fun T : ℝ => (32/Real.pi)*Real.exp (-(Real.pi/8)*T)) atTop (𝓝 0) := by
    have he := Real.tendsto_exp_neg_atTop_nhds_zero.comp
      (tendsto_id.const_mul_atTop (show 0< Real.pi/8 by positivity))
    have hm := he.const_mul (32/Real.pi)
    simpa only [Function.comp_apply,id_eq,neg_mul,mul_zero] using hm
  have hevent := (tendsto_order.mp htend).2 (β/4) (by positivity)
  obtain ⟨T,hT,hTail⟩ := (hevent.and (eventually_ge_atTop 1)).exists
  let x := β*h/(16*Real.exp T)
  let μ := min (1/4) (x^2)
  have hx : 0< x := by dsimp [x]; positivity
  have hμ : 0<μ := lt_min (by norm_num) (sq_pos_of_pos hx)
  have hμroot : Real.sqrt μ≤ x := by
    have h := Real.sqrt_le_sqrt (min_le_right (1/4) (x^2))
    simpa only [Real.sqrt_sq hx.le] using h
  have hmid : (4*Real.exp T/h)*Real.sqrt μ≤β/4 := by
    apply (mul_le_mul_of_nonneg_left hμroot (show 0≤4*Real.exp T/h by positivity)).trans
    dsimp [x]
    field_simp
    norm_num
  exact ⟨h,T,μ,hh,hh1,hTail,hμ,min_le_left _ _,hnear,hT.le,hmid⟩

/-- A single compact frequency interval and positive peak height work
for every competitive atom of every odd degree at least seven. -/
theorem exists_competitive_peak (c : ℝ) (hc : 0< c) :
    ∃h T μ : ℝ, 0< h ∧ h≤1 ∧ 1≤ T ∧ 0<μ ∧ μ≤1/4 ∧
      ∀r : ℕ, 3≤ r → ∀u : Fin (2*r+1) → ℝ,
        0 < incomingEnergy u →
        c*Real.sqrt (incomingEnergy u) ≤ (2*r+1:ℕ)*|parityCorrelation u 0| →
        ∃t∈Ioc h T, μ< paritySineProduct u t := by
  let M := 16384/Real.pi^3
  let b := Real.sqrt (c/M)
  let A := 2/c
  let β := c*b
  have hM : 0< M := by dsimp [M]; positivity
  have hb : 0< b := Real.sqrt_pos.mpr (by positivity)
  have hA : 0< A := by dsimp [A]; positivity
  have hβ : 0<β := mul_pos hc hb
  obtain ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,hnear,htail,hmid⟩ := exists_peak_parameters A β hA hβ
  refine ⟨h,T,μ,hh,hh1,hT,hμ,hμ1,?_⟩
  intro r hr u hu hcomp
  have hupper := competitive_scale_upper r u c hc hcomp
  have hlower := competitive_scale_lower_square r hr u c hc hu hcomp
  have hbz : b≤ incomingScale u := by
    have hsq : c/M≤ incomingScale u^2 := (div_le_iff₀ hM).mpr (by simpa [M,mul_comm] using hlower)
    have hs := Real.sqrt_le_sqrt hsq
    simpa only [b,Real.sqrt_sq (incomingScale_nonneg u)] using hs
  have hs := incomingScale_mul_sqrt (by omega : 0<2*r+1) u
  have hr2 := Real.sq_sqrt (show (0:ℝ)≤(2*r+1:ℕ) by positivity)
  have hroot : 0< Real.sqrt (2*r+1:ℕ) := Real.sqrt_pos.mpr (by positivity)
  have hscore : c*incomingScale u≤ Real.sqrt (2*r+1:ℕ)*|parityCorrelation u 0| := by
    apply (mul_le_mul_iff_left₀ hroot).mp
    rw [←hs] at hcomp
    calc
      c*incomingScale u*Real.sqrt (2*r+1:ℕ) = c*(incomingScale u*Real.sqrt (2*r+1:ℕ)) := by ring
      _ ≤ _ := hcomp
      _ = (Real.sqrt (2*r+1:ℕ)*|parityCorrelation u 0|)*Real.sqrt (2*r+1:ℕ) := by
        rw [mul_right_comm,←pow_two,hr2]
  have hcoef : β≤ Real.sqrt (2*r+1:ℕ)*|parityCorrelation u 0| :=
    (mul_le_mul_of_nonneg_left hbz hc.le).trans hscore
  exact parity_compact_peak_of_bounds r hr u A β h T μ hA.le hupper hβ hcoef
    hh hh1 hT hμ hnear htail hmid

end NeuralGeneralization.OnlineLowerTanh
