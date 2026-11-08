import NeuralGeneralization.NonpolynomialInterpolationDictionary
import Mathlib.Data.Fintype.Fin

/-! Layered bounded-fan-in circuits and their exact block encodings.
The single constant neuron is counted in the width. Every other neuron belongs
to exactly one signal block, so shared circuit signals do not accumulate an
unbounded number of coefficients in a network weight. -/
noncomputable section
open scoped BigOperators
namespace NeuralGeneralization.NonpolynomialInterpolation
open ConcreteModel

/-- A Boolean circuit with `S` carried signals per layer and `r+1` gate layers.
All gates have arity `q`; smaller gates may ignore some arguments. -/
structure LayeredCircuit (q d S r : ℕ) where
  gate : Fin (r + 1) → Fin S → BooleanFunction q
  inputSource : Fin S → Fin q → Fin (d + 1)
  source : Fin r → Fin S → Fin q → Fin S
  output : Fin S

namespace LayeredCircuit
variable {q d S r : ℕ}

def patterns (C : LayeredCircuit q d S r) (x : Cube d) : ℕ → Fin S → Cube q
  | 0 => fun i k => Fin.cases true x (C.inputSource i k)
  | n + 1 => if h : n < r then
      fun i k => C.gate (⟨n, by omega⟩ : Fin (r + 1)) (C.source ⟨n, h⟩ i k)
        (C.patterns x n (C.source ⟨n, h⟩ i k))
    else C.patterns x n

theorem patterns_succ (C : LayeredCircuit q d S r) (x : Cube d) (s : Fin r) :
    C.patterns x (s.val + 1) = fun i k =>
      C.gate s.castSucc (C.source s i k) (C.patterns x s.val (C.source s i k)) := by
  simp only [patterns, dif_pos s.isLt]
  rfl

def computes (C : LayeredCircuit q d S r) : BooleanFunction d :=
  fun x => C.gate (Fin.last r) C.output (C.patterns x r C.output)

end LayeredCircuit

/-- One constant neuron plus one full feature block per carried signal. -/
def circuitWidth (q S : ℕ) : ℕ := 1 + S * Fintype.card (Cube q)

theorem circuitWidth_eq (q S : ℕ) : circuitWidth q S = 1 + S * 2 ^ q := by
  simp [circuitWidth, Cube]

def circuitNeurons (q S : ℕ) : Unit ⊕ (Fin S × Cube q) ≃ Fin (circuitWidth q S) :=
  Fintype.equivOfCardEq (by simp [circuitWidth])

namespace GateDictionary
variable {φ : ℝ → ℝ} {q d S r : ℕ}

def feature (D : GateDictionary φ q) (p : Cube q) (j : Cube q) : ℝ :=
  φ ((∑ k, D.input j k * labelReal (p k)) + D.bias j)

def encoding (D : GateDictionary φ q) (p : Fin S → Cube q) : Fin (circuitWidth q S) → ℝ :=
  fun i => match (circuitNeurons q S).symm i with
  | .inl _ => φ D.constantInput
  | .inr (s, j) => D.feature (p s) j

/-- The coefficients are genuine weights of the original no-internal-bias model. -/
def circuitWeights (D : GateDictionary φ q) (C : LayeredCircuit q d S r) :
    Weights d (circuitWidth q S) r
  | .inl (i, j) => match (circuitNeurons q S).symm i with
    | .inl _ => if j = 0 then D.constantInput else 0
    | .inr (s, k) => (if j = 0 then D.bias k else 0) +
        ∑ a, if C.inputSource s a = j then D.input k a else 0
  | .inr (.inl (t, i, j)) => match (circuitNeurons q S).symm i,
      (circuitNeurons q S).symm j with
    | .inl _, .inl _ => D.constantInput / φ D.constantInput
    | .inl _, .inr _ => 0
    | .inr (_, k), .inl _ => D.bias k / φ D.constantInput
    | .inr (s, k), .inr (v, l) => ∑ a,
        if C.source t s a = v then D.input k a * D.readout (C.gate t.castSucc v) l else 0
  | .inr (.inr i) => match (circuitNeurons q S).symm i with
    | .inl _ => 0
    | .inr (s, k) => if s = C.output then D.readout (C.gate (Fin.last r) s) k else 0

/-- The affine offsets in the first layer use only `x₀ = 1`. -/
theorem inputRow_sum (D : GateDictionary φ q) (C : LayeredCircuit q d S r)
    (x : Cube d) (s : Fin S) (k : Cube q) :
    (∑ j : Fin (d + 1), ((if j = 0 then D.bias k else 0) +
      ∑ a, if C.inputSource s a = j then D.input k a else 0) * inputVector x j) =
      (∑ a, D.input k a * labelReal (C.patterns x 0 s a)) + D.bias k := by
  classical
  simp_rw [add_mul, Finset.sum_add_distrib, Finset.sum_mul, ite_mul, zero_mul]
  rw [Finset.sum_comm]
  simp only [Finset.sum_ite_eq, Finset.sum_ite_eq', Finset.mem_univ, ↓reduceIte, inputVector, Fin.cases_zero, mul_one]
  have he (a : Fin q) : Fin.cases 1 (fun i => labelReal (x i)) (C.inputSource s a) =
      labelReal (C.patterns x 0 s a) := by
    unfold LayeredCircuit.patterns
    generalize C.inputSource s a = j
    refine Fin.cases ?_ (fun j => ?_) j <;> rfl
  simp_rw [he]
  ring

/-- The first hidden layer is exactly the chosen interpolation features. -/
theorem firstHidden_circuit (D : GateDictionary φ q) (C : LayeredCircuit q d S r)
    (x : Cube d) : firstHidden φ (D.circuitWeights C) x = D.encoding (C.patterns x 0) := by
  classical
  funext i
  cases hi : (circuitNeurons q S).symm i with
  | inl u => simp [firstHidden, circuitWeights, encoding, hi, inputVector]
  | inr p =>
    rcases p with ⟨s, k⟩
    simpa only [firstHidden, circuitWeights, encoding, hi, feature] using
      congrArg φ (D.inputRow_sum C x s k)

end GateDictionary
end NeuralGeneralization.NonpolynomialInterpolation
