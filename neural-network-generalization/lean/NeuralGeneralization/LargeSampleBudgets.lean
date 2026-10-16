import NeuralGeneralization.AdaptiveBinomialBudget
import NeuralGeneralization.AdaptiveScalarBudget

/-! Uniform numerical closure of the adaptive large-sample cutoffs.  The
cutoff is constructed from the actual dimension threshold, and the upper
band controls every fixed polynomial weight needed in the three regimes. -/
noncomputable section
open Filter
open scoped Topology
namespace NeuralGeneralization.AdaptiveCutoff
open SmallSampleCutoff

/-- A proved, actual adaptive cutoff; this is data returned by the construction,
not an additional premise of the final sample-complexity theorem. -/
structure LargeCutoff (d n : ℕ) (A ε : ℝ) (r : ℕ) : Prop where
  positive : 1 ≤ r
  odd : Odd r
  small : (r:ℝ) ≤ ε*(d:ℝ)
  large : logDimension d^2/2 ≤ (r:ℝ)
  threshold : A*(lowDimension d r:ℝ)*Real.log (8*(n:ℝ)) ≤ n
  next_threshold : (n:ℝ) < A*(lowDimension d (r+2):ℝ)*Real.log (8*(n:ℝ))
  sampling : paritySquaredSamplingBudget d r n ≤ n
  band_le : r+additionalBand d ≤ 2*r
  degree_le : 131072*(r+additionalBand d+1) ≤ d
  log_small : Real.log (8*(n:ℝ)) ≤ ε^2*(d:ℝ)

lemma largeCutoff_eventually (A ε : ℝ) (hA : (2:ℝ)^79 ≤ A)
    (hε0 : 0<ε) (hε1 : ε≤1/262144) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ,
      Real.exp (logDimension d^3)≤(n:ℝ) →
      (n:ℝ)≤Real.exp ((ε^2/8)*(d:ℝ)) →
      ∃ r : ℕ, LargeCutoff d n A ε r := by
  have hε : ε≤1 := by linarith
  have hεsq : ε^2≤ε := by nlinarith only [hε0,hε]
  have hspos : 0<ε^2 := sq_pos_of_pos hε0
  have hssmall : ε^2≤1/128 := by linarith only [hεsq,hε1]
  filter_upwards [eventually_exists_cutoffs A (ε^2) hA hspos hssmall,
    sample_log_small_eventually (show 0<ε^2/8 by positivity)]
    with d hcut hlog n hmin hmax
  obtain ⟨r,hr,hodd,hsmall,hlarge,hthr,hnext,hsample,hband,hdeg⟩ := hcut n hmin hmax
  have hn : 0<n := Nat.cast_pos.mp ((Real.exp_pos _).trans_le hmin)
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hrsmall : (r:ℝ)≤ε*(d:ℝ) := hsmall.trans (mul_le_mul_of_nonneg_right hεsq hd0)
  have hdeg' : 131072*(r+additionalBand d+1)≤d := by
    have hb : ((r+additionalBand d:ℕ):ℝ)≤2*(r:ℝ) := by exact_mod_cast hband
    have he := mul_le_mul_of_nonneg_right hε1 hd0
    have hes : ε^2≤ε/2 := by nlinarith only [hε0,hε1]
    have hscaled := mul_le_mul_of_nonneg_right hes hd0
    have hrone : (1:ℝ)≤r := by exact_mod_cast hr
    have hh : (131072:ℝ)*(((r+additionalBand d:ℕ):ℝ)+1)≤d := by
      nlinarith only [hb,hsmall,he,hscaled,hrone,hd0]
    exact_mod_cast hh
  refine ⟨r,hr,hodd,hrsmall,hlarge,hthr,hnext,hsample,hband,hdeg',?_⟩
  have hl := hlog n hn hmax
  nlinarith only [hl,mul_nonneg (sq_nonneg ε) hd0]

lemma upper_band_polynomial_bound {d n r : ℕ} {A U ε : ℝ}
    (hA : 0≤A) (hU : 0≤U) (hn : 0<n) (hdlog : 1≤logDimension d)
    (hε : ε≤1) (hε0 : 0≤ε) (hcut : LargeCutoff d n A ε r) :
    (n:ℝ)*(U/((d+1).choose (r+additionalBand d+2):ℝ))*((d:ℝ)+1)^10 ≤
      4*A*U/((d:ℝ)+1)^9 := by
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg _
  have hdpos : 0<(d:ℝ)+1 := by positivity
  have hs : ε^2≤1 := by nlinarith only [hε,hε0]
  have hlog : Real.log (8*(n:ℝ))≤2*(d:ℝ) := by
    have hh := mul_le_mul_of_nonneg_right hs hd0
    linarith only [hcut.log_small,hh,hd0]
  have hdim : 3*(r+additionalBand d+2)≤d := by
    have := hcut.positive
    have := hcut.degree_le
    omega
  have hh := sampled_upper_band_budget hA hU hn hdlog hdim hcut.next_threshold hlog
  have hp := mul_le_mul_of_nonneg_right hh (pow_nonneg hdpos.le 10)
  apply hp.trans
  have hnumer : 4*A*U*(d:ℝ)≤4*A*U*((d:ℝ)+1) := by
    have hh : 0≤4*A*U := by positivity
    nlinarith only [hh]
  calc
    _ = (4*A*U*(d:ℝ))/((d:ℝ)+1)^10 := by field_simp <;> ring
    _ ≤ (4*A*U*((d:ℝ)+1))/((d:ℝ)+1)^10 :=
      div_le_div_of_nonneg_right hnumer (pow_nonneg hdpos.le 10)
    _ = _ := by field_simp <;> ring

