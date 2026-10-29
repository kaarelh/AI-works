import AffineLookup

/-! Shared-wire substitution of actual threshold DAGs. In contrast to replacing
wires by formulas, this preserves polynomial size under logarithmically many
rounds of composition. -/

namespace ConditionalNonpolynomial.AnalyticLookup
open NeuralGeneralization.BatchTwoCircuitConverse

def substitutionIndex {d k n : ℕ} (e : Fin k → Fin (d+2+n)) (i : ℕ) : ℕ :=
  if h : i < k then e ⟨i,h⟩ else
  if i < k+2 then d+(i-k) else d+2+n+(i-(k+2))

lemma substitutionIndex_lt {d k n m : ℕ} (e : Fin k → Fin (d+2+n))
    (i : ℕ) (hi : i < k+2+m) : substitutionIndex e i < d+2+(n+m) := by
  unfold substitutionIndex
  split
  · have := (e ⟨i,by assumption⟩).isLt
    omega
  · split <;> omega

lemma substitutionIndex_last {d k n m : ℕ} (e : Fin k → Fin (d+2+n)) :
    substitutionIndex e (k+2+m) = d+2+(n+m) := by
  have h0 : ¬ k+2+m < k := by omega
  have h1 : ¬ k+2+m < k+2 := by omega
  simp [substitutionIndex, h0, h1]
  omega

def substitutionWire {d k n : ℕ} (e : Fin k → Fin (d+2+n)) (m : ℕ)
    (i : Fin (k+2+m)) : Fin (d+2+(n+m)) :=
  ⟨substitutionIndex e i, substitutionIndex_lt e i i.isLt⟩

def substituteGates {d k n : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) : {m : ℕ} → ThresholdGates k m → ThresholdGates d (n+m)
  | 0, _ => g
  | m+1, (h,a) => (substituteGates g e h, a.map (substitutionWire e m))

