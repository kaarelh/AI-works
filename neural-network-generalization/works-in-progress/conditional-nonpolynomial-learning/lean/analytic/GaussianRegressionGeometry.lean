import GaussianAnchorLaws
import FeatureGramContraction
import GaussianDirectionSplit

noncomputable section
set_option backward.isDefEq.respectTransparency false
set_option maxHeartbeats 2000000
open MeasureTheory ProbabilityTheory
open scoped BigOperators RealInnerProductSpace
namespace ConditionalNonpolynomial.Analytic
open ConditionalAnalytic
open NeuralGeneralization.FiniteDifferential NeuralGeneralization.GaussianAngularFields
open NeuralGeneralization.GaussianAngularPrice NeuralGeneralization.GaussianFieldTilt

variable {X I : Type*} [Fintype X] [DecidableEq X] [Fintype I]

def anchorRegressionMean (S : Finset X) (c : S→ℝ) (z : X→ℝ) : ℝ :=
  ∑s:S,c s*z s

def anchorRegressionResidual (A : X→I→ℝ) (S : Finset X) (x : X) (c : S→ℝ) : I→ℝ :=
  fun i=>A x i-∑s:S,c s*A s i

@[fun_prop] theorem anchorRegressionMean_measurable (S : Finset X) (c : S→ℝ) :
    Measurable (anchorRegressionMean S c) := by unfold anchorRegressionMean; fun_prop

/-- Orthogonal projection gives an actual finite linear predictor of the query
from the anchor values, including singular anchor covariance matrices. -/
theorem exists_anchor_regression_coefficients (A : X→I→ℝ) (S : Finset X) (x : X) :
    ∃ c : S→ℝ,
      (∀s:S,∑i,anchorRegressionResidual A S x c i*A s i=0) ∧
      (∑i,(anchorRegressionResidual A S x c i)^2)≤‖WithLp.toLp 2 (A x)‖^2 := by
  classical
  let u : S→EuclideanSpace ℝ I := fun s=>WithLp.toLp 2 (A s)
  let F := Fintype.linearCombination ℝ u
  let V := F.range
  let a : EuclideanSpace ℝ I := WithLp.toLp 2 (A x)
  have hp : V.starProjection a∈F.range := V.starProjection_apply_mem a
  obtain ⟨c,hc⟩ := hp
  have hFc : F c=WithLp.toLp 2 (fun i=>∑s:S,c s*A s i) := by
    ext i
    simp [F,Fintype.linearCombination_apply,u]
  have hres : WithLp.toLp 2 (anchorRegressionResidual A S x c)=a-V.starProjection a := by
    rw [←hc,hFc]
    ext i
    rfl
  refine ⟨c,?_,?_⟩
  · intro s
    have hs : u s∈V := by
      refine ⟨Pi.single s 1,?_⟩
      simp [F]
    have hh := V.starProjection_inner_eq_zero a (u s) hs
    rw [←hres] at hh
    simpa only [PiLp.inner_apply,u,WithLp.ofLp_toLp,Real.inner_apply,mul_comm] using hh
  · have hh := Vᗮ.norm_starProjection_apply_le a
    have he : Vᗮ.starProjection a=a-V.starProjection a := by
      rw [V.starProjection_orthogonal]
      rfl
    rw [he,←hres] at hh
    have hs := pow_le_pow_left₀ (norm_nonneg _) hh 2
    rw [EuclideanSpace.norm_sq_eq] at hs
    simpa only [WithLp.ofLp_toLp,Real.norm_eq_abs,sq_abs,a] using hs

theorem anchorRegression_residual_identity (A : X→I→ℝ) (S : Finset X) (x : X)
    (c : S→ℝ) (ξ : I→ℝ) :
    fieldLinear A ξ x-anchorRegressionMean S c (maskCoordinates S (fieldLinear A ξ))=
      ∑i,anchorRegressionResidual A S x c i*ξ i := by
  classical
  simp only [fieldLinear_apply,anchorRegressionMean,maskCoordinates,Finset.coe_mem,if_true,
    anchorRegressionResidual,sub_mul,Finset.sum_sub_distrib]
  congr 1
  simp_rw [Finset.mul_sum,Finset.sum_mul]
  rw [Finset.sum_comm]
  apply Finset.sum_congr rfl
  intro s _
  apply Finset.sum_congr rfl
  intro i _
  ring

#print axioms exists_anchor_regression_coefficients
#print axioms anchorRegression_residual_identity
end ConditionalNonpolynomial.Analytic
