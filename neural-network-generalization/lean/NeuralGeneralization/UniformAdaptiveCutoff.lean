import NeuralGeneralization.AdaptiveDimensionCutoff
import NeuralGeneralization.SmallSampleCutoff

/-! Uniform existence of actual adaptive cutoffs throughout the exponential
large-sample range. The short extra band has logarithmic width. -/
noncomputable section
open Filter
open scoped Topology
namespace NeuralGeneralization.AdaptiveCutoff
open SquaredSampling SmallSampleCutoff

lemma log_two_lower : (1:ℝ)/2 ≤ Real.log 2 := by
  have h := Real.one_sub_inv_le_log_of_pos (by norm_num : (0:ℝ)<2)
  norm_num at h ⊢
  exact h

lemma log_eight_upper : Real.log (8:ℝ) ≤ 3 := by
  have h := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
  rw [show (8:ℝ)=2^3 by norm_num, Real.log_pow]
  norm_num
  linarith only [h]

def additionalBand (d : ℕ) : ℕ := 2*⌈20*logDimension d⌉₊

lemma additionalBand_even (d : ℕ) : Even (additionalBand d) := by
  exact ⟨_,by unfold additionalBand; ring⟩

lemma additionalBand_bounds {d : ℕ} (hd : 1≤logDimension d) :
    40*logDimension d ≤ (additionalBand d:ℝ) ∧
    (additionalBand d:ℝ) ≤ 42*logDimension d := by
  have hlo := Nat.le_ceil (20*logDimension d)
  have hhi := Nat.ceil_lt_add_one (show 0≤20*logDimension d by linarith)
  unfold additionalBand
  push_cast
  constructor <;> linarith

