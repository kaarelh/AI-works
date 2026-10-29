import TanhResidualBall
import ScalarVarianceSum
import NeuralGeneralization.GaussianFieldTilt

/-! Exact standardized scalar controls extracted from an actual controlled
Gaussian field, including the exclusion of zero-variance coordinates. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianFieldTilt
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

variable {X I : Type*} [Fintype X] [Fintype I]

theorem field_coordinate_hasLaw (A : X → I → ℝ) (x : X) :
    HasLaw (fun z : X → ℝ => z x)
      (gaussianReal 0 (‖WithLp.toLp 2 (A x)‖^2).toNNReal) (fieldLaw A) := by
  refine ⟨(measurable_pi_apply x).aemeasurable, ?_⟩
  unfold fieldLaw
  rw [Measure.map_map (measurable_pi_apply x) (fieldLinear A).continuous.measurable]
  have heq : (fun z : X → ℝ => z x) ∘ fieldLinear A =
      gaussianLinearForm (WithLp.toLp 2 (A x)) := by
    funext z
    simp only [Function.comp_apply, fieldLinear_apply, gaussianLinearForm, PiLp.inner_apply,
      WithLp.ofLp_toLp, Real.inner_apply]
  rw [heq]
  exact (gaussianLinearForm_hasLaw (WithLp.toLp 2 (A x))).map_eq

theorem controlled_field_zero_coordinate (A : X → I → ℝ) (x : X)
    (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A) ≠ ∞) (hzero : ‖WithLp.toLp 2 (A x)‖^2 = 0) :
    ∀ᵐ z ∂Q, z x = 0 := by
  have hLaw := field_coordinate_hasLaw A x
  have hnull : (fieldLaw A) {z : X → ℝ | z x ≠ 0} = 0 := by
    have hh := hLaw.measure_eq (p := fun z : ℝ => z ≠ 0) (by measurability)
    rw [hzero, Real.toNNReal_zero, gaussianReal_zero_var] at hh
    simpa using hh
  exact ae_iff.mpr ((klDiv_ne_top_iff.mp hKL).1 hnull)

theorem controlled_field_positive_source (A : X → I → ℝ) (x : X)
    (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A) ≠ ∞)
    (hpos : 0 < ∫ z, (Real.tanh (z x))^2 ∂Q) :
    0 < ‖WithLp.toLp 2 (A x)‖^2 := by
  rcases (sq_nonneg ‖WithLp.toLp 2 (A x)‖).eq_or_lt with hz | hp
  · have heq := controlled_field_zero_coordinate A x Q hKL hz.symm
    have hi : (∫ z, (Real.tanh (z x))^2 ∂Q) = 0 := by
      calc
        _ = ∫ z, (0:ℝ) ∂Q := integral_congr_ae (heq.mono fun z hz => by simp [hz])
        _ = 0 := integral_zero _ _
    linarith
  · exact hp

theorem field_coordinate_standardized_law (A : X → I → ℝ) (x : X)
    (hpos : 0 < ‖WithLp.toLp 2 (A x)‖^2) :
    HasLaw (fun z : X → ℝ => (Real.sqrt (‖WithLp.toLp 2 (A x)‖^2))⁻¹*z x)
      (gaussianReal 0 1) (fieldLaw A) := by
  let a := ‖WithLp.toLp 2 (A x)‖^2
  have ha : 0 < a := hpos
  have h := gaussianReal_const_mul (field_coordinate_hasLaw A x) ((Real.sqrt a)⁻¹)
  have hv : (NNReal.mk ((Real.sqrt a)⁻¹^2) (sq_nonneg _))*a.toNNReal = 1 := by
    apply NNReal.coe_injective
    simp only [NNReal.coe_mul, NNReal.coe_mk, Real.coe_toNNReal _ ha.le, NNReal.coe_one]
    rw [inv_pow, Real.sq_sqrt ha.le, inv_mul_cancel₀ ha.ne']
  change HasLaw (fun z => (Real.sqrt a)⁻¹*z x)
    (gaussianReal ((Real.sqrt a)⁻¹*0) ((NNReal.mk ((Real.sqrt a)⁻¹^2) (sq_nonneg _))*a.toNNReal))
    (fieldLaw A) at h
  simpa only [mul_zero, hv] using h

/-- Standardization preserves the actual tanh second moment and can only
decrease the actual KL charge, by data processing. -/
theorem controlled_field_scalar_step (A : X → I → ℝ) (x : X)
    (Q : Measure (X → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (fieldLaw A) ≠ ∞)
    (hpos : 0 < ∫ z, (Real.tanh (z x))^2 ∂Q) :
    ∃ P : Measure ℝ, IsProbabilityMeasure P ∧ klDiv P (gaussianReal 0 1) ≠ ∞ ∧
      (klDiv P (gaussianReal 0 1)).toReal ≤ (klDiv Q (fieldLaw A)).toReal ∧
      scalarTransition (‖WithLp.toLp 2 (A x)‖^2) P = ∫ z, (Real.tanh (z x))^2 ∂Q := by
  let a := ‖WithLp.toLp 2 (A x)‖^2
  have ha : 0 < a := controlled_field_positive_source A x Q hKL hpos
  let T : (X → ℝ) → ℝ := fun z => (Real.sqrt a)⁻¹*z x
  have hT : Measurable T := by dsimp [T]; fun_prop
  have hmap : (fieldLaw A).map T = gaussianReal 0 1 :=
    (field_coordinate_standardized_law A x ha).map_eq
  have hdata := NeuralGeneralization.RobustEntropy.klDiv_map_le Q (fieldLaw A) hT
  rw [hmap] at hdata
  have hf : klDiv (Q.map T) (gaussianReal 0 1) ≠ ∞ :=
    ne_of_lt (lt_of_le_of_lt hdata (lt_top_iff_ne_top.mpr hKL))
  refine ⟨Q.map T, Measure.isProbabilityMeasure_map hT.aemeasurable, hf,
    ENNReal.toReal_mono hKL hdata, ?_⟩
  unfold scalarTransition varianceTest
  rw [integral_map hT.aemeasurable (by fun_prop)]
  apply integral_congr_ae
  filter_upwards [] with z
  dsimp [T]
  rw [← mul_assoc, mul_inv_cancel₀ (Real.sqrt_pos.mpr ha).ne', one_mul]

#print axioms controlled_field_scalar_step
end ConditionalNonpolynomial.Analytic
