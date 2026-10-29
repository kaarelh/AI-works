import PhysicalShortReadout
import CanonicalSignBudgets

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel

def canonicalSignPrecision {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : ℝ :=
  1/(32*((H:ℝ)+1)*(1+‖P.readout‖))

lemma canonicalSignPrecision_pos {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : 0<canonicalSignPrecision P := by
  unfold canonicalSignPrecision
  positivity

lemma canonicalSignPrecision_le_one {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : canonicalSignPrecision P≤1 := by
  have hden : 1≤32*((H:ℝ)+1)*(1+‖P.readout‖) := by
    have hr := norm_nonneg P.readout
    have hH := Nat.cast_nonneg (α:=ℝ) H
    nlinarith
  simpa only [canonicalSignPrecision,div_one] using one_div_le_one_div_of_le (by norm_num) hden

lemma canonicalSignPrecision_readout {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : ‖P.readout‖*canonicalSignPrecision P≤1/32 := by
  unfold canonicalSignPrecision
  rw [mul_one_div]
  apply (div_le_iff₀ (by positivity : 0<32*((H:ℝ)+1)*(1+‖P.readout‖))).mpr
  have hr := norm_nonneg P.readout
  have hH := Nat.cast_nonneg (α:=ℝ) H
  nlinarith

end ConditionalNonpolynomial.Analytic.PhysicalShort
