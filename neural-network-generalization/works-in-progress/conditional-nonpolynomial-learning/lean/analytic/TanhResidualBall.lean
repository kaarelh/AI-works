import TanhResidualEntropy
import NeuralGeneralization.GaussianResidualIndependence

/-! A genuine ballwise residual estimate for tanh features under an arbitrary
finite-KL perturbation of the standard Gaussian coefficient law. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic

variable {I : Type*} [Fintype I]

def gaussianLinearForm (a : EuclideanSpace ℝ I) (z : I → ℝ) : ℝ :=
  ⟪a, WithLp.toLp 2 z⟫

theorem gaussianLinearForm_measurable (a : EuclideanSpace ℝ I) :
    Measurable (gaussianLinearForm a) := by
  unfold gaussianLinearForm
  fun_prop

theorem gaussianLinearForm_hasLaw (a : EuclideanSpace ℝ I) :
    HasLaw (gaussianLinearForm a) (gaussianReal 0 (‖a‖^2).toNNReal)
      (Measure.pi fun _ : I => gaussianReal 0 1) := by
  refine ⟨(gaussianLinearForm_measurable a).aemeasurable, ?_⟩
  have h := NeuralGeneralization.GaussianResidualIndependence.map_inner_eq_gaussian a
  rw [NeuralGeneralization.GaussianOrthogonal.euclideanGaussian,
    Measure.map_map (by fun_prop) (WithLp.measurable_toLp 2 (I → ℝ))] at h
  exact h

def tanhResidualFeature (a : EuclideanSpace ℝ I) (z : I → ℝ) : ℝ :=
  tanhRemainder (gaussianLinearForm a z)

/-- The square of the L²(Q) distance between two actual remainder features.
In particular its Lipschitz constant on the radius-s ball is bounded by
112(s²+sqrt(KL)), independently of the coefficient dimension. -/
theorem tanhResidualFeature_ball_difference
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (s : ℝ) (hs : 0 < s) (a b : EuclideanSpace ℝ I)
    (ha : ‖a‖ ≤ s) (hb : ‖b‖ ≤ s) :
    Integrable (fun z => (tanhResidualFeature a z-tanhResidualFeature b z)^2) Q ∧
    (∫ z, (tanhResidualFeature a z-tanhResidualFeature b z)^2 ∂Q) ≤
      ‖a-b‖^2 * (16*(klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal+12544*s^4) := by
  by_cases hab : a = b
  · subst b
    simp
  have hδ : 0 < ‖a-b‖ := norm_pos_iff.mpr (sub_ne_zero.mpr hab)
  let an : EuclideanSpace ℝ I := s⁻¹ • a
  let bn : EuclideanSpace ℝ I := s⁻¹ • b
  let dn : EuclideanSpace ℝ I := ‖a-b‖⁻¹ • (a-b)
  have han : ‖an‖ ≤ 1 := by
    dsimp [an]
    rw [norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hs]
    have h := mul_le_mul_of_nonneg_left ha (inv_nonneg.mpr hs.le)
    simpa [inv_mul_cancel₀ hs.ne'] using h
  have hbn : ‖bn‖ ≤ 1 := by
    dsimp [bn]
    rw [norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hs]
    have h := mul_le_mul_of_nonneg_left hb (inv_nonneg.mpr hs.le)
    simpa [inv_mul_cancel₀ hs.ne'] using h
  have hdn : ‖dn‖ ≤ 1 := by
    dsimp [dn]
    rw [norm_smul, Real.norm_eq_abs, abs_inv, abs_of_pos hδ, inv_mul_cancel₀ hδ.ne']
  have hvar (v : EuclideanSpace ℝ I) (hv : ‖v‖ ≤ 1) : (‖v‖^2).toNNReal ≤ 1 := by
    apply Real.toNNReal_le_iff_le_coe.mpr
    change ‖v‖^2 ≤ (1 : ℝ)
    nlinarith [norm_nonneg v]
  have hA (z : I → ℝ) : s*gaussianLinearForm an z = gaussianLinearForm a z := by
    dsimp [gaussianLinearForm, an]
    rw [real_inner_smul_left]
    field_simp
  have hB (z : I → ℝ) : s*gaussianLinearForm bn z = gaussianLinearForm b z := by
    dsimp [gaussianLinearForm, bn]
    rw [real_inner_smul_left]
    field_simp
  have hrel (z : I → ℝ) : s*gaussianLinearForm an z-s*gaussianLinearForm bn z =
      ‖a-b‖*gaussianLinearForm dn z := by
    rw [hA, hB]
    dsimp [gaussianLinearForm, dn]
    rw [real_inner_smul_left, inner_sub_left]
    field_simp
  have h := tanhRemainder_entropy_difference_sq Q
    (Measure.pi fun _ : I => gaussianReal 0 1) hKL
    (gaussianLinearForm an) (gaussianLinearForm bn) (gaussianLinearForm dn)
    (gaussianLinearForm_measurable an) (gaussianLinearForm_measurable bn) s ‖a-b‖ hδ.ne' hrel
    (‖dn‖^2).toNNReal (‖an‖^2).toNNReal (‖bn‖^2).toNNReal
    (hvar dn hdn) (hvar an han) (hvar bn hbn)
    (gaussianLinearForm_hasLaw dn) (gaussianLinearForm_hasLaw an) (gaussianLinearForm_hasLaw bn)
  simpa only [hA, hB, tanhResidualFeature] using h

theorem tanhResidualFeature_ball_rms_lipschitz
    (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1) ≠ ∞)
    (s : ℝ) (hs : 0 < s) (a b : EuclideanSpace ℝ I)
    (ha : ‖a‖ ≤ s) (hb : ‖b‖ ≤ s) :
    Real.sqrt (∫ z, (tanhResidualFeature a z-tanhResidualFeature b z)^2 ∂Q) ≤
      112 * (s^2+Real.sqrt ((klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal)) * ‖a-b‖ := by
  have hbnd := (tanhResidualFeature_ball_difference Q hKL s hs a b ha hb).2
  let D := (klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal
  have hD : 0 ≤ D := ENNReal.toReal_nonneg
  have hsD := Real.sq_sqrt hD
  have hscalar : 16*D+12544*s^4 ≤ 12544*(s^2+Real.sqrt D)^2 := by
    have hc : 0 ≤ s^2*Real.sqrt D := mul_nonneg (sq_nonneg s) (Real.sqrt_nonneg D)
    nlinarith
  apply (Real.sqrt_le_left (show 0 ≤ 112*(s^2+Real.sqrt D)*‖a-b‖ by positivity)).mpr
  calc
    _ ≤ ‖a-b‖^2 * (16*D+12544*s^4) := hbnd
    _ ≤ ‖a-b‖^2 * (12544*(s^2+Real.sqrt D)^2) :=
      mul_le_mul_of_nonneg_left hscalar (sq_nonneg _)
    _ = _ := by ring

#print axioms tanhResidualFeature_ball_difference
#print axioms tanhResidualFeature_ball_rms_lipschitz
end ConditionalNonpolynomial.Analytic
