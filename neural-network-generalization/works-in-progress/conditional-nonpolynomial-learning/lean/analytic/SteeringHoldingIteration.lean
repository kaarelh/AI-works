import SteeringExactSteps

/-! Arbitrarily long exact holding and quantitative purification, using the
actual Gaussian variance controls selected by the intermediate value theorem. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped NNReal ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

def holdingChoice (v r : ℝ) : ℝ :=
  if h : 0 ≤ v ∧ 0 ≤ r ∧ v+r ≤ 1/128 then
    Classical.choose (exact_holding_step h.1 h.2.1 h.2.2) else 0

theorem holdingChoice_spec {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r) (hq : v+r ≤ 1/128) :
    0 ≤ holdingChoice v r ∧ holdingChoice v r ≤ 16*(v+r) ∧
      steeringSignal ((1+holdingChoice v r)*v) r = v ∧
      0 ≤ steeringResidual ((1+holdingChoice v r)*v) r ∧
      steeringResidual ((1+holdingChoice v r)*v) r ≤ r ∧
      klDiv (steeringControl (holdingChoice v r)) (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv (steeringControl (holdingChoice v r)) (gaussianReal 0 1)).toReal ≤ 64*(v+r)^2 := by
  unfold holdingChoice
  rw [dif_pos ⟨hv,hr,hq⟩]
  exact Classical.choose_spec (exact_holding_step hv hr hq)

def holdingResidual (v r : ℝ) : ℕ → ℝ
  | 0 => r
  | n+1 => steeringResidual ((1+holdingChoice v (holdingResidual v r n))*v)
      (holdingResidual v r n)

def holdingInflation (v r : ℝ) (n : ℕ) : ℝ := holdingChoice v (holdingResidual v r n)

theorem holdingResidual_bounds {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) (n : ℕ) : 0 ≤ holdingResidual v r n ∧ holdingResidual v r n ≤ r := by
  induction n with
  | zero => exact ⟨hr,le_rfl⟩
  | succ n ih =>
    have hs := holdingChoice_spec hv ih.1 (by linarith : v+holdingResidual v r n ≤ 1/128)
    exact ⟨hs.2.2.2.1,hs.2.2.2.2.1.trans ih.2⟩

theorem holdingInflation_step {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) (n : ℕ) :
    0 ≤ holdingInflation v r n ∧ holdingInflation v r n ≤ 16*(v+r) ∧
      steeringSignal ((1+holdingInflation v r n)*v) (holdingResidual v r n) = v ∧
      klDiv (steeringControl (holdingInflation v r n)) (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv (steeringControl (holdingInflation v r n)) (gaussianReal 0 1)).toReal ≤ 64*(v+r)^2 := by
  have hb := holdingResidual_bounds hv hr hq n
  have hs := holdingChoice_spec hv hb.1 (by linarith : v+holdingResidual v r n ≤ 1/128)
  refine ⟨hs.1,hs.2.1.trans (by linarith),hs.2.2.1,hs.2.2.2.2.2.1,?_⟩
  apply hs.2.2.2.2.2.2.trans
  have hh := pow_le_pow_left₀ (add_nonneg hv hb.1) (show v+holdingResidual v r n ≤ v+r by linarith) 2
  nlinarith

theorem holding_total_cost {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) (H : ℕ) :
    (∑ n ∈ Finset.range H,
      (klDiv (steeringControl (holdingInflation v r n)) (gaussianReal 0 1)).toReal) ≤
      64*(H : ℝ)*(v+r)^2 := by
  have hh := Finset.sum_le_sum (s := Finset.range H)
    (fun n _ => (holdingInflation_step hv hr hq n).2.2.2.2)
  simpa only [Finset.sum_const,Finset.card_range,nsmul_eq_mul,mul_assoc,mul_left_comm] using hh

theorem purificationRate_le : purificationRate ≤ 1/32 := by
  have ha : purificationNoiseMass ≤ 1 := measureReal_le_one
  have hb : purificationSignalMass ≤ 1 := measureReal_le_one
  have h := mul_le_mul ha hb purificationSignalMass_pos.le (by norm_num : (0 : ℝ) ≤ 1)
  unfold purificationRate
  nlinarith

theorem holdingResidual_purifies {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hrv : r ≤ v) (hq : v+r ≤ 1/128) (n : ℕ) :
    holdingResidual v r n ≤ (1-purificationRate*v)^n*r := by
  have hfac : 0 ≤ 1-purificationRate*v := by
    have hprod := mul_le_mul_of_nonneg_right purificationRate_le hv
    linarith
  induction n with
  | zero => simp [holdingResidual]
  | succ n ih =>
    have hb := holdingResidual_bounds hv hr hq n
    have hs := holdingInflation_step hv hr hq n
    have hstep := steeringResidual_strict hb.1 (hb.2.trans hrv)
      (show v ≤ (1+holdingInflation v r n)*v by nlinarith [mul_nonneg hs.1 hv])
      (show v ≤ 1/2 by linarith)
    change holdingResidual v r (n+1) ≤ _ at hstep
    have hm := mul_le_mul_of_nonneg_left ih hfac
    rw [pow_succ]
    nlinarith only [hstep,hm]

theorem holdingResidual_exp_bound {v r : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hrv : r ≤ v) (hq : v+r ≤ 1/128) (n : ℕ) :
    holdingResidual v r n ≤ Real.exp (-purificationRate*v*(n : ℝ))*r := by
  apply (holdingResidual_purifies hv hr hrv hq n).trans
  have hfac : 0 ≤ 1-purificationRate*v := by
    have hprod := mul_le_mul_of_nonneg_right purificationRate_le hv
    linarith
  have hh := pow_le_pow_left₀ hfac (Real.one_sub_le_exp_neg (purificationRate*v)) n
  have hm := mul_le_mul_of_nonneg_right hh hr
  rw [← Real.exp_nat_mul] at hm
  convert hm using 1 <;> congr 2 <;> ring

#print axioms holdingResidual_exp_bound
#print axioms holding_total_cost
end ConditionalNonpolynomial.Analytic
