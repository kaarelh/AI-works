import Circuits
import Mathlib.Algebra.BigOperators.Group.List.Basic
import Mathlib.Data.Real.Basic
import Mathlib.Algebra.BigOperators.Group.Finset.Basic
import Mathlib.Algebra.BigOperators.Fin
import Mathlib.Tactic.Linarith

open scoped BigOperators

namespace ConditionalNonpolynomial

/-- Renaming earlier wires changes only the gate's references, not its operation. -/
def ThresholdGate.map {n m : ℕ} (f : Fin n → Fin m) : ThresholdGate n → ThresholdGate m
  | .nand i j => .nand (f i) (f j)
  | .threshold is k => .threshold (is.map f) k

@[simp] theorem ThresholdGate.eval_map {n m : ℕ} (f : Fin n → Fin m)
    (a : ThresholdGate n) (x : Fin m → Bool) :
    (a.map f).eval x = a.eval (x ∘ f) := by
  cases a with
  | nand i j => rfl
  | threshold is k => simp [ThresholdGate.map, ThresholdGate.eval, List.filter_map, Function.comp_def]

@[simp] theorem ThresholdGate.fanIn_map {n m : ℕ} (f : Fin n → Fin m)
    (a : ThresholdGate n) : (a.map f).fanIn = a.fanIn := by
  cases a <;> simp [ThresholdGate.map, ThresholdGate.fanIn]

@[simp] theorem ThresholdGate.inputDepth_map {n m : ℕ} (f : Fin n → Fin m)
    (a : ThresholdGate n) (x : Fin m → ℕ) :
    (a.map f).inputDepth x = a.inputDepth (x ∘ f) := by
  cases a <;> simp [ThresholdGate.map, ThresholdGate.inputDepth, List.map_map]

def ThresholdCircuit.appendGate {d : ℕ} (c : ThresholdCircuit d)
    (a : ThresholdGate (d + 2 + c.gateCount)) : ThresholdCircuit d where
  gateCount := c.gateCount + 1
  gates := (c.gates, a)
  output := ⟨d + 2 + c.gateCount, by omega⟩

@[simp] theorem ThresholdCircuit.eval_appendGate {d : ℕ} (c : ThresholdCircuit d)
    (a : ThresholdGate (d + 2 + c.gateCount)) (x : Input d) :
    (c.appendGate a).eval x = a.eval (fun i => c.gates.eval x i) := by
  simp [ThresholdCircuit.appendGate, ThresholdCircuit.eval, ThresholdGates.eval]

@[simp] theorem ThresholdCircuit.size_appendGate {d : ℕ} (c : ThresholdCircuit d)
    (a : ThresholdGate (d + 2 + c.gateCount)) :
    (c.appendGate a).size = c.size + a.fanIn + 1 := by
  simp [ThresholdCircuit.appendGate, ThresholdCircuit.size, ThresholdGates.wireCount]
  omega

@[simp] theorem ThresholdCircuit.depth_appendGate {d : ℕ} (c : ThresholdCircuit d)
    (a : ThresholdGate (d + 2 + c.gateCount)) :
    (c.appendGate a).depth = max c.depth
      (a.inputDepth (fun i => c.gates.wireDepth i) + 1) := rfl

theorem ThresholdGates.eval_initial {d n : ℕ} (g : ThresholdGates d n)
    (x : Input d) (i : ℕ) (hi : i < d + 2) :
    g.eval x i = NeuralGeneralization.BatchTwoCircuitConverse.initialWire x i := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rcases g with ⟨g, a⟩
    simp only [ThresholdGates.eval]
    rw [Function.update_of_ne (by omega : i ≠ d + 2 + n)]
    exact ih g

theorem ThresholdGates.depth_initial {d n : ℕ} (g : ThresholdGates d n)
    (i : ℕ) (hi : i < d + 2) : g.wireDepth i = 0 := by
  induction n with
  | zero => rfl
  | succ n ih =>
    rcases g with ⟨g, a⟩
    simp only [ThresholdGates.wireDepth]
    rw [Function.update_of_ne (by omega : i ≠ d + 2 + n)]
    exact ih g

/-- Inserting `n` gates leaves the input/constant indices unchanged and shifts
all non-input indices. This is the wire renaming for parallel composition. -/
def shiftedWire (d n m : ℕ) (i : Fin (d + 2 + m)) : Fin (d + 2 + (n + m)) :=
  ⟨if i.val < d + 2 then i.val else i.val + n, by
    split <;> have := i.isLt <;> omega⟩

