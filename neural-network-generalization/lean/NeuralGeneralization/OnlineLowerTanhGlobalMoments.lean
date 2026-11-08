import NeuralGeneralization.OnlineLowerTanhQuantitativeMoments
import NeuralGeneralization.OnlineLowerTanhGlobalSaddle
import NeuralGeneralization.OnlineLowerTanhBiasIntegral

/-! Summed quantitative approximation for actual bias derivative kernels. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology Classical
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

def residualMomentSum : ℝ := ∑' l:ℕ, residualMomentEnvelope l
lemma residualMomentSum_nonneg : 0≤residualMomentSum :=
  tsum_nonneg residualMomentEnvelope_nonneg

def balancedMomentMain (n j : ℕ) (a B θ : ℝ) (l : ℕ) : ℝ :=
  balancedCellScale n a * (-1 : ℝ)^(n*l) *
    (residualDerivativeKernel j (residualPeak a l) * balancedCellGaussian n a B *
      Real.sin (B*residualPeak a l+θ))

def balancedMomentLinear (n j : ℕ) (a B θ : ℝ) (l : ℕ) : ℝ :=
  balancedCellScale n a * (-1 : ℝ)^(n*l) *
    ((balancedCellScale n a)^2 * B * residualWeightedKernelFirst j (residualPeak a l) *
      balancedCellGaussian n a B * Real.cos (B*residualPeak a l+θ))

def balancedMomentActual (n j : ℕ) (a B θ : ℝ) (l : ℕ) : ℝ :=
  ∫ t : ℝ in Ioc ((l : ℝ)*(Real.pi/a)) (((l : ℝ)+1)*(Real.pi/a)) ∩ Ici (Real.pi/8),
    residualRawKernel (fun _ : Fin n => a) B θ (residualDerivativeKernel j) t

lemma balancedMomentMain_abs (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) (l : ℕ) :
    |balancedMomentMain n j a B θ l| ≤
      (balancedCellScale n a * balancedCellGaussian n a B) * residualMomentEnvelope l := by
  have hs := (balancedCellScale_pos hn (show 0 < a by linarith)).le
  have hG := balancedCellGaussian_nonneg n a B
  have hE := residualMomentEnvelope_nonneg l
  have hk := (residualWeightedKernel_center_bounds j hj ha ha2 l).1
  unfold balancedMomentMain
  rw [abs_mul, abs_mul, abs_of_nonneg hs, abs_pow, abs_neg, abs_one, one_pow, mul_one,
    abs_mul, abs_mul, abs_of_nonneg hG]
  calc
    _ ≤ balancedCellScale n a * ((residualMomentEnvelope l)*balancedCellGaussian n a B*1) := by
      gcongr
      exact Real.abs_sin_le_one _
    _ = _ := by ring

lemma balancedMomentLinear_abs (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) (l : ℕ) :
    |balancedMomentLinear n j a B θ l| ≤
      balancedCellScale n a * residualMomentEnvelope l *
        ((balancedCellScale n a)^2* |B| *balancedCellGaussian n a B) := by
  have hs := (balancedCellScale_pos hn (show 0 < a by linarith)).le
  have hG := balancedCellGaussian_nonneg n a B
  have hE := residualMomentEnvelope_nonneg l
  have hk := (residualWeightedKernel_center_bounds j hj ha ha2 l).2.1
  unfold balancedMomentLinear
  simp only [abs_mul, abs_pow, abs_of_nonneg hs, abs_neg, abs_one, one_pow,
    mul_one, abs_of_nonneg hG]
  calc
    _ ≤ balancedCellScale n a *
      ((balancedCellScale n a)^2* |B| *(residualMomentEnvelope l)*balancedCellGaussian n a B*1) := by
      gcongr
      exact Real.abs_cos_le_one _
    _ = _ := by ring

