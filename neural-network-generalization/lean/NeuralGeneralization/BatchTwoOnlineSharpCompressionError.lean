import NeuralGeneralization.SampledNetworkError

/-! Sharp square-root energy propagation for the explicit online appendix
compression budget. The actual sampling and truncation objects are unchanged. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoOnlineSharp
open ConcreteModel Compression CompressionSampling

lemma sqrt_power_square {K : ℝ} (hK : 0≤K) (a : ℕ) : (Real.sqrt K^a)^2=K^a := by
  rw [pow_right_comm,Real.sq_sqrt hK]

lemma twice_sqrt_power_square {K : ℝ} (hK : 0≤K) (a : ℕ) : ((2*Real.sqrt K)^a)^2=(4*K)^a := by
  rw [pow_right_comm,mul_pow,Real.sq_sqrt hK]
  norm_num

theorem pruned_step_sharp {d N r : ℕ} (hN : 0<N) (φ : ℝ→ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ} (hρ : 0<ρ) (hq : 0<q)
    (hqsq : q^2=(N:ℝ)) (hK : 1≤K) (w : Weights d N r)
    (hw : weightedSquaredNorm w≤K) (x : Cube d) (s : Fin r) :
    |mixedOutput φ w (prunedWeights ρ q w) (fun _ i=>i) x s.castSucc-
      mixedOutput φ w (prunedWeights ρ q w) (fun _ i=>i) x s.succ|≤
      ρ*(Real.sqrt K)^(r+1) := by
  have hNR:(N:ℝ)≠0:=by exact_mod_cast hN.ne'
  have hK0:0≤K:=by linarith
  let v:=prunedWeights ρ q w
  have hvc:weightedSquaredNorm v≤K:=(prunedWeights_cost_le ρ q w).trans hw
  have hg:suffixSquaredGain v (s.val+1)≤K/(N:ℝ)*K^(r-1) :=
    (suffixSquaredGain_le_of_cost hN v hK0 hvc _).trans
      (mul_le_mul_of_nonneg_left (pow_le_pow_right₀ hK (by omega)) (by positivity))
  have hj:(∑i,rowReplacementError φ w v (fun _ i=>i) x s i^2)≤ρ^2*(N:ℝ)*K/4 := by
    have hp:=pruned_rowReplacement_squaredSum_le φ hφ.1 hρ hq w x s
    have hi:=(internal_squaredNorm_le_cost w s).trans hw
    have hh:=hp.trans (mul_le_mul_of_nonneg_left hi (sq_nonneg (ρ/2*q)))
    have he:(ρ/2*q)^2*K=ρ^2*(N:ℝ)*K/4:=by rw [←hqsq];ring
    exact he ▸ hh
  have hm:=mul_le_mul hg hj (Finset.sum_nonneg (fun _ _=>sq_nonneg _))
    (by positivity : 0≤K/(N:ℝ)*K^(r-1))
  have he:(K/(N:ℝ)*K^(r-1))*(ρ^2*(N:ℝ)*K/4)=ρ^2*K^(r+1)/4 := by
    have hr:0<r:=Nat.zero_lt_of_lt s.isLt
    rw [show r+1=(r-1)+2 by omega,pow_add]
    field_simp <;> ring
  rw [he] at hm
  apply abs_le_of_sq_le_sq _ (by positivity)
  rw [mul_pow,sqrt_power_square hK0]
  have hb:ρ^2*K^(r+1)/4≤ρ^2*K^(r+1):=by nlinarith [mul_nonneg (sq_nonneg ρ) (pow_nonneg hK0 (r+1))]
  exact (mixedOutput_replacement_step_squared_le φ hφ.2 w v (fun _ i=>i) x s).trans (hm.trans hb)

theorem pruned_readout_sharp {d N r : ℕ} (φ : ℝ→ℝ) (hφ : admissibleActivation φ)
    {ρ q K : ℝ} (hρ : 0<ρ) (hq : 0<q) (hqsq : q^2=(N:ℝ)) (hK : 1≤K)
    (w : Weights d N r) (hw : weightedSquaredNorm w≤K) (x : Cube d) :
    |mixedOutput φ w (prunedWeights ρ q w) (fun _ i=>i) x (Fin.last r)-networkOutput φ w x|≤
      ρ*(Real.sqrt K)^(r+1) := by
  have hp:=pruned_output_preactivation_error hρ hq w (finalHidden φ w x)
    (fun j=>by simpa only [hiddenPrefix_last] using hiddenPrefix_bounded φ hφ.1 w x r j)
  have hh:|mixedOutput φ w (prunedWeights ρ q w) (fun _ i=>i) x (Fin.last r)-networkOutput φ w x|≤
      ρ/2*q*outputRowNorm w := by
    simpa only [mixedOutput,Fin.val_last,hiddenSuffix_last,hiddenPrefix_last,linearReadout,
      networkOutput,abs_sub_comm] using hp
  have hc:(N:ℝ)*outputRowNorm w^2≤K := by
    rw [outputRowNorm_sq]
    exact (output_squaredNorm_mul_width_le_cost w).trans hw
  have hs:(ρ/2*q*outputRowNorm w)^2≤ρ^2*K/4:=by
    have hm:=mul_le_mul_of_nonneg_left hc (sq_nonneg ρ)
    rw [←hqsq] at hm
    nlinarith
  have hpow:K≤K^(r+1):=by simpa using pow_le_pow_right₀ hK (show 1≤r+1 by omega)
  have hb:(ρ/2*q*outputRowNorm w)^2≤(ρ*(Real.sqrt K)^(r+1))^2:=by
    rw [mul_pow ρ ((Real.sqrt K)^(r+1)),sqrt_power_square (by linarith)]
    have hm:=mul_le_mul_of_nonneg_left hpow (sq_nonneg ρ)
    nlinarith [mul_nonneg (sq_nonneg ρ) (show 0≤K by linarith)]
  exact hh.trans ((le_abs_self _).trans (abs_le_of_sq_le_sq hb (by positivity)))

