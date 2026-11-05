import NeuralGeneralization.GeneralMarginMain
import NeuralGeneralization.GeneralMarginPolynomialBounds

/-! Universal all-width polynomial learning for every admissible monotone
score transform, with the training margin and inverse endpoint gap added to the resources. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.GeneralMargin
open ConcreteModel RobustConfidence RobustMainAssembly

/-- The universal coefficient and degree precede all problem parameters.
The envelope adds the training margin and reciprocal transformed-score gap. -/
theorem polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ m u : ℝ,∀ F : ℝ → ℝ,Admissible m u F → ∀ d C r : ℕ,0 < d → ∀ B : LayeredBooleanCircuit d C r,
      ∀ c ε δ : ℝ,0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ n : ℕ,A*(polynomialBase d C r 1 m c ε δ (gap m u F))^k ≤ n →
      ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
        1-δ ≤ (CompressionSampling.iidSamples D n).real E ∧
        ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        ∀ globalMargin : Bool,
          0 < (smallPrior d N r σ).real (posteriorEvent m u F c globalMargin B.computes S) ∧
          gibbsMarginRisk D (posterior (N := N) (r := r) m u F c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) u ≤ ε/3 ∧
          D.real {x | correctConfidence (posterior (N := N) (r := r) m u F c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) u x ≤ (2/3:ℝ)} ≤ ε := by
  obtain ⟨A,hA,k,hpoly⟩ := sampleBudget_for_cost_polynomial
  refine ⟨A,hA,k,?_⟩
  intro m u F hF d C r hd B c ε δ hc hε hε1 hδ hδ1 D hD n hn
  letI := hD
  let K := digitalMassPolynomial d C r (c+m+1)
  let U := polynomialBase d C r 1 m c ε δ (gap m u F)
  obtain ⟨hU,hdU,hCU,hrU,hcU,hci,hei,hMlog,hδlog,hΔi,hcm⟩ :=
    polynomialBase_bounds d C r (by decide : 0 < 1) hF.train_pos.le hc hε hδ hδ1 hF.gap_pos
  have hKU : K ≤ 2000000000000*U^7 := by
    have hh := digitalMassPolynomial_le_base d C r hU hdU hCU hrU (show 0 ≤ c+m+1 by linarith [hF.train_pos]) hcm
    change K ≤ 1000000000000*U^7 at hh
    have hu0 : 0 ≤ U^7 := by positivity
    linarith
  have hnpos : 0 < n := by
    have hh : 0 < A*U^k := by positivity
    exact_mod_cast hh.trans_le hn
  have hb := (div_le_iff₀ (sq_pos_of_pos (by positivity : 0 < ε/12))).mp
    ((hpoly d C r 1 (by decide) m K c ε δ (gap m u F) hF.train_pos.le (digitalMassPolynomial_nonneg d C r (c+m+1))
      hc hε hε1 hδ hδ1 hF.gap_pos hKU).trans hn)
  simp only [Nat.cast_one,Real.log_one,zero_add] at hb
  apply learning hF hd B hc hε hε1 hδ D n hnpos
  have hlog : Real.log (2/δ) ≤ Real.log (4/δ) :=
    Real.log_le_log (by positivity) (div_le_div_of_nonneg_right (by norm_num) hδ.le)
  linarith

#print axioms polynomial
end NeuralGeneralization.GeneralMargin
