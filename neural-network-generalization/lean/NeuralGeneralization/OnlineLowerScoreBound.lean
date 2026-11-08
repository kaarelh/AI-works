import NeuralGeneralization.OnlineLowerVariationWitness
import Mathlib.Algebra.Order.BigOperators.Ring.Finset
import Mathlib.Topology.Order.Compact

/-!
# Width-independent output bounds and compact score boxes

For activations with `|φ t| ≤ |t|` (including ReLU and tanh), the complete
Boolean-cube score of a shallow network is bounded by its actual weighted
Gaussian cost. Consequently every bounded-cost family, across all widths,
lies in one finite-dimensional compact score-pair box.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower
open ConcreteModel

theorem inputVector_squared {d : ℕ} (x : Cube d) (j : Fin (d + 1)) :
    inputVector x j ^ 2 = 1 := by
  refine Fin.cases ?_ (fun i => ?_) j
  · simp [inputVector]
  · simp [inputVector, labelReal]

/-- A coarse dimension-uniform bound, using `d ≥ 1` and the constant input. -/
theorem input_dot_abs_le_atom_cost {d : ℕ} (hd : 0 < d)
    (a : Fin (d + 1) → ℝ) (x : Cube d) :
    |∑ j, a j * inputVector x j| ≤ 2 * Real.sqrt (incomingAtomCost a) := by
  have hC := Finset.sum_mul_sq_le_sq_mul_sq Finset.univ a (inputVector x)
  have hx : (∑ j, inputVector x j ^ 2) = (d : ℝ) + 1 := by
    simp [inputVector_squared]
  rw [hx] at hC
  have ha : 0 ≤ ∑ j, a j ^ 2 := Finset.sum_nonneg (fun j _ => sq_nonneg _)
  have hA : 0 ≤ incomingAtomCost a := mul_nonneg (Nat.cast_nonneg _) ha
  have hdR : (1 : ℝ) ≤ d := by exact_mod_cast hd
  have hdim : (∑ j, a j ^ 2) * ((d : ℝ) + 1) ≤ 4 * incomingAtomCost a := by
    unfold incomingAtomCost
    nlinarith
  have hsq := Real.sq_sqrt hA
  have hpos := Real.sqrt_nonneg (incomingAtomCost a)
  have habs := abs_nonneg (∑ j, a j * inputVector x j)
  have habssq := sq_abs (∑ j, a j * inputVector x j)
  nlinarith

/-- Every finite atomic score is bounded by its weighted atomic cost. -/
theorem atomicScore_abs_le_cost {d q : ℕ} (hd : 0 < d)
    (φ : ℝ → ℝ) (hφ : ∀ t, |φ t| ≤ |t|)
    (a : Fin q → Fin (d + 1) → ℝ) (c : Fin q → ℝ) (x : Cube d) :
    |atomicScore φ a c x| ≤ atomicWeightedCost a c := by
  calc
    _ ≤ ∑ j, |c j * φ (∑ k, a j k * inputVector x k)| :=
      Finset.abs_sum_le_sum_abs _ _
    _ ≤ atomicWeightedCost a c := by
      apply Finset.sum_le_sum
      intro j hj
      rw [abs_mul]
      have h := (hφ (∑ k, a j k * inputVector x k)).trans
        (input_dot_abs_le_atom_cost hd (a j) x)
      have hm := mul_le_mul_of_nonneg_left h (abs_nonneg (c j))
      simpa only [mul_assoc, mul_left_comm, mul_comm] using hm

/-- The actual finite network bound, uniform in learner width. -/
theorem networkOutput_abs_le_weightedSquaredNorm {d N : ℕ}
    (hd : 0 < d) (hN : 0 < N) (φ : ℝ → ℝ)
    (hφ : ∀ t, |φ t| ≤ |t|) (w : Weights d N 0) (x : Cube d) :
    |networkOutput φ w x| ≤ weightedSquaredNorm w := by
  rw [networkOutput_eq_atomicScore]
  exact (atomicScore_abs_le_cost hd φ hφ _ _ x).trans
    (atomicWeightedCost_le_weightedSquaredNorm hN w)

/-- A width-independent compact box for cost and all finite-cube outputs. -/
def scorePairBox (d : ℕ) (cap : ℝ) : Set (ℝ × (Cube d → ℝ)) :=
  Set.Icc (0, fun _ => -cap) (cap, fun _ => cap)

theorem isCompact_scorePairBox (d : ℕ) (cap : ℝ) :
    IsCompact (scorePairBox d cap) := isCompact_Icc

/-- Every capped actual network lies in that same compact box. -/
theorem actual_score_pair_mem_box {d N : ℕ} (hd : 0 < d) (hN : 0 < N)
    (φ : ℝ → ℝ) (hφ : ∀ t, |φ t| ≤ |t|)
    (w : Weights d N 0) (cap : ℝ) (hcap : weightedSquaredNorm w ≤ cap) :
    (weightedSquaredNorm w, networkOutput φ w) ∈ scorePairBox d cap := by
  constructor
  · constructor
    · exact weightedSquaredNorm_nonneg w
    · intro x
      exact (neg_le_of_abs_le ((networkOutput_abs_le_weightedSquaredNorm hd hN φ hφ w x).trans hcap))
  · constructor
    · exact hcap
    · intro x
      exact le_of_abs_le ((networkOutput_abs_le_weightedSquaredNorm hd hN φ hφ w x).trans hcap)

end NeuralGeneralization.OnlineLower
