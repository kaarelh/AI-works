import TargetPolynomialFloor
import CriticalMemorizerSeed
import ScalarChannelOccupation

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
namespace ConditionalNonpolynomial.Analytic

/-- All target steering overhead is logarithmic in the size parameter; no
unproved channel-existence hypothesis remains. -/
theorem exists_polynomial_nearbaseline_channel {v r R : ℝ}
    (hv : 0<v) (hr : 0≤r) (hq : v+r≤1) (hR : 2≤R)
    (hvR : 1/R^23≤v) (H : ℕ) (hHR : (H:ℝ)+1≤R)
    (hH : 6656*targetProgramConstant*Real.log R≤(H:ℝ)) :
    ∃ P : ScalarChannelPath v r,
      P.length=H ∧
      P.cost≤scalarBaseline.toReal+
        692224*targetProgramConstant^2*(Real.log R)^2/(H:ℝ) ∧
      P.SignalFloor (Real.exp (-targetSignalExponent*Real.log R)) ∧
      P.terminal.1≤1 ∧
      (∀ j z,|P.score j z|≤Real.exp (targetSignalExponent*Real.log R)) := by
  have hv1 : v≤1 := by linarith
  have hT := signal_lower_log_budget hv hR hvR H hHR
  have hT0 : 0≤targetLogBudget v H := (by linarith [targetLogBudget_ge_one hv hv1 H])
  have hA := targetProgramConstant_ge
  have hH0 : 0<(H:ℝ) := lt_of_lt_of_le (by nlinarith [logarithm_half_le hR]) hH
  have hbudget : 256*targetProgramConstant*targetLogBudget v H≤(H:ℝ) := by
    have hm := mul_le_mul_of_nonneg_left hT (show 0≤256*targetProgramConstant by positivity)
    nlinarith
  obtain ⟨P,hlen,hcost,hfloor⟩ := exists_exact_nearbaseline_channel hv hr hq H hbudget
  have hfloor' : P.SignalFloor (Real.exp (-targetSignalExponent*Real.log R)) := by
    intro j hj
    exact (cooledSeedFloor_polynomial hv hR hvR H hHR).trans (hfloor j hj)
  refine ⟨P,hlen,?_,hfloor',?_,fun j z=>polynomialFloor_score_bound hR P hfloor' j z⟩
  · have hs := pow_le_pow_left₀ hT0 hT 2
    have hm := mul_le_mul_of_nonneg_left hs
      (show 0≤1024*targetProgramConstant^2 by positivity)
    have hd := div_le_div_of_nonneg_right hm hH0.le
    have he : 1024*targetProgramConstant^2*(26*Real.log R)^2/(H:ℝ)=
        692224*targetProgramConstant^2*(Real.log R)^2/(H:ℝ) := by ring
    rw [he] at hd
    linarith
  · have hh := P.totalState_le_one hq P.length
    have hr' := (P.state_pos P.length).2
    unfold ScalarChannelPath.totalState at hh
    rw [P.state_terminal] at hh hr'
    linarith

theorem inverse_sqrt_polynomialFloor_le {R : ℝ} (hR : 2≤R) :
    1/Real.sqrt (Real.exp (-targetSignalExponent*Real.log R))≤
      Real.exp (targetSignalExponent*Real.log R) := by
  let β := Real.exp (-targetSignalExponent*Real.log R)
  have hβ : 0<β := Real.exp_pos _
  have hD : 0≤targetSignalExponent*Real.log R :=
    mul_nonneg targetSignalExponent_pos.le (by linarith [logarithm_half_le hR])
  have hβ1 : β≤1 := Real.exp_le_one_iff.mpr (by nlinarith)
  have hs : β≤Real.sqrt β := by
    apply (sq_le_sq₀ hβ.le (Real.sqrt_nonneg _)).mp
    rw [Real.sq_sqrt hβ.le]
    nlinarith
  have hh := one_div_le_one_div_of_le hβ hs
  have he : 1/β=Real.exp (targetSignalExponent*Real.log R) := by
    dsimp [β]
    rw [neg_mul,Real.exp_neg]
    simp
  exact hh.trans_eq he

theorem thirteenth_power_le_targetBound {R : ℝ} (hR : 2≤R) :
    R^13≤Real.exp (targetSignalExponent*Real.log R) := by
  have hR0 : 0<R := by linarith
  have he : R^13=Real.exp ((13:ℝ)*Real.log R) := by
    have hm := Real.exp_nat_mul (Real.log R) 13
    norm_num only [Nat.cast_ofNat] at hm
    rw [hm,Real.exp_log hR0]
  rw [he]
  apply Real.exp_le_exp.mpr
  have hD : (13:ℝ)≤targetSignalExponent := by
    unfold targetSignalExponent
    linarith [targetCoolingLogConstant_pos]
  exact mul_le_mul_of_nonneg_right hD (by linarith [logarithm_half_le hR])

#print axioms exists_polynomial_nearbaseline_channel
end ConditionalNonpolynomial.Analytic
