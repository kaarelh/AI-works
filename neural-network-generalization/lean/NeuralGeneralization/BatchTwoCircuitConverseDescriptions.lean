import NeuralGeneralization.BatchTwoCircuitConverseCircuits

/-!
# Injectivity of concrete circuit repairs

Erasing exactly the appended gates recovers the original description. Thus
repair injectivity is proved for syntax, even though it fails for functions.
-/

namespace NeuralGeneralization.BatchTwoCircuitConverse

/-- Delete the last gate, keeping an empty circuit empty. -/
def Circuit.pop {d : ℕ} : Circuit d → Circuit d
  | ⟨0, _⟩ => Circuit.empty d
  | ⟨n + 1, g, _, _⟩ => ⟨n, g⟩

@[simp] theorem Circuit.pop_add {d : ℕ} (c : Circuit d) (i j : Fin c.wires) :
    (c.add i j).pop = c := by cases c; rfl

/-- Delete k trailing gates. -/
def Circuit.drop {d : ℕ} : ℕ → Circuit d → Circuit d
  | 0, c => c
  | k + 1, c => drop k c.pop

@[simp] theorem Circuit.drop_zero {d : ℕ} (c : Circuit d) : c.drop 0 = c := rfl

@[simp] theorem Circuit.drop_succ {d : ℕ} (c : Circuit d) (k : ℕ) :
    c.drop (k + 1) = c.pop.drop k := rfl

theorem Circuit.drop_add {d : ℕ} (c : Circuit d) (k l : ℕ) :
    c.drop (k + l) = (c.drop l).drop k := by
  induction l generalizing c with
  | zero => simp
  | succ l ih => simp only [Nat.add_succ, Circuit.drop_succ, ih]

@[simp] theorem Circuit.drop_andLiteral {d : ℕ} (c : Circuit d)
    (a : Fin c.wires) (j : Fin d) (b : Bool) :
    (c.andLiteral a j b).drop 3 = c := by
  simp [Circuit.andLiteral, Circuit.drop]

@[simp] theorem Circuit.drop_overrideWire {d : ℕ} (c : Circuit d)
    (h e : Fin c.wires) (y : Bool) :
    (c.overrideWire h e y).drop 3 = c := by
  cases y <;> simp [Circuit.overrideWire, Circuit.drop]

@[simp] theorem AccCircuit.drop_build {d : ℕ} (target : Input d)
    (a : AccCircuit d) (js : List (Fin d)) :
    (a.build target js).circuit.drop (3 * js.length) = a.circuit := by
  induction js generalizing a with
  | nil => simp [AccCircuit.build]
  | cons j js ih =>
    simp only [AccCircuit.build, List.length_cons, Nat.mul_add, Nat.mul_one]
    rw [Nat.add_comm, Circuit.drop_add, ih]
    exact Circuit.drop_andLiteral _ _ _ _

@[simp] theorem Circuit.drop_equalityAccumulator {d : ℕ} (c : Circuit d)
    (target : Input d) :
    (c.equalityAccumulator target).circuit.drop (3 * d) = c := by
  unfold Circuit.equalityAccumulator
  simpa only [List.length_finRange] using
    AccCircuit.drop_build target
      ⟨c, ⟨d + 1, by unfold Circuit.wires; omega⟩⟩ (List.finRange d)

/-- The appended NAND suffix can be deleted without knowing the original circuit. -/
@[simp] theorem Circuit.drop_overwrite {d : ℕ} (c : Circuit d)
    (target : Input d) (y : Bool) :
    (c.overwrite target y).drop (3 * d + 3) = c := by
  rw [Circuit.drop_add]
  simp only [Circuit.overwrite, Circuit.drop_overrideWire, Circuit.drop_equalityAccumulator]

/-- The manuscript's injective overwrite lemma, for the explicit circuit syntax. -/
theorem Circuit.overwrite_injective {d : ℕ} (target : Input d) (y : Bool) :
    Function.Injective (fun c : Circuit d => c.overwrite target y) := by
  intro a b hab
  have := congrArg (Circuit.drop (3 * d + 3)) hab
  simpa only [Circuit.drop_overwrite] using this

end NeuralGeneralization.BatchTwoCircuitConverse
