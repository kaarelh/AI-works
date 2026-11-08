import NeuralGeneralization.NonpolynomialCircuitBounds

/-! Ordinary acyclic Boolean circuits, with a depth certificate. Sources may
be augmented inputs or earlier gates; fan-out and skipped layers are unrestricted. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.NonpolynomialInterpolation
open ConcreteModel

structure BooleanCircuit (q d C D : ℕ) where
  gate : Fin C → BooleanFunction q
  source : Fin C → Fin q → Fin (d + 1) ⊕ Fin C
  level : Fin C → Fin D
  source_before : ∀ i a j, source i a = .inr j → (level j).val < (level i).val
  output : Fin (d + 1) ⊕ Fin C

namespace BooleanCircuit
variable {q d C D : ℕ}

def evaluate (B : BooleanCircuit q d C D) (x : Cube d) : ℕ → Fin C → Bool
  | 0 => fun _ => true
  | n + 1 => fun i => B.gate i (fun a => match B.source i a with
      | .inl j => Fin.cases true x j
      | .inr j => B.evaluate x n j)

/-- Once a gate's depth has been reached, its value is independent of the
number of further simultaneous circuit updates. -/
theorem evaluate_agree (B : BooleanCircuit q d C D) (x : Cube d) (i : Fin C)
    {n m : ℕ} (hn : (B.level i).val < n) (hm : (B.level i).val < m) :
    B.evaluate x n i = B.evaluate x m i := by
  generalize he : (B.level i).val = k at hn hm
  induction k using Nat.strong_induction_on generalizing i n m with
  | h k ih =>
    obtain ⟨n, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (show n ≠ 0 by omega)
    obtain ⟨m, rfl⟩ := Nat.exists_eq_succ_of_ne_zero (show m ≠ 0 by omega)
    simp only [evaluate]
    congr 1
    funext a
    cases hs : B.source i a with
    | inl j => rfl
    | inr j =>
      have hj := B.source_before i a j hs
      exact ih (B.level j).val (by omega) j rfl (by omega) (by omega)

def computes (B : BooleanCircuit q d C D) : BooleanFunction d :=
  fun x => match B.output with
    | .inl j => Fin.cases true x j
    | .inr j => B.evaluate x D j

/-- One input carrier per gate-input occurrence, every gate output, and the
possible direct input readout. Repeated occurrences need no distinctness hypothesis. -/
abbrev Signal (q C : ℕ) := (Fin C × Fin q) ⊕ (Fin C ⊕ Unit)

def signalCount (q C : ℕ) : ℕ := C * q + C + 1

def signalEquiv (q C : ℕ) : Signal q C ≃ Fin (signalCount q C) :=
  Fintype.equivOfCardEq (by simp [signalCount, add_assoc])

def inputOfSource : (Fin (d + 1) ⊕ Fin C) → Fin (d + 1)
  | .inl i => i
  | .inr _ => 0

def signalValue (B : BooleanCircuit q d C D) (x : Cube d) (n : ℕ) : Signal q C → Bool
  | .inl (i, a) => Fin.cases true x (inputOfSource (B.source i a))
  | .inr (.inl i) => B.evaluate x n i
  | .inr (.inr _) => Fin.cases true x (inputOfSource B.output)

def signalGate (B : BooleanCircuit q d C D) (hq : 0 < q) : Signal q C → BooleanFunction q
  | .inl _ => fun x => x ⟨0, hq⟩
  | .inr (.inl i) => B.gate i
  | .inr (.inr _) => fun x => x ⟨0, hq⟩

def firstSource (B : BooleanCircuit q d C D) : Signal q C → Fin q → Fin (d + 1)
  | .inl (i, a), _ => inputOfSource (B.source i a)
  | .inr (.inl i), a => inputOfSource (B.source i a)
  | .inr (.inr _), _ => inputOfSource B.output

def nextSource (B : BooleanCircuit q d C D) : Signal q C → Fin q → Signal q C
  | .inl p, _ => .inl p
  | .inr (.inl i), a => match B.source i a with
      | .inl _ => .inl (i, a)
      | .inr j => .inr (.inl j)
  | .inr (.inr u), _ => .inr (.inr u)

def outputSignal (B : BooleanCircuit q d C D) : Signal q C :=
  match B.output with
  | .inl _ => .inr (.inr ())
  | .inr i => .inr (.inl i)

