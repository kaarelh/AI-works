import NeuralGeneralization.RobustModel
import Mathlib.Tactic.Ring

/-!
# Exact postactivation injections for a virtual computational path

These identities are deterministic. They neither assume nor assert that a
probabilistic compressed path exists. Once such a path has been constructed,
its discrepancies are disturbances of the original network, without any
product of downstream matrix norms.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

theorem fold_finRange_of_path {β : Type*} (n : ℕ)
    (F : β → Fin n → β) (v : Fin (n + 1) → β)
    (hstep : ∀ s, F (v s.castSucc) s = v s.succ) :
    (List.finRange n).foldl F (v 0) = v (Fin.last n) := by
  induction n with
  | zero => simp
  | succ n ih =>
    rw [List.finRange_succ_last, List.foldl_append, List.foldl_cons,
      List.foldl_nil, List.foldl_map]
    have hp := ih (fun b s => F b s.castSucc) (fun s => v s.castSucc) (by
      intro s
      simpa using hstep s.castSucc)
    simp only [Fin.castSucc_zero] at hp
    rw [hp]
    simpa using hstep (Fin.last n)

/-- The unique coordinatewise discrepancies making the original network
follow a prescribed sequence of hidden vectors and a prescribed output. -/
def pathDisturbance {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) (h : Fin (r + 1) → Fin N → ℝ) (z : ℝ) :
    NetworkDisturbance N r :=
  (Fin.cases
    (fun i => h 0 i - firstHidden φ w x i)
    (fun s i => h s.succ i - hiddenStep φ w (h s.castSucc) s i),
   z - ∑ i, w (Sum.inr (Sum.inr i)) * h (Fin.last r) i)

@[simp] theorem pathDisturbance_first {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d)
    (h : Fin (r + 1) → Fin N → ℝ) (z : ℝ) :
    noisyFirstHidden φ w x (pathDisturbance φ w x h z) = h 0 := by
  funext i
  simp [noisyFirstHidden, pathDisturbance]

@[simp] theorem pathDisturbance_step {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d)
    (h : Fin (r + 1) → Fin N → ℝ) (z : ℝ) (s : Fin r) :
    noisyHiddenStep φ w (pathDisturbance φ w x h z) (h s.castSucc) s =
      h s.succ := by
  funext i
  simp [noisyHiddenStep, pathDisturbance]

@[simp] theorem pathDisturbance_final {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d)
    (h : Fin (r + 1) → Fin N → ℝ) (z : ℝ) :
    noisyFinalHidden φ w x (pathDisturbance φ w x h z) = h (Fin.last r) := by
  unfold noisyFinalHidden
  rw [pathDisturbance_first]
  exact fold_finRange_of_path r _ h (pathDisturbance_step φ w x h z)

/-- The virtual output is exactly the original network under the constructed
postactivation disturbances, with no stability premise. -/
@[simp] theorem pathDisturbance_output {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d)
    (h : Fin (r + 1) → Fin N → ℝ) (z : ℝ) :
    noisyNetworkOutput φ w x (pathDisturbance φ w x h z) = z := by
  unfold noisyNetworkOutput
  rw [pathDisturbance_final]
  simp [pathDisturbance]

/-- The disturbance budget is the sum of local squared errors, with no
downstream amplification factors. -/
theorem pathDisturbance_budget {d N r : ℕ} (φ : ℝ → ℝ)
    (w : Weights d N r) (x : Cube d)
    (h : Fin (r + 1) → Fin N → ℝ) (z : ℝ) :
    noiseBudgetSq (pathDisturbance φ w x h z) =
      ((∑ i, (h 0 i - firstHidden φ w x i) ^ 2) +
        ∑ s : Fin r, ∑ i,
          (h s.succ i - hiddenStep φ w (h s.castSucc) s i) ^ 2) / (N : ℝ) +
      (z - ∑ i, w (Sum.inr (Sum.inr i)) * h (Fin.last r) i) ^ 2 := by
  simp [noiseBudgetSq, pathDisturbance, Fin.sum_univ_succ]

/-- Local discrepancies satisfying the actual calibrated budget inherit
the original network's clipped-score stability. -/
theorem clipped_path_of_robust {d N r : ℕ} (φ : ℝ → ℝ) (c : ℝ)
    (w : Weights d N r) (hw : w ∈ robustEvent φ c) (x : Cube d)
    (h : Fin (r + 1) → Fin N → ℝ) (z : ℝ)
    (hb : noiseBudgetSq (pathDisturbance φ w x h z) ≤ (robustRadius c w)^2) :
    |clippedScore z - clippedScore (networkOutput φ w x)| ≤ (1 / 16 : ℝ) := by
  simpa using hw x (pathDisturbance φ w x h z) hb

end NeuralGeneralization.ConcreteModel
