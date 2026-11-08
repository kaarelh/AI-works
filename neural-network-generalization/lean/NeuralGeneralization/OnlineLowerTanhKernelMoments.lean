import NeuralGeneralization.OnlineLowerTanhKernelTaylor
import Mathlib.Analysis.SpecificLimits.Normed

/-! Uniform first and second Taylor estimates for the bias-derivative
kernels t/sinh and t²/sinh on every sine cell. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology
open Set
namespace NeuralGeneralization.OnlineLowerTanh

def residualWeightedKernelFirst (j:ℕ) (t:ℝ) : ℝ :=
  match j with
  | 0 => residualKernelFirst t
  | 1 => residualDerivativeKernel 0 t+t*residualKernelFirst t
  | _ => 2*t*residualDerivativeKernel 0 t+t^2*residualKernelFirst t

def residualWeightedKernelSecond (j:ℕ) (t:ℝ) : ℝ :=
  match j with
  | 0 => residualKernelSecond t
  | 1 => 2*residualKernelFirst t+t*residualKernelSecond t
  | _ => 2*residualDerivativeKernel 0 t+4*t*residualKernelFirst t+t^2*residualKernelSecond t

lemma residualDerivativeKernel_factor (j:ℕ) (t:ℝ) :
    residualDerivativeKernel j t=t^j*residualDerivativeKernel 0 t := by
  simp [residualDerivativeKernel,div_eq_mul_inv]

lemma residualWeightedKernel_hasDerivAt (j:ℕ) (hj:j≤2) {t:ℝ} (ht:0<t) :
    HasDerivAt (residualDerivativeKernel j) (residualWeightedKernelFirst j t) t := by
  interval_cases j
  · exact residualKernel_hasDerivAt ht
  · have h:=(hasDerivAt_id t).mul (residualKernel_hasDerivAt ht)
    convert h using 1 <;> try rfl
    · funext x; simpa only [pow_one,id_eq,Pi.mul_apply] using residualDerivativeKernel_factor 1 x
    · simp [residualWeightedKernelFirst]
  · have h:=((hasDerivAt_id t).pow 2).mul (residualKernel_hasDerivAt ht)
    convert h using 1 <;> try rfl
    · funext x; simpa only [id_eq,Pi.pow_apply,Pi.mul_apply] using residualDerivativeKernel_factor 2 x
    · simp [residualWeightedKernelFirst]

lemma residualWeightedKernelFirst_hasDerivAt (j:ℕ) (hj:j≤2) {t:ℝ} (ht:0<t) :
    HasDerivAt (residualWeightedKernelFirst j) (residualWeightedKernelSecond j t) t := by
  interval_cases j
  · exact residualKernelFirst_hasDerivAt ht
  · have h:=(residualKernel_hasDerivAt ht).add
      ((hasDerivAt_id t).mul (residualKernelFirst_hasDerivAt ht))
    convert h using 1 <;> try rfl
    simp [residualWeightedKernelSecond]
    ring
  · have h:=(((hasDerivAt_id t).const_mul 2).mul (residualKernel_hasDerivAt ht)).add
      (((hasDerivAt_id t).pow 2).mul (residualKernelFirst_hasDerivAt ht))
    convert h using 1 <;> try rfl
    simp [residualWeightedKernelSecond]
    ring

lemma residualPeak_cell_upper_four {a x:ℝ} (ha:1≤a) (l:ℕ)
    (hx:|x|≤Real.pi/(2*a)) : residualPeak a l+x≤4*((l:ℝ)+1) := by
  have ha0:0<a := by linarith
  have hx1: x≤Real.pi/(2*a) := (abs_le.mp hx).2
  have he : residualPeak a l+Real.pi/(2*a)=((l:ℝ)+1)*Real.pi/a := by
    unfold residualPeak periodicFrequency
    field_simp
    ring
  have hp:((l:ℝ)+1)*Real.pi/a≤4*((l:ℝ)+1) := by
    apply (div_le_iff₀ ha0).mpr
    have hl:0≤(l:ℝ)+1 := by positivity
    nlinarith [Real.pi_lt_four]
  linarith

def residualMomentEnvelope (l:ℕ) : ℝ :=
  16384*((l:ℝ)+1)^2*Real.exp (-(l:ℝ))

lemma residualMomentEnvelope_nonneg (l:ℕ) : 0≤residualMomentEnvelope l := by
  unfold residualMomentEnvelope
  positivity

