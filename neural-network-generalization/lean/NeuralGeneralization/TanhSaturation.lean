import NeuralGeneralization.Activation
import Mathlib.Analysis.SpecialFunctions.Exp
import Mathlib.Data.Real.Sign
import Mathlib.MeasureTheory.Integral.DominatedConvergence
import Mathlib.Topology.Algebra.Order.Field
import Mathlib.Tactic.FieldSimp

/-!
# Saturation of tanh in the diverging-variance regime

The argument works for jointly coupled preactivations, not just fixed inputs.
Consequently it applies along convergent covariance square-root couplings,
including singular joint Gaussian limits with nonzero scalar variances.
-/

noncomputable section
open Filter MeasureTheory
open scoped Topology

namespace NeuralGeneralization.TanhSaturation

theorem tanh_exp_formula (x : ℝ) :
    Real.tanh x = 1 - 2 / (Real.exp (2 * x) + 1) := by
  rw [Real.tanh_eq, Real.exp_neg]
  have hexp : Real.exp (2 * x) = Real.exp x ^ 2 := by
    rw [two_mul, Real.exp_add, pow_two]
  rw [hexp]
  have hp := Real.exp_pos x
  have hp' : 0 < Real.exp x ^ 2 + 1 := by positivity
  field_simp
  ring

theorem tendsto_tanh_atTop : Tendsto Real.tanh atTop (𝓝 (1 : ℝ)) := by
  have he : Tendsto (fun x : ℝ => Real.exp (2 * x) + 1) atTop atTop :=
    tendsto_atTop_add_const_right _ _
      (Real.tendsto_exp_atTop.comp (tendsto_id.const_mul_atTop (by norm_num)))
  have hh : Tendsto (fun x : ℝ => 1 - 2 / (Real.exp (2 * x) + 1)) atTop (𝓝 (1 : ℝ)) := by
    simpa using (tendsto_const_nhds.sub (tendsto_const_nhds.div_atTop he))
  simpa only [← tanh_exp_formula] using hh

/-- The preactivation itself may vary with width. Nonzero limiting scalar
values suffice; no uniform lower bound across all samples is assumed. -/
theorem tendsto_tanh_scaled {ι : Type*} {l : Filter ι} {s u : ι → ℝ} {a : ℝ}
    (hs : Tendsto s l atTop) (hu : Tendsto u l (𝓝 a)) (ha : a ≠ 0) :
    Tendsto (fun i => Real.tanh (s i * u i)) l (𝓝 (Real.sign a)) := by
  rcases ha.lt_or_gt with ha | ha
  · have hh := tendsto_tanh_atTop.comp (hs.atTop_mul_pos (neg_pos.mpr ha) hu.neg)
    simpa only [Function.comp_def, mul_neg, Real.tanh_neg, Real.sign_of_neg ha, neg_neg] using hh.neg
  · rw [Real.sign_of_pos ha]
    exact tendsto_tanh_atTop.comp (hs.atTop_mul_pos ha hu)

theorem tendsto_sign {ι : Type*} {l : Filter ι} {u : ι → ℝ} {a : ℝ}
    (hu : Tendsto u l (𝓝 a)) (ha : a ≠ 0) :
    Tendsto (fun i => Real.sign (u i)) l (𝓝 (Real.sign a)) := by
  rcases ha.lt_or_gt with ha | ha
  · rw [Real.sign_of_neg ha]
    apply tendsto_const_nhds.congr'
    filter_upwards [hu.eventually (Iio_mem_nhds ha)] with i hi
    exact (Real.sign_of_neg hi).symm
  · rw [Real.sign_of_pos ha]
    apply tendsto_const_nhds.congr'
    filter_upwards [hu.eventually (Ioi_mem_nhds ha)] with i hi
    exact (Real.sign_of_pos hi).symm

@[fun_prop] theorem measurable_sign : Measurable Real.sign := by
  unfold Real.sign
  exact Measurable.ite (measurableSet_lt measurable_id measurable_const) measurable_const
    (Measurable.ite (measurableSet_lt measurable_const measurable_id) measurable_const measurable_const)

