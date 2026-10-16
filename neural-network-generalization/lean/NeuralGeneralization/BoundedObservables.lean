import NeuralGeneralization.BoundedDualOptimality
import NeuralGeneralization.BoundedTilt

/-!
# Actual exponential families of finite bounded observables

This module defines the genuine exponential family of finite bounded
observables and proves its continuity and entropy identities. It is
independent of Gaussian nondegeneracy. The Gaussian covariance application
sets the observables to products of bounded activations.
-/

noncomputable section

open MeasureTheory
open scoped BigOperators

namespace NeuralGeneralization.ActualBoundedDual

open BoundedDual BoundedTilt

variable {Ω ι : Type*} [MeasurableSpace Ω] [Fintype ι] [DecidableEq ι] [Nonempty ι]

def potential (T : ι → Ω → ℝ) (v : ι → ℝ) (x : Ω) : ℝ :=
  pairing v (fun i => T i x)

def mean (μ : Measure Ω) (T : ι → Ω → ℝ) (v : ι → ℝ) (i : ι) : ℝ :=
  ∫ x, T i x ∂(μ.tilted (potential T v))

def entropy (μ : Measure Ω) (T : ι → Ω → ℝ) (v : ι → ℝ) : ℝ :=
  ∫ x, Real.log (density μ (potential T v) x) ∂(μ.tilted (potential T v))

def objective (μ : Measure Ω) (T : ι → Ω → ℝ) (q v : ι → ℝ) : ℝ :=
  pairing v q - Real.log (partition μ (potential T v))

omit [DecidableEq ι] [Nonempty ι] in
lemma measurable_potential (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (v : ι → ℝ) : Measurable (potential T v) :=
  Finset.measurable_fun_sum Finset.univ (fun i _ => (hT i).const_mul (v i))

omit [MeasurableSpace Ω] [DecidableEq ι] [Nonempty ι] in
lemma continuous_potential (T : ι → Ω → ℝ) (x : Ω) :
    Continuous (fun v : ι → ℝ => potential T v x) :=
  continuous_finsetSum _ (fun i _ => (continuous_apply i).mul continuous_const)

omit [MeasurableSpace Ω] [DecidableEq ι] [Nonempty ι] in
lemma potential_bound (T : ι → Ω → ℝ) (hT : ∀ i x, |T i x| ≤ 1)
    (v : ι → ℝ) (x : Ω) : |potential T v x| ≤ entryL1 v := by
  calc
    |potential T v x| ≤ ∑ i, |v i * T i x| := Finset.abs_sum_le_sum_abs _ _
    _ ≤ ∑ i, |v i| := by
      apply Finset.sum_le_sum
      intro i hi
      rw [abs_mul]
      exact (mul_le_mul_of_nonneg_left (hT i x) (abs_nonneg _)).trans_eq (mul_one _)
    _ = entryL1 v := rfl

omit [MeasurableSpace Ω] [DecidableEq ι] [Nonempty ι] in
lemma potential_line (T : ι → Ω → ℝ) (star dir : ι → ℝ) (t : ℝ) :
    potential T (star + t • dir) = fun x => potential T star x + t * potential T dir x := by
  funext x
  simp only [potential, pairing, Pi.add_apply, Pi.smul_apply, smul_eq_mul,
    add_mul, Finset.sum_add_distrib, Finset.mul_sum, mul_assoc]

variable (μ : Measure Ω) [IsProbabilityMeasure μ]

omit [Fintype ι] [DecidableEq ι] [Nonempty ι] in
lemma integrable_observable (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (i : ι) : Integrable (T i) μ := by
  apply (integrable_const (1 : ℝ)).mono' (hT i).aestronglyMeasurable
  exact ae_of_all μ (fun x => by simpa only [Real.norm_eq_abs] using hbound i x)

omit [DecidableEq ι] [Nonempty ι] in
lemma integral_potential (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (v : ι → ℝ) :
    (∫ x, potential T v x ∂μ) = pairing v (fun i => ∫ x, T i x ∂μ) := by
  unfold potential pairing
  rw [integral_finsetSum]
  · simp only [integral_const_mul]
  · intro i hi
    exact (integrable_observable μ T hT hbound i).const_mul (v i)

omit [DecidableEq ι] [Nonempty ι] in
lemma continuousOn_objective_ball (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (q : ι → ℝ) (G : ℝ) :
    ContinuousOn (objective μ T q) {v : ι → ℝ | entryL1 v ≤ G} := by
  have hpartition : ContinuousOn (fun v : ι → ℝ => partition μ (potential T v))
      {v : ι → ℝ | entryL1 v ≤ G} := by
    apply continuousOn_of_dominated
      (bound := fun _ : Ω => Real.exp G)
    · intro v hv
      exact (measurable_potential T hT v).exp.aestronglyMeasurable
    · intro v hv
      apply ae_of_all μ
      intro x
      rw [Real.norm_eq_abs, abs_of_pos (Real.exp_pos _)]
      exact Real.exp_le_exp.mpr
        (((le_abs_self _).trans (potential_bound T hbound v x)).trans hv)
    · exact integrable_const _
    · exact ae_of_all μ (fun x => (Real.continuous_exp.comp (continuous_potential T x)).continuousOn)
  have hlog := hpartition.log (fun v _ =>
    (partition_pos μ _ (measurable_potential T hT v) (potential_bound T hbound v)).ne')
  exact (continuous_finsetSum _
    (fun i _ => (continuous_apply i).mul continuous_const)).continuousOn.sub hlog

omit [DecidableEq ι] [Nonempty ι] in
lemma actual_entropy_identity (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (v : ι → ℝ) :
    entropy μ T v = pairing v (mean μ T v) - Real.log (partition μ (potential T v)) := by
  letI : IsProbabilityMeasure (μ.tilted (potential T v)) :=
    tilted_probability μ _ (measurable_potential T hT v) (potential_bound T hbound v)
  unfold entropy
  rw [tilted_entropy_identity μ _ (measurable_potential T hT v)
    (potential_bound T hbound v)]
  rw [integral_potential _ T hT hbound v]
  rfl

omit [DecidableEq ι] [Nonempty ι] in
lemma actual_entropy_nonneg (T : ι → Ω → ℝ) (hT : ∀ i, Measurable (T i))
    (hbound : ∀ i x, |T i x| ≤ 1) (v : ι → ℝ) : 0 ≤ entropy μ T v :=
  tilted_entropy_nonneg μ _ (measurable_potential T hT v) (potential_bound T hbound v)

end NeuralGeneralization.ActualBoundedDual

end