def ThresholdGates.concat {d n : ℕ} (g : ThresholdGates d n) :
    {m : ℕ} → ThresholdGates d m → ThresholdGates d (n + m)
  | 0, _ => g
  | m + 1, (h, a) => (ThresholdGates.concat g h, a.map (shiftedWire d n m))

@[simp] theorem ThresholdGates.wireCount_concat {d n m : ℕ}
    (g : ThresholdGates d n) (h : ThresholdGates d m) :
    (g.concat h).wireCount = g.wireCount + h.wireCount := by
  induction m with
  | zero => simp [ThresholdGates.concat, ThresholdGates.wireCount]
  | succ m ih =>
    rcases h with ⟨h, a⟩
    simp only [ThresholdGates.concat, ThresholdGates.wireCount,
      ThresholdGate.fanIn_map, ih h]
    omega

theorem ThresholdGates.eval_concat_shift {d n m : ℕ}
    (g : ThresholdGates d n) (h : ThresholdGates d m) (x : Input d)
    (i : ℕ) (hi : i < d + 2 + m) :
    (g.concat h).eval x (if i < d + 2 then i else i + n) = h.eval x i := by
  induction m generalizing i with
  | zero =>
    simp only [Nat.add_zero] at hi
    simp only [ThresholdGates.concat, if_pos hi, ThresholdGates.eval]
    exact g.eval_initial x i hi
  | succ m ih =>
    rcases h with ⟨h, a⟩
    by_cases he : i = d + 2 + m
    · subst i
      have hn : ¬ d + 2 + m < d + 2 := by omega
      simp only [ThresholdGates.concat, ThresholdGates.eval, if_neg hn]
      have heq : d + 2 + m + n = d + 2 + (n + m) := by omega
      rw [heq, Function.update_self, Function.update_self, ThresholdGate.eval_map]
      congr 1
      funext j
      exact ih h j j.isLt
    · have hi' : i < d + 2 + m := by omega
      have hshift : (if i < d + 2 then i else i + n) ≠ d + 2 + (n + m) := by
        split <;> omega
      simp only [ThresholdGates.concat, ThresholdGates.eval]
      rw [Function.update_of_ne hshift, Function.update_of_ne he]
      exact ih h i hi'

theorem ThresholdGates.depth_concat_shift {d n m : ℕ}
    (g : ThresholdGates d n) (h : ThresholdGates d m)
    (i : ℕ) (hi : i < d + 2 + m) :
    (g.concat h).wireDepth (if i < d + 2 then i else i + n) = h.wireDepth i := by
  induction m generalizing i with
  | zero =>
    simp only [Nat.add_zero] at hi
    simp only [ThresholdGates.concat, if_pos hi, ThresholdGates.wireDepth]
    exact g.depth_initial i hi
  | succ m ih =>
    rcases h with ⟨h, a⟩
    by_cases he : i = d + 2 + m
    · subst i
      have hn : ¬ d + 2 + m < d + 2 := by omega
      simp only [ThresholdGates.concat, ThresholdGates.wireDepth, if_neg hn]
      have heq : d + 2 + m + n = d + 2 + (n + m) := by omega
      rw [heq, Function.update_self, Function.update_self, ThresholdGate.inputDepth_map]
      congr 2
      funext j
      exact ih h j j.isLt
    · have hi' : i < d + 2 + m := by omega
      have hshift : (if i < d + 2 then i else i + n) ≠ d + 2 + (n + m) := by
        split <;> omega
      simp only [ThresholdGates.concat, ThresholdGates.wireDepth]
      rw [Function.update_of_ne hshift, Function.update_of_ne he]
      exact ih h i hi'

theorem ThresholdGates.eval_concat_old {d n m : ℕ}
    (g : ThresholdGates d n) (h : ThresholdGates d m) (x : Input d)
    (i : ℕ) (hi : i < d + 2 + n) : (g.concat h).eval x i = g.eval x i := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rcases h with ⟨h, a⟩
    simp only [ThresholdGates.concat, ThresholdGates.eval]
    rw [Function.update_of_ne (by omega : i ≠ d + 2 + (n + m))]
    exact ih h

theorem ThresholdGates.depth_concat_old {d n m : ℕ}
    (g : ThresholdGates d n) (h : ThresholdGates d m)
    (i : ℕ) (hi : i < d + 2 + n) : (g.concat h).wireDepth i = g.wireDepth i := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rcases h with ⟨h, a⟩
    simp only [ThresholdGates.concat, ThresholdGates.wireDepth]
    rw [Function.update_of_ne (by omega : i ≠ d + 2 + (n + m))]
    exact ih h

