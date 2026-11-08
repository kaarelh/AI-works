import NeuralGeneralization.NonpolynomialCircuitSimulation
import NeuralGeneralization.RobustCompressionGridPadding
import Mathlib.Tactic.DeriveFintype

/-! Uniform coefficient and complexity bounds for the finite gate dictionary.
The finite collection of possible weight values is independent of circuit
width, input dimension, and depth. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.NonpolynomialInterpolation
open ConcreteModel

/-- Every compiler weight has one of these finitely many forms. -/
inductive WeightForm (q : ℕ) where
  | zero
  | constantInput
  | constantRelay
  | biasRelay (k : Cube q)
  | readout (g : BooleanFunction q) (k : Cube q)
  | input (bias : Bool) (k mask : Cube q)
  | internal (k : Cube q) (g : BooleanFunction q) (j mask : Cube q)
  deriving Fintype

namespace GateDictionary
variable {φ : ℝ → ℝ} {q : ℕ}

def weightValue (D : GateDictionary φ q) : WeightForm q → ℝ
  | .zero => 0
  | .constantInput => D.constantInput
  | .constantRelay => D.constantInput / φ D.constantInput
  | .biasRelay k => D.bias k / φ D.constantInput
  | .readout g k => D.readout g k
  | .input bias k mask => (if bias then D.bias k else 0) +
      ∑ a, if mask a then D.input k a else 0
  | .internal k g j mask => ∑ a, if mask a then D.input k a * D.readout g j else 0

def coefficientBound (D : GateDictionary φ q) : ℝ :=
  1 + ∑ a : WeightForm q, |D.weightValue a|

theorem coefficientBound_ge_one (D : GateDictionary φ q) : 1 ≤ D.coefficientBound := by
  have hs : 0 ≤ ∑ a : WeightForm q, |D.weightValue a| := Finset.sum_nonneg (fun _ _ => abs_nonneg _)
  unfold coefficientBound
  linarith

theorem weightValue_bound (D : GateDictionary φ q) (a : WeightForm q) :
    |D.weightValue a| ≤ D.coefficientBound := by
  have hs := Finset.single_le_sum (f := fun a : WeightForm q => |D.weightValue a|)
    (fun a _ => abs_nonneg _) (Finset.mem_univ a)
  unfold coefficientBound
  linarith

/-- This is where the independent signal blocks prevent width-dependent weights. -/
theorem circuitWeights_value (D : GateDictionary φ q) {d S r : ℕ}
    (C : LayeredCircuit q d S r) (i : WeightIndex d (circuitWidth q S) r) :
    ∃ a : WeightForm q, D.circuitWeights C i = D.weightValue a := by
  classical
  rcases i with ⟨i, j⟩ | (⟨t, i, j⟩ | i)
  · cases hi : (circuitNeurons q S).symm i with
    | inl u =>
      by_cases hj : j = 0
      · exact ⟨.constantInput, by simp [circuitWeights, weightValue, hi, hj]⟩
      · exact ⟨.zero, by simp [circuitWeights, weightValue, hi, hj]⟩
    | inr p =>
      rcases p with ⟨s, k⟩
      exact ⟨.input (decide (j = 0)) k (fun a => decide (C.inputSource s a = j)), by
        simp [circuitWeights, weightValue, hi]⟩
  · cases hi : (circuitNeurons q S).symm i with
    | inl u =>
      cases hj : (circuitNeurons q S).symm j with
      | inl v => exact ⟨.constantRelay, by simp [circuitWeights, weightValue, hi, hj]⟩
      | inr p => exact ⟨.zero, by simp [circuitWeights, weightValue, hi, hj]⟩
    | inr p =>
      rcases p with ⟨s, k⟩
      cases hj : (circuitNeurons q S).symm j with
      | inl u => exact ⟨.biasRelay k, by simp [circuitWeights, weightValue, hi, hj]⟩
      | inr p' =>
        rcases p' with ⟨v, l⟩
        exact ⟨.internal k (C.gate t.castSucc v) l (fun a => decide (C.source t s a = v)), by
          simp [circuitWeights, weightValue, hi, hj]⟩
  · cases hi : (circuitNeurons q S).symm i with
    | inl u => exact ⟨.zero, by simp [circuitWeights, weightValue, hi]⟩
    | inr p =>
      rcases p with ⟨s, k⟩
      by_cases hs : s = C.output
      · exact ⟨.readout (C.gate (Fin.last r) s) k, by simp [circuitWeights, weightValue, hi, hs]⟩
      · exact ⟨.zero, by simp [circuitWeights, weightValue, hi, hs]⟩

theorem circuitWeights_bounded (D : GateDictionary φ q) {d S r : ℕ}
    (C : LayeredCircuit q d S r) : boundedWeights D.coefficientBound (D.circuitWeights C) := by
  intro i
  obtain ⟨a, ha⟩ := D.circuitWeights_value C i
  rw [ha]
  exact D.weightValue_bound a

/-- Width padding makes the same integer bound count both width and weights. -/
theorem circuit_complexity (D : GateDictionary φ q) {d S r M : ℕ}
    (C : LayeredCircuit q d S r) (hwidth : circuitWidth q S ≤ M)
    (hcoeff : D.coefficientBound ≤ M) : realizesAtComplexity (r := r) φ C.computes M := by
  have hM : 1 ≤ M := (by simp [circuitWidth] : 1 ≤ circuitWidth q S).trans hwidth
  have hb : boundedWeights M (D.circuitWeights C) :=
    fun i => (D.circuitWeights_bounded C i).trans hcoeff
  refine ⟨hM, widthPaddedWeights hwidth (D.circuitWeights C), ?_,
    widthPaddedWeights_bounded hwidth (Nat.cast_nonneg M) _ hb⟩
  intro x
  rw [networkOutput_widthPaddedWeights, D.networkOutput_circuit]
  cases C.computes x <;> norm_num [labelReal]

end GateDictionary

/-- The dictionary constant precedes all circuit parameters. -/
theorem layered_circuit_simulation {φ : ℝ → ℝ} (hφ : Continuous φ)
    (hn : Nonpolynomial φ) (q : ℕ) :
    ∃ A : ℝ, 1 ≤ A ∧ ∀ d S r (C : LayeredCircuit q d S r),
      ∃ w : Weights d (1 + S * 2 ^ q) r,
        boundedWeights A w ∧ ∀ x, networkOutput φ w x = labelReal (C.computes x) := by
  obtain ⟨D⟩ := exists_gateDictionary hφ hn q
  refine ⟨D.coefficientBound, D.coefficientBound_ge_one, ?_⟩
  intro d S r C
  rw [← circuitWidth_eq q S]
  exact ⟨D.circuitWeights C, D.circuitWeights_bounded C, D.networkOutput_circuit C⟩

end NeuralGeneralization.NonpolynomialInterpolation
