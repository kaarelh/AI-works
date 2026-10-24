import NeuralGeneralization.BatchTwoRelativeGrowthPatternUnion

/-! Relative growth bound with the manuscript's logarithmic sample budget. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory Set
namespace NeuralGeneralization.BatchTwoRelativeGrowth
open CompressionSampling
variable {X H : Type*} [Fintype X] [MeasurableSpace X] [MeasurableSingletonClass X] [Fintype H]

theorem relative_growth_good_probability_log (D : Measure X) [IsProbabilityMeasure D]
    (a : H → X → Bool) (n : ℕ) (hn : 0 < n) {u E δ : ℝ}
    (hδ : 0 < δ) (hδ1 : δ < 1) (hE : 0 ≤ E)
    (hP : ∀ p : (Fin n → X) × (Fin n → X), ((pairedPatterns a p).card : ℝ) ≤ Real.exp E)
    (hbudget : 32*(E+Real.log (4/δ)) ≤ (n : ℝ)*u) :
    1-δ ≤ (iidSamples D n).real (badSample D a n u)ᶜ := by
  have hl2 : 0 < Real.log 2 := Real.log_pos (by norm_num)
  have hratio : (2 : ℝ) ≤ 4/δ := (le_div_iff₀ hδ).mpr (by linarith)
  have hl : Real.log 2 ≤ Real.log (4/δ) := Real.log_le_log (by norm_num) hratio
  have hlog : 0 ≤ Real.log (4/δ) := by linarith
  have hu : 32*Real.log 2 ≤ (n : ℝ)*u := by linarith
  have htail := relative_growth_tail D a n hn hu (Real.exp E) hP
  have hexp : E-(6 : ℝ)/25*n*u ≤ -Real.log (4/δ) := by nlinarith
  have he := Real.exp_le_exp.mpr hexp
  have hid : 2*Real.exp (-Real.log (4/δ)) = δ/2 := by
    rw [Real.exp_neg, Real.exp_log (by positivity)]
    field_simp
    <;> norm_num
  have htail' : (iidSamples D n).real (badSample D a n u) ≤ δ := by
    calc
      _ ≤ 2*Real.exp E*Real.exp (-(6 : ℝ)/25*n*u) := htail
      _ = 2*Real.exp (E-(6 : ℝ)/25*n*u) := by
        rw [mul_assoc, ← Real.exp_add]
        congr 2
        ring
      _ ≤ 2*Real.exp (-Real.log (4/δ)) := mul_le_mul_of_nonneg_left he (by norm_num)
      _ = δ/2 := hid
      _ ≤ δ := by linarith
  rw [probReal_compl_eq_one_sub (Set.toFinite (badSample D a n u)).measurableSet]
  linarith

end NeuralGeneralization.BatchTwoRelativeGrowth