@[simp] theorem ThresholdGates.depth_concat {d n m : ℕ}
    (g : ThresholdGates d n) (h : ThresholdGates d m) :
    (g.concat h).depth = max g.depth h.depth := by
  induction m with
  | zero => simp [ThresholdGates.concat, ThresholdGates.depth]
  | succ m ih =>
    rcases h with ⟨h, a⟩
    simp only [ThresholdGates.concat, ThresholdGates.depth, ih h,
      ThresholdGate.inputDepth_map]
    have heq : (fun i : Fin (d + 2 + (n + m)) => (g.concat h).wireDepth ↑i) ∘ shiftedWire d n m =
        (fun i : Fin (d + 2 + m) => h.wireDepth i) := by
      funext i
      exact g.depth_concat_shift h i i.isLt
    rw [heq, max_assoc]

theorem ThresholdGates.wireDepth_le {d n : ℕ} (g : ThresholdGates d n) (i : ℕ) :
    g.wireDepth i ≤ g.depth := by
  induction n with
  | zero => simp [ThresholdGates.wireDepth, ThresholdGates.depth]
  | succ n ih =>
    rcases g with ⟨g, a⟩
    simp only [ThresholdGates.wireDepth, ThresholdGates.depth]
    by_cases he : i = d + 2 + n
    · subst i
      rw [Function.update_self]
      exact le_max_right _ _
    · rw [Function.update_of_ne he]
      exact (ih g).trans (le_max_left _ _)

private theorem foldl_max_le (l : List ℕ) (a D : ℕ) (ha : a ≤ D)
    (hl : ∀ z ∈ l, z ≤ D) : l.foldl max a ≤ D := by
  induction l generalizing a with
  | nil => exact ha
  | cons b l ih =>
    apply ih (max a b) (max_le ha (hl b (by simp)))
    intro z hz
    exact hl z (by simp [hz])

theorem ThresholdGate.inputDepth_le {n : ℕ} (g : ThresholdGate n)
    (a : Fin n → ℕ) (D : ℕ) (ha : ∀ i, a i ≤ D) : g.inputDepth a ≤ D := by
  cases g with
  | nand i j => exact max_le (ha i) (ha j)
  | threshold is k =>
    apply foldl_max_le _ _ _ (Nat.zero_le _)
    intro z hz
    rcases List.mem_map.mp hz with ⟨i, _, rfl⟩
    exact ha i

/-- A shared finite circuit with a list of designated output wires. -/
structure CircuitBank (d : ℕ) where
  gateCount : ℕ
  gates : ThresholdGates d gateCount
  outputs : List (Fin (d + 2 + gateCount))

def CircuitBank.empty (d : ℕ) : CircuitBank d := ⟨0, (), []⟩
def CircuitBank.eval {d : ℕ} (b : CircuitBank d) (x : Input d) : List Bool :=
  b.outputs.map fun i : Fin (d + 2 + b.gateCount) => b.gates.eval x (i : ℕ)

def CircuitBank.size {d : ℕ} (b : CircuitBank d) : ℕ := b.gateCount + b.gates.wireCount

def CircuitBank.depth {d : ℕ} (b : CircuitBank d) : ℕ := b.gates.depth

def CircuitBank.prepend {d : ℕ} (c : ThresholdCircuit d) (b : CircuitBank d) : CircuitBank d where
  gateCount := c.gateCount + b.gateCount
  gates := c.gates.concat b.gates
  outputs := (Fin.castLE (by omega) c.output) ::
    b.outputs.map (shiftedWire d c.gateCount b.gateCount)

@[simp] theorem CircuitBank.eval_prepend {d : ℕ} (c : ThresholdCircuit d)
    (b : CircuitBank d) (x : Input d) : (b.prepend c).eval x = c.eval x :: b.eval x := by
  simp only [CircuitBank.prepend, CircuitBank.eval, List.map_cons, List.map_map]
  congr 1
  · exact c.gates.eval_concat_old b.gates x c.output c.output.isLt
  · apply List.map_congr_left
    intro i hi
    exact c.gates.eval_concat_shift b.gates x i i.isLt

@[simp] theorem CircuitBank.size_prepend {d : ℕ} (c : ThresholdCircuit d)
    (b : CircuitBank d) : (b.prepend c).size = c.size + b.size := by
  simp only [CircuitBank.size, CircuitBank.prepend, ThresholdGates.wireCount_concat,
    ThresholdCircuit.size]
  omega

