import NeuralGeneralization.OnlineLowerTanhCellSeries
import NeuralGeneralization.OnlineLowerTanhResidualBalanced

/-! # Summing the quantitative equal-coordinate cells at arbitrary bias -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open scoped BigOperators Topology Classical
open MeasureTheory Set Filter
namespace NeuralGeneralization.OnlineLowerTanh

def saddleRemainderConstant : ℝ := ∫ y : ℝ, saddleTaylorMajorant y

def saddleCellSum : ℝ := ∑' l : ℕ, Real.exp (-(l : ℝ))

lemma saddleRemainderConstant_nonneg : 0 ≤ saddleRemainderConstant :=
  integral_nonneg saddleTaylorMajorant_nonneg

lemma saddleCellSum_nonneg : 0 ≤ saddleCellSum := tsum_nonneg (fun _ => (Real.exp_pos _).le)

def balancedCellGaussian (n : ℕ) (a B : ℝ) : ℝ :=
  Real.sqrt (2*Real.pi) * Real.exp (-(B*balancedCellScale n a)^2/2)

def balancedCellMain (n : ℕ) (a B θ : ℝ) (l : ℕ) : ℝ :=
  balancedCellScale n a * (-1 : ℝ)^(n*l) *
    (residualDerivativeKernel 0 (residualPeak a l) * balancedCellGaussian n a B *
      Real.sin (B*residualPeak a l+θ))

def balancedCellLinear (n : ℕ) (a B θ : ℝ) (l : ℕ) : ℝ :=
  balancedCellScale n a * (-1 : ℝ)^(n*l) *
    ((balancedCellScale n a)^2 * B * residualKernelFirst (residualPeak a l) *
      balancedCellGaussian n a B * Real.cos (B*residualPeak a l+θ))

def balancedCellActual (n : ℕ) (a B θ : ℝ) (l : ℕ) : ℝ :=
  ∫ t : ℝ in Ioc ((l : ℝ)*(Real.pi/a)) (((l : ℝ)+1)*(Real.pi/a)) ∩ Ici (Real.pi/8),
    residualRawKernel (fun _ : Fin n => a) B θ (residualDerivativeKernel 0) t

lemma balancedCellGaussian_nonneg (n : ℕ) (a B : ℝ) : 0 ≤ balancedCellGaussian n a B := by
  unfold balancedCellGaussian
  positivity

lemma balancedCellMain_abs {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) (l : ℕ) :
    |balancedCellMain n a B θ l| ≤
      (balancedCellScale n a * 4 * balancedCellGaussian n a B) * Real.exp (-(l : ℝ)) := by
  have hs := (balancedCellScale_pos hn (show 0 < a by linarith)).le
  have hG := balancedCellGaussian_nonneg n a B
  have hk := (residualKernel_center_bounds ha ha2 l).1
  unfold balancedCellMain
  rw [abs_mul, abs_mul, abs_of_nonneg hs, abs_pow, abs_neg, abs_one, one_pow, mul_one,
    abs_mul, abs_mul, abs_of_nonneg hG]
  calc
    _ ≤ balancedCellScale n a * ((4*Real.exp (-(l : ℝ)))*balancedCellGaussian n a B*1) := by
      gcongr
      exact Real.abs_sin_le_one _
    _ = _ := by ring

lemma balancedCellLinear_abs {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) (l : ℕ) :
    |balancedCellLinear n a B θ l| ≤
      balancedCellScale n a * Real.exp (-(l : ℝ)) *
        (32*(balancedCellScale n a)^2* |B| *balancedCellGaussian n a B) := by
  have hs := (balancedCellScale_pos hn (show 0 < a by linarith)).le
  have hG := balancedCellGaussian_nonneg n a B
  have hk := (residualKernel_center_bounds ha ha2 l).2.1
  unfold balancedCellLinear
  simp only [abs_mul, abs_pow, abs_of_nonneg hs, abs_neg, abs_one, one_pow,
    mul_one, abs_of_nonneg hG]
  calc
    _ ≤ balancedCellScale n a *
      ((balancedCellScale n a)^2* |B| *(32*Real.exp (-(l : ℝ)))*balancedCellGaussian n a B*1) := by
      gcongr
      exact Real.abs_cos_le_one _
    _ = _ := by ring

