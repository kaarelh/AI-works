import WeightedAffine

/-! Actual constant-depth evaluation of arbitrary scalar lookup tables applied
to bounded-integer affine forms. The table is represented by its true entries.
This module proves the circuit, rather than assuming an arithmetic compiler. -/

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup

def negateCircuit {d : ℕ} (c : ThresholdCircuit d) : ThresholdCircuit d :=
  c.appendGate (.nand c.output c.output)

@[simp] theorem negateCircuit_eval {d : ℕ} (c : ThresholdCircuit d) (x : Input d) :
    (negateCircuit c).eval x = !(c.eval x) := by
  simp [negateCircuit, ThresholdGate.eval, ThresholdCircuit.eval_appendGate]
  rfl

@[simp] theorem negateCircuit_size {d : ℕ} (c : ThresholdCircuit d) :
    (negateCircuit c).size = c.size+3 := by
  simp [negateCircuit, ThresholdGate.fanIn]

theorem negateCircuit_depth {d : ℕ} (c : ThresholdCircuit d) :
    (negateCircuit c).depth ≤ c.depth+1 := by
  rw [negateCircuit, ThresholdCircuit.depth_appendGate]
  apply max_le (Nat.le_succ _)
  simp only [ThresholdGate.inputDepth, max_self]
  exact Nat.add_le_add_right (c.gates.wireDepth_le c.output) 1

def affineEquality {d : ℕ} (ts : List (SignedTerm d)) (j : ℤ) : ThresholdCircuit d :=
  thresholdList [signedComparison ts j, negateCircuit (signedComparison ts (j+1))] 2

@[simp] theorem affineEquality_eval {d : ℕ} (ts : List (SignedTerm d))
    (j : ℤ) (x : Input d) :
    (affineEquality ts j).eval x = decide ((ts.map (fun t => t.value x)).sum = j) := by
  have h := thresholdList_all [signedComparison ts j,
    negateCircuit (signedComparison ts (j+1))] x
  simp only [List.length_cons, List.length_nil] at h
  rw [affineEquality, h]
  simp only [List.all_cons, List.all_nil, Bool.and_true, signedComparison_eval,
    negateCircuit_eval]
  apply Bool.eq_iff_iff.mpr
  simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq, decide_eq_false_iff_not]
  omega

theorem affineEquality_depth {d : ℕ} (ts : List (SignedTerm d)) (j : ℤ) :
    (affineEquality ts j).depth ≤ 4 := by
  apply thresholdList_depth _ _ 3
  intro c hc
  simp only [List.mem_cons, List.not_mem_nil, or_false] at hc
  rcases hc with rfl | rfl
  · exact (signedComparison_depth _ _).trans (by omega)
  · exact (negateCircuit_depth _).trans (Nat.add_le_add_right (signedComparison_depth _ _) 1)

theorem affineEquality_size {d : ℕ} (ts : List (SignedTerm d)) (j : ℤ) :
    (affineEquality ts j).size ≤ 8*(ts.map (fun t => t.positive+t.negative)).sum+8 := by
  rw [affineEquality, thresholdList_size]
  simp only [List.map_cons, List.map_nil, List.sum_cons, List.sum_nil,
    List.length_cons, List.length_nil, negateCircuit_size]
  have h0 := signedComparison_size ts j
  have h1 := signedComparison_size ts (j+1)
  omega

/-- Arbitrary scalar table applied to one integer affine form. -/
def affineLookup {d : ℕ} (ts : List (SignedTerm d)) (entries : List ℤ) :
    ThresholdCircuit d :=
  thresholdList (entries.map (affineEquality ts)) 1

@[simp] theorem affineLookup_eval {d : ℕ} (ts : List (SignedTerm d))
    (entries : List ℤ) (x : Input d) :
    (affineLookup ts entries).eval x =
      decide ((ts.map (fun t => t.value x)).sum ∈ entries) := by
  rw [affineLookup, thresholdList_any]
  apply Bool.eq_iff_iff.mpr
  simp [List.any_eq_true, affineEquality_eval]

theorem affineLookup_depth {d : ℕ} (ts : List (SignedTerm d)) (entries : List ℤ) :
    (affineLookup ts entries).depth ≤ 5 := by
  apply thresholdList_depth _ _ 4
  intro c hc
  obtain ⟨j,hj,rfl⟩ := List.mem_map.mp hc
  exact affineEquality_depth ts j

theorem affineLookup_size {d : ℕ} (ts : List (SignedTerm d)) (entries : List ℤ) :
    (affineLookup ts entries).size ≤
      (8*(ts.map (fun t => t.positive+t.negative)).sum+9)*entries.length+1 := by
  rw [affineLookup, thresholdList_size]
  have hs := sum_sizes_le (entries.map (affineEquality ts))
    (8*(ts.map (fun t => t.positive+t.negative)).sum+8) (by
      intro c hc
      obtain ⟨j,hj,rfl⟩ := List.mem_map.mp hc
      exact affineEquality_size ts j)
  simp only [List.length_map] at hs ⊢
  nlinarith

#print axioms affineLookup_eval
#print axioms affineLookup_depth
#print axioms affineLookup_size

end ConditionalNonpolynomial.AnalyticLookup