lemma balancedMoment_two_term_error (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) (l : ℕ) :
    |balancedMomentActual n j a B θ l -
      (balancedMomentMain n j a B θ l + balancedMomentLinear n j a B θ l)| ≤
      balancedCellScale n a * (residualMomentEnvelope l)/(n : ℝ)*saddleRemainderConstant := by
  have hs := (balancedCellScale_pos hn (show 0 < a by linarith)).le
  have hh := mul_le_mul_of_nonneg_left (balancedMomentCell_oscillatory_error j hj hn ha ha2 l B θ) hs
  rw [balancedMomentActual, balancedMomentCell_integral j hn (show 0 < a by linarith)]
  have he : balancedMomentMain n j a B θ l + balancedMomentLinear n j a B θ l =
      balancedCellScale n a * (-1 : ℝ)^(n*l) *
      (residualDerivativeKernel j (residualPeak a l)*Real.sqrt (2*Real.pi)*
        Real.exp (-(B*balancedCellScale n a)^2/2)*Real.sin (B*residualPeak a l+θ) +
       balancedCellScale n a*residualWeightedKernelFirst j (residualPeak a l)*Real.sqrt (2*Real.pi)*
        (B*balancedCellScale n a)*Real.exp (-(B*balancedCellScale n a)^2/2)*
          Real.cos (B*residualPeak a l+θ)) := by
    unfold balancedMomentMain balancedMomentLinear balancedCellGaussian
    ring
  rw [he, ← mul_sub, abs_mul, abs_mul, abs_of_nonneg hs]
  simp only [abs_pow, abs_neg, abs_one, one_pow, mul_one]
  convert hh using 1 <;> first | rfl | (simp only [saddleRemainderConstant]; ring)

lemma balancedMoment_main_error (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) (l : ℕ) :
    |balancedMomentActual n j a B θ l - balancedMomentMain n j a B θ l| ≤
      (balancedCellScale n a * (saddleRemainderConstant/(n : ℝ) +
        (balancedCellScale n a)^2* |B| *balancedCellGaussian n a B)) * residualMomentEnvelope l := by
  have ht := abs_sub_le (balancedMomentActual n j a B θ l)
    (balancedMomentMain n j a B θ l + balancedMomentLinear n j a B θ l) (balancedMomentMain n j a B θ l)
  rw [add_sub_cancel_left] at ht
  have he := balancedMoment_two_term_error j hj hn ha ha2 B θ l
  have hl := balancedMomentLinear_abs j hj hn ha ha2 B θ l
  calc
    _ ≤ _ := ht.trans (add_le_add he hl)
    _ = _ := by ring

lemma balancedMomentMain_summable (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) : Summable (balancedMomentMain n j a B θ) := by
  apply Summable.of_norm_bounded (residualMomentEnvelope_summable.mul_left
    (balancedCellScale n a*balancedCellGaussian n a B))
  intro l
  simpa only [Real.norm_eq_abs] using balancedMomentMain_abs j hj hn ha ha2 B θ l

/-- Summing the actual integrals preserves the explicit Gaussian damping
of the first-order bias correction. -/
theorem balancedMoment_cutoff_main_error (j:ℕ) (hj:j≤2) {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) :
    |(∫ t : ℝ in Ioi (Real.pi/8),
       residualRawKernel (fun _ : Fin n => a) B θ (residualDerivativeKernel j) t) -
      ∑' l : ℕ, balancedMomentMain n j a B θ l| ≤
      balancedCellScale n a * (saddleRemainderConstant/(n : ℝ) +
        (balancedCellScale n a)^2* |B| *balancedCellGaussian n a B) * residualMomentSum := by
  have ha0 : 0 < a := by linarith
  have hf := residualRawKernel_integrable hn (fun _ : Fin n => a) B θ j
  have hs := hasSum_integral_truncated_cells _ hf (Real.pi/a) (Real.pi/8)
    (by positivity) (by positivity)
  change HasSum (balancedMomentActual n j a B θ) _ at hs
  have hm := balancedMomentMain_summable j hj hn ha ha2 B θ
  rw [← hs.tsum_eq, ← hs.summable.tsum_sub hm]
  have habs := norm_tsum_le_tsum_norm (hs.summable.sub hm).norm
  have hbound := Summable.tsum_le_tsum
    (fun l => by simpa only [Real.norm_eq_abs] using balancedMoment_main_error j hj hn ha ha2 B θ l)
    (hs.summable.sub hm).norm
    (residualMomentEnvelope_summable.mul_left
      (balancedCellScale n a*(saddleRemainderConstant/(n : ℝ)+
        (balancedCellScale n a)^2* |B| *balancedCellGaussian n a B)))
  have hfinal := habs.trans hbound
  rw [tsum_mul_left] at hfinal
  simpa only [Real.norm_eq_abs, residualMomentSum] using hfinal