lemma residualWeightedKernel_cell_bounds (j:ℕ) (hj:j≤2)
    {a x:ℝ} (ha:1≤a) (ha2:a≤2) (l:ℕ) (hx:|x|≤Real.pi/(2*a))
    (hcut:Real.pi/8≤residualPeak a l+x) :
    |residualDerivativeKernel j (residualPeak a l+x)|≤residualMomentEnvelope l ∧
    |residualWeightedKernelFirst j (residualPeak a l+x)|≤residualMomentEnvelope l ∧
    |residualWeightedKernelSecond j (residualPeak a l+x)|≤residualMomentEnvelope l := by
  let t:=residualPeak a l+x
  let L:ℝ:=(l:ℝ)+1
  let E:=Real.exp (-(l:ℝ))
  have ht0:0≤t := le_trans (by positivity) hcut
  have ht:t≤4*L := residualPeak_cell_upper_four ha l hx
  have hL:1≤L := by dsimp [L]; linarith [Nat.cast_nonneg (α:=ℝ) l]
  have hE:0≤E := (Real.exp_pos _).le
  have hLe:E≤L^2*E := by nlinarith [mul_nonneg (sq_nonneg (L-1)) hE]
  have htE:t*E≤4*(L^2*E) := by
    have hh:=mul_le_mul_of_nonneg_right ht hE
    have hLL:L*E≤L^2*E := by nlinarith [mul_nonneg (show 0≤L*(L-1) by positivity) hE]
    nlinarith
  have ht2E:t^2*E≤16*(L^2*E) := by
    have hh: t^2≤16*L^2 := by nlinarith
    nlinarith [mul_le_mul_of_nonneg_right hh hE]
  obtain ⟨h0,h1,h2⟩:=residualKernel_cell_bounds ha ha2 l hx hcut
  change |residualDerivativeKernel 0 t|≤4*E at h0
  change |residualKernelFirst t|≤32*E at h1
  change |residualKernelSecond t|≤512*E at h2
  have h0t:=mul_le_mul_of_nonneg_left h0 ht0
  have h1t:=mul_le_mul_of_nonneg_left h1 ht0
  have h2t:=mul_le_mul_of_nonneg_left h2 ht0
  have h0tt:=mul_le_mul_of_nonneg_left h0 (sq_nonneg t)
  have h1tt:=mul_le_mul_of_nonneg_left h1 (sq_nonneg t)
  have h2tt:=mul_le_mul_of_nonneg_left h2 (sq_nonneg t)
  change |residualDerivativeKernel j t|≤16384*L^2*E ∧
    |residualWeightedKernelFirst j t|≤16384*L^2*E ∧
    |residualWeightedKernelSecond j t|≤16384*L^2*E
  interval_cases j
  · simpa only [residualWeightedKernelFirst,residualWeightedKernelSecond] using
      (show |residualDerivativeKernel 0 t|≤16384*L^2*E ∧
        |residualKernelFirst t|≤16384*L^2*E ∧ |residualKernelSecond t|≤16384*L^2*E by
        constructor; nlinarith; constructor <;> nlinarith)
  · rw [residualDerivativeKernel_factor]
    simp only [pow_one,residualWeightedKernelFirst,residualWeightedKernelSecond,
      abs_mul,abs_of_nonneg ht0]
    have h01:=abs_add_le (residualDerivativeKernel 0 t) (t*residualKernelFirst t)
    have h12:=abs_add_le (2*residualKernelFirst t) (t*residualKernelSecond t)
    norm_num only [abs_mul,abs_of_nonneg ht0] at h01 h12
    constructor; nlinarith
    constructor <;> nlinarith
  · rw [residualDerivativeKernel_factor]
    simp only [residualWeightedKernelFirst,residualWeightedKernelSecond,
      abs_mul,abs_pow,abs_of_nonneg ht0]
    have h01:=abs_add_le (2*t*residualDerivativeKernel 0 t) (t^2*residualKernelFirst t)
    have h012: |2*residualDerivativeKernel 0 t+4*t*residualKernelFirst t+t^2*residualKernelSecond t|≤
        |2*residualDerivativeKernel 0 t|+|4*t*residualKernelFirst t|+|t^2*residualKernelSecond t| :=
      (abs_add_le _ _).trans (add_le_add (abs_add_le _ _) le_rfl)
    norm_num only [abs_mul,abs_pow,abs_of_nonneg ht0] at h01 h012
    constructor; nlinarith
    constructor <;> nlinarith

