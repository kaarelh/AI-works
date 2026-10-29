import ScalarChannelPath

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped NNReal ENNReal
namespace ConditionalNonpolynomial.Analytic

theorem ScalarChannelPath.exists_of_sequence (H : ℕ) (s : ℕ → ℝ×ℝ)
    (Q : ℕ → Measure ℝ) (hpos : ∀ j ≤ H, 0 < (s j).1 ∧ 0 ≤ (s j).2)
    (hprob : ∀ j < H, IsProbabilityMeasure (Q j))
    (hfinite : ∀ j < H, klDiv (Q j) (gaussianReal 0 1) ≠ ∞)
    (hstep : ∀ j < H, s (j+1)=
      (controlledSignal (Q j) (s j).1 (s j).2, controlledResidual (Q j) (s j).1 (s j).2)) :
    ∃ p : ScalarChannelPath (s 0).1 (s 0).2,
      p.length=H ∧ (∀ j ≤ H, p.state j=s j) ∧ (∀ j < H, p.control j=Q j) := by
  induction H generalizing s Q with
  | zero =>
    refine ⟨.stop (hpos 0 le_rfl).1 (hpos 0 le_rfl).2,rfl,?_,?_⟩
    · intro j hj
      have : j=0 := by omega
      subst j
      exact Prod.eta (s 0)
    · intro j hj
      omega
  | succ H ih =>
    have htail := ih (fun j => s (j+1)) (fun j => Q (j+1))
      (fun j hj => hpos (j+1) (by omega))
      (fun j hj => hprob (j+1) (by omega))
      (fun j hj => hfinite (j+1) (by omega))
      (fun j hj => hstep (j+1) (by omega))
    have hzero := hstep 0 (by omega)
    rw [hzero] at htail
    obtain ⟨tail,hlen,hstate,hcontrol⟩ := htail
    refine ⟨.step (hpos 0 (by omega)).1 (hpos 0 (by omega)).2 (Q 0)
      (hprob 0 (by omega)) (hfinite 0 (by omega)) tail,?_,?_,?_⟩
    · change tail.length+1=H+1
      rw [hlen]
    · intro j hj
      cases j with
      | zero => exact Prod.eta (s 0)
      | succ j => exact hstate j (by omega)
    · intro j hj
      cases j with
      | zero => rfl
      | succ j => exact hcontrol j (by omega)

#print axioms ScalarChannelPath.exists_of_sequence
end ConditionalNonpolynomial.Analytic
