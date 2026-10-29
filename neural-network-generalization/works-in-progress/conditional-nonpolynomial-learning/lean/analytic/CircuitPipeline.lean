import CircuitSubstitution

/-! Multi-output threshold programs with genuine shared state. Appending stages
adds their sizes and depths. Consequently logarithmically many polynomial-size
constant-depth stages have polynomial size and logarithmic depth. -/

namespace ConditionalNonpolynomial.AnalyticLookup

structure CircuitMap (d k : ℕ) where
  gateCount : ℕ
  gates : ThresholdGates d gateCount
  outputs : Fin k → Fin (d+2+gateCount)

def CircuitMap.eval {d k : ℕ} (c : CircuitMap d k) (x : Input d) : Input k :=
  fun i => c.gates.eval x (c.outputs i)
def CircuitMap.size {d k : ℕ} (c : CircuitMap d k) : ℕ := c.gateCount+c.gates.wireCount
def CircuitMap.depth {d k : ℕ} (c : CircuitMap d k) : ℕ := c.gates.depth

def CircuitMap.identity (d : ℕ) : CircuitMap d d :=
  ⟨0, (), fun i => ⟨i, by omega⟩⟩

@[simp] theorem CircuitMap.eval_identity (d : ℕ) (x : Input d) :
    (CircuitMap.identity d).eval x = x := by
  funext i
  simp [CircuitMap.identity, CircuitMap.eval, ThresholdGates.eval,
    NeuralGeneralization.BatchTwoCircuitConverse.initialWire, i.isLt]

@[simp] theorem CircuitMap.size_identity (d : ℕ) : (CircuitMap.identity d).size = 0 := rfl
@[simp] theorem CircuitMap.depth_identity (d : ℕ) : (CircuitMap.identity d).depth = 0 := rfl

def CircuitMap.then {d k l : ℕ} (c : CircuitMap d k) (b : CircuitMap k l) : CircuitMap d l where
  gateCount := c.gateCount+b.gateCount
  gates := substituteGates c.gates c.outputs b.gates
  outputs := fun i => substitutionWire c.outputs b.gateCount (b.outputs i)

@[simp] theorem CircuitMap.eval_then {d k l : ℕ} (c : CircuitMap d k)
    (b : CircuitMap k l) (x : Input d) :
    (c.then b).eval x = b.eval (c.eval x) := by
  funext i
  exact substituteGates_eval c.gates c.outputs b.gates x (b.outputs i) (b.outputs i).isLt

@[simp] theorem CircuitMap.size_then {d k l : ℕ} (c : CircuitMap d k) (b : CircuitMap k l) :
    (c.then b).size = c.size+b.size := by
  simp [CircuitMap.then, CircuitMap.size]
  omega

theorem CircuitMap.depth_then {d k l : ℕ} (c : CircuitMap d k) (b : CircuitMap k l) :
    (c.then b).depth ≤ c.depth+b.depth := substituteGates_depth c.gates c.outputs b.gates

def CircuitMap.select {d k : ℕ} (c : CircuitMap d k) (i : Fin k) : ThresholdCircuit d :=
  ⟨c.gateCount, c.gates, c.outputs i⟩

@[simp] theorem CircuitMap.eval_select {d k : ℕ} (c : CircuitMap d k) (i : Fin k) (x : Input d) :
    (c.select i).eval x = c.eval x i := rfl
@[simp] theorem CircuitMap.size_select {d k : ℕ} (c : CircuitMap d k) (i : Fin k) :
    (c.select i).size = c.size := rfl
@[simp] theorem CircuitMap.depth_select {d k : ℕ} (c : CircuitMap d k) (i : Fin k) :
    (c.select i).depth = c.depth := rfl

def pipeline {k : ℕ} : List (CircuitMap k k) → CircuitMap k k
  | [] => CircuitMap.identity k
  | c::cs => c.then (pipeline cs)

