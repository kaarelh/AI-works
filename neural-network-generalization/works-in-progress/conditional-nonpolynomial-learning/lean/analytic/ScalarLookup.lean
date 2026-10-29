import CircuitOperations
import Mathlib.Data.Fintype.Card

/-! Actual constant-depth scalar lookup circuits. These implement arbitrary
finite tables; the polynomial resource corollary requires logarithmically many
input bits. No computable description of the table is required. -/

noncomputable section
namespace ConditionalNonpolynomial.AnalyticLookup

open NeuralGeneralization.BatchTwoCircuitConverse

/-- One unweighted threshold on the selected outputs of an actual circuit bank. -/
def bankThreshold {d : ℕ} (b : CircuitBank d) (k : ℕ) : ThresholdCircuit d :=
  ({gateCount := b.gateCount, gates := b.gates, output := ⟨d, by omega⟩} :
    ThresholdCircuit d).appendGate (.threshold b.outputs k)

@[simp] theorem bankThreshold_eval {d : ℕ} (b : CircuitBank d) (k : ℕ) (x : Input d) :
    (bankThreshold b k).eval x = decide (k ≤ (b.eval x).count true) := by
  simp only [bankThreshold, ThresholdCircuit.eval_appendGate, ThresholdGate.eval]
  congr 1
  simp [CircuitBank.eval, List.count, List.countP_eq_length_filter,
    List.filter_map, Function.comp_def]

@[simp] theorem bankThreshold_size {d : ℕ} (b : CircuitBank d) (k : ℕ) :
    (bankThreshold b k).size = b.size + b.outputs.length + 1 := by
  simp [bankThreshold, ThresholdCircuit.appendGate, ThresholdGate.fanIn,
    ThresholdCircuit.size, CircuitBank.size, ThresholdGates.wireCount]
  omega

theorem bankThreshold_depth {d : ℕ} (b : CircuitBank d) (k : ℕ) :
    (bankThreshold b k).depth ≤ b.depth + 1 := by
  simp only [bankThreshold, ThresholdCircuit.depth_appendGate]
  apply max_le (Nat.le_succ _)
  apply Nat.add_le_add_right
  exact ThresholdGate.inputDepth_le _ _ _ (fun i => b.gates.wireDepth_le i)

def thresholdList {d : ℕ} (cs : List (ThresholdCircuit d)) (k : ℕ) : ThresholdCircuit d :=
  bankThreshold (CircuitBank.ofList cs) k

@[simp] theorem thresholdList_eval {d : ℕ} (cs : List (ThresholdCircuit d))
    (k : ℕ) (x : Input d) :
    (thresholdList cs k).eval x = decide (k ≤ (cs.map fun c => c.eval x).count true) := by
  simp [thresholdList]

@[simp] theorem thresholdList_size {d : ℕ} (cs : List (ThresholdCircuit d)) (k : ℕ) :
    (thresholdList cs k).size = (cs.map ThresholdCircuit.size).sum + cs.length + 1 := by
  simp [thresholdList]

theorem thresholdList_depth {d : ℕ} (cs : List (ThresholdCircuit d))
    (k D : ℕ) (h : ∀ c ∈ cs, c.depth ≤ D) :
    (thresholdList cs k).depth ≤ D + 1 :=
  (bankThreshold_depth _ _).trans (Nat.add_le_add_right (CircuitBank.depth_ofList_le cs D h) 1)

lemma count_all (bs : List Bool) :
    decide (bs.length ≤ bs.count true) = bs.all id := by
  apply Bool.eq_iff_iff.mpr
  simp only [decide_eq_true_eq, List.all_eq_true, id_eq]
  constructor
  · intro h b hb
    exact ((List.count_eq_length.mp (Nat.le_antisymm List.count_le_length h)) b hb).symm
  · intro h
    exact Nat.le_of_eq (List.count_eq_length.mpr (fun b hb => (h b hb).symm)).symm

@[simp] theorem thresholdList_all {d : ℕ} (cs : List (ThresholdCircuit d)) (x : Input d) :
    (thresholdList cs cs.length).eval x = cs.all (fun c => c.eval x) := by
  rw [thresholdList_eval]
  have h := count_all (cs.map fun c => c.eval x)
  simpa [List.all_map, Function.comp_def] using h