lemma balancedMomentRaw_small_integral (j:ℕ) {n:ℕ} (hn:0<n) {a:ℝ}
    (ha:1≤a) (ha2:a≤2) (B θ:ℝ) :
    |∫t:ℝ in Ioc 0 (Real.pi/8),
      residualRawKernel (fun _:Fin n=>a) B θ (residualDerivativeKernel j) t| ≤
      (1/2:ℝ)*(Real.pi/4)^(n-1) := by
  have hc:IntegrableOn (fun _:ℝ=>(4/Real.pi)*(Real.pi/4)^(n-1)) (Ioc 0 (Real.pi/8)) :=
    integrableOn_const (ne_of_lt measure_Ioc_lt_top)
  have hh:=norm_integral_le_of_norm_le (f:=residualRawKernel (fun _:Fin n=>a) B θ
    (residualDerivativeKernel j)) hc (by
      filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
      have h:=residualWeightedKernel_small_interval_pointwise j (n-1) ha ha2 ht.1 ht.2
      have hn1:n-1+1=n:=by omega
      rw [hn1] at h
      simp only [residualRawKernel,Finset.prod_const,Finset.card_univ,Fintype.card_fin,
        Real.norm_eq_abs]
      have he:Real.sin (B*t+θ)*Real.sin (a*t)^n*residualDerivativeKernel j t=
        Real.sin (B*t+θ)*(Real.sin (a*t)^n*residualDerivativeKernel j t):=by ring
      rw [he,abs_mul]
      exact (mul_le_mul_of_nonneg_right (Real.abs_sin_le_one _) (abs_nonneg _)).trans
        (by simpa using h))
  rw [Real.norm_eq_abs] at hh
  have he:(∫x:ℝ in Ioc 0 (Real.pi/8),(4/Real.pi)*(Real.pi/4)^(n-1))=
      (1/2:ℝ)*(Real.pi/4)^(n-1) := by
    simp only [integral_const,Measure.real,Measure.restrict_apply_univ,smul_eq_mul,Real.volume_Ioc,
      sub_zero,ENNReal.toReal_ofReal (show (0:ℝ)≤Real.pi/8 by positivity)]
    field_simp
    <;> ring
  exact hh.trans_eq he

/-- Undamped leading Fourier series for the actual moment integral. -/
def balancedMomentLeading (n j:ℕ) (a B θ:ℝ) : ℝ :=
  Real.sqrt (2*Real.pi)/a * ∑' l:ℕ, (-1:ℝ)^(n*l)*
    residualDerivativeKernel j (residualPeak a l)*Real.sin (B*residualPeak a l+θ)

lemma balancedMoment_series_summable (j:ℕ) (hj:j≤2) (n:ℕ) {a:ℝ}
    (ha:1≤a) (ha2:a≤2) (B θ:ℝ) :
    Summable (fun l:ℕ=>(-1:ℝ)^(n*l)*residualDerivativeKernel j (residualPeak a l)*
      Real.sin (B*residualPeak a l+θ)) := by
  apply Summable.of_norm_bounded residualMomentEnvelope_summable
  intro l
  rw [Real.norm_eq_abs,abs_mul,abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul]
  exact (mul_le_mul_of_nonneg_left (Real.abs_sin_le_one _) (abs_nonneg _)).trans
    (by simpa using (residualWeightedKernel_center_bounds j hj ha ha2 l).1)

lemma balancedMomentLeading_abs (j:ℕ) (hj:j≤2) (n:ℕ) {a:ℝ}
    (ha:1≤a) (ha2:a≤2) (B θ:ℝ) :
    |balancedMomentLeading n j a B θ| ≤Real.sqrt (2*Real.pi)*residualMomentSum := by
  have ha0:0<a:=by linarith
  have hs:=balancedMoment_series_summable j hj n ha ha2 B θ
  have hh:=norm_tsum_le_tsum_norm hs.norm
  have hb:=Summable.tsum_le_tsum (fun l=>by
    rw [Real.norm_eq_abs,abs_mul,abs_mul,abs_pow,abs_neg,abs_one,one_pow,one_mul]
    exact (mul_le_mul_of_nonneg_left (Real.abs_sin_le_one _) (abs_nonneg _)).trans
      (by simpa using (residualWeightedKernel_center_bounds j hj ha ha2 l).1))
    hs.norm residualMomentEnvelope_summable
  have hsum:|∑'l:ℕ,(-1:ℝ)^(n*l)*residualDerivativeKernel j (residualPeak a l)*
      Real.sin (B*residualPeak a l+θ)| ≤residualMomentSum:=by
    simpa only [Real.norm_eq_abs,residualMomentSum] using hh.trans hb
  unfold balancedMomentLeading
  rw [abs_mul,abs_of_nonneg (by positivity : 0≤Real.sqrt (2*Real.pi)/a)]
  calc
    _≤(Real.sqrt (2*Real.pi)/a)*residualMomentSum:=mul_le_mul_of_nonneg_left hsum (by positivity)
    _≤Real.sqrt (2*Real.pi)*residualMomentSum:=by
      exact mul_le_mul_of_nonneg_right (div_le_self (Real.sqrt_nonneg _) ha) residualMomentSum_nonneg

