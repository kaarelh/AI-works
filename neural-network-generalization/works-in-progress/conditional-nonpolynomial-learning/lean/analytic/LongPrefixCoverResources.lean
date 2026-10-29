import LongPrefixBudgetBounds

noncomputable section
set_option maxHeartbeats 1000000
namespace ConditionalNonpolynomial.Analytic

theorem longPrefix_radius_small {a T C G K E n L r : ℝ}
    (ha : 0<a) (hT : 1≤T) (hG : 0≤G) (hL : 0≤L)
    (hK : 4*longBlockSpan*(C+G+16)≤K)
    (hE : E≤C*a*T) (hn : K*T/(4*longBlockSpan)≤n)
    (hreadout : L≤Real.exp (G*T))
    (hr : r≤4*Real.exp (E/a-n)) :
    r≤1/(64*(1+L)) := by
  have hc : 0<longBlockSpan := by norm_num [longBlockSpan,longBlockContraction]
  have hT0 : 0≤T := by linarith
  have he : E/a≤C*T := (div_le_iff₀ ha).mpr (by nlinarith only [hE])
  have hk : (C+G+16)*T≤K*T/(4*longBlockSpan) := by
    apply (le_div_iff₀ (by positivity : 0<4*longBlockSpan)).mpr
    have hh := mul_le_mul_of_nonneg_right hK hT0
    nlinarith only [hh]
  have hexp : E/a-n≤ -(G*T)-16*T := by linarith
  have hrad : r≤4*Real.exp (-(G*T)-16*T) :=
    hr.trans (mul_le_mul_of_nonneg_left (Real.exp_le_exp.mpr hexp) (by norm_num))
  have hgexp : 1≤Real.exp (G*T) := Real.one_le_exp (mul_nonneg hG hT0)
  have hden : 1+L≤2*Real.exp (G*T) := by linarith
  have hlog512 : Real.log (512:ℝ)≤9 := by
    have hh := Real.log_le_sub_one_of_pos (by norm_num : (0:ℝ)<2)
    rw [show (512:ℝ)=2^9 by norm_num,Real.log_pow]
    norm_num
    linarith
  have h512 : (512:ℝ)≤Real.exp (16*T) := by
    have hh := Real.exp_le_exp.mpr (show Real.log (512:ℝ)≤16*T by linarith)
    rwa [Real.exp_log (by norm_num : (0:ℝ)<512)] at hh
  have heprod : (4*Real.exp (-(G*T)-16*T))*(64*(2*Real.exp (G*T)))=
      512/Real.exp (16*T) := by
    rw [Real.exp_sub,Real.exp_neg]
    field_simp
    norm_num
  have hprod : r*(64*(1+L))≤1 := by
    calc
      _ ≤ (4*Real.exp (-(G*T)-16*T))*(64*(1+L)) :=
        mul_le_mul_of_nonneg_right hrad (by positivity)
      _ ≤ (4*Real.exp (-(G*T)-16*T))*(64*(2*Real.exp (G*T))) :=
        mul_le_mul_of_nonneg_left (mul_le_mul_of_nonneg_left hden (by norm_num)) (by positivity)
      _ = 512/Real.exp (16*T) := heprod
      _ ≤ 1 := (div_le_one (Real.exp_pos _)).mpr h512
  exact (le_div_iff₀ (by positivity : 0<64*(1+L))).mpr hprod

theorem longPrefix_block_count_upper {a K T : ℝ} {J : ℕ}
    (ha : 0<a) (hJ : (J:ℝ)≤(K+1)*T/a) :
    ((J/⌈longBlockContraction/a⌉₊:ℕ):ℝ)≤(K+1)*T/64 := by
  let b := ⌈longBlockContraction/a⌉₊
  have hc : 0<longBlockContraction := by norm_num [longBlockContraction]
  obtain ⟨hb,hbc,_⟩ := ceiling_block_length ha hc
  have hfit : ((J/b:ℕ):ℝ)*(b:ℝ)≤J := by exact_mod_cast Nat.div_mul_le_self J b
  have h1 := mul_le_mul_of_nonneg_right hfit ha.le
  have h2 := mul_le_mul_of_nonneg_left hbc (show (0:ℝ)≤(J/b:ℕ) by positivity)
  have hj := (le_div_iff₀ ha).mp hJ
  apply (le_div_iff₀ (by norm_num : (0:ℝ)<64)).mpr
  dsimp [b,longBlockContraction] at h1 h2 ⊢
  nlinarith only [h1,h2,hj]

theorem longPrefix_cover_cardinality {a K T : ℝ} {J : ℕ}
    (ha : 0<a) (hJ : (J:ℝ)≤(K+1)*T/a) (M : ℕ) :
    (M:ℝ)^(J/⌈longBlockContraction/a⌉₊)≤
      Real.exp (((K+1)*Real.log ((M:ℝ)+1)/64)*T) := by
  have hn := longPrefix_block_count_upper ha hJ
  have hlog : 0≤Real.log ((M:ℝ)+1) := Real.log_nonneg (by linarith [Nat.cast_nonneg M (α:=ℝ)])
  have hm := mul_le_mul_of_nonneg_right hn hlog
  calc
    _ ≤ ((M:ℝ)+1)^(J/⌈longBlockContraction/a⌉₊) :=
      pow_le_pow_left₀ (by positivity) (by linarith) _
    _ = Real.exp ((J/⌈longBlockContraction/a⌉₊:ℕ)*Real.log ((M:ℝ)+1)) := by
      rw [←Real.log_pow,Real.exp_log (by positivity)]
    _ ≤ _ := Real.exp_le_exp.mpr (by nlinarith only [hm])

#print axioms longPrefix_radius_small
#print axioms longPrefix_cover_cardinality
end ConditionalNonpolynomial.Analytic
