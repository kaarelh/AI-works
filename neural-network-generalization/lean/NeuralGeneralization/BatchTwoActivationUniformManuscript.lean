import NeuralGeneralization.BatchTwoActivationManuscriptBudgets

/-!
# The literal manuscript sample formula, with an enlarged endpoint polynomial

The endpoint energy polynomial is existential in the manuscript. Enlarging
it preserves any proved compression property. This theorem shows how to
choose that enlargement so the displayed `B(J_*)` bound follows from the
already proved uniform learning theorem, without changing its hypotheses
or narrowing the simultaneous width/scale event.
-/
noncomputable section
set_option maxHeartbeats 1600000
namespace NeuralGeneralization.BatchTwoActivation
open ConcreteModel

def manuscriptEnlargedEndpoint (r:ℕ) (A:ℝ) (m:ℕ) (J₀:ℝ→ℝ→ℝ) (d K:ℝ) : ℝ :=
  J₀ d K+((r:ℝ)+2)*(A*(1+d+K)^m+1)

theorem uniform_manuscript_sample_bound (r:ℕ) (ℓ:ℝ) (hℓ:1≤ℓ) :
    ∃A:ℝ,0<A ∧ ∃m:ℕ,
    ∀P J₀:ℝ→ℝ→ℝ,(∀d K,0≤d→0≤K→0≤J₀ d K)→
    ∀φ:ℝ→ℝ,zeroLipschitzActivation ℓ φ→
    ∀d:ℕ,1≤d→∀f:BooleanFunction d,∀C:ℕ,realizesAtComplexity (r:=r) φ f C→
    ∀D:InputLaw d,∀ε δ:ℝ,0<ε→ε<1→0<δ→δ<1→∀n:ℕ,
    (2/ε)*(manuscriptLogCapacity d r ℓ
      (manuscriptCombinedEnergy P (manuscriptEnlargedEndpoint r A m J₀) d C r ℓ ε)+
      Real.log (1/δ))≤(n:ℝ)→
    (∀N,C≤N→∀t,0<t→t≤1→∀s:Fin n→Cube d,
      0<posteriorDenominator φ (1/2) (activationBandPrior d N r t) f s) ∧
    1-δ≤sampleProbability D n (fun s=>∀N,C≤N→∀t,0<t→t≤1→
      posteriorRisk D f (networkPosterior φ (1/2) (activationBandPrior d N r t) f s)≤ε) := by
  obtain ⟨A,hA,m,hlearn⟩:=uniform_unbounded_activation_learning r ℓ hℓ
  refine ⟨A,hA,m,?_⟩
  intro P J₀ hJ₀ φ hφ d hd f C hf D ε δ hε hε1 hδ hδ1 n hn
  have hlog0:0≤Real.log (1/ε):=Real.log_nonneg ((one_le_div hε).mpr hε1.le)
  let K:=manuscriptEndpointBudget d C r ℓ ε
  have hK:(C:ℝ)+Real.log (1/ε)≤K:=manuscriptEndpointBudget_lower hf.1 hℓ hε hε1
  have hK0:0≤K:=by have:=Nat.cast_nonneg C (α:=ℝ);linarith
  let V:=A*(1+(d:ℝ)+K)^m
  have hV0:0≤V:=by dsimp [V];positivity
  have henv:MainStatements.polynomialEnvelope A m d C (Real.log (1/ε))≤V := by
    unfold MainStatements.polynomialEnvelope
    apply mul_le_mul_of_nonneg_left _ hA.le
    apply pow_le_pow_left₀ (by positivity)
    linarith
  have henergy:((r:ℝ)+2)*(V+1)≤
      manuscriptCombinedEnergy P (manuscriptEnlargedEndpoint r A m J₀) d C r ℓ ε := by
    apply le_trans _ (manuscriptCombinedEnergy_ge P (manuscriptEnlargedEndpoint r A m J₀) hf.1 hℓ hε hε1)
    change ((r:ℝ)+2)*(V+1)≤J₀ d K+((r:ℝ)+2)*(V+1)
    have hh:=hJ₀ d K (Nat.cast_nonneg d) hK0
    linarith
  have hcap:=manuscriptLogCapacity_dominates hd hℓ hV0 henergy
  apply hlearn φ hφ d hd f C hf D ε δ hε hε1 hδ hδ1 n
  apply le_trans _ hn
  apply mul_le_mul_of_nonneg_left _ (by positivity : (0:ℝ)≤2/ε)
  linarith

end NeuralGeneralization.BatchTwoActivation