@[simp] theorem substituteGates_wireCount {d k n m : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (h : ThresholdGates k m) :
    (substituteGates g e h).wireCount = g.wireCount+h.wireCount := by
  induction m with
  | zero => simp [substituteGates, ThresholdGates.wireCount]
  | succ m ih =>
    rcases h with ⟨h,a⟩
    simp [substituteGates, ThresholdGates.wireCount, ih h, Nat.add_assoc]

lemma substitutionIndex_initial_eval {d k n : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (x : Input d) (i : ℕ) (hi : i < k+2) :
    g.eval x (substitutionIndex e i) = initialWire (fun j => g.eval x (e j)) i := by
  by_cases hik : i < k
  · simp [substitutionIndex, hik, initialWire]
  · have hg : d+(i-k) < d+2 := by omega
    simp only [substitutionIndex, dif_neg hik, if_pos hi]
    rw [g.eval_initial x _ hg]
    by_cases he : i = k
    · subst i
      simp [initialWire]
    · have he : i = k+1 := by omega
      subst i
      simp [initialWire]

/-- Evaluation of a shared-wire substitution is genuine functional composition. -/
theorem substituteGates_eval {d k n m : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (h : ThresholdGates k m) (x : Input d)
    (i : ℕ) (hi : i < k+2+m) :
    (substituteGates g e h).eval x (substitutionIndex e i) =
      h.eval (fun j => g.eval x (e j)) i := by
  induction m generalizing i with
  | zero => exact substitutionIndex_initial_eval g e x i hi
  | succ m ih =>
    rcases h with ⟨h,a⟩
    by_cases he : i = k+2+m
    · subst i
      simp only [substituteGates, ThresholdGates.eval, substitutionIndex_last,
        Function.update_self, ThresholdGate.eval_map]
      congr 1
      funext j
      exact ih h j j.isLt
    · have hi' : i < k+2+m := by omega
      have hne : substitutionIndex e i ≠ d+2+(n+m) :=
        Nat.ne_of_lt (substitutionIndex_lt e i hi')
      simp only [substituteGates, ThresholdGates.eval]
      rw [Function.update_of_ne hne, Function.update_of_ne he]
      exact ih h i hi'

/-- All prior wires retain their values when a new DAG is appended. -/
theorem substituteGates_eval_old {d k n m : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (h : ThresholdGates k m) (x : Input d)
    (i : ℕ) (hi : i < d+2+n) :
    (substituteGates g e h).eval x i = g.eval x i := by
  induction m with
  | zero => rfl
  | succ m ih =>
    rcases h with ⟨h,a⟩
    simp only [substituteGates, ThresholdGates.eval]
    rw [Function.update_of_ne (by omega : i ≠ d+2+(n+m))]
    exact ih h

lemma foldl_max_map_le_add {α : Type*} (l : List α) (a b : α → ℕ) (D u v : ℕ)
    (hu : u ≤ v+D) (hab : ∀ i ∈ l, a i ≤ b i+D) :
    (l.map a).foldl max u ≤ (l.map b).foldl max v+D := by
  induction l generalizing u v with
  | nil => exact hu
  | cons i l ih =>
    simp only [List.map_cons, List.foldl_cons]
    apply ih (max u (a i)) (max v (b i))
    · apply max_le
      · exact hu.trans (Nat.add_le_add_right (le_max_left _ _) D)
      · exact (hab i (by simp)).trans (Nat.add_le_add_right (le_max_right _ _) D)
    · intro j hj
      exact hab j (by simp [hj])

lemma gate_inputDepth_le_add {n : ℕ} (g : ThresholdGate n)
    (a b : Fin n → ℕ) (D : ℕ) (hab : ∀ i, a i ≤ b i+D) :
    g.inputDepth a ≤ g.inputDepth b+D := by
  cases g with
  | nand i j =>
    exact max_le ((hab i).trans (Nat.add_le_add_right (le_max_left _ _) D))
      ((hab j).trans (Nat.add_le_add_right (le_max_right _ _) D))
  | threshold is k =>
    exact foldl_max_map_le_add is a b D 0 0 (by omega) (fun i _ => hab i)

/-- Substitution adds the depth of the source DAG, without duplicating paths. -/
theorem substituteGates_wireDepth {d k n m : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (h : ThresholdGates k m)
    (i : ℕ) (hi : i < k+2+m) :
    (substituteGates g e h).wireDepth (substitutionIndex e i) ≤
      h.wireDepth i + g.depth := by
  induction m generalizing i with
  | zero =>
    simpa only [substituteGates, ThresholdGates.wireDepth, Nat.zero_add] using
      g.wireDepth_le (substitutionIndex e i)
  | succ m ih =>
    rcases h with ⟨h,a⟩
    by_cases he : i = k+2+m
    · subst i
      simp only [substituteGates, ThresholdGates.wireDepth, substitutionIndex_last,
        Function.update_self, ThresholdGate.inputDepth_map]
      have hh := gate_inputDepth_le_add a
        ((fun j : Fin (d+2+(n+m)) => (substituteGates g e h).wireDepth j) ∘
          substitutionWire e m)
        (fun j => h.wireDepth j) g.depth (fun j => ih h j j.isLt)
      omega
    · have hi' : i < k+2+m := by omega
      have hne : substitutionIndex e i ≠ d+2+(n+m) :=
        Nat.ne_of_lt (substitutionIndex_lt e i hi')
      simp only [substituteGates, ThresholdGates.wireDepth]
      rw [Function.update_of_ne hne, Function.update_of_ne he]
      exact ih h i hi'

theorem substituteGates_depth {d k n m : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (h : ThresholdGates k m) :
    (substituteGates g e h).depth ≤ g.depth+h.depth := by
  induction m with
  | zero => simp [substituteGates, ThresholdGates.depth]
  | succ m ih =>
    rcases h with ⟨h,a⟩
    simp only [substituteGates, ThresholdGates.depth, ThresholdGate.inputDepth_map]
    apply max_le
    · exact (ih h).trans (Nat.add_le_add_left (le_max_left _ _) g.depth)
    · have hh := gate_inputDepth_le_add a
        ((fun j : Fin (d+2+(n+m)) => (substituteGates g e h).wireDepth j) ∘
          substitutionWire e m)
        (fun j => h.wireDepth j) g.depth
        (fun j => substituteGates_wireDepth g e h j j.isLt)
      have hmax := le_max_right h.depth (a.inputDepth (fun j => h.wireDepth j)+1)
      omega

/-- Append an actual circuit, feeding its input wires from an existing DAG. -/
def substituteCircuit {d k n : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (c : ThresholdCircuit k) : ThresholdCircuit d where
  gateCount := n+c.gateCount
  gates := substituteGates g e c.gates
  output := substitutionWire e c.gateCount c.output

@[simp] theorem substituteCircuit_eval {d k n : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (c : ThresholdCircuit k) (x : Input d) :
    (substituteCircuit g e c).eval x = c.eval (fun j => g.eval x (e j)) :=
  substituteGates_eval g e c.gates x c.output c.output.isLt

@[simp] theorem substituteCircuit_size {d k n : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (c : ThresholdCircuit k) :
    (substituteCircuit g e c).size = n+g.wireCount+c.size := by
  simp [substituteCircuit, ThresholdCircuit.size, Nat.add_assoc, Nat.add_comm,
    Nat.add_left_comm]

theorem substituteCircuit_depth {d k n : ℕ} (g : ThresholdGates d n)
    (e : Fin k → Fin (d+2+n)) (c : ThresholdCircuit k) :
    (substituteCircuit g e c).depth ≤ g.depth+c.depth :=
  substituteGates_depth g e c.gates

#print axioms substituteCircuit_eval
#print axioms substituteCircuit_size
#print axioms substituteCircuit_depth
#print axioms substituteGates_eval
#print axioms substituteGates_wireCount

end ConditionalNonpolynomial.AnalyticLookup
