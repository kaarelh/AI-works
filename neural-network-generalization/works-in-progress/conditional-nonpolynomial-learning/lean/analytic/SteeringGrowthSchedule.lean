import SteeringBudget

noncomputable section
set_option backward.isDefEq.respectTransparency false
namespace ConditionalNonpolynomial.Analytic

def growthSchedule (p v : ℝ) (n : ℕ) : ℝ := min p ((1+2*p)^n*v)

theorem growthSchedule_bounds {p v : ℝ} (hv : 0 ≤ v) (hvp : v ≤ p) (n : ℕ) :
    v ≤ growthSchedule p v n ∧ growthSchedule p v n ≤ p := by
  have hp : 0 ≤ p := hv.trans hvp
  have hpow : (1 : ℝ) ≤ (1+2*p)^n := one_le_pow₀ (by linarith)
  refine ⟨le_min hvp ?_,min_le_left _ _⟩
  nlinarith [mul_le_mul_of_nonneg_right hpow hv]

theorem growthSchedule_zero {p v : ℝ} (hvp : v ≤ p) : growthSchedule p v 0 = v := by
  simp only [growthSchedule,pow_zero,one_mul,min_eq_right hvp]

theorem growthSchedule_recursion {p v : ℝ} (hv : 0 ≤ v) (hvp : v ≤ p) (n : ℕ) :
    growthSchedule p v (n+1) = min p ((1+2*p)*growthSchedule p v n) := by
  have hp : 0 ≤ p := hv.trans hvp
  have hfac : 1 ≤ 1+2*p := by linarith
  have hbase : 0 ≤ (1+2*p)^n*v := by positivity
  unfold growthSchedule
  rw [pow_succ]
  have he : (1+2*p)^n*(1+2*p)*v=(1+2*p)*((1+2*p)^n*v) := by ring
  rw [he]
  by_cases hle : (1+2*p)^n*v ≤ p
  · rw [min_eq_right hle]
  · have hrev := le_of_not_ge hle
    have hmul := mul_le_mul_of_nonneg_left hrev (by linarith : 0 ≤ 1+2*p)
    have hpp : p ≤ (1+2*p)*p := by nlinarith [sq_nonneg p]
    rw [min_eq_left hrev,min_eq_left hpp,min_eq_left (hpp.trans hmul)]

theorem growthSchedule_step {p v : ℝ} (hv : 0 ≤ v) (hvp : v ≤ p) (n : ℕ) :
    growthSchedule p v n ≤ growthSchedule p v (n+1) ∧
      growthSchedule p v (n+1) ≤ growthSchedule p v n*(1+4*(growthSchedule p v n+p)) := by
  have hb := growthSchedule_bounds hv hvp n
  have hp : 0 ≤ p := hv.trans hvp
  have hx : 0 ≤ growthSchedule p v n := hv.trans hb.1
  rw [growthSchedule_recursion hv hvp]
  constructor
  · apply le_min hb.2
    nlinarith [mul_nonneg hp hx]
  · apply (min_le_right _ _).trans
    have hh : 1+2*p ≤ 1+4*(growthSchedule p v n+p) := by linarith
    have hm := mul_le_mul_of_nonneg_left hh hx
    nlinarith only [hm]

theorem growth_log_gain {p : ℝ} (hp : 0 ≤ p) (hp1 : p ≤ 1) :
    p ≤ Real.log (1+2*p) := by
  have hh := Real.le_log_one_add_of_nonneg (show 0 ≤ 2*p by positivity)
  have hden : 0 < 2*p+2 := by positivity
  have hlow : p ≤ 2*(2*p)/(2*p+2) := by
    apply (le_div_iff₀ hden).mpr
    nlinarith [mul_nonneg hp (sub_nonneg.mpr hp1)]
  exact hlow.trans hh

theorem growthSchedule_reaches {p v : ℝ} (hv : 0 < v) (hvp : v ≤ p)
    (hp1 : p ≤ 1) (H : ℕ) (hbudget : Real.log (p/v) ≤ (H : ℝ)*p) :
    growthSchedule p v H = p := by
  have hp : 0 < p := hv.trans_le hvp
  have hg := growth_log_gain hp.le hp1
  have hlog : Real.log (p/v) ≤ (H : ℝ)*Real.log (1+2*p) :=
    hbudget.trans (mul_le_mul_of_nonneg_left hg (Nat.cast_nonneg H))
  have hexp := Real.exp_le_exp.mpr hlog
  rw [Real.exp_log (div_pos hp hv),Real.exp_nat_mul,Real.exp_log (by positivity : 0<1+2*p)] at hexp
  have hm := mul_le_mul_of_nonneg_right hexp hv.le
  rw [div_mul_cancel₀ p hv.ne'] at hm
  exact min_eq_left hm

#print axioms growthSchedule_reaches
end ConditionalNonpolynomial.Analytic
