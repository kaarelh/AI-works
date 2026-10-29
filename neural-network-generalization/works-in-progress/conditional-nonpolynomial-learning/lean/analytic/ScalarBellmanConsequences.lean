import ScalarBaselineBridge

noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal
namespace ConditionalNonpolynomial.Analytic

/-- Bellman lower bound remains valid if the next variance is smaller than the
controlled second moment, and if the Gaussian input variance is contracted.
This is useful when the maximizing query changes between layers. -/
theorem scalarValue_controlled_step {a q r : ℝ} (hq : 0<q) (hr : 0<r)
    (ha : 0≤a) (haq : a≤q) (Q : Measure ℝ) (hprob : IsProbabilityMeasure Q)
    (hfinite : klDiv Q (gaussianReal 0 1)≠∞)
    (hrnext : r≤scalarTransition a Q) :
    scalarValue q≤(klDiv Q (gaussianReal 0 1)).toReal+scalarValue r := by
  letI := hprob
  have hrnext' := hrnext.trans (scalarTransition_mono Q ha haq)
  have hn := hr.trans_le hrnext'
  have hb := scalarValue_bellman hq Q hprob hfinite hn
  have hm := scalarValue_antitone hr hrnext'
  linarith

/-- Any finitely many genuine controlled scalar steps plus a valid final
readout dominate V of the initial state, even with smaller next variances. -/
theorem scalarValue_controlled_suffix (m : ℕ) (q a : ℕ → ℝ) (Q : ℕ → Measure ℝ)
    (hq : ∀j≤m,0<q j) (ha : ∀j<m,0≤a j) (haq : ∀j<m,a j≤q j)
    (hprob : ∀j<m,IsProbabilityMeasure (Q j))
    (hfinite : ∀j<m,klDiv (Q j) (gaussianReal 0 1)≠∞)
    (htrans : ∀j<m,q (j+1)≤scalarTransition (a j) (Q j)) :
    scalarValue (q 0)≤
      (∑j ∈ Finset.range m,(klDiv (Q j) (gaussianReal 0 1)).toReal)+1/(8*q m) := by
  have hprefix : scalarValue (q 0)≤
      (∑j ∈ Finset.range m,(klDiv (Q j) (gaussianReal 0 1)).toReal)+scalarValue (q m) := by
    induction m with
    | zero => simp
    | succ m ih =>
      have hi := ih (fun j hj => hq j (Nat.le_succ_of_le hj))
        (fun j hj => ha j (Nat.lt_succ_of_lt hj))
        (fun j hj => haq j (Nat.lt_succ_of_lt hj))
        (fun j hj => hprob j (Nat.lt_succ_of_lt hj))
        (fun j hj => hfinite j (Nat.lt_succ_of_lt hj))
        (fun j hj => htrans j (Nat.lt_succ_of_lt hj))
      have hs := scalarValue_controlled_step (hq m (Nat.le_succ m)) (hq (m+1) le_rfl)
        (ha m (Nat.lt_succ_self m)) (haq m (Nat.lt_succ_self m)) (Q m)
        (hprob m (Nat.lt_succ_self m)) (hfinite m (Nat.lt_succ_self m))
        (htrans m (Nat.lt_succ_self m))
      rw [Finset.sum_range_succ]
      linarith
  have hr := scalarValue_le_readout (hq m le_rfl)
  linarith

/-- The proved linear bridge identifies V* as the right-hand zero-variance
limit, stated in epsilon form to expose an explicit convergence modulus. -/
theorem scalarValue_limit_modulus {ε q : ℝ} (hε : 0<ε) (hq : 0<q)
    (hsmall : q<ε/526336) : |scalarValue q-scalarBaseline.toReal|<ε := by
  have hb := scalarBaseline_global_bridge hq
  rw [abs_of_nonpos (by linarith [hb.1])]
  have hh := (lt_div_iff₀ (by norm_num : (0:ℝ)<526336)).mp hsmall
  linarith

#print axioms scalarValue_controlled_suffix
#print axioms scalarValue_limit_modulus
end ConditionalNonpolynomial.Analytic
