import ScalarGaussianControls
import ScalarChannelSequence
import SteeringFreeCooling
import SteeringHoldingIteration
import SteeringGrowthIteration
import SteeringScoreAdapter

/-! The actual cooling, holding and growth recursions packaged as finite
Gaussian-controlled scalar paths with their concrete costs and states. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped NNReal ENNReal BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem exists_freeCooling_gaussian_path {v r : ℝ} (hv : 0 < v) (hr : 0 ≤ r)
    (hqr : v+r ≤ 1) (H : ℕ) :
    ∃ p : ScalarChannelPath v r, p.length=H ∧ p.hiddenCost=0 ∧ p.GaussianControls ∧
      (∀ j ≤ H, p.state j=freeCoolingState v r j) := by
  have hpos (j : ℕ) (_hj : j ≤ H) :
      0 < (freeCoolingState v r j).1 ∧ 0 ≤ (freeCoolingState v r j).2 := by
    refine ⟨?_,(freeCoolingState_nonneg hv.le hr j).2⟩
    exact lt_of_lt_of_le (mul_pos hv (Real.exp_pos _))
      (freeCoolingState_signal_exp_lower hv.le hr hqr j)
  obtain ⟨p,hlen,hstate,hcontrol⟩ := ScalarChannelPath.exists_of_sequence H
    (freeCoolingState v r) (fun _ => gaussianReal 0 1) hpos
    (fun _ _ => inferInstance) (fun _ _ => by simp) (fun _ _ => rfl)
  refine ⟨p,hlen,?_,?_,hstate⟩
  · rw [p.hiddenCost_eq_sum,hlen]
    apply Finset.sum_eq_zero
    intro j hj
    rw [hcontrol j (Finset.mem_range.mp hj)]
    simp
  · intro j hj
    rw [hlen] at hj
    refine ⟨0,le_rfl,?_⟩
    rw [hcontrol j hj]
    simp [steeringControl]

theorem exists_holding_gaussian_path {v r : ℝ} (hv : 0 < v) (hr : 0 ≤ r)
    (hq : v+r ≤ 1/128) (H : ℕ) :
    ∃ p : ScalarChannelPath v r, p.length=H ∧
      p.hiddenCost ≤ 64*(H : ℝ)*(v+r)^2 ∧ p.GaussianControls ∧
      (∀ j ≤ H, p.state j=(v,holdingResidual v r j)) := by
  let s := fun j => (v,holdingResidual v r j)
  let Q := fun j => steeringControl (holdingInflation v r j)
  have hpos (j : ℕ) (_hj : j ≤ H) : 0 < (s j).1 ∧ 0 ≤ (s j).2 :=
    ⟨hv,(holdingResidual_bounds hv.le hr hq j).1⟩
  have hstep (j : ℕ) (_hj : j < H) :
      s (j+1)=(controlledSignal (Q j) (s j).1 (s j).2,
        controlledResidual (Q j) (s j).1 (s j).2) := by
    have hs := holdingInflation_step hv.le hr hq j
    dsimp only [s,Q]
    rw [controlledSignal_steeringControl hs.1 hv.le,
      controlledResidual_steeringControl hs.1 hv.le,hs.2.2.1]
    rfl
  obtain ⟨p,hlen,hstate,hcontrol⟩ := ScalarChannelPath.exists_of_sequence H s Q hpos
    (fun _ _ => inferInstance) (fun j _ => (holdingInflation_step hv.le hr hq j).2.2.2.1) hstep
  refine ⟨p,hlen,?_,?_,hstate⟩
  · rw [p.hiddenCost_eq_sum,hlen]
    have he : (∑ j ∈ Finset.range H,(klDiv (p.control j) (gaussianReal 0 1)).toReal)=
        ∑ j ∈ Finset.range H,(klDiv (steeringControl (holdingInflation v r j)) (gaussianReal 0 1)).toReal := by
      apply Finset.sum_congr rfl
      intro j hj
      rw [hcontrol j (Finset.mem_range.mp hj)]
    rw [he]
    exact holding_total_cost hv.le hr hq H
  · intro j hj
    rw [hlen] at hj
    refine ⟨holdingInflation v r j,(holdingInflation_step hv.le hr hq j).1,?_⟩
    exact hcontrol j hj

theorem exists_growth_gaussian_path {p v r : ℝ} (hv : 0 < v) (hvp : v ≤ p)
    (hr : 0 ≤ r) (hrp : r ≤ p) (hp : p ≤ 1/256) (H : ℕ) :
    ∃ a : ScalarChannelPath v r, a.length=H ∧ a.hiddenCost ≤ 256*(H : ℝ)*p^2 ∧ a.GaussianControls ∧
      (∀ j ≤ H, a.state j=(growthSchedule p v j,growthResidual p v r j)) := by
  let s := fun j => (growthSchedule p v j,growthResidual p v r j)
  let Q := fun j => steeringControl (growthInflation p v r j)
  have hpos (j : ℕ) (_hj : j ≤ H) : 0 < (s j).1 ∧ 0 ≤ (s j).2 :=
    ⟨hv.trans_le (growthSchedule_bounds hv.le hvp j).1,
      (growthResidual_bounds hv.le hvp hr hrp hp j).1⟩
  have hstep (j : ℕ) (_hj : j < H) :
      s (j+1)=(controlledSignal (Q j) (s j).1 (s j).2,
        controlledResidual (Q j) (s j).1 (s j).2) := by
    have hs := growthInflation_step hv.le hvp hr hrp hp j
    have hjpos := (hpos j (by omega)).1.le
    dsimp only [s,Q]
    rw [controlledSignal_steeringControl hs.1 hjpos,
      controlledResidual_steeringControl hs.1 hjpos,hs.2.2.1]
    rfl
  have hseq := ScalarChannelPath.exists_of_sequence H s Q hpos
    (fun _ _ => inferInstance) (fun j _ => (growthInflation_step hv.le hvp hr hrp hp j).2.2.2.1) hstep
  change ∃ a : ScalarChannelPath (growthSchedule p v 0) r,
    a.length=H ∧ (∀ j ≤ H,a.state j=s j) ∧ (∀ j < H,a.control j=Q j) at hseq
  rw [growthSchedule_zero hvp] at hseq
  obtain ⟨a,hlen,hstate,hcontrol⟩ := hseq
  refine ⟨a,hlen,?_,?_,hstate⟩
  · rw [a.hiddenCost_eq_sum,hlen]
    have he : (∑ j ∈ Finset.range H,(klDiv (a.control j) (gaussianReal 0 1)).toReal)=
        ∑ j ∈ Finset.range H,(klDiv (steeringControl (growthInflation p v r j)) (gaussianReal 0 1)).toReal := by
      apply Finset.sum_congr rfl
      intro j hj
      rw [hcontrol j (Finset.mem_range.mp hj)]
    rw [he]
    exact growth_total_cost hv.le hvp hr hrp hp H
  · intro j hj
    rw [hlen] at hj
    refine ⟨growthInflation p v r j,(growthInflation_step hv.le hvp hr hrp hp j).1,?_⟩
    exact hcontrol j hj

#print axioms exists_growth_gaussian_path
end ConditionalNonpolynomial.Analytic
