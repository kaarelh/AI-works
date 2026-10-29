import MultiOutputCircuits
import IntegerAffine

/-! Polynomial-size one-hot scalar tables after integer affine evaluation.
Encoding one scalar grid this way costs polynomially many wires, avoiding any
truth table over the full multidimensional state. -/
noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup

def integerValue {d : ℕ} (ts : List (Fin d × ℤ)) (x : Input d) : ℤ :=
  (ts.map fun t => if x t.1 then t.2 else 0).sum

def integerWeight {d : ℕ} (ts : List (Fin d × ℤ)) : ℕ :=
  (ts.map fun t => t.2.natAbs).sum

theorem integerValue_bound {d : ℕ} (ts : List (Fin d × ℤ)) (x : Input d) :
    (integerValue ts x).natAbs ≤ integerWeight ts := by
  induction ts with
  | nil => simp [integerValue, integerWeight]
  | cons t ts ih =>
    have hh := Int.natAbs_add_le (if x t.1 then t.2 else 0) (integerValue ts x)
    have ht : (if x t.1 then t.2 else 0).natAbs ≤ t.2.natAbs := by
      cases x t.1 <;> simp
    simp only [integerValue, List.map_cons, List.sum_cons, integerWeight] at ih ⊢
    dsimp only [integerValue] at hh
    omega

def integerRange (W : ℕ) : List ℤ := (List.range (2*W+1)).map (fun j : ℕ => (j:ℤ)-W)

@[simp] theorem integerRange_length (W : ℕ) : (integerRange W).length = 2*W+1 := by
  simp [integerRange]

theorem mem_integerRange {W : ℕ} {v : ℤ} (hv : v.natAbs ≤ W) : v ∈ integerRange W := by
  have hp : v ≤ (v.natAbs:ℤ) := Int.le_natAbs
  have hn : -v ≤ (v.natAbs:ℤ) := by simpa using (Int.le_natAbs (a:=-v))
  have hj : (v+(W:ℤ)).toNat < 2*W+1 := by omega
  apply List.mem_map.mpr
  refine ⟨(v+(W:ℤ)).toNat, List.mem_range.mpr hj, ?_⟩
  omega

/-- One-hot code of a scalar table value. Each output is a separate scalar
lookup on the same integer affine preactivation, and only scalar values are
enumerated. -/
def oneHotAffine {d q : ℕ} (ts : List (Fin d × ℤ)) (table : ℤ → Fin q) : CircuitMap d q :=
  CircuitMap.ofCircuits fun i => affineLookup (ts.map integerTerm)
    ((integerRange (integerWeight ts)).filter fun v => decide (table v=i))

@[simp] theorem oneHotAffine_eval {d q : ℕ} (ts : List (Fin d × ℤ))
    (table : ℤ → Fin q) (x : Input d) (i : Fin q) :
    (oneHotAffine ts table).eval x i = decide (table (integerValue ts x)=i) := by
  have hr := mem_integerRange (integerValue_bound ts x)
  have hv : ((ts.map integerTerm).map fun t => t.value x).sum = integerValue ts x := by
    simp [integerValue, List.map_map, Function.comp_def]
  simp only [oneHotAffine, CircuitMap.eval_ofCircuits, affineLookup_eval]
  rw [hv]
  simp [hr]

theorem oneHotAffine_depth {d q : ℕ} (ts : List (Fin d × ℤ)) (table : ℤ → Fin q) :
    (oneHotAffine ts table).depth ≤ 5 := by
  apply CircuitMap.depth_ofCircuits_le
  intro i
  exact affineLookup_depth _ _

theorem oneHotAffine_size {d q : ℕ} (ts : List (Fin d × ℤ)) (table : ℤ → Fin q) :
    (oneHotAffine ts table).size ≤
      q*((8*integerWeight ts+9)*(2*integerWeight ts+1)+1) := by
  apply CircuitMap.size_ofCircuits_le
  intro i
  have hh := affineLookup_size (ts.map integerTerm)
    ((integerRange (integerWeight ts)).filter fun v => decide (table v=i))
  have hw : ((ts.map integerTerm).map (fun t => t.positive+t.negative)).sum = integerWeight ts := by
    simp [integerWeight, List.map_map, Function.comp_def]
  rw [hw] at hh
  have hlen := List.length_filter_le (fun v => decide (table v=i)) (integerRange (integerWeight ts))
  rw [integerRange_length] at hlen
  have hm := Nat.mul_le_mul_left (8*integerWeight ts+9) hlen
  omega

#print axioms oneHotAffine_eval
#print axioms oneHotAffine_size
#print axioms oneHotAffine_depth
end ConditionalNonpolynomial.AnalyticLookup