/-- The extra logarithmic band makes the remaining eigenvalue negligible,
uniformly throughout the entire exponential sample interval. -/
theorem eventually_upper_band_polynomial_budget (A U δ : ℝ)
    (hA : 0≤A) (hU : 0≤U) (hδ : 0<δ) :
    ∀ᶠ d : ℕ in atTop, ∀ n r : ℕ, ∀ ε : ℝ, 0≤ε → ε≤1 → 0<n →
      LargeCutoff d n A ε r →
      (n:ℝ)*(U/((d+1).choose (r+additionalBand d+2):ℝ))*((d:ℝ)+1)^10 ≤ δ := by
  have hD : Tendsto (fun d : ℕ=>(d:ℝ)+1) atTop atTop :=
    tendsto_atTop_add_const_right _ 1 tendsto_natCast_atTop_atTop
  have hlim : Tendsto (fun d : ℕ=>4*A*U/((d:ℝ)+1)^9) atTop (𝓝 0) :=
    tendsto_const_nhds.div_atTop ((tendsto_pow_atTop (by decide : (9:ℕ)≠0)).comp hD)
  filter_upwards [logDimension_tendsto.eventually_ge_atTop 1,
    hlim.eventually (eventually_le_nhds hδ)] with d hd hbound n r ε he0 he hn hcut
  exact (upper_band_polynomial_bound hA hU hn hd he he0 hcut).trans hbound

/-- All admissible Gram/comparator bounds satisfy the head budget with an
arbitrarily small constant, at an explicitly positive exponential rate. -/
theorem eventually_large_head_and_tail (A C U η δ : ℝ)
    (hA : (2:ℝ)^79≤A) (hC : 1≤C) (hU : 0≤U) (hη : 0<η) (hδ : 0<δ) :
    ∃ c : ℝ, 0<c ∧ ∀ᶠ d : ℕ in atTop, ∀ n : ℕ,
      Real.exp (logDimension d^3)≤(n:ℝ) → (n:ℝ)≤Real.exp (c*(d:ℝ)) →
      ∃ r : ℕ, LargeCutoff d n A (min (1/262144) (η/(60*C^2))) r ∧
      (n:ℝ)*(U/((d+1).choose (r+additionalBand d+2):ℝ))*((d:ℝ)+1)^10≤δ ∧
      ∀ G B ell W T : ℝ,
        0≤G → 0≤B → 0≤ell → 0≤W → 0≤T → W*T≤(d:ℝ)/(r:ℝ) →
        G≤C*T*(1+Real.sqrt ((d:ℝ)*Real.log (8*(n:ℝ)))/(r:ℝ)+Real.log (8*(n:ℝ))/(r:ℝ)) →
        (n:ℝ)*ell≤C*Real.log (8*(n:ℝ))*T/(r:ℝ) → B≤C*(n:ℝ)*W →
        ((r+additionalBand d:ℕ):ℝ)^2*(4*G*B/(n:ℝ)+ell*B)≤η*(d:ℝ)^2 := by
  let ε : ℝ := min (1/262144) (η/(60*C^2))
  have hC0 : 0<C := by linarith only [hC]
  have hε0 : 0<ε := lt_min (by norm_num) (by positivity)
  have hεsmall : ε≤1/262144 := min_le_left _ _
  have hε1 : ε≤1 := by linarith only [hεsmall]
  have hA0 : 0≤A := by nlinarith only [hA]
  refine ⟨ε^2/8,by positivity,?_⟩
  filter_upwards [largeCutoff_eventually A ε hA hε0 hεsmall,
    eventually_upper_band_polynomial_budget A U δ hA0 hU hδ,
    eventually_ge_atTop 1] with d hcut htail hd n hmin hmax
  obtain ⟨r,hr⟩ := hcut n hmin hmax
  have hn : 0<n := Nat.cast_pos.mp ((Real.exp_pos _).trans_le hmin)
  refine ⟨r,hr,htail n r ε hε0.le hε1 hn hr,?_⟩
  intro G B ell W T hG hB hell hW hT hWT hGbound hellbound hBbound
  have hd0 : (0:ℝ)<d := Nat.cast_pos.mpr (by omega)
  have hr0 : (0:ℝ)<r := Nat.cast_pos.mpr (by have := hr.positive; omega)
  have hu : ((r+additionalBand d:ℕ):ℝ)≤2*(r:ℝ) := by exact_mod_cast hr.band_le
  have hL : 0≤Real.log (8*(n:ℝ)) := (by norm_num : (0:ℝ)≤1).trans (log_eight_sample_ge_one hn)
  have hh := head_budget_of_scaled_bounds hd0 hr0 (Nat.cast_pos.mpr hn) hL hC0.le
    (Nat.cast_nonneg (r+additionalBand d)) hu hG hell hW hT hB hWT hGbound
    hellbound hBbound hε0.le hε1 hr.small hr.log_small
  apply hh.trans
  have he := min_le_right (1/262144:ℝ) (η/(60*C^2))
  have he' : 60*C^2*ε≤η := by
    have hden : 0<60*C^2 := by positivity
    have ht := (le_div_iff₀ hden).mp he
    simpa only [mul_comm, ε] using ht
  exact mul_le_mul_of_nonneg_right he' (sq_nonneg (d:ℝ))

end NeuralGeneralization.AdaptiveCutoff
