import NeuralGeneralization.BatchTwoCircuitConverseCircuits
import Mathlib.Algebra.BigOperators.Group.Finset.Basic

/-!
# The deterministic Occam circuit converse

For the explicit ordered NAND language, an arbitrary minimum-size consistent
circuit predictor incurs at least `C_A(f)/(3d+3)` mistakes before it has observed
`A`. The reveal order and tie-breaking are unrestricted; repetitions are allowed.
This is the first main theorem of the circuit-converse manuscript.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

open scoped BigOperators

noncomputable section

variable {d : ℕ}

/-- Consistency on the observed input set. -/
def Circuit.Fits (c : Circuit d) (f : Input d → Bool) (A : Finset (Input d)) : Prop :=
  ∀ x ∈ A, c.eval x = f x

theorem Circuit.fits_overwrite (c : Circuit d) (f : Input d → Bool)
    (A : Finset (Input d)) (hc : c.Fits f A) (a : Input d) :
    (c.overwrite a (f a)).Fits f (insert a A) := by
  classical
  intro x hx
  rcases Finset.mem_insert.mp hx with rfl | hx
  · simp
  · simp only [Circuit.eval_overwrite]
    split
    · rename_i he; simpa [he]
    · exact hc x hx

theorem exists_fitting_circuit (f : Input d → Bool) (A : Finset (Input d)) :
    ∃ c : Circuit d, c.Fits f A := by
  classical
  induction A using Finset.induction_on with
  | empty => exact ⟨Circuit.empty d, by intro x hx; simp at hx⟩
  | @insert a A ha ih =>
    obtain ⟨c, hc⟩ := ih
    exact ⟨c.overwrite a (f a), c.fits_overwrite f A hc a⟩

theorem exists_fitting_size (f : Input d → Bool) (A : Finset (Input d)) :
    ∃ n : ℕ, ∃ c : Circuit d, c.size = n ∧ c.Fits f A := by
  obtain ⟨c, hc⟩ := exists_fitting_circuit f A
  exact ⟨c.size, c, rfl, hc⟩

/-- Minimum NAND gate count among functions agreeing with f on A. -/
def complexity (f : Input d → Bool) (A : Finset (Input d)) : ℕ :=
  by classical exact Nat.find (exists_fitting_size f A)

theorem complexity_le (f : Input d → Bool) (A : Finset (Input d))
    (c : Circuit d) (hc : c.Fits f A) : complexity f A ≤ c.size :=
  by classical exact Nat.find_min' (exists_fitting_size f A) ⟨c, rfl, hc⟩

theorem exists_minimizer (f : Input d → Bool) (A : Finset (Input d)) :
    ∃ c : Circuit d, c.size = complexity f A ∧ c.Fits f A :=
  by classical exact Nat.find_spec (exists_fitting_size f A)

@[simp] theorem complexity_empty (f : Input d → Bool) : complexity f ∅ = 0 := by
  apply Nat.eq_zero_of_le_zero
  exact complexity_le f ∅ (Circuit.empty d) (by intro x hx; simp at hx)

/-- Inputs observed before round t. -/
def history (x : ℕ → Input d) (t : ℕ) : Finset (Input d) :=
  (Finset.range t).image x

@[simp] theorem history_zero (x : ℕ → Input d) : history x 0 = ∅ := by
  simp [history]

@[simp] theorem history_succ (x : ℕ → Input d) (t : ℕ) :
    history x (t + 1) = insert (x t) (history x t) := by
  classical
  simp [history, Finset.range_add_one]

/-- Every prediction is made by any minimum-gate-count consistent circuit. -/
def IsOccam (f : Input d → Bool) (x : ℕ → Input d) (c : ℕ → Circuit d) : Prop :=
  ∀ t, (c t).Fits f (history x t) ∧ (c t).size = complexity f (history x t)

/-- Actual 0/1 mistakes through the first t predictions. -/
def mistakes (f : Input d → Bool) (x : ℕ → Input d) (c : ℕ → Circuit d) (t : ℕ) : ℕ :=
  ∑ i ∈ Finset.range t, if (c i).eval (x i) = f (x i) then 0 else 1

@[simp] theorem mistakes_zero (f : Input d → Bool) (x : ℕ → Input d)
    (c : ℕ → Circuit d) : mistakes f x c 0 = 0 := by simp [mistakes]

@[simp] theorem mistakes_succ (f : Input d → Bool) (x : ℕ → Input d)
    (c : ℕ → Circuit d) (t : ℕ) :
    mistakes f x c (t + 1) = mistakes f x c t +
      if (c t).eval (x t) = f (x t) then 0 else 1 := by
  simp [mistakes, Finset.sum_range_succ]

/-- Main deterministic converse, with the manuscript's exact gate-cost constant.
No choice of reveal order or minimizing tie-breaking is excluded. -/
theorem deterministic_occam_converse (f : Input d → Bool) (x : ℕ → Input d)
    (c : ℕ → Circuit d) (hc : IsOccam f x c) (t : ℕ) :
    complexity f (history x t) ≤ (3 * d + 3) * mistakes f x c t := by
  classical
  induction t with
  | zero => simp
  | succ t ih =>
    obtain ⟨hfit, hsize⟩ := hc t
    rw [history_succ, mistakes_succ]
    by_cases he : (c t).eval (x t) = f (x t)
    · simp only [he, ↓reduceIte, add_zero]
      have hfit' : (c t).Fits f (insert (x t) (history x t)) := by
        intro a ha
        rcases Finset.mem_insert.mp ha with rfl | ha
        · exact he
        · exact hfit a ha
      exact (complexity_le f _ (c t) hfit').trans (hsize ▸ ih)
    · simp only [he, ↓reduceIte]
      have hbound := complexity_le f _ ((c t).overwrite (x t) (f (x t)))
        ((c t).fits_overwrite f (history x t) hfit (x t))
      rw [Circuit.size_overwrite, hsize] at hbound
      calc
        complexity f (insert (x t) (history x t)) ≤
            complexity f (history x t) + (3 * d + 3) := hbound
        _ ≤ (3 * d + 3) * mistakes f x c t + (3 * d + 3) :=
          Nat.add_le_add_right ih _
        _ = (3 * d + 3) * (mistakes f x c t + 1) := by simp [Nat.mul_add]

/-- Once A has been completely revealed, the same inequality applies to C_A(f). -/
theorem deterministic_complete_reveal (f : Input d → Bool) (x : ℕ → Input d)
    (c : ℕ → Circuit d) (hc : IsOccam f x c) (t : ℕ) (A : Finset (Input d))
    (hA : history x t = A) :
    complexity f A ≤ (3 * d + 3) * mistakes f x c t := by
  simpa only [hA] using deterministic_occam_converse f x c hc t

/-- The bound constructs a genuine circuit for f on A, rather than only bounding
an abstract potential or an assumed description-length functional. -/
theorem deterministic_small_circuit (f : Input d → Bool) (x : ℕ → Input d)
    (c : ℕ → Circuit d) (hc : IsOccam f x c) (t : ℕ) :
    ∃ a : Circuit d, a.Fits f (history x t) ∧
      a.size ≤ (3 * d + 3) * mistakes f x c t := by
  obtain ⟨a, ha, hfit⟩ := exists_minimizer f (history x t)
  exact ⟨a, hfit, ha ▸ deterministic_occam_converse f x c hc t⟩

end
end NeuralGeneralization.BatchTwoCircuitConverse