lemma balancedCell_two_term_error {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) (l : ℕ) :
    |balancedCellActual n a B θ l -
      (balancedCellMain n a B θ l + balancedCellLinear n a B θ l)| ≤
      balancedCellScale n a * (512*Real.exp (-(l : ℝ)))/(n : ℝ)*saddleRemainderConstant := by
  have hs := (balancedCellScale_pos hn (show 0 < a by linarith)).le
  have hh := mul_le_mul_of_nonneg_left (balancedCell_oscillatory_error hn ha ha2 l B θ) hs
  rw [balancedCellActual, balancedCell_integral hn (show 0 < a by linarith)]
  have he : balancedCellMain n a B θ l + balancedCellLinear n a B θ l =
      balancedCellScale n a * (-1 : ℝ)^(n*l) *
      (residualDerivativeKernel 0 (residualPeak a l)*Real.sqrt (2*Real.pi)*
        Real.exp (-(B*balancedCellScale n a)^2/2)*Real.sin (B*residualPeak a l+θ) +
       balancedCellScale n a*residualKernelFirst (residualPeak a l)*Real.sqrt (2*Real.pi)*
        (B*balancedCellScale n a)*Real.exp (-(B*balancedCellScale n a)^2/2)*
          Real.cos (B*residualPeak a l+θ)) := by
    unfold balancedCellMain balancedCellLinear balancedCellGaussian
    ring
  rw [he, ← mul_sub, abs_mul, abs_mul, abs_of_nonneg hs]
  simp only [abs_pow, abs_neg, abs_one, one_pow, mul_one]
  convert hh using 1 <;> first | rfl | (simp only [saddleRemainderConstant]; ring)

lemma balancedCell_main_error {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) (l : ℕ) :
    |balancedCellActual n a B θ l - balancedCellMain n a B θ l| ≤
      (balancedCellScale n a * (512*saddleRemainderConstant/(n : ℝ) +
        32*(balancedCellScale n a)^2* |B| *balancedCellGaussian n a B)) * Real.exp (-(l : ℝ)) := by
  have ht := abs_sub_le (balancedCellActual n a B θ l)
    (balancedCellMain n a B θ l + balancedCellLinear n a B θ l) (balancedCellMain n a B θ l)
  rw [add_sub_cancel_left] at ht
  have he := balancedCell_two_term_error hn ha ha2 B θ l
  have hl := balancedCellLinear_abs hn ha ha2 B θ l
  calc
    _ ≤ _ := ht.trans (add_le_add he hl)
    _ = _ := by ring

lemma balancedCellMain_summable {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) : Summable (balancedCellMain n a B θ) := by
  apply Summable.of_norm_bounded (residualKernel_envelope_summable
    (balancedCellScale n a*4*balancedCellGaussian n a B))
  intro l
  simpa only [Real.norm_eq_abs] using balancedCellMain_abs hn ha ha2 B θ l

/-- Summing the actual integrals preserves the explicit Gaussian damping
of the first-order bias correction. -/
theorem balanced_cutoff_main_error {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) :
    |(∫ t : ℝ in Ioi (Real.pi/8),
       residualRawKernel (fun _ : Fin n => a) B θ (residualDerivativeKernel 0) t) -
      ∑' l : ℕ, balancedCellMain n a B θ l| ≤
      balancedCellScale n a * (512*saddleRemainderConstant/(n : ℝ) +
        32*(balancedCellScale n a)^2* |B| *balancedCellGaussian n a B) * saddleCellSum := by
  have ha0 : 0 < a := by linarith
  have hf := residualRawKernel_integrable hn (fun _ : Fin n => a) B θ 0
  have hs := hasSum_integral_truncated_cells _ hf (Real.pi/a) (Real.pi/8)
    (by positivity) (by positivity)
  change HasSum (balancedCellActual n a B θ) _ at hs
  have hm := balancedCellMain_summable hn ha ha2 B θ
  rw [← hs.tsum_eq, ← hs.summable.tsum_sub hm]
  have habs := norm_tsum_le_tsum_norm (hs.summable.sub hm).norm
  have hbound := Summable.tsum_le_tsum
    (fun l => by simpa only [Real.norm_eq_abs] using balancedCell_main_error hn ha ha2 B θ l)
    (hs.summable.sub hm).norm
    (residualKernel_envelope_summable
      (balancedCellScale n a*(512*saddleRemainderConstant/(n : ℝ)+
        32*(balancedCellScale n a)^2* |B| *balancedCellGaussian n a B)))
  have hfinal := habs.trans hbound
  rw [tsum_mul_left] at hfinal
  simpa only [Real.norm_eq_abs, saddleCellSum] using hfinal


