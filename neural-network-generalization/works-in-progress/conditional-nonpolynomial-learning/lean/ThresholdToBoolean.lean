import Circuits
import Mathlib.Tactic.NormNum
import Mathlib.Tactic.Linarith
import Mathlib.Tactic.Ring

/-! Explicit polynomial-size simulation of threshold circuits by NAND circuits.
No complexity-class inclusion is assumed. -/

namespace ConditionalNonpolynomial
namespace ThresholdToBoolean

open NeuralGeneralization.BatchTwoCircuitConverse

/-- Three NAND gates for `a ∨ (b ∧ e)`, preserving all previous wires. -/
def orAnd {d : ℕ} (c : Circuit d) (a b e : Fin c.wires) : Circuit d :=
  let c₁ := c.add b e
  let ai : Fin c₁.wires := ⟨a, by simp [c₁, Circuit.wires]; omega⟩
  let c₂ := c₁.add ai ai
  c₂.add ⟨c₁.wires, by simp [c₂, Circuit.wires]⟩
    ⟨c.wires, by simp [c₂, c₁, Circuit.wires]; omega⟩

@[simp] theorem size_orAnd {d : ℕ} (c : Circuit d) (a b e : Fin c.wires) :
    (orAnd c a b e).size = c.size + 3 := by
  simp [orAnd]

theorem extends_orAnd {d : ℕ} (c : Circuit d) (a b e : Fin c.wires) :
    c.Extends (orAnd c a b e) := by
  unfold orAnd
  exact (c.extends_add _ _).trans ((Circuit.extends_add _ _ _).trans
    (Circuit.extends_add _ _ _))

@[simp] theorem eval_orAnd {d : ℕ} (c : Circuit d) (a b e : Fin c.wires)
    (x : Input d) :
    (orAnd c a b e).eval x = (c.evalWire x a || (c.evalWire x b && c.evalWire x e)) := by
  have ha := a.isLt
  have hw : c.wires < (c.add b e).wires := by simp [Circuit.wires]
  simp only [orAnd, Circuit.eval_add, Circuit.evalWire_add_new,
    Circuit.evalWire_add_old, Bool.and_self, ha, hw]
  cases c.evalWire x a <;> cases c.evalWire x b <;> cases c.evalWire x e <;> decide

/-- Copy a selected wire to the final output using two NAND gates. -/
def copy {d : ℕ} (c : Circuit d) (a : Fin c.wires) : Circuit d :=
  let c₁ := c.add a a
  c₁.add ⟨c.wires, by simp [c₁, Circuit.wires]⟩
    ⟨c.wires, by simp [c₁, Circuit.wires]⟩

@[simp] theorem size_copy {d : ℕ} (c : Circuit d) (a : Fin c.wires) :
    (copy c a).size = c.size + 2 := by simp [copy]

theorem extends_copy {d : ℕ} (c : Circuit d) (a : Fin c.wires) :
    c.Extends (copy c a) := by
  unfold copy
  exact (c.extends_add _ _).trans (Circuit.extends_add _ _ _)

@[simp] theorem eval_copy {d : ℕ} (c : Circuit d) (a : Fin c.wires) (x : Input d) :
    (copy c a).eval x = c.evalWire x a := by
  simp [copy]

/-- Lift an existing wire through an extension. -/
def liftWire {d : ℕ} {c c' : Circuit d} (h : c.Extends c')
    (i : Fin c.wires) : Fin c'.wires :=
  ⟨i, by have hi := i.isLt; have hs := h.1; unfold Circuit.wires at *; omega⟩

@[simp] theorem eval_liftWire {d : ℕ} {c c' : Circuit d} (h : c.Extends c')
    (i : Fin c.wires) (x : Input d) :
    c'.evalWire x (liftWire h i) = c.evalWire x i := h.2 x i i.isLt

/-- Parallel evaluation of any finite list of three-input gadgets, with their
selected output wires retained and an exact linear gate-count increase. -/
theorem parallel_orAnd {d m : ℕ} (c : Circuit d)
    (a b e : Fin m → Fin c.wires) :
    ∃ c' : Circuit d, c.Extends c' ∧ c'.size = c.size + 3 * m ∧
      ∃ out : Fin m → Fin c'.wires, ∀ i x,
        c'.evalWire x (out i) =
          (c.evalWire x (a i) || (c.evalWire x (b i) && c.evalWire x (e i))) := by
  induction m generalizing c with
  | zero =>
    exact ⟨c, Circuit.Extends.refl c, by simp, Fin.elim0, by intro i; exact Fin.elim0 i⟩
  | succ m ih =>
    let c₁ := orAnd c (a 0) (b 0) (e 0)
    have h₁ : c.Extends c₁ := extends_orAnd c _ _ _
    obtain ⟨c₂, h₂, hs₂, out₂, hv₂⟩ := ih c₁
      (fun i => liftWire h₁ (a i.succ))
      (fun i => liftWire h₁ (b i.succ))
      (fun i => liftWire h₁ (e i.succ))
    refine ⟨c₂, h₁.trans h₂, ?_,
      Fin.cases (liftWire h₂ ⟨c₁.outputWire, c₁.outputWire_lt⟩) out₂, ?_⟩
    · rw [hs₂]
      simp [c₁, Nat.mul_add]
      omega
    · intro i x
      refine Fin.cases ?_ (fun j => ?_) i
      · simp only [Fin.cases_zero, eval_liftWire]
        exact eval_orAnd c _ _ _ x
      · simp only [Fin.cases_succ]
        simpa only [eval_liftWire] using hv₂ j x