theorem abs_sign_le_one (x : ℝ) : |Real.sign x| ≤ 1 := by
  rcases Real.sign_apply_eq x with h | h | h <;> simp only [h] <;> norm_num

/-- Continuity of sign moments follows from actual null scalar boundaries;
singularity of the joint distribution causes no problem. -/
theorem tendsto_sign_product_integral {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsFiniteMeasure μ]
    {U V : ℕ → Ω → ℝ} {u v : Ω → ℝ}
    (hU : ∀ n, Measurable (U n)) (hV : ∀ n, Measurable (V n))
    (hu : ∀ᵐ ω ∂μ, Tendsto (fun n => U n ω) atTop (𝓝 (u ω)))
    (hv : ∀ᵐ ω ∂μ, Tendsto (fun n => V n ω) atTop (𝓝 (v ω)))
    (hu0 : ∀ᵐ ω ∂μ, u ω ≠ 0) (hv0 : ∀ᵐ ω ∂μ, v ω ≠ 0) :
    Tendsto (fun n => ∫ ω, Real.sign (U n ω) * Real.sign (V n ω) ∂μ)
      atTop (𝓝 (∫ ω, Real.sign (u ω) * Real.sign (v ω) ∂μ)) := by
  apply tendsto_integral_of_dominated_convergence (fun _ => (1 : ℝ))
  · intro n
    exact ((measurable_sign.comp (hU n)).mul (measurable_sign.comp (hV n))).aestronglyMeasurable
  · exact integrable_const 1
  · intro n
    apply ae_of_all
    intro ω
    rw [Real.norm_eq_abs, abs_mul]
    exact (mul_le_mul (abs_sign_le_one _) (abs_sign_le_one _)
      (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)
  · filter_upwards [hu, hv, hu0, hv0] with ω hωu hωv hωu0 hωv0
    exact (tendsto_sign hωu hωu0).mul (tendsto_sign hωv hωv0)

/-- Dominated convergence for the actual pairwise covariance observable.
The two coordinates may be dependent and the joint law may be singular. -/
theorem tendsto_tanh_product_integral {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsFiniteMeasure μ] {s : ℕ → ℝ}
    {U V : ℕ → Ω → ℝ} {u v : Ω → ℝ}
    (hs : Tendsto s atTop atTop) (hU : ∀ n, Measurable (U n))
    (hV : ∀ n, Measurable (V n))
    (hu : ∀ᵐ ω ∂μ, Tendsto (fun n => U n ω) atTop (𝓝 (u ω)))
    (hv : ∀ᵐ ω ∂μ, Tendsto (fun n => V n ω) atTop (𝓝 (v ω)))
    (hu0 : ∀ᵐ ω ∂μ, u ω ≠ 0) (hv0 : ∀ᵐ ω ∂μ, v ω ≠ 0) :
    Tendsto (fun n => ∫ ω, Real.tanh (s n * U n ω) * Real.tanh (s n * V n ω) ∂μ)
      atTop (𝓝 (∫ ω, Real.sign (u ω) * Real.sign (v ω) ∂μ)) := by
  apply tendsto_integral_of_dominated_convergence (fun _ => (1 : ℝ))
  · intro n
    exact (((ConcreteModel.tanh_lipschitzWith.continuous.measurable).comp
      ((hU n).const_mul (s n))).mul
      ((ConcreteModel.tanh_lipschitzWith.continuous.measurable).comp
        ((hV n).const_mul (s n)))).aestronglyMeasurable
  · exact integrable_const 1
  · intro n
    apply ae_of_all
    intro ω
    rw [Real.norm_eq_abs, abs_mul]
    exact (mul_le_mul (Real.abs_tanh_lt_one _).le (Real.abs_tanh_lt_one _).le
      (abs_nonneg _) (by norm_num)).trans_eq (one_mul _)
  · filter_upwards [hu, hv, hu0, hv0] with ω hωu hωv hωu0 hωv0
    exact (tendsto_tanh_scaled hs hωu hωu0).mul (tendsto_tanh_scaled hs hωv hωv0)

end NeuralGeneralization.TanhSaturation
