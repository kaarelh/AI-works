import CircuitOperations

/-! Concrete NAND embedding and finite-exception closure for the circuit classes.
No circuit-class inclusion or hardcoding oracle is assumed. -/

namespace ConditionalNonpolynomial

namespace BooleanEmbedding
open NeuralGeneralization.BatchTwoCircuitConverse

def gates {d : ℕ} : {n : ℕ} → Gates d n → ThresholdGates d n
  | 0, _ => ()
  | _ + 1, (g, i, j) => (gates g, .nand i j)

@[simp] theorem eval_gates {d n : ℕ} (g : Gates d n) (x : Input d) :
    (gates g).eval x = g.eval x := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rcases g with ⟨g, i, j⟩
    simp only [gates, ThresholdGates.eval, ThresholdGate.eval, ih, Gates.eval]

@[simp] theorem wireCount_gates {d n : ℕ} (g : Gates d n) :
    (gates g).wireCount = 2 * n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rcases g with ⟨g, i, j⟩
    simp only [gates, ThresholdGates.wireCount, ThresholdGate.fanIn, ih]
    omega

theorem depth_gates_le {d n : ℕ} (g : Gates d n) : (gates g).depth ≤ n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rcases g with ⟨g, i, j⟩
    simp only [gates, ThresholdGates.depth, ThresholdGate.inputDepth]
    have h := ih g
    have hi := (gates g).wireDepth_le i
    have hj := (gates g).wireDepth_le j
    omega

end BooleanEmbedding

def booleanToThreshold {d : ℕ} (c : BooleanCircuit d) : ThresholdCircuit d where
  gateCount := c.size
  gates := BooleanEmbedding.gates c.gates
  output := ⟨c.outputWire, c.outputWire_lt⟩

@[simp] theorem booleanToThreshold_eval {d : ℕ} (c : BooleanCircuit d) :
    (booleanToThreshold c).eval = c.eval := by
  funext x
  simp only [booleanToThreshold, ThresholdCircuit.eval, BooleanEmbedding.eval_gates]
  rfl

@[simp] theorem booleanToThreshold_size {d : ℕ} (c : BooleanCircuit d) :
    (booleanToThreshold c).size = 3 * c.size := by
  simp only [booleanToThreshold, ThresholdCircuit.size, BooleanEmbedding.wireCount_gates]
  omega

theorem booleanToThreshold_depth_le {d : ℕ} (c : BooleanCircuit d) :
    (booleanToThreshold c).depth ≤ c.size := BooleanEmbedding.depth_gates_le c.gates

/-- Eventual polynomial-size and logarithmic-depth threshold circuits suffice
for TC¹ membership. For the finite exceptional input lengths, the existing
NAND circuits are embedded directly; their resource bound gives uniform finite
constants. No effective construction of the family is required. -/
theorem mem_TC1_of_PPoly_eventually (f : Family) (hf : f ∈ PPoly)
    (h : ∃ A k B d0 : ℕ, ∀ d : ℕ, d0 ≤ d →
      ∃ c : ThresholdCircuit d, c.size ≤ A * (d + 2)^k ∧
        c.depth ≤ B * Nat.log2 (d + 2) ∧ c.eval = f d) : f ∈ TC1 := by
  rcases hf with ⟨A0, k0, h0⟩
  rcases h with ⟨A, k, B, d0, h⟩
  let M := A0 * (d0 + 2)^k0
  refine ⟨A + 3 * M, k, B + M, fun d => ?_⟩
  by_cases hd : d0 ≤ d
  · obtain ⟨c, hs, hdep, he⟩ := h d hd
    refine ⟨c, hs.trans ?_, hdep.trans ?_, he⟩
    · exact Nat.mul_le_mul_right _ (by omega)
    · exact Nat.mul_le_mul_right _ (by omega)
  · obtain ⟨c, hs, he⟩ := h0 d
    have hb : c.size ≤ M := hs.trans (Nat.mul_le_mul_left A0
      (Nat.pow_le_pow_left (by omega : d + 2 ≤ d0 + 2) k0))
    have hp : 1 ≤ (d + 2)^k := Nat.one_le_pow k (d + 2) (by omega)
    have hlog : 1 ≤ Nat.log2 (d + 2) := by
      rw [Nat.le_log2] <;> omega
    refine ⟨booleanToThreshold c, ?_, ?_, (booleanToThreshold_eval c).trans he⟩
    · rw [booleanToThreshold_size]
      calc
        3 * c.size ≤ 3 * M := Nat.mul_le_mul_left 3 hb
        _ ≤ A + 3 * M := by omega
        _ ≤ (A + 3 * M) * (d + 2)^k :=
          le_mul_of_one_le_right (Nat.zero_le _) hp
    · calc
        (booleanToThreshold c).depth ≤ c.size := booleanToThreshold_depth_le c
        _ ≤ M := hb
        _ ≤ B + M := by omega
        _ ≤ (B + M) * Nat.log2 (d + 2) :=
          le_mul_of_one_le_right (Nat.zero_le _) hlog

#print axioms booleanToThreshold_eval
#print axioms booleanToThreshold_size
#print axioms booleanToThreshold_depth_le
#print axioms mem_TC1_of_PPoly_eventually

end ConditionalNonpolynomial