def falseWire {d : ℕ} (c : Circuit d) : Fin c.wires :=
  ⟨d, by unfold Circuit.wires; omega⟩

def trueWire {d : ℕ} (c : Circuit d) : Fin c.wires :=
  ⟨d + 1, by unfold Circuit.wires; omega⟩

@[simp] theorem eval_falseWire {d : ℕ} (c : Circuit d) (x : Input d) :
    c.evalWire x (falseWire c) = false := c.evalWire_false x

@[simp] theorem eval_trueWire {d : ℕ} (c : Circuit d) (x : Input d) :
    c.evalWire x (trueWire c) = true := c.evalWire_true x

lemma count_step (k c : ℕ) (b : Bool) :
    decide (k ≤ c + if b then 1 else 0) =
      (decide (k ≤ c) || (b && decide (k - 1 ≤ c))) := by
  cases b
  · simp
  · by_cases h0 : k ≤ c <;> by_cases h1 : k - 1 ≤ c <;> simp_all <;> omega

/-- Build every threshold of a list of old wires by the count recurrence.
The gate count is quadratic in list length, with no truth-table expansion. -/
theorem count_wires {d : ℕ} (c : Circuit d) (is : List (Fin c.wires)) :
    ∃ c' : Circuit d, c.Extends c' ∧
      c'.size ≤ c.size + 3 * is.length * (is.length + 1) ∧
      ∃ out : ℕ → Fin c'.wires, ∀ k x,
        c'.evalWire x (out k) = decide (k ≤ (is.filter fun (i : Fin c.wires) => c.evalWire x i).length) := by
  induction is with
  | nil =>
    refine ⟨c, Circuit.Extends.refl c, by simp,
      (fun k => if k = 0 then trueWire c else falseWire c), ?_⟩
    intro k x
    by_cases hk : k = 0 <;> simp [hk]
  | cons b is ih =>
    obtain ⟨c₁, h₁, hs₁, out₁, hv₁⟩ := ih
    obtain ⟨c₂, h₂, hs₂, out₂, hv₂⟩ := parallel_orAnd (m := is.length + 2) c₁
      (fun i => out₁ i) (fun _ => liftWire h₁ b) (fun i => out₁ (i - 1))
    refine ⟨c₂, h₁.trans h₂, ?_,
      (fun k => if hk : k < is.length + 2 then out₂ ⟨k, hk⟩ else falseWire c₂), ?_⟩
    · simp only [List.length_cons]
      rw [hs₂]
      nlinarith
    · intro k x
      by_cases hk : k < is.length + 2
      · simp only [hk, ↓reduceDIte]
        rw [hv₂]
        simp only [hv₁, eval_liftWire]
        rw [← count_step]
        cases hb : c.evalWire x b <;> simp [hb]
      · have hlen := List.length_filter_le (fun (i : Fin c.wires) => c.evalWire x i) (b :: is)
        have hcount : ¬ k ≤ ((b :: is).filter fun (i : Fin c.wires) => c.evalWire x i).length := by
          simp only [List.length_cons] at hlen
          omega
        simp [hk, hcount]

/-- A single threshold gate has an actual NAND implementation extending any
already constructed circuit, with a quadratic number of additional gates. -/
theorem threshold_extension {d : ℕ} (c : Circuit d)
    (is : List (Fin c.wires)) (k : ℕ) :
    ∃ c' : Circuit d, c.Extends c' ∧
      c'.size ≤ c.size + 5 * (is.length + 1)^2 ∧
      ∀ x, c'.eval x = decide (k ≤ (is.filter fun (i : Fin c.wires) => c.evalWire x i).length) := by
  obtain ⟨c₁, h₁, hs₁, out, hv⟩ := count_wires c is
  refine ⟨copy c₁ (out k), h₁.trans (extends_copy c₁ _), ?_, ?_⟩
  · rw [size_copy]
    nlinarith
  · intro x
    rw [eval_copy, hv]


