import CanonicalPicardReadout
import Mathlib.Algebra.Order.Floor.Ring

noncomputable section
set_option maxHeartbeats 3000000
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory Set
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

def canonicalSignPrecision {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) : ℝ :=
  1/(32*((H:ℝ)+1)*(1+‖P.readout‖))

lemma canonicalSignPrecision_pos {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) : 0<canonicalSignPrecision P := by
  unfold canonicalSignPrecision
  positivity

lemma canonicalSignPrecision_le_one {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) : canonicalSignPrecision P≤1 := by
  have hden : 1≤32*((H:ℝ)+1)*(1+‖P.readout‖) := by
    have hr := norm_nonneg P.readout
    have hH := Nat.cast_nonneg (α:=ℝ) H
    nlinarith
  simpa only [canonicalSignPrecision,div_one] using one_div_le_one_div_of_le (by norm_num) hden

lemma canonicalSignPrecision_readout {d H : ℕ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H 1 f) : ‖P.readout‖*canonicalSignPrecision P≤1/32 := by
  unfold canonicalSignPrecision
  rw [mul_one_div]
  apply (div_le_iff₀ (by positivity : 0<32*((H:ℝ)+1)*(1+‖P.readout‖))).mpr
  have hr := norm_nonneg P.readout
  have hH := Nat.cast_nonneg (α:=ℝ) H
  nlinarith

def causalSignIterations (E Λ r : ℝ) : ℕ :=
  ⌈(2*Λ+E+Real.log (384*(1+r)))/Real.log 2⌉₊

def causalSignRounding (E Λ r : ℝ) : ℝ :=
  1/(64*(1+r)*Real.exp (E+Λ))

lemma causalSignRounding_pos (E Λ : ℝ) {r : ℝ} (hr : 0≤r) :
    0<causalSignRounding E Λ r := by unfold causalSignRounding; positivity

lemma causalSignIterations_bound {E Λ r : ℝ} (hE : 0≤E) (hΛ : 0≤Λ) (hr : 0≤r) :
    (causalSignIterations E Λ r:ℝ)≤
      (2*Λ+E+Real.log (384*(1+r)))/Real.log 2+1 := by
  apply (Nat.ceil_lt_add_one ?_).le
  apply div_nonneg _ (Real.log_nonneg (by norm_num))
  exact add_nonneg (by positivity) (Real.log_nonneg (by linarith))

/-- O(E+Λ+log(1+r)) genuinely parallel Picard iterations suffice; the
finite evaluator only needs inverse-exponential-in-these-budgets precision. -/
theorem causalSignBudgets {E Λ r η : ℝ} (hΛ : 0≤Λ) (hr : 0≤r)
    (hη : 0≤η) (hη1 : η≤1) :
    Real.exp E*r*((4+2*η)*Λ^(causalSignIterations E Λ r)/
        ((causalSignIterations E Λ r).factorial:ℝ)+
      causalSignRounding E Λ r*Real.exp Λ)≤1/32 := by
  let k := causalSignIterations E Λ r
  have hlog : 0<Real.log 2 := Real.log_pos (by norm_num)
  have hk : 2*Λ+E+Real.log (384*(1+r))≤(k:ℝ)*Real.log 2 := by
    have hh := Nat.le_ceil ((2*Λ+E+Real.log (384*(1+r)))/Real.log 2)
    exact (div_le_iff₀ hlog).mp hh
  have he : Real.exp (E+2*Λ-(k:ℝ)*Real.log 2)≤1/(384*(1+r)) := by
    have hh := Real.exp_le_exp.mpr (show E+2*Λ-(k:ℝ)*Real.log 2≤
      -Real.log (384*(1+r)) by linarith)
    simpa only [Real.exp_neg,Real.exp_log (by positivity : 0<384*(1+r)),one_div] using hh
  have htail := factorial_tail_le_exponential hΛ (by positivity : 0≤4+2*η) k
  have hfirst : Real.exp E*r*((4+2*η)*Λ^k/(k.factorial:ℝ))≤1/64 := by
    calc
      _ ≤ Real.exp E*r*((4+2*η)*Real.exp (2*Λ-(k:ℝ)*Real.log 2)) :=
        mul_le_mul_of_nonneg_left htail (mul_nonneg (Real.exp_nonneg _) hr)
      _ = r*(4+2*η)*Real.exp (E+2*Λ-(k:ℝ)*Real.log 2) := by
        rw [show E+2*Λ-(k:ℝ)*Real.log 2=E+(2*Λ-(k:ℝ)*Real.log 2) by ring,Real.exp_add]
        ring
      _ ≤ r*(4+2*η)*(1/(384*(1+r))) :=
        mul_le_mul_of_nonneg_left he (by positivity)
      _ ≤ 1/64 := by
        rw [mul_one_div]
        apply (div_le_iff₀ (by positivity : 0<384*(1+r))).mpr
        nlinarith
  have hsecond : Real.exp E*r*(causalSignRounding E Λ r*Real.exp Λ)≤1/64 := by
    have he0 : Real.exp E≠0 := (Real.exp_pos E).ne'
    have he1 : Real.exp Λ≠0 := (Real.exp_pos Λ).ne'
    have hr1 : 1+r≠0 := by positivity
    have hid : Real.exp E*r*(causalSignRounding E Λ r*Real.exp Λ)=r/(64*(1+r)) := by
      unfold causalSignRounding
      rw [Real.exp_add]
      field_simp
    rw [hid]
    apply (div_le_iff₀ (by positivity : 0<64*(1+r))).mpr
    linarith
  rw [mul_add]
  exact (add_le_add hfirst hsecond).trans_eq (by norm_num)

#print axioms causalSignBudgets
end ConditionalNonpolynomial.Analytic
