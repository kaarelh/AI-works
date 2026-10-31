import NeuralGeneralization.BatchTwoQuadraticEnvelopeRate
import Mathlib.Topology.Order.Compact

/-! Continuous positive coordinate densities with a common quadratic log-tail
coefficient give global Gaussian envelopes with arbitrarily close exponents.
The compact-region constants are derived, not assumed. -/
noncomputable section
open MeasureTheory ProbabilityTheory Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.QuadraticTail
open ConcreteModel

theorem quadratic_remainder_bound {V : ℝ → ℝ} (hV : Continuous V) (a : ℝ)
    (hplus : Tendsto (fun x => V x / x^2) atTop (𝓝 a))
    (hminus : Tendsto (fun x => V x / x^2) atBot (𝓝 a))
    {ε : ℝ} (hε : 0 < ε) :
    ∃ B : ℝ, 0 ≤ B ∧ ∀ x : ℝ, |V x - a*x^2| ≤ ε*x^2+B := by
  have hp := ((tendsto_order.mp hplus).1 (a-ε) (by linarith)).and
    ((tendsto_order.mp hplus).2 (a+ε) (by linarith))
  have hm := ((tendsto_order.mp hminus).1 (a-ε) (by linarith)).and
    ((tendsto_order.mp hminus).2 (a+ε) (by linarith))
  obtain ⟨u, hu⟩ := eventually_atTop.mp hp
  obtain ⟨l, hl⟩ := eventually_atBot.mp hm
  let R := max 1 (max |u| |l|)
  have hR : 1 ≤ R := le_max_left _ _
  have huR : u ≤ R := (le_abs_self u).trans ((le_max_left _ _).trans (le_max_right _ _))
  have hlR : -R ≤ l := by
    have hh : |l| ≤ R := (le_max_right _ _).trans (le_max_right _ _)
    have hh' := neg_abs_le l
    linarith
  have hc : Continuous (fun x => |V x-a*x^2|) := by fun_prop
  obtain ⟨z, hz, hmax⟩ := isCompact_Icc.exists_isMaxOn
    (Set.nonempty_Icc.mpr (by linarith : -R ≤ R)) hc.continuousOn
  refine ⟨|V z-a*z^2|, abs_nonneg _, fun x => ?_⟩
  by_cases hin : x ∈ Set.Icc (-R) R
  · exact (hmax hin).trans (by nlinarith [sq_nonneg x])
  have hout : x < -R ∨ R < x := by simpa only [Set.mem_Icc, not_and_or, not_le] using hin
  have hx : x ≠ 0 := by rcases hout with h | h <;> linarith
  have htail : a-ε < V x/x^2 ∧ V x/x^2 < a+ε := by
    rcases hout with h | h
    · exact hl x (h.le.trans hlR)
    · exact hu x (huR.trans h.le)
  have hlow := (lt_div_iff₀ (sq_pos_of_ne_zero hx)).mp htail.1
  have hhigh := (div_lt_iff₀ (sq_pos_of_ne_zero hx)).mp htail.2
  apply (abs_le.mpr ⟨by nlinarith, by nlinarith⟩ : |V x-a*x^2| ≤ ε*x^2).trans
  exact le_add_of_nonneg_right (abs_nonneg _)

structure Coordinate (a : ℝ) where
  law : Measure ℝ
  probability : IsProbabilityMeasure law
  density : ℝ → ℝ
  continuous_density : Continuous density
  positive_density : ∀ x, 0 < density x
  integrable_density : Integrable density
  density_eq : law = volume.withDensity (fun x => ENNReal.ofReal (density x))
  positive_tail : Tendsto (fun x => -Real.log (density x) / x^2) atTop (𝓝 a)
  negative_tail : Tendsto (fun x => -Real.log (density x) / x^2) atBot (𝓝 a)
attribute [instance] Coordinate.probability

theorem Coordinate.exists_envelope {a ε : ℝ} (ν : Coordinate a) (hε : 0 < ε) :
    ∃ L U : ℝ, 0 < L ∧ 0 < U ∧
      (∀ x, L*Real.exp (-(a+ε)*x^2) ≤ ν.density x) ∧
      (∀ x, ν.density x ≤ U*Real.exp (-(a-ε)*x^2)) := by
  have hV : Continuous (fun x => -Real.log (ν.density x)) :=
    (ν.continuous_density.log (fun x => (ν.positive_density x).ne')).neg
  obtain ⟨B, hB, hb⟩ := quadratic_remainder_bound hV a ν.positive_tail ν.negative_tail hε
  refine ⟨Real.exp (-B), Real.exp B, Real.exp_pos _, Real.exp_pos _, ?_, ?_⟩
  · intro x
    rw [←Real.exp_add, ←Real.exp_log (ν.positive_density x)]
    apply Real.exp_le_exp.mpr
    have hh := (abs_le.mp (hb x)).2
    nlinarith
  · intro x
    rw [←Real.exp_add, ←Real.exp_log (ν.positive_density x)]
    apply Real.exp_le_exp.mpr
    have hh := (abs_le.mp (hb x)).1
    nlinarith

def Coordinate.envelope {a ε : ℝ} (ν : Coordinate a) (hε : 0 < ε) :
    QuadraticEnvelope.Coordinate (2*(a-ε)) (2*(a+ε)) :=
  let h := ν.exists_envelope hε
  { law := ν.law
    probability := ν.probability
    density := ν.density
    measurable_density := ν.continuous_density.measurable
    integrable_density := ν.integrable_density
    density_nonneg := fun x => (ν.positive_density x).le
    density_eq := ν.density_eq
    lowerFactor := h.choose
    upperFactor := h.choose_spec.choose
    lowerFactor_pos := h.choose_spec.choose_spec.1
    upperFactor_pos := h.choose_spec.choose_spec.2.1
    lower := by simpa only [mul_div_cancel_left₀ _ (by norm_num : (2:ℝ)≠0)] using h.choose_spec.choose_spec.2.2.1
    upper := by simpa only [mul_div_cancel_left₀ _ (by norm_num : (2:ℝ)≠0)] using h.choose_spec.choose_spec.2.2.2 }

def smallPrior {d N r : ℕ} {a : ℝ} (ν : WeightIndex d N r → Coordinate a) (σ : ℝ) :
    Measure (Weights d N r) :=
  (Measure.pi fun i => (ν i).law).map (fun u i => BatchTwoNonGaussian.smallScale d N r σ i*u i)

@[simp] theorem envelope_smallPrior {d N r : ℕ} {a ε : ℝ}
    (ν : WeightIndex d N r → Coordinate a) (hε : 0 < ε) (σ : ℝ) :
    QuadraticEnvelope.smallPrior (fun i => (ν i).envelope hε) σ = smallPrior ν σ := rfl

end NeuralGeneralization.QuadraticTail
