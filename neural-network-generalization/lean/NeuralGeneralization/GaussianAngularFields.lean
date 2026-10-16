import NeuralGeneralization.FiniteDifferential
import NeuralGeneralization.GaussianProductStein
import Mathlib.Analysis.SpecialFunctions.Trigonometric.Deriv
import Mathlib.Analysis.Calculus.ParametricIntegral

/-! # Angular interpolation of actual finite Gaussian fields
The endpoints may have singular covariance. All interpolation coefficients
and their derivatives are uniformly bounded, including at both endpoints.
-/
noncomputable section
open MeasureTheory ProbabilityTheory
open scoped BigOperators NNReal Topology
namespace NeuralGeneralization.GaussianAngularFields
open FiniteDifferential
variable {I J K : Type*} [Fintype I] [Fintype J] [Fintype K]

def standardLaw (R : Type*) [Fintype R] : Measure (R → ℝ) :=
  Measure.pi (fun _ : R => gaussianReal 0 1)

instance standardLaw_probability (R : Type*) [Fintype R] :
    IsProbabilityMeasure (standardLaw R) := by unfold standardLaw; infer_instance

def angleMatrix (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ) (i : I) : J ⊕ K → ℝ :=
  Sum.elim (fun j => Real.cos θ * A i j) (fun k => Real.sin θ * B i k)

def velocityMatrix (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ) (i : I) : J ⊕ K → ℝ :=
  Sum.elim (fun j => -Real.sin θ * A i j) (fun k => Real.cos θ * B i k)

def angularField (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ) (z : J ⊕ K → ℝ) : I → ℝ :=
  fieldLinear (angleMatrix A B θ) z

def angularVelocity (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ) (z : J ⊕ K → ℝ) : I → ℝ :=
  fieldLinear (velocityMatrix A B θ) z

def leftField (A : I → J → ℝ) (z : J ⊕ K → ℝ) (i : I) : ℝ :=
  ∑ j, A i j * z (.inl j)

def rightField (B : I → K → ℝ) (z : J ⊕ K → ℝ) (i : I) : ℝ :=
  ∑ k, B i k * z (.inr k)

omit [Fintype I] in
theorem angularField_eq (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ) (z : J ⊕ K → ℝ) :
    angularField A B θ z = Real.cos θ • leftField A z + Real.sin θ • rightField B z := by
  funext i
  simp only [angularField, fieldLinear_apply, angleMatrix, Fintype.sum_sum_type,
    Sum.elim_inl, Sum.elim_inr, Pi.add_apply, Pi.smul_apply, smul_eq_mul,
    leftField, rightField, Finset.mul_sum, mul_assoc]

omit [Fintype I] in
theorem angularVelocity_eq (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ) (z : J ⊕ K → ℝ) :
    angularVelocity A B θ z = -Real.sin θ • leftField A z + Real.cos θ • rightField B z := by
  funext i
  simp only [angularVelocity, fieldLinear_apply, velocityMatrix, Fintype.sum_sum_type,
    Sum.elim_inl, Sum.elim_inr, Pi.add_apply, Pi.smul_apply, smul_eq_mul,
    leftField, rightField, Finset.mul_sum, mul_assoc]

theorem hasDerivAt_angularField (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ)
    (z : J ⊕ K → ℝ) :
    HasDerivAt (fun t => angularField A B t z) (angularVelocity A B θ z) θ := by
  simp_rw [angularField_eq, angularVelocity_eq]
  exact ((Real.hasDerivAt_cos θ).smul_const (leftField A z)).add
    ((Real.hasDerivAt_sin θ).smul_const (rightField B z))

omit [Fintype I] in
theorem continuous_angularField (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ) :
    Continuous (angularField A B θ) := (fieldLinear (angleMatrix A B θ)).continuous

omit [Fintype I] in
theorem velocity_abs_le (A : I → J → ℝ) (B : I → K → ℝ) (θ : ℝ)
    (z : J ⊕ K → ℝ) (i : I) :
    |angularVelocity A B θ z i| ≤ |leftField A z i| + |rightField B z i| := by
  rw [angularVelocity_eq]
  change |-Real.sin θ * leftField A z i + Real.cos θ * rightField B z i| ≤ _
  calc
    _ ≤ |-Real.sin θ * leftField A z i| + |Real.cos θ * rightField B z i| := abs_add_le _ _
    _ ≤ |leftField A z i| + |rightField B z i| := by
      simp only [abs_mul, abs_neg]
      exact add_le_add
        (by simpa only [one_mul] using mul_le_mul_of_nonneg_right (Real.abs_sin_le_one θ) (abs_nonneg _))
        (by simpa only [one_mul] using mul_le_mul_of_nonneg_right (Real.abs_cos_le_one θ) (abs_nonneg _))

omit [Fintype I] in
theorem integrable_leftField (A : I → J → ℝ) (i : I) :
    Integrable (fun z : J ⊕ K → ℝ => leftField A z i) (standardLaw (J ⊕ K)) :=
  integrable_finsetSum Finset.univ (fun j _ =>
    (GaussianProductStein.integrable_coord (fun _ : J ⊕ K => (1 : ℝ≥0)) (.inl j)).const_mul (A i j))

omit [Fintype I] in
theorem integrable_rightField (B : I → K → ℝ) (i : I) :
    Integrable (fun z : J ⊕ K → ℝ => rightField B z i) (standardLaw (J ⊕ K)) :=
  integrable_finsetSum Finset.univ (fun k _ =>
    (GaussianProductStein.integrable_coord (fun _ : J ⊕ K => (1 : ℝ≥0)) (.inr k)).const_mul (B i k))

theorem integrable_velocity_bound (A : I → J → ℝ) (B : I → K → ℝ) (C : ℝ) :
    Integrable (fun z : J ⊕ K → ℝ => C * ∑ i, (|leftField A z i| + |rightField B z i|))
      (standardLaw (J ⊕ K)) :=
  (integrable_finsetSum Finset.univ (fun i _ =>
    (integrable_leftField A i).abs.add (integrable_rightField B i).abs)).const_mul C

end NeuralGeneralization.GaussianAngularFields
end
