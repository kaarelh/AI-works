import NeuralGeneralization.BatchTwoImprovedGrid

/-! Resource exponents for the exact grid entropy. Constants below depend only
on resource coefficients, never on learner width or the accuracy parameters. -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel

private theorem log_le_resource {x a S:ℝ} {p:ℕ} (hx:0<x) (ha:0<a)
    (hS:1≤S) (hxbound:x≤a*S^p):
    Real.log x≤(a+p)*(1+Real.log S) := by
  have hSp:0<S := by linarith
  have hl:0≤Real.log S := Real.log_nonneg hS
  have hh:=Real.log_le_log hx hxbound
  rw [Real.log_mul ha.ne' (pow_ne_zero _ hSp.ne'),Real.log_pow] at hh
  have hla:=Real.log_le_sub_one_of_pos ha
  have ham:=mul_nonneg ha.le hl
  have hp:(0:ℝ)≤p := Nat.cast_nonneg p
  nlinarith

private theorem resource_parameter_count {d M r:ℕ} {a S:ℝ}
    (ha:1≤a) (hS:1≤S) (hd:(d:ℝ)≤S) (hr:(r:ℝ)≤S) (hM:(M:ℝ)≤a*S^21):
    (robustParameterCount d M r:ℝ)≤(3*a+a^2)*S^43 := by
  have hS0:0≤S := by linarith
  have ha0:0≤a := by linarith
  have hd2:(d:ℝ)+2≤3*S := by linarith
  have hlin:=mul_le_mul hM hd2 (by positivity) (by positivity : 0≤a*S^21)
  have hMsq: (M:ℝ)^2≤a^2*S^42 := by
    have hh:=(sq_le_sq₀ (Nat.cast_nonneg M) (by positivity : 0≤a*S^21)).mpr hM
    nlinarith [show (a*S^21)^2=a^2*S^42 by ring]
  have hquad:=mul_le_mul hr hMsq (sq_nonneg (M:ℝ)) hS0
  have hpow:S^22≤S^43 := pow_le_pow_right₀ hS (by omega)
  have hpl:=mul_le_mul_of_nonneg_left hpow (show 0≤3*a by positivity)
  unfold robustParameterCount
  push_cast
  nlinarith [show a*S^21*(3*S)=3*a*S^22 by ring,
    show S*(a^2*S^42)=a^2*S^43 by ring]

def improvedGridBudgetCoefficient (a b c:ℝ):ℝ :=
  (3*a+a^2)*(b+c+33+2*(a*(b+1)+46))

theorem improvedGridEntropy_resource_budget {d M r B R:ℕ} {a b c S:ℝ}
    (ha:1≤a) (hb:1≤b) (hc:1≤c) (hS:1≤S)
    (hd:(d:ℝ)≤S) (hr:(r:ℝ)≤S)
    (hM:(M:ℝ)≤a*S^21) (hB:(B:ℝ)≤b*S^24) (hR:(R:ℝ)≤c*S^3)
    (hBp:0<B) (hRp:0<R):
    improvedGridEntropy d M r B R≤ improvedGridBudgetCoefficient a b c*S^44*(1+Real.log S) := by
  have hS0:0≤S := by linarith
  have ha0:0<a := by linarith
  have hb0:0<b := by linarith
  have hc0:0<c := by linarith
  have hL:1≤1+Real.log S := by linarith [Real.log_nonneg hS]
  have hlogB:=log_le_resource (Nat.cast_pos.mpr hBp) hb0 hS hB
  have hlogR:=log_le_resource (Nat.cast_pos.mpr hRp) hc0 hS hR
  have hlogd:=log_le_resource (show 0<(d:ℝ)+1 by positivity)
    (show (0:ℝ)<2 by norm_num) hS (p:=1) (by simpa using show (d:ℝ)+1≤2*S by linarith)
  have hpow24:1≤S^24 := one_le_pow₀ hS
  have hBplus:(B:ℝ)+1≤(b+1)*S^24 := by nlinarith
  have hmul:=mul_le_mul hM hBplus (by positivity) (show 0≤a*S^21 by positivity)
  have hpow45:1≤S^45 := one_le_pow₀ hS
  have hbase:(M:ℝ)*((B:ℝ)+1)+1≤(a*(b+1)+1)*S^45 := by
    have he:a*S^21*((b+1)*S^24)=a*(b+1)*S^45 := by ring
    rw [he] at hmul
    nlinarith
  have hlogbase:=log_le_resource (show 0<(M:ℝ)*((B:ℝ)+1)+1 by positivity)
    (show 0<a*(b+1)+1 by positivity) hS hbase
  have hlog3:Real.log (3:ℝ)≤3*(1+Real.log S) := by
    linarith [Real.log_le_sub_one_of_pos (show (0:ℝ)<3 by norm_num)]
  have hbase0:0≤(a*(b+1)+46)*(1+Real.log S) := by positivity
  have hr2:(r:ℝ)+1≤2*S := by linarith
  have hlogbase':Real.log ((M:ℝ)*((B:ℝ)+1)+1)≤(a*(b+1)+46)*(1+Real.log S) := by
    norm_num at hlogbase
    nlinarith
  have hmulbase:((r:ℝ)+1)*Real.log ((M:ℝ)*((B:ℝ)+1)+1)≤
      2*S*((a*(b+1)+46)*(1+Real.log S)) := by
    exact (mul_le_mul_of_nonneg_left hlogbase' (by positivity)).trans
      (mul_le_mul_of_nonneg_right hr2 hbase0)
  have hother:(b+c+33)*(1+Real.log S)≤(b+c+33)*S*(1+Real.log S) := by
    have hm:=mul_le_mul_of_nonneg_left hS (show 0≤(b+c+33)*(1+Real.log S) by positivity)
    nlinarith
  have hf:improvedGridLogFactor d M r B R≤
      (b+c+33+2*(a*(b+1)+46))*S*(1+Real.log S) := by
    unfold improvedGridLogFactor
    norm_num at hlogB hlogR hlogd
    nlinarith
  have hp:=resource_parameter_count ha hS hd hr hM
  have hf0:0≤(b+c+33+2*(a*(b+1)+46))*S*(1+Real.log S) := by positivity
  have hh:=mul_le_mul_of_nonneg_right hp hf0
  have hh':=(mul_le_mul_of_nonneg_left hf
    (Nat.cast_nonneg (robustParameterCount d M r))).trans hh
  unfold improvedGridEntropy improvedGridBudgetCoefficient
  exact hh'.trans_eq (by ring)

theorem improvedGridEntropy_resource_polynomial {d M r B R:ℕ} {a b c S:ℝ}
    (ha:1≤a) (hb:1≤b) (hc:1≤c) (hS:1≤S)
    (hd:(d:ℝ)≤S) (hr:(r:ℝ)≤S)
    (hM:(M:ℝ)≤a*S^21) (hB:(B:ℝ)≤b*S^24) (hR:(R:ℝ)≤c*S^3)
    (hBp:0<B) (hRp:0<R):
    improvedGridEntropy d M r B R≤ improvedGridBudgetCoefficient a b c*S^45 := by
  have h:=improvedGridEntropy_resource_budget ha hb hc hS hd hr hM hB hR hBp hRp
  have hl:1+Real.log S≤S := by linarith [Real.log_le_sub_one_of_pos (show 0<S by linarith)]
  have hc0:0≤ improvedGridBudgetCoefficient a b c*S^44 := by
    unfold improvedGridBudgetCoefficient
    positivity
  exact h.trans ((mul_le_mul_of_nonneg_left hl hc0).trans_eq (by ring))

end NeuralGeneralization.ConcreteModel
