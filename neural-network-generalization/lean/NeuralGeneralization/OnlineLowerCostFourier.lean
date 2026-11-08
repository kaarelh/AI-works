import NeuralGeneralization.OnlineLowerCostEnumerator
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.Fin.Tuple.Basic
import Mathlib.Algebra.BigOperators.Ring.Finset

/-!+# Direct Fourier sum for the weighted path

The recursion here sums over vertex spins, with one factor `1 + a s` for
each loop and `1 + e s s'` for each edge. The syndrome contributes its
Walsh sign. It is therefore the normalized Fourier sum of the column
product. A checked two-state identity identifies it with the independent
edge-choice enumerator used in the ordering theorem.
-/

noncomputable section
open scoped BigOperators

namespace NeuralGeneralization.OnlineLower

/-- Boolean `false` is the positive spin; `true` is the negative spin. -/
def pathSpin (s : Bool) : ℝ := if s then -1 else 1

def pathWalshBit (v s : Bool) : ℝ := if v then pathSpin s else 1

/-- Sum over all spins strictly to the right of the displayed first spin.
Each eliminated spin is averaged with probability one half. -/
def pathSpinMessage (a : ℝ) : List (Bool × ℝ) → Bool → Bool → ℝ
  | [], terminal, s => pathWalshBit terminal s * (1 + a * pathSpin s)
  | (v, e) :: rest, terminal, s =>
      pathWalshBit v s * (1 + a * pathSpin s) *
        ((1 + e * pathSpin s) * pathSpinMessage a rest terminal false +
          (1 - e * pathSpin s) * pathSpinMessage a rest terminal true) / 2

def pathWalshSum (a : ℝ) (data : List (Bool × ℝ)) (terminal : Bool) : ℝ :=
  (pathSpinMessage a data terminal false + pathSpinMessage a data terminal true) / 2

theorem pathSpinMessage_eq (a : ℝ) (data : List (Bool × ℝ)) (terminal : Bool) :
    (pathSpinMessage a data terminal false, pathSpinMessage a data terminal true) =
      hadamardPair (pathEdgeSum a data terminal false, pathEdgeSum a data terminal true) := by
  induction data with
  | nil =>
    cases terminal <;> apply Prod.ext <;>
      dsimp [pathSpinMessage, pathWalshBit, pathSpin, pathEdgeSum, loopFactor,
        hadamardPair] <;> ring
  | cons ve rest ih =>
    obtain ⟨v, e⟩ := ve
    have hi0 := congrArg Prod.fst ih
    have hi1 := congrArg Prod.snd ih
    dsimp [hadamardPair] at hi0 hi1
    rw [pathEdgeSum_step]
    cases v <;> apply Prod.ext <;>
      dsimp [pathSpinMessage, pathWalshBit, pathSpin, rawPathStep, hadamardPair] <;>
      rw [hi0, hi1] <;> ring

theorem pathWalshSum_eq_edgeSum (a : ℝ) (data : List (Bool × ℝ)) (terminal : Bool) :
    pathWalshSum a data terminal = pathEdgeSum a data terminal false := by
  have h := pathSpinMessage_eq a data terminal
  have h0 := congrArg Prod.fst h
  have h1 := congrArg Prod.snd h
  dsimp [hadamardPair] at h0 h1
  unfold pathWalshSum
  rw [h0, h1]
  ring

theorem candidatePathWalsh_lt (x : ℝ) (hx0 : 0 < x) (hx1 : x < 1)
    (endpoint : Bool) {xs ys : List Bool} (hlen : xs.length = ys.length)
    (hlex : digitLexLt xs ys) :
    pathWalshSum (pathLoop x) (pathBlockData x (fixedParityBlocks endpoint xs)) false <
      pathWalshSum (pathLoop x) (pathBlockData x (fixedParityBlocks endpoint ys)) false := by
  simp only [pathWalshSum_eq_edgeSum]
  exact candidatePathEnumerator_lt x hx0 hx1 endpoint hlen hlex

/-- The literal product of loop, edge, and Walsh factors for a fixed first
spin and an arbitrary assignment of all remaining vertex spins. -/
def pathTailWeight (a : ℝ) : (data : List (Bool × ℝ)) →
    Bool → Bool → (Fin data.length → Bool) → ℝ
  | [], terminal, s, _ => pathWalshBit terminal s * (1 + a * pathSpin s)
  | (v, e) :: rest, terminal, s, tail =>
      pathWalshBit v s * (1 + a * pathSpin s) *
        (1 + e * pathSpin s * pathSpin (tail 0)) *
          pathTailWeight a rest terminal (tail 0) (fun i => tail i.succ)

theorem sum_bool_tuple_succ (n : ℕ) (f : (Fin (n + 1) → Bool) → ℝ) :
    (∑ s, f s) =
      (∑ tail : Fin n → Bool, f (Fin.cons false tail)) +
      ∑ tail : Fin n → Bool, f (Fin.cons true tail) := by
  classical
  rw [← (Fin.consEquiv (fun _ : Fin (n + 1) => Bool)).sum_comp f]
  rw [Fintype.sum_prod_type]
  simp [Fin.consEquiv, add_comm]

theorem pathTailWeight_sum (a : ℝ) (data : List (Bool × ℝ))
    (terminal s : Bool) :
    (∑ tail : Fin data.length → Bool, pathTailWeight a data terminal s tail) =
      (2 : ℝ) ^ data.length * pathSpinMessage a data terminal s := by
  classical
  induction data generalizing s with
  | nil => simp [pathTailWeight, pathSpinMessage]
  | cons ve rest ih =>
    obtain ⟨v, e⟩ := ve
    change (∑ tail : Fin (rest.length + 1) → Bool,
      pathTailWeight a ((v, e) :: rest) terminal s tail) = _
    rw [sum_bool_tuple_succ]
    simp only [pathTailWeight, Fin.cons_zero, Fin.cons_succ, pathSpin,
      Bool.false_eq_true, if_false, if_true]
    rw [← Finset.mul_sum, ← Finset.mul_sum, ih, ih]
    simp only [List.length_cons, pathSpinMessage, pow_succ, pathSpin]
    ring

def pathVertexWeight (a : ℝ) (data : List (Bool × ℝ)) (terminal : Bool)
    (spins : Fin (data.length + 1) → Bool) : ℝ :=
  pathTailWeight a data terminal (spins 0) (fun i => spins i.succ)

theorem pathWalshSum_eq_vertex_mean (a : ℝ) (data : List (Bool × ℝ))
    (terminal : Bool) :
    pathWalshSum a data terminal =
      (∑ spins : Fin (data.length + 1) → Bool,
        pathVertexWeight a data terminal spins) / (2 : ℝ) ^ (data.length + 1) := by
  classical
  rw [sum_bool_tuple_succ]
  simp only [pathVertexWeight, Fin.cons_zero, Fin.cons_succ]
  rw [pathTailWeight_sum, pathTailWeight_sum]
  unfold pathWalshSum
  rw [pow_succ]
  have h : (2 : ℝ) ^ data.length ≠ 0 := pow_ne_zero _ (by norm_num)
  field_simp

end NeuralGeneralization.OnlineLower
