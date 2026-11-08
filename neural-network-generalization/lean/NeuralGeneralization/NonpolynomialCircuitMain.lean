import NeuralGeneralization.NonpolynomialCircuitDAG

/-! The strong-prior paper's circuit simulation and finite-complexity remark.
The constant is chosen before all input dimensions, gate counts, and depths. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.NonpolynomialInterpolation
open ConcreteModel
namespace BooleanCircuit
variable {q d C D : ℕ}

/-- Pad the arity by one ignored input; this also handles a basis of nullary gates. -/
def padArity (B : BooleanCircuit q d C D) : BooleanCircuit (q + 1) d C D where
  gate i x := B.gate i (fun a => x a.succ)
  source i := Fin.cases (.inl 0) (B.source i)
  level := B.level
  source_before i a j h := by
    revert h
    refine Fin.cases ?_ (fun a => ?_) a
    · simp
    · exact B.source_before i a j
  output := B.output

theorem padArity_evaluate (B : BooleanCircuit q d C D) (x : Cube d) (n : ℕ) :
    B.padArity.evaluate x n = B.evaluate x n := by
  induction n with
  | zero => rfl
  | succ n ih =>
    funext i
    simp only [evaluate, padArity, Fin.cases_succ]
    simp only [padArity] at ih
    rw [ih]

theorem padArity_computes (B : BooleanCircuit q d C D) : B.padArity.computes = B.computes := by
  funext x
  change (match B.output with
    | .inl j => Fin.cases true x j
    | .inr j => B.padArity.evaluate x D j) = B.computes x
  rw [padArity_evaluate]
  rfl

end BooleanCircuit

/-- A literal network-size bound for circuits with positive maximum fan-in. -/
theorem circuit_simulation_positive_arity {φ : ℝ → ℝ} (hφ : Continuous φ)
    (hn : Nonpolynomial φ) (q : ℕ) (hq : 0 < q) :
    ∃ a : ℕ, 1 ≤ a ∧ ∀ d C D r, 1 ≤ C → D ≤ r + 1 →
      ∀ B : BooleanCircuit q d C D, ∃ w : Weights d (a * C) r,
        boundedWeights a w ∧ (∀ x, networkOutput φ w x = labelReal (B.computes x)) ∧
        realizesAtComplexity (r := r) φ B.computes (a * C) := by
  obtain ⟨K⟩ := exists_gateDictionary hφ hn q
  let a : ℕ := ⌈K.coefficientBound⌉₊ + 2 + (q + 2) * 2 ^ q
  have ha : 1 ≤ a := by dsimp [a]; omega
  have hKa : K.coefficientBound ≤ (a : ℝ) :=
    (Nat.le_ceil _).trans (Nat.cast_le.mpr (by dsimp [a]; omega))
  refine ⟨a, ha, ?_⟩
  intro d C D r hC hD B
  let T := B.layered hq r
  have hw : circuitWidth q (BooleanCircuit.signalCount q C) ≤ a * C := by
    rw [circuitWidth_eq]
    dsimp [BooleanCircuit.signalCount]
    have hp : 1 ≤ 2 ^ q := Nat.one_le_two_pow
    have hcq : C * q + C + 1 ≤ C * (q + 2) := by nlinarith
    have hmul := Nat.mul_le_mul_right (2 ^ q) hcq
    have hca : 2 + (q + 2) * 2 ^ q ≤ a := by dsimp [a]; omega
    nlinarith [Nat.mul_le_mul_right C hca]
  have hEq : T.computes = B.computes := B.layered_computes hq r hD
  have hb : boundedWeights a (K.circuitWeights T) := fun i => (K.circuitWeights_bounded T i).trans hKa
  let w := widthPaddedWeights hw (K.circuitWeights T)
  have hwb : boundedWeights a w := widthPaddedWeights_bounded hw (Nat.cast_nonneg a) _ hb
  have hwa : a ≤ a * C := by simpa using Nat.mul_le_mul_left a hC
  refine ⟨w, hwb, ?_, ?_⟩
  · intro x
    simp only [w, networkOutput_widthPaddedWeights, K.networkOutput_circuit, hEq]
  · rw [← hEq]
    exact K.circuit_complexity T hw (hKa.trans (Nat.cast_le.mpr hwa))

