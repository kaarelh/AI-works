import NeuralGeneralization.SubcriticalMain
import NeuralGeneralization.ParityNetworkDepth

/-! The exponential lower bound applies to targets with explicitly polynomial
bounded-weight network complexity at the same fixed depth. -/
noncomputable section
open Filter
namespace NeuralGeneralization.MainProofs
open ConcreteModel MainStatements

/-- Full parity is a polynomial-complexity target, yet the actual subcritical
width-first posterior satisfies the exponential confidence lower bound. -/
theorem subcriticalSmallNetworkLowerBound (r : ℕ) (a : ℝ) (ha : 0<a) :
    ∃ c : ℝ, 0<c ∧ ∃ d₀ : ℕ, ∀ d : ℕ, d₀≤d → 1≤d →
      ∃ C : ℕ, isComplexity (r:=r) Real.tanh (parity d) C ∧ C≤32*(d+1)^2 ∧
      ∀ n : ℕ, (n:ℝ)≤Real.exp (c*(d:ℝ)) → ∀ γ : ℝ, γ<1 →
        (∀ᶠ N : ℕ in atTop, ∀ s : Fin n→Cube d,
          0<posteriorDenominator Real.tanh a (powerPrior d N r γ) (parity d) s) ∧
        (3/4:ℝ)≤sampleProbability (uniformLaw d) n (fun s =>
          (1/16:ℝ)≤Filter.liminf (parityFailure d r n a γ s) atTop) := by
  obtain ⟨c,hc,d₀,hd₀⟩ := subcriticalExponential r a ha
  refine ⟨c,hc,d₀,?_⟩
  intro d hd hd1
  obtain ⟨C,hC,hbound⟩ := ParityNetwork.exists_parity_complexity d r
  exact ⟨C,hC,hbound,hd₀ d hd hd1⟩

end NeuralGeneralization.MainProofs
