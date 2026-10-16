import NeuralGeneralization.BetaTruncation
import Mathlib.MeasureTheory.Integral.IntervalIntegral.IntegrationByParts

/-! The elementary Poisson clock change of variables used in sharp
kernel eigenvalue estimates. -/
noncomputable section
namespace NeuralGeneralization
open MeasureTheory Set

lemma poissonFlipProbability_hasDerivAt (u : ℝ) :
    HasDerivAt poissonFlipProbability (Real.exp (-2*u)) u := by
  have h := ((hasDerivAt_const u (1 : ℝ)).sub
    (((hasDerivAt_id u).const_mul (-2)).exp)).div_const 2
  convert h using 1 <;> try rfl
  simp only [id_eq]
  ring

lemma poissonFlipProbability_pos {u : ℝ} (hu : 0 < u) :
    0 < poissonFlipProbability u := by
  have h : Real.exp (-2*u) < 1 := by rw [Real.exp_lt_one_iff]; linarith
  unfold poissonFlipProbability
  linarith

lemma poissonFlipProbability_lower {a u : ℝ} (hu : 0 ≤ u) (hua : u ≤ a) :
    u*Real.exp (-2*a) ≤ poissonFlipProbability u := by
  have he := Real.add_one_le_exp (2*u)
  have hh := mul_le_mul_of_nonneg_right he (Real.exp_pos (-2*u)).le
  have hcancel : Real.exp (2*u)*Real.exp (-2*u)=1 := by
    rw [← Real.exp_add,show 2*u+ -2*u=0 by ring,Real.exp_zero]
  rw [hcancel] at hh
  have hmono : Real.exp (-2*a) ≤ Real.exp (-2*u) := by
    apply Real.exp_le_exp.mpr
    linarith
  unfold poissonFlipProbability
  nlinarith [mul_le_mul_of_nonneg_left hmono hu]

lemma poissonFlipProbability_continuous : Continuous poissonFlipProbability := by
  unfold poissonFlipProbability
  fun_prop

/-- Exact finite change of variables, valid even for endpoint-singular
integrands because the clock is monotone. -/
theorem poisson_beta_change (a : ℝ) (ha : 0 ≤ a) (g : ℝ → ℝ) :
    (∫ u : ℝ in Ioo 0 a,g (poissonFlipProbability u)*Real.exp (-2*u)) =
      ∫ p : ℝ in Ioo 0 (poissonFlipProbability a),g p := by
  have h := intervalIntegral.integral_comp_mul_deriv_of_deriv_nonneg
    (a := 0) (b := a) (g := g) poissonFlipProbability_continuous.continuousOn
    (fun u _ => poissonFlipProbability_hasDerivAt u)
    (fun u _ => (Real.exp_pos _).le)
  have hz : poissonFlipProbability 0=0 := by norm_num [poissonFlipProbability]
  rw [hz,intervalIntegral.integral_of_le ha,
    intervalIntegral.integral_of_le (poissonFlipProbability_nonneg ha),
    integral_Ioc_eq_integral_Ioo,integral_Ioc_eq_integral_Ioo] at h
  exact h

/-- Integrability is preserved by the same exact monotone substitution. -/
theorem poisson_beta_integrable_iff (a : ℝ) (ha : 0 ≤ a) (g : ℝ → ℝ) :
    IntegrableOn (fun u => g (poissonFlipProbability u)*Real.exp (-2*u)) (Ioo 0 a) ↔
      IntegrableOn g (Ioo 0 (poissonFlipProbability a)) := by
  have h := intervalIntegral.integrable_comp_mul_deriv_iff_of_deriv_nonneg
    (a := 0) (b := a) (g := g) poissonFlipProbability_continuous.continuousOn
    (fun u _ => poissonFlipProbability_hasDerivAt u)
    (fun u _ => (Real.exp_pos _).le)
  have hz : poissonFlipProbability 0=0 := by norm_num [poissonFlipProbability]
  rw [hz,intervalIntegrable_iff_integrableOn_Ioo_of_le ha,
    intervalIntegrable_iff_integrableOn_Ioo_of_le (poissonFlipProbability_nonneg ha)] at h
  exact h

end NeuralGeneralization
