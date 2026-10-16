import NeuralGeneralization.ParameterCounting
import Mathlib.Analysis.Complex.Exponential

/-!
# Exponential capacity bound from explicit network parameter quantization

The exponent is an explicit polynomial at fixed depth. The deliberately loose
bound uses `log x ≤ x`, avoiding irrelevant optimization of packing constants.
The only width reduction left to supply is the actual compression theorem.
-/

noncomputable section

namespace NeuralGeneralization.ConcreteModel

def parameterCapacityExponent (d N r B : ℕ) : ℕ :=
  Fintype.card (WeightIndex d N r) * (2 * (B * parameterMesh d N r B) + 1)

theorem weightIndex_card (d N r : ℕ) :
    Fintype.card (WeightIndex d N r) = N * (d + 1) + r * (N * N) + N := by
  simp [WeightIndex, Fintype.card_sum, Fintype.card_prod, Nat.add_assoc]

/-- The exponent's explicit polynomial formula, with depth held fixed. -/
theorem parameterCapacityExponent_eq (d N r B : ℕ) :
    parameterCapacityExponent d N r B =
      (N * (d + 1) + r * (N * N) + N) *
        (2 * (B * ((d + 1) * (N * (B + 1) + 1) ^ (r + 1))) + 1) := by
  simp only [parameterCapacityExponent, parameterMesh, weightIndex_card]

theorem boundedNetworkFunctions_card_le_exp (d N r B : ℕ)
    (φ : ℝ → ℝ) (hφ : admissibleActivation φ) :
    (Fintype.card (BoundedNetworkFunctions d N r B φ) : ℝ) ≤
      Real.exp (parameterCapacityExponent d N r B : ℝ) := by
  let A : ℕ := 2 * (B * parameterMesh d N r B) + 1
  let P : ℕ := Fintype.card (WeightIndex d N r)
  have hc : (Fintype.card (BoundedNetworkFunctions d N r B φ) : ℝ) ≤ (A : ℝ) ^ P := by
    exact_mod_cast boundedNetworkFunctions_explicit_card_le d N r B φ hφ
  have ha : (A : ℝ) ≤ Real.exp (A : ℝ) := by
    have hh := Real.add_one_le_exp (A : ℝ)
    linarith
  calc
    _ ≤ (A : ℝ) ^ P := hc
    _ ≤ (Real.exp (A : ℝ)) ^ P := pow_le_pow_left₀ (by positivity) ha P
    _ = Real.exp (parameterCapacityExponent d N r B : ℝ) := by
      rw [← Real.exp_nat_mul]
      congr 1
      simp [parameterCapacityExponent, A, P]

/-- A class whose members actually have compressed representatives inherits
the proven capacity bound. The hypothesis is an existence claim for concrete
weights, not a bound on the cardinality being concluded. -/
theorem representedClass_card_le_exp {d : ℕ} (A : Finset (BooleanFunction d))
    (N r B : ℕ) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (hrep : ∀ f ∈ A, ∃ w : Weights d N r,
      w ∈ marginEvent φ (1 / 2) f ∧ boundedWeights B w) :
    (A.card : ℝ) ≤ Real.exp (parameterCapacityExponent d N r B : ℝ) := by
  classical
  let embed : ↥A → BoundedNetworkFunctions d N r B φ :=
    fun f => ⟨f.val, hrep f.val f.property⟩
  have hinj : Function.Injective embed := by
    intro f g h
    apply Subtype.ext
    exact congrArg (fun z : BoundedNetworkFunctions d N r B φ => z.val) h
  have hcard := Fintype.card_le_of_injective embed hinj
  rw [Fintype.card_coe] at hcard
  have hcardR : (A.card : ℝ) ≤ Fintype.card (BoundedNetworkFunctions d N r B φ) := by
    exact_mod_cast hcard
  exact hcardR.trans (boundedNetworkFunctions_card_le_exp d N r B φ hφ)

end NeuralGeneralization.ConcreteModel
