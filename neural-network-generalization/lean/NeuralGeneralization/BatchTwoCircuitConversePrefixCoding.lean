import NeuralGeneralization.BatchTwoCircuitConversePrefixPrior

/-!
# Explicit circuit-to-prefix-code length bound
-/
namespace NeuralGeneralization.BatchTwoCircuitConverse.Prefix
noncomputable section
open Classical
variable {d : ℕ}

theorem addressBits_le (d n : ℕ) :
    addressBits d n ≤ n * Nat.clog 2 (d+n+1) := by
  unfold addressBits
  calc
    (∑ i ∈ Finset.range n, Nat.clog 2 (d+2+i)) ≤
        ∑ _i ∈ Finset.range n, Nat.clog 2 (d+n+1) := by
      apply Finset.sum_le_sum
      intro i hi
      exact Nat.clog_mono_right 2 (by have := Finset.mem_range.mp hi; omega)
    _ = _ := by simp

theorem baseLength_le (d n : ℕ) :
    baseLength d n ≤ 3+n+2*n*Nat.clog 2 (d+n+1) := by
  have h := addressBits_le d n
  unfold baseLength
  split_ifs with hn
  · simp [hn]
  · nlinarith

/-- The asymptotic code bound in the manuscript, with an explicit integer formula. -/
theorem codeComplexity_le_gate_code (f : Input d → Bool) (A : Finset (Input d)) :
    codeComplexity f A ≤ 3+complexity f A+
      2*complexity f A*Nat.clog 2 (d+complexity f A+1) := by
  obtain ⟨c, hs, hc⟩ := exists_minimizer f A
  have hp : (Program.base c).Fits f A := hc
  have h := codeComplexity_le f A (Program.base c) hp
  rw [Program.length_base, hs] at h
  exact h.trans (baseLength_le d (complexity f A))

end
end NeuralGeneralization.BatchTwoCircuitConverse.Prefix
