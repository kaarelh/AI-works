import NeuralGeneralization.UniformAdaptiveCutoff

/-! Exact cancellation of the adaptive dimension threshold against the
binomial factor in the actual sharp neural spectrum. -/
noncomputable section
namespace NeuralGeneralization.AdaptiveCutoff
open SmallSampleCutoff

lemma next_threshold_binomial {d r n : ℕ} {A : ℝ}
    (hA : 0≤A) (hn : 0<n) (hdim : 3*(r+2)≤d)
    (hnext : (n:ℝ)<A*(lowDimension d (r+2):ℝ)*Real.log (8*(n:ℝ))) :
    (n:ℝ)≤2*A*Real.log (8*(n:ℝ))*((d+1).choose (r+2):ℝ) := by
  have hdim' := (lowDimension_le_twice_choose hdim).trans
    (Nat.mul_le_mul_left 2 (Nat.choose_le_choose (r+2) (Nat.le_succ d)))
  have hcast : (lowDimension d (r+2):ℝ)≤2*((d+1).choose (r+2):ℝ) := by exact_mod_cast hdim'
  have hL : 0≤Real.log (8*(n:ℝ)) := (by norm_num : (0:ℝ)≤1).trans (log_eight_sample_ge_one hn)
  apply hnext.le.trans
  have hh := mul_le_mul_of_nonneg_right (mul_le_mul_of_nonneg_left hcast hA) hL
  nlinarith only [hh]

lemma additionalBand_pow_lower {d : ℕ} (hd : 1≤logDimension d) :
    ((d:ℝ)+1)^20≤(2:ℝ)^(additionalBand d) := by
  have hb := (additionalBand_bounds hd).1
  have hh := mul_le_mul_of_nonneg_left log_two_lower
    (Nat.cast_nonneg (additionalBand d) : (0:ℝ)≤additionalBand d)
  have he : 20*logDimension d≤(additionalBand d:ℝ)*Real.log 2 := by linarith only [hb,hh]
  have hexp := Real.exp_le_exp.mpr he
  rw [show (20:ℝ)=(20:ℕ) by norm_num,Real.exp_nat_mul,Real.exp_nat_mul] at hexp
  simpa only [logDimension,Real.exp_log (by positivity : (0:ℝ)<(d:ℝ)+1),
    Real.exp_log (by norm_num : (0:ℝ)<2)] using hexp

lemma band_choose_growth {d r u : ℕ} (hru : r≤u) (hdim : 3*(u+2)≤d+1) :
    (2:ℝ)^(u-r)*((d+1).choose (r+2):ℝ)≤((d+1).choose (u+2):ℝ) := by
  have hh := BinomialGeometry.choose_growth (D:=d+1) (k:=r+2) (j:=u+2) (B:=u+2)
    (by omega) le_rfl hdim
  rw [show u+2-(r+2)=u-r by omega] at hh
  exact_mod_cast hh

lemma sampled_eigenvalue_budget {n L A U T r K ell : ℝ}
    (hL : 0≤L) (hA : 0≤A) (hU : 0≤U) (hT : 0≤T) (hr : 0<r) (hK : 0<K)
    (hn : 0≤n) (hnext : n≤2*A*L*K) (hell : ell≤U*T/(r*K)) :
    n*ell≤2*A*U*L*T/r := by
  have h1 := mul_le_mul_of_nonneg_left hell hn
  have h2 := mul_le_mul_of_nonneg_right hnext (show 0≤U*T/(r*K) by positivity)
  apply h1.trans
  calc
    _ ≤ (2*A*L*K)*(U*T/(r*K)) := h2
    _ = _ := by field_simp <;> ring