lemma sample_log_upper {d n : ℕ} {α : ℝ} (hd : 3≤d) (hn : 0<n)
    (hα : α≤1) (hmax : (n:ℝ)≤Real.exp ((α/8)*(d:ℝ))) :
    Real.log (8*(n:ℝ)) ≤ 2*(d:ℝ) := by
  have hn0 : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hlog := Real.log_le_log hn0 hmax
  rw [Real.log_exp] at hlog
  rw [Real.log_mul (by norm_num : (8:ℝ)≠0) hn0.ne']
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg d
  have hd3 : (3:ℝ)≤d := by exact_mod_cast hd
  have hh := mul_le_mul_of_nonneg_right hα hd0
  nlinarith only [hlog,log_eight_upper,hd3,hh,hd0]

/-- Explicit finite conditions already give an adaptive cutoff, its next
failed threshold, and a logarithmic additional band no larger than the cutoff. -/
theorem exists_cutoffs_finite {d n : ℕ} {A α : ℝ}
    (hA : (2:ℝ)^79≤A) (hα0 : 0<α) (hα : α≤1/128)
    (hdA : A≤(d:ℝ)+1) (hdα : 16≤α*(d:ℝ))
    (hdlog : 128≤logDimension d)
    (hmin : Real.exp (logDimension d^3)≤(n:ℝ))
    (hmax : (n:ℝ)≤Real.exp ((α/8)*(d:ℝ))) :
    ∃ r : ℕ, 1≤r ∧ Odd r ∧ (r:ℝ)≤α*(d:ℝ) ∧
      logDimension d^2/2≤(r:ℝ) ∧
      A*(lowDimension d r:ℝ)*Real.log (8*(n:ℝ))≤n ∧
      (n:ℝ)<A*(lowDimension d (r+2):ℝ)*Real.log (8*(n:ℝ)) ∧
      paritySquaredSamplingBudget d r n≤n ∧
      r+additionalBand d≤2*r ∧ 64*(r+additionalBand d)≤d := by
  have hA1 : 1≤A := by nlinarith only [hA]
  have hd0 : (0:ℝ)≤d := Nat.cast_nonneg d
  have hα1 : α≤1 := by linarith
  have hd16 : (16:ℝ)≤d := by nlinarith only [hdα,hα1,hd0]
  have hd3 : 3≤d := by exact_mod_cast (show (3:ℝ)≤d by linarith only [hd16])
  have hD : (0:ℝ)<(d:ℝ)+1 := by positivity
  have hD2 : (2:ℝ)≤(d:ℝ)+1 := by linarith only [hd16]
  have hL0 : 0<logDimension d := by linarith only [hdlog]
  have hn0 : (0:ℝ)<n := (Real.exp_pos _).trans_le hmin
  have hn : 0<n := Nat.cast_pos.mp hn0
  have hlogn : logDimension d^3≤Real.log (n:ℝ) := by
    have hh := Real.log_le_log (Real.exp_pos _) hmin
    simpa only [Real.log_exp] using hh
  have hL := sample_log_upper hd3 hn hα1 hmax
  have hL1 := log_eight_sample_ge_one hn
  have hpoly : ((d:ℝ)+1)^4≤(n:ℝ) := by
    have hh : 4*logDimension d≤logDimension d^3 := by nlinarith [sq_nonneg (logDimension d-2)]
    have he := Real.exp_le_exp.mpr hh
    rw [show (4:ℝ)=(4:ℕ) by norm_num,Real.exp_nat_mul] at he
    simpa only [logDimension, Real.exp_log hD] using he.trans hmin
  have hgood : A*(lowDimension d 1:ℝ)*Real.log (8*(n:ℝ))≤n := by
    have hdim : lowDimension d 1=d+1 := by simp [lowDimension_eq_sum,Finset.sum_range_succ,Nat.add_comm]
    rw [hdim]
    push_cast
    calc
      _ ≤ ((d:ℝ)+1)*((d:ℝ)+1)*(2*(d:ℝ)) := by gcongr
      _ ≤ ((d:ℝ)+1)^4 := by nlinarith [sq_nonneg (d:ℝ)]
      _ ≤ n := hpoly
  let R : ℕ := 2*⌈α*(d:ℝ)/4⌉₊+1
  have hRodd : Odd R := ⟨_,rfl⟩
  have hRlo : α*(d:ℝ)/2+1≤(R:ℝ) := by
    have hh := Nat.le_ceil (α*(d:ℝ)/4)
    dsimp [R]
    push_cast
    linarith
  have hRhi : (R:ℝ)≤α*(d:ℝ) := by
    have hh := Nat.ceil_lt_add_one (show 0≤α*(d:ℝ)/4 by positivity)
    dsimp [R]
    push_cast
    linarith only [hh,hdα]
  have hR1 : 1<R := by
    have hh : (1:ℝ)<R := by linarith only [hRlo,hdα]
    exact_mod_cast hh
  have hRdim : 3*R≤d := by
    have hh := mul_le_mul_of_nonneg_right hα hd0
    have hg : (3:ℝ)*(R:ℝ)≤d := by nlinarith only [hRhi,hh,hd0]
    exact_mod_cast hg
  have hbad : (n:ℝ)<A*(lowDimension d R:ℝ)*Real.log (8*(n:ℝ)) := by
    have hpow : (2:ℝ)^R≤(lowDimension d R:ℝ) := by exact_mod_cast lowDimension_two_pow hRdim
    have he : Real.exp ((α/8)*(d:ℝ))<(2:ℝ)^R := by
      rw [← Real.exp_log (by positivity : (0:ℝ)<(2:ℝ)^R),Real.log_pow]
      apply Real.exp_lt_exp.mpr
      have hh := mul_le_mul_of_nonneg_left log_two_lower (Nat.cast_nonneg R : (0:ℝ)≤R)
      nlinarith only [hh,hRlo,hdα]
    have hdim0 : (0:ℝ)≤lowDimension d R := Nat.cast_nonneg _
    have hh := mul_le_mul_of_nonneg_right hA1 hdim0
    have hh' := mul_le_mul_of_nonneg_left hL1 (mul_nonneg (by linarith only [hA1]) hdim0)
    exact (hmax.trans_lt he).trans_le (by nlinarith only [hpow,hh,hh'])
  obtain ⟨r,hr1,hrR,hrodd,hthr,hnext⟩ :=
    exists_odd_threshold_cutoff d n 1 R A hR1 (by decide) hRodd hgood hbad
  have hrhi : (r:ℝ)≤α*(d:ℝ) := (by exact_mod_cast hrR.le : (r:ℝ)≤R).trans hRhi
  have hnpoly : (n:ℝ)<((d:ℝ)+1)^(r+5) := by
    have hdim : (lowDimension d (r+2):ℝ)≤((d:ℝ)+1)^(r+2) := by
      exact_mod_cast lowDimension_pow d (r+2)
    apply hnext.trans_le
    calc
      _ ≤ ((d:ℝ)+1)*((d:ℝ)+1)^(r+2)*(2*((d:ℝ)+1)) := by gcongr; linarith only [hL]
      _ = 2*((d:ℝ)+1)^(r+4) := by ring
      _ ≤ ((d:ℝ)+1)^(r+5) := by
        calc
          _ ≤ ((d:ℝ)+1)*((d:ℝ)+1)^(r+4) :=
            mul_le_mul_of_nonneg_right hD2 (pow_nonneg hD.le _)
          _ = _ := by ring
  have hlog := Real.log_lt_log hn0 hnpoly
  rw [Real.log_pow] at hlog
  have hrlo : logDimension d^2/2≤(r:ℝ) := by
    have hh : logDimension d^3<((r:ℝ)+5)*logDimension d := by
      simpa only [Nat.cast_add,Nat.cast_ofNat,logDimension] using hlogn.trans_lt hlog
    have hh' : logDimension d^2<(r:ℝ)+5 := by
      apply (mul_lt_mul_iff_right₀ hL0).mp
      nlinarith only [hh]
    nlinarith only [hh',hdlog,sq_nonneg (logDimension d-128)]
  have hband := (additionalBand_bounds (by linarith only [hdlog] : 1≤logDimension d)).2
  have hbandr : additionalBand d≤r := by
    have hh : (additionalBand d:ℝ)≤r := by
      nlinarith only [hband,hrlo,hdlog,sq_nonneg (logDimension d-128)]
    exact_mod_cast hh
  have hdim : 64*(r+additionalBand d)≤d := by
    have hh := mul_le_mul_of_nonneg_right hα hd0
    have hr : (128:ℝ)*(r:ℝ)≤d := by nlinarith only [hrhi,hh]
    have hnat : 128*r≤d := by exact_mod_cast hr
    omega
  exact ⟨r,hr1,hrodd,hrhi,hrlo,hthr,hnext,samplingBudget_of_threshold hn hA hthr,by omega,hdim⟩

/-- The construction is uniform over every specified sample size in the
entire large-sample exponential interval. -/
theorem eventually_exists_cutoffs (A α : ℝ) (hA : (2:ℝ)^79≤A)
    (hα0 : 0<α) (hα : α≤1/128) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ,
      Real.exp (logDimension d^3)≤(n:ℝ) →
      (n:ℝ)≤Real.exp ((α/8)*(d:ℝ)) →
      ∃ r : ℕ, 1≤r ∧ Odd r ∧ (r:ℝ)≤α*(d:ℝ) ∧
        logDimension d^2/2≤(r:ℝ) ∧
        A*(lowDimension d r:ℝ)*Real.log (8*(n:ℝ))≤n ∧
        (n:ℝ)<A*(lowDimension d (r+2):ℝ)*Real.log (8*(n:ℝ)) ∧
        paritySquaredSamplingBudget d r n≤n ∧
        r+additionalBand d≤2*r ∧ 64*(r+additionalBand d)≤d := by
  have hdim : Tendsto (fun d : ℕ => (d:ℝ)) atTop atTop := tendsto_natCast_atTop_atTop
  filter_upwards [hdim.eventually_ge_atTop A,
    hdim.eventually_ge_atTop (16/α),logDimension_tendsto.eventually_ge_atTop 128]
    with d hdA hdα hdlog n hmin hmax
  exact exists_cutoffs_finite hA hα0 hα (by linarith only [hdA])
    (by simpa only [mul_comm] using (div_le_iff₀ hα0).mp hdα) hdlog hmin hmax

lemma sample_log_small_eventually {c : ℝ} (hc : 0<c) :
    ∀ᶠ d : ℕ in atTop, ∀ n : ℕ, 0<n →
      (n:ℝ)≤Real.exp (c*(d:ℝ)) → Real.log (8*(n:ℝ))≤2*c*(d:ℝ) := by
  have hdim : Tendsto (fun d : ℕ => (d:ℝ)) atTop atTop := tendsto_natCast_atTop_atTop
  filter_upwards [hdim.eventually_ge_atTop (3/c)] with d hd n hn hmax
  have hn0 : (0:ℝ)<n := Nat.cast_pos.mpr hn
  have hlog := Real.log_le_log hn0 hmax
  rw [Real.log_exp] at hlog
  rw [Real.log_mul (by norm_num : (8:ℝ)≠0) hn0.ne']
  have hh := (div_le_iff₀ hc).mp hd
  linarith only [hlog,hh,log_eight_upper]

end NeuralGeneralization.AdaptiveCutoff
