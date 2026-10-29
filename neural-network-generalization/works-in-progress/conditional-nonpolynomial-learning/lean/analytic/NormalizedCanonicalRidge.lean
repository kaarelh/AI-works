import CanonicalQuadratureBridge

noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory InformationTheory ConditionalAnalytic
open scoped BigOperators RealInnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
variable {I : Type*} [Fintype I]

def gaussianRowNorm (z : I → ℝ) : ℝ := ‖WithLp.toLp 2 z‖
def gaussianRowDirection (z : I → ℝ) (i : I) : ℝ := z i / gaussianRowNorm z

lemma gaussianRowNorm_measurable : Measurable (gaussianRowNorm (I := I)) := by
  unfold gaussianRowNorm
  fun_prop

lemma gaussianRowDirection_bound (z : I → ℝ) (i : I) :
    |gaussianRowDirection z i| ≤ 1 := by
  have hn : 0 ≤ gaussianRowNorm z := norm_nonneg _
  by_cases hz : gaussianRowNorm z = 0
  · simp [gaussianRowDirection,hz]
  · rw [gaussianRowDirection, abs_div, abs_of_nonneg hn]
    exact (div_le_one (lt_of_le_of_ne hn (Ne.symm hz))).mpr
      (PiLp.norm_apply_le (WithLp.toLp 2 z) i)

lemma gaussianRowNorm_sq_integrable
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    Integrable (fun z => (gaussianRowNorm z)^2) Q := by
  simp only [gaussianRowNorm, EuclideanSpace.real_norm_sq_eq, WithLp.ofLp_toLp]
  exact integrable_finsetSum _ (fun i _ => gaussian_coordinate_second_moment_integrable Q hKL i)

lemma gaussianRowNorm_sq_integral_le
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞) :
    (∫ z, (gaussianRowNorm z)^2 ∂Q) ≤
      2*(Fintype.card I:ℝ)+4*(klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal := by
  simp only [gaussianRowNorm, EuclideanSpace.real_norm_sq_eq, WithLp.ofLp_toLp]
  rw [integral_finsetSum _ (fun i _ => gaussian_coordinate_second_moment_integrable Q hKL i)]
  have hsingle (i : I) : (∫ z, (z i)^2 ∂Q) ≤
      2+2*(Real.sqrt (∫ z, (z i)^2 ∂Q)-1)^2 := by
    have hn : 0 ≤ ∫ z, (z i)^2 ∂Q := integral_nonneg (fun _ => sq_nonneg _)
    have hs := Real.sq_sqrt hn
    nlinarith [sq_nonneg (Real.sqrt (∫ z, (z i)^2 ∂Q)-2)]
  have hh := Finset.sum_le_sum (s:=Finset.univ) (fun i _ => hsingle i)
  rw [Finset.sum_add_distrib, ← Finset.mul_sum] at hh
  have hp := gaussian_actual_polar_deviation Q hKL
  simp only [Finset.sum_const, Finset.card_univ, nsmul_eq_mul] at hh
  nlinarith

lemma normalizedGaussianRidge_eq {U : ℝ} (S α : ℝ) (hS : S ≠ 0) (hα : α ≠ 0)
    (z : I → ℝ) (v : ParameterCube I U) :
    (gaussianRowNorm z/α)*normalizedTanh (S*gaussianRowNorm z)
      (ridgeInput (gaussianRowDirection z) v) =
      (S*α)⁻¹ * Real.tanh (gaussianLinearForm (S • WithLp.toLp 2 v.val) z) := by
  by_cases hr : gaussianRowNorm z = 0
  · have hz : WithLp.toLp 2 z = (0 : EuclideanSpace ℝ I) := norm_eq_zero.mp hr
    have hzi : z = 0 := by simpa using congrArg WithLp.ofLp hz
    subst z
    simp [gaussianRowNorm, gaussianLinearForm, inner_zero_right]
  · have harg : S*gaussianRowNorm z*ridgeInput (gaussianRowDirection z) v =
        gaussianLinearForm (S • WithLp.toLp 2 v.val) z := by
      simp only [ridgeInput, gaussianRowDirection, gaussianLinearForm,
        PiLp.inner_apply, PiLp.smul_apply, WithLp.ofLp_toLp, Real.inner_apply, smul_eq_mul]
      rw [Finset.mul_sum]
      apply Finset.sum_congr rfl
      intro i hi
      field_simp
      <;> ring
    rw [normalizedTanh, if_neg (mul_ne_zero hS hr), harg]
    field_simp
    <;> ring

/-- The normalized actual L² feature used for the scale-independent evaluator. -/
def normalizedTanhL2 (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (S α : ℝ) (v : EuclideanSpace ℝ I) : Lp ℝ 2 Q :=
  (S*α)⁻¹ • actualTanhL2 Q (S • v)

lemma normalizedTanhL2_ae (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (S α : ℝ) (v : EuclideanSpace ℝ I) :
    normalizedTanhL2 Q S α v =ᵐ[Q]
      fun z => (S*α)⁻¹ * Real.tanh (gaussianLinearForm (S • v) z) := by
  filter_upwards [Lp.coeFn_smul ((S*α)⁻¹) (actualTanhL2 Q (S • v)),
    actualTanhL2_ae Q (S • v)] with z hz ht
  simpa only [normalizedTanhL2, hz, Pi.smul_apply, smul_eq_mul, ht]

variable (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (V : Submodule ℝ (Lp ℝ 2 Q)) [FiniteDimensional ℝ V]

lemma normalizedCanonicalJoint_ae {U : ℝ} (S α : ℝ) (hS : S ≠ 0) (hα : α ≠ 0)
    (v : ParameterCube I U) :
    jointRidge (canonicalBasisValues Q V) (fun z => gaussianRowNorm z/α)
      (fun z => S*gaussianRowNorm z) gaussianRowDirection v =ᵐ[Q]
    fun z => WithLp.toLp 2
      (normalizedTanhL2 Q S α (WithLp.toLp 2 v.val) z • canonicalBasisValues Q V z,
       (normalizedTanhL2 Q S α (WithLp.toLp 2 v.val) z)^2) := by
  filter_upwards [normalizedTanhL2_ae Q S α (WithLp.toLp 2 v.val)] with z hz
  unfold jointRidge jointCanonicalObservable
  rw [normalizedGaussianRidge_eq S α hS hα, hz]

lemma normalizedCanonicalJoint_integral {U : ℝ} (S α : ℝ) (hS : S ≠ 0) (hα : α ≠ 0)
    (v : ParameterCube I U) :
    (∫ z, jointRidge (canonicalBasisValues Q V) (fun z => gaussianRowNorm z/α)
      (fun z => S*gaussianRowNorm z) gaussianRowDirection v z ∂Q) =
    WithLp.toLp 2 (projectionCoefficients V (normalizedTanhL2 Q S α (WithLp.toLp 2 v.val)),
      ‖normalizedTanhL2 Q S α (WithLp.toLp 2 v.val)‖^2) := by
  rw [integral_congr_ae (normalizedCanonicalJoint_ae Q V S α hS hα v)]
  exact canonicalJointMoment_eq Q V _

#print axioms gaussianRowNorm_sq_integral_le
#print axioms normalizedCanonicalJoint_integral
end ConditionalNonpolynomial.Analytic
