import NeuralGeneralization.BatchTwoContinuousSphereAnticoncentration
import NeuralGeneralization.BatchTwoContinuousSphereSymmetry
import NeuralGeneralization.BatchTwoContinuousSphereTeacher
import NeuralGeneralization.BatchTwoContinuousSphereBudget
import NeuralGeneralization.BatchTwoContinuousStrongMain
import NeuralGeneralization.BatchTwoContinuousFiniteMain

/-! The paper's full-sphere sign-confidence corollary. The likelihood is
conditioned on real tanh scores with tolerance epsilon/(12 sqrt d).
The budget is an explicit polynomial, independent of learner width. -/
noncomputable section
set_option backward.isDefEq.respectTransparency false
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.BatchTwoContinuousSphere
open ConcreteModel BatchTwoContinuous BatchTwoNonGaussian CompressionSampling

/-- Every fixed gamma≥1, including the mean-field endpoint, at every N≥1.
The teacher is exactly tanh of the first coordinate, on the whole sphere. -/
theorem spherical_score_learning_finite_scale (ν : CoordinateLaw) (γ : ℝ) (hγ : 1≤γ) :
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ, ∀ k N : ℕ, 1≤N →
    ∀ ε δ : ℝ, 0<ε → ε<1 → 0<δ → δ<1 → ∀ n : ℕ,
    sphereSampleBudget A m k ε δ≤(n:ℝ) →
    1-δ≤(iidSamples (uniformSphere (k+1)) n).real {s |
      let Q := BatchTwoContinuous.posterior Real.tanh (BatchTwoNonGaussian.powerPrior ν (k+1) N 0 γ)
        (fun x => Real.tanh (x 0)) (scoreTolerance k ε) s
      Classification.confidenceFailure Real.tanh (uniformSphere (k+1)) Q
        (scoreLabel (fun x => Real.tanh (x 0)))≤ε} := by
  obtain ⟨A,hA,m,hlearn⟩ := finiteScaleRegression 0 ν γ hγ
  refine ⟨A,hA,m,?_⟩
  intro k N hN ε δ hε hε1 hδ hδ1 n hn
  obtain ⟨hρ,hρτ,_,_⟩ := score_parameters k hε hε1
  have hb := (sphere_finite_budget hA.le m k hε hε1 hδ).trans hn
  have h := hlearn (k+1) 1 (by omega) (by omega) 1 (by norm_num)
    (scoreTeacher k) (scoreTeacher_bounded k) (inputBall (k+1)) (inputBall_admissible (k+1))
    N hN (uniformSphere (k+1)) inferInstance (uniformSphere_inputBall k)
    (scoreTolerance k ε) (scoreAccuracy k ε) (ε/2) δ hρ hρτ (by positivity)
    (by linarith) hδ hδ1 n hb
  have hw : BatchTwoContinuous.output Real.tanh (scoreTeacher k)=fun x => Real.tanh (x 0) :=
    funext (scoreTeacher_output k)
  rw [hw] at h
  apply h.trans
  apply measureReal_mono ?_ (measure_ne_top _ _)
  intro s hs
  letI : IsFiniteMeasure (BatchTwoContinuous.posterior Real.tanh
      (BatchTwoNonGaussian.powerPrior ν (k+1) N 0 γ)
      (fun x => Real.tanh (x 0)) (scoreTolerance k ε) s) := by
    unfold BatchTwoContinuous.posterior
    infer_instance
  apply spherical_score_to_sign Real.tanh _ hε
  exact hs.2

/-- Strong-prior scale threshold is chosen before confidence and sample size.
The theorem uses the actual coordinate prior and score-conditioned posterior. -/
theorem spherical_score_learning_strong_prior (ν : CoordinateLaw) :
    ∃ A : ℝ, 0<A ∧ ∃ m : ℕ, ∀ k N : ℕ, 1≤N →
    ∀ ε : ℝ, 0<ε → ε<1 → ∃ σ₀ : ℝ, 0<σ₀ ∧
    ∀ σ : ℝ, 0<σ → σ<σ₀ → ∀ δ : ℝ, 0<δ → δ<1 → ∀ n : ℕ,
    sphereSampleBudget A m k ε δ≤(n:ℝ) →
    1-δ≤(iidSamples (uniformSphere (k+1)) n).real {s |
      let Q := BatchTwoContinuous.posterior Real.tanh (BatchTwoNonGaussian.smallPrior ν (k+1) N 0 σ)
        (fun x => Real.tanh (x 0)) (scoreTolerance k ε) s
      Classification.confidenceFailure Real.tanh (uniformSphere (k+1)) Q
        (scoreLabel (fun x => Real.tanh (x 0)))≤ε} := by
  obtain ⟨A,hA,m,hlearn⟩ := strongPriorRegression 0 ν
  refine ⟨A,hA,m,?_⟩
  intro k N hN ε hε hε1
  obtain ⟨hρ,hρτ,_,_⟩ := score_parameters k hε hε1
  obtain ⟨σ₀,hσ₀,hs⟩ := hlearn (k+1) 1 (by omega) (by omega) 1 (by norm_num)
    (scoreTeacher k) (scoreTeacher_bounded k) (inputBall (k+1)) (inputBall_admissible (k+1))
    N hN (scoreTolerance k ε) (scoreAccuracy k ε) (ε/2) hρ hρτ (by positivity) (by linarith)
  refine ⟨σ₀,hσ₀,?_⟩
  intro σ hσ hσlt δ hδ hδ1 n hn
  have h := hs σ hσ hσlt (uniformSphere (k+1)) inferInstance (uniformSphere_inputBall k)
    δ hδ hδ1 n ((sphere_strong_budget hA.le m k hε hε1).trans hn)
  have hw : BatchTwoContinuous.output Real.tanh (scoreTeacher k)=fun x => Real.tanh (x 0) :=
    funext (scoreTeacher_output k)
  rw [hw] at h
  apply h.trans
  apply measureReal_mono ?_ (measure_ne_top _ _)
  intro s hs
  letI : IsFiniteMeasure (BatchTwoContinuous.posterior Real.tanh
      (BatchTwoNonGaussian.smallPrior ν (k+1) N 0 σ)
      (fun x => Real.tanh (x 0)) (scoreTolerance k ε) s) := by
    unfold BatchTwoContinuous.posterior
    infer_instance
  apply spherical_score_to_sign Real.tanh _ hε
  exact hs.2

#print axioms spherical_score_learning_finite_scale
#print axioms spherical_score_learning_strong_prior
end NeuralGeneralization.BatchTwoContinuousSphere
