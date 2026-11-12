import NeuralGeneralization.GaussianConeRadial

/-! First radial moment of the independent Gaussian coordinates. -/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators
namespace NeuralGeneralization.BatchTwoContinuousSphere
open GaussianConeRadial

abbrev coordinateGaussian (n : ℕ) : Measure (Fin n → ℝ) :=
  Measure.pi (fun _ : Fin n => gaussianReal 0 1)

def radius {n : ℕ} (x : Fin n → ℝ) : ℝ := Real.sqrt (squaredRadius x)

theorem squaredRadius_nonneg {n : ℕ} (x : Fin n → ℝ) : 0 ≤ squaredRadius x := by
  unfold squaredRadius
  positivity

theorem radius_nonneg {n : ℕ} (x : Fin n → ℝ) : 0 ≤ radius x := Real.sqrt_nonneg _

theorem radius_sq {n : ℕ} (x : Fin n → ℝ) : (radius x)^2 = squaredRadius x :=
  Real.sq_sqrt (squaredRadius_nonneg x)

theorem measurable_radius (n : ℕ) : Measurable (radius : (Fin n → ℝ) → ℝ) := by
  unfold radius squaredRadius
  fun_prop

theorem integrable_squaredRadius (n : ℕ) : Integrable (squaredRadius (I := Fin n)) (coordinateGaussian n) := by
  unfold squaredRadius
  exact integrable_finsetSum _ (fun i _ => integrable_eval_sq i)

theorem integrable_radius (n : ℕ) : Integrable (radius : (Fin n → ℝ) → ℝ) (coordinateGaussian n) := by
  apply ((integrable_squaredRadius n).add (integrable_const 1)).mono' (measurable_radius n).aestronglyMeasurable
  apply Filter.Eventually.of_forall
  intro x
  rw [Real.norm_eq_abs, abs_of_nonneg (radius_nonneg x)]
  change radius x ≤ squaredRadius x+1
  have hh := radius_sq x
  have hn := squaredRadius_nonneg x
  nlinarith [sq_nonneg (radius x-1)]

/-- The slightly relaxed sqrt(n+1) bound avoids a special zero-dimensional
case and is exactly sufficient for the ambient dimension n+1. -/
theorem integral_radius_le_sqrt_succ (n : ℕ) :
    (∫ x, radius x ∂coordinateGaussian n) ≤ Real.sqrt ((n:ℝ)+1) := by
  let b := Real.sqrt ((n:ℝ)+1)
  have hb : 0 < b := Real.sqrt_pos.mpr (by positivity)
  have hb2 : b^2 = (n:ℝ)+1 := Real.sq_sqrt (by positivity)
  have hp (x : Fin n → ℝ) : 2*b*radius x ≤ squaredRadius x+((n:ℝ)+1) := by
    have hr := radius_sq x
    nlinarith [sq_nonneg (radius x-b)]
  have hi := integral_mono ((integrable_radius n).const_mul (2*b))
    ((integrable_squaredRadius n).add (integrable_const ((n:ℝ)+1))) hp
  simp only [Pi.add_apply] at hi
  rw [integral_const_mul, integral_add (integrable_squaredRadius n) (integrable_const ((n:ℝ)+1)),
    integral_squaredRadius] at hi
  simp only [Fintype.card_fin, integral_const, probReal_univ, smul_eq_mul, one_mul] at hi
  nlinarith

end NeuralGeneralization.BatchTwoContinuousSphere
