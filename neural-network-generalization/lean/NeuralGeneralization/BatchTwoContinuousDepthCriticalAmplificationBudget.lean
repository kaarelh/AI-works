import NeuralGeneralization.BatchTwoContinuousDepthCriticalAmplification
import NeuralGeneralization.BatchTwoContinuousDepthCriticalFreeLayers

/-! Quantified late amplification: logarithmically many constant-cost shifts
recover a signal after any number of free Gaussian cooling layers. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
namespace NeuralGeneralization.BatchTwoContinuousDepthCritical

noncomputable def amplificationGain : ℝ := 2/amplificationConstant
noncomputable def amplificationCount (u:ℝ) : ℕ := ⌈Real.log (1/u)/Real.log 2⌉₊

theorem amplificationConstant_le_half : amplificationConstant≤1/2 := by
  unfold amplificationConstant
  nlinarith [sq_nonneg (Real.tanh 3)]

theorem amplificationGain_pos : 0<amplificationGain := div_pos (by norm_num) amplificationConstant_pos

theorem amplification_threshold {b:ℝ} (hb:0≤b) :
    min (2*b) amplificationConstant=amplificationConstant*min (amplificationGain*b) 1 := by
  have ha:=amplificationConstant_pos
  rw [mul_min_of_nonneg _ _ ha.le,mul_one]
  unfold amplificationGain
  have he : amplificationConstant*(2/amplificationConstant*b)=2*b := by field_simp <;> ring
  rw [he]

theorem amplification_iterate {u:ℝ} (hu:0<u) (b:ℕ→ℝ) (hb0:u≤b 0)
    (hstep:∀s,amplificationConstant*min (amplificationGain*b s) 1≤b (s+1)) :
    ∀s,min ((2:ℝ)^s*u) amplificationConstant≤b s := by
  intro s
  induction s with
  | zero => simp only [pow_zero,one_mul];exact (min_le_left _ _).trans hb0
  | succ s ih =>
    have hpos : 0<min ((2:ℝ)^s*u) amplificationConstant := lt_min (by positivity) amplificationConstant_pos
    have hb : 0≤b s := hpos.le.trans ih
    have hstepS:=hstep s
    rw [←amplification_threshold hb] at hstepS
    have hh : min (2*min ((2:ℝ)^s*u) amplificationConstant) amplificationConstant ≤ min (2*b s) amplificationConstant := min_le_min (mul_le_mul_of_nonneg_left ih (by norm_num : (0:ℝ)≤2)) le_rfl
    have he : min (2*min ((2:ℝ)^s*u) amplificationConstant) amplificationConstant=
        min ((2:ℝ)^(s+1)*u) amplificationConstant := by
      rw [mul_min_of_nonneg _ _ (by norm_num : (0:ℝ)≤2),pow_succ]
      have ha : amplificationConstant≤2*amplificationConstant := by linarith [amplificationConstant_pos]
      rw [min_assoc,min_eq_right ha]
      congr 1
      ring
    rw [he] at hh
    exact hh.trans hstepS

theorem amplificationCount_power {u:ℝ} (hu:0<u) (hu1:u≤1) :
    1≤(2:ℝ)^(amplificationCount u)*u := by
  have hlog2:0<Real.log 2 := Real.log_pos (by norm_num)
  have hceil:=Nat.le_ceil (Real.log (1/u)/Real.log 2)
  have hh := (div_le_iff₀ hlog2).mp hceil
  have he := Real.exp_le_exp.mpr hh
  rw [Real.exp_log (one_div_pos.mpr hu)] at he
  have hid : Real.exp ((amplificationCount u:ℝ)*Real.log 2)=(2:ℝ)^amplificationCount u := by
    rw [Real.exp_nat_mul,Real.exp_log (by norm_num : (0:ℝ)<2)]
  change 1/u≤Real.exp ((amplificationCount u:ℝ)*Real.log 2) at he
  rw [hid] at he
  exact (div_le_iff₀ hu).mp he

theorem amplificationCount_bound {u:ℝ} (hu:0<u) (hu1:u≤1) :
    (amplificationCount u:ℝ)≤Real.log (1/u)/Real.log 2+1 := by
  have hlog : 0≤Real.log (1/u) := Real.log_nonneg ((one_le_div hu).mpr hu1)
  exact (Nat.ceil_lt_add_one (div_nonneg hlog (Real.log_pos (by norm_num)).le)).le

theorem amplification_reaches_constant {u:ℝ} (hu:0<u) (hu1:u≤1)
    (b:ℕ→ℝ) (hb0:u≤b 0)
    (hstep:∀s,amplificationConstant*min (amplificationGain*b s) 1≤b (s+1)) :
    amplificationConstant≤b (amplificationCount u) := by
  have hh:=amplification_iterate hu b hb0 hstep (amplificationCount u)
  have ha:=amplificationConstant_le_half
  have hp:=amplificationCount_power hu hu1
  rwa [min_eq_right (by linarith)] at hh

end NeuralGeneralization.BatchTwoContinuousDepthCritical
