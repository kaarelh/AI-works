import NeuralGeneralization.BatchTwoCircuitConversePrior
import NeuralGeneralization.BatchTwoOnlinePosterior

/-!
# Forward online mistake bound for the actual geometric circuit prior

The countable description PMF is pushed to functions, then conditioned on exact
observed labels. The prior lower bound comes from an actual NAND implementation.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped BigOperators ENNReal
noncomputable section
open Classical

/-- The explicit upper bound in the geometric circuit-prior theorem. -/
def gateBudget (d n : ℕ) : ℝ :=
  (n + 1) * Real.log 2 + 2 * n * Real.log (d + n + 1)

theorem neg_log_circuitMass {d : ℕ} (c : Circuit d) :
    -Real.log (circuitMass c).toReal =
      (c.size + 1) * Real.log 2 + Real.log (Fintype.card (Gates d c.size)) := by
  rw [circuitMass_toReal, Real.log_div, Real.log_pow, Real.log_inv]
  · push_cast
    ring
  · positivity
  · exact_mod_cast (Gates.card_pos d c.size).ne'

theorem neg_log_circuitMass_le_budget {d : ℕ} (c : Circuit d) :
    -Real.log (circuitMass c).toReal ≤ gateBudget d c.size := by
  rw [neg_log_circuitMass]
  have hb : (Fintype.card (Gates d c.size) : ℝ) ≤
      ((d + c.size + 1 : ℕ) : ℝ) ^ (2 * c.size) := by
    exact_mod_cast Gates.card_le d c.size
  have hl := Real.log_le_log
    (by exact_mod_cast Gates.card_pos d c.size : (0 : ℝ) < Fintype.card (Gates d c.size)) hb
  rw [Real.log_pow] at hl
  push_cast at hl
  unfold gateBudget
  linarith

theorem neg_log_functionWeight_le_budget {d : ℕ} (c : Circuit d) :
    -Real.log (functionWeight d c.eval) ≤ gateBudget d c.size := by
  have hl := Real.log_le_log (circuitMass_toReal_pos c) (circuitMass_toReal_le_weight c)
  exact (neg_le_neg hl).trans (neg_log_circuitMass_le_budget c)

/-- Any real NAND circuit fitting the queried support supplies this finite-time
online bound for the exact geometric circuit posterior. -/
theorem geometric_circuit_forward (d : ℕ) (f : Input d → Bool)
    (A : Finset (Input d)) (query : ℕ → {x // x ∈ A})
    (c : Circuit d) (hc : c.Fits f A) (n : ℕ) :
    BatchTwoOnline.cumulativeError (functionWeight d)
      (fun g (x : {x // x ∈ A}) => g x.val = f x.val) query n ≤ gateBudget d c.size := by
  exact (BatchTwoOnline.cumulativeError_le_neg_log
    (functionWeight d) (fun g (x : {x // x ∈ A}) => g x.val = f x.val) query
    (functionWeight_nonneg d) c.eval (fun x => hc x.val x.property)
    (functionWeight_pos c.eval) (le_of_eq (functionWeight_sum d)) n).trans
      (neg_log_functionWeight_le_budget c)

/-- The actual infinite sum of posterior-sampling mistake probabilities is finite
and obeys the same implementation-size bound. Repeated queries cause no issue. -/
theorem geometric_circuit_total_forward (d : ℕ) (f : Input d → Bool)
    (A : Finset (Input d)) (query : ℕ → {x // x ∈ A})
    (c : Circuit d) (hc : c.Fits f A) :
    BatchTwoOnline.totalError (functionWeight d)
      (fun g (x : {x // x ∈ A}) => g x.val = f x.val) query ≤
      ENNReal.ofReal (gateBudget d c.size) := by
  exact (BatchTwoOnline.totalError_le_neg_log
    (functionWeight d) (fun g (x : {x // x ∈ A}) => g x.val = f x.val) query
    (functionWeight_nonneg d) c.eval (fun x => hc x.val x.property)
    (functionWeight_pos c.eval) (le_of_eq (functionWeight_sum d))).trans
      (ENNReal.ofReal_le_ofReal (neg_log_functionWeight_le_budget c))

/-- The gate count can be the minimum over functions matching f on A. -/
theorem geometric_minimum_circuit_total_forward (d : ℕ) (f : Input d → Bool)
    (A : Finset (Input d)) (query : ℕ → {x // x ∈ A}) :
    BatchTwoOnline.totalError (functionWeight d)
      (fun g (x : {x // x ∈ A}) => g x.val = f x.val) query ≤
      ENNReal.ofReal (gateBudget d (complexity f A)) := by
  obtain ⟨c, hsize, hc⟩ := exists_minimizer f A
  simpa only [hsize] using geometric_circuit_total_forward d f A query c hc

end
end NeuralGeneralization.BatchTwoCircuitConverse
