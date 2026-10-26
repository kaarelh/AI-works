import NeuralGeneralization.RobustCircuitMargin
import NeuralGeneralization.BatchTwoCircuitConverseCircuits
import Mathlib.Data.List.OfFn

/-!
# Bounded-weight tanh teachers for concrete Boolean circuits

This module constructs actual weights. No realizability or circuit-simulation
assumption is used in the theorems below.
-/

noncomputable section
open scoped BigOperators
open NeuralGeneralization.ConcreteModel

namespace ConditionalNonpolynomial

namespace LayeredTeacher

theorem first_close {d C r : ℕ} (B : LayeredBooleanCircuit d C r)
    (x : Cube d) (i : Fin C) :
    |firstHidden Real.tanh (B.teacher 64 2) x i -
      labelReal (B.firstBits x i)| ≤ (1/16 : ℝ) := by
  have hm := (B.first i).signed_linear_margin (Fin.cases true x)
  have hinput : (fun j => labelReal (Fin.cases true x j)) = inputVector x := by
    funext j
    refine Fin.cases ?_ (fun k => ?_) j <;> rfl
  rw [hinput] at hm
  have hp : (64 : ℝ)/2 ≤ labelReal (B.firstBits x i) *
      (64 * (B.first i).linear 1 (inputVector x)) := by
    change _ ≤ labelReal ((B.first i).eval (Fin.cases true x)) * _
    nlinarith
  have hs := tanh_global_secant (B.firstBits x i) (u := 0)
    (A := 64) (by norm_num) hp
  norm_num at hs
  simpa only [firstHidden, B.first_teacher_preactivation] using hs

theorem step_close {d C r : ℕ} (B : LayeredBooleanCircuit d C r)
    (h : Fin C → ℝ) (b : Fin C → Bool) (s : Fin r)
    (hc : b B.constant = true)
    (hh : ∀ i, |h i-labelReal (b i)| ≤ (1/16 : ℝ)) :
    ∀ i, |hiddenStep Real.tanh (B.teacher 64 2) h s i -
      labelReal (B.stepBits b s i)| ≤ (1/16 : ℝ) := by
  intro i
  have hm := (B.internal s i).signed_linear_near_bits b h B.constant hc hh
  have hp : (64 : ℝ)/2 ≤ labelReal (B.stepBits b s i) *
      (64 * (B.internal s i).linear (h B.constant) h) := by
    change _ ≤ labelReal ((B.internal s i).eval b) * _
    nlinarith
  have hs := tanh_global_secant (B.stepBits b s i) (u := 0)
    (A := 64) (by norm_num) hp
  norm_num at hs
  simpa only [hiddenStep, B.internal_teacher_preactivation] using hs

theorem fold_close {d C r : ℕ} (B : LayeredBooleanCircuit d C r)
    (ss : List (Fin r)) (h : Fin C → ℝ) (b : Fin C → Bool)
    (hc : b B.constant = true)
    (hh : ∀ i, |h i-labelReal (b i)| ≤ (1/16 : ℝ)) :
    ∀ i, |ss.foldl (hiddenStep Real.tanh (B.teacher 64 2)) h i -
      labelReal (ss.foldl B.stepBits b i)| ≤ (1/16 : ℝ) := by
  induction ss generalizing h b with
  | nil => exact hh
  | cons s ss ih =>
      simp only [List.foldl_cons]
      exact ih _ _ (by simpa using hc) (step_close B h b s hc hh)

theorem teacher_margin {d C r : ℕ} (B : LayeredBooleanCircuit d C r) :
    B.teacher 64 2 ∈ marginEvent Real.tanh (1/2) B.computes := by
  intro x
  have he := fold_close B (List.finRange r) (firstHidden Real.tanh (B.teacher 64 2) x)
    (B.firstBits x) (B.firstBits_constant x) (first_close B x) B.output
  change |finalHidden Real.tanh (B.teacher 64 2) x B.output -
    labelReal (B.computes x)| ≤ (1/16 : ℝ) at he
  rw [networkOutput, B.readout_teacher]
  rcases abs_le.mp he with ⟨hl, hu⟩
  cases hb : B.computes x <;> simp only [hb, labelReal_false, labelReal_true] at hl hu ⊢ <;>
    nlinarith