/-- Compile one actual gate after an arbitrary concrete wire embedding. -/
theorem gate_extension {d m : ℕ} (c : Circuit d) (a : ThresholdGate m)
    (w : Fin m → Fin c.wires) :
    ∃ c' : Circuit d, c.Extends c' ∧
      c'.size ≤ c.size + 5 * (a.fanIn + 1)^2 ∧
      ∀ x, c'.eval x = a.eval (fun i => c.evalWire x (w i)) := by
  cases a with
  | nand i j =>
    refine ⟨c.add (w i) (w j), c.extends_add _ _, ?_, ?_⟩
    · simp [ThresholdGate.fanIn]
    · intro x
      simp [ThresholdGate.eval]
  | threshold is k =>
    obtain ⟨c', he, hs, hv⟩ := threshold_extension c (is.map w) k
    refine ⟨c', he, ?_, ?_⟩
    · simpa [ThresholdGate.fanIn] using hs
    · intro x
      rw [hv]
      simp only [ThresholdGate.eval]
      congr 2
      clear hs hv
      induction is with
      | nil => rfl
      | cons i is ih =>
        cases hi : c.evalWire x (w i) <;> simp [hi, ih]

/-- Compile all gates, retaining a correct selected wire for every original
input, constant, and intermediate gate. -/
theorem compile_gates {d n : ℕ} (g : ThresholdGates d n) :
    ∃ c : Circuit d, c.size ≤ 5 * (n + g.wireCount)^2 ∧
      ∃ w : Fin (d + 2 + n) → Fin c.wires, ∀ i x,
        c.evalWire x (w i) = g.eval x i := by
  induction n with
  | zero =>
    refine ⟨Circuit.empty d, by simp [ThresholdGates.wireCount],
      (fun i => ⟨i, by simpa [Circuit.wires] using i.isLt⟩), ?_⟩
    intro i x
    rfl
  | succ n ih =>
    rcases g with ⟨g, a⟩
    obtain ⟨c, hs, w, hv⟩ := ih g
    obtain ⟨c', he, hs', hv'⟩ := gate_extension c a w
    refine ⟨c', ?_,
      (fun i => if hi : (i : ℕ) < d + 2 + n
        then liftWire he (w ⟨i, hi⟩)
        else ⟨c'.outputWire, c'.outputWire_lt⟩), ?_⟩
    · simp only [ThresholdGates.wireCount]
      nlinarith [Nat.zero_le ((n + g.wireCount) * (a.fanIn + 1))]
    · intro i x
      by_cases hi : (i : ℕ) < d + 2 + n
      · simp only [hi, ↓reduceDIte, eval_liftWire, hv, ThresholdGates.eval]
        rw [Function.update_of_ne (Nat.ne_of_lt hi)]
      · have hie : (i : ℕ) = d + 2 + n := by have hh := i.isLt; omega
        simp only [hi, ↓reduceDIte]
        change c'.eval x = _
        rw [hv']
        have hf : (fun j => c.evalWire x (w j)) = (fun (j : Fin (d + 2 + n)) => g.eval x j) := by
          funext j
          exact hv j x
        rw [hf]
        simp [ThresholdGates.eval, hie]

/-- Every finite threshold circuit has an equivalent NAND circuit with a
universal quadratic size bound; depth is unrestricted in this simulation. -/
theorem threshold_to_boolean {d : ℕ} (a : ThresholdCircuit d) :
    ∃ c : Circuit d, c.size ≤ 7 * (a.size + 1)^2 ∧ c.eval = a.eval := by
  obtain ⟨c, hs, w, hv⟩ := compile_gates a.gates
  refine ⟨copy c (w a.output), ?_, ?_⟩
  · rw [size_copy]
    change c.size + 2 ≤ 7 * (a.gateCount + a.gates.wireCount + 1)^2
    ring_nf at hs ⊢
    omega
  · funext x
    rw [eval_copy, hv]
    rfl

end ThresholdToBoolean

/-- The standard circuit-class inclusion, proved by the explicit quadratic
threshold-to-NAND compiler, not postulated as a complexity assumption. -/
theorem TC1_subset_PPoly : TC1 ⊆ PPoly := by
  rintro f ⟨A, k, B, h⟩
  refine ⟨7 * (A + 1)^2, 2 * k, fun d => ?_⟩
  obtain ⟨a, hs, hd, ha⟩ := h d
  obtain ⟨c, hc, he⟩ := ThresholdToBoolean.threshold_to_boolean a
  refine ⟨c, hc.trans ?_, he.trans ha⟩
  have hp : 1 ≤ (d + 2)^k := by
    exact Nat.one_le_pow k (d + 2) (by omega)
  have hb : a.size + 1 ≤ (A + 1) * (d + 2)^k := by nlinarith
  calc
    7 * (a.size + 1)^2 ≤ 7 * ((A + 1) * (d + 2)^k)^2 :=
      Nat.mul_le_mul_left 7 (Nat.pow_le_pow_left hb 2)
    _ = 7 * (A + 1)^2 * (d + 2)^(2*k) := by
      rw [Nat.mul_pow, ← Nat.pow_mul, Nat.mul_comm k 2]
      ring

#print axioms ThresholdToBoolean.threshold_to_boolean
#print axioms TC1_subset_PPoly

end ConditionalNonpolynomial
