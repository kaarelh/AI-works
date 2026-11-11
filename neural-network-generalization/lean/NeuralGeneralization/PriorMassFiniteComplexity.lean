import NeuralGeneralization.PriorMassComplexity

/-! Positive unconditioned prior mass implies finite bounded-weight complexity.
This removes the finiteness premise from the inverse mass-complexity corollary.
No nonpolynomiality assumption on the activation is needed. -/
noncomputable section
open MeasureTheory
namespace NeuralGeneralization.ConcreteModel
open CompressionSampling

/-- Any strict-margin implementation admits a bounded-complexity realization. -/
theorem finite_complexity_of_margin_witness {d N r : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (w : Weights d N r)
    (hw : w ∈ marginEvent φ (1 / 2) f) :
    ∃ C, isComplexity (r := r) φ f C := by
  classical
  let K : ℕ := ⌈weightedSquaredNorm w⌉₊ + 1
  have hK : 1 ≤ K := by dsimp [K]; omega
  have he : weightedSquaredNorm w ≤ (K : ℝ) := by
    have h := Nat.le_ceil (weightedSquaredNorm w)
    dsimp [K]
    push_cast
    linarith
  obtain ⟨v, hv, hb, _⟩ := norm_compression hd hN hK φ hφ f w he hw
  have hex : ∃ C, realizesAtComplexity (r := r) φ f C :=
    ⟨compressionWidth d r K, compressionWidth_pos d r K hK, v, hv, hb⟩
  exact ⟨Nat.find hex, Nat.find_spec hex, fun C hC => Nat.find_min' hex hC⟩

/-- Positive raw mass, under any weight measure, supplies the needed witness. -/
theorem finite_complexity_of_positive_functionMass {d N r : ℕ}
    (hd : 1 ≤ d) (hN : 0 < N) (φ : ℝ → ℝ) (hφ : admissibleActivation φ)
    (f : BooleanFunction d) (μ : Measure (Weights d N r))
    (hp : 0 < functionMass φ (1 / 2) μ f) :
    ∃ C, isComplexity (r := r) φ f C := by
  have hne : (marginEvent (N := N) (r := r) φ (1 / 2) f).Nonempty := by
    by_contra h
    have he := Set.not_nonempty_iff_eq_empty.mp h
    simp only [functionMass, he, measure_empty, ENNReal.toReal_zero, lt_self_iff_false] at hp
  obtain ⟨w, hw⟩ := hne
  exact finite_complexity_of_margin_witness hd hN φ hφ f w hw

/-- The inverse inequality with no a priori finite-complexity hypothesis.
The constants are uniform in the activation, function, dimension, and width. -/
theorem finite_complexity_le_polynomial_powerMassComplexity
    (r : ℕ) (γ : ℝ) (hγ : 1 < γ) :
    ∃ A : ℝ, 0 < A ∧ ∃ k : ℕ, ∀ d N : ℕ, 1 ≤ d → 0 < N →
      ∀ φ : ℝ → ℝ, admissibleActivation φ → ∀ f : BooleanFunction d,
      0 < functionMass φ (1 / 2) (powerPrior d N r γ) f →
      ∃ C, isComplexity (r := r) φ f C ∧
        (C : ℝ) ≤ A * (1 + (d : ℝ) + powerMassComplexity (N := N) (r := r) φ γ f)^k := by
  obtain ⟨A, hA, k, hbound⟩ := complexity_le_polynomial_powerMassComplexity r γ hγ
  refine ⟨A, hA, k, ?_⟩
  intro d N hd hN φ hφ f hp
  obtain ⟨C, hC⟩ := finite_complexity_of_positive_functionMass hd hN φ hφ f _ hp
  exact ⟨C, hC, hbound d C N hd hN φ hφ f hC hp⟩

/-- The paper's matrix-depth convention, with finiteness obtained from raw mass. -/
theorem paper_finite_mass_complexity_corollary (L : ℕ) (_hL : 2 ≤ L)
    (γ : ℝ) (hγ : 1 < γ) :
    ∃ A : ℝ, 0 < A ∧ ∃ k : ℕ, ∀ d N : ℕ, 1 ≤ d → 1 ≤ N →
      ∀ φ : ℝ → ℝ, admissibleActivation φ → ∀ f : BooleanFunction d,
      0 < functionMass φ (1 / 2) (powerPrior d N (L - 2) γ) f →
      ∃ C, isComplexity (r := L - 2) φ f C ∧
        (C : ℝ) ≤ A * (1 + (d : ℝ) + powerMassComplexity (N := N) (r := L - 2) φ γ f)^k ∧
        ∀ N' : ℕ, C ≤ N' → ∀ γ' : ℝ, 1 ≤ γ' →
          0 < functionMass φ (1 / 2) (powerPrior d N' (L - 2) γ') f ∧
          powerMassComplexity (N := N') (r := L - 2) φ γ' f ≤
            2 * cylinderPolynomialCoefficient (L - 2) *
              (1 + (d : ℝ) + C)^cylinderPolynomialDegree (L - 2) := by
  obtain ⟨A, hA, k, hbound⟩ := finite_complexity_le_polynomial_powerMassComplexity (L - 2) γ hγ
  refine ⟨A, hA, k, ?_⟩
  intro d N hd hN φ hφ f hp
  obtain ⟨C, hC, hb⟩ := hbound d N hd hN φ hφ f hp
  refine ⟨C, hC, hb, ?_⟩
  intro N' hN' γ' hγ'
  exact ⟨(Real.exp_pos _).trans_le (powerPrior_target_mass_polynomial hd φ hφ f hC.1 hN' hγ'),
    powerMassComplexity_le_polynomial_complexity hd φ hφ f hC.1 hN' hγ'⟩

end NeuralGeneralization.ConcreteModel