lemma balancedCellMain_eq_peakModel {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 0 < a) (B θ : ℝ) (l : ℕ) :
    balancedCellMain n a B θ l = residualPeakModel (fun _ : Fin n => 1)
      (fun _ => 0) a B θ l 0 := by
  unfold balancedCellMain balancedCellGaussian residualPeakModel
  rw [balancedCellScale_eq_residual]
  simp only [Nat.sub_self, Nat.zero_div, Finset.sum_const_zero, zero_add,
    zero_pow (by decide : 2 ≠ 0), zero_mul, neg_zero, zero_div, Real.exp_zero, mul_one]
  ring

lemma balancedCellMain_sum {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a) (B : ℝ) :
    (∑' l : ℕ, balancedCellMain n a B ((n : ℝ)*Real.pi/2) l) =
      residualLeading (fun _ : Fin n => 1) (fun _ => 0) a B := by
  simp_rw [balancedCellMain_eq_peakModel hn ha,
    residual_peak_model_coefficient hn (fun _ : Fin n => 1) (fun _ => by decide)
      (fun _ => 0) ha B]
  rw [tsum_mul_left]
  rfl

lemma balancedLeading_normalized {n : ℕ} (hn : 0 < n) {a : ℝ} (ha : 0 < a) (B : ℝ) :
    Real.sqrt (n : ℝ) * residualLeading (fun _ : Fin n => 1) (fun _ => 0) a B =
      (-1 : ℝ)^(n/2) * Real.sqrt (2/Real.pi) *
        Real.exp (-B^2/(2*a^2*(n : ℝ))) *
          periodicFourierResponse a (B+(n%2 : ℕ)*a) := by
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  have hnorm : Real.sqrt (n : ℝ) * Real.sqrt (2/(Real.pi*(n : ℝ))) = Real.sqrt (2/Real.pi) := by
    rw [← Real.sqrt_mul hnR.le]
    congr 1
    field_simp
  unfold residualLeading residualPhaseSign
  simp only [Nat.sub_self, Nat.zero_div, Finset.sum_const_zero, zero_add,
    zero_pow (by decide : 2 ≠ 0), residualVariance_one, smoothedResponse_zero]
  calc
    _ = (-1 : ℝ)^(n/2) * (Real.sqrt (n : ℝ)*Real.sqrt (2/(Real.pi*(n : ℝ)))) *
      Real.exp (-B^2/(2*a^2*(n : ℝ))) * periodicFourierResponse a (B+(n%2 : ℕ)*a) := by ring
    _ = _ := by rw [hnorm]


lemma balancedRaw_small_integral {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B θ : ℝ) :
    |∫ t : ℝ in Ioc 0 (Real.pi/8),
      residualRawKernel (fun _ : Fin n => a) B θ (residualDerivativeKernel 0) t| ≤
      (1/2 : ℝ)*(Real.pi/4)^(n-1) := by
  have ha0 : 0 < a := by linarith
  let g := fun t => paritySineProduct (fun _ : Fin n => a) t / Real.sinh ((Real.pi/2)*t)
  have hz := parity_kernel_near_zero_integral hn (fun _ : Fin n => a)
    (show (0 : ℝ) ≤ 2 by norm_num) (show 0 < Real.pi/2 by positivity)
    (show 0 ≤ Real.pi/8 by positivity) (fun _ => by simpa only [abs_of_pos ha0] using ha2)
  have hdom := norm_integral_le_of_norm_le (f :=
    residualRawKernel (fun _ : Fin n => a) B θ (residualDerivativeKernel 0)) hz.1
    (by
      filter_upwards [ae_restrict_mem measurableSet_Ioc] with t ht
      simpa only [Real.norm_eq_abs] using residualRawKernel_dom (fun _ : Fin n => a) B θ ht.1)
  rw [Real.norm_eq_abs] at hdom
  apply hdom.trans
  have he : Real.pi/8*(2/(Real.pi/2)*(2*(Real.pi/8))^(n-1)) =
      (1/2 : ℝ)*(Real.pi/4)^(n-1) := by
    rw [show 2*(Real.pi/8) = Real.pi/4 by ring]
    field_simp
    <;> ring
  exact hz.2.trans_eq he

/-- Global quantitative approximation to the exact periodic leading term.
The bias-dependent error retains Gaussian damping at every real bias. -/
theorem balanced_global_error_explicit {n : ℕ} (hn : 0 < n) {a : ℝ}
    (ha : 1 ≤ a) (ha2 : a ≤ 2) (B : ℝ) :
    Real.sqrt (n : ℝ) * |parityCorrelation (fun _ : Fin n => a) B -
      residualLeading (fun _ : Fin n => 1) (fun _ => 0) a B| ≤
      (1/2 : ℝ)*Real.sqrt (n : ℝ)*(Real.pi/4)^(n-1) +
      (512*saddleRemainderConstant*saddleCellSum)/(n : ℝ) +
      (32*Real.sqrt (2*Real.pi)*saddleCellSum)* |B|/(n : ℝ)*
        Real.exp (-B^2/(2*a^2*(n : ℝ))) := by
  have ha0 : 0 < a := by linarith
  have hnR : (0 : ℝ) < n := by exact_mod_cast hn
  let f := residualRawKernel (fun _ : Fin n => a) B ((n : ℝ)*Real.pi/2) (residualDerivativeKernel 0)
  have hf := residualRawKernel_integrable hn (fun _ : Fin n => a) B ((n : ℝ)*Real.pi/2) 0
  have hfc := hf.mono_set (Ioi_subset_Ioi (show (0 : ℝ) ≤ Real.pi/8 by positivity))
  have hsplit := intervalIntegral.integral_interval_add_Ioi hf hfc
  rw [intervalIntegral.integral_of_le (show (0 : ℝ) ≤ Real.pi/8 by positivity)] at hsplit
  have hcorr : parityCorrelation (fun _ : Fin n => a) B =
      (∫ t : ℝ in Ioc 0 (Real.pi/8), f t) + (∫ t : ℝ in Ioi (Real.pi/8), f t) := by
    rw [residualRawKernel_parity]
    exact hsplit.symm
  have hz := balancedRaw_small_integral hn ha ha2 B ((n : ℝ)*Real.pi/2)
  have hc := balanced_cutoff_main_error hn ha ha2 B ((n : ℝ)*Real.pi/2)
  rw [balancedCellMain_sum hn ha0 B] at hc
  have hs := balancedCellScale_bounds hn ha
  have hnorm : Real.sqrt (n : ℝ)*balancedCellScale n a ≤ 1 := by
    have he : Real.sqrt (n : ℝ)*balancedCellScale n a = 1/a := by
      unfold balancedCellScale
      field_simp
    rw [he]
    simpa using one_div_le_one_div_of_le (by norm_num : (0 : ℝ) < 1) ha
  have hC := saddleRemainderConstant_nonneg
  have hS := saddleCellSum_nonneg
  have hG := balancedCellGaussian_nonneg n a B
  have hcm := mul_le_mul_of_nonneg_left hc (Real.sqrt_nonneg (n : ℝ))
  have hcore0 : 0 ≤ (512*saddleRemainderConstant/(n : ℝ) +
      32*(balancedCellScale n a)^2* |B| *balancedCellGaussian n a B)*saddleCellSum := by positivity
  have hscale := mul_le_mul_of_nonneg_right hnorm hcore0
  have hsq := mul_le_mul_of_nonneg_right hs.2.2
    (show 0 ≤ 32* |B| *balancedCellGaussian n a B*saddleCellSum by positivity)
  have hexp : balancedCellGaussian n a B = Real.sqrt (2*Real.pi)*
      Real.exp (-B^2/(2*a^2*(n : ℝ))) := by
    unfold balancedCellGaussian
    rw [balancedCellScale_eq_residual,
      residual_gaussian_exponent hn (fun _ : Fin n => 1) (fun _ => by decide) ha0,
      residualVariance_one]
  rw [hexp] at hcm hscale hsq
  have htri : |parityCorrelation (fun _ : Fin n => a) B-
      residualLeading (fun _ : Fin n => 1) (fun _ => 0) a B| ≤
      |∫ t : ℝ in Ioc 0 (Real.pi/8), f t| +
      |(∫ t : ℝ in Ioi (Real.pi/8), f t)-
        residualLeading (fun _ : Fin n => 1) (fun _ => 0) a B| := by
    rw [hcorr, add_sub_assoc]
    exact abs_add_le _ _
  have htrim := mul_le_mul_of_nonneg_left htri (Real.sqrt_nonneg (n : ℝ))
  have hzm := mul_le_mul_of_nonneg_left hz (Real.sqrt_nonneg (n : ℝ))
  dsimp [f] at *
  linear_combination htrim + hzm + hcm + hscale + hsq


def balancedGlobalConstant : ℝ :=
  1 + 512*saddleRemainderConstant*saddleCellSum + 32*Real.sqrt (2*Real.pi)*saddleCellSum

lemma balancedGlobalConstant_pos : 0 < balancedGlobalConstant := by
  unfold balancedGlobalConstant
  positivity [saddleRemainderConstant_nonneg, saddleCellSum_nonneg]

lemma balanced_small_tail_eventually :
    ∀ᶠ n : ℕ in atTop, 0 < n ∧
      (1/2 : ℝ)*Real.sqrt (n : ℝ)*(Real.pi/4)^(n-1) ≤ 1/(n : ℝ) := by
  have hq : 0 < Real.pi/4 := by positivity
  have hq1 : Real.pi/4 < 1 := by linarith [Real.pi_lt_four]
  have ht := (tendsto_pow_const_mul_const_pow_of_lt_one 2 hq.le hq1).div_const (Real.pi/4)
  simp only [zero_div] at ht
  filter_upwards [eventually_ge_atTop 1, ht.eventually (gt_mem_nhds (show (0 : ℝ) < 2 by norm_num))]
    with n hn hsmall
  have hnR : (0 : ℝ) < n := by exact_mod_cast (show 0 < n by omega)
  have hn1 : (1 : ℝ) ≤ n := by exact_mod_cast hn
  have he : (n : ℝ)^2*(Real.pi/4)^n/(Real.pi/4) =
      (n : ℝ)^2*(Real.pi/4)^(n-1) := by
    have hnp : n = (n-1)+1 := by omega
    have hp : (Real.pi/4)^n = (Real.pi/4)^(n-1)*(Real.pi/4) := by
      rw [← pow_succ, ← hnp]
    rw [hp]
    field_simp
  rw [he] at hsmall
  have hs : Real.sqrt (n : ℝ) ≤ n := by
    have hsq := Real.sq_sqrt hnR.le
    nlinarith [Real.sqrt_nonneg (n : ℝ)]
  refine ⟨by omega, (le_div_iff₀ hnR).mpr ?_⟩
  have hh := mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hs hnR.le)
    (show 0 ≤ (Real.pi/4)^(n-1) by positivity)
  nlinarith

