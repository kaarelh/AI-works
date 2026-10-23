import NeuralGeneralization.BatchTwoActivationGaussianMoment
import Mathlib.Analysis.InnerProductSpace.Projection.Minimal
import Mathlib.Analysis.InnerProductSpace.PiL2

/-!
# Actual measurable convex projections and Gaussian distance moments

The projection is constructed by the Hilbert-space minimizer theorem.
Its nonexpansiveness and measurability are proved. Gaussian distance tails
are obtained from the transport concentration theorem, not postulated.
-/

noncomputable section
open MeasureTheory ProbabilityTheory Set
open scoped BigOperators ENNReal RealInnerProductSpace
namespace NeuralGeneralization.BatchTwoActivation

variable {E : Type*} [NormedAddCommGroup E] [InnerProductSpace ℝ E] [CompleteSpace E]

/-- The actual nearest point in a nonempty closed convex set. -/
def convexProjection (K : Set E) (hne : K.Nonempty) (hclosed : IsClosed K)
    (hconv : Convex ℝ K) (x : E) : E :=
  Classical.choose (exists_norm_eq_iInf_of_complete_convex hne hclosed.isComplete hconv x)

theorem convexProjection_mem (K : Set E) (hne : K.Nonempty) (hclosed : IsClosed K)
    (hconv : Convex ℝ K) (x : E) : convexProjection K hne hclosed hconv x∈K :=
  (Classical.choose_spec (exists_norm_eq_iInf_of_complete_convex hne hclosed.isComplete hconv x)).1

theorem convexProjection_minimizes (K : Set E) (hne : K.Nonempty) (hclosed : IsClosed K)
    (hconv : Convex ℝ K) (x : E) :
    ‖x-convexProjection K hne hclosed hconv x‖=⨅w : K, ‖x-w.val‖ :=
  (Classical.choose_spec (exists_norm_eq_iInf_of_complete_convex hne hclosed.isComplete hconv x)).2

theorem convexProjection_optimality (K : Set E) (hne : K.Nonempty) (hclosed : IsClosed K)
    (hconv : Convex ℝ K) (x : E) : ∀y∈K,
      ⟪x-convexProjection K hne hclosed hconv x,
        y-convexProjection K hne hclosed hconv x⟫≤0 :=
  (norm_eq_iInf_iff_real_inner_le_zero hconv
    (convexProjection_mem K hne hclosed hconv x)).mp
      (convexProjection_minimizes K hne hclosed hconv x)

theorem convexProjection_lipschitz (K : Set E) (hne : K.Nonempty) (hclosed : IsClosed K)
    (hconv : Convex ℝ K) : LipschitzWith 1 (convexProjection K hne hclosed hconv) := by
  apply LipschitzWith.of_dist_le_mul
  intro x y
  let a := convexProjection K hne hclosed hconv x
  let b := convexProjection K hne hclosed hconv y
  have h₁ := convexProjection_optimality K hne hclosed hconv x b
    (convexProjection_mem K hne hclosed hconv y)
  have h₂ := convexProjection_optimality K hne hclosed hconv y a
    (convexProjection_mem K hne hclosed hconv x)
  change ⟪x-a,b-a⟫≤0 at h₁
  change ⟪y-b,a-b⟫≤0 at h₂
  have h₁' : 0≤⟪x-a,a-b⟫ := by
    have he : b-a=-(a-b) := by abel
    rw [he, inner_neg_right] at h₁
    linarith
  have hid : ⟪x-y,a-b⟫=⟪a-b,a-b⟫+⟪x-a,a-b⟫-⟪y-b,a-b⟫ := by
    simp only [inner_sub_left]
    ring
  have hs : ‖a-b‖^2≤‖x-y‖*‖a-b‖ := by
    have hh := (le_abs_self ⟪x-y,a-b⟫).trans (abs_real_inner_le_norm (x-y) (a-b))
    rw [hid, real_inner_self_eq_norm_sq] at hh
    linarith
  simp only [NNReal.coe_one, one_mul, dist_eq_norm]
  change ‖a-b‖≤‖x-y‖
  nlinarith [norm_nonneg (a-b), norm_nonneg (x-y)]

theorem convexProjection_distance (K : Set E) (hne : K.Nonempty) (hclosed : IsClosed K)
    (hconv : Convex ℝ K) (x : E) :
    ‖x-convexProjection K hne hclosed hconv x‖=Metric.infDist x K := by
  rw [convexProjection_minimizes, Metric.infDist_eq_iInf]
  simp only [dist_eq_norm]

def gaussianSetDistance {n : ℕ} (K : Set (EuclideanSpace ℝ (Fin n)))
    (x : Fin n→ℝ) : ℝ := Metric.infDist (WithLp.toLp 2 x) K

theorem gaussianSetDistance_measurable {n : ℕ} (K : Set (EuclideanSpace ℝ (Fin n))) :
    Measurable (gaussianSetDistance K) :=
  ((Metric.lipschitz_infDist_pt K).continuous.comp (PiLp.continuous_toLp 2 _)).measurable

theorem gaussianSetDistance_squareLipschitz {n : ℕ} (K : Set (EuclideanSpace ℝ (Fin n))) :
    SquareLipschitz (gaussianSetDistance K) := by
  intro x y
  have h := (Metric.lipschitz_infDist_pt K).dist_le_mul (WithLp.toLp 2 x) (WithLp.toLp 2 y)
  simp only [NNReal.coe_one, one_mul, Real.dist_eq, dist_eq_norm] at h
  have hs := pow_le_pow_left₀ (abs_nonneg _) h 2
  simpa only [Real.norm_eq_abs, sq_abs, ← WithLp.toLp_sub, EuclideanSpace.real_norm_sq_eq,
    PiLp.toLp_apply, Pi.sub_apply, gaussianSetDistance, euclideanSquaredDistance] using hs

/-- Every positive-mass closed convex Gaussian bulk has a measurable
projection with a dimension-free exponential moment of its squared residual. -/
theorem gaussian_convex_projection_moment {n : ℕ}
    (K : Set (EuclideanSpace ℝ (Fin n))) (hne : K.Nonempty) (hclosed : IsClosed K)
    (hconv : Convex ℝ K)
    (hmass : (1/2:ℝ)≤(standardGaussian n).real ((WithLp.toLp 2) ⁻¹' K)) :
    Measurable (fun x : Fin n→ℝ => convexProjection K hne hclosed hconv (WithLp.toLp 2 x)) ∧
    (∫⁻ x, ENNReal.ofReal (Real.exp
      (‖WithLp.toLp 2 x-convexProjection K hne hclosed hconv (WithLp.toLp 2 x)‖^2/8))
      ∂standardGaussian n)≤3 := by
  refine ⟨((convexProjection_lipschitz K hne hclosed hconv).continuous.comp
    (PiLp.continuous_toLp 2 _)).measurable, ?_⟩
  simp_rw [convexProjection_distance]
  exact gaussian_zeroSet_exp_square_moment (gaussianSetDistance K)
    (gaussianSetDistance_measurable K) (gaussianSetDistance_squareLipschitz K)
    ((WithLp.toLp 2) ⁻¹' K)
    (hclosed.measurableSet.preimage (PiLp.continuous_toLp 2 _).measurable)
    hmass (fun x hx => Metric.infDist_zero_of_mem hx)

end NeuralGeneralization.BatchTwoActivation
