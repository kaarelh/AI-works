import ClosedConditionalImpossibility

noncomputable section
namespace ConditionalNonpolynomial.IndependentAudit
open NeuralGeneralization.ConcreteModel

/-- Independent expansion of the public theorem into the literal finite-width
network posterior and a strictly positive conditioning denominator. -/
theorem literalFiniteCounterexample
    (hsep : PPoly ≠ TC1) (T : CanonicalSchedule) (A : ℝ) (hA : 0<A) (k : ℕ) :
    ∃ d : ℕ, 1≤d ∧ ∃ r : ℕ, 1≤r ∧
    ∃ f : BooleanFunction d, ∃ C : ℕ,
      realizesAtComplexity (r:=r) Real.tanh f C ∧
    ∃ N : ℕ, C≤N ∧ ∃ D : InputLaw d, ∃ n : ℕ,
      A*(1+(d:ℝ)+(C:ℝ)+((r+2:ℕ):ℝ))^k≤(n:ℝ) ∧
      (1/2:ℝ)<sampleProbability D n (fun s=>
        (1/16:ℝ)<confidenceFailure D f
          (networkPosterior Real.tanh (1/2)
            (smallPrior d N r (T.scale d (r+2) N/Real.sqrt N)) f s)) ∧
      ∀s:Fin n→Cube d,0<posteriorDenominator Real.tanh (1/2)
        (smallPrior d N r (T.scale d (r+2) N/Real.sqrt N)) f s := by
  obtain ⟨d,hd,r,hr,f,C,hf,N,hCN,D,n,hn,hfail⟩:=
    conditionalCounterexamples hsep T A hA k
  refine ⟨d,hd,r,hr,f,C,hf,N,hCN,D,n,hn,?_,?_⟩
  · exact (successProbability_lt_half_iff T f D).mp hfail
  · exact canonical_posteriorDenominator_pos T hd hr f hf hCN

#print axioms Analytic.smallActionPathCapacity
#print axioms Analytic.actualLongNearcriticalPathCapacity
#print axioms Analytic.actualFarStrongPathCapacity
#print axioms uniformPathCircuitBound
#print axioms analyticPosteriorCeiling
#print axioms conditionalImpossibility
#print axioms conditionalCounterexamples
#print axioms literalFiniteCounterexample
end ConditionalNonpolynomial.IndependentAudit