theorem pruned_output_sharp {d N r : ℕ} (hN : 0<N) (φ : ℝ→ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ} (hρ : 0<ρ) (hq : 0<q)
    (hqsq : q^2=(N:ℝ)) (hK : 1≤K) (w : Weights d N r)
    (hw : weightedSquaredNorm w≤K) (x : Cube d) :
    |networkOutput φ (prunedWeights ρ q w) x-networkOutput φ w x|≤
      ((r:ℝ)+1)*ρ*(Real.sqrt K)^(r+1) := by
  let F:=mixedOutput φ w (prunedWeights ρ q w) (fun _ i=>i) x
  have hc:=finite_chain_abs_le F
  have hs:(∑s : Fin r,|F s.castSucc-F s.succ|)≤(r:ℝ)*(ρ*(Real.sqrt K)^(r+1)) := by
    calc
      _ ≤ ∑_s : Fin r,ρ*(Real.sqrt K)^(r+1) := Finset.sum_le_sum
        (fun s _=>pruned_step_sharp hN φ hφ hρ hq hqsq hK w hw x s)
      _ = _ := by simp
  have hr:=pruned_readout_sharp φ hφ hρ hq hqsq hK w hw x
  have ht:=abs_sub_le (F 0) (F (Fin.last r)) (networkOutput φ w x)
  have hzero:F 0=networkOutput φ (prunedWeights ρ q w) x :=
    mixedOutput_zero_of_first_eq φ w _ _ x (fun _ _=>rfl)
  rw [hzero] at ht hc
  change |F (Fin.last r)-networkOutput φ w x|≤_ at hr
  nlinarith


theorem sampled_step_sharp {d N r M : ℕ} (hM : 0<M) (φ : ℝ→ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ} (hρ : 0<ρ) (hq : 0<q)
    (hqsq : q^2=(N:ℝ)) (hK : 1≤K) (w u : Weights d N r)
    (I : Fin (r+1)→Fin M→Fin N) (hcost : weightedSquaredNorm (sampledWeights u I)≤4*K)
    (hmass : retainedRowMass w I≤8*(M:ℝ)*K) (x : Cube d) (s : Fin r)
    (hrow : ∀a,|rowSamplingError φ u I x s a|≤ρ/2*q*internalRowNorm w s (I s.succ a)) :
    |mixedOutput φ u (sampledWeights u I) I x s.castSucc-
      mixedOutput φ u (sampledWeights u I) I x s.succ|≤ρ*(2*Real.sqrt K)^(r+1) := by
  have hMR:(M:ℝ)≠0:=by exact_mod_cast hM.ne'
  have hK0:0≤K:=by linarith
  have h4K:1≤4*K:=by linarith
  have hg:suffixSquaredGain (sampledWeights u I) (s.val+1)≤(4*K)/(M:ℝ)*(4*K)^(r-1) :=
    (suffixSquaredGain_le_of_cost hM _ (by positivity) hcost _).trans
      (mul_le_mul_of_nonneg_left (pow_le_pow_right₀ h4K (by omega)) (by positivity))
  have hj:=sampled_row_errors_squaredSum_le φ hρ hq hqsq w u I hmass x s hrow
  have hm:=mul_le_mul hg hj (Finset.sum_nonneg (fun _ _=>sq_nonneg _))
    (by positivity : 0≤(4*K)/(M:ℝ)*(4*K)^(r-1))
  have he:((4*K)/(M:ℝ)*(4*K)^(r-1))*(2*ρ^2*(M:ℝ)*K)=ρ^2*(4*K)^(r+1)/2 := by
    have hr:0<r:=Nat.zero_lt_of_lt s.isLt
    rw [show r+1=(r-1)+2 by omega,pow_add]
    field_simp <;> ring
  rw [he] at hm
  apply abs_le_of_sq_le_sq _ (by positivity)
  rw [mul_pow,twice_sqrt_power_square hK0]
  have hb:ρ^2*(4*K)^(r+1)/2≤ρ^2*(4*K)^(r+1) := by
    nlinarith [mul_nonneg (sq_nonneg ρ) (pow_nonneg (by positivity : 0≤4*K) (r+1))]
  exact (mixedOutput_step_squared_le φ hφ.2 u I x s).trans (hm.trans hb)

