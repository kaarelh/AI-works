import PhysicalShortSign

noncomputable section
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic.PhysicalShort
open NeuralGeneralization.ConcreteModel

 theorem canonicalSignRounding_pos_bound {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : 0<canonicalSignRounding P :=
  causalSignRounding_pos _ _ (norm_nonneg _)

 theorem canonicalSignRounding_small {d H : ℕ} {t : ℝ} {f : BooleanFunction d}
    (P : ControlledMarginPath d H t f) : canonicalSignRounding P≤1/64 := by
  have hE:0≤canonicalEntropySum P:=by
    unfold canonicalEntropySum
    exact Finset.sum_nonneg (fun j _=>Real.sqrt_nonneg _)
  have hL:=canonicalNonlinearBudget_nonneg P (canonicalSignPrecision P)
  have he:1≤Real.exp (canonicalEntropySum P+canonicalNonlinearBudget P (canonicalSignPrecision P)):=
    Real.one_le_exp (by linarith)
  have hr:=norm_nonneg P.readout
  have hden:64≤64*(1+‖P.readout‖)*Real.exp (canonicalEntropySum P+canonicalNonlinearBudget P (canonicalSignPrecision P)):=by
    nlinarith [mul_nonneg hr (sub_nonneg.mpr he)]
  exact one_div_le_one_div_of_le (by norm_num) hden


#print axioms canonicalSignRounding_small
end ConditionalNonpolynomial.Analytic.PhysicalShort
