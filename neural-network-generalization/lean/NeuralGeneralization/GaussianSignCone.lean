import NeuralGeneralization.GaussianConeRadial

/-! Actual conditional moments for finite homogeneous Gaussian sign constraints. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal
namespace NeuralGeneralization.GaussianSignCone
open GaussianConeRadial
variable {I J : Type*} [Fintype I] [Fintype J]

def signCone (A : J → I → ℝ) : Set (I → ℝ) :=
  {x | ∀ j, 0 < ∑ i, A j i * x i}

theorem measurableSet_signCone (A : J → I → ℝ) :
    MeasurableSet (signCone A) := by
  change MeasurableSet {x : I → ℝ | ∀ j, 0 < ∑ i, A j i * x i}
  rw [Set.setOf_forall]
  exact MeasurableSet.iInter (fun j => measurableSet_lt measurable_const (by fun_prop))

theorem positiveHomogeneous_signCone (A : J → I → ℝ) :
    PositiveHomogeneous (signCone A) := by
  intro a ha x
  have heq (j : J) : (∑ i, A j i * (a • x) i) = a * ∑ i, A j i * x i := by
    simp only [Pi.smul_apply, smul_eq_mul, Finset.mul_sum]
    apply Finset.sum_congr rfl
    intro i hi
    ring
  simp only [signCone, Set.mem_setOf_eq, heq, mul_pos_iff_of_pos_left ha]

theorem conditional_mean_sq_le (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) :
    (∑ i, (∫ x : I → ℝ, x i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) ^ 2)
      ≤ Fintype.card I :=
  sum_sq_conditional_mean_le_card (signCone A) (measurableSet_signCone A)
    (positiveHomogeneous_signCone A) hprob

/-- Every observed signed linear form has a strictly positive posterior mean. -/
theorem signed_conditional_mean_pos (A : J → I → ℝ)
    (hprob : (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A) ≠ 0) (j : J) :
    0 < ∑ i, A j i *
      (∫ x : I → ℝ, x i ∂cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)) := by
  let ν := cond (Measure.pi (fun _ : I => gaussianReal 0 1)) (signCone A)
  letI : IsProbabilityMeasure ν := cond_isProbabilityMeasure hprob
  have hi (i : I) : Integrable (fun x : I → ℝ => A j i * x i) ν :=
    (((memLp_eval i).integrable (by norm_num)).restrict.smul_measure
      (ENNReal.inv_ne_top.mpr hprob)).const_mul _
  have hf : Integrable (fun x : I → ℝ => ∑ i, A j i * x i) ν :=
    integrable_finsetSum _ (fun i _ => hi i)
  have hp : ∀ᵐ x : I → ℝ ∂ν, 0 < ∑ i, A j i * x i :=
    ae_cond_of_forall_mem (measurableSet_signCone A) (fun x hx => hx j)
  have hn : ∀ᵐ x : I → ℝ ∂ν, 0 ≤ ∑ i, A j i * x i := hp.mono (fun _ h => h.le)
  have hs : Function.support (fun x : I → ℝ => ∑ i, A j i * x i) =ᵐ[ν] Set.univ := by
    filter_upwards [hp] with x hx
    apply propext
    change (∑ i, A j i * x i) ≠ 0 ↔ True
    simp [hx.ne']
  have hm : ν (Function.support (fun x : I → ℝ => ∑ i, A j i * x i)) = 1 := by
    rw [measure_congr hs, measure_univ]
  have hpos := (integral_pos_iff_support_of_nonneg_ae hn hf).2 (by rw [hm]; norm_num)
  rw [integral_finsetSum _ (fun i _ => hi i)] at hpos
  simpa only [integral_const_mul] using hpos

end NeuralGeneralization.GaussianSignCone