lemma residualMomentEnvelope_summable : Summable residualMomentEnvelope := by
  have h:= (Real.summable_pow_mul_exp_neg_nat_mul 2 (r:=1) (by norm_num)).comp_injective Nat.succ_injective
  have hh:=h.mul_left (16384*Real.exp 1)
  apply hh.congr
  intro l
  dsimp [residualMomentEnvelope]
  simp only [Function.comp_apply,Nat.succ_eq_add_one,Nat.cast_add,Nat.cast_one,neg_one_mul]
  have he:Real.exp 1*Real.exp (-((l:ℝ)+1))=Real.exp (-(l:ℝ)) := by
    rw [←Real.exp_add]
    congr 1
    ring
  calc
    _ = 16384*((l:ℝ)+1)^2*(Real.exp 1*Real.exp (-((l:ℝ)+1))) := by ring
    _ = _ := by rw [he]

lemma residualWeightedKernel_center_bounds (j:ℕ) (hj:j≤2)
    {a:ℝ} (ha:1≤a) (ha2:a≤2) (l:ℕ) :
    |residualDerivativeKernel j (residualPeak a l)|≤residualMomentEnvelope l ∧
    |residualWeightedKernelFirst j (residualPeak a l)|≤residualMomentEnvelope l ∧
    |residualWeightedKernelSecond j (residualPeak a l)|≤residualMomentEnvelope l := by
  simpa only [add_zero] using residualWeightedKernel_cell_bounds j hj (x:=0) ha ha2 l
    (by simp; positivity) (by simpa using residualPeak_above_cutoff ha ha2 l)

lemma residualWeightedKernel_cell_taylor (j:ℕ) (hj:j≤2)
    {a x:ℝ} (ha:1≤a) (ha2:a≤2) (l:ℕ) (hx:|x|≤Real.pi/(2*a))
    (hcut:Real.pi/8≤residualPeak a l+x) :
    |residualDerivativeKernel j (residualPeak a l+x)-
      residualDerivativeKernel j (residualPeak a l)-residualWeightedKernelFirst j (residualPeak a l)*x|≤
        residualMomentEnvelope l*x^2 := by
  have hc:=residualPeak_above_cutoff ha ha2 l
  have hseg (z:ℝ) (hz:z∈uIcc (residualPeak a l) (residualPeak a l+x)) :
      Real.pi/8≤z ∧ |z-residualPeak a l|≤Real.pi/(2*a) := by
    exact ⟨le_trans (le_min hc hcut) hz.1,
      (abs_sub_left_of_mem_uIcc hz).trans (by simpa using hx)⟩
  have ht (z:ℝ) (hz:z∈uIcc (residualPeak a l) (residualPeak a l+x)) : 0<z :=
    lt_of_lt_of_le (by positivity : (0:ℝ)<Real.pi/8) (hseg z hz).1
  have hb (z:ℝ) (hz:z∈uIcc (residualPeak a l) (residualPeak a l+x)) :
      |residualWeightedKernelSecond j z|≤residualMomentEnvelope l := by
    have hh:=(residualWeightedKernel_cell_bounds j hj ha ha2 l (hseg z hz).2
      (by simpa using (hseg z hz).1)).2.2
    simpa using hh
  have hh:=second_derivative_remainder_bound (residualDerivativeKernel j)
    (residualWeightedKernelFirst j) (residualWeightedKernelSecond j)
    (residualPeak a l) (residualPeak a l+x) (residualMomentEnvelope l)
    (residualMomentEnvelope_nonneg l)
    (fun z hz=>residualWeightedKernel_hasDerivAt j hj (ht z hz))
    (fun z hz=>residualWeightedKernelFirst_hasDerivAt j hj (ht z hz)) hb
  simpa only [add_sub_cancel_left] using hh

lemma residualWeightedKernel_small_interval_pointwise (j n:ℕ)
    {a t:ℝ} (ha:1≤a) (ha2:a≤2) (ht:0<t) (htcut:t≤Real.pi/8) :
    |Real.sin (a*t)^(n+1)*residualDerivativeKernel j t|≤
      (4/Real.pi)*(Real.pi/4)^n := by
  have ht1:t≤1 := by linarith [Real.pi_lt_four]
  have hp:t^j≤1 := pow_le_one₀ ht.le ht1
  have h0:=residualKernel_small_interval_pointwise ha ha2 ht htcut n
  have he:Real.sin (a*t)^(n+1)*residualDerivativeKernel j t=
      t^j*(Real.sin (a*t)^(n+1)/Real.sinh (Real.pi*t/2)) := by
    unfold residualDerivativeKernel
    ring
  rw [he,abs_mul,abs_of_nonneg (pow_nonneg ht.le j)]
  exact (mul_le_mul_of_nonneg_right hp (abs_nonneg _)).trans (by simpa using h0)

end NeuralGeneralization.OnlineLowerTanh
