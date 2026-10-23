import NeuralGeneralization.BatchTwoImprovedResources

/-! The explicit sharp sample size pays the literal Gram concentration bound,
including its logarithm of the actual chosen sample size. -/
noncomputable section
namespace NeuralGeneralization.BatchTwoImprovedResources
open SquaredSampling
set_option maxRecDepth 4000
set_option exponentiation.threshold 512
set_option maxHeartbeats 400000

theorem bankSize_le_logEnvelope (p : Input) : bankSize p≤2^261*(logEnvelope p)^7 := by
  obtain ⟨hT,hK,hH,hR⟩ := basic_logEnvelope_bounds p
  have he := error_le_logEnvelope_sq p
  have hq := rank_le_logEnvelope p
  have hv := readoutMoment_le_logEnvelope p
  have hT4 : logEnvelope p≤(logEnvelope p)^4 := Nat.le_self_pow (by omega) _
  have hT5 : (logEnvelope p)^5≤(logEnvelope p)^7 := Nat.pow_le_pow_right hT (by omega)
  have hT6 : (logEnvelope p)^6≤(logEnvelope p)^7 := Nat.pow_le_pow_right hT (by omega)
  have hT7 : 1≤(logEnvelope p)^7 := Nat.one_le_pow _ _ hT
  have hfirst : p.energy+rank p+1≤4*(logEnvelope p)^4 := by omega
  have h1 := Nat.mul_le_mul hfirst he
  have h2 := Nat.mul_le_mul_right (logEnvelope p) (Nat.mul_le_mul hq (Nat.pow_le_pow_left hH 2))
  have h3 := Nat.mul_le_mul (Nat.mul_le_mul hv hH) (Nat.pow_le_pow_left hR 2)
  have hb : (p.energy+rank p+1)*inverseError p+rank p*(inverseFailure p)^2*logEnvelope p+
      readoutMoment p*inverseFailure p*(p.inverseRadius+1)^2≤17*(logEnvelope p)^7 := by
    have he1 : 4*(logEnvelope p)^4*(logEnvelope p)^2=4*(logEnvelope p)^6 := by ring
    have he2 : 3*(logEnvelope p)^4*(logEnvelope p)^2*logEnvelope p=3*(logEnvelope p)^7 := by ring
    have he3 : 10*(logEnvelope p)^2*logEnvelope p*(logEnvelope p)^2=10*(logEnvelope p)^5 := by ring
    rw [he1] at h1
    rw [he2] at h2
    rw [he3] at h3
    omega
  unfold bankSize
  have hh := Nat.mul_le_mul_left (2^256) hb
  norm_num at hh ⊢
  omega

theorem restrictionLog_allocation (p : Input) :
    restrictionLog (bankSize p) (rank p)≤512*logEnvelope p := by
  have hT : (1:ℝ)≤logEnvelope p := by exact_mod_cast (basic_logEnvelope_bounds p).1
  have hT0 : (0:ℝ)<logEnvelope p := by linarith
  have hm : (0:ℝ)<bankSize p := Nat.cast_pos.mpr (bankSize_pos p)
  have hq : (0:ℝ)<rank p := Nat.cast_pos.mpr (rank_pos p)
  have hb : (bankSize p:ℝ)≤2^261*(logEnvelope p:ℝ)^7 := by exact_mod_cast bankSize_le_logEnvelope p
  have hr : (rank p:ℝ)≤3*(logEnvelope p:ℝ)^4 := by exact_mod_cast rank_le_logEnvelope p
  have hlogT : Real.log (logEnvelope p:ℝ)≤logEnvelope p :=
    (Real.log_le_sub_one_of_pos hT0).trans (by linarith)
  have hl2 : Real.log (2:ℝ)≤1 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    norm_num at h
    exact h
  have hl3 : Real.log (3:ℝ)≤2 := by
    have h := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<3)
    norm_num at h
    exact h
  have hmLog := Real.log_le_log (by positivity : (0:ℝ)<8*bankSize p)
    (mul_le_mul_of_nonneg_left hb (by norm_num : (0:ℝ)≤8))
  have he : 8*((2:ℝ)^261*(logEnvelope p:ℝ)^7)=2^264*(logEnvelope p:ℝ)^7 := by
    rw [show (264:ℕ)=261+3 by norm_num,pow_add]
    norm_num
    ring
  rw [he,Real.log_mul (by positivity : (2:ℝ)^264≠0) (by positivity : (logEnvelope p:ℝ)^7≠0),Real.log_pow,Real.log_pow] at hmLog
  have hqLog := Real.log_le_log hq hr
  rw [Real.log_mul (by norm_num : (3:ℝ)≠0) (by positivity : (logEnvelope p:ℝ)^4≠0),Real.log_pow] at hqLog
  norm_num at hmLog hqLog
  have hd := dimensionCutoff_le_two_log (rank p)
  unfold restrictionLog
  push_cast
  nlinarith

theorem gram_allocation (p : Input) :
    256*(268435456:ℝ)^2*(2*rank p)*restrictionLog (bankSize p) (rank p)≤
      ((inverseFailure p:ℝ)⁻¹)^2*bankSize p := by
  have hh : (0:ℝ) < inverseFailure p := Nat.cast_pos.mpr (inverseFailure_pos p)
  have hbase : 2^256*(rank p*(inverseFailure p)^2*logEnvelope p)≤bankSize p := by
    unfold bankSize
    omega
  have hbaseR : (2:ℝ)^256*(rank p*(inverseFailure p:ℝ)^2*logEnvelope p)≤bankSize p := by
    exact_mod_cast hbase
  have hlog := restrictionLog_allocation p
  have hleft := mul_le_mul_of_nonneg_left hlog
    (by positivity : 0≤256*(268435456:ℝ)^2*(2*rank p))
  have hupper : 256*(268435456:ℝ)^2*(2*rank p)*(512*logEnvelope p)≤
      (2:ℝ)^256*rank p*logEnvelope p := by
    have hqT : 0≤(rank p:ℝ)*logEnvelope p := by positivity
    nlinarith only [hqT]
  have he : ((inverseFailure p:ℝ)⁻¹)^2*
      ((2:ℝ)^256*(rank p*(inverseFailure p:ℝ)^2*logEnvelope p))=
      (2:ℝ)^256*rank p*logEnvelope p := by field_simp
  exact hleft.trans (hupper.trans (he ▸ mul_le_mul_of_nonneg_left hbaseR (by positivity)))
end NeuralGeneralization.BatchTwoImprovedResources
