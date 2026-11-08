import NeuralGeneralization.OnlineLowerTanhProductLaplace
import NeuralGeneralization.OnlineLowerTanhSineIntegrable

/-! # Uniform tails of the actual absolute tanh Fourier kernel -/
noncomputable section
open MeasureTheory Set
namespace NeuralGeneralization.OnlineLowerTanh

theorem inv_sinh_exp_bound (b t : ℝ) (hb : 0<b) (ht : 1≤t) :
    1/Real.sinh (b*t) ≤ (2/b)*Real.exp (-(b/2)*t) := by
  have htpos : 0<t := lt_of_lt_of_le (by norm_num) ht
  have hs := Real.sinh_pos_iff.mpr (mul_pos hb htpos)
  have hl := sinh_exp_lower (b*t) (mul_pos hb htpos).le
  have hm := mul_le_mul_of_nonneg_right hl
    (show 0≤(2/b)*Real.exp (-(b/2)*t) by positivity)
  have he : Real.exp (b*t/2)*Real.exp (-(b/2)*t)=1 := by
    rw [← Real.exp_add]
    convert Real.exp_zero using 1 <;> ring
  have hid : (b*t/2*Real.exp (b*t/2))*((2/b)*Real.exp (-(b/2)*t))=t := by
    calc
      _ = (b*t/2)*(2/b)*(Real.exp (b*t/2)*Real.exp (-(b/2)*t)) := by ring
      _ = t := by rw [he]; field_simp
  rw [hid] at hm
  exact (div_le_iff₀ hs).mpr (by nlinarith only [ht,hm])

theorem inv_sinh_tail_bound (T t : ℝ) (hT : 1≤T) (ht : T≤t) :
    1/Real.sinh (Real.pi*t/2) ≤
      ((4/Real.pi)*Real.exp (-(Real.pi/8)*T))*Real.exp (-(Real.pi/8)*t) := by
  have h := inv_sinh_exp_bound (Real.pi/2) t (by positivity) (hT.trans ht)
  have he : Real.exp (-((Real.pi/2)/2)*t)=
      Real.exp (-(Real.pi/8)*t)*Real.exp (-(Real.pi/8)*t) := by
    rw [← Real.exp_add]
    congr 1
    ring
  rw [show Real.pi/2*t=Real.pi*t/2 by ring,show 2/(Real.pi/2)=4/Real.pi by field_simp; ring,he] at h
  have hmono : Real.exp (-(Real.pi/8)*t) ≤ Real.exp (-(Real.pi/8)*T) := by
    apply Real.exp_le_exp.mpr
    nlinarith [Real.pi_pos]
  calc
    _ ≤ _ := h
    _ = ((4/Real.pi)*Real.exp (-(Real.pi/8)*t))*Real.exp (-(Real.pi/8)*t) := by ring
    _ ≤ _ := mul_le_mul_of_nonneg_right
      (mul_le_mul_of_nonneg_left hmono (by positivity)) (Real.exp_pos _).le

theorem parity_absolute_kernel_tail {n r : ℕ} (hn : n=2*r+1)
    (u : Fin n → ℝ) (T : ℝ) (hT : 1≤T) :
    Real.sqrt (n:ℝ)*(∫t : ℝ in Ioi T,
      paritySineProduct u t/Real.sinh (Real.pi*t/2)) ≤
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
  obtain ⟨hExp,hExpBound⟩ := paritySineProduct_laplace (by omega : 0<n) u c hc
  have hInt := (integrable_parity_absolute_kernel hn u).mono_set hsub
  have hExpT := hExp.mono_set hsub
  have hI := integral_mono_ae hInt (hExpT.const_mul L) (by
    filter_upwards [ae_restrict_mem measurableSet_Ioi] with t ht
    have hpoint := inv_sinh_tail_bound T t hT (show T≤t from le_of_lt ht)
    have h := mul_le_mul_of_nonneg_left hpoint (paritySineProduct_nonneg u t)
    dsimp [L,c]
    convert h using 1 <;> ring)
  rw [integral_const_mul] at hI
  have hwhole := setIntegral_mono_set hExp
    (Filter.Eventually.of_forall (fun t => mul_nonneg (Real.exp_pos _).le (paritySineProduct_nonneg u t)))
    (Filter.Eventually.of_forall (fun t => show t∈Ioi T → t∈Ioi (0:ℝ) from fun ht => hsub ht))
  have hIwhole := hI.trans (mul_le_mul_of_nonneg_left hwhole hL)
  have hIscaled := mul_le_mul_of_nonneg_left hIwhole (Real.sqrt_nonneg (n:ℝ))
  have hlast := mul_le_mul_of_nonneg_left hExpBound hL
  have he : L*(Real.pi/c)=(32/Real.pi)*Real.exp (-(Real.pi/8)*T) := by
    dsimp [L,c]
    field_simp
    ring
  rw [he] at hlast
  nlinarith only [hIscaled,hlast]

end NeuralGeneralization.OnlineLowerTanh