lemma balancedMomentMain_sum_normalized {n:ℕ} (hn:0<n) (j:ℕ) {a:ℝ}
    (ha:0<a) (B θ:ℝ) :
    Real.sqrt (n:ℝ)*(∑'l:ℕ,balancedMomentMain n j a B θ l)=
      Real.exp (-(B*balancedCellScale n a)^2/2)*balancedMomentLeading n j a B θ := by
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn
  have hs:Real.sqrt (n:ℝ)*balancedCellScale n a=1/a:=by
    unfold balancedCellScale
    field_simp
  have he:∀l,balancedMomentMain n j a B θ l=
      balancedCellScale n a*balancedCellGaussian n a B *
      ((-1:ℝ)^(n*l)*residualDerivativeKernel j (residualPeak a l)*
        Real.sin (B*residualPeak a l+θ)):=by intro l;unfold balancedMomentMain;ring
  simp_rw [he]
  rw [tsum_mul_left]
  unfold balancedMomentLeading balancedCellGaussian
  linear_combination hs*(Real.sqrt (2*Real.pi)*Real.exp (-(B*balancedCellScale n a)^2/2)*
    ∑'l:ℕ,(-1:ℝ)^(n*l)*residualDerivativeKernel j (residualPeak a l)*
      Real.sin (B*residualPeak a l+θ))

lemma balancedMoment_global_damped_error (j:ℕ) (hj:j≤2) {n:ℕ} (hn:0<n) {a:ℝ}
    (ha:1≤a) (ha2:a≤2) (B θ:ℝ) :
    |Real.sqrt (n:ℝ)*(∫t:ℝ in Ioi 0,
        residualRawKernel (fun _:Fin n=>a) B θ (residualDerivativeKernel j) t)-
      Real.exp (-(B*balancedCellScale n a)^2/2)*balancedMomentLeading n j a B θ| ≤
      (1/2:ℝ)*Real.sqrt (n:ℝ)*(Real.pi/4)^(n-1)+
        (saddleRemainderConstant+Real.sqrt (2*Real.pi)*|B|)*residualMomentSum/(n:ℝ) := by
  have ha0:0<a:=by linarith
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn
  let f:=residualRawKernel (fun _:Fin n=>a) B θ (residualDerivativeKernel j)
  have hf:=residualRawKernel_integrable hn (fun _:Fin n=>a) B θ j
  have hfc:=hf.mono_set (Ioi_subset_Ioi (show (0:ℝ)≤Real.pi/8 by positivity))
  have hsplit:=intervalIntegral.integral_interval_add_Ioi hf hfc
  rw [intervalIntegral.integral_of_le (show (0:ℝ)≤Real.pi/8 by positivity)] at hsplit
  have hz:=balancedMomentRaw_small_integral j hn ha ha2 B θ
  have hc:=balancedMoment_cutoff_main_error j hj hn ha ha2 B θ
  have hs:=balancedCellScale_bounds hn ha
  have hnorm:Real.sqrt (n:ℝ)*balancedCellScale n a≤1:=by
    have he:Real.sqrt (n:ℝ)*balancedCellScale n a=1/a:=by
      unfold balancedCellScale;field_simp
    rw [he]
    simpa using one_div_le_one_div_of_le (by norm_num : (0:ℝ)<1) ha
  have hC:=saddleRemainderConstant_nonneg
  have hS:=residualMomentSum_nonneg
  have hG:=balancedCellGaussian_nonneg n a B
  have hG1:balancedCellGaussian n a B≤Real.sqrt (2*Real.pi):=by
    unfold balancedCellGaussian
    apply mul_le_of_le_one_right (by positivity)
    exact Real.exp_le_one_iff.mpr (by nlinarith [sq_nonneg (B*balancedCellScale n a)])
  have hcm:=mul_le_mul_of_nonneg_left hc (Real.sqrt_nonneg (n:ℝ))
  have hscale:=mul_le_mul_of_nonneg_right hnorm
    (show 0≤(saddleRemainderConstant/(n:ℝ)+
      (balancedCellScale n a)^2*|B| *balancedCellGaussian n a B)*residualMomentSum by positivity)
  have hsq:=mul_le_mul_of_nonneg_right hs.2.2
    (show 0≤|B| *balancedCellGaussian n a B*residualMomentSum by positivity)
  have hgg:=mul_le_mul_of_nonneg_right hG1
    (show 0≤|B| *residualMomentSum/(n:ℝ) by positivity)
  have htri:|(∫t:ℝ in Ioi 0,f t)-∑'l,balancedMomentMain n j a B θ l| ≤
      |∫t:ℝ in Ioc 0 (Real.pi/8),f t| +
      |(∫t:ℝ in Ioi (Real.pi/8),f t)-∑'l,balancedMomentMain n j a B θ l|:=by
    rw [←hsplit,add_sub_assoc]
    exact abs_add_le _ _
  have ht:=mul_le_mul_of_nonneg_left htri (Real.sqrt_nonneg (n:ℝ))
  have hzz:=mul_le_mul_of_nonneg_left hz (Real.sqrt_nonneg (n:ℝ))
  rw [←balancedMomentMain_sum_normalized hn j ha0 B θ,←mul_sub,abs_mul,
    abs_of_nonneg (Real.sqrt_nonneg (n:ℝ))]
  dsimp [f] at *
  linear_combination ht+hzz+hcm+hscale+hsq+hgg


def balancedMomentCompactConstant (L:ℝ) : ℝ :=
  1+(saddleRemainderConstant+Real.sqrt (2*Real.pi)*L+
    Real.sqrt (2*Real.pi)*L^2/2)*residualMomentSum

lemma balancedMomentCompactConstant_pos {L:ℝ} (hL:0≤L) :
    0<balancedMomentCompactConstant L := by
  unfold balancedMomentCompactConstant
  positivity [saddleRemainderConstant_nonneg,residualMomentSum_nonneg]

/-- The first two actual derivative moments have a uniform `1/n` error
on every fixed compact bias interval, with no unproved scalar assumptions. -/
theorem balancedMoment_compact_error (L:ℝ) (hL:0≤L) :
    ∃N₀:ℕ,0<N₀ ∧ ∀n:ℕ,N₀≤n → ∀j:ℕ,j≤2 →
      ∀a:ℝ,1≤a → a≤2 → ∀B θ:ℝ,|B|≤L →
      |Real.sqrt (n:ℝ)*(∫t:ℝ in Ioi 0,
        residualRawKernel (fun _:Fin n=>a) B θ (residualDerivativeKernel j) t)-
        balancedMomentLeading n j a B θ|≤balancedMomentCompactConstant L/(n:ℝ) := by
  obtain ⟨N₀,hN⟩:=Filter.eventually_atTop.mp balanced_small_tail_eventually
  refine ⟨max N₀ 1,by omega,?_⟩
  intro n hn j hj a ha ha2 B θ hB
  obtain ⟨hn0,htail⟩:=hN n (le_trans (le_max_left _ _) hn)
  have hnR:(0:ℝ)<n:=by exact_mod_cast hn0
  have hs:=balancedCellScale_bounds hn0 ha
  have hraw:=balancedMoment_global_damped_error j hj hn0 ha ha2 B θ
  have hlead:=balancedMomentLeading_abs j hj n ha ha2 B θ
  have hsqr:B^2≤L^2:=by nlinarith [sq_abs B,abs_nonneg B]
  have hprod:(B*balancedCellScale n a)^2/2≤L^2/(2*(n:ℝ)):=by
    have h1:=mul_le_mul_of_nonneg_right hs.2.2 (sq_nonneg B)
    have h2:=div_le_div_of_nonneg_right hsqr hnR.le
    calc
      _=(balancedCellScale n a)^2*B^2/2:=by ring
      _≤(B^2/(n:ℝ))/2:=by
        apply div_le_div_of_nonneg_right _ (by norm_num : (0:ℝ)≤2)
        simpa only [one_div,div_eq_mul_inv,mul_one,one_mul,mul_comm] using h1
      _≤(L^2/(n:ℝ))/2:=div_le_div_of_nonneg_right h2 (by norm_num)
      _=L^2/(2*(n:ℝ)):=by ring
  have hexp0:Real.exp (-(B*balancedCellScale n a)^2/2)≤1:=
    Real.exp_le_one_iff.mpr (by nlinarith [sq_nonneg (B*balancedCellScale n a)])
  have hexp:|Real.exp (-(B*balancedCellScale n a)^2/2)-1|≤L^2/(2*(n:ℝ)):=by
    rw [abs_of_nonpos (by linarith)]
    have hh:=Real.add_one_le_exp (-(B*balancedCellScale n a)^2/2)
    linarith
  have hdelta:|Real.exp (-(B*balancedCellScale n a)^2/2)*balancedMomentLeading n j a B θ-
      balancedMomentLeading n j a B θ|≤
      L^2/(2*(n:ℝ))*(Real.sqrt (2*Real.pi)*residualMomentSum):=by
    rw [←sub_one_mul,abs_mul]
    exact mul_le_mul hexp hlead (abs_nonneg _) (by positivity)
  have htri:=abs_sub_le
    (Real.sqrt (n:ℝ)*(∫t:ℝ in Ioi 0,
      residualRawKernel (fun _:Fin n=>a) B θ (residualDerivativeKernel j) t))
    (Real.exp (-(B*balancedCellScale n a)^2/2)*balancedMomentLeading n j a B θ)
    (balancedMomentLeading n j a B θ)
  have hBmul:=mul_le_mul_of_nonneg_right hB
    (show 0≤Real.sqrt (2*Real.pi)*residualMomentSum/(n:ℝ) by
      positivity [residualMomentSum_nonneg])
  unfold balancedMomentCompactConstant
  linear_combination htri+hraw+hdelta+htail+hBmul

/-- Compact approximation to the literal first derivative of the finite
cube parity coefficient. -/
theorem balancedBiasFirst_compact_error (L:ℝ) (hL:0≤L) :
    ∃N₀:ℕ,0<N₀ ∧ ∀n:ℕ,N₀≤n → ∀a:ℝ,1≤a → a≤2 → ∀B:ℝ,|B|≤L →
      |Real.sqrt (n:ℝ)*parityBiasFirst (fun _:Fin n=>a) B-
        balancedMomentLeading n 1 a B ((n:ℝ)*Real.pi/2+Real.pi/2)|≤
        balancedMomentCompactConstant L/(n:ℝ) := by
  obtain ⟨N,hN,h⟩:=balancedMoment_compact_error L hL
  refine ⟨N,hN,?_⟩
  intro n hn a ha ha2 B hB
  rw [parityBiasFirst_integral (lt_of_lt_of_le hN hn)]
  exact h n hn 1 (by decide) a ha ha2 B _ hB

/-- Compact approximation to the literal second derivative. -/
theorem balancedBiasSecond_compact_error (L:ℝ) (hL:0≤L) :
    ∃N₀:ℕ,0<N₀ ∧ ∀n:ℕ,N₀≤n → ∀a:ℝ,1≤a → a≤2 → ∀B:ℝ,|B|≤L →
      |Real.sqrt (n:ℝ)*parityBiasSecond (fun _:Fin n=>a) B+
        balancedMomentLeading n 2 a B ((n:ℝ)*Real.pi/2)|≤
        balancedMomentCompactConstant L/(n:ℝ) := by
  obtain ⟨N,hN,h⟩:=balancedMoment_compact_error L hL
  refine ⟨N,hN,?_⟩
  intro n hn a ha ha2 B hB
  rw [parityBiasSecond_integral (lt_of_lt_of_le hN hn)]
  have hh:=h n hn 2 (by decide) a ha ha2 B ((n:ℝ)*Real.pi/2) hB
  convert hh using 1
  rw [show Real.sqrt (n:ℝ)* -(∫t:ℝ in Ioi 0,
      residualRawKernel (fun _:Fin n=>a) B ((n:ℝ)*Real.pi/2) (residualDerivativeKernel 2) t)+
      balancedMomentLeading n 2 a B ((n:ℝ)*Real.pi/2)=
      -(Real.sqrt (n:ℝ)*(∫t:ℝ in Ioi 0,
      residualRawKernel (fun _:Fin n=>a) B ((n:ℝ)*Real.pi/2) (residualDerivativeKernel 2) t)-
      balancedMomentLeading n 2 a B ((n:ℝ)*Real.pi/2)) by ring,abs_neg]


end NeuralGeneralization.OnlineLowerTanh
