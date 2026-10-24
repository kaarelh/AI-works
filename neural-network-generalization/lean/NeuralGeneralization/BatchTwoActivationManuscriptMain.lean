import NeuralGeneralization.BatchTwoActivationStrongManuscript
import NeuralGeneralization.BatchTwoActivationUniformManuscript
import NeuralGeneralization.BatchTwoActivationEndpointEnergyWitness

/-! Closed manuscript learning statements with actual polynomial width and
energy envelopes. Enlarging the existential endpoint energy polynomial
preserves the proved reconstruction bound. -/
noncomputable section
set_option maxHeartbeats 1800000
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

theorem uniform_manuscript_learning (r : ℕ) (ℓ : ℝ) (hℓ : 1≤ℓ) :
    ∃b : ℕ,1≤b ∧ ℓ≤(b:ℝ) ∧
    ∃aP : ℝ,0<aP ∧ ∃kP : ℕ,∃aJ : ℝ,0<aJ ∧ ∃kJ : ℕ,
    (∀(d : ℕ) (K : ℝ),0≤K→(activationLearnerThreshold b d ⌈K⌉₊ (r+1):ℝ)≤aP*(1+(d:ℝ)+K)^kP) ∧
    (∀(d : ℕ) (K : ℝ),0≤K→(activationEndpointEnergyBudget b d ⌈K⌉₊ (r+1):ℝ)≤aJ*(1+(d:ℝ)+K)^kJ) ∧
    ∃A : ℝ,0<A ∧ ∃m : ℕ,
    ∀φ : ℝ→ℝ,zeroLipschitzActivation ℓ φ→
    ∀d : ℕ,1≤d→∀f : BooleanFunction d,∀C : ℕ,realizesAtComplexity (r:=r) φ f C→
    ∀D : InputLaw d,∀ε δ : ℝ,0<ε→ε<1→0<δ→δ<1→∀n : ℕ,
    (2/ε)*(manuscriptLogCapacity d r ℓ (manuscriptCombinedEnergy
      (fun d K=>aP*(1+d+K)^kP)
      (manuscriptEnlargedEndpoint r A m (fun d K=>aJ*(1+d+K)^kJ)) d C r ℓ ε)+
      Real.log (1/δ))≤(n:ℝ)→
    (∀N,C≤N→∀t,0<t→t≤1→∀s : Fin n→Cube d,
      0<posteriorDenominator φ (1/2) (activationBandPrior d N r t) f s) ∧
    1-δ≤sampleProbability D n (fun s=>∀N,C≤N→∀t,0<t→t≤1→
      posteriorRisk D f (networkPosterior φ (1/2) (activationBandPrior d N r t) f s)≤ε) := by
  obtain ⟨B,hB,hB',hB''⟩ := scalarCutoff_uniform_bounds
  let b : ℕ := 1+⌈ℓ⌉₊+⌈B⌉₊
  have hb : 1≤b := by dsimp [b];omega
  have hℓb : ℓ≤(b:ℝ) := by
    exact (Nat.le_ceil ℓ).trans (by exact_mod_cast (show ⌈ℓ⌉₊≤b by dsimp [b];omega))
  obtain ⟨aP,haP,kP,hP⟩ := (activationLearnerThreshold_polynomial b (r+1)).shifted_ceil_real_envelope
  obtain ⟨aJ,haJ,kJ,hJ⟩ := (activationEndpointEnergyBudget_polynomial b (r+1)).shifted_ceil_real_envelope
  obtain ⟨A,hA,m,hmain⟩ := uniform_manuscript_sample_bound r ℓ hℓ
  refine ⟨b,hb,hℓb,aP,haP,kP,aJ,haJ,kJ,?_,?_,A,hA,m,?_⟩
  · intro d K hK
    simpa only [zero_add,Nat.cast_zero,add_zero] using hP d 0 K hK
  · intro d K hK
    simpa only [zero_add,Nat.cast_zero,add_zero] using hJ d 0 K hK
  · apply hmain
    intro d K hd hK
    positivity

#print axioms strong_prior_manuscript_learning
#print axioms uniform_manuscript_learning
end NeuralGeneralization.BatchTwoActivation
