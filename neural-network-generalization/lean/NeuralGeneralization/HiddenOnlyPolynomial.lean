import NeuralGeneralization.HiddenOnlyMain
import NeuralGeneralization.MonotoneScorePolynomialBounds

/-! The full all-width Gaussian learning theorem for hidden-only support.
The fixed extra compression constant is absorbed into the universal coefficient,
so the polynomial has exactly the original problem parameters. -/
noncomputable section
open MeasureTheory ProbabilityTheory
namespace NeuralGeneralization.HiddenOnly
open ConcreteModel RobustConfidence RobustMainAssembly
open ScoreTransform (polynomialBase polynomialBase_bounds sampleBudget_for_cost_polynomial)

/-- The original polynomial envelope, with universal coefficient and degree,
for the literal hidden-only Gaussian-conditioned learner. -/
theorem polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ d C r : ℕ,0 < d → ∀ B : LayeredBooleanCircuit d C r,
      ∀ c ε δ : ℝ,0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ n : ℕ,RobustMainStatements.depthPolynomialEnvelope A k d C r c ε δ ≤ n →
      ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
        1-δ ≤ (CompressionSampling.iidSamples D n).real E ∧
        ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
        ∀ globalMargin : Bool,
          0 < (smallPrior d N r σ).real (posteriorEvent c globalMargin B.computes S) ∧
          gibbsMarginRisk D (posterior (N := N) (r := r) c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) ≤ ε/3 ∧
          D.real {x | correctConfidence (posterior (N := N) (r := r) c σ globalMargin B.computes S)
            (fun x => labelReal (B.computes x)) (networkOutput Real.tanh) (1/4) x ≤ (2/3:ℝ)} ≤ ε := by
  obtain ⟨A,hA,k,hpoly⟩ := sampleBudget_for_cost_polynomial
  refine ⟨A*24^k,by positivity,k,?_⟩
  intro d C r hd B c ε δ hc hε hε1 hδ hδ1 D hD n hn
  letI := hD
  let K := digitalMassPolynomial d C r c
  let U := polynomialBase d C r 1 c ε δ (1/20)
  obtain ⟨hU,hdU,hCU,hrU,hcU,hci,hei,hMlog,hδlog,hΔi⟩ :=
    polynomialBase_bounds d C r (by decide : 0 < 1) hc hε hδ hδ1 (by norm_num : (0:ℝ)<1/20)
  have hKU : K ≤ 2000000000000*U^7 := by
    have hh := digitalMassPolynomial_le_base d C r hU hdU hCU hrU hc.le hcU
    change K ≤ 1000000000000*U^7 at hh
    have hu0 : 0 ≤ U^7 := by positivity
    linarith
  have hbase := (mainPolynomialBase_bounds d C r hc hε hδ hδ1).1
  have hUbase : U ≤ 24*mainPolynomialBase d C r c ε δ := by
    dsimp [U,ScoreTransform.polynomialBase,RobustLocalized.polynomialBase]
    norm_num only [Nat.cast_one,Real.log_one,add_zero,one_div_div,div_one]
    linarith
  have hnU : A*U^k ≤ n := by
    apply le_trans _ hn
    change A*U^k ≤ (A*24^k)*(mainPolynomialBase d C r c ε δ)^k
    calc
      A*U^k ≤ A*(24*mainPolynomialBase d C r c ε δ)^k :=
        mul_le_mul_of_nonneg_left (pow_le_pow_left₀ (by positivity) hUbase k) hA.le
      _ = _ := by rw [mul_pow]; ring
  have hnpos : 0 < n := by
    have hh : 0 < A*U^k := by positivity
    exact_mod_cast hh.trans_le hnU
  have hb := (div_le_iff₀ (sq_pos_of_pos (by positivity : 0 < ε/12))).mp
    ((hpoly d C r 1 (by decide) K c ε δ (1/20) (digitalMassPolynomial_nonneg d C r c)
      hc hε hε1 hδ hδ1 (by norm_num : (0:ℝ)<1/20) hKU).trans hnU)
  simp only [Nat.cast_one,Real.log_one,zero_add] at hb
  apply learning hd B hc hε hε1 hδ D n hnpos
  have hlog : Real.log (2/δ) ≤ Real.log (4/δ) :=
    Real.log_le_log (by positivity) (div_le_div_of_nonneg_right (by norm_num) hδ.le)
  linarith

#print axioms polynomial
end NeuralGeneralization.HiddenOnly
