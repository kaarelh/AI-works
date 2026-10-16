import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Field
import Mathlib.Algebra.Order.BigOperators.Group.Finset
import Mathlib.Data.Fintype.BigOperators
import Mathlib.Data.List.FinRange
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.NormNum

/-!
# Deterministic finite network architecture

Depth `L = r + 2` comprises an input matrix, `r` internal matrices, and a
linear readout. The only bias is the augmented constant input coordinate.
This file has no probabilistic or Gaussian assumptions.
-/

noncomputable section

open scoped BigOperators

namespace NeuralGeneralization.ConcreteModel

abbrev Cube (d : ℕ) := Fin d → Bool
abbrev BooleanFunction (d : ℕ) := Cube d → Bool

/-- `true` denotes the label `+1`; `false` denotes `-1`. -/
def labelReal (b : Bool) : ℝ := if b then 1 else -1

@[simp] theorem labelReal_true : labelReal true = 1 := rfl
@[simp] theorem labelReal_false : labelReal false = -1 := rfl
@[simp] theorem abs_labelReal (b : Bool) : |labelReal b| = 1 := by
  cases b <;> norm_num [labelReal]

/-- The coordinates of all weights, including the readout. -/
abbrev WeightIndex (d N r : ℕ) :=
  (Fin N × Fin (d + 1)) ⊕ ((Fin r × Fin N × Fin N) ⊕ Fin N)

abbrev Weights (d N r : ℕ) := WeightIndex d N r → ℝ

def inputVector {d : ℕ} (x : Cube d) : Fin (d + 1) → ℝ :=
  Fin.cases 1 (fun i => labelReal (x i))

def firstHidden {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) : Fin N → ℝ :=
  fun i => φ (∑ j, w (Sum.inl (i, j)) * inputVector x j)

def hiddenStep {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (h : Fin N → ℝ) (s : Fin r) : Fin N → ℝ :=
  fun i => φ (∑ j, w (Sum.inr (Sum.inl (s, i, j))) * h j)

def finalHidden {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) : Fin N → ℝ :=
  (List.finRange r).foldl (hiddenStep φ w) (firstHidden φ w x)

/-- Linear readout after all `r+1` hidden layers. -/
def networkOutput {d N r : ℕ} (φ : ℝ → ℝ) (w : Weights d N r)
    (x : Cube d) : ℝ :=
  ∑ i, w (Sum.inr (Sum.inr i)) * finalHidden φ w x i

def admissibleActivation (φ : ℝ → ℝ) : Prop :=
  (∀ t, |φ t| ≤ 1) ∧ ∀ t s, |φ t - φ s| ≤ |t - s|

/-- The strict margin is imposed at every input, including unobserved inputs. -/
def marginEvent {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (f : BooleanFunction d) : Set (Weights d N r) :=
  {w | ∀ x, a < labelReal (f x) * networkOutput φ w x}

def globalMarginEvent {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ) :
    Set (Weights d N r) :=
  {w | ∀ x, a < |networkOutput φ w x|}

theorem marginEvent_subset_global {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ)
    (f : BooleanFunction d) :
    marginEvent (N := N) (r := r) φ a f ⊆ globalMarginEvent φ a := by
  intro w hw x
  calc
    a < labelReal (f x) * networkOutput φ w x := hw x
    _ ≤ |labelReal (f x) * networkOutput φ w x| := le_abs_self _
    _ = |networkOutput φ w x| := by rw [abs_mul, abs_labelReal, one_mul]

/-- The global absolute-margin event is exactly the union of its sign events. -/
theorem globalMarginEvent_eq_iUnion {d N r : ℕ} (φ : ℝ → ℝ) (a : ℝ) :
    globalMarginEvent (d := d) (N := N) (r := r) φ a =
      ⋃ f : BooleanFunction d, marginEvent φ a f := by
  classical
  ext w
  constructor
  · intro hw
    let f : BooleanFunction d := fun x => decide (0 ≤ networkOutput φ w x)
    apply Set.mem_iUnion.mpr
    refine ⟨f, ?_⟩
    intro x
    have hx := hw x
    by_cases hz : 0 ≤ networkOutput φ w x
    · simpa [f, labelReal, hz, abs_of_nonneg hz] using hx
    · simpa [f, labelReal, hz, abs_of_neg (lt_of_not_ge hz)] using hx
  · intro hw
    obtain ⟨f, hf⟩ := Set.mem_iUnion.mp hw
    exact marginEvent_subset_global φ a f hf

theorem marginEvents_disjoint {d N r : ℕ} (φ : ℝ → ℝ) {a : ℝ}
    (ha : 0 ≤ a) {f g : BooleanFunction d} (hfg : f ≠ g) :
    Disjoint (marginEvent (N := N) (r := r) φ a f) (marginEvent φ a g) := by
  classical
  apply Set.disjoint_left.mpr
  intro w hwf hwg
  obtain ⟨x, hx⟩ := Function.ne_iff.mp hfg
  have hf := hwf x
  have hg := hwg x
  cases hfx : f x <;> cases hgx : g x <;>
    simp_all [labelReal] <;> linarith

/-- The norm appearing in the exponent of the Gaussian density. -/
def weightedSquaredNorm {d N r : ℕ} (w : Weights d N r) : ℝ :=
  (d : ℝ) / N * (∑ i, ∑ j, w (Sum.inl (i, j)) ^ 2) +
  (∑ s, ∑ i, ∑ j, w (Sum.inr (Sum.inl (s, i, j))) ^ 2) +
  (N : ℝ) * (∑ i, w (Sum.inr (Sum.inr i)) ^ 2)

/-- Every coefficient of the prior's quadratic norm is nonnegative. -/
theorem weightedSquaredNorm_nonneg {d N r : ℕ} (w : Weights d N r) :
    0 ≤ weightedSquaredNorm w := by
  unfold weightedSquaredNorm
  exact add_nonneg
    (add_nonneg
      (mul_nonneg (div_nonneg (Nat.cast_nonneg d) (Nat.cast_nonneg N))
        (Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ => sq_nonneg _))
      (Finset.sum_nonneg fun _ _ => Finset.sum_nonneg fun _ _ =>
        Finset.sum_nonneg fun _ _ => sq_nonneg _))
    (mul_nonneg (Nat.cast_nonneg N) (Finset.sum_nonneg fun _ _ => sq_nonneg _))

def boundedWeights {d N r : ℕ} (B : ℝ) (w : Weights d N r) : Prop :=
  ∀ i, |w i| ≤ B

/-- A witness for bounded-weight network complexity at width `C`. -/
def realizesAtComplexity {d r : ℕ} (φ : ℝ → ℝ)
    (f : BooleanFunction d) (C : ℕ) : Prop :=
  1 ≤ C ∧ ∃ w : Weights d C r,
    w ∈ marginEvent φ (1 / 2) f ∧ boundedWeights C w

/-- This relation says precisely that `C` is the minimum admissible integer. -/
def isComplexity {d r : ℕ} (φ : ℝ → ℝ)
    (f : BooleanFunction d) (C : ℕ) : Prop :=
  realizesAtComplexity (r := r) φ f C ∧
    ∀ C', realizesAtComplexity (r := r) φ f C' → C ≤ C'

end NeuralGeneralization.ConcreteModel
