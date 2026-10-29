import PrescribedConditionalScore
import UniformGaussianSteering
import SteeringScoreAdapter
import ScalarPathScoreProgram
import ScaledSplitRowChannel

noncomputable section
set_option maxHeartbeats 1000000
open MeasureTheory ProbabilityTheory InformationTheory
open scoped BigOperators
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel NeuralGeneralization.BatchTwoContinuousDepthCritical

theorem residualScale_scalarBooleanState {t : ℝ} (ht : 0≤t) (f : Bool) (v r : ℝ) :
    residualScale t (scalarBooleanState f v r)=scalarBooleanState f v (t^2*r) := by
  unfold residualScale scalarBooleanState
  change WithLp.toLp 2 (labelReal f*Real.sqrt v,t*Real.sqrt r)=
    WithLp.toLp 2 (labelReal f*Real.sqrt v,Real.sqrt (t^2*r))
  rw [Real.sqrt_mul (sq_nonneg t),Real.sqrt_sq ht]

theorem uniform_prescribed_score_channel (Q : Measure ℝ) [IsProbabilityMeasure Q]
    {a r s t : ℝ} (ht : 0≤t) (hr : 0≤r) (hs : 0<s)
    (hsS : s≤controlledSignal Q a (t^2*r)) (f : Bool) :
    scalarSourceMoment (Q.prod scoreSignLaw) Prod.fst (prescribedConditionalScore Q a (t^2*r) s)
      (residualScale t (scalarBooleanState f a r))=
      scalarBooleanState f s (controlledSignal Q a (t^2*r)+controlledResidual Q a (t^2*r)-s) := by
  rw [residualScale_scalarBooleanState ht]
  exact scalarSourceMoment_prescribedConditionalScore Q (mul_nonneg (sq_nonneg _) hr) hs hsS f

/-- An actual tagged Gaussian channel reusing a critical Gaussian stage under
smaller physical noise, while preserving precisely the critical tracked signal. -/
theorem uniform_gaussian_prescribed_stage {ε a r rCrit t : ℝ}
    (hε : 0≤ε) (ha : 0≤a) (hr : 0≤r) (hrr : r≤rCrit) (ht : 0≤t) (ht1 : t≤1)
    (hS : 0<steeringSignal ((1+ε)*a) rCrit) :
    let s := steeringSignal ((1+ε)*a) rCrit
    let rnext := coolingSecondMoment ((1+ε)*a+t^2*r)-s
    (0≤rnext ∧ rnext≤steeringResidual ((1+ε)*a) rCrit) ∧
    (∀ f : Bool,
      scalarSourceMoment ((steeringControl ε).prod scoreSignLaw) Prod.fst
        (prescribedConditionalScore (steeringControl ε) a (t^2*r) s)
        (residualScale t (scalarBooleanState f a r))=scalarBooleanState f s rnext) ∧
    (∫z,(prescribedConditionalScore (steeringControl ε) a (t^2*r) s z)^2
      ∂(steeringControl ε).prod scoreSignLaw)=1 ∧
    (∀z,|prescribedConditionalScore (steeringControl ε) a (t^2*r) s z|≤1/Real.sqrt s+1) ∧
    klDiv ((steeringControl ε).prod scoreSignLaw) ((gaussianReal 0 1).prod scoreSignLaw)=
      klDiv (steeringControl ε) (gaussianReal 0 1) := by
  dsimp only
  have hstage := gaussian_stage_reuse (show 0≤(1+ε)*a by positivity) hr hrr ht ht1
  have hsS : steeringSignal ((1+ε)*a) rCrit≤controlledSignal (steeringControl ε) a (t^2*r) := by
    rw [controlledSignal_steeringControl hε ha]
    exact hstage.1
  refine ⟨⟨hstage.2.1,hstage.2.2.1⟩,?_,
    prescribedConditionalScore_unit _ hS hsS,
    prescribedConditionalScore_bound _ hS hsS,score_downgrade_kl _ _⟩
  intro f
  have hh := uniform_prescribed_score_channel (steeringControl ε) ht hr hS hsS f
  rw [controlledSignal_steeringControl hε ha,controlledResidual_steeringControl hε ha,
    steeringSignal_add_residual (show 0≤(1+ε)*a by positivity) (mul_nonneg (sq_nonneg _) hr)] at hh
  exact hh

