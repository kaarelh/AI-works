import NeuralGeneralization.BatchTwoContinuousDepthCriticalUniformTracking
import NeuralGeneralization.BatchTwoContinuousDepthCriticalSeedRows

/-! Explicit population constants and stable signal recovery for the critical
training interpolator. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical

noncomputable def seedSignal (n P:ℕ) : ℝ := 7/(32*(n:ℝ)*(P:ℝ))
noncomputable def retainedSignal (n P h:ℕ) : ℝ :=
  seedSignal n P*Real.exp (-(1+Real.log ((h:ℝ)+1))/(coolingConstant*derivativeFloor))/2
noncomputable def robustAmplificationGain : ℝ := 4/amplificationConstant
noncomputable def saturationGain : ℝ := (2+Real.log 200)/amplificationConstant

theorem gaussianRowMean_eq_shiftedMean {I:Type*} [Fintype I] (c:I→ℝ) (m:ℝ) :
    gaussianRowMean c m=shiftedMean (∑i,c i^2) m :=
  gaussian_row_integral c (fun z=>Real.tanh (m+z)) (by fun_prop)

theorem shiftedSecond_bounds (q m:ℝ) : 0≤shiftedSecond q m ∧ shiftedSecond q m≤1 := by
  refine ⟨integral_nonneg (fun _=>sq_nonneg _),?_⟩
  have hh:=norm_integral_le_of_norm_le_const (μ:=gaussianReal 0 1)
    (f:=fun z:ℝ=>Real.tanh (m+Real.sqrt q*z)^2) (C:=1)
    (Filter.Eventually.of_forall fun z=>by
      rw [Real.norm_eq_abs,abs_of_nonneg (sq_nonneg _)]
      exact (sq_le_one_iff_abs_le_one _).mpr (Real.abs_tanh_lt_one _).le)
  have hnon : 0≤(∫z:ℝ,Real.tanh (m+Real.sqrt q*z)^2 ∂gaussianReal 0 1) := integral_nonneg (fun z=>sq_nonneg _)
  simpa only [shiftedSecond,Real.norm_eq_abs,abs_of_nonneg hnon,probReal_univ,mul_one] using hh

theorem shiftedMean_abs_le_one (q m:ℝ) : |shiftedMean q m|≤1 := by
  have hh:=norm_integral_le_of_norm_le_const (μ:=gaussianReal 0 1)
    (f:=fun z:ℝ=>Real.tanh (m+Real.sqrt q*z)) (C:=1)
    (Filter.Eventually.of_forall fun z=>by simpa only [Real.norm_eq_abs] using (Real.abs_tanh_lt_one _).le)
  simpa only [shiftedMean,Real.norm_eq_abs,measureReal_univ_eq_one,mul_one] using hh

def momentBox (J:Type*) : Set ((J→ℝ)×(J→ℝ)) :=
  Icc (fun _=>0) (fun _=>1) ×ˢ Icc (fun _=>-1) (fun _=>1)

theorem momentBox_compact (J:Type*) [Fintype J] : IsCompact (momentBox J) :=
  isCompact_Icc.prod isCompact_Icc

theorem freeMomentMap_mem {J:Type*} {s:(J→ℝ)×(J→ℝ)} (hs:s∈momentBox J) :
    freeMomentMap s∈momentBox J := by
  refine ⟨⟨fun i=>coolingSecondMoment_nonneg _,fun i=>
    (coolingSecondMoment_le _ (hs.1.1 i)).trans (hs.1.2 i)⟩,⟨?_,?_⟩⟩
  · intro i
    have hp:0≤coolingDerivative (s.1 i):=(coolingDerivative_pos _).le
    have hu:coolingDerivative (s.1 i)≤1 := by rw [coolingDerivative_eq];linarith [coolingSecondMoment_nonneg (s.1 i)]
    have hm:=mul_le_mul_of_nonneg_right (hs.2.1 i) hp
    change -1≤s.2 i*coolingDerivative (s.1 i)
    nlinarith
  · intro i
    have hp:0≤coolingDerivative (s.1 i):=(coolingDerivative_pos _).le
    have hu:coolingDerivative (s.1 i)≤1 := by rw [coolingDerivative_eq];linarith [coolingSecondMoment_nonneg (s.1 i)]
    have hm:=mul_le_mul_of_nonneg_right (hs.2.2 i) hp
    change s.2 i*coolingDerivative (s.1 i)≤1
    nlinarith

theorem freeMomentMap_uniformContinuous {J:Type*} [Fintype J] :
    UniformContinuousOn (@freeMomentMap J) (momentBox J) :=
  (momentBox_compact J).uniformContinuousOn_of_continuous freeMomentMap_continuous.continuousOn

theorem seedSignal_pos {n P:ℕ} (hn:0<n) (hP:0<P) : 0<seedSignal n P := by
  unfold seedSignal
  positivity