@[simp] theorem CircuitBank.depth_prepend {d : ℕ} (c : ThresholdCircuit d)
    (b : CircuitBank d) : (b.prepend c).depth = max c.depth b.depth := by
  exact c.gates.depth_concat b.gates

@[simp] theorem CircuitBank.outputs_length_prepend {d : ℕ} (c : ThresholdCircuit d)
    (b : CircuitBank d) : (b.prepend c).outputs.length = b.outputs.length + 1 := by
  simp [CircuitBank.prepend]

def CircuitBank.ofList {d : ℕ} : List (ThresholdCircuit d) → CircuitBank d
  | [] => .empty d
  | c :: cs => (CircuitBank.ofList cs).prepend c

@[simp] theorem CircuitBank.eval_ofList {d : ℕ} (cs : List (ThresholdCircuit d))
    (x : Input d) : (CircuitBank.ofList cs).eval x = cs.map (fun c => c.eval x) := by
  induction cs with
  | nil => rfl
  | cons c cs ih => simp [CircuitBank.ofList, ih]

@[simp] theorem CircuitBank.size_ofList {d : ℕ} (cs : List (ThresholdCircuit d)) :
    (CircuitBank.ofList cs).size = (cs.map ThresholdCircuit.size).sum := by
  induction cs with
  | nil => rfl
  | cons c cs ih => simp [CircuitBank.ofList, ih]

@[simp] theorem CircuitBank.outputs_length_ofList {d : ℕ} (cs : List (ThresholdCircuit d)) :
    (CircuitBank.ofList cs).outputs.length = cs.length := by
  induction cs with
  | nil => rfl
  | cons c cs ih => simp [CircuitBank.ofList, ih]

theorem CircuitBank.depth_ofList_le {d : ℕ} (cs : List (ThresholdCircuit d))
    (D : ℕ) (h : ∀ c ∈ cs, c.depth ≤ D) : (CircuitBank.ofList cs).depth ≤ D := by
  induction cs with
  | nil => exact Nat.zero_le _
  | cons c cs ih =>
    simp only [CircuitBank.ofList, CircuitBank.depth_prepend]
    exact max_le (h c (by simp)) (ih (fun c hc => h c (by simp [hc])))

/-- Append a single strict-majority gate to all the bank's outputs. -/
def CircuitBank.majority {d : ℕ} (b : CircuitBank d) : ThresholdCircuit d :=
  ({ gateCount := b.gateCount, gates := b.gates,
     output := ⟨d, by omega⟩ } : ThresholdCircuit d).appendGate
    (strictMajorityGate b.outputs)

@[simp] theorem CircuitBank.eval_majority {d : ℕ} (b : CircuitBank d) (x : Input d) :
    b.majority.eval x = decide (b.outputs.length / 2 < (b.eval x).count true) := by
  simp only [CircuitBank.majority, ThresholdCircuit.eval_appendGate, strictMajorityGate_eval]
  congr 1
  simp [CircuitBank.eval, List.count, List.countP_eq_length_filter,
    List.filter_map, Function.comp_def]

@[simp] theorem CircuitBank.size_majority {d : ℕ} (b : CircuitBank d) :
    b.majority.size = b.size + b.outputs.length + 1 := by
  simp [CircuitBank.majority, ThresholdCircuit.appendGate, strictMajorityGate,
    ThresholdGate.fanIn, ThresholdCircuit.size, CircuitBank.size, ThresholdGates.wireCount]
  omega

theorem CircuitBank.depth_majority_le {d : ℕ} (b : CircuitBank d) :
    b.majority.depth ≤ b.depth + 1 := by
  simp only [CircuitBank.majority, ThresholdCircuit.depth_appendGate]
  apply max_le
  · exact Nat.le_succ _
  · apply Nat.add_le_add_right
    apply ThresholdGate.inputDepth_le
    intro i
    exact b.gates.wireDepth_le i

/-- Concrete majority of a list of concrete threshold circuits. -/
def majorityCircuit {d : ℕ} (cs : List (ThresholdCircuit d)) : ThresholdCircuit d :=
  (CircuitBank.ofList cs).majority

@[simp] theorem majorityCircuit_eval {d : ℕ} (cs : List (ThresholdCircuit d))
    (x : Input d) : (majorityCircuit cs).eval x =
      decide (cs.length / 2 < (cs.map fun c => c.eval x).count true) := by
  simp [majorityCircuit]

@[simp] theorem majorityCircuit_size {d : ℕ} (cs : List (ThresholdCircuit d)) :
    (majorityCircuit cs).size = (cs.map ThresholdCircuit.size).sum + cs.length + 1 := by
  simp [majorityCircuit]

