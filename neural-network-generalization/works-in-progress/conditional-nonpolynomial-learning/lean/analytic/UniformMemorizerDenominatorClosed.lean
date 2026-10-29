import UniformMemorizerDenominator
import UniformFinalBudget

/-! Uniform finite-width denominator bound for every physical prefactor
0<t≤1. There are no unproved analytic or statistical hypotheses. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace ConditionalNonpolynomial.Analytic
open NeuralGeneralization.ConcreteModel

/-- The width exponent and action-overhead constant are independent of the
physical prefactor, target, sample, input dimension, and network depth. H is
the number of hidden matrices after the first (seeded) hidden layer. -/
theorem exists_uniform_memorizer_denominator_constants :
    ∃W : ℕ,1≤W ∧ ∃C : ℝ,0<C ∧
    ∀(d n H N : ℕ) (sample : Fin n→Cube d) (f : BooleanFunction d) (R t : ℝ),
      1≤d→1≤H→2≤R→(d:ℝ)+1≤R→(n:ℝ)≤R→(H:ℝ)+1≤R→
      0<t→t≤1→6656*targetProgramConstant*Real.log R≤(H:ℝ)→
      (2:ℝ)^d*R^W≤(N:ℝ)→
      Real.exp (-(N:ℝ)*((H:ℝ)*subcriticalCostBaseline (t^2).toNNReal+scalarBaseline.toReal+
        C*(((t^2)⁻¹-1)*Real.log R+(Real.log R)^2/(H:ℝ))))≤
        posteriorDenominator Real.tanh (1/2) (smallPrior d N H (t/Real.sqrt N)) f sample := by
  obtain ⟨W,hW,hall⟩ := uniform_memorizer_denominator_of_budgets
    uniformFinalActionConstant uniformFinalWidthConstant
    uniformFinalActionConstant_pos uniformFinalWidthConstant_ge_one
    (fun t v R H ht ht1 hv hv1 hR hH hHR hT hlarge=>
      ⟨uniform_final_action_bound ht ht1 hv hv1 hR hH hT hlarge,
        uniform_final_width_bounds ht ht1 hv hv1 hR hH hHR hT⟩)
  exact ⟨W,hW,uniformFinalActionConstant,uniformFinalActionConstant_pos,hall⟩

#print axioms exists_uniform_memorizer_denominator_constants
end ConditionalNonpolynomial.Analytic
