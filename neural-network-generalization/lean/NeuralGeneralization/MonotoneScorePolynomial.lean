import NeuralGeneralization.MonotoneScoreMain
import NeuralGeneralization.MonotoneScorePolynomialBounds

/-! Universal all-width polynomial learning for every admissible monotone
score transform, with only its inverse endpoint gap added to the resources. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.ScoreTransform
open ConcreteModel RobustConfidence RobustMainAssembly

/-- The universal coefficient and degree precede all problem parameters.
The envelope adds only the reciprocal transformed-score gap to the original parameters. -/
theorem polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ F : ℝ → ℝ,Admissible F → ∀ d C r : ℕ,0 < d → ∀ B : LayeredBooleanCircuit d C r,
      ∀ c ε δ : ℝ,0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ n : ℕ,A*(polynomialBase d C r 1 c ε δ (gap F))^k ≤ n →
      ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
        1-δ ≤ (CompressionSampling.iidSamples D n).real E ∧
        ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        ∀ globalMargin : Bool,
          0 < (smallPrior d N r σ).real (posteriorEvent F c globalMargin B.computes S) ∧
          gibbsMarginRisk D (posterior (N := N) (r := r) F c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε/3 ∧
          D.real {x | correctConfidence (posterior (N := N) (r := r) F c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ ε := by
  obtain ⟨A,hA,k,hpoly⟩ := sampleBudget_for_cost_polynomial
  refine ⟨A,hA,k,?_⟩
  intro F hF d C r hd B c ε δ hc hε hε1 hδ hδ1 D hD n hn
  letI := hD
  let K := digitalMassPolynomial d C r c
  let U := polynomialBase d C r 1 c ε δ (gap F)
  obtain ⟨hU,hdU,hCU,hrU,hcU,hci,hei,hMlog,hδlog,hΔi⟩ :=
    polynomialBase_bounds d C r (by decide : 0 < 1) hc hε hδ hδ1 hF.gap_pos
  have hKU : K ≤ 2000000000000*U^7 := by
    have hh := digitalMassPolynomial_le_base d C r hU hdU hCU hrU hc.le hcU
    change K ≤ 1000000000000*U^7 at hh
    have hu0 : 0 ≤ U^7 := by positivity
    linarith
  have hnpos : 0 < n := by
    have hh : 0 < A*U^k := by positivity
    exact_mod_cast hh.trans_le hn
  have hb := (div_le_iff₀ (sq_pos_of_pos (by positivity : 0 < ε/12))).mp
    ((hpoly d C r 1 (by decide) K c ε δ (gap F) (digitalMassPolynomial_nonneg d C r c)
      hc hε hε1 hδ hδ1 hF.gap_pos hKU).trans hn)
  simp only [Nat.cast_one,Real.log_one,zero_add] at hb
  apply learning hF hd B hc hε hε1 hδ D n hnpos
  have hlog : Real.log (2/δ) ≤ Real.log (4/δ) :=
    Real.log_le_log (by positivity) (div_le_div_of_nonneg_right (by norm_num) hδ.le)
  linarith

#print axioms polynomial
end NeuralGeneralization.ScoreTransform