theorem teacher_bounded {d C r : ℕ} (B : LayeredBooleanCircuit d C r)
    (hC : 192 ≤ C) : boundedWeights C (B.teacher 64 2) := by
  intro i
  have hCr : (192 : ℝ) ≤ C := by exact_mod_cast hC
  rcases i with ⟨i,j⟩ | (⟨s,i,j⟩ | i)
  · simp only [LayeredBooleanCircuit.teacher, abs_mul, abs_of_nonneg (by norm_num : (0:ℝ)≤64)]
    have := (B.first i).abs_coeff_le (0 : Fin (d+1)) j
    nlinarith
  · simp only [LayeredBooleanCircuit.teacher, abs_mul, abs_of_nonneg (by norm_num : (0:ℝ)≤64)]
    have := (B.internal s i).abs_coeff_le B.constant j
    nlinarith
  · simp only [LayeredBooleanCircuit.teacher]
    split_ifs
    all_goals norm_num
    all_goals linarith

theorem realizes {d C r : ℕ} (B : LayeredBooleanCircuit d C r)
    (hC : 192 ≤ C) : realizesAtComplexity (r := r) Real.tanh B.computes C :=
  ⟨by omega, B.teacher 64 2, teacher_margin B, teacher_bounded B hC⟩

end LayeredTeacher

namespace NandTeacher

open NeuralGeneralization.BatchTwoCircuitConverse

abbrev Stage (C : ℕ) := Fin C → DigitalGate (Fin C)

def runStage {C : ℕ} (b : Fin C → Bool) (g : Stage C) : Fin C → Bool :=
  fun i => (g i).eval b

def copyStage (C : ℕ) : Stage C := fun i => .copy i

@[simp] theorem runStage_copy {C : ℕ} (b : Fin C → Bool) :
    runStage b (copyStage C) = b := by
  funext i
  rfl

/-- One NAND stage updates just its new wire, copying all other wires. -/
def addStage {d n C : ℕ} (hC : d+2+n < C)
    (i j : Fin (d+2+n)) : Stage C := fun k =>
  if (k : ℕ) = d+2+n then
    .nand ⟨i, by omega⟩ ⟨j, by omega⟩ else .copy k

@[simp] theorem runStage_add {d n C : ℕ} (hC : d+2+n < C)
    (i j : Fin (d+2+n)) (b : Fin C → Bool) (k : Fin C) :
    runStage b (addStage hC i j) k =
      if (k : ℕ) = d+2+n then
        !(b ⟨i, by omega⟩ && b ⟨j, by omega⟩) else b k := by
  simp only [runStage, addStage]
  split <;> rfl

def stages {d C : ℕ} : {n : ℕ} → Gates d n → (d+2+n ≤ C) → List (Stage C)
  | 0, _, _ => []
  | n+1, (g,i,j), hC => stages g (by omega) ++ [addStage (by omega) i j]

@[simp] theorem stages_length {d C n : ℕ} (g : Gates d n) (hC : d+2+n ≤ C) :
    (stages g hC).length = n := by
  induction n with
  | zero => rfl
  | succ n ih =>
      rcases g with ⟨g,i,j⟩
      simp only [stages, List.length_append, List.length_singleton, ih]

theorem stages_constant {d C n : ℕ} (g : Gates d n) (hC : d+2+n ≤ C)
    (a : Stage C) (ha : a ∈ stages g hC) :
    a ⟨d+1, by omega⟩ = .copy ⟨d+1, by omega⟩ := by
  induction n with
  | zero => simp [stages] at ha
  | succ n ih =>
      rcases g with ⟨g,i,j⟩
      simp only [stages, List.mem_append, List.mem_singleton] at ha
      rcases ha with ha | rfl
      · exact ih g _ ha
      · simp only [addStage]
        rw [if_neg (by omega)]

theorem stages_eval {d C n : ℕ} (g : Gates d n) (hC : d+2+n ≤ C)
    (x : Input d) (b : Fin C → Bool)
    (hb : ∀ k : Fin C, (k : ℕ) < d+2 → b k = initialWire x k) :
    ∀ k : Fin C, (k : ℕ) < d+2+n →
      (stages g hC).foldl runStage b k = g.eval x k := by
  induction n with
  | zero => intro k hk; exact hb k (by omega)
  | succ n ih =>
      rcases g with ⟨g,i,j⟩
      intro k hk
      simp only [stages, List.foldl_append, List.foldl_cons, List.foldl_nil,
        runStage_add, Gates.eval]
      by_cases he : (k : ℕ) = d+2+n
      · rw [if_pos he, Function.update_apply]
        simp only [he, if_true]
        rw [ih g _ ⟨i, by omega⟩ i.isLt, ih g _ ⟨j, by omega⟩ j.isLt]
      · rw [if_neg he, Function.update_of_ne he]
        exact ih g _ k (by omega)

