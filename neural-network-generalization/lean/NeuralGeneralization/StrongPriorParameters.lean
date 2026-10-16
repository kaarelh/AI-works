import NeuralGeneralization.CapacityBound
import NeuralGeneralization.CompressionWidth
import NeuralGeneralization.PolynomialGrowth

/-! # Explicit polynomial parameters for strong-prior learning -/

namespace NeuralGeneralization
open ConcreteModel CompressionSampling

/-- One unit of slack turns the infimum energy bound into an actual witness. -/
def strongEnergyBudget (d r C : ℕ) : ℕ :=
  2 * (d * (d + 1) * C ^ 2 + (r + 1) * C ^ 4) + 1

def strongCompressionWidth (d r C : ℕ) : ℕ :=
  compressionWidth d r (strongEnergyBudget d r C)

def strongCapacity (d r C : ℕ) : ℕ :=
  parameterCapacityExponent d (strongCompressionWidth d r C) r
    (strongCompressionWidth d r C)

/-- All constants in the final sample bound are polynomial at each fixed depth. -/
theorem strongCapacity_polynomialGrowth (r : ℕ) :
    PolynomialGrowth2 (fun d C => strongCapacity d r C) := by
  have hK : PolynomialGrowth2 (fun d C => strongEnergyBudget d r C) := by
    unfold strongEnergyBudget
    exact ((PolynomialGrowth2.const 2).mul
      (((PolynomialGrowth2.left.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).mul
        (PolynomialGrowth2.right.pow 2)).add
          ((PolynomialGrowth2.const (r + 1)).mul (PolynomialGrowth2.right.pow 4)))).add
            (PolynomialGrowth2.const 1)
  have hQ : PolynomialGrowth2 (fun d C => compressionQ r (strongEnergyBudget d r C)) := by
    unfold compressionQ
    exact ((PolynomialGrowth2.const 24).mul (PolynomialGrowth2.const (r + 1))).mul
      (((PolynomialGrowth2.const 4).mul hK).pow (r + 1))
  have hM : PolynomialGrowth2 (fun d C => strongCompressionWidth d r C) := by
    unfold strongCompressionWidth compressionWidth
    exact ((((PolynomialGrowth2.const 65536).mul (PolynomialGrowth2.const (r + 1))).mul
      (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).mul (hQ.pow 8)).add
        ((PolynomialGrowth2.const 9).mul hK)
  have hdim : PolynomialGrowth2 (fun d C =>
      strongCompressionWidth d r C * (d + 1) +
      r * (strongCompressionWidth d r C * strongCompressionWidth d r C) +
      strongCompressionWidth d r C) :=
    ((hM.mul (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1))).add
      ((PolynomialGrowth2.const r).mul (hM.mul hM))).add hM
  have hmesh : PolynomialGrowth2 (fun d C => (d + 1) *
      (strongCompressionWidth d r C * (strongCompressionWidth d r C + 1) + 1) ^ (r + 1)) :=
    (PolynomialGrowth2.left.add (PolynomialGrowth2.const 1)).mul
      (((hM.mul (hM.add (PolynomialGrowth2.const 1))).add
        (PolynomialGrowth2.const 1)).pow (r + 1))
  simpa only [strongCapacity, parameterCapacityExponent_eq] using
    hdim.mul (((PolynomialGrowth2.const 2).mul (hM.mul hmesh)).add (PolynomialGrowth2.const 1))


end NeuralGeneralization
