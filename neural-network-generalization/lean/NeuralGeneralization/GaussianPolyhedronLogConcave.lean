import NeuralGeneralization.GaussianConvexPenalty

/-! Actual logarithmic concavity of Gaussian probabilities of finite affine
halfspace intersections. The proof takes dominated limits of the explicit
positive continuous penalty functions. -/
noncomputable section
open MeasureTheory ProbabilityTheory Set Filter
open scoped BigOperators Topology
namespace NeuralGeneralization.GaussianPolyhedronLogConcave
open PrekopaLeindlerInterval GaussianCoordinateIntegration GaussianConvexPenalty
variable {I J : Type*} [Fintype I] [Fintype J]

def region (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ) : Set (I → ℝ) :=
  {z | ∀ j, residual A a b t z j ≤ 0}

theorem isClosed_region (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ) :
    IsClosed (region A a b t) := by
  have heq : region A a b t = ⋂ j, {z | residual A a b t z j ≤ 0} := by ext z; simp [region]
  rw [heq]
  apply isClosed_iInter
  intro j
  apply isClosed_le _ continuous_const
  unfold GaussianConvexPenalty.residual
  fun_prop

theorem penalty_eq_zero_of_mem (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ)
    {z : I → ℝ} (hz : z ∈ region A a b t) : penalty A a b t z = 0 := by
  apply Finset.sum_eq_zero
  intro j _
  rw [max_eq_left (hz j), zero_pow (by norm_num)]

theorem penalty_pos_of_not_mem (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ)
    {z : I → ℝ} (hz : z ∉ region A a b t) : 0 < penalty A a b t z := by
  classical
  have hz' : ∃ j, 0 < residual A a b t z j := by
    simpa only [region, mem_setOf_eq, not_forall, not_le] using hz
  obtain ⟨j,hj⟩ := hz'
  apply (Finset.sum_pos_iff_of_nonneg (fun _ _ => sq_nonneg _)).2
  exact ⟨j, Finset.mem_univ _, sq_pos_of_pos (lt_max_of_lt_right hj)⟩

theorem approximation_tendsto (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ) (z : I → ℝ) :
    Tendsto (fun n => approximation A a b n t z) atTop
      (𝓝 ((region A a b t).indicator (fun _ => (1 : ℝ)) z)) := by
  classical
  by_cases hz : z ∈ region A a b t
  · simpa only [approximation, penalty_eq_zero_of_mem A a b t hz, mul_zero, Real.exp_zero,
      indicator_of_mem hz] using tendsto_const_nhds (x := (1 : ℝ))
  · have hlim := Real.tendsto_exp_neg_atTop_nhds_zero.comp
      ((tendsto_natCast_atTop_atTop : Tendsto (fun n : ℕ => (n : ℝ)) atTop atTop).atTop_mul_const
        (penalty_pos_of_not_mem A a b t hz))
    simpa only [Function.comp_def, neg_mul, approximation, indicator_of_notMem hz] using hlim

theorem integral_approximation_tendsto (A : J → I → ℝ) (a b : J → ℝ) (t : ℝ) :
    Tendsto (fun n => ∫ z, approximation A a b n t z ∂law I) atTop
      (𝓝 ((law I).real (region A a b t))) := by
  have h := tendsto_integral_of_dominated_convergence (μ := law I) (fun _ => (1 : ℝ))
    (fun n => (continuous_approximation A a b n t).aestronglyMeasurable)
    (integrable_const 1)
    (fun n => Eventually.of_forall fun z => by
      rw [Real.norm_eq_abs, abs_of_pos (approximation_pos A a b n t z)]
      exact approximation_le_one A a b n t z)
    (Eventually.of_forall (approximation_tendsto A a b t))
  have hind : (∫ z, (region A a b t).indicator (fun _ => (1 : ℝ)) z ∂law I) =
      (law I).real (region A a b t) := integral_indicator_one (isClosed_region A a b t).measurableSet
  rw [hind] at h
  exact h

/-- No nonsingularity assumptions are needed: `A` can be any finite matrix.
The conclusion is the multiplicative form of actual Gaussian log-concavity. -/
theorem region_mass_logConcave (A : J → I → ℝ) (a b : J → ℝ) (s t : ℝ)
    {θ : ℝ} (hθ : θ ∈ Icc 0 1) :
    ((law I).real (region A a b s)) ^ (1-θ) *
      ((law I).real (region A a b t)) ^ θ ≤
      (law I).real (region A a b (mix θ s t)) := by
  exact le_of_tendsto_of_tendsto
    (((integral_approximation_tendsto A a b s).rpow_const (Or.inr (sub_nonneg.mpr hθ.2))).mul
      ((integral_approximation_tendsto A a b t).rpow_const (Or.inr hθ.1)))
    (integral_approximation_tendsto A a b (mix θ s t))
    (Eventually.of_forall fun n => integral_approximation_logConcave A a b n s t hθ)

end NeuralGeneralization.GaussianPolyhedronLogConcave
end