def uniformGaussianResidual (v ε : ℕ→ℝ) (t r0 : ℝ) : ℕ→ℝ
  | 0=>r0
  | j+1=>coolingSecondMoment ((1+ε j)*v j+t^2*uniformGaussianResidual v ε t r0 j)-v (j+1)

/-- Reuse every stage of an arbitrary finite Gaussian critical schedule. There
is no monotonicity assumption about the seed's diagonal variance. Only an upper
bound on its residual by the comparator's initial residual is needed. -/
theorem uniformGaussianResidual_bounds (v rCrit ε : ℕ→ℝ) {t r0 : ℝ} {H : ℕ}
    (ht : 0≤t) (ht1 : t≤1) (hr0 : 0≤r0) (hr0le : r0≤rCrit 0)
    (hv : ∀j≤H,0≤v j) (hε : ∀j<H,0≤ε j)
    (hvs : ∀j<H,v (j+1)=steeringSignal ((1+ε j)*v j) (rCrit j))
    (hrs : ∀j<H,rCrit (j+1)=steeringResidual ((1+ε j)*v j) (rCrit j))
    (j : ℕ) (hj : j≤H) :
    0≤uniformGaussianResidual v ε t r0 j ∧ uniformGaussianResidual v ε t r0 j≤rCrit j := by
  induction j with
  | zero=>exact ⟨hr0,hr0le⟩
  | succ j ih=>
    have hjlt : j<H := by omega
    have hb := ih (by omega)
    have hstage := gaussian_stage_reuse (a:=(1+ε j)*v j)
      (mul_nonneg (by linarith [hε j hjlt]) (hv j (by omega))) hb.1 hb.2 ht ht1
    simpa only [uniformGaussianResidual,hvs j hjlt,hrs j hjlt] using
      And.intro hstage.2.1 hstage.2.2.1

theorem uniformGaussianResidual_moment (v rCrit ε : ℕ→ℝ) {t r0 : ℝ} {H : ℕ}
    (ht : 0≤t) (ht1 : t≤1) (hr0 : 0≤r0) (hr0le : r0≤rCrit 0)
    (hv : ∀j≤H,0<v j) (hε : ∀j<H,0≤ε j)
    (hvs : ∀j<H,v (j+1)=steeringSignal ((1+ε j)*v j) (rCrit j))
    (hrs : ∀j<H,rCrit (j+1)=steeringResidual ((1+ε j)*v j) (rCrit j))
    (j : ℕ) (hj : j<H) (f : Bool) :
    scalarSourceMoment ((steeringControl (ε j)).prod scoreSignLaw) Prod.fst
      (prescribedConditionalScore (steeringControl (ε j)) (v j)
        (t^2*uniformGaussianResidual v ε t r0 j) (v (j+1)))
      (residualScale t (scalarBooleanState f (v j) (uniformGaussianResidual v ε t r0 j)))=
      scalarBooleanState f (v (j+1)) (uniformGaussianResidual v ε t r0 (j+1)) := by
  have hb := uniformGaussianResidual_bounds v rCrit ε ht ht1 hr0 hr0le
    (fun i hi=>(hv i hi).le) hε hvs hrs j (by omega)
  have hS : 0<steeringSignal ((1+ε j)*v j) (rCrit j) := by rw [←hvs j hj]; exact hv _ (by omega)
  have hh := (uniform_gaussian_prescribed_stage (hε j hj) (hv j (by omega)).le
    hb.1 hb.2 ht ht1 hS).2.1 f
  simpa only [uniformGaussianResidual,←hvs j hj] using hh

#print axioms uniform_gaussian_prescribed_stage
#print axioms uniformGaussianResidual_moment
end ConditionalNonpolynomial.Analytic