@[simp] theorem thresholdList_any {d : ℕ} (cs : List (ThresholdCircuit d)) (x : Input d) :
    (thresholdList cs 1).eval x = cs.any (fun c => c.eval x) := by
  rw [thresholdList_eval]
  apply Bool.eq_iff_iff.mpr
  simp [Nat.succ_le_iff, List.count_pos_iff, List.any_eq_true]

/-- A raw input wire, with no gate cost. -/
def inputCircuit {d : ℕ} (i : Fin d) : ThresholdCircuit d :=
  ⟨0, (), ⟨i, by omega⟩⟩

@[simp] theorem inputCircuit_eval {d : ℕ} (i : Fin d) (x : Input d) :
    (inputCircuit i).eval x = x i := by
  simp [inputCircuit, ThresholdCircuit.eval, ThresholdGates.eval, initialWire, i.isLt]

@[simp] theorem inputCircuit_size {d : ℕ} (i : Fin d) : (inputCircuit i).size = 0 := rfl
@[simp] theorem inputCircuit_depth {d : ℕ} (i : Fin d) : (inputCircuit i).depth = 0 := rfl

/-- A signed input literal uses at most one NAND gate. -/
def literal {d : ℕ} (i : Fin d) (b : Bool) : ThresholdCircuit d :=
  if b then inputCircuit i else
    (inputCircuit i).appendGate (.nand (inputCircuit i).output (inputCircuit i).output)

@[simp] theorem literal_eval {d : ℕ} (i : Fin d) (b : Bool) (x : Input d) :
    (literal i b).eval x = decide (x i = b) := by
  cases b <;> simp only [literal, Bool.false_eq_true, ↓reduceIte,
    ThresholdCircuit.eval_appendGate, ThresholdGate.eval]
  · simp [inputCircuit, ThresholdGates.eval, initialWire, i.isLt]
  · simp

theorem literal_size {d : ℕ} (i : Fin d) (b : Bool) : (literal i b).size ≤ 3 := by
  cases b <;> simp [literal, ThresholdGate.fanIn]

theorem literal_depth {d : ℕ} (i : Fin d) (b : Bool) : (literal i b).depth ≤ 1 := by
  cases b
  · change ((inputCircuit i).appendGate (.nand (inputCircuit i).output (inputCircuit i).output)).depth ≤ 1
    rw [ThresholdCircuit.depth_appendGate]
    simp [ThresholdGate.inputDepth, inputCircuit, ThresholdCircuit.depth,
      ThresholdGates.wireDepth, ThresholdGates.depth]
  · change (inputCircuit i).depth ≤ 1
    simp

/-- Equality with one bit string, implemented at threshold depth at most two. -/
def equalityCircuit {d : ℕ} (a : Input d) : ThresholdCircuit d :=
  thresholdList (List.ofFn fun i => literal i (a i)) d

@[simp] theorem equalityCircuit_eval {d : ℕ} (a x : Input d) :
    (equalityCircuit a).eval x = decide (x = a) := by
  have hh := thresholdList_all (List.ofFn fun i => literal i (a i)) x
  simp only [List.length_ofFn] at hh
  rw [equalityCircuit, hh]
  apply Bool.eq_iff_iff.mpr
  simp only [List.all_eq_true, List.mem_ofFn, forall_exists_index, forall_apply_eq_imp_iff,
    literal_eval, decide_eq_true_eq]
  exact ⟨fun h => funext h, fun h i => congrFun h i⟩

theorem sum_sizes_le {d : ℕ} (cs : List (ThresholdCircuit d)) (S : ℕ)
    (h : ∀ c ∈ cs, c.size ≤ S) : (cs.map ThresholdCircuit.size).sum ≤ cs.length*S := by
  induction cs with
  | nil => simp
  | cons c cs ih =>
    have h0 := h c (by simp)
    have h1 := ih (fun a ha => h a (by simp [ha]))
    simp only [List.map_cons, List.sum_cons, List.length_cons]
    nlinarith

