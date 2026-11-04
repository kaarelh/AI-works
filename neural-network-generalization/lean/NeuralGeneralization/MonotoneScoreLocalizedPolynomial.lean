import NeuralGeneralization.MonotoneScoreLocalizedMain
import NeuralGeneralization.MonotoneScorePolynomialBounds
import NeuralGeneralization.RobustLocalizedPolynomial

/-! The arbitrary transformed-score localized theorem, with a universal
polynomial in the inverse gap and the exact union-conditioned Gaussian. -/
noncomputable section
namespace NeuralGeneralization.ScoreTransform.Localized
open ConcreteModel RobustMainAssembly RobustCompressionInput
open MeasureTheory ProbabilityTheory RobustConfidence

/-- The same fixed coefficient and degree work for every positive gap. -/
theorem sampleBudget_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ d C r M : ℕ,0 < M → ∀ c ε δ Δ : ℝ,
      0 < c → 0 < ε → ε < 1 → 0 < δ → δ < 1 → 0 < Δ →
      2*(Real.log (M:ℝ)+
        (resources d r (componentCost d C r M c ε) c ε Δ).entropyBudget+
        Real.log (4/δ))/(ε/12)^2 ≤ A*(polynomialBase d C r M c ε δ Δ)^k := by
  obtain ⟨A,hA,k,hpoly⟩ := sampleBudget_for_cost_polynomial
  refine ⟨A,hA,k,?_⟩
  intro d C r M hM c ε δ Δ hc hε hε1 hδ hδ1 hΔ
  apply hpoly d C r M hM (componentCost d C r M c ε) c ε δ Δ
    (componentCost_nonneg d C r hM c hε hε1) hc hε hε1 hδ hδ1 hΔ
  obtain ⟨hU,hd,hC,hr,hcU,hci,hei,hMlog,hδlog,hΔi⟩ :=
    polynomialBase_bounds d C r hM hc hε hδ hδ1 hΔ
  exact RobustLocalized.componentCost_le_base d C r hM hU hd hC hr hc hcU hε hei hMlog

/-- The paper's localized-union theorem: universal polynomial labeled
complexity, logarithmic-family validation complexity, and a single event
simultaneous in all eligible network widths and Gaussian scales. -/
theorem localized_union_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ F : ℝ → ℝ,Admissible F → ∀ d C r M : ℕ,0 < d → ∀ T : LayeredBooleanCircuit d C r,
      ∀ B : Fin M → Set (Cube d),∀ j0 : Fin M,B j0 = ∅ →
      ∀ c ρ ε δ : ℝ,0 < c → 0 ≤ ρ → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ m n : ℕ,2*(Real.log (M:ℝ)+Real.log (4/δ))/(ε/12)^2 ≤ m →
        A*(polynomialBase d C r M c ε δ (gap F))^k ≤ n →
      ∃ E : Set ((Fin m → Cube d) × (Fin n → Cube d)),MeasurableSet E ∧
        1-δ ≤ ((Measure.pi (fun _ : Fin m => D)).prod (Measure.pi (fun _ : Fin n => D))).real E ∧
        ∀ VS ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
          gibbsMarginRisk D (posterior (N := N) (r := r) F B c ρ σ T.computes VS.1 VS.2)
            (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) ≤ ρ+ε := by
  obtain ⟨A,hA,k,hpoly⟩ := sampleBudget_polynomial
  refine ⟨A,hA,k,?_⟩
  intro F hF d C r M hd T B j0 hzero c ρ ε δ hc hρ hε hε1 hδ hδ1 D hD m n hm hn
  letI := hD
  have hM : 0 < M := Nat.zero_lt_of_lt j0.isLt
  have hbase := (polynomialBase_bounds d C r hM hc hε hδ hδ1 hF.gap_pos).1
  have hnpos : 0 < n := by
    have hh : 0 < A*(polynomialBase d C r M c ε δ (gap F))^k := by positivity
    exact_mod_cast hh.trans_le hn
  have hlogM : 0 ≤ Real.log (M:ℝ) := Real.log_nonneg (by exact_mod_cast hM)
  have hlogδ : 0 < Real.log (4/δ) := Real.log_pos ((lt_div_iff₀ hδ).mpr (by linarith))
  have hmpos : 0 < m := by
    have hh : 0 < 2*(Real.log (M:ℝ)+Real.log (4/δ))/(ε/12)^2 := by positivity
    exact_mod_cast hh.trans_le hm
  have heps : 0 < (ε/12)^2 := sq_pos_of_pos (by positivity)
  apply localized_union_learning hF hd T B j0 hzero hc hρ hε hε1 hδ hδ1 D m n hmpos hnpos
  · exact (div_le_iff₀ heps).mp hm
  · exact (div_le_iff₀ heps).mp ((hpoly d C r M hM c ε δ (gap F) hc hε hε1 hδ hδ1 hF.gap_pos).trans hn)

/-- The same universal polynomial suffices when validation and training use
the same IID inputs. No independent validation data are required. -/
theorem localized_same_inputs_polynomial :
    ∃ A : ℝ,0 < A ∧ ∃ k : ℕ,
      ∀ F : ℝ → ℝ,Admissible F → ∀ d C r M : ℕ,0 < d → ∀ T : LayeredBooleanCircuit d C r,
      ∀ B : Fin M → Set (Cube d),∀ j0 : Fin M,B j0 = ∅ →
      ∀ c ρ ε δ : ℝ,0 < c → 0 ≤ ρ → 0 < ε → ε < 1 → 0 < δ → δ < 1 →
      ∀ D : Measure (Cube d),IsProbabilityMeasure D →
      ∀ n : ℕ,A*(polynomialBase d C r M c ε δ (gap F))^k ≤ n →
      ∃ E : Set (Fin n → Cube d),MeasurableSet E ∧
        1-δ ≤ (Measure.pi (fun _ : Fin n => D)).real E ∧
        ∀ S ∈ E,∀ N : ℕ,C ≤ N → ∀ σ : ℝ,0 < σ → (N:ℝ)*σ^2 ≤ 1 →
          gibbsMarginRisk D (posterior (N := N) (r := r) F B c ρ σ T.computes S S)
            (fun x => labelReal (T.computes x)) (networkOutput Real.tanh) (1/4) ≤ ρ+ε := by
  obtain ⟨A,hA,k,hpoly⟩ := sampleBudget_polynomial
  refine ⟨A,hA,k,?_⟩
  intro F hF d C r M hd T B j0 hzero c ρ ε δ hc hρ hε hε1 hδ hδ1 D hD n hn
  letI := hD
  have hM : 0 < M := Nat.zero_lt_of_lt j0.isLt
  have hbase := (polynomialBase_bounds d C r hM hc hε hδ hδ1 hF.gap_pos).1
  have hnpos : 0 < n := by
    have hh : 0 < A*(polynomialBase d C r M c ε δ (gap F))^k := by positivity
    exact_mod_cast hh.trans_le hn
  have hb := (div_le_iff₀ (sq_pos_of_pos (by positivity : 0 < ε/12))).mp
    ((hpoly d C r M hM c ε δ (gap F) hc hε hε1 hδ hδ1 hF.gap_pos).trans hn)
  apply localized_same_inputs hF hd T B j0 hzero hc hρ hε hε1 hδ D n hnpos _ hb
  have he : (0:ℝ) ≤ (resources d r (componentCost d C r M c ε) c ε (gap F)).entropyBudget := Nat.cast_nonneg _
  linarith

#print axioms localized_union_polynomial
#print axioms localized_same_inputs_polynomial
end NeuralGeneralization.ScoreTransform.Localized
