import NeuralGeneralization.BoundedObservables
import NeuralGeneralization.IIDLaw
import Mathlib.MeasureTheory.Integral.Pi

/-!
# Fixed empirical dual tests under the actual IID product law

Samples have their actual IID product law. A fixed dual test is a product
of normalized exponential-tilt densities, hence has exponential expectation
exactly one. The bad event is measurable even though its definition
quantifies over a continuum of dual parameters.
-/

noncomputable section

open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.DualCertificate

open BoundedDual BoundedTilt ActualBoundedDual CompressionSampling

variable {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι] [DecidableEq ι] [Nonempty ι]

def empirical (T : ι → Ω → ℝ) {N : ℕ} (a : Fin N → Ω) (i : ι) : ℝ :=
  (∑ j, T i (a j)) / (N : ℝ)

omit [MeasurableSpace Ω] [DecidableEq ι] [Nonempty ι] in
theorem scaled_pairing_empirical (T : ι → Ω → ℝ) {N : ℕ} (hN : 0 < N)
    (a : Fin N → Ω) (v : ι → ℝ) :
    (N : ℝ) * pairing v (empirical T a) = ∑ j, potential T v (a j) := by
  have hNR : (N : ℝ) ≠ 0 := by exact_mod_cast hN.ne'
  simp only [pairing, empirical, ← mul_div_assoc, ← Finset.sum_div]
  rw [mul_div_cancel_left₀ _ hNR]
  simp only [Finset.mul_sum]
  rw [Finset.sum_comm]
  rfl

variable (μ : Measure Ω) [IsProbabilityMeasure μ]

omit [DecidableEq ι] [Nonempty ι] in
theorem exp_objective_eq_product_density
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {N : ℕ} (hN : 0 < N)
    (a : Fin N → Ω) (v : ι → ℝ) :
    Real.exp ((N : ℝ) * objective μ T (empirical T a) v) =
      ∏ j, density μ (potential T v) (a j) := by
  have hZ := partition_pos μ (potential T v) (measurable_potential T hT v)
    (potential_bound T hbound v)
  have hexponent : (N : ℝ) * objective μ T (empirical T a) v =
      ∑ j, (potential T v (a j) - Real.log (partition μ (potential T v))) := by
    unfold objective
    rw [mul_sub, scaled_pairing_empirical T hN a v, Finset.sum_sub_distrib]
    simp only [Finset.sum_const, Finset.card_univ, Fintype.card_fin, nsmul_eq_mul]
  rw [hexponent, Real.exp_sum]
  apply Finset.prod_congr rfl
  intro j hj
  rw [Real.exp_sub, Real.exp_log hZ]
  rfl

omit [DecidableEq ι] [Nonempty ι] in
theorem integrable_exp_objective
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {N : ℕ} (hN : 0 < N) (v : ι → ℝ) :
    Integrable (fun a : Fin N → Ω => Real.exp ((N : ℝ) * objective μ T (empirical T a) v))
      (iidSamples μ N) := by
  simp_rw [exp_objective_eq_product_density μ T hT hbound hN]
  exact Integrable.fintype_prod (fun _ => integrable_density μ _
    (measurable_potential T hT v) (potential_bound T hbound v))

omit [DecidableEq ι] [Nonempty ι] in
theorem integral_exp_objective_eq_one
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {N : ℕ} (hN : 0 < N) (v : ι → ℝ) :
    (∫ a, Real.exp ((N : ℝ) * objective μ T (empirical T a) v) ∂iidSamples μ N) = 1 := by
  simp_rw [exp_objective_eq_product_density μ T hT hbound hN]
  rw [iidSamples, integral_fintype_prod_eq_prod]
  simp only [integral_density μ _ (measurable_potential T hT v)
    (potential_bound T hbound v), Finset.prod_const_one]

omit [DecidableEq ι] [Nonempty ι] in
theorem fixed_test_tail
    (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) {N : ℕ} (hN : 0 < N) (v : ι → ℝ) (t : ℝ) :
    (iidSamples μ N).real {a | t < objective μ T (empirical T a) v} ≤
      Real.exp (-(N : ℝ) * t) := by
  have hNR : 0 < (N : ℝ) := by exact_mod_cast hN
  have h := mul_meas_ge_le_integral_of_nonneg
    (μ := iidSamples μ N)
    (f := fun a => Real.exp ((N : ℝ) * objective μ T (empirical T a) v))
    (ae_of_all _ (fun _ => (Real.exp_pos _).le))
    (integrable_exp_objective μ T hT hbound hN v) (Real.exp ((N : ℝ) * t))
  rw [integral_exp_objective_eq_one μ T hT hbound hN v] at h
  have hMarkov := (le_div_iff₀ (Real.exp_pos ((N : ℝ) * t))).2
    (show (iidSamples μ N).real
      {a | Real.exp ((N : ℝ) * t) ≤ Real.exp ((N : ℝ) * objective μ T (empirical T a) v)} *
        Real.exp ((N : ℝ) * t) ≤ 1 by simpa only [mul_comm] using h)
  calc
    (iidSamples μ N).real {a | t < objective μ T (empirical T a) v} ≤
        (iidSamples μ N).real
          {a | Real.exp ((N : ℝ) * t) ≤ Real.exp ((N : ℝ) * objective μ T (empirical T a) v)} := by
      apply measureReal_mono _ (measure_ne_top _ _)
      intro a ha
      exact Real.exp_le_exp.mpr (mul_le_mul_of_nonneg_left ha.le hNR.le)
    _ ≤ 1 / Real.exp ((N : ℝ) * t) := hMarkov
    _ = Real.exp (-(N : ℝ) * t) := by rw [one_div, ← Real.exp_neg]; congr 1; ring

/-- Failure means that some parameter in the bounded ball beats the threshold. -/
def badEvent (T : ι → Ω → ℝ) (N : ℕ) (G K : ℝ) : Set (Fin N → Ω) :=
  {a | ∃ lam : ι → ℝ, entryL1 lam ≤ G ∧ K < objective μ T (empirical T a) lam}

omit [DecidableEq ι] [Nonempty ι] [IsProbabilityMeasure μ] in
/-- Although the bad event quantifies over a continuum of dual parameters,
it is measurable: it is the preimage of an open subset of moment space. -/
theorem measurableSet_badEvent (T : ι → Ω → ℝ)
    (hT : ∀ i, Measurable (T i)) (N : ℕ) (G K : ℝ) :
    MeasurableSet (badEvent μ T N G K) := by
  have hem : Measurable (fun a : Fin N → Ω => empirical T a) := by
    apply measurable_pi_lambda
    intro i
    exact (Finset.measurable_fun_sum Finset.univ
      (fun j _ => (hT i).comp (measurable_pi_apply j))).div_const (N : ℝ)
  let R : Set (ι → ℝ) := {q | ∃ v : ι → ℝ, entryL1 v ≤ G ∧ K < objective μ T q v}
  have hR : IsOpen R := by
    have heq : R = ⋃ v : ι → ℝ, ⋃ _hv : entryL1 v ≤ G,
        {q : ι → ℝ | K < objective μ T q v} := by
      ext q
      simp [R]
    rw [heq]
    apply isOpen_iUnion
    intro v
    apply isOpen_iUnion
    intro hv
    apply isOpen_lt continuous_const
    exact (continuous_finsetSum _
      (fun i _ => continuous_const.mul (continuous_apply i))).sub continuous_const
  exact hR.measurableSet.preimage hem

end NeuralGeneralization.DualCertificate

end