/-- A single absolute constant works for every sufficiently large dimension,
every gain in `[1,2]`, and every real bias. -/
theorem balanced_global_error_uniform :
    ∃ N₀ : ℕ, 0 < N₀ ∧ ∀ n : ℕ, N₀ ≤ n → ∀ a : ℝ, 1 ≤ a → a ≤ 2 → ∀ B : ℝ,
      Real.sqrt (n : ℝ) * |parityCorrelation (fun _ : Fin n => a) B -
        residualLeading (fun _ : Fin n => 1) (fun _ => 0) a B| ≤
        balancedGlobalConstant/(n : ℝ) + balancedGlobalConstant* |B|/(n : ℝ)*
          Real.exp (-B^2/(2*a^2*(n : ℝ))) := by
  obtain ⟨N₀, hN⟩ := Filter.eventually_atTop.mp balanced_small_tail_eventually
  refine ⟨max N₀ 1, by omega, ?_⟩
  intro n hn a ha ha2 B
  obtain ⟨hnpos, htail⟩ := hN n (le_trans (le_max_left _ _) hn)
  have hnR : (0 : ℝ) < n := by exact_mod_cast hnpos
  have hraw := balanced_global_error_explicit hnpos ha ha2 B
  have hC := saddleRemainderConstant_nonneg
  have hS := saddleCellSum_nonneg
  have hK0 : 1 + 512*saddleRemainderConstant*saddleCellSum ≤ balancedGlobalConstant := by
    unfold balancedGlobalConstant
    have hh : 0 ≤ 32*Real.sqrt (2*Real.pi)*saddleCellSum := by positivity
    linarith
  have hK1 : 32*Real.sqrt (2*Real.pi)*saddleCellSum ≤ balancedGlobalConstant := by
    unfold balancedGlobalConstant
    have hh : 0 ≤ 512*saddleRemainderConstant*saddleCellSum := by positivity
    linarith
  have hconst := div_le_div_of_nonneg_right hK0 hnR.le
  have hlin := mul_le_mul_of_nonneg_right
    (div_le_div_of_nonneg_right (mul_le_mul_of_nonneg_right hK1 (abs_nonneg B)) hnR.le)
    (Real.exp_pos (-B^2/(2*a^2*(n : ℝ)))).le
  calc
    _ ≤ _ := hraw
    _ ≤ balancedGlobalConstant/(n : ℝ) + balancedGlobalConstant* |B|/(n : ℝ)*
        Real.exp (-B^2/(2*a^2*(n : ℝ))) := by
      rw [add_div] at hconst
      linarith

end NeuralGeneralization.OnlineLowerTanh
