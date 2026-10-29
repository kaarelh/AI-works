import SteeringGrowthSchedule

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped NNReal ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic

def budgetChoice (v r δ w : ℝ) : ℝ :=
  if h : 0 ≤ v ∧ 0 ≤ r ∧ r ≤ δ ∧ v+δ ≤ 1/128 ∧ v ≤ w ∧ w ≤ v*(1+4*(v+δ)) then
    Classical.choose (exact_steering_budget h.1 h.2.1 h.2.2.1 h.2.2.2.1 h.2.2.2.2.1 h.2.2.2.2.2)
  else 0

theorem budgetChoice_spec {v r δ w : ℝ} (hv : 0 ≤ v) (hr : 0 ≤ r)
    (hrδ : r ≤ δ) (hq : v+δ ≤ 1/128) (hvw : v ≤ w)
    (hw : w ≤ v*(1+4*(v+δ))) :
    0 ≤ budgetChoice v r δ w ∧ budgetChoice v r δ w ≤ 16*(v+δ) ∧
      steeringSignal ((1+budgetChoice v r δ w)*v) r = w ∧
      0 ≤ steeringResidual ((1+budgetChoice v r δ w)*v) r ∧
      steeringResidual ((1+budgetChoice v r δ w)*v) r ≤ r ∧
      klDiv (steeringControl (budgetChoice v r δ w)) (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv (steeringControl (budgetChoice v r δ w)) (gaussianReal 0 1)).toReal ≤ 64*(v+δ)^2 := by
  unfold budgetChoice
  rw [dif_pos ⟨hv,hr,hrδ,hq,hvw,hw⟩]
  exact Classical.choose_spec (exact_steering_budget hv hr hrδ hq hvw hw)

def growthResidual (p v r : ℝ) : ℕ → ℝ
  | 0 => r
  | n+1 => steeringResidual
      ((1+budgetChoice (growthSchedule p v n) (growthResidual p v r n)
        p (growthSchedule p v (n+1)))*growthSchedule p v n) (growthResidual p v r n)

def growthInflation (p v r : ℝ) (n : ℕ) : ℝ :=
  budgetChoice (growthSchedule p v n) (growthResidual p v r n) p (growthSchedule p v (n+1))

theorem growthResidual_bounds {p v r : ℝ} (hv : 0 ≤ v) (hvp : v ≤ p)
    (hr : 0 ≤ r) (hrp : r ≤ p) (hp : p ≤ 1/256) (n : ℕ) :
    0 ≤ growthResidual p v r n ∧ growthResidual p v r n ≤ r := by
  induction n with
  | zero => exact ⟨hr,le_rfl⟩
  | succ n ih =>
    have hb := growthSchedule_bounds hv hvp n
    have hstep := growthSchedule_step hv hvp n
    have hs := budgetChoice_spec (hv.trans hb.1) ih.1 (ih.2.trans hrp)
      (by linarith : growthSchedule p v n+p ≤ 1/128) hstep.1 hstep.2
    exact ⟨hs.2.2.2.1,hs.2.2.2.2.1.trans ih.2⟩

theorem growthInflation_step {p v r : ℝ} (hv : 0 ≤ v) (hvp : v ≤ p)
    (hr : 0 ≤ r) (hrp : r ≤ p) (hp : p ≤ 1/256) (n : ℕ) :
    0 ≤ growthInflation p v r n ∧ growthInflation p v r n ≤ 32*p ∧
      steeringSignal ((1+growthInflation p v r n)*growthSchedule p v n)
        (growthResidual p v r n) = growthSchedule p v (n+1) ∧
      klDiv (steeringControl (growthInflation p v r n)) (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv (steeringControl (growthInflation p v r n)) (gaussianReal 0 1)).toReal ≤ 256*p^2 := by
  have hb := growthSchedule_bounds hv hvp n
  have hrb := growthResidual_bounds hv hvp hr hrp hp n
  have hstep := growthSchedule_step hv hvp n
  have hs := budgetChoice_spec (hv.trans hb.1) hrb.1 (hrb.2.trans hrp)
    (by linarith : growthSchedule p v n+p ≤ 1/128) hstep.1 hstep.2
  refine ⟨hs.1,hs.2.1.trans (by linarith),hs.2.2.1,hs.2.2.2.2.2.1,?_⟩
  apply hs.2.2.2.2.2.2.trans
  have hh := pow_le_pow_left₀ (add_nonneg (hv.trans hb.1) (hv.trans hvp))
    (show growthSchedule p v n+p ≤ 2*p by linarith) 2
  nlinarith

theorem growth_total_cost {p v r : ℝ} (hv : 0 ≤ v) (hvp : v ≤ p)
    (hr : 0 ≤ r) (hrp : r ≤ p) (hp : p ≤ 1/256) (H : ℕ) :
    (∑ n ∈ Finset.range H,
      (klDiv (steeringControl (growthInflation p v r n)) (gaussianReal 0 1)).toReal) ≤
      256*(H : ℝ)*p^2 := by
  have hh := Finset.sum_le_sum (s := Finset.range H)
    (fun n _ => (growthInflation_step hv hvp hr hrp hp n).2.2.2.2)
  simpa only [Finset.sum_const,Finset.card_range,nsmul_eq_mul,mul_assoc,mul_left_comm] using hh

#print axioms growthInflation_step
#print axioms growth_total_cost
end ConditionalNonpolynomial.Analytic
