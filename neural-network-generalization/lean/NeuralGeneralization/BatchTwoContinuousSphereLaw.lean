import NeuralGeneralization.BatchTwoContinuousSphereMoments
import Mathlib.Probability.Distributions.Gaussian.Multivariate

/-! The uniform spherical law, constructed by normalizing a standard
isotropic Gaussian. Its coordinates use the continuous-input model's type. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousSphere
open GaussianConeRadial

def direction {d : ℕ} (x : Fin d → ℝ) : Fin d → ℝ := fun i => x i / radius x

def uniformSphere (d : ℕ) : Measure (Fin d → ℝ) := (coordinateGaussian d).map direction

theorem measurable_direction (d : ℕ) : Measurable (direction : (Fin d → ℝ) → (Fin d → ℝ)) := by
  apply measurable_pi_lambda
  intro i
  exact (measurable_pi_apply i).div (measurable_radius d)

instance (d : ℕ) : IsProbabilityMeasure (uniformSphere d) :=
  Measure.isProbabilityMeasure_map (measurable_direction d).aemeasurable

theorem radius_eq_norm {d : ℕ} (x : Fin d → ℝ) :
    radius x = ‖WithLp.toLp 2 x‖ := by
  rw [EuclideanSpace.norm_eq]
  simp only [radius, squaredRadius, Real.norm_eq_abs, sq_abs, PiLp.toLp_apply]

theorem radius_eq_zero_iff {d : ℕ} (x : Fin d → ℝ) : radius x = 0 ↔ x = 0 := by
  rw [radius_eq_norm, norm_eq_zero]
  exact (WithLp.toLp_injective 2).eq_iff

theorem abs_coordinate_le_radius {d : ℕ} (x : Fin d → ℝ) (i : Fin d) : |x i| ≤ radius x := by
  apply (sq_le_sq₀ (abs_nonneg _) (radius_nonneg x)).mp
  rw [sq_abs, radius_sq]
  exact Finset.single_le_sum (fun j _ => sq_nonneg (x j)) (Finset.mem_univ i)

theorem direction_coordinate_bound {d : ℕ} (x : Fin d → ℝ) (i : Fin d) :
    |direction x i| ≤ 1 := by
  by_cases h : radius x = 0
  · simp [direction, h]
  · rw [direction, abs_div, abs_of_nonneg (radius_nonneg x)]
    exact (div_le_one (lt_of_le_of_ne (radius_nonneg x) (Ne.symm h))).mpr
      (abs_coordinate_le_radius x i)

theorem direction_squaredRadius {d : ℕ} (x : Fin d → ℝ) (hx : x ≠ 0) :
    squaredRadius (direction x) = 1 := by
  have hr : radius x ≠ 0 := fun hr => hx ((radius_eq_zero_iff x).mp hr)
  simp only [squaredRadius, direction, div_pow, ← Finset.sum_div]
  change squaredRadius x / (radius x)^2 = 1
  rw [← radius_sq]
  exact div_self (pow_ne_zero _ hr)

theorem coordinateGaussian_zero_null (n : ℕ) : coordinateGaussian (n+1) {0} = 0 := by
  letI : NullSingletonClass (gaussianReal 0 1) := nullSingletonClass_gaussianReal (by norm_num)
  have hmap := (measurePreserving_eval (fun _ : Fin (n+1) => gaussianReal 0 1) 0).map_eq
  have he := congrArg (fun μ : Measure ℝ => μ {0}) hmap
  rw [Measure.map_apply (measurable_pi_apply 0) (measurableSet_singleton 0), measure_singleton] at he
  apply le_antisymm _ bot_le
  calc
    _ ≤ coordinateGaussian (n+1) ((fun x : Fin (n+1) → ℝ => x 0) ⁻¹' {0}) := by
      apply measure_mono
      intro x hx
      have hx0 : x = 0 := hx
      simp [hx0]
    _ = 0 := he

/-- The normalized law is supported on the complete unit sphere. -/
theorem uniformSphere_on_sphere (n : ℕ) :
    ∀ᵐ x ∂uniformSphere (n+1), squaredRadius x = 1 := by
  apply (ae_map_iff (measurable_direction (n+1)).aemeasurable
    (measurableSet_eq_fun (by unfold squaredRadius; fun_prop) measurable_const)).mpr
  have hz : ∀ᵐ x ∂coordinateGaussian (n+1), x ≠ 0 := by
    rw [ae_iff]
    simpa only [not_not, Set.setOf_eq_eq_singleton] using coordinateGaussian_zero_null n
  exact hz.mono (fun x hx => direction_squaredRadius x hx)

/-- The same law in Euclidean coordinates is normalized standard Gaussian,
so the definition uses the full isotropic Gaussian, not a coordinate prior. -/
theorem uniformSphere_euclidean (d : ℕ) :
    (uniformSphere d).map (WithLp.toLp 2) =
      (stdGaussian (EuclideanSpace ℝ (Fin d))).map (fun x => ‖x‖⁻¹ • x) := by
  have hn : Measurable (fun x : EuclideanSpace ℝ (Fin d) => ‖x‖⁻¹ • x) := by fun_prop
  have ht : Measurable (WithLp.toLp 2 : (Fin d → ℝ) → EuclideanSpace ℝ (Fin d)) := by fun_prop
  rw [uniformSphere, Measure.map_map ht (measurable_direction d),
    ← map_pi_eq_stdGaussian, Measure.map_map hn ht]
  congr 1
  funext x
  ext i
  simp only [Function.comp_apply, direction, PiLp.smul_apply, smul_eq_mul,
    PiLp.toLp_apply, ← radius_eq_norm, div_eq_mul_inv, mul_comm]

end NeuralGeneralization.BatchTwoContinuousSphere
