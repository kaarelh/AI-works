import ControlledLayerTransfer
import HilbertCovarianceRepair
import Mathlib.MeasureTheory.Function.L2Space

noncomputable section
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators InnerProductSpace ENNReal
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization NeuralGeneralization.FiniteDifferential
open NeuralGeneralization.GaussianAngularFields

variable {Ω : Type*} [MeasurableSpace Ω]

lemma bounded_memLp_two (Q : Measure Ω) [IsFiniteMeasure Q]
    (f : Ω → ℝ) (hf : Measurable f) (hb : ∀ x, |f x| ≤ 1) : MemLp f 2 Q := by
  apply (memLp_const (1:ℝ)).mono' hf.aestronglyMeasurable
  filter_upwards [] with x
  exact hb x

noncomputable def boundedL2Feature (Q : Measure Ω) [IsFiniteMeasure Q]
    (f : Ω → ℝ) (hf : Measurable f) (hb : ∀ x, |f x| ≤ 1) : Lp ℝ 2 Q :=
  (bounded_memLp_two Q f hf hb).toLp f

lemma boundedL2Feature_ae (Q : Measure Ω) [IsFiniteMeasure Q]
    (f : Ω → ℝ) (hf : Measurable f) (hb : ∀ x, |f x| ≤ 1) :
    boundedL2Feature Q f hf hb =ᵐ[Q] f :=
  (bounded_memLp_two Q f hf hb).coeFn_toLp

lemma boundedL2Feature_inner (Q : Measure Ω) [IsFiniteMeasure Q]
    (f g : Ω → ℝ) (hf : Measurable f) (hg : Measurable g)
    (hfb : ∀ x, |f x| ≤ 1) (hgb : ∀ x, |g x| ≤ 1) :
    inner ℝ (boundedL2Feature Q f hf hfb) (boundedL2Feature Q g hg hgb) =
      ∫ x, f x*g x ∂Q := by
  rw [L2.inner_def]
  apply integral_congr_ae
  filter_upwards [boundedL2Feature_ae Q f hf hfb,boundedL2Feature_ae Q g hg hgb] with x hfx hgx
  simp only [hfx,hgx,Real.inner_apply]

lemma boundedL2Feature_norm_sub_sq (Q : Measure Ω) [IsFiniteMeasure Q]
    (f g : Ω → ℝ) (hf : Measurable f) (hg : Measurable g)
    (hfb : ∀ x, |f x| ≤ 1) (hgb : ∀ x, |g x| ≤ 1) :
    ‖boundedL2Feature Q f hf hfb-boundedL2Feature Q g hg hgb‖^2 =
      ∫ x, (f x-g x)^2 ∂Q := by
  rw [← real_inner_self_eq_norm_sq,L2.inner_def]
  apply integral_congr_ae
  filter_upwards [Lp.coeFn_sub (boundedL2Feature Q f hf hfb) (boundedL2Feature Q g hg hgb),
    boundedL2Feature_ae Q f hf hfb,boundedL2Feature_ae Q g hg hgb] with x hsub hfx hgx
  simp only [hsub,Pi.sub_apply,hfx,hgx,Real.inner_apply,pow_two]

variable {X I : Type*} [Fintype X] [Fintype I]

noncomputable def tanhL2Feature (Q : Measure (I → ℝ)) [IsFiniteMeasure Q]
    (A : X → I → ℝ) (x : X) : Lp ℝ 2 Q :=
  boundedL2Feature Q (fun g => Real.tanh (fieldLinear A g x))
    (by fun_prop) (fun _ => (Real.abs_tanh_lt_one _).le)

lemma tanhL2Feature_inner (Q : Measure (I → ℝ)) [IsFiniteMeasure Q]
    (A B : X → I → ℝ) (x y : X) :
    inner ℝ (tanhL2Feature Q A x) (tanhL2Feature Q B y) =
      ∫ g, Real.tanh (fieldLinear A g x)*Real.tanh (fieldLinear B g y) ∂Q :=
  boundedL2Feature_inner Q _ _ _ _ _ _

lemma tanhL2Feature_norm_sub_sq (Q : Measure (I → ℝ)) [IsFiniteMeasure Q]
    (A B : X → I → ℝ) (x : X) :
    ‖tanhL2Feature Q A x-tanhL2Feature Q B x‖^2 =
      ∫ g, (Real.tanh (fieldLinear A g x)-Real.tanh (fieldLinear B g x))^2 ∂Q :=
  boundedL2Feature_norm_sub_sq Q _ _ _ _ _ _

/-- The true L² feature distance under an arbitrary finite-KL Gaussian control.
A coarse linear gain is sufficient because its logarithm controls precision. -/
theorem tanhL2Feature_error (Q : Measure (I → ℝ)) [IsProbabilityMeasure Q]
    (hKL : klDiv Q (standardLaw I) ≠ ∞)
    (A B : X → I → ℝ) {δ : ℝ} (hδ : 0 ≤ δ)
    (hclose : ∀ x, ∑ i, (A x i-B x i)^2 ≤ δ^2) (x : X) :
    ‖tanhL2Feature Q A x-tanhL2Feature Q B x‖ ≤
      δ*(1+4*(klDiv Q (standardLaw I)).toReal+2*Fintype.card I) := by
  have h := ConditionalAnalytic.tanh_feature_repair_squared Q hKL (A x) (B x) (hclose x)
  have hn : 0 ≤ 4*(klDiv Q (standardLaw I)).toReal+2*Fintype.card I := by positivity
  have hs := tanhL2Feature_norm_sub_sq Q A B x
  simp only [fieldLinear_apply] at hs
  rw [← hs] at h
  apply (sq_le_sq₀ (norm_nonneg _) (by positivity)).mp
  have hh : 4*(klDiv Q (standardLaw I)).toReal+2*Fintype.card I ≤
      (1+4*(klDiv Q (standardLaw I)).toReal+2*Fintype.card I)^2 := by nlinarith
  have hb := mul_le_mul_of_nonneg_left hh (sq_nonneg δ)
  nlinarith

end ConditionalNonpolynomial.Analytic