/-- The first layer evaluates every gate using the inputs and dummy `true`
values at gates not yet reached. Those dummy values cannot affect a completed gate. -/
theorem signal_first (B : BooleanCircuit q d C D) (hq : 0 < q) (x : Cube d)
    (i : Signal q C) :
    B.signalGate hq i (fun a => Fin.cases true x (B.firstSource i a)) = B.signalValue x 1 i := by
  rcases i with ⟨i, a⟩ | (i | u)
  · rfl
  · simp only [signalGate, firstSource, signalValue, evaluate]
    congr 1
    funext a
    cases B.source i a <;> rfl
  · rfl

/-- Every subsequent layer performs one simultaneous update and relays inputs. -/
theorem signal_next (B : BooleanCircuit q d C D) (hq : 0 < q) (x : Cube d)
    (n : ℕ) (i : Signal q C) :
    B.signalGate hq i (fun a => B.signalValue x n (B.nextSource i a)) =
      B.signalValue x (n + 1) i := by
  rcases i with ⟨i, a⟩ | (i | u)
  · rfl
  · simp only [signalGate, signalValue, evaluate]
    congr 1
    funext a
    cases hs : B.source i a <;> simp [nextSource, hs, inputOfSource]
  · rfl

/-- Every requested network depth is realized by additional exact circuit updates. -/
def layered (B : BooleanCircuit q d C D) (hq : 0 < q) (r : ℕ) :
    LayeredCircuit q d (signalCount q C) r where
  gate _ i := B.signalGate hq ((signalEquiv q C).symm i)
  inputSource i a := B.firstSource ((signalEquiv q C).symm i) a
  source _ i a := signalEquiv q C (B.nextSource ((signalEquiv q C).symm i) a)
  output := signalEquiv q C B.outputSignal

/-- Exact gate-by-gate correspondence, including carried inputs. -/
theorem layered_signal (B : BooleanCircuit q d C D) (hq : 0 < q) (r : ℕ)
    (x : Cube d) (n : ℕ) (hn : n ≤ r) (i : Signal q C) :
    (B.layered hq r).gate ⟨n, by omega⟩ (signalEquiv q C i)
      ((B.layered hq r).patterns x n (signalEquiv q C i)) = B.signalValue x (n + 1) i := by
  induction n generalizing i with
  | zero => simpa [layered, LayeredCircuit.patterns] using B.signal_first hq x i
  | succ n ih =>
    rw [LayeredCircuit.patterns_succ (B.layered hq r) x (⟨n, by omega⟩ : Fin r)]
    have he (a : Fin q) :
        (B.layered hq r).gate (⟨n, by omega⟩ : Fin (r + 1))
          ((B.layered hq r).source ⟨n, by omega⟩ (signalEquiv q C i) a)
          ((B.layered hq r).patterns x n
            ((B.layered hq r).source ⟨n, by omega⟩ (signalEquiv q C i) a)) =
          B.signalValue x (n + 1) (B.nextSource i a) := by
      simpa only [layered, Equiv.symm_apply_apply] using ih (by omega) (B.nextSource i a)
    change B.signalGate hq ((signalEquiv q C).symm (signalEquiv q C i))
      (fun a => _) = _
    simp only [Equiv.symm_apply_apply]
    apply Eq.trans _ (B.signal_next hq x (n + 1) i)
    apply congrArg (B.signalGate hq i)
    exact funext he

/-- The layer expansion preserves the ordinary DAG's function at every sufficient depth. -/
theorem layered_computes (B : BooleanCircuit q d C D) (hq : 0 < q) (r : ℕ)
    (hD : D ≤ r + 1) : (B.layered hq r).computes = B.computes := by
  funext x
  have hv := B.layered_signal hq r x r le_rfl B.outputSignal
  change (B.layered hq r).computes x = B.computes x
  rw [show (B.layered hq r).computes x = B.signalValue x (r + 1) B.outputSignal from hv]
  cases ho : B.output with
  | inl j => simp [computes, outputSignal, signalValue, inputOfSource, ho]
  | inr j =>
    simp only [computes, outputSignal, ho, signalValue]
    exact B.evaluate_agree x j (lt_of_lt_of_le (B.level j).isLt hD) (B.level j).isLt

end BooleanCircuit
end NeuralGeneralization.NonpolynomialInterpolation