/-- Circuit simulation for every fixed bounded fan-in, with an activation-
dependent constant independent of `d`, `C`, `D`, and the requested depth. -/
theorem circuit_simulation {φ : ℝ → ℝ} (hφ : Continuous φ)
    (hn : Nonpolynomial φ) (q : ℕ) :
    ∃ a : ℕ, 1 ≤ a ∧ ∀ d C D r, 1 ≤ C → D ≤ r + 1 →
      ∀ B : BooleanCircuit q d C D, ∃ w : Weights d (a * C) r,
        boundedWeights a w ∧ (∀ x, networkOutput φ w x = labelReal (B.computes x)) ∧
        realizesAtComplexity (r := r) φ B.computes (a * C) := by
  obtain ⟨a, ha, h⟩ := circuit_simulation_positive_arity hφ hn (q + 1) (by omega)
  refine ⟨a, ha, fun d C D r hC hD B => ?_⟩
  simpa only [BooleanCircuit.padArity_computes] using h d C D r hC hD B.padArity

/-- The paper's depth notation: `L` counts all weight matrices, including the
final linear readout. The produced width is at most `a C` (in fact exactly it). -/
theorem paper_circuit_simulation {φ : ℝ → ℝ} (hφ : Continuous φ)
    (hn : Nonpolynomial φ) (q : ℕ) :
    ∃ a : ℕ, 1 ≤ a ∧ ∀ d C D L, 1 ≤ C → 2 ≤ L → D + 1 ≤ L →
      ∀ B : BooleanCircuit q d C D, ∃ w : Weights d (a * C) (L - 2),
        boundedWeights a w ∧ (∀ x, networkOutput φ w x = labelReal (B.computes x)) ∧
        realizesAtComplexity (r := L - 2) φ B.computes (a * C) := by
  obtain ⟨a, ha, h⟩ := circuit_simulation hφ hn q
  exact ⟨a, ha, fun d C D L hC hL hD B => h d C D (L - 2) hC (by omega) B⟩

/-- The same bound for the existing minimum bounded-weight implementation complexity. -/
theorem paper_complexity_bound {φ : ℝ → ℝ} (hφ : Continuous φ)
    (hn : Nonpolynomial φ) (q : ℕ) :
    ∃ a : ℕ, ∀ d C D r, 1 ≤ C → D ≤ r + 1 →
      ∀ B : BooleanCircuit q d C D, ∀ M, isComplexity (r := r) φ B.computes M → M ≤ a * C := by
  obtain ⟨a, _, ha⟩ := circuit_simulation hφ hn q
  refine ⟨a, fun d C D r hC hD B M hM => ?_⟩
  obtain ⟨_, _, _, hreal⟩ := ha d C D r hC hD B
  exact hM.2 _ hreal

/-- Every Boolean function is a single gate if the fan-in is allowed to be its
input dimension. This is used only for finiteness, not the fixed-basis size bound. -/
def truthTableCircuit {d : ℕ} (f : BooleanFunction d) : BooleanCircuit d d 1 1 where
  gate _ := f
  source _ a := .inl a.succ
  level _ := 0
  source_before _ _ _ h := by cases h
  output := .inr 0

theorem truthTableCircuit_computes {d : ℕ} (f : BooleanFunction d) :
    (truthTableCircuit f).computes = f := by
  rfl

/-- The paper's remark: every Boolean function has finite complexity at every depth `L ≥ 2`. -/
theorem every_function_finite_complexity {φ : ℝ → ℝ} (hφ : Continuous φ)
    (hn : Nonpolynomial φ) (d r : ℕ) (f : BooleanFunction d) :
    ∃ M, isComplexity (r := r) φ f M := by
  classical
  obtain ⟨a, _, ha⟩ := circuit_simulation hφ hn d
  obtain ⟨_, _, _, hr⟩ := ha d 1 1 r le_rfl (by omega) (truthTableCircuit f)
  have hex : ∃ M, realizesAtComplexity (r := r) φ f M := ⟨a * 1, by simpa only [truthTableCircuit_computes] using hr⟩
  exact ⟨Nat.find hex, Nat.find_spec hex, fun M hM => Nat.find_min' hex hM⟩

end NeuralGeneralization.NonpolynomialInterpolation