@[simp] theorem pipeline_eval {k : ℕ} (cs : List (CircuitMap k k)) (x : Input k) :
    (pipeline cs).eval x = cs.foldl (fun a c => c.eval a) x := by
  induction cs generalizing x with
  | nil => simp [pipeline]
  | cons c cs ih => simp [pipeline, ih]

@[simp] theorem pipeline_size {k : ℕ} (cs : List (CircuitMap k k)) :
    (pipeline cs).size = (cs.map CircuitMap.size).sum := by
  induction cs with
  | nil => simp [pipeline]
  | cons c cs ih => simp [pipeline, ih]

theorem pipeline_depth {k : ℕ} (cs : List (CircuitMap k k)) :
    (pipeline cs).depth ≤ (cs.map CircuitMap.depth).sum := by
  induction cs with
  | nil => simp [pipeline]
  | cons c cs ih =>
    exact (CircuitMap.depth_then c (pipeline cs)).trans (by simpa using Nat.add_le_add_left ih c.depth)

lemma sum_map_bound {α : Type*} (xs : List α) (f : α → ℕ) (B : ℕ)
    (hf : ∀ x ∈ xs, f x ≤ B) : (xs.map f).sum ≤ xs.length*B := by
  induction xs with
  | nil => simp
  | cons x xs ih =>
    have hh := hf x (by simp)
    have ht := ih (fun z hz => hf z (by simp [hz]))
    simp only [List.map_cons, List.sum_cons, List.length_cons]
    nlinarith

/-- No formula expansion is hidden in the compilation: sizes add over stages. -/
theorem pipeline_bounds {k : ℕ} (cs : List (CircuitMap k k)) (S D : ℕ)
    (hs : ∀ c ∈ cs, c.size ≤ S) (hd : ∀ c ∈ cs, c.depth ≤ D) :
    (pipeline cs).size ≤ cs.length*S ∧ (pipeline cs).depth ≤ cs.length*D := by
  constructor
  · rw [pipeline_size]
    exact sum_map_bound cs CircuitMap.size S hs
  · exact (pipeline_depth cs).trans (sum_map_bound cs CircuitMap.depth D hd)

/-- A logarithmic number of polynomial-size constant-depth stages is a
polynomial-size, logarithmic-depth threshold DAG, including input preprocessing. -/
theorem initialized_pipeline_bounds {d k : ℕ} (initial : CircuitMap d k)
    (cs : List (CircuitMap k k)) (R A a B D I J : ℕ)
    (hR : 0 < R) (hlen : cs.length ≤ B*Nat.log2 R)
    (hinitSize : initial.size ≤ I*R^a) (hinitDepth : initial.depth ≤ J)
    (hs : ∀ c ∈ cs, c.size ≤ A*R^a) (hd : ∀ c ∈ cs, c.depth ≤ D) :
    (initial.then (pipeline cs)).size ≤ (I+B*A)*R^(a+1) ∧
      (initial.then (pipeline cs)).depth ≤ J+B*D*Nat.log2 R := by
  have hb := pipeline_bounds cs (A*R^a) D hs hd
  have hlen' : cs.length ≤ B*R :=
    hlen.trans (Nat.mul_le_mul_left B (Nat.log2_le_self R))
  constructor
  · rw [CircuitMap.size_then, Nat.pow_succ]
    have hp : 1 ≤ R := hR
    have h0 : I*R^a ≤ I*R^a*R := Nat.le_mul_of_pos_right _ hR
    have h1 := Nat.mul_le_mul_right (A*R^a) hlen'
    have h2 := hb.1
    nlinarith
  · have hh := CircuitMap.depth_then initial (pipeline cs)
    nlinarith

#print axioms CircuitMap.eval_then
#print axioms CircuitMap.size_then
#print axioms CircuitMap.depth_then
#print axioms initialized_pipeline_bounds

end ConditionalNonpolynomial.AnalyticLookup
