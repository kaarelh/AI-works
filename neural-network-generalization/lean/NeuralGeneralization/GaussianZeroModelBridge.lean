import NeuralGeneralization.GaussianZeroDeterministic
import NeuralGeneralization.GaussianSignPosteriorBridge
import NeuralGeneralization.ParityModelBridge

/-! # Exact function-posterior convention at the fixed-margin endpoint -/
noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators
namespace NeuralGeneralization.GaussianZeroModelBridge
open ConcreteModel FieldPosteriorBridge GaussianFieldTilt GaussianSignPosteriorBridge
variable {d n : ℕ}

lemma walshFunctionMass_eq_plain_fieldMass (w : Finset (Fin d) → ℝ) (a : ℝ) (g : BooleanFunction d) :
    walshFunctionMass w a g = fieldMass (fieldLaw (WalshGaussianEnergy.matrix w)) id a g := by
  rw [walshFunctionMass, measureReal_def, ← WalshGaussianEnergy.map_toLp_fieldLaw,
    Measure.map_apply (WithLp.measurable_toLp 2 _) (WalshGaussianLaw.isOpen_orthant g a).measurableSet]
  rfl

lemma conditioning_probability_ne_zero (w : Finset (Fin d) → ℝ) (hw : ∀ S, 0 < w S)
    {a : ℝ} (ha : 0 ≤ a) (f : BooleanFunction d) (s : Fin n → Cube d) :
    fieldLaw (WalshGaussianEnergy.matrix w) (conditioningEvent id a f s) ≠ 0 := by
  have hp : 0 < fieldMass (fieldLaw (WalshGaussianEnergy.matrix w)) id a f := by
    rw [← walshFunctionMass_eq_plain_fieldMass]
    exact ENNReal.toReal_pos (WalshGaussianLaw.orthant_pos w hw f a).ne' (measure_ne_top _ _)
  have hsub : fieldOrthant (id : (Cube d → ℝ) → Cube d → ℝ) a f ⊆ conditioningEvent id a f s := by
    intro z hz
    exact ⟨orthant_subset_global id a f hz, fun j => ha.trans_lt (hz (s j))⟩
  intro hh
  have hzero := measure_mono_null hsub hh
  simp only [fieldMass, measureReal_def, hzero, ENNReal.toReal_zero, lt_self_iff_false] at hp

/-- The actual finite function posterior equals the posterior sign
probability of the whole conditioned Gaussian field, including global margin. -/
theorem correctConfidence_eq_plain_conditional (w : Finset (Fin d) → ℝ)
    {a : ℝ} (ha : 0 ≤ a) (s : Fin n → Cube d) (x : Cube d) :
    correctConfidence (parity d) (posterior (walshFunctionMass w a) (consistent (parity d) s)) x =
      GaussianMarginConfidence.confidence
        (cond (fieldLaw (WalshGaussianEnergy.matrix w)) (conditioningEvent id a (parity d) s)) x := by
  have he : walshFunctionMass w a=fieldMass (fieldLaw (WalshGaussianEnergy.matrix w)) id a :=
    funext (walshFunctionMass_eq_plain_fieldMass w a)
  rw [he, correctConfidence_eq_conditional _ id (fun x => measurable_pi_apply x) ha]
  simp only [correctEvent, GaussianMarginConfidence.confidence, id_eq, labelReal_parity]

/-- Buffered confidence failure of the actual fixed-margin neural Gaussian
posterior is precisely the deterministic endpoint's quantity. -/
theorem buffered_failure_eq (w : Finset (Fin d) → ℝ) {a : ℝ} (ha : 0 ≤ a)
    (s : Fin n → Cube d) (theta : ℝ) :
    ConfidenceClipping.failure
      (correctConfidence (parity d) (posterior (walshFunctionMass w a) (consistent (parity d) s))) theta =
    ConfidenceClipping.failure
      (GaussianMarginConfidence.confidence
        (cond (fieldLaw (WalshGaussianEnergy.matrix w)) (conditioningEvent id a (parity d) s))) theta := by
  congr 1
  exact funext (correctConfidence_eq_plain_conditional w ha s)

end NeuralGeneralization.GaussianZeroModelBridge