theorem majorityCircuit_depth_le {d : ℕ} (cs : List (ThresholdCircuit d))
    (D : ℕ) (h : ∀ c ∈ cs, c.depth ≤ D) : (majorityCircuit cs).depth ≤ D + 1 := by
  exact (CircuitBank.ofList cs).depth_majority_le.trans
    (Nat.add_le_add_right (CircuitBank.depth_ofList_le cs D h) 1)

private theorem bool_agreement_sum (bs : List Bool) (b : Bool) :
    (bs.map (fun v => if v = b then (1 : ℝ) else -1)).sum =
      if b then 2 * (bs.count true : ℝ) - bs.length
        else bs.length - 2 * (bs.count true : ℝ) := by
  induction bs with
  | nil => cases b <;> simp
  | cons a bs ih =>
    cases a <;> cases b <;> simp_all <;> linarith

/-- Positive signed agreement excludes ties and makes strict majority correct,
for either target label. -/
theorem strictMajority_eq_of_positive_agreement (bs : List Bool) (b : Bool)
    (h : 0 < (bs.map (fun v => if v = b then (1 : ℝ) else -1)).sum) :
    decide (bs.length / 2 < bs.count true) = b := by
  rw [bool_agreement_sum] at h
  cases b with
  | false =>
    simp only [Bool.false_eq_true, ↓reduceIte] at h
    have hc : 2 * bs.count true < bs.length := by exact_mod_cast (by linarith :
      2 * (bs.count true : ℝ) < bs.length)
    have : ¬ bs.length / 2 < bs.count true := by omega
    simp [this]
  | true =>
    simp only [↓reduceIte] at h
    have hc : bs.length < 2 * bs.count true := by exact_mod_cast (by linarith :
      (bs.length : ℝ) < 2 * bs.count true)
    have : bs.length / 2 < bs.count true := by omega
    simp [this]

/-- A finite family of circuit votes with pointwise positive signed agreement
has a concrete threshold circuit computing the target exactly. -/
theorem majorityCircuit_ofFn_eval_eq {d m : ℕ} (cs : Fin m → ThresholdCircuit d)
    (f : Input d → Bool)
    (h : ∀ x, 0 < ∑ i, if (cs i).eval x = f x then (1 : ℝ) else -1) :
    (majorityCircuit (List.ofFn cs)).eval = f := by
  funext x
  rw [majorityCircuit_eval]
  have hh : 0 < ((List.ofFn cs).map (fun c => c.eval x) |>.map
      (fun v => if v = f x then (1 : ℝ) else -1)).sum := by
    simpa [List.map_map, List.map_ofFn, List.sum_ofFn, Function.comp_def] using h x
  have he := strictMajority_eq_of_positive_agreement
    ((List.ofFn cs).map fun c => c.eval x) (f x) hh
  simpa only [List.length_map] using he

private theorem sum_map_size_le {d : ℕ} (cs : List (ThresholdCircuit d)) (S : ℕ)
    (h : ∀ c ∈ cs, c.size ≤ S) : (cs.map ThresholdCircuit.size).sum ≤ cs.length * S := by
  induction cs with
  | nil => simp
  | cons c cs ih =>
    simp only [List.map_cons, List.sum_cons, List.length_cons]
    have h0 := h c (by simp)
    have h1 := ih (fun c hc => h c (by simp [hc]))
    simp only [Nat.add_mul, Nat.one_mul]
    omega

theorem majorityCircuit_ofFn_size_le {d m : ℕ} (cs : Fin m → ThresholdCircuit d)
    (S : ℕ) (h : ∀ i, (cs i).size ≤ S) :
    (majorityCircuit (List.ofFn cs)).size ≤ m * (S + 1) + 1 := by
  rw [majorityCircuit_size]
  have hs := sum_map_size_le (List.ofFn cs) S (by
    intro c hc
    rcases List.mem_ofFn.mp hc with ⟨i, rfl⟩
    exact h i)
  simp only [List.length_ofFn] at hs ⊢
  nlinarith

theorem majorityCircuit_ofFn_depth_le {d m : ℕ} (cs : Fin m → ThresholdCircuit d)
    (D : ℕ) (h : ∀ i, (cs i).depth ≤ D) :
    (majorityCircuit (List.ofFn cs)).depth ≤ D + 1 := by
  apply majorityCircuit_depth_le
  intro c hc
  rcases List.mem_ofFn.mp hc with ⟨i, rfl⟩
  exact h i

end ConditionalNonpolynomial
