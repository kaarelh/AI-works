import NeuralGeneralization.RobustCircuit

/-! Width-one witnesses under the paper's counted-wire convention. No
constant wire is added to a literal, first-stage NAND, or negation chain. -/
noncomputable section
namespace NeuralGeneralization.ConcreteModel.LayeredBooleanCircuit

/-- Any first-stage gate, followed by an arbitrary sequence of copies and
negations, has literal width one at every depth. -/
def widthOne {d r : ℕ} (g : DigitalGate (Fin (d+1))) (negate : Fin r → Bool) :
    LayeredBooleanCircuit d 1 r where
  constant := 0
  first := fun _ => g
  internal := fun s _ => if negate s then .negate 0 else .copy 0
  output := 0
  bias_available := by
    intro pre post s x hpre i j k hgate
    cases hs : negate s <;> simp [hs] at hgate

@[simp] theorem widthOne_zero_computes {d : ℕ} (g : DigitalGate (Fin (d+1)))
    (x : Cube d) :
    (widthOne (r := 0) g (fun i => Fin.elim0 i)).computes x =
      g.eval (Fin.cases true x) := by
  simp [computes, finalBits, firstBits, widthOne]

/-- Copying additional hidden stages changes neither function nor width. -/
theorem widthOne_copies_compute {d r : ℕ} (g : DigitalGate (Fin (d+1)))
    (x : Cube d) :
    (widthOne (r := r) g (fun _ => false)).computes x =
      g.eval (Fin.cases true x) := by
  have hfold (ss : List (Fin r)) (h : Fin 1 → Bool) :
      ss.foldl (widthOne g (fun _ => false)).stepBits h = h := by
    induction ss generalizing h with
    | nil => rfl
    | cons s ss ih =>
      rw [List.foldl_cons, ih]
      funext i
      have hi : i = 0 := Subsingleton.elim _ _
      simp [stepBits, widthOne, DigitalGate.eval, hi]
  unfold computes finalBits
  rw [hfold]
  rfl

theorem widthOne_literal {d r : ℕ} (j : Fin d) (x : Cube d) :
    (widthOne (r := r) (.copy j.succ) (fun _ => false)).computes x = x j := by
  rw [widthOne_copies_compute]
  rfl

theorem widthOne_negative_constant {d r : ℕ} (x : Cube d) :
    (widthOne (d := d) (r := r) (.negate 0) (fun _ => false)).computes x = false := by
  rw [widthOne_copies_compute]
  rfl

end NeuralGeneralization.ConcreteModel.LayeredBooleanCircuit