def firstGate {d C : ℕ} (k : Fin C) : DigitalGate (Fin (d+1)) :=
  if h : (k : ℕ) < d then .copy (Fin.succ ⟨k, h⟩)
  else if (k : ℕ) = d+1 then .copy 0 else .negate 0

@[simp] theorem firstGate_eval {d C : ℕ} (x : Input d) (k : Fin C) :
    (firstGate k).eval (Fin.cases true x) = initialWire x k := by
  unfold firstGate initialWire
  split_ifs <;> simp_all [DigitalGate.eval]

@[simp] theorem firstGate_constant {d C : ℕ} (hC : d+2 ≤ C) :
    firstGate (d := d) (⟨d+1, by omega⟩ : Fin C) = .copy 0 := by
  simp [firstGate]

/-- Constant-wire-preserving padding supplies at least d+1 internal stages. -/
def paddedStages {d C n : ℕ} (g : Gates d n) (hC : d+2+n ≤ C) : List (Stage C) :=
  stages g hC ++ List.replicate (d+1) (copyStage C)

@[simp] theorem paddedStages_length {d C n : ℕ} (g : Gates d n) (hC : d+2+n ≤ C) :
    (paddedStages g hC).length = n+d+1 := by
  simp [paddedStages, Nat.add_assoc]

@[simp] theorem fold_copies {C : ℕ} (k : ℕ) (b : Fin C → Bool) :
    (List.replicate k (copyStage C)).foldl runStage b = b := by
  induction k with
  | zero => rfl
  | succ k ih => simpa only [List.replicate_succ, List.foldl_cons, runStage_copy] using ih

theorem paddedStages_constant {d C n : ℕ} (g : Gates d n) (hC : d+2+n ≤ C)
    (a : Stage C) (ha : a ∈ paddedStages g hC) :
    a ⟨d+1, by omega⟩ = .copy ⟨d+1, by omega⟩ := by
  simp only [paddedStages, List.mem_append] at ha
  rcases ha with ha | ha
  · exact stages_constant g hC a ha
  · have : a = copyStage C := (List.eq_of_mem_replicate ha)
    subst a
    rfl

/-- Concrete sequential simulation with polynomial width and depth. -/
def layered {d : ℕ} (c : Circuit d) :
    LayeredBooleanCircuit d (d+c.size+256)
      (paddedStages (C := d+c.size+256) c.gates (by omega)).length where
  constant := ⟨d+1, by omega⟩
  first := firstGate
  internal := fun s => (paddedStages c.gates (by omega)).get s
  output := ⟨c.outputWire, by have := c.outputWire_lt; unfold Circuit.wires at this; omega⟩
  first_constant := firstGate_constant (by omega)
  internal_constant := fun s => paddedStages_constant c.gates (by omega) _ (List.get_mem _ _)

theorem layered_computes {d : ℕ} (c : Circuit d) :
    (layered c).computes = c.eval := by
  funext x
  let C := d+c.size+256
  let hC : d+2+c.size ≤ C := by dsimp [C]; omega
  let ps := paddedStages (C := C) c.gates hC
  let b : Fin C → Bool := fun i => (firstGate i).eval (Fin.cases true x)
  let out : Fin C := ⟨c.outputWire, by
    have := c.outputWire_lt
    unfold Circuit.wires at this
    dsimp [C]
    omega⟩
  change (List.finRange ps.length).foldl
    (fun state s => runStage state (ps.get s)) b out = c.eval x
  rw [← List.foldl_map]
  rw [← List.ofFn_eq_map, List.ofFn_get]
  dsimp [ps]
  rw [paddedStages, List.foldl_append, fold_copies]
  exact stages_eval c.gates hC x b (fun k _ => firstGate_eval x k) out c.outputWire_lt

/-- Every concrete NAND circuit has an actual bounded-weight tanh teacher.
The input dimension and gate count determine polynomial resources explicitly. -/
theorem realizes_compiled {d : ℕ} (c : Circuit d) :
    realizesAtComplexity (r := c.size+d+1) Real.tanh c.eval (d+c.size+256) := by
  have h := LayeredTeacher.realizes (layered c) (by omega)
  simpa only [layered_computes, paddedStages_length] using h

/-- The constructed depth is at least the input dimension and at least three. -/
theorem compiled_depth_bounds {d : ℕ} (c : Circuit d) :
    d ≤ (c.size+d+1)+2 ∧ 3 ≤ (c.size+d+1)+2 := by omega

#print axioms realizes_compiled

end NandTeacher

end ConditionalNonpolynomial
