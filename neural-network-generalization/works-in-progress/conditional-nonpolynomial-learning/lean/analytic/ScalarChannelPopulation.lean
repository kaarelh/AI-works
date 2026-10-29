import ScalarScoreGeometry
import DimensionFreeGaussianTransfer
import ScalarChannelSamplingMetric

/-! Actual population scalar-channel error propagation under arbitrary
finite-entropy Gaussian-coordinate controls, including auxiliary score tags. -/
noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators ENNReal RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields

variable {Ω I : Type*} [MeasurableSpace Ω] [Fintype I]

def scalarChannelFeature (Z : Ω→I→ℝ) (a : EuclideanSpace ℝ I) (z : Ω) : ℝ :=
  Real.tanh (gaussianLinearForm a (Z z))

lemma scalarChannelFeature_measurable (Z : Ω→I→ℝ) (hZ : Measurable Z)
    (a : EuclideanSpace ℝ I) : Measurable (scalarChannelFeature Z a) := by
  unfold scalarChannelFeature gaussianLinearForm
  fun_prop

lemma scalarChannelFeature_bound (Z : Ω→I→ℝ) (a : EuclideanSpace ℝ I) (z : Ω) :
    |scalarChannelFeature Z a z|≤1 := (Real.abs_tanh_lt_one _).le

def scalarChannelMoment (Q : Measure Ω) (Z : Ω→I→ℝ) (b : Ω→ℝ)
    (a : EuclideanSpace ℝ I) : WithLp 2 (ℝ×ℝ) :=
  canonicalCompletion (∫z,b z*scalarChannelFeature Z a z ∂Q)
    (∫z,(scalarChannelFeature Z a z)^2 ∂Q)

/-- The projection score may depend on arbitrary auxiliary variables.
Only the actual law of the Gaussian coordinates enters the entropy gain. -/
theorem scalarChannelMoment_lipschitz (Q : Measure Ω) [IsProbabilityMeasure Q]
    (Z : Ω→I→ℝ) (hZ : Measurable Z) (b : Ω→ℝ) (hb : MemLp b 2 Q)
    (hunit : (∫z,(b z)^2 ∂Q)=1)
    (hKL : klDiv (Q.map Z) (standardLaw I)≠∞)
    (a a' : EuclideanSpace ℝ I) :
    ‖scalarChannelMoment Q Z b a-scalarChannelMoment Q Z b a'‖≤
      (1+Real.sqrt (2*(klDiv (Q.map Z) (standardLaw I)).toReal))*‖a-a'‖ := by
  letI : IsProbabilityMeasure (Q.map Z) := Measure.isProbabilityMeasure_map hZ.aemeasurable
  let f := scalarChannelFeature Z a
  let g := scalarChannelFeature Z a'
  have hf : Measurable f := scalarChannelFeature_measurable Z hZ a
  have hg : Measurable g := scalarChannelFeature_measurable Z hZ a'
  have hfb : ∀z,|f z|≤1 := scalarChannelFeature_bound Z a
  have hgb : ∀z,|g z|≤1 := scalarChannelFeature_bound Z a'
  have hdist : ‖boundedL2Feature Q f hf hfb-boundedL2Feature Q g hg hgb‖=
      ‖actualTanhL2 (Q.map Z) a-actualTanhL2 (Q.map Z) a'‖ := by
    apply (sq_eq_sq₀ (norm_nonneg _) (norm_nonneg _)).mp
    rw [boundedL2Feature_norm_sub_sq,actualTanhL2_distance_sq,
      integral_map hZ.aemeasurable (by unfold gaussianLinearForm; fun_prop)]
    rfl
  have hs := scalarScore_moment_distance Q b f g hb hunit hf hg hfb hgb
  rw [hdist] at hs
  exact hs.trans (actualTanhL2_dimension_free (Q.map Z) hKL a a')

/-- The exact multiplicative loss is at most exp(sqrt(2D)), so products over
depth depend on the square-root entropy sum rather than depth itself. -/
theorem scalarChannelMoment_lipschitz_exp (Q : Measure Ω) [IsProbabilityMeasure Q]
    (Z : Ω→I→ℝ) (hZ : Measurable Z) (b : Ω→ℝ) (hb : MemLp b 2 Q)
    (hunit : (∫z,(b z)^2 ∂Q)=1)
    (hKL : klDiv (Q.map Z) (standardLaw I)≠∞)
    (a a' : EuclideanSpace ℝ I) :
    ‖scalarChannelMoment Q Z b a-scalarChannelMoment Q Z b a'‖≤
      Real.exp (Real.sqrt (2*(klDiv (Q.map Z) (standardLaw I)).toReal))*‖a-a'‖ := by
  apply (scalarChannelMoment_lipschitz Q Z hZ b hb hunit hKL a a').trans
  apply mul_le_mul_of_nonneg_right _ (norm_nonneg _)
  simpa only [add_comm] using Real.add_one_le_exp
    (Real.sqrt (2*(klDiv (Q.map Z) (standardLaw I)).toReal))

#print axioms scalarChannelMoment_lipschitz
#print axioms scalarChannelMoment_lipschitz_exp
end ConditionalNonpolynomial.Analytic