theorem sampled_readout_sharp {d N r M : ℕ} (φ : ℝ→ℝ)
    {ρ q K : ℝ} (hρ : 0<ρ) (hqsq : q^2=(N:ℝ)) (hK : 1≤K)
    (w u : Weights d N r) (hw : weightedSquaredNorm w≤K)
    (I : Fin (r+1)→Fin M→Fin N) (x : Cube d)
    (hread : |((N:ℝ)/M)*∑a,u (Sum.inr (Sum.inr (I (Fin.last r) a)))*finalHidden φ u x (I (Fin.last r) a)-
      networkOutput φ u x|≤ρ/2*q*outputRowNorm w) :
    |((N:ℝ)/M)*∑a,u (Sum.inr (Sum.inr (I (Fin.last r) a)))*finalHidden φ u x (I (Fin.last r) a)-
      networkOutput φ u x|≤ρ*(2*Real.sqrt K)^(r+1) := by
  have hc:(N:ℝ)*outputRowNorm w^2≤K:=by
    rw [outputRowNorm_sq]
    exact (output_squaredNorm_mul_width_le_cost w).trans hw
  have hs:(ρ/2*q*outputRowNorm w)^2≤ρ^2*K/4:=by
    have hm:=mul_le_mul_of_nonneg_left hc (sq_nonneg ρ)
    rw [←hqsq] at hm
    nlinarith
  have hK0:0≤K:=by linarith
  have hpow:K≤(4*K)^(r+1):=by
    have hh:=pow_le_pow_right₀ (show 1≤4*K by linarith) (show 1≤r+1 by omega)
    simp only [pow_one] at hh
    linarith
  have hb:(ρ/2*q*outputRowNorm w)^2≤(ρ*(2*Real.sqrt K)^(r+1))^2:=by
    rw [mul_pow ρ ((2*Real.sqrt K)^(r+1)),twice_sqrt_power_square hK0]
    nlinarith [mul_le_mul_of_nonneg_left hpow (sq_nonneg ρ),mul_nonneg (sq_nonneg ρ) hK0]
  exact hread.trans ((le_abs_self _).trans (abs_le_of_sq_le_sq hb (by positivity)))

theorem sampled_output_sharp {d N r M : ℕ} (hM : 0<M) (φ : ℝ→ℝ)
    (hφ : admissibleActivation φ) {ρ q K : ℝ} (hρ : 0<ρ) (hq : 0<q)
    (hqsq : q^2=(N:ℝ)) (hK : 1≤K) (w u : Weights d N r) (hw : weightedSquaredNorm w≤K)
    (I : Fin (r+1)→Fin M→Fin N) (hcost : weightedSquaredNorm (sampledWeights u I)≤4*K)
    (hmass : retainedRowMass w I≤8*(M:ℝ)*K) (x : Cube d)
    (hrow : ∀s a,|rowSamplingError φ u I x s a|≤ρ/2*q*internalRowNorm w s (I s.succ a))
    (hread : |((N:ℝ)/M)*∑a,u (Sum.inr (Sum.inr (I (Fin.last r) a)))*finalHidden φ u x (I (Fin.last r) a)-
      networkOutput φ u x|≤ρ/2*q*outputRowNorm w) :
    |networkOutput φ (sampledWeights u I) x-networkOutput φ u x|≤
      ((r:ℝ)+1)*ρ*(2*Real.sqrt K)^(r+1) := by
  let F:=mixedOutput φ u (sampledWeights u I) I x
  have hc:=finite_chain_abs_le F
  have hs:(∑s : Fin r,|F s.castSucc-F s.succ|)≤(r:ℝ)*(ρ*(2*Real.sqrt K)^(r+1)) := by
    calc
      _ ≤ ∑_s : Fin r,ρ*(2*Real.sqrt K)^(r+1) := Finset.sum_le_sum
        (fun s _=>sampled_step_sharp hM φ hφ hρ hq hqsq hK w u I hcost hmass x s (hrow s))
      _ = _ := by simp
  have hr:=sampled_readout_sharp φ hρ hqsq hK w u hw I x hread
  have ht:=abs_sub_le (F 0) (F (Fin.last r)) (networkOutput φ u x)
  have hzero:F 0=networkOutput φ (sampledWeights u I) x:=mixedOutput_zero φ u I x
  rw [hzero] at ht hc
  have hlast:F (Fin.last r)=((N:ℝ)/M)*∑a,u (Sum.inr (Sum.inr (I (Fin.last r) a)))*finalHidden φ u x (I (Fin.last r) a):=
    mixedOutput_last φ u I x
  rw [←hlast] at hr
  nlinarith

end NeuralGeneralization.BatchTwoOnlineSharp