lemma sampled_second_moment_budget {n d L A U T r K s₂ : ℝ}
    (hd : 0≤d) (hL : 0≤L) (hA : 0≤A) (hU : 0≤U) (hT : 0≤T)
    (hr : 0<r) (hK : 0<K) (hn : 0≤n)
    (hnext : n≤2*A*L*K) (hs : s₂≤U*T^2/(r^2*K)) :
    Real.sqrt (n*d*s₂)≤Real.sqrt (2*A*U)*T*Real.sqrt (d*L)/r := by
  have h1 := mul_le_mul_of_nonneg_left hs (mul_nonneg hn hd)
  have h2 := mul_le_mul_of_nonneg_right hnext (show 0≤d*(U*T^2/(r^2*K)) by positivity)
  have hbound : n*d*s₂≤2*A*U*T^2*(d*L)/r^2 := by
    have he : (2*A*L*K)*(d*(U*T^2/(r^2*K)))=2*A*U*T^2*(d*L)/r^2 := by
      field_simp <;> ring
    nlinarith only [h1,h2,he]
  apply (Real.sqrt_le_left (by positivity : 0≤Real.sqrt (2*A*U)*T*Real.sqrt (d*L)/r)).mpr
  rw [div_pow,mul_pow,mul_pow,Real.sq_sqrt (by positivity : 0≤2*A*U),
    Real.sq_sqrt (mul_nonneg hd hL)]
  nlinarith only [hbound]

/-- Dropping only the upper-cutoff power factor still leaves a rapidly
vanishing tail budget, because the additional band grows the binomial factor. -/
theorem sampled_upper_band_budget {d r n : ℕ} {A U : ℝ}
    (hA : 0≤A) (hU : 0≤U) (hn : 0<n) (hdlog : 1≤logDimension d)
    (hdim : 3*(r+additionalBand d+2)≤d)
    (hnext : (n:ℝ)<A*(lowDimension d (r+2):ℝ)*Real.log (8*(n:ℝ)))
    (hlog : Real.log (8*(n:ℝ))≤2*(d:ℝ)) :
    (n:ℝ)*(U/((d+1).choose (r+additionalBand d+2):ℝ))≤
      4*A*U*(d:ℝ)/((d:ℝ)+1)^20 := by
  let K : ℝ := ((d+1).choose (r+2):ℝ)
  let K' : ℝ := ((d+1).choose (r+additionalBand d+2):ℝ)
  have hK : 0<K := Nat.cast_pos.mpr (Nat.choose_pos (by omega))
  have hK' : 0<K' := Nat.cast_pos.mpr (Nat.choose_pos (by omega))
  have hD : 0<(d:ℝ)+1 := by positivity
  have hnext' := next_threshold_binomial hA hn (by omega) hnext
  have hg := band_choose_growth (d:=d) (r:=r) (u:=r+additionalBand d) (by omega) (by omega)
  rw [Nat.add_sub_cancel_left] at hg
  have hgrowth : ((d:ℝ)+1)^20*K≤K' :=
    (mul_le_mul_of_nonneg_right (additionalBand_pow_lower hdlog) hK.le).trans hg
  change (n:ℝ)*(U/K')≤_
  apply (le_div_iff₀ (pow_pos hD _)).mpr
  have h1 := mul_le_mul_of_nonneg_right hnext' hU
  have h2 := mul_le_mul_of_nonneg_left hlog (show 0≤2*A*K*U by positivity)
  have h3 := mul_le_mul_of_nonneg_left hgrowth (show 0≤4*A*U*(d:ℝ) by positivity)
  apply (mul_le_mul_iff_left₀ hK').mp
  have he : ((n:ℝ)*(U/K')*((d:ℝ)+1)^20)*K'=(n:ℝ)*U*((d:ℝ)+1)^20 := by field_simp
  rw [he]
  have h4 : (n:ℝ)*U≤4*A*U*(d:ℝ)*K := by nlinarith only [h1,h2]
  have h5 := mul_le_mul_of_nonneg_right h4 (pow_nonneg hD.le 20)
  nlinarith only [h3,h5]

end NeuralGeneralization.AdaptiveCutoff