theorem equalityCircuit_size {d : ℕ} (a : Input d) : (equalityCircuit a).size ≤ 4*d+1 := by
  rw [equalityCircuit, thresholdList_size]
  have h := sum_sizes_le (List.ofFn fun i => literal i (a i)) 3 (by
    intro c hc
    obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hc
    exact literal_size i (a i))
  simp only [List.length_ofFn] at h ⊢
  omega

theorem equalityCircuit_depth {d : ℕ} (a : Input d) : (equalityCircuit a).depth ≤ 2 := by
  apply thresholdList_depth _ _ 1
  intro c hc
  obtain ⟨i,rfl⟩ := List.mem_ofFn.mp hc
  exact literal_depth i (a i)

/-- Arbitrary finite one-bit lookup table. Every true table entry contributes
one equality test; one final OR joins the tests. -/
def lookupCircuit {d : ℕ} (f : Input d → Bool) : ThresholdCircuit d :=
  thresholdList (((Finset.univ : Finset (Input d)).toList.filter f).map equalityCircuit) 1

@[simp] theorem lookupCircuit_eval {d : ℕ} (f : Input d → Bool) :
    (lookupCircuit f).eval = f := by
  funext x
  rw [lookupCircuit, thresholdList_any]
  apply Bool.eq_iff_iff.mpr
  simp [List.any_eq_true, equalityCircuit_eval]

/-- Exact scalar lookup has constant depth even for an arbitrary table. -/
theorem lookupCircuit_depth {d : ℕ} (f : Input d → Bool) :
    (lookupCircuit f).depth ≤ 3 := by
  apply thresholdList_depth _ _ 2
  intro c hc
  obtain ⟨a,ha,rfl⟩ := List.mem_map.mp hc
  exact equalityCircuit_depth a

/-- Its size is linear in the table length times the input bit count. -/
theorem lookupCircuit_size {d : ℕ} (f : Input d → Bool) :
    (lookupCircuit f).size ≤ (4*d+2)*2^d+1 := by
  let entries := (Finset.univ : Finset (Input d)).toList.filter f
  have hlen : entries.length ≤ 2^d := by
    have h := List.length_filter_le f (Finset.univ : Finset (Input d)).toList
    simpa [entries, Input, Fintype.card_fun] using h
  rw [lookupCircuit, thresholdList_size]
  have hs := sum_sizes_le (entries.map equalityCircuit) (4*d+1) (by
    intro c hc
    obtain ⟨a,ha,rfl⟩ := List.mem_map.mp hc
    exact equalityCircuit_size a)
  simp only [List.length_map] at hs ⊢
  change (entries.map equalityCircuit |>.map ThresholdCircuit.size).sum + entries.length + 1 ≤ _
  nlinarith

/-- An O(log R)-bit scalar table has polynomial length. -/
theorem logbits_table_length {b k R : ℕ} (hR : 0 < R)
    (hb : b ≤ k * Nat.log2 R) : 2^b ≤ R^k := by
  calc
    2^b ≤ 2^(k * Nat.log2 R) := Nat.pow_le_pow_right (by omega) hb
    _ = (2^(Nat.log2 R))^k := by rw [← Nat.pow_mul, Nat.mul_comm]
    _ ≤ R^k := Nat.pow_le_pow_left (Nat.log2_self_le (by omega)) k

/-- Quantitative finite-bit compiler for an entirely arbitrary scalar table:
logarithmic bit count gives polynomial size and constant threshold depth. -/
theorem lookupCircuit_size_logbits {b k R : ℕ} (f : Input b → Bool)
    (hR : 0 < R) (hb : b ≤ k * Nat.log2 R) :
    (lookupCircuit f).size ≤ (4*k+3)*R^(k+1) := by
  have hs := lookupCircuit_size f
  have ht := logbits_table_length hR hb
  have hb' : b ≤ k*R := hb.trans (Nat.mul_le_mul_left k (Nat.log2_le_self R))
  have hpoly := Nat.mul_le_mul_left (4*b+2) ht
  have hbase : 1 ≤ R^k := Nat.one_le_pow k R hR
  rw [Nat.pow_succ]
  nlinarith

#print axioms lookupCircuit_size_logbits
#print axioms lookupCircuit_eval
#print axioms lookupCircuit_depth
#print axioms lookupCircuit_size

end ConditionalNonpolynomial.AnalyticLookup