theorem seedSignal_le_one {n P:ℕ} (hn:0<n) (hP:0<P) : seedSignal n P≤1 := by
  have hnR:(1:ℝ)≤n:=by exact_mod_cast hn
  have hPR:(1:ℝ)≤P:=by exact_mod_cast hP
  unfold seedSignal
  apply (div_le_iff₀ (by positivity)).mpr
  nlinarith

theorem retainedSignal_pos {n P:ℕ} (hn:0<n) (hP:0<P) (h:ℕ) : 0<retainedSignal n P h := by
  unfold retainedSignal
  exact div_pos (mul_pos (seedSignal_pos hn hP) (Real.exp_pos _)) (by norm_num)

theorem retainedSignal_le_one {n P:ℕ} (hn:0<n) (hP:0<P) (h:ℕ) : retainedSignal n P h≤1 := by
  have he:Real.exp (-(1+Real.log ((h:ℝ)+1))/(coolingConstant*derivativeFloor))≤1 := by
    apply Real.exp_le_one_iff.mpr
    apply div_nonpos_of_nonpos_of_nonneg
    · have hl:=Real.log_nonneg (show (1:ℝ)≤(h:ℝ)+1 by have : (0:ℝ)≤h:=Nat.cast_nonneg h;linarith)
      linarith
    · exact mul_nonneg coolingConstant_pos.le derivativeFloor_pos.le
  have hm:=mul_le_mul (seedSignal_le_one hn hP) he (Real.exp_pos _).le (by norm_num : (0:ℝ)≤1)
  unfold retainedSignal
  linarith

theorem robustAmplificationGain_pos : 0<robustAmplificationGain :=
  div_pos (by norm_num) amplificationConstant_pos

/-- A small row-mean error still permits doubling, uniformly over the actual
variance. No covariance tracking is needed in the controlled layers. -/
theorem robust_amplification_step {u b v ε:ℝ} (hu:0<u)
    (hb:u≤b) (hεu:ε≤u) (hεC:ε≤amplificationConstant/2)
    (hv:amplificationConstant*min (robustAmplificationGain*b) 1-ε≤v) :
    min (2*b) (amplificationConstant/2)≤v := by
  have hc:=amplificationConstant_pos
  have he:amplificationConstant*min (robustAmplificationGain*b) 1=min (4*b) amplificationConstant := by
    rw [mul_min_of_nonneg _ _ hc.le,mul_one]
    unfold robustAmplificationGain
    congr 1
    field_simp
  rw [he] at hv
  by_cases h:4*b≤amplificationConstant
  · rw [min_eq_left h] at hv
    have hh:min (2*b) (amplificationConstant/2)≤2*b:=min_le_left _ _
    linarith
  · rw [min_eq_right (le_of_not_ge h)] at hv
    exact (min_le_right _ _).trans (by linarith)

theorem robust_amplification_iterate {u:ℝ} (hu:0<u)
    (b:ℕ→ℝ) (hb0:u≤b 0)
    (hstep:∀s,min (2*b s) (amplificationConstant/2)≤b (s+1)) :
    ∀s,min ((2:ℝ)^s*u) (amplificationConstant/2)≤b s := by
  intro s
  induction s with
  | zero=>simpa only [pow_zero,one_mul] using (min_le_left u (amplificationConstant/2)).trans hb0
  | succ s ih=>
    have hh:min (2*min ((2:ℝ)^s*u) (amplificationConstant/2)) (amplificationConstant/2)≤
        min (2*b s) (amplificationConstant/2):=
      min_le_min (mul_le_mul_of_nonneg_left ih (by norm_num : (0:ℝ)≤2)) le_rfl
    have he:min (2*min ((2:ℝ)^s*u) (amplificationConstant/2)) (amplificationConstant/2)=
        min ((2:ℝ)^(s+1)*u) (amplificationConstant/2) := by
      rw [mul_min_of_nonneg _ _ (by norm_num : (0:ℝ)≤2),pow_succ]
      rw [min_assoc,min_eq_right (show amplificationConstant/2≤2*(amplificationConstant/2) by linarith [amplificationConstant_pos])]
      congr 1
      ring
    rw [he] at hh
    exact hh.trans (hstep s)

theorem robust_amplification_reaches {u:ℝ} (hu:0<u) (hu1:u≤1)
    (b:ℕ→ℝ) (hb0:u≤b 0)
    (hstep:∀s,min (2*b s) (amplificationConstant/2)≤b (s+1)) :
    amplificationConstant/2≤b (amplificationCount u) := by
  have hh:=robust_amplification_iterate hu b hb0 hstep (amplificationCount u)
  have hp:=amplificationCount_power hu hu1
  have hc:=amplificationConstant_le_half
  rwa [min_eq_right (by linarith)] at hh

end NeuralGeneralization.BatchTwoContinuousDepthCritical
