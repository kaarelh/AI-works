import ActualGaussianL2Layer
import BoundedTiltLift

noncomputable section
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal NNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.ConcreteModel NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields NeuralGeneralization.GaussianFieldTilt
open NeuralGeneralization.BoundedTilt ConditionalAnalytic

variable {I X : Type*} [Fintype I] [Fintype X]

/-- Actual L² tanh features have Gaussian entropy gain 1+sqrt(2D), with no
ambient dimension factor. -/
theorem actualTanhL2_dimension_free (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)≠∞)
    (a b : EuclideanSpace ℝ I) :
    ‖actualTanhL2 Q a-actualTanhL2 Q b‖≤
      (1+Real.sqrt (2*(klDiv Q (Measure.pi fun _ : I => gaussianReal 0 1)).toReal))*‖a-b‖ := by
  have hpoint : ∀ᵐz ∂Q, ‖(actualTanhL2 Q a-actualTanhL2 Q b) z‖≤
      ‖linearL2Map Q hKL (a-b) z‖ := by
    filter_upwards [Lp.coeFn_sub (actualTanhL2 Q a) (actualTanhL2 Q b),
      actualTanhL2_ae Q a,actualTanhL2_ae Q b,linearL2Map_ae Q hKL (a-b)] with z hs ha hb hl
    have ht := tanh_lipschitzWith.dist_le_mul (gaussianLinearForm a z) (gaussianLinearForm b z)
    simp only [Real.dist_eq,NNReal.coe_one,one_mul] at ht
    simpa only [hs,Pi.sub_apply,ha,hb,hl,Real.norm_eq_abs,gaussianLinearForm,inner_sub_left] using ht
  exact (Lp.norm_le_norm_of_ae_le hpoint).trans (linearL2Map_norm_le Q hKL (a-b))

lemma actualTanhL2_distance_sq (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (a b : EuclideanSpace ℝ I) :
    ‖actualTanhL2 Q a-actualTanhL2 Q b‖^2=
      ∫z,(Real.tanh (gaussianLinearForm a z)-Real.tanh (gaussianLinearForm b z))^2 ∂Q :=
  boundedL2Feature_norm_sub_sq Q _ _ _ _ _ _

/-- Raw-array form of the same one-query bound. It applies to arbitrary
finite-KL controls, not only bounded exponential tilts. -/
theorem tanh_feature_dimension_free_squared (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I)≠∞) (a b : I → ℝ) {δ : ℝ}
    (hclose : ∑i,(a i-b i)^2≤δ^2) :
    (∫z,(Real.tanh (∑i,a i*z i)-Real.tanh (∑i,b i*z i))^2 ∂Q)≤
      (1+Real.sqrt (2*(klDiv Q (standardLaw I)).toReal))^2*δ^2 := by
  let u : EuclideanSpace ℝ I := WithLp.toLp 2 a
  let v : EuclideanSpace ℝ I := WithLp.toLp 2 b
  have hnorm : ‖u-v‖^2≤δ^2 := by
    rw [PiLp.norm_sq_eq_of_L2]
    simpa only [Real.norm_eq_abs,sq_abs,PiLp.sub_apply,u,v,WithLp.ofLp_toLp] using hclose
  have hh := actualTanhL2_dimension_free Q hKL u v
  have hs := pow_le_pow_left₀ (norm_nonneg _) hh 2
  rw [actualTanhL2_distance_sq,mul_pow] at hs
  have hm := mul_le_mul_of_nonneg_left hnorm
    (sq_nonneg (1+Real.sqrt (2*(klDiv Q (standardLaw I)).toReal)))
  have hid (a : I → ℝ) (z : I → ℝ) : gaussianLinearForm (WithLp.toLp 2 a) z=∑i,a i*z i := by
    simp only [gaussianLinearForm,PiLp.inner_apply,WithLp.ofLp_toLp,Real.inner_apply]
  simpa only [u,v,hid,standardLaw] using hs.trans hm

/-- Lift the actual bounded tilt to common Gaussian coordinates. Every
one-query feature error has dimension-free multiplicative gain. This is the
linear recurrence estimate whose product is exp(O(sum sqrt(D_j))). -/
theorem controlled_gaussian_dimension_free_coupling
    (A B : X → I → ℝ) (V : (X → ℝ) → ℝ) (hV : Measurable V)
    {K : ℝ} (hbound : ∀z,|V z|≤K) {δ : ℝ}
    (hclose : ∀x,∑i,(A x i-B x i)^2≤δ^2) :
    ∃Q : Measure (I → ℝ), IsProbabilityMeasure Q ∧
      klDiv Q (standardLaw I)≠∞ ∧
      (klDiv Q (standardLaw I)).toReal=
        (klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal ∧
      Q.map (fieldLinear A)=(fieldLaw A).tilted V ∧
      ∀x,(∫z,(Real.tanh (fieldLinear A z x)-Real.tanh (fieldLinear B z x))^2 ∂Q)≤
        (1+Real.sqrt (2*(klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal))^2*δ^2 := by
  let μ := standardLaw I
  let Q := μ.tilted (V ∘ fieldLinear A)
  have hA : Measurable (fieldLinear A) := (fieldLinear A).continuous.measurable
  letI : IsProbabilityMeasure Q := tilted_probability μ (V ∘ fieldLinear A)
    (hV.comp hA) (fun z => hbound (fieldLinear A z))
  have hKL : klDiv Q μ≠∞ := boundedTilt_klDiv_ne_top μ
    (V ∘ fieldLinear A) (hV.comp hA) (fun z => hbound (fieldLinear A z))
  have hcost : (klDiv Q (standardLaw I)).toReal=
      (klDiv ((fieldLaw A).tilted V) (fieldLaw A)).toReal :=
    klDiv_tilted_pullback μ (fieldLinear A) hA V hV hbound
  refine ⟨Q,inferInstance,hKL,hcost,map_tilted_pullback μ (fieldLinear A) hA V hV,?_⟩
  intro x
  simpa only [fieldLinear_apply,hcost] using
    tanh_feature_dimension_free_squared Q hKL (A x) (B x) (hclose x)

#print axioms actualTanhL2_dimension_free
#print axioms tanh_feature_dimension_free_squared
#print axioms controlled_gaussian_dimension_free_coupling
end ConditionalNonpolynomial.Analytic
