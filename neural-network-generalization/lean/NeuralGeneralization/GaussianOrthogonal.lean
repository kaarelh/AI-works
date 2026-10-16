import Mathlib.Probability.Distributions.Gaussian.Real
import Mathlib.MeasureTheory.Measure.CharacteristicFunction.Basic
import Mathlib.Analysis.InnerProductSpace.PiL2
import Mathlib.Tactic.FunProp

/-!
# Exact orthogonal-coordinate cylinder laws

A finite product of centered Gaussians with common variance is invariant under
an orthogonal coordinate change. The proof uses its characteristic function,
so it needs no abstract multivariate Gaussian or covariance assumption.
Consequently any cylinder specified in orthogonal coordinates has exactly the
product of its one-dimensional Gaussian interval probabilities.
-/

noncomputable section
open MeasureTheory ProbabilityTheory WithLp
open scoped BigOperators NNReal RealInnerProductSpace

namespace NeuralGeneralization.GaussianOrthogonal

variable {ι : Type*} [Fintype ι]

/-- The concrete product law, expressed in Euclidean coordinates. -/
def euclideanGaussian (v : ℝ≥0) : Measure (EuclideanSpace ℝ ι) :=
  (Measure.pi (fun _ : ι => gaussianReal 0 v)).map (toLp 2)

instance euclideanGaussian_probability (v : ℝ≥0) :
    IsProbabilityMeasure (euclideanGaussian (ι := ι) v) :=
  Measure.isProbabilityMeasure_map (WithLp.measurable_toLp 2 (ι → ℝ)).aemeasurable

theorem charFun_euclideanGaussian (v : ℝ≥0) (t : EuclideanSpace ℝ ι) :
    charFun (euclideanGaussian v) t =
      Complex.exp (((-(v : ℝ) * ‖t‖ ^ 2 / 2 : ℝ) : ℂ)) := by
  rw [euclideanGaussian, charFun_pi]
  simp only [charFun_gaussianReal, Complex.ofReal_zero, mul_zero, zero_mul, zero_sub]
  rw [← Complex.exp_sum]
  congr 1
  rw [EuclideanSpace.real_norm_sq_eq]
  simp only [Complex.ofReal_div, Complex.ofReal_neg, Complex.ofReal_mul,
    Complex.ofReal_ofNat, Complex.ofReal_sum, Complex.ofReal_pow,
    Finset.mul_sum, Finset.sum_div, Finset.sum_neg_distrib, neg_mul, neg_div]

/-- Pulling a characteristic function through an orthogonal map uses its
inverse on the argument. This is a direct change-of-variables identity. -/
theorem charFun_map_isometry
    (μ : Measure (EuclideanSpace ℝ ι))
    (f : EuclideanSpace ℝ ι ≃ₗᵢ[ℝ] EuclideanSpace ℝ ι)
    (t : EuclideanSpace ℝ ι) :
    charFun (μ.map f) t = charFun μ (f.symm t) := by
  rw [charFun_apply, charFun_apply,
    integral_map f.continuous.measurable.aemeasurable (by fun_prop)]
  simp only [f.inner_map_eq_flip]

/-- Exact orthogonal invariance, including the degenerate variance-zero law. -/
theorem euclideanGaussian_map (v : ℝ≥0)
    (f : EuclideanSpace ℝ ι ≃ₗᵢ[ℝ] EuclideanSpace ℝ ι) :
    (euclideanGaussian v).map f = euclideanGaussian v := by
  apply Measure.ext_of_charFun
  funext t
  rw [charFun_map_isometry, charFun_euclideanGaussian, charFun_euclideanGaussian,
    f.symm.norm_map]

/-- The same orthogonal change of variables on the actual real coordinate
function space used for network weights. -/
def coordinateMap (f : EuclideanSpace ℝ ι ≃ₗᵢ[ℝ] EuclideanSpace ℝ ι) :
    (ι → ℝ) → (ι → ℝ) :=
  fun x => ofLp (f (toLp 2 x))

theorem coordinateMap_measurable
    (f : EuclideanSpace ℝ ι ≃ₗᵢ[ℝ] EuclideanSpace ℝ ι) :
    Measurable (coordinateMap f) :=
  (WithLp.measurable_ofLp 2 (ι → ℝ)).comp
    (f.continuous.measurable.comp (WithLp.measurable_toLp 2 (ι → ℝ)))

theorem productGaussian_map_coordinateMap (v : ℝ≥0)
    (f : EuclideanSpace ℝ ι ≃ₗᵢ[ℝ] EuclideanSpace ℝ ι) :
    (Measure.pi (fun _ : ι => gaussianReal 0 v)).map (coordinateMap f) =
      Measure.pi (fun _ : ι => gaussianReal 0 v) := by
  apply (MeasurableEquiv.toLp 2 (ι → ℝ)).map_measurableEquiv_injective
  change ((Measure.pi (fun _ : ι => gaussianReal 0 v)).map (coordinateMap f)).map
    (toLp 2) = (Measure.pi (fun _ : ι => gaussianReal 0 v)).map (toLp 2)
  rw [Measure.map_map (WithLp.measurable_toLp 2 (ι → ℝ)) (coordinateMap_measurable f)]
  have heq : (toLp 2) ∘ coordinateMap f = f ∘ (toLp 2) := by
    funext x
    rfl
  rw [heq, ← Measure.map_map f.continuous.measurable
    (WithLp.measurable_toLp 2 (ι → ℝ))]
  exact euclideanGaussian_map v f

/-- Taking `A i = univ` for unconstrained coordinates gives the usual
orthogonal cylinder probability without imposing any bound on those weights. -/
theorem orthogonal_cylinder_measure (v : ℝ≥0)
    (f : EuclideanSpace ℝ ι ≃ₗᵢ[ℝ] EuclideanSpace ℝ ι)
    (A : ι → Set ℝ) (hA : ∀ i, MeasurableSet (A i)) :
    (Measure.pi (fun _ : ι => gaussianReal 0 v))
        (coordinateMap f ⁻¹' Set.pi Set.univ A) =
      ∏ i, gaussianReal 0 v (A i) := by
  rw [← Measure.map_apply (coordinateMap_measurable f) (MeasurableSet.univ_pi hA),
    productGaussian_map_coordinateMap v f, Measure.pi_pi]

end NeuralGeneralization.GaussianOrthogonal
